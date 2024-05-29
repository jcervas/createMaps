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
-i '/Users/cervas/My Drive/Projects/Redistricting/2024/Nassau/data/Plans/nassau-2023.geojson' name=nassau-2023-enacted \
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
Nassau 2013 Population Deviations
```
  cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
  mapshaper-xl 2gb \
  -i gis/nassau.json \
  -i gis/nassau-water.json \
  -i '/Users/cervas/My Drive/Redistricting/2024/Nassau/data-locked/Plans/nassau-2013-2020data.geojson' name=nassau13 \
  -proj target=nassau,nassau13 '+proj=utm +zone=18 +datum=NAD83' \
  -classify target=nassau13 field=PopDevPct save-as=fill breaks=-0.05,-0.025,0,0.025,0.05 colors=PuOr null-value="#fff" key-name="legend-deviations" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=200 key-font-size=10 key-last-suffix="%" \
  -dissolve target=nassau13 field=fill + name=deviations \
  -innerlines target=nassau13 \
  -style target=nassau13 opacity=1 stroke-width=1 stroke-opacity=1 stroke=#777 stroke-dasharray="0 3 0" \
  -each target=nassau13 'type="nassau13"' \
  -o target=nassau,deviations,nassau13 max-height=800 'images/nassau13-deviations.svg'
```

## Villages and Cities/Towns

```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/nassau.json \
-i 'data/GIS/political-subdivisions(census)/cdp.json' \
-i 'data/GIS/political-subdivisions(census)/cities-towns.json' \
-i 'data/GIS/political-subdivisions(census)/villages.json' \
-i 'data-locked/Plans/nassau-2023.geojson' \
-filter target=nassau-2023 'id=="11"' \
-style target=nassau-2023 fill=color opacity=0.5 stroke=none \
-style target=villages fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#777 stroke-dasharray="0 3 0" \
-each target=cities-towns 'cx=this.innerX, cy=this.innerY' \
-points target=cities-towns x=cx y=cy + name=Cities_Towns-labels \
-each target=Cities_Towns-labels 'NAME20 = NAME20.toUpperCase()' \
-style target=Cities_Towns-labels label-text=NAME20 text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-innerlines target=cities-towns \
-style target=cities-towns opacity=1 stroke-width=1 stroke-opacity=1 stroke=#777 stroke-dasharray="0 3 0" \
-each target=villages 'cx=this.innerX, cy=this.innerY' \
-points target=villages x=cx y=cy + name=Villages-labels \
-style target=Villages-labels label-text=NAME20 text-anchor=middle fill=#000 stroke=none opacity=1 font-size=7px font-weight=300 line-height=20px font-family=arial class="g-text-shadow p" \
-proj target=nassau,nassau-2023,cities-towns,Cities_Towns-labels,villages,Villages-labels '+proj=utm +zone=18 +datum=NAD83' \
-classify target=villages field=NAME20 colors=Category20 save-as=fill \
-o target=nassau,villages,Villages-labels max-height=800 'images/villages.svg' \
-o target=nassau,cities-towns,Cities_Towns-labels max-height=800 'images/cities-towns.svg' \
-o target=nassau,cities-towns,Cities_Towns-labels,nassau-2023 max-height=800 'images/cities-towns-D9.svg'
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
-i gis/nassau23.json name=nassau23 \
-i gis/cervas.json \
-proj target=asian,nassau23,nassau,nassau-small,cervas '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=nassau23 '["9","10","18"].indexOf(NAME) > -1' invert + name=nassau23-other \
-filter target=nassau23 '["9","10","18"].indexOf(NAME) > -1' + name=influence \
-filter target=cervas '["10"].indexOf(NAME) > -1' invert + name=cervas-other \
-filter target=cervas '["10"].indexOf(NAME) > -1' + name=cervas-influence \
-innerlines target=nassau23 + name=nassaulines \
-innerlines target=cervas + name=cervaslines \
-style target=nassau23-other fill=#fff opacity=0.25 stroke-width=0 stroke-opacity=0 \
-style target=cervas-other fill=#fff opacity=0.25 stroke-width=0 stroke-opacity=0 \
-style target=nassaulines fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-style target=cervaslines fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc stroke-dasharray="0 3 0" \
-clip target=asian bbox=20865,61667,31564,70730 + name=blk-grps-zoom \
-clip target=influence bbox=20865,61667,31564,70730 + name=influence-zoom \
-clip target=cervas-influence bbox=20865,61667,31564,70730 + name=cervas-influence-zoom \
-each target=influence-zoom 'cx=this.innerX, cy=this.innerY' \
-points target=influence-zoom x=cx y=cy + name=nassau23-labels \
-style target=nassau23-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-each target=cervas-influence-zoom 'cx=this.innerX, cy=this.innerY' \
-points target=cervas-influence-zoom x=cx y=cy + name=cervas-labels \
-style target=cervas-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-rectangle target=influence-zoom + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-style target=influence-zoom fill=none opacity=1 stroke-width=3 stroke=#000 \
-style target=cervas-influence-zoom fill=none opacity=1 stroke-width=3 stroke=#000 \
-style target=influence fill=none opacity=1 stroke-width=1 stroke=#000 \
-style target=cervas-influence fill=none opacity=1 stroke-width=1 stroke=#000 \
-o target=nassau,asian width=500 'images/asian-bg.svg' \
-o target=nassau-small,rect, width=100 'images/asian-nassau-small.svg' \
-o target=blk-grps-zoom,influence-zoom,nassau23-labels width=500 'images/asian-alt-zoom-bg.svg' \
-o target=nassau,asian,rect, width=100 'images/asian-nassau-small.svg' \
-o target=blk-grps-zoom,cervas-influence-zoom,cervas-labels width=500 'images/asian-alt-zoom-bg-cervas.svg'
```

