cd '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/mid-decade-redistricting/mid-decade'

mkdir -p clipped
mkdir -p svg

for f in *.geojson; do
base=$(basename "$f" .geojson)

mapshaper \
-i "$f" name=data \
-i '../states.json' name=states \
-clip target=data source=states \
-proj target=data albersusa \
-each DEM='DemPct / (DemPct + RepPct)' \
-each Party='DEM > 0.5 ? "DEM" : "GOP"' \
-each winning_pct_display='Party === "DEM" ? DEM * 100 : (1 - DEM) * 100' \
-style target=data fill='Party === "DEM" ? (winning_pct_display >= 65 ? "#1375B7" : winning_pct_display >= 60 ? "#5295CC" : winning_pct_display >= 55 ? "#92BDE0" : "#CEEAFD") : Party === "GOP" ? (winning_pct_display >= 65 ? "#C93135" : winning_pct_display >= 60 ? "#DB7171" : winning_pct_display >= 55 ? "#EAA9A9" : "#FCE0E0") : "none"' opacity=0.8 stroke=none \
-o target=data "clipped/${base}.json" \
-innerlines + name=inner \
-style target=inner stroke=#fff \
-o target=data,inner "svg/${base}.svg"
done



# ----------------------------
# Reusable styles (IMPORTANT: arrays)
# ----------------------------

DEM_STYLE=(
  "fill=rgba(115,181,234,0.6)"
)

DEM_BORDER=(
  "stroke=rgba(115,181,234,1)"
)

GOP_STYLE=(
  "fill=rgba(238,141,140,0.6)"
)

GOP_BORDER=(
  "stroke=rgba(238,141,140,1)"
  )

COURT_BASE=(
  "fill=rgba(253,181,21,0.6)"
  "stroke=rgba(253,181,21,1)"
)

OUTLINE_BLACK=(
  "stroke=rgba(0,0,0,1)"
)

REJECTED_STYLE=(
  "fill-pattern=hatches 45deg 2px #ddd 2px #eee"
)

PROPOSED=(
  "fill-pattern=hatches 45deg 2px none 2px #eee"
  "stroke-width=2"
)

PENDING_PATTERN=(
  "opacity=0.5"
)


mapshaper \
-i '../states.json' name=states \
-i '../redistrict-map.csv' \
-join target=states source=redistrict-map keys=NAME,state \
-proj target=states albersusa \
-lines + name=borders \
-style target=borders stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' \
-target states \
-style fill=none \
-style where='party=="dem"' "${DEM_STYLE[@]}" "${DEM_BORDER[@]}" \
-style where='party=="gop"' "${GOP_STYLE[@]}" "${GOP_BORDER[@]}" \
-style where='status=="blocked"' "${REJECTED_STYLE[@]}" \
-style where='party=="dem" && mid_decade=="court"' "${DEM_STYLE[@]}" "${DEM_BORDER[@]}" \
-style where='party=="gop" && mid_decade=="court"' "${GOP_STYLE[@]}" "${GOP_BORDER[@]}" \
-style where='status=="pending"' "${PENDING_PATTERN[@]}" \
-style where='status=="proposed"' "${PROPOSED[@]}" \
-dissolve + name=US \
-style fill='#fafafa' \
-o format=topojson target=states ../redistricting2026.json \
-o target=US,borders,states ../svg/redistricting2026.svg




