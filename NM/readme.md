cd '/Users/cervas/My Drive/GitHub/createMaps/NM/images'

```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/censusAPI/censusAPI.R")
nm_blocks <- censusAPI(state="NM", geo="block", table="P4")
columns_to_remove <- grep("A$", colnames(nm_blocks))
data_filtered <- nm_blocks[, -columns_to_remove]
write.csv(data_filtered, "/Users/cervas/Library/Mobile Documents/com~apple~CloudDocs/Downloads/NM/blocks.csv")
```

Import Block or Tract file with command `name=tracts`
```
mapshaper \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/tracts.json' name=tracts \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/tractscsv.csv' name=tractscsv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/NM/blocks.json' name=blocks \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/blockscsv.csv' name=blockscsv string-fields=GEOID20 \
-simplify target=blocks 0.1 \
-join target=tracts source=tractscsv keys=GEOID20,GEOID20 \
-join target=blocks source=blockscsv keys=GEOID20,GEOID20 \
-filter target=blocks 'AWATER20>=ALAND20' + name=water \
-style target=water fill=#fff \
-dissolve target=tracts COUNTYFP20 + name=county \
-innerlines \
-style target=county fill=none stroke=#fff stroke-width=1 stroke-dasharray="0 3 0" \
-each target=tracts 'hispanicper=P4_002N/P4_001N*100' \
-each target=tracts 'density = P4_001N / (ALAND20/2589988)' \
-filter target=tracts 'STATEFP20 == "35"' + name=tracts_b \
-each target=blocks 'hispanicper=P4_002N/P4_001N*100' \
-each target=blocks 'density = P4_001N / (ALAND20/2589988)' \
-filter target=blocks 'STATEFP20 == "35"' + name=blocks_b \
-classify target=tracts field=density save-as=fill colors=greys classes=5 \
-classify target=tracts_b field=hispanicper save-as=fill nice colors='#ffffff,#5A5A5A' breaks=25,50,75 null-value="#fff" key-name="legend_HispanicVAP" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-classify target=blocks_b field=hispanicper save-as=fill nice colors='#eeeeee,#5A5A5A' breaks=50,75 null-value="#eeeeee" key-name="legend_HispanicVAP_blocks" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-style target=tracts_b opacity=1 \
-dissolve target=tracts field=fill \
-dissolve target=tracts_b field=fill \
-dissolve target=blocks_b field=fill \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/us-cart.json' name=us-cart \
-filter target=us-cart 'STATEFP == "35"' \
-style target=us-cart fill=none stroke=#000 opacity=1 stroke-opacity=1 \
```

```
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/plans/cd-2021.geojson' name=cd2021 \
-innerlines target=cd2021 + name=cd-lines \
-innerlines target=cd2021 + name=cd-lines2 \
-style target=cd-lines stroke-width=5 fill=none stroke-opacity=1 stroke=#000 \
-style target=cd-lines2 stroke-width=0.5 fill=none stroke-opacity=1 stroke=#fff \
-style target=cd2021 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/cities.json' name=cities \
-i '/Users/cervas/My Drive/GitHub/createMaps/NM/place.json' name=place \
-filter target=place '["Albuquerque","South Valley","Pajarito Mesa"].indexOf(NAME20) > -1' \
-style target=place fill=none stroke=blue stroke-width=1 stroke-dasharray="0 3 0" \
-clip target=tracts us-cart \
-clip target=tracts_b us-cart \
-clip target=blocks_b us-cart \
-clip target=county us-cart \
-clip target=cd2021 us-cart \
-clip target=cd-lines us-cart \
-clip target=cities us-cart \
-clip target=place us-cart \
-clip target=water us-cart \
-each target=cd2021 'cx=this.innerX, cy=this.innerY' \
-points target=cd2021 x=cx y=cy + name=cd2021-labels \
-style target=cd2021-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
```

```
-clip target=tracts_b bbox=-106.898,34.926,-106.4525,35.2487 + name=tracts_b-clip \
-clip target=blocks_b bbox=-106.898,34.926,-106.4525,35.2487 + name=blocks_b-clip \
-clip target=county bbox=-106.898,34.926,-106.4525,35.2487 + name=county-clip \
-clip target=cd-lines bbox=-106.898,34.926,-106.4525,35.2487 + name=cd-lines-clip \
-clip target=cd-lines2 bbox=-106.898,34.926,-106.4525,35.2487 + name=cd-lines2-clip \
-clip target=place bbox=-106.898,34.926,-106.4525,35.2487 + name=place-clip \
-clip target=cities bbox=-106.898,34.926,-106.4525,35.2487 + name=cities-clip \
-clip target=water bbox=-106.898,34.926,-106.4525,35.2487 + name=water-clip \
-o target=tracts_b-clip,water-clip,county-clip,place-clip,cd-lines-clip,cd-lines2-clip,cities-clip '/Users/cervas/My Drive/GitHub/createMaps/NM/images/albuq_tracts.svg' format=svg \
-o target=blocks_b-clip,water-clip,county-clip,place-clip,cd-lines-clip,cd-lines2-clip,cities-clip '/Users/cervas/My Drive/GitHub/createMaps/NM/images/albuq_blocks.svg' format=svg
```

```
-proj target=tracts,tracts_b,us-cart,cities,county,cd2021,place '+proj=tmerc +lat_0=31 +lon_0=-106.25 +k=0.9999 +x_0=500000.0000000002 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs' \
```

Output as .svg files
```
-o target=tracts,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/NM/images/cd2021_tracts.svg' format=svg \
-o target=tracts_b,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/NM/images/cd2021-hispanic-tracts.svg' format=svg \
-classify target=cd2021 save-as=fill colors=Category20 non-adjacent \
-style target=cd2021 opacity=0.75 stroke=none \
-o target=tracts,cd2021,county,cities,us-cart,cd2021-labels '/Users/cervas/My Drive/GitHub/createMaps/NM/images/cd2021.svg'
```

![](images/legend_hispanic.png)
![](images/al.png)


Load USA_MajorCities.geojson with command `name=cities`
```
mapshaper -i '/Users/cervas/My Drive/GitHub/createMaps/NM/USA_Major_Cities.geojson' name=cities \
-filter target=cities "ST=='NM'" \
-filter target=cities "POP_CLASS>=7" \
-filter target=cities "POP_CLASS>=7" + name=cities-labels \
-filter-fields target=cities,cities-labels NAME \
-style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-each target=cities-labels dx=5 \
-each target=cities-labels dy=0 \
-style target=cities r=4 \
-each target=cities "type='point'" \
-each target=cities-labels "type='text-label'" \
-merge-layers target=cities,cities-labels force \
-o target=cities,cities-labels '/Users/cervas/My Drive/GitHub/createMaps/NM/cities.json' format=geojson
```

Arrange labels and merge
```
-merge-layers target=* force
```
