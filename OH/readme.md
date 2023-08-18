
# 2022 Ohio Congressional Map
![](images/cd2022.svg)


```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/censusAPI/censusAPI.R")
blocks <- censusAPI(state="OH", geo="block", table="P1")
columns_to_remove <- grep("A$", colnames(blocks))
data_filtered <- blocks[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/OH/blockscsv.csv")
```



```
cd '/Users/cervas/My Drive/GitHub/createMaps/OH'
mapshaper-xl 20gb \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/OH/tl_2020_39_tabblock20.shp' name=blocks \
-i '/Users/cervas/My Drive/GitHub/createMaps/OH/blockscsv.csv' name=blockscsv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/createMaps/OH/cities.json' name=cities \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Congress/US_2022_Districts.json' name=cd2022 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-filter target=us-cart 'STUSPS == "OH"' \
-style target=us-cart fill=none stroke=#000 opacity=1 stroke-opacity=1 \
-simplify target=blocks 0.05 \
-join target=blocks source=blockscsv keys=GEOID20,GEOID20 \
-filter target=blocks 'AWATER20>=ALAND20' + name=water \
-dissolve \
-style target=water fill=#fff \
-dissolve target=blocks field=TRACTCE20 calc=' TOTAL = sum(P1_001N), COUNTYFP20 = max(COUNTYFP20), ALAND20 = sum(ALAND20), STATEFP20 = max(STATEFP20)' + name=tracts \
-dissolve target=blocks field=blkgrp calc=' TOTAL = sum(P1_001N), COUNTYFP20 = max(COUNTYFP20), ALAND20 = sum(ALAND20), STATEFP20 = max(STATEFP20)' + name=blkgrps \
-each target=blocks 'density = P1_001N / (ALAND20/2589988)' \
-each target=blkgrps 'density = TOTAL / (ALAND20/2589988)' \
-each target=tracts 'density = TOTAL / (ALAND20/2589988)' \
-dissolve target=tracts COUNTYFP20 + name=county \
-innerlines \
-style target=county fill=none stroke=#fff stroke-width=1 stroke-dasharray="0 3 0" stroke-opacity=0.5 \
```

```
-filter target=blocks 'STATEFP20 == "39"' + name=blocks-styled \
-filter target=blocks 'STATEFP20 == "39"' + name=blocks-bw \
-filter target=tracts 'STATEFP20 == "39"' + name=blkgrps-styled \
-filter target=tracts 'STATEFP20 == "39"' + name=tracts-styled \
-classify target=blocks-styled field=density save-as=fill colors=OrRd classes=9 key-name="legend_densityOH_blocks" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=blocks-bw field=density save-as=fill colors=greys classes=5 key-name="legend_densityOH_blocks" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=blkgrps-styled field=density save-as=fill colors=greys classes=9 key-name="legend_densityOH_blkgrps" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=tracts-styled field=density save-as=fill nice colors=greys classes=5 key-name="legend_densityOH_tracts" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-dissolve target=blocks-styled field=fill \
-dissolve target=blocks-bw field=fill \
-dissolve target=blkgrps-styled field=fill \
-dissolve target=tracts-styled field=fill \
-proj target=tracts-styled,blocks-bw,blkgrps-styled,blocks-styled,water,county,cities,cd2022,us-cart '+proj=lcc +lat_1=41.7 +lat_2=40.43333333333333 +lat_0=39.66666666666666 +lon_0=-82.5 +x_0=600000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs ' \
-o target=blocks-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/OH/images/OH_blocks.svg' format=svg \
-o target=blocks-bw,water,us-cart '/Users/cervas/My Drive/GitHub/createMaps/OH/images/OH_blocks_bw.svg' format=svg \
-o target=blkgrps-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/OH/images/OH_blkgrps.svg' format=svg \
-o target=tracts-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/OH/images/OH_tracts.svg' format=svg \
```

```
-filter target=cd2022 'ST=="OH"' \
-style target=cd2022 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
-each target=cd2022 'cx=this.innerX, cy=this.innerY' \
-points target=cd2022 x=cx y=cy + name=cd2022-labels \
-style target=cd2022-labels label-text=CODE text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-classify target=cd2022 save-as=fill colors=Category20 non-adjacent \
-style target=cd2022 opacity=0.75 stroke=none \
-clip source=us-cart target=tracts-styled \
-clip source=us-cart target=blocks-bw \
-clip source=us-cart target=blkgrps-styled \
-clip source=us-cart target=blocks-styled \
-clip source=us-cart target=water \
-clip source=us-cart target=county \
-clip source=us-cart target=cities \
-clip source=us-cart target=cd2022 \
-o target=tracts-styled,cd2022,county,cities,ST,cd2022-labels,us-cart '/Users/cervas/My Drive/GitHub/createMaps/OH/images/cd2022.svg'
```


-filter target=ST 'STATEFP == "35"' \
-style target=ST fill=none stroke=#000 opacity=1 stroke-opacity=1 \

mapshaper -i '/Users/cervas/My Drive/GitHub/createMaps/USA_Major_Cities.geojson' name=cities \
-filter target=cities "ST=='OH'" \
-filter target=cities "POP_CLASS>=8" \
-filter target=cities "POP_CLASS>=8" + name=cities-labels \
-filter-fields target=cities,cities-labels NAME \
-style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-each target=cities-labels dx=5 \
-each target=cities-labels dy=0 \
-style target=cities r=4 \
-each target=cities "type='point'" \
-each target=cities-labels "type='text-label'" \
-merge-layers target=cities,cities-labels force \
-o target=cities,cities-labels '/Users/cervas/My Drive/GitHub/createMaps/OH/cities.json' format=geojson


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