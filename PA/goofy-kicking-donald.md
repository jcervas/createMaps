Create a map of the infamous PA-07 "Goofy Kicking Donald Duck"
```
mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/congressional-district-boundaries/GeoJson/Pennsylvania_113_to_114.geojson' name=pa \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/us-urban.json' name=urban \
-style stroke=none fill='rgba(0,0,0,0.3)' \
-proj EPSG:3652 \
-target pa \
-proj match=urban \
-target pa \
-filter district==7 + name=pa07 \
-style stroke='rgba(239,58,71,0.8)' fill='rgba(239,58,71,0.5)' \
-clip target=urban source=pa07 \
-target urban,pa07 \
-o '/Users/cervas/Downloads/pa07.svg' \
-dissolve target=pa \
-style stroke=#941120 fill=#fff \
-style target=pa07 stroke=none fill=#000 \
-target pa,pa07 \
-o '/Users/cervas/Downloads/pa.svg'
```

