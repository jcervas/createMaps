
# 2024 North Carolina Congressional Map
![](images/cd2024.svg)

# 2026 North Carolina Congressional Map
![](images/cd2026.svg)



Import Block and Tract file with command `name=blocks`
```
cd '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/NC'

mapshaper \
-i 'GIS/tl_2025_37_tract.json' name=tracts \
-filter "ALAND>'0'" \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/tractscsv.csv' string-fields=GEOID20 \
-join target=tracts source=tractscsv keys=GEOIDFQ,GEO_ID force \
```

Run this to create a layer for counties
```
-dissolve target=tracts COUNTYFP + name=counties \
-innerlines \
-style target=counties fill=none stroke=#fff stroke-width=1 stroke-dasharray="0 3 0" \
```

Add Density Variable to data
```
-each target=tracts 'density = P1_001N / (ALAND/2589988)' \
-classify target=tracts field=density save-as=fill nice colors=greys classes=5 \
-dissolve target=tracts field=fill \
```

Add the Congressional District Shapefile with command `name=cd`
```
-i 'GIS/NC-2024.geojson' name=cd2024 \
-i 'GIS/NC-2026.geojson' name=cd2026 \
-style target=cd2024 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
-style target=cd2026 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
```


Load USA_MajorCities.geojson with command `name=cities`
```
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/USA_Major_Cities.geojson' name=cities \
-filter target=cities "ST=='NC'" \
-filter target=cities "POPULATION>=500000" \
-filter target=cities "POPULATION>=500000" + name=cities-labels \
-filter-fields target=cities,cities-labels NAME \
-style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-each target=cities-labels dx=5 \
-each target=cities-labels dy=0 \
-style target=cities r=4 \
-each target=cities "type='point'" \
-each target=cities-labels "type='text-label'" \
-merge-layers target=cities,cities-labels force \
-o target=cities 'cities.json' format=geojson \
```

Project all layers
```
-proj target=tracts,counties,cities,cd2024,cd2026 EPSG:2264 \
```

Label Districts
```
-each target=cd2024 'cx=this.innerX, cy=this.innerY' \
-points target=cd2024 x=cx y=cy + name=cd2024-labels \
-style target=cd2024-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
```

```
-each target=cd2026 'cx=this.innerX, cy=this.innerY' \
-points target=cd2026 x=cx y=cy + name=cd2026-labels \
-style target=cd2026-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
```

Clip Districts to Coastline
```
-clip target=cd2024 tracts \
-clip target=cd2026 tracts \
```

Colorizer
```
-colorizer name=fillColor breaks='1,2,3,4,5,6,7,8,9,10,11,12,13,14' colors='white,#e10000,#0000f8,#88ff6e,#00c3ff,#ffb800,#DC143C,#ff5700,#38ffbf,#dcff1b,#002eff,#ff2700,#62ff95,#ff8400,#11fae6' \

```


Output Population Density as .svg files
```
-o target=cities,counties,tracts 'images/tracts.svg' format=svg \
```


```
-svg-style target=cd2024 fill='fillColor(id)' \
-style target=cd2024 opacity=0.75 stroke=none \
-o target=tracts,cd2024,counties,cities,cd2024-labels 'images/cd2024.svg' \
```

```
-svg-style target=cd2026 fill='fillColor(id)' \
-style target=cd2026 opacity=0.75 stroke=none \
-o target=tracts,cd2026,counties,cities,cd2026-labels 'images/cd2026.svg'
```

```shell
find . -type f -name "*.svg" | while read -r f; do
  sed -i '' '/<\/svg>/i\
<style media="screen,print">\
.g-Shadow p { text-shadow: 1px 1px 0px rgba(254, 254, 254, .15); }\
.g-text-shadow { text-shadow: 1px 1px 1px rgba(254,254,254,1), -1px 1px 1px rgba(254,254,254,1), 1px -1px 1px rgba(254,254,254,1), -1px -1px 1px rgba(254,254,254,1); }\
</style>
' "$f"
done
```




Arrange labels and merge
```
-merge-layers target=* force
```

## Add css to .svg
```{css}
<style media="screen,print">
/* Custom CSS */
.g-Shadow p {
    text-shadow: 1px 1px 0px rgba(254, 254, 254, .15);
}

.g-text-shadow {
    text-shadow: 1px 1px 1px rgba(254, 254, 254, 1), -1px 1px 1px rgba(254, 254, 254, 1), 1px -1px 1px rgba(254, 254, 254, 1), -1px -1px 1px rgba(254, 254, 254, 1);
}
</style>
```
