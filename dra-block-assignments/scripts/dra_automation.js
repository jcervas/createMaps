/**
 * dra_automation.js — Browser automation for downloading DRA Official Map
 * block assignment CSVs.
 *
 * HOW TO USE
 * ----------
 * 1. Start the local server:
 *      python3 scripts/dra_server.py
 *
 * 2. Open Chrome and log in to davesredistricting.org.
 *
 * 3. Navigate to the Official Maps list:
 *      https://davesredistricting.org/maps#list::Official-Maps
 *
 * 4. Open DevTools → Console and paste this entire file.
 *
 * 5. Run (from the top, all plans):
 *      runV3(0)
 *
 *    Or resume from a specific index (e.g. after a crash):
 *      runV3(86)
 *
 * 6. Monitor progress:
 *      ({index: window._dra3.index, saved: window._dra3.saved.length,
 *        errors: window._dra3.errors.length, done: window._dra3.done})
 *
 * 7. To stop early:
 *      window._STOP = true
 *
 * WHAT IT DOES
 * ------------
 * - Fetches the full plan list from data.dra2020.net/_state_plans.json
 * - For each plan, navigates to #viewmap::{id} and waits for data to load
 *   (detected by: no "Retrieving…" spinner + Export button visible + table
 *   has non-zero population values)
 * - Intercepts the CSV anchor click before the browser can download it,
 *   captures the text, and POSTs it to localhost:9001 (dra_server.py)
 * - Saves as {title}.csv — same name shown in DRA's UI
 * - Logs progress to window._dra3.log; errors to window._dra3.errors
 *
 * KNOWN ISSUES
 * ------------
 * - HI maps consistently fail to load (DRA server-side issue, not this script)
 * - Some 116th-Congress plans have duplicate entries in _state_plans.json
 *   with different year values but the same ID — only one file is saved
 * - If the page goes blank (React crash), reload and re-paste this script,
 *   then call runV3(window._dra3.saved.length) to resume from where you left off
 */

// ─── Anchor intercept ────────────────────────────────────────────────────────
// Must be installed before any Export clicks. Prevents the browser from
// triggering a file download and instead captures the CSV text in memory.
(function installAnchorIntercept() {
  const origCreate = document.createElement.bind(document);
  document.createElement = function (tag) {
    const el = origCreate(tag);
    if (tag.toLowerCase() === 'a') {
      const origClick = el.click.bind(el);
      el.click = function () {
        if (el.download && el.href &&
            (el.href.startsWith('blob:') || el.href.startsWith('data:'))) {
          const href = el.href;
          el.href = 'javascript:void(0)';
          if (href.startsWith('blob:')) {
            fetch(href).then(r => r.text()).then(txt => {
              window._lastCapturedCSV = txt;
              if (window._csvCallback) { window._csvCallback(txt); window._csvCallback = null; }
            });
          } else {
            const txt = decodeURIComponent(href.split(',').slice(1).join(','));
            window._lastCapturedCSV = txt;
            if (window._csvCallback) { window._csvCallback(txt); window._csvCallback = null; }
          }
          return;
        }
        return origClick();
      };
    }
    return el;
  };
  console.log('[DRA] Anchor intercept installed');
})();

// ─── Helpers ─────────────────────────────────────────────────────────────────

/** Sleep that checks window._STOP every 200 ms so the loop can be killed. */
function draSlp(ms) {
  return new Promise(res => {
    const step = 200;
    let elapsed = 0;
    const iv = setInterval(() => {
      if (window._STOP) { clearInterval(iv); res(); return; }
      elapsed += step;
      if (elapsed >= ms) { clearInterval(iv); res(); }
    }, step);
  });
}

/**
 * Returns true when the currently loaded map has finished fetching its data:
 *   1. No "Retrieving N data files…" spinner
 *   2. Export button visible in the top toolbar
 *   3. At least one table cell has a non-zero integer value (population data)
 */
function isDataLoaded() {
  const spin = Array.from(document.querySelectorAll('span'))
    .find(s => s.textContent.trim().startsWith('Retrieving'));
  if (spin) return false;

  const exportBtn = Array.from(document.querySelectorAll('button'))
    .find(b => b.getAttribute('aria-label') === 'Export' &&
               b.getBoundingClientRect().top < 50);
  if (!exportBtn) return false;

  for (const td of document.querySelectorAll('td')) {
    if (parseInt(td.textContent.replace(/,/g, ''), 10) > 0) return true;
  }
  return false;
}

