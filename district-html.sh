jq -r '.features[].properties.id' \
'/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/mid-decade-redistricting/mid-decade/SC-2026-Proposal.geojson' \
| sort -n | uniq |
while read -r i; do

echo "Processing newdistrict $i"

mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/mid-decade-redistricting/mid-decade/SC-2026-Proposal.geojson' name=newplan \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/sc-cd-2022.geojson' name=oldplan \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/us-counties.json' name=us-counties \
-target us-counties \
-proj albersusa densify \
-dissolve STUSPS copy-fields=STATE_NAME,STUSPS + name=us-state \
-each 'labelled = STUSPS!="SC"' \
-filter 'STUSPS=="SC"' + name=focus-state \
-target newplan \
-proj albersusa densify \
-clip us-counties \
-target oldplan \
-proj albersusa densify \
-clip us-counties \
-target newplan \
-filter "id==$i" + name=newdistrict \
-target oldplan \
-filter "id==$i" + name=olddistrict \
-merge-layers target=newdistrict,olddistrict name=districts_both \
-dissolve \
-each 'area="TRUE"' \
-frame height=400 width=600 offset=4% name=rectangle \
-target newplan \
-filter "id==$i" + name=newdistrict \
-lines + name=newdistrict_lines \
-style fill=none stroke=#000 \
-target oldplan \
-filter "id==$i" + name=olddistrict \
-lines + name=olddistrict_lines \
-style fill=none stroke=#aaa \
-style target=olddistrict fill-pattern="dashes 45deg 1px 1px 1px rgba(168,168,168,0.5) 4px rgba(255,255,255,0.99)" "stroke=none" \
-style target=newdistrict "fill=rgba(255,255,255,1)" "stroke=#000" \
-target us-state \
-clip rectangle \
-filter 'STUSPS!="SC"' remove-empty \
-points inner + name=st-labels \
-style target=st-labels label-text='STATE_NAME.toUpperCase()' dy=4 fill='#aaa' font-size=14px \
-target us-counties \
-clip rectangle \
-target us-counties \
-filter 'STUSPS=="SC"' \
-filter 'STUSPS=="SC"' + name=labels \
-calc 'TOTAL=sum($.area)' \
-each 'labelled = $.area > TOTAL/40' \
-join target=labels source=districts_both point-method \
-points inner \
-filter 'area == "TRUE"' \
-filter labelled \
-target us-counties \
-lines + name=borders \
-style target=borders stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' stroke-dasharray='4 2' \
-filter 'TYPE=="inner"' \
-style target=us-state fill='STUSPS=="SC" ? "none" : "#ccc"' stroke=none \
-innerlines + name=st-lines \
-style 'stroke="rgba(0,0,0,0.7)"' \
-style target=rectangle fill='rgba(160,216,242,1)' stroke=none \
-style target=labels label-text='NAME.toUpperCase()' dy=4 fill='#aaa' font-size=10px \
-style target=newplan fill="id==$i ? '#fff' : '#ececec'" opacity=1 stroke=none \
-o target=rectangle,us-state,newplan,newdistrict,olddistrict,st-labels,labels,borders,olddistrict_lines,newdistrict_lines,st-lines \
"/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/districts/district${i}.svg" \
-target newdistrict \
-style clear \
-style fill='#fff' stroke=none opacity=1 \
-target olddistrict \
-style clear \
-style fill='#fff' stroke=none opacity=1 \
-style target=focus-state fill='#ececec' stroke='#aaa' \
-frame height=100 width=150 offset=4% name=state-frame \
-style fill=none stroke=none \
-target rectangle \
-rectangle \
-style fill=none stroke="#000" \
-o target=state-frame,focus-state,newdistrict,olddistrict,rectangle \
"/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/districts/st-district${i}.svg"

done


cat > index.html <<'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>newdistrict Maps</title>

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
}
</style>
</head>

<body>

<h1>newdistrict Maps</h1>

<div class="grid">
EOF

for file in newdistrict*.svg; do
    num=$(echo "$file" | sed 's/newdistrict\([0-9]*\)\.svg/\1/')

cat >> index.html <<EOF
<div class="card">
    <div class="label">newdistrict $num</div>

    <div class="maps">
        <div class="main-map">
            <img src="$file">
        </div>

        <div class="inset-map">
            <img src="st-newdistrict$num.svg">
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