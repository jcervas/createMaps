# Code to create map of Nassau County

```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/decennialAPI/decennialAPI.R")
blocks <- decennialAPI(state="NY", geo="block", table="P1")
columns_to_remove <- grep("A$", colnames(blocks))
data_filtered <- blocks[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/NY/blockscsv.csv")
```

ny <- decennialAPI(state="NY", geo="block", table="P4", variables=c("P4_001N","P4_005N"))
ny$GEOID20 <- paste0(ny$state, ny$county, ny$tract, ny$block)
write.csv(ny, "/Users/cervas/My Drive/GitHub/createMaps/NY/P4-blocks-csv.csv", row.names=F)

```
cd '/Users/cervas/My Drive/GitHub/createMaps/NY/Nassau'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-filter target=us-cart 'STUSPS == "NY"' \
-i '/Users/cervas/My Drive/Projects/Redistricting/2023/Nassau/data/Plans/nassau-county-adopted-2023.geojson' name=nassau-2023-enacted \
-clip source=us-cart target=nassau-2023-enacted \
-style opacity=1 fill=color \
-innerlines + name=nassau-2023-enacted-lines \
-style fill=none stroke=#000 \
-each target=nassau-2023-enacted "cx=$.innerX, cy=$.innerY" \
-points target=nassau-2023-enacted x=cx y=cy + name=district-labels \
-style target=district-labels label-text=id text-anchor=start fill=#000 font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/NY/tl_2020_36_tabblock20.shp' name=blocks \
-simplify 0.1 \
-filter 'COUNTYFP20 == "059"' \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/blocks-csv.csv' name=blocks-csv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/P4-blocks-csv.csv' name=P4-blocks-csv string-fields=GEOID20 \
-join target=blocks source=blocks-csv keys=GEOID20,GEOID20 \
-join target=blocks source=P4-blocks-csv keys=GEOID20,GEOID20 \
-each target=blocks 'density = P1_001N / (ALAND20/2589988)' \
-each target=blocks 'minority = (P4_001N - P4_005N)/P4_001N * 100' \
-classify target=blocks field=minority save-as=fill nice colors='#ffffff,#f0f0f0,#d9d9d9,#bdbdbd,#969696' breaks=10,25,50,75 null-value="#fff" key-name="legend-blocks-minority" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-dissolve target=blocks field=fill \
-clip source=us-cart target=blocks \
-proj target=blocks,nassau-2023-enacted '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +ellps=GRS80 +units=m +no_defs' \
-o target=blocks,border 'images/minority-blocks.svg' \
-o target=nassau-2023-enacted,district-labels  'images/nassau-2023-enacted.svg'
```

## CVAP Maps
[Download CVAP from Census](https://www.census.gov/programs-surveys/decennial-census/about/voting-rights/cvap.html)

### Asian CVAP Map
```
cd '/Users/cervas/My Drive/Redistricting/2023/Nassau/'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_bg20.shp' name=blk-grps \
-i 'data/agg_data_ASIAN.csv' string-fields=GEOID20 \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-innerlines target=current2023 + name=currentlines \
-style target=current2023 fill=#ffffff opacity=0.85 stroke-width=2 stroke-opacity=1 stroke=#000 \
-filter target=blk-grps COUNTYFP20=='059' \
-join target=blk-grps source=agg_data_ASIAN keys=GEOID20,GEOID20 \
-classify target=blk-grps field=cvap_est_per save-as=fill nice colors=Greys breaks=.25,.35,.4,.45,.50,.75 null-value="#fff" key-name="legend-bg-asian" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-proj target=blk-grps,current2023,us-cart '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-o target=blk-grps,current2023 'images/asian-bg.svg'
```
Using Illstrator, delete districts in transparency layer you want to feature. For Asians, districts 9,10,18. Also adjust the stroke-width for non-highlighted districts.

### Valley Stream
```
cd '/Users/cervas/My Drive/Redistricting/2023/Nassau/'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-i 'data/GIS/political-subdivisions(ny.gov)/Nassau_Villages.json' name=villages \
-filter target=villages 'NAME=="Valley Stream"' + name=valley-stream \
-style target=valley-stream fill=#ccc stroke=none opacity=1 \
-style target=villages fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-dissolve target=current2023 + name=nassau \
-style target=nassau fill=none opacity=1 stroke=#000 stroke-width=1 \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#333 \
-style target=current2023 fill=none opacity=1 stroke-width=2 stroke-opacity=1 stroke=#000 \
-proj target=villages,valley-stream,current2023,us-cart '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=valley-stream,villages,currentlines,current2023,current2023-labels,nassau 'images/valley-stream.svg'
```
districts 3, 7, 14



### Freeport
```
cd '/Users/cervas/My Drive/Redistricting/2023/Nassau/'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-i 'data/GIS/political-subdivisions(ny.gov)/Nassau_Villages.json' name=villages \
-filter target=villages 'NAME=="Freeport"' + name=freeport \
-style target=freeport fill=#ccc stroke=none opacity=1 \
-style target=villages fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-dissolve target=current2023 + name=nassau \
-style target=nassau fill=none opacity=1 stroke=#000 stroke-width=1 \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#333 \
-style target=current2023 fill=none opacity=1 stroke-width=2 stroke-opacity=1 stroke=#000 \
-proj target=villages,freeport,current2023,us-cart '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=freeport,villages,currentlines,current2023,current2023-labels,nassau 'images/freeport.svg'
```
districts 5,6



### Hempstead 
```
cd '/Users/cervas/My Drive/Redistricting/2023/Nassau/'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-i 'data/GIS/political-subdivisions(ny.gov)/Nassau_Villages.json' name=villages \
-filter target=villages 'NAME=="Hempstead"' + name=hempstead \
-style target=hempstead fill=#ccc stroke=none opacity=1 \
-style target=villages fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-dissolve target=current2023 + name=nassau \
-style target=nassau fill=none opacity=1 stroke=#000 stroke-width=1 \
-filter target=current2023 '["1","2"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["1","2"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#333 \
-style target=current2023 fill=none opacity=1 stroke-width=2 stroke-opacity=1 stroke=#000 \
-proj target=villages,hempstead,current2023,us-cart '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=hempstead,villages,currentlines,current2023,current2023-labels,nassau 'images/hempstead.svg'
```
districts 5,6

## Minority Blocks Choropleth

### Freeport
```
cd '/Users/cervas/My Drive/Redistricting/2023/Nassau/'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-i 'data/GIS/political-subdivisions(census)/villages.json' name=villages \
-i 'data/agg_data_MINORITY.csv' string-fields=GEOID20 \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_bg20.shp' name=blk-grps \
-filter target=blk-grps COUNTYFP20=='059' \
-join target=blk-grps source=agg_data_MINORITY keys=GEOID20,GEOID20 \
-classify target=blk-grps field=cvap_est_per save-as=fill nice colors=Greys breaks=.25,.3,.35,.4,.45,.50 null-value="#fff" key-name="legend-bg-freeport" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-filter target=villages 'NAME20=="Freeport"' \
-style target=villages fill=none stroke="red" stroke-width=5 opacity=1 \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' + name=currentlines \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=2 stroke-opacity=1 stroke=#fff \
-style target=current2023 fill=none opacity=1 stroke-width=3 stroke-opacity=1 stroke=#000 \
-proj target=blk-grps,villages,current2023,us-cart '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-clip target=blk-grps source=current2023 \
-o target=blk-grps,current2023,villages,currentlines,current2023-labels 'images/freeport_minority.svg'
```
districts 5,6
