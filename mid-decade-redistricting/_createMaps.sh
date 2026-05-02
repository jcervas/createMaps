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





mapshaper \
-i '../states.json' name=states \
-i '../redistrict-map.csv' \
-join target=states source=redistrict-map keys=NAME,state \
-proj target=states albersusa \
-style fill=#F2F0EF stroke=#fff \
-filter target=states '[0].includes(mid_decade)' + name=rejected \
-filter target=states '["partisan"].includes(mid_decade)' + name=partisan \
-filter target=states '["court"].includes(mid_decade)' + name=court \
-filter target=states '["possible"].includes(mid_decade)' + name=possible \
-filter target=states '[999,null].includes(mid_decade)' + name=not \
-style target=rejected fill="#aaa" stroke=#fff fill-pattern='hatches 45deg 2px #aaa 2px #eee' \
-style target=partisan where='party=="dem"' fill='rgba(115,181,234,0.8)' stroke='rgba(115,181,234,1)' \
-style target=partisan where='party=="gop"' fill='rgba(238,141,140,0.8)' stroke='rgba(238,141,140,1)' \
-style target=court fill='rgba(253,181,21,0.8)' stroke='rgba(253,181,21,1)' \
-style target=court where='party=="dem"' fill='rgba(115,181,234,0.8)' stroke='rgba(0,0,0,1)' \
-style target=court where='party=="gop"' fill='rgba(238,141,140,0.8)' stroke='rgba(0,0,0,1)' \
-style target=not fill="#eee" stroke=#fff \
-style target=court where='status=="pending"' stroke='rgba(0,0,0,1)' fill-pattern='hatches 45deg 1px rgba(238,141,140,0.8) 1.5px #ddd' \
-style target=possible where='status=="pending"' stroke='rgba(255,255,255,1)' fill-pattern='hatches 45deg 1px rgba(238,141,140,0.8) 1.5px #ddd' \
-style target=partisan where='status=="pending"' stroke='rgba(238,141,140,1)' fill='rgba(238,141,140,0.1)' \
-dissolve target=states + name=US \
-style target=US fill=none stroke=#000 \
-o format=topojson target=not,rejected,partisan,court,US ../redistricting2026.json \
-o target=not,US ../svg/map_not.svg \
-o target=rejected,US ../svg/map_rejected.svg \
-o target=partisan,US ../svg/map_partisan.svg \
-o target=court,US ../svg/map_court.svg \
-o target=US,states,not,possible,rejected,partisan,court ../svg/redistricting2026.svg


-style target=redistricted fill='[1,2,3,4].includes(mid_decade) ? (mid_decade === 1 ? "#EF3A47" : mid_decade === 2 ? "#FDB515" : mid_decade === 3 ? "#003594" : mid_decade === 4 ? "#009647" : "none") : "#F2F0EF"' stroke=#000 \
-style target=states fill='[0,999].includes(mid_decade) ? (mid_decade === 0 ? "#008F91" : mid_decade === 999 ? "#ddd" : "none") : "#F2F0EF"' \
-dissolve target=states + name=US \
-style target=US fill=none stroke=#000 \
-o target=states,redistricted,US redistricting2026.svg



