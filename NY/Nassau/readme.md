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
-i '/Users/cervas/My Drive/Projects/Redistricting/2024/Nassau/data/Plans/nassau-county-adopted-2023.geojson' name=nassau-2023-enacted \
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

## Villages and Cities/Towns

```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/nassau.json \
-i 'data/GIS/political-subdivisions(census)/cdp.json' \
-i 'data/GIS/political-subdivisions(census)/cities-towns.json' \
-i 'data/GIS/political-subdivisions(census)/villages.json' \
-style target=villages fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#777 stroke-dasharray="0 3 0" \
-each target=cities-towns 'cx=this.innerX, cy=this.innerY' \
-points target=cities-towns x=cx y=cy + name=Cities_Towns-labels \
-style target=Cities_Towns-labels label-text=NAME20 text-anchor=middle fill=#000 stroke=none opacity=1 font-size=12px font-weight=500 line-height=20px font-family=arial class="g-text-shadow p" \
-innerlines target=cities-towns \
-style target=cities-towns opacity=1 stroke-width=1 stroke-opacity=1 stroke=#777 stroke-dasharray="0 3 0" \
-each target=villages 'cx=this.innerX, cy=this.innerY' \
-points target=villages x=cx y=cy + name=Villages-labels \
-style target=Villages-labels label-text=NAME20 text-anchor=middle fill=#000 stroke=none opacity=1 font-size=7px font-weight=300 line-height=20px font-family=arial class="g-text-shadow p" \
-proj target=nassau,cities-towns,Cities_Towns-labels,villages,Villages-labels '+proj=utm +zone=18 +datum=NAD83' \
-o target=nassau,villages,Villages-labels max-height=800 'images/villages.svg' \
-o target=nassau,cities-towns,Cities_Towns-labels max-height=800 'images/cities-towns.svg'
```

