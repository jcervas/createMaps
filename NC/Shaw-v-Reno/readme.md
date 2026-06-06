Create a map of the infamous state-12 racial gerrymander
```
mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/congressional-district-boundaries/GeoJson/North Carolina_103_to_105.geojson' name=state \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/us-urban.json' name=urban \
-style stroke=none fill='rgba(0,0,0,0.1)' \
-proj EPSG:2264 \
-target state \
-proj match=urban \
-target state \
-filter district==12 + name=district \
-style stroke='rgba(239,58,71,0.6)' fill='rgba(239,58,71,0.3)' \
-clip target=urban source=district \
-target urban,district \
-o '/Users/cervas/Downloads/nc12.svg' \
-dissolve target=state \
-style stroke=#941120 fill=#fff \
-style target=district stroke=none fill=#000 \
-target state,district \
-o '/Users/cervas/Downloads/nc.svg'
```