### Valley Stream
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/nassau23.json \
-i gis/nassau23-labels.json \
-i gis/cervas.json \
-i gis/cervas-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,nassau23,nassau23-labels,cervas,cervas-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Valley Stream"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=nassau23 '["3","7","14"].indexOf(NAME) > -1' invert + name=nassaulines \
-filter target=nassau23 '["3","7","14"].indexOf(NAME) > -1' \
-rectangle source=nassau23 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=nassau23-labels '["5","6"].indexOf(NAME) > -1' \
-innerlines target=nassaulines \
-style target=nassaulines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=nassau23 fill=#fff \
-filter target=cervas '["7"].indexOf(NAME) > -1' invert + name=cervaslines \
-filter target=cervas '["7"].indexOf(NAME) > -1' \
-rectangle source=cervas + name=rect-cervas \
-style target=rect-cervas fill=none stroke=#000 stroke-width=3 \
-filter target=cervas-labels '["7"].indexOf(NAME) > -1' \
-innerlines target=cervaslines \
-style target=cervaslines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=cervas fill=#fff \
-o target=nassau,rect, width=100 'images/Valley-Stream-nassau-small.svg' \
-o target=nassau,nassaulines,nassau23,villages,nassau23-labels width=500 'images/Valley-Stream.svg' \
-o target=nassau,rect-cervas, width=100 'images/Valley-Stream-nassau-small-cervas.svg' \
-o target=nassau,cervaslines,cervas,villages,cervas-labels width=500 'images/Valley-Stream-cervas.svg'
```

### Freeport
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/nassau23.json \
-i gis/nassau23-labels.json \
-i gis/cervas.json \
-i gis/cervas-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,nassau23,nassau23-labels,cervas,cervas-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Freeport"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=nassau23 '["5","6"].indexOf(NAME) > -1' invert + name=nassaulines \
-filter target=nassau23 '["5","6"].indexOf(NAME) > -1' \
-rectangle source=nassau23 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=nassau23-labels '["5","6"].indexOf(NAME) > -1' \
-innerlines target=nassaulines \
-style target=nassaulines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=nassau23 fill=#fff \
-filter target=cervas '["5"].indexOf(NAME) > -1' invert + name=cervaslines \
-filter target=cervas '["5"].indexOf(NAME) > -1' \
-rectangle source=cervas + name=rect-cervas \
-style target=rect-cervas fill=none stroke=#000 stroke-width=3 \
-filter target=cervas-labels '["5"].indexOf(NAME) > -1' \
-innerlines target=cervaslines \
-style target=cervaslines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=cervas fill=#fff \
-o target=nassau,rect, width=100 'images/Freeport-nassau-small.svg' \
-o target=nassau,nassaulines,nassau23,villages,nassau23-labels width=500 'images/Freeport.svg' \
-o target=nassau,rect-cervas, width=100 'images/Freeport-nassau-small-cervas.svg' \
-o target=nassau,cervaslines,cervas,villages,cervas-labels width=500 'images/Freeport-cervas.svg'
```

### Hempstead

