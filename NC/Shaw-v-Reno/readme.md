Create a map of the infamous NC-12 racial gerrymander
```
mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/congressional-district-boundaries/GeoJson/North Carolina_103_to_105.geojson' name=nc \
-proj EPSG:2264 \
-filter district==12 + name=nc12 \
-style stroke='rgba(239,58,71,1)' fill='rgba(239,58,71,0.9)' \
-target nc12 \
-o '/Users/cervas/Downloads/nc12.svg' \
-rectangle target=nc12 offset=4% + name=rectangle \
-style target=rectangle fill=none stroke=#000 \
-dissolve target=nc \
-style stroke=#941120 fill=none \
-target nc,rectangle,nc12 \
-o '/Users/cervas/Downloads/nc.svg'
```