## CVAP Maps
[Download CVAP from Census](https://www.census.gov/programs-surveys/decennial-census/about/voting-rights/cvap.html)

### Asian CVAP Map
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/asian.json \
-i gis/nassau.json \
-i gis/nassau.json name=nassau-small \
-i gis/current2023.json name=current2023 \
-proj target=asian,current2023,nassau,nassau-small '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=current2023 '["9","10","18"].indexOf(NAME) > -1' invert + name=current \
-filter target=current2023 '["9","10","18"].indexOf(NAME) > -1' + name=influence \
-innerlines target=current + name=currentlines \
-style target=current fill=#fff opacity=0.25 stroke-width=0 stroke-opacity=0 \
-style target=currentlines fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-clip target=asian bbox=20865,61667,31564,70730 + name=blk-grps-zoom \
-clip target=influence bbox=20865,61667,31564,70730 + name=influence-zoom \
-each target=influence-zoom 'cx=this.innerX, cy=this.innerY' \
-points target=influence-zoom x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-rectangle target=influence-zoom + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-style target=influence-zoom fill=none opacity=1 stroke-width=3 stroke=#000 \
-style target=influence fill=none opacity=1 stroke-width=1 stroke=#000 \
-o target=nassau,asian,currentlines,current,influence width=500 'images/asian-bg.svg' \
-o target=nassau-small,rect, width=100 'images/asian-nassau-small.svg' \
-o target=blk-grps-zoom,influence-zoom,current2023-labels,rect width=500 'images/asian-alt-zoom-bg.svg'
```

### Valley Stream
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/current2023.json \
-i gis/current2023-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,current2023,current2023-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Valley Stream"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' \
-rectangle bbox=19559.0036845778,47130.54615853556,31121.474689535808,61579.124356780754 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=current2023-labels '["3","7","14"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=current2023 fill=#fff \
-o target=nassau,rect, width=100 'images/valley-stream-nassau-small.svg' \
-o target=nassau,currentlines,current2023,villages,current2023-labels width=500 'images/valley-stream.svg'
```

### Freeport
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/current2023.json \
-i gis/current2023-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,current2023,current2023-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Freeport"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["5","6"].indexOf(NAME) > -1' \
-rectangle source=current2023 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=current2023-labels '["5","6"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=current2023 fill=#fff \
-o target=nassau,rect, width=100 'images/Freeport-nassau-small.svg' \
-o target=nassau,currentlines,current2023,villages,current2023-labels width=500 'images/Freeport.svg'
```

### Hempstead
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/current2023.json \
-i gis/current2023-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,current2023,current2023-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Hempstead"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=current2023 '["1","2"].indexOf(NAME) > -1' invert + name=currentlines \
-filter target=current2023 '["1","2"].indexOf(NAME) > -1' \
-rectangle source=current2023 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=current2023-labels '["1","2"].indexOf(NAME) > -1' \
-innerlines target=currentlines \
-style target=currentlines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=current2023 fill=#fff \
-o target=nassau,rect, width=100 'images/Hempstead-nassau-small.svg' \
-o target=nassau,currentlines,current2023,villages,current2023-labels width=500 'images/Hempstead.svg'
```

## Minority Blocks Choropleth

### Freeport
```

-o target=blk-grps,current2023,villages,currentlines,current2023-labels 'images/freeport_minority.svg'
```
districts 5,6



### Valley Stream
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/villages.json \
-i gis/minority.json name=blk-grps \
-filter target=villages 'NAME20=="Valley Stream"' \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-proj target=blk-grps,villages,current2023 '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' + name=currentlines \
-filter target=current2023 '["3","7","14"].indexOf(NAME) > -1' \
-innerlines target=current2023 target=currentlines \
-style target=currentlines stroke-dasharray="0" opacity=1 stroke-width=3 stroke-opacity=1 stroke=#000 \
-style target=current2023 fill=none opacity=1 stroke-width=3 stroke-opacity=1 stroke=#000 \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-clip target=blk-grps source=current2023 \
-o target=blk-grps,current2023,villages,currentlines,current2023-labels max-height=600 'images/valley-stream_minority.svg'
```



## Map Setup

### County
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_county20.shp' name=counties \
-filter target=counties 'NAME20=="Nassau"' \
-style target=counties fill=#f9f9f9 stroke=#ccc stroke-dasharray="10 5" \
-o gis/nassau.json
```

### Villages
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/GIS/political-subdivisions(census)/villages.json' name=villages \
-style target=villages fill=none stroke="#9e9ac8" stroke-width=7 opacity=1 \
-o gis/villages.json
```

### Villages-dotted
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/GIS/political-subdivisions(census)/villages.json' name=villages \
-style fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-o gis/villages-dotted.json
```

### Current 2023 Map
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data-locked/Plans/nassau-county-adopted-2023.geojson' name=current2023 \
-style target=current2023 fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#000 \
-each target=current2023 'cx=this.innerX, cy=this.innerY' \
-points target=current2023 x=cx y=cy + name=current2023-labels \
-style target=current2023-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=16px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=current2023-labels gis/current2023-labels.json \
-o target=current2023 gis/current2023.json
```


### Minority Cholopleth
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/agg_data_MINORITY.csv' string-fields=GEOID20 name=minority \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_bg20.shp' name=blk-grps \
-filter target=blk-grps COUNTYFP20=='059' \
-join target=blk-grps source=minority keys=GEOID20,GEOID20 \
-each 'cvap_est_per = cvap_est_per * 100' \
-classify target=blk-grps field=cvap_est_per save-as=fill nice colors=YlOrRd breaks=25,30,35,40,45,50,55,60,65,70,75 null-value="#fff" key-name="legend-bg-minority" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=200 key-font-size=10 key-last-suffix="%" \
-o gis/minority.json
```

### Asian Cholopleth
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/agg_data_ASIAN.csv' string-fields=GEOID20 name=minority \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_bg20.shp' name=blk-grps \
-filter target=blk-grps COUNTYFP20=='059' \
-join target=blk-grps source=minority keys=GEOID20,GEOID20 \
-each 'cvap_est_per = cvap_est_per * 100' \
-classify target=blk-grps field=cvap_est_per save-as=fill nice colors=OrRd breaks=25,30,35,40,45,50 null-value="#fff" key-name="legend-bg-asian" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=200 key-font-size=10 key-last-suffix="%" \
-o gis/asian.json
```
### Biden/Trump Cholopleth (blocks)
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i data/GIS/nassau-blocks.json \
-i data/dra-Election_Data_Block_NY/election_data_block_NY.v01.csv string-fields=GEOID name=data \
-join target=nassau-blocks source=data keys=GEOID20,GEOID \
-each 'DemVoteShare = E_20_PRES_Dem /E_20_PRES_Total * 100' \
-classify target=nassau-blocks field=DemVoteShare save-as=fill nice colors='#C93135,#FCE0E0,#CEEAFD,#1375B7' breaks=30,40,50,60,70 null-value="#fff" key-name="legend-partisanship" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=200 key-font-size=10 key-last-suffix="%" \
-o gis/biden-trump.json
```

### Biden/Trump Cholopleth (block groups)
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data/dra-Election_Data_Block_NY/blk-grp-2020.csv' string-fields=BlockGroupID name=data \
-i 'data/GIS/tl_2020_36_all/tl_2020_36_bg20.shp' name=blk-grps \
-filter target=blk-grps COUNTYFP20=='059' \
-join target=blk-grps source=data keys=GEOID20,BlockGroupID \
-each 'DemVoteShare = E_20_PRES_Dem /E_20_PRES_Total * 100' \
-classify target=blk-grps field=DemVoteShare save-as=fill nice colors='#C93135,#FCE0E0,#CEEAFD,#1375B7' breaks=30,40,50,60,70 null-value="#fff" key-name="legend-partisanship" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=200 key-font-size=10 key-last-suffix="%" \
-o gis/biden-trump-block-groups.json
```
