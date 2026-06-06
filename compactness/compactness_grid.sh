#!/bin/bash
# compactness_grid.sh
# Rasterizes the 25 ranked SVGs and assembles them into a 5x5 PNG grid.
# Each cell is labelled with rank, plan name, district, and Polsby-Popper score.
#
# Requires: qlmanage (macOS built-in), python3 + Pillow

set -euo pipefail

SVG_DIR="compactness_svgs"
TOP25_CSV="compactness_results_top25.csv"
OUTPUT_PNG="compactness_grid.png"
CELL_SIZE=400   # px per cell before padding
TMPDIR_LOCAL=$(mktemp -d)
trap 'rm -rf "$TMPDIR_LOCAL"' EXIT

if [[ ! -f "$TOP25_CSV" ]]; then
  echo "Error: $TOP25_CSV not found. Run compactness.sh first."
  exit 1
fi

echo "Rasterizing SVGs..."
while IFS=',' read -r rank plan district_id pp; do
  safe_id=$(echo "$district_id" | tr -d ' "')
  svg="${SVG_DIR}/rank${rank}_${plan}_district${safe_id}.svg"
  if [[ ! -f "$svg" ]]; then
    echo "  [SKIP] $svg not found"
    continue
  fi
  qlmanage -t -s "$CELL_SIZE" -o "$TMPDIR_LOCAL" "$svg" >/dev/null 2>&1
done < <(tail -n +2 "$TOP25_CSV")

echo "Assembling 5x5 grid..."

python3 - "$TMPDIR_LOCAL" "$TOP25_CSV" "$OUTPUT_PNG" "$CELL_SIZE" <<'PYEOF'
import sys, os, re, csv
from PIL import Image, ImageDraw, ImageFont

tmp_dir   = sys.argv[1]
csv_path  = sys.argv[2]
out_path  = sys.argv[3]
cell_size = int(sys.argv[4])

COLS, ROWS = 5, 5
PAD        = 12   # padding inside each cell
LABEL_H    = 52   # height reserved for label at bottom of cell
BORDER     = 2    # border between cells
BG         = (255, 255, 255)
BORDER_COL = (200, 200, 200)

cell_w = cell_size + PAD * 2
cell_h = cell_size + PAD * 2 + LABEL_H
canvas_w = COLS * cell_w + (COLS + 1) * BORDER
canvas_h = ROWS * cell_h + (ROWS + 1) * BORDER

canvas = Image.new("RGB", (canvas_w, canvas_h), BG)
draw = ImageDraw.Draw(canvas)

# Draw grid lines
for col in range(COLS + 1):
    x = col * (cell_w + BORDER)
    draw.rectangle([x, 0, x + BORDER - 1, canvas_h], fill=BORDER_COL)
for row in range(ROWS + 1):
    y = row * (cell_h + BORDER)
    draw.rectangle([0, y, canvas_w, y + BORDER - 1], fill=BORDER_COL)

try:
    font_label = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
    font_rank  = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18)
except:
    font_label = ImageFont.load_default()
    font_rank  = font_label

with open(csv_path) as f:
    entries = list(csv.DictReader(f))

for entry in entries:
    rank       = int(entry['rank'])
    plan       = entry['plan']
    district_id = entry['district_id'].strip().strip('"')
    pp         = float(entry['pp'])

    safe_id = re.sub(r'[\s"]', '', district_id)
    # qlmanage appends .png to the full filename
    svg_name = f"rank{rank}_{plan}_district{safe_id}.svg.png"
    png_path = os.path.join(tmp_dir, svg_name)

    col = (rank - 1) % COLS
    row = (rank - 1) // COLS
    cell_x = BORDER + col * (cell_w + BORDER)
    cell_y = BORDER + row * (cell_h + BORDER)

    # Draw white cell background
    draw.rectangle([cell_x, cell_y, cell_x + cell_w - 1, cell_y + cell_h - 1], fill=BG)

    if os.path.exists(png_path):
        img = Image.open(png_path).convert("RGBA")
        # Fit district image into cell_size × cell_size preserving aspect ratio
        img.thumbnail((cell_size, cell_size), Image.LANCZOS)
        # Centre it in the cell
        ix = cell_x + PAD + (cell_size - img.width)  // 2
        iy = cell_y + PAD + (cell_size - img.height) // 2
        # Composite onto white background (handles transparency)
        bg_patch = Image.new("RGBA", img.size, (255, 255, 255, 255))
        bg_patch.paste(img, mask=img.split()[3])
        canvas.paste(bg_patch.convert("RGB"), (ix, iy))
    else:
        draw.text((cell_x + PAD, cell_y + PAD + cell_size // 2),
                  "image not found", font=font_label, fill=(180, 0, 0))

    # Label: rank + plan + district + PP score
    label_y = cell_y + PAD + cell_size + 4
    draw.text((cell_x + PAD, label_y),
              f"#{rank}  {plan}  D{district_id}",
              font=font_rank, fill=(30, 30, 30))
    draw.text((cell_x + PAD, label_y + 22),
              f"Polsby-Popper: {pp:.4f}",
              font=font_label, fill=(80, 80, 80))

canvas.save(out_path, "PNG", dpi=(150, 150))
print(f"Saved: {out_path}  ({canvas.width}×{canvas.height} px)")
PYEOF