/**
 * Clicks the Export button, waits for the dialog, clicks "Export" inside it,
 * and resolves with the captured CSV text.
 */
function captureCSV(timeout = 35000) {
  return new Promise((resolve, reject) => {
    const t = setTimeout(() => {
      window._csvCallback = null;
      reject(new Error('csv_timeout'));
    }, timeout);

    window._csvCallback = txt => { clearTimeout(t); resolve(txt); };

    const exportBtn = Array.from(document.querySelectorAll('button'))
      .find(b => b.getAttribute('aria-label') === 'Export' &&
                 b.getBoundingClientRect().top < 50);
    if (!exportBtn) {
      clearTimeout(t); window._csvCallback = null;
      reject(new Error('no_export_icon')); return;
    }
    exportBtn.click();

    setTimeout(() => {
      const dialog = document.querySelector('[role="dialog"]');
      if (!dialog) {
        clearTimeout(t); window._csvCallback = null;
        reject(new Error('no_dialog')); return;
      }
      const btn = Array.from(dialog.querySelectorAll('button'))
        .find(b => b.textContent.trim() === 'Export');
      if (btn) btn.click();
      else {
        clearTimeout(t); window._csvCallback = null;
        reject(new Error('no_dialog_btn'));
      }
    }, 700);
  });
}

/** POSTs the captured CSV to the local dra_server.py receiver. */
async function postToServer(plan, csv) {
  const r = await fetch('http://localhost:9001', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      title:    plan.title,
      id:       plan.id,
      state:    plan.stateCode || plan.state,
      planType: plan.planType,
      csv,
    }),
  });
  return r.json();
}

// ─── Main loop ───────────────────────────────────────────────────────────────

/**
 * Download block assignment CSVs for all Official Maps.
 *
 * @param {number} startFrom  Index to start at (0 = beginning). Use a saved
 *                            count after a crash to resume without duplicating.
 */
async function runV3(startFrom = 0) {
  const dra = window._dra3 = {
    plans: [], index: 0, log: [], saved: [], errors: [], running: true, done: false,
  };

  // Load the full plan list
  const resp = await fetch('https://data.dra2020.net/file/dra-datafiles/_state_plans.json');
  const raw  = await resp.json();
  // Each state key has a .plans array
  dra.plans  = Object.values(raw).flatMap(s => s.plans || []).filter(p => p?.id && p?.title);
  dra.log.push(`Loaded ${dra.plans.length} plans; starting from index ${startFrom}`);

  for (let i = startFrom; i < dra.plans.length; i++) {
    if (window._STOP) break;
    dra.index    = i;
    const plan   = dra.plans[i];

    window.location.hash = '#viewmap::' + plan.id;
    await draSlp(2000);

    // Wait for map data (up to 30 s)
    const start = Date.now();
    while (!isDataLoaded() && Date.now() - start < 30000) {
      if (window._STOP) throw new Error('killed');
      await draSlp(500);
    }

    if (!isDataLoaded()) {
      dra.log.push(`[${i + 1}/${dra.plans.length}] ${plan.title}: NOT_LOADED`);
      dra.errors.push({ ...plan, reason: 'load_failed' });
      continue;
    }

    dra.log.push(`[${i + 1}/${dra.plans.length}] ${plan.title}: loaded`);

    try {
      const csv  = await captureCSV(35000);
      const rows = (csv.match(/\n/g) || []).length;
      await postToServer(plan, csv);
      dra.saved.push({ title: plan.title, id: plan.id, rows });
      dra.log.push(`  → saved ${rows} rows`);
    } catch (e) {
      dra.log.push(`  → ERROR: ${e.message}`);
      dra.errors.push({ ...plan, reason: e.message });
    }

    await draSlp(500);
  }

  dra.done    = !window._STOP;
  dra.running = false;
  dra.log.push(dra.done ? 'COMPLETE' : 'STOPPED');
  console.log(`[DRA] ${dra.done ? 'Complete' : 'Stopped'} — saved: ${dra.saved.length}, errors: ${dra.errors.length}`);
}
