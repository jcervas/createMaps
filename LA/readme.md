Import Block and Tract file with command `name=blocks`
```
mapshaper \
-i '/Users/cervas/My Drive/GitHub/Data Files/Census/la2020.pl/clean data/GIS/block/blocks20.shp' name=blocks \
-i '/Users/cervas/My Drive/GitHub/Data Files/Census/la2020.pl/clean data/GIS/tract/tracts20.shp' name=tracts \
-simplify target=blocks 0.01 \
-simplify target=tracts 0.01 \
```

Run this to create a layer for counties
```
-dissolve target=tracts COUNTYF + name=county \
-innerlines \
-style target=county fill=none stroke=#fff stroke-width=1 stroke-dasharray="0 3 0" \
```

This creates the Black percentage in the blocks/tracts layer
```
-each target=blocks 'blackper=BLACK/TOTAL*100' \
-each target=tracts 'blackper=BLACK/TOTAL*100' \
-each target=blocks 'density = TOTAL / (ALAND/2589988)' \
-each target=tracts 'density = TOTAL / (ALAND/2589988)' \
-filter target=blocks STATE==22 + name=blocks_b \
-filter target=tracts STATE==22 + name=tracts_b \
-classify target=blocks field=density save-as=fill nice colors=greys classes=5 \
-classify target=tracts field=density save-as=fill nice colors=greys classes=5 \
-classify target=blocks_b field=blackper save-as=fill key-name="legend_Black" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix='%' nice colors='#ffffff,#f0f0f0,#d9d9d9,#bdbdbd,#969696' breaks=10,25,50,75 null-value="#fff" \
-classify target=tracts_b field=blackper save-as=fill nice colors='#ffffff,#f0f0f0,#d9d9d9,#bdbdbd,#969696' breaks=10,25,50,75 null-value="#fff" \
-dissolve target=blocks field=fill \
-dissolve target=tracts field=fill \
-dissolve target=blocks_b field=fill \
-dissolve target=tracts_b field=fill \
```

Import a cartographic shapefile to us-cart shoreline. Use command `name=us-cart`
```
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-filter target=us-cart STATEFP==22 \
-style target=us-cart fill=none stroke=#000 opacity=1 stroke-opacity=1 \
```

Add the Congressional District Shapefile with command `name=cd`
```
-i '/Users/cervas/My Drive/GitHub/createMaps/LA/plans/LA 2022 Congressional.geojson' name=cd2021 \
-style target=cd2021 stroke-width=1 fill=none stroke-opacity=1 stroke=#000 \
```

Add `cities` layer, which is preprocessed (see below)
```
-i '/Users/cervas/My Drive/GitHub/createMaps/LA/cities.json' name=cities \
```

us-cart layers to cartographic layer
```
-clip target=blocks us-cart \
-clip target=tracts us-cart \
-clip target=blocks_b us-cart \
-clip target=tracts_b us-cart \
-clip target=county us-cart \
-clip target=cd2021 us-cart \
```

Project all layers
```
-proj target=blocks,blocks_b,tracts,tracts_b,us-cart,county,cities,cd2021 '+proj=lcc +lat_1=32.66666666666666 +lat_2=31.16666666666667 +lat_0=30.5 +lon_0=-92.5 +x_0=1000000 +y_0=0 +ellps=GRS80 +units=m +no_defs' \
```

Label Districts
```
-each target=cd2021 'cx=this.innerX, cy=this.innerY' \
-points target=cd2021 x=cx y=cy + name=cd2021-labels \
-style target=cd2021-labels label-text=NAME text-anchor=middle fill=#000 stroke=none opacity=1 font-size=18px font-weight=800 line-height=20px font-family=arial class="g-text-shadow p" \
```

Output Population Density as .svg files
```
-o target=blocks,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/LA/images/cd2021_blocks.svg' format=svg \
-o target=tracts,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/LA/images/cd2021_tracts.svg' format=svg \
-o target=blocks_b,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/LA/images/cd2021-black-blocks.svg' format=svg \
-o target=tracts_b,county,cd2021,cities,us-cart '/Users/cervas/My Drive/GitHub/createMaps/LA/images/cd2021-black-tracts.svg' format=svg \
-style target=cd2021 fill=color non-adjacent \
-style target=cd2021 opacity=0.75 stroke=none \
-o target=tracts,cd2021,county,cities,us-cart,cd2021-labels '/Users/cervas/My Drive/GitHub/createMaps/LA/images/cd2021.svg'
```

# 2022 Louisiana Congressional Map
![](images/cd2021.svg)


Load USA_MajorCities.geojson with command `name=cities`
```
mapshaper -i '/Users/cervas/My Drive/GitHub/createMaps/USA_Major_Cities.geojson' name=cities \
-filter target=cities "ST=='LA'" \
-filter target=cities "POPULATION>=200000" \
-filter target=cities "POPULATION>=200000" + name=cities-labels \
-filter-fields target=cities,cities-labels NAME \
-style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-each target=cities-labels dx=5 \
-each target=cities-labels dy=0 \
-style target=cities r=4 \
-each target=cities "type='point'" \
-each target=cities-labels "type='text-label'" \
-merge-layers target=cities,cities-labels force \
-o target=cities,cities-labels '/Users/cervas/My Drive/GitHub/createMaps/LA/cities.json' format=geojson
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
