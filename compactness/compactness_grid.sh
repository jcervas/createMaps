#!/bin/bash
# compactness_grid.sh
# Rasterizes ranked SVGs and assembles them into a PNG grid (5 columns, N rows).
# Reads however many SVGs exist in compactness_svgs/ that match the ranked CSV.
# Each cell is labelled with rank, plan, district, PP score, and Reock score.
#
# Requires: qlmanage (macOS built-in), python3 + Pillow

set -euo pipefail

SVG_DIR="compactness_svgs"
RANKED_CSV="compactness_results_ranked.csv"
OUTPUT_PNG="compactness_grid.png"
CELL_SIZE=400      # px per cell (before padding)
GRID_COLS=5        # number of columns in the grid

TMPDIR_LOCAL=$(mktemp -d)
trap 'rm -rf "$TMPDIR_LOCAL"' EXIT

if [[ ! -f "$RANKED_CSV" ]]; then
  echo "Error: $RANKED_CSV not found. Run compactness.sh first."
  exit 1
fi

echo "Rasterizing SVGs..."
count=0
while IFS=',' read -r rank plan district_id rest; do
  safe_id=$(echo "$district_id" | tr -d ' "')
  svg="${SVG_DIR}/rank${rank}_${plan}_district${safe_id}.svg"
  if [[ ! -f "$svg" ]]; then
    continue   # silently skip — only rasterize what was actually generated
  fi
  qlmanage -t -s "$CELL_SIZE" -o "$TMPDIR_LOCAL" "$svg" >/dev/null 2>&1
  count=$((count + 1))
done < <(tail -n +2 "$RANKED_CSV")
echo "  Rasterized $count SVGs"

echo "Assembling grid ($GRID_COLS columns)..."

python3 - "$TMPDIR_LOCAL" "$RANKED_CSV" "$SVG_DIR" "$OUTPUT_PNG" "$CELL_SIZE" "$GRID_COLS" <<'PYEOF'
import sys, os, re, csv, math
from PIL import Image, ImageDraw, ImageFont

tmp_dir   = sys.argv[1]
csv_path  = sys.argv[2]
svg_dir   = sys.argv[3]
out_path  = sys.argv[4]
cell_size = int(sys.argv[5])
cols      = int(sys.argv[6])

PAD        = 12   # padding inside each cell
LABEL_H    = 52   # height reserved for label text
BORDER     = 2    # px between cells
BG         = (255, 255, 255)
BORDER_COL = (200, 200, 200)

# Load all ranked entries that have a corresponding SVG
with open(csv_path) as f:
    all_entries = list(csv.DictReader(f))

entries = []
for entry in all_entries:
    rank        = int(entry['rank'])
    plan        = entry['plan']
    district_id = entry['district_id'].strip().strip('"')
    safe_id     = re.sub(r'[\s"]', '', district_id)
    svg_name    = f"rank{rank}_{plan}_district{safe_id}.svg.png"
    png_path    = os.path.join(tmp_dir, svg_name)
    if os.path.exists(png_path):
        entries.append((entry, png_path))

n    = len(entries)
rows = math.ceil(n / cols)

cell_w   = cell_size + PAD * 2
cell_h   = cell_size + PAD * 2 + LABEL_H
canvas_w = cols * cell_w + (cols + 1) * BORDER
canvas_h = rows * cell_h + (rows + 1) * BORDER

print(f"  Grid: {cols} cols × {rows} rows = {n} cells  ({canvas_w}×{canvas_h} px)")

canvas = Image.new("RGB", (canvas_w, canvas_h), BG)
draw   = ImageDraw.Draw(canvas)

# Grid lines
for c in range(cols + 1):
    x = c * (cell_w + BORDER)
    draw.rectangle([x, 0, x + BORDER - 1, canvas_h], fill=BORDER_COL)
for r in range(rows + 1):
    y = r * (cell_h + BORDER)
    draw.rectangle([0, y, canvas_w, y + BORDER - 1], fill=BORDER_COL)

try:
    font_label = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
    font_rank  = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18)
except Exception:
    font_label = ImageFont.load_default()
    font_rank  = font_label

for i, (entry, png_path) in enumerate(entries):
    rank        = int(entry['rank'])
    plan        = entry['plan']
    district_id = entry['district_id'].strip().strip('"')
    pp          = float(entry['polsby_popper'])
    reock       = float(entry['reock'])

    col    = i % cols
    row    = i // cols
    cell_x = BORDER + col * (cell_w + BORDER)
    cell_y = BORDER + row * (cell_h + BORDER)

    draw.rectangle([cell_x, cell_y, cell_x + cell_w - 1, cell_y + cell_h - 1], fill=BG)

    img = Image.open(png_path).convert("RGBA")
    img.thumbnail((cell_size, cell_size), Image.LANCZOS)
    ix = cell_x + PAD + (cell_size - img.width)  // 2
    iy = cell_y + PAD + (cell_size - img.height) // 2
    bg_patch = Image.new("RGBA", img.size, (255, 255, 255, 255))
    bg_patch.paste(img, mask=img.split()[3])
    canvas.paste(bg_patch.convert("RGB"), (ix, iy))

    label_y = cell_y + PAD + cell_size + 4
    draw.text((cell_x + PAD, label_y),
              f"#{rank}  {plan}  D{district_id}",
              font=font_rank, fill=(30, 30, 30))
    draw.text((cell_x + PAD, label_y + 22),
              f"PP: {pp:.4f}   Reock: {reock:.4f}",
              font=font_label, fill=(80, 80, 80))

canvas.save(out_path, "PNG", dpi=(150, 150))
print(f"Saved: {out_path}  ({canvas.width}×{canvas.height} px)")
PYEOF