```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/nassau23.json \
-i gis/nassau23-labels.json \
-i gis/cervas.json \
-i gis/cervas-labels.json \
-i gis/nassau.json \
-i gis/villages-dotted.json \
-proj target=villages-dotted,nassau23,nassau23-labels,cervas,cervas-labels,nassau '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=villages-dotted 'NAME20=="Hempstead"' + name=villages \
-style target=villages fill=#666 stroke=none opacity=0.5 \
-filter target=nassau23 '["1","2"].indexOf(NAME) > -1' invert + name=nassaulines \
-filter target=nassau23 '["1","2"].indexOf(NAME) > -1' \
-rectangle source=nassau23 + name=rect \
-style target=rect fill=none stroke=#000 stroke-width=3 \
-filter target=nassau23-labels '["1","2"].indexOf(NAME) > -1' \
-innerlines target=nassaulines \
-style target=nassaulines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=nassau23 fill=#fff \
-filter target=cervas '["1"].indexOf(NAME) > -1' invert + name=cervaslines \
-filter target=cervas '["1"].indexOf(NAME) > -1' \
-rectangle source=cervas + name=rect-cervas \
-style target=rect-cervas fill=none stroke=#000 stroke-width=3 \
-filter target=cervas-labels '["1"].indexOf(NAME) > -1' \
-innerlines target=cervaslines \
-style target=cervaslines stroke-dasharray="0 3 0" opacity=1 stroke-width=1 stroke-opacity=1 stroke=#ccc \
-style target=cervas fill=#fff \
-o target=nassau,rect, width=100 'images/Hempstead-nassau-small.svg' \
-o target=nassau,nassaulines,nassau23,villages,nassau23-labels width=500 'images/Hempstead.svg' \
-o target=nassau,rect-cervas, width=100 'images/Hempstead-nassau-small-cervas.svg' \
-o target=nassau,cervaslines,cervas,villages,cervas-labels width=500 'images/Hempstead-cervas.svg'
```

## Minority Blocks Choropleth

### Freeport
```

-o target=blk-grps,nassau23,villages,nassaulines,nassau23-labels 'images/freeport_minority.svg'
```
districts 5,6



### Valley Stream
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i gis/villages.json \
-i gis/minority.json \
-i gis/nassau.json \
-filter target=villages 'NAME20=="Valley Stream"' \
-i 'data-locked/Plans/nassau-2023.geojson' name=nassau23 \
-proj target=nassau,minority,villages,nassau23 '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74' \
-filter target=nassau23 '["3","7","14"].indexOf(NAME) > -1' + name=nassaulines \
-filter target=nassau23 '["3","7","14"].indexOf(NAME) > -1' \
-innerlines target=nassau23 target=nassaulines \
-style target=nassaulines stroke-dasharray="0" opacity=1 stroke-width=3 stroke-opacity=1 stroke=#000 \
-style target=nassau23 fill=none opacity=1 stroke-width=3 stroke-opacity=1 stroke=#000 \
-each target=nassau23 'cx=this.innerX, cy=this.innerY' \
-points target=nassau23 x=cx y=cy + name=nassau23-labels \
-style target=nassau23-labels label-text=NAME text-anchor=middle fill=#000 stroke=#fff stroke-width=1 opacity=1 font-size=28px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-clip target=minority bbox=19559.003684577747,47130.5461585568,31121.474689535728,61579.12435680058 \
-o target=minority,nassau23,villages,nassaulines,nassau23-labels width=500 max-height=600 'images/valley-stream_minority.svg'
```

-----------------------------------------------

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
-style target=villages fill=none stroke="#FFB612" stroke-width=7 opacity=1 \
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

### Nassau 2023 Map
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data-locked/Plans/nassau-2023.geojson' name=nassau23 \
-style target=nassau23 fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#000 \
-each target=nassau23 'cx=this.innerX, cy=this.innerY' \
-points target=nassau23 x=cx y=cy + name=nassau23-labels \
-style target=nassau23-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=16px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=nassau23-labels gis/nassau23-labels.json \
-o target=nassau23 gis/nassau23.json
```

### Cervas Illustrive Plan
```
cd '/Users/cervas/My Drive/Redistricting/2024/Nassau/'
mapshaper-xl 2gb \
-i 'data-locked/Plans/Illustrative-Plans/cervas-illustrative.geojson' name=cervas \
-style target=cervas fill=none opacity=1 stroke-width=1 stroke-opacity=1 stroke=#000 \
-each target=cervas 'cx=this.innerX, cy=this.innerY' \
-points target=cervas x=cx y=cy + name=cervas-labels \
-style target=cervas-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=16px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-o target=cervas-labels gis/cervas-labels.json \
-o target=cervas gis/cervas.json
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
-classify target=blk-grps field=cvap_est_per save-as=fill method=equal-interval colors=BuGn null-value="#fff" key-name="legend-bg-minority" key-style="simple" key-tile-height=10 key-tic-length=0 key-width=300 key-font-size=10 key-last-suffix="%" \
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
