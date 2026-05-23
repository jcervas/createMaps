jq -r '.features[].properties.id' \
'/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/mid-decade-redistricting/mid-decade/SC-2026-Proposal.geojson' \
| sort -n | uniq |
while read -r i; do

echo "Processing district $i"

mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/mid-decade-redistricting/mid-decade/SC-2026-Proposal.geojson' name=plan \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/us-counties.json' name=us-counties \
-target us-counties \
-proj albersusa densify \
-dissolve STUSPS copy-fields=STATE_NAME,STUSPS + name=us-state \
-filter 'STUSPS=="SC"' + name=focus-state \
-target plan \
-proj albersusa densify \
-clip us-counties \
-target plan \
-filter "id==$i" + name=district \
-frame height=400 width=600 offset=4% name=rectangle \
-target us-counties \
-clip rectangle \
-target us-counties \
-filter 'STUSPS=="SC"' \
-each 'labelled = this.area > 1e9' \
-points inner + name=labels \
-filter labelled \
-target us-counties \
-lines + name=borders \
-style target=borders stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' stroke-dasharray='4 2' \
-filter 'TYPE=="inner"' \
-target us-state \
-each 'labelled = STUSPS!="SC"' \
-points inner + name=st-labels \
-filter labelled \
-style target=st-labels label-text='STATE_NAME.toUpperCase()' dy=4 fill='#aaa' font-size=14px \
-style target=us-state fill='STUSPS=="SC" ? "none" : "#ccc"' stroke=#000 \
-style target=rectangle fill='rgba(160,216,242,1)' stroke=#000 \
-style target=labels label-text='NAME.toUpperCase()' dy=4 fill='#aaa' font-size=10px \
-style target=plan fill="id==$i ? '#fff' : '#ececec'" opacity=1 \
-o target=rectangle,us-state,plan,borders,st-labels,labels \
"/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/districts/district${i}.svg" \
-target district \
-style fill='#fff' opacity=1 \
-style target=focus-state fill='#000' stroke=none \
-frame height=100 width=150 offset=4% name=state-frame \
-style fill=none stroke=none \
-o target=state-frame,focus-state,district \
"/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/districts/st-district${i}.svg"

done


cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>District Maps</title>

<style>
body {
    font-family: Arial, sans-serif;
    margin: 40px;
    background: #f5f5f5;
}

.grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(520px, 1fr));
    gap: 40px;
}

.card {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
}

.label {
    font-size: 28px;
    font-weight: bold;
    margin-bottom: 20px;
    text-align: center;
}

.maps {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 24px;
}

.main-map img {
    width: 400px;
    height: auto;
}

.inset-map img {
    width: 120px;
    height: auto;
    border: 1px solid #ccc;
}
</style>
</head>

<body>

<h1>District Maps</h1>

<div class="grid">
EOF

for file in district*.svg; do
    num=$(echo "$file" | sed 's/district\([0-9]*\)\.svg/\1/')

cat >> index.html <<EOF
<div class="card">
    <div class="label">District $num</div>

    <div class="maps">
        <div class="main-map">
            <img src="$file">
        </div>

        <div class="inset-map">
            <img src="st-district$num.svg">
        </div>
    </div>
</div>
EOF

done

cat >> index.html <<'EOF'
</div>

</body>
</html>
EOF

open index.html