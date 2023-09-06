
# 2022 Florida Congressional Map
![](images/cd2022.svg)


```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/decennialAPI/decennialAPI.R")
blocks <- censusAPI(state="FL", geo="block", table="P1")
columns_to_remove <- grep("A$", colnames(blocks))
data_filtered <- blocks[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/FL/blockscsv.csv")
```



```
cd '/Users/cervas/My Drive/GitHub/createMaps/FL'
mapshaper-xl 20gb \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/FL/tl_2020_12_tabblock20.shp' name=blocks \
-i '/Users/cervas/My Drive/GitHub/createMaps/FL/blockscsv.csv' name=blockscsv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/createMaps/FL/cities.json' name=cities \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Congress/US_2022_Districts.json' name=cd2022 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-filter target=us-cart 'STUSPS == "FL"' \
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
-filter target=blocks 'STATEFP20 == "12"' + name=blocks-styled \
-filter target=blocks 'STATEFP20 == "12"' + name=blocks-bw \
-filter target=tracts 'STATEFP20 == "12"' + name=blkgrps-styled \
-filter target=tracts 'STATEFP20 == "12"' + name=tracts-styled \
-classify target=blocks-styled field=density save-as=fill colors=OrRd classes=9 key-name="legend_densityFL_blocks" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=blocks-bw field=density save-as=fill nice colors=#ffffff,#454545 classes=3 key-name="legend_densityFL_blocks_bw" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=blkgrps-styled field=density save-as=fill nice colors=greys classes=3 key-name="legend_densityFL_blkgrps" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-classify target=tracts-styled field=density save-as=fill nice colors=greys classes=5 key-name="legend_densityFL_tracts" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-dissolve target=blocks-styled field=fill \
-dissolve target=blocks-bw field=fill \
-dissolve target=blkgrps-styled field=fill \
-dissolve target=tracts-styled field=fill \
-proj target=tracts-styled,blocks-bw,blkgrps-styled,blocks-styled,water,county,cities,cd2022,us-cart EPSG:3662 \
-filter target=cd2022 'ST=="FL"' \
-style target=cd2022 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
-each target=cd2022 'cx=this.innerX, cy=this.innerY' \
-points target=cd2022 x=cx y=cy + name=cd2022-labels \
-style target=cd2022-labels label-text=CODE text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
-classify target=cd2022 save-as=fill colors=Category20 non-adjacent \
-style target=cd2022 opacity=0.75 stroke=none \
-style target=us-cart class="g-Shadow p" \
-clip source=us-cart target=tracts-styled \
-clip source=us-cart target=blocks-bw \
-clip source=us-cart target=blkgrps-styled \
-clip source=us-cart target=blocks-styled \
-clip source=us-cart target=water \
-clip source=us-cart target=county \
-clip source=us-cart target=cd2022 \
-o target=blocks-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/FL/images/FL_blocks.svg' format=svg \
-o target=blocks-bw,water,us-cart '/Users/cervas/My Drive/GitHub/createMaps/FL/images/FL_blocks_bw.svg' format=svg \
-o target=blkgrps-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/FL/images/FL_blkgrps.svg' format=svg \
-o target=tracts-styled,water,county,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/FL/images/FL_tracts.svg' format=svg \
-o target=tracts-styled,cd2022,county,cities,ST,us-cart '/Users/cervas/My Drive/GitHub/createMaps/FL/images/cd2022.svg'
```


-filter target=ST 'STATEFP == "12"' \
-style target=ST fill=none stroke=#000 opacity=1 stroke-opacity=1 \


mapshaper -i '/Users/cervas/My Drive/GitHub/createMaps/USA_Major_Cities.geojson' name=cities \
  -filter target=cities '["FL"].indexOf(ST) > -1' \
  -filter target=cities '["Tallahassee","Jacksonville", "Gainesville","Tampa","St. Petersburg","Miami","Lakeland","Miami","Orlando"].indexOf(NAME) > -1' \
  -filter target=cities '["Tallahassee","Jacksonville", "Gainesville","Tampa","St. Petersburg","Miami","Lakeland","Miami","Orlando"].indexOf(NAME) > -1' + name=cities-labels \
  -style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
  -style target=cities-labels 'text-anchor=middle' where='["Tampa"].indexOf(NAME) > -1' \
  -style target=cities-labels 'text-anchor=end' where='["Miami","Jacksonville","Orlando"].indexOf(NAME) > -1' \
  -style target=cities-labels 'dy=-10' where='["Tampa"].indexOf(NAME) > -1' \
  -style target=cities-labels 'dy=15' where='["Jacksonville"].indexOf(NAME) > -1' \
  -each target=cities-labels 'dx=-5' where='["Miami","Jacksonville","Orlando"].indexOf(NAME) > -1' \
  -each target=cities-labels 'dx=5' where='["St. Petersburg","Tallahassee","Gainesville","Lakeland"].indexOf(NAME) > -1' \
  -style target=cities r=4 stroke=#fff \
  -each target=cities 'type="point"' \
  -each target=cities-labels 'type="text-label"' \
  -merge-layers target=cities-labels,cities force \
  -o target=cities,cities-labels '/Users/cervas/My Drive/GitHub/createMaps/FL/cities.json' format=geojson

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



