
Set Working Directory
`cd "/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS"`

# Base Map

### Cartographic Map (for water boundaries)
```
   mapshaper -i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Cartographic/2021/cb_2021_us_all_500k/cb_2021_us_state_500k/cb_2021_us_state_500k.shp' name=us-cart \
  -filter target=us-cart STATEFP==42 \
  -style target=us-cart fill=none stroke=#000 opacity=1 stroke-opacity=1 \
  -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/counties/pa_counties20.shp' name=counties \
  -proj target='counties,us-cart' EPSG:3652 \
  -clip target=counties us-cart \
  -each target=counties 'cx=this.innerX, cy=this.innerY' \
  -points target=counties x=cx y=cy + name=counties-labels \
  -style target=counties-labels label-text=NAME_x text-anchor=middle font-size=10px font-weight=800 line-height=16px font-family=helvetica class="g-text-shadow p" \
  -innerlines target=counties \
  -style target=counties fill=none stroke=#000 stroke-width=1 stroke-dasharray="0 3 0" \
  -i '/Users/cervas/My Drive/GitHub/Data Files/GIS/USA_Major_Cities.geojson' name=cities \
  -proj target=cities EPSG:3652 \
  -filter target=cities '["PA"].indexOf(ST) > -1' \
  -filter target=cities '["Pittsburgh","Erie", "State College","Allentown","Philadelphia","Harrisburg"].indexOf(NAME) > -1' \
  -filter target=cities '["Pittsburgh","Erie", "State College","Allentown","Philadelphia","Harrisburg"].indexOf(NAME) > -1' + name=cities-labels \
  -style target=cities-labels label-text=NAME text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=helvetica class="g-text-shadow p" stroke-width=0.25 stroke=#fff \
  -style target=cities-labels 'text-anchor=middle' where='["Pittsburgh","Erie", "State College"].indexOf(NAME) > -1' \
  -style target=cities-labels 'text-anchor=end' where='["Allentown","Philadelphia","Harrisburg"].indexOf(NAME) > -1' \
  -style target=cities-labels 'dy=-10' where='["Pittsburgh", "State College"].indexOf(NAME) > -1' \
  -style target=cities-labels 'dy=15' where='["Allentown", "Erie","State College"].indexOf(NAME) > -1' \
  -each target=cities-labels 'dx=-5' where='["Philadelphia","Harrisburg"].indexOf(NAME) > -1' \
  -style target=cities r=4 stroke=#fff stroke-width=0.25 \
  -each target=cities 'type="point"' \
  -each target=cities-labels 'type="text-label"' \
  -merge-layers target=cities-labels,cities force \
  -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/blocks_simplified/water_simplified.json' name=water \
  -style target=water fill=#000 stroke=none \
  -proj EPSG:3652 \
  -each 'type="water"' \
  -clip us-cart \
```

# Specialized maps

### PA House 2013 Population Deviations
```
  -i '/Users/cervas/My Drive/Projects/Redistricting/2022/PA/data/Plans/PA-2020-State-House.geojson' name=house \
  -proj target=house EPSG:3652 \
  -clip target=house us-cart \
  -classify target=house field=PopDevPct save-as=fill breaks=-0.05,0,0.05 colors=PuOr null-value="#fff" key-name="legend_popdev" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
  -style target=house opacity=1 stroke=fill stroke-width=0.0 stroke-opacity=0 \
  -dissolve target=house field=fill \
  -each target=house 'type="house"' \
```


### PA Senate 2013 Population Deviations
```
  -i '/Users/cervas/My Drive/Projects/Redistricting/2022/PA/data/Plans/PA-2020-State-Senate.geojson' name=senate \
  -proj target=senate EPSG:3652 \
  -clip target=senate us-cart \
  -classify target=senate field=PopDevPct save-as=fill breaks=-0.05,0,0.05 colors=PuOr null-value="#fff" \
  -style target=senate opacity=1 stroke=fill stroke-width=0.0 stroke-opacity=0 \
  -dissolve target=senate field=fill \
  -each target=senate 'type="senate"' \
```

### Tract density map
```
  -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/tracts/tracts.json' name=tracts \
  -proj EPSG:3652 \
  -each 'density = TOTAL / (ALAND20/2589988)' target=tracts \
  -classify field=density save-as=fill nice colors=OrRd classes=5 null-value="#fff" key-name="legend_popdensity" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 \
  -each 'type="tracts"' \
-filter target=tracts STATEFP20==42 + name=tracts-grey \
-classify field=density save-as=fill nice colors=greys classes=5 \ 
```


## Political Maps

### State House
```
  -i '/Users/cervas/My Drive/Projects/Redistricting/2022/PA/data/Plans/PA-2022-State-House.geojson' name=house2021 \
  -i '/Users/cervas/My Drive/GitHub/Data/Elections/State Legislature/PA/data/STH_house_dist.csv' name=house2022 string-fields=district \
  -proj target=house2021 EPSG:3652 \
  -clip target=house2021 us-cart \
  -join target=house2021 source=house2022 keys=NAME,district \
  -classify target=house2021 field=DEM save-as=fill breaks=0.5 colors=#C93135,#1375B7 null-value=#eee \
  -style target=house2021 opacity=0.5 stroke=#000 stroke-width=0.5 stroke-opacity=1 \
  -each target=house2021 'cx=this.innerX, cy=this.innerY' \
  -points target=house2021 x=cx y=cy + name=house2021-labels \
  -style target=house2021-labels label-text=id text-anchor=middle font-size=8px font-weight=800 line-height=8px font-family=helvetica class="g-text-shadow p" \
  -style target=house2021-labels fill=#000 stroke=none \
```

### State Senate
```
  -i '/Users/cervas/My Drive/Projects/Redistricting/2022/PA/data/Plans/PA-2022-State-Senate.geojson' name=senate2021 \
  -i '/Users/cervas/My Drive/GitHub/Data/Elections/State Legislature/PA/data/STS_sen_dist.csv' name=senate2022 string-fields=district \
  -proj target=senate2021 EPSG:3652 \
  -clip target=senate2021 us-cart \
  -join target=senate2021 source=senate2022 keys=NAME,district \
  -classify target=senate2021 field=DEM save-as=fill breaks=0.5 colors=#C93135,#1375B7 null-value=#eee \
  -style target=senate2021 opacity=0.5 stroke=#000 stroke-width=0.5 stroke-opacity=1 \
  -each target=senate2021 'cx=this.innerX, cy=this.innerY' \
  -points target=senate2021 x=cx y=cy + name=senate2021-labels \
  -style target=senate2021-labels label-text=id text-anchor=middle font-size=8px font-weight=800 line-height=8px font-family=helvetica class="g-text-shadow p" \
  -style target=senate2021-labels fill=#000 stroke=none \
```

  -style fill-pattern='hatches 45deg 2px red 2px grey'



# Output maps

Output "Counties" map:
```
  -o target=us-cart,counties,counties-labels '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_counties.svg'
```

Output "House" Deviation map:
```
  -o target=house,counties,us-cart,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_house_2020.svg'
```


Output "Senate" Deviation map:
```
  -o target=senate,counties,us-cart,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_senate_2020.svg'
```


Output "tracts" density map:
```
  -o target=tracts,water,counties,us-cart,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_tracts_pop.svg'
```

Output "House" Election map:
```
  -o target=tracts-grey,house2021,counties,us-cart,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_house_2022_election.svg'
```

Output "Senate" Election map:
```
  -o target=tracts-grey,senate2021,counties,us-cart,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_senate_2022_election.svg'
```

House District Map:
```
 -classify target=house2021 save-as=fill colors=Category20 non-adjacent \
 -style opacity=0.5 stroke=none \
-o target=tracts-grey,house2021,counties,us-cart,house2021-labels,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_house_2021.svg'

```

Senate District Map:
```
 -classify target=senate2021 field=id save-as=fill colors=#90EE90,#FFE4E1,#4682B4,#00c3ff,#ffb800,#005eff,#7B68EE,#38ffbf,#dcff1b,#FFFFE0,#ff2700,#62ff95,#ff8400,#11fae6,#ffe400,#001bff,#7FFF00,#0093ff,#F4A460,#7FFF00,#AFEEEE,#9370DB,#4682B4,#FFFFE0,#CD853F,#FF4500 \
 -style opacity=0.5 stroke=none \
-o target=tracts-grey,senate2021,counties,us-cart,senate2021-labels,cities '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/maps/PA_senate_2021.svg'

```

District colors:
#90EE90,#FFE4E1,#4682B4,#00c3ff,#ffb800,#005eff,#7B68EE,#38ffbf,#dcff1b,#FFFFE0,#ff2700,#62ff95,#ff8400,#11fae6,#ffe400,#001bff,#7FFF00,#0093ff,#F4A460,#7FFF00,#AFEEEE,#9370DB,#4682B4,#FFFFE0,#CD853F,#FF4500

# Create GIS files

To find the density in square miles, divide area by `2589988`.

## Blocks
```
mapshaper -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/blocks/pa_blocks20.shp' -simplify 0.1% -clean -o '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/blocks_simplified' format=geojson
```

```
mapshaper blocks_simplified/PA_blocks20_simplified.json \
  -dissolve COUNTY copy-fields='STATE,COUNTY' calc='TOTAL = sum(TOTAL),ALAND = sum(ALAND)' + name=PA_Counties \
  -o blocks_simplified/PA_Counties.json format=geojson
```

# Simplified Tracts
```
mapshaper -i ./tracts/pa_tracts20.shp -simplify 1% -clean -o blocks_simplified/PA_tracts20_simplified.json format=geojson force
```


## Water
```
mapshaper -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/blocks_simplified/pa_blocks20.json' name=water \
  -filter 'ALAND<1' \
  -simplify 0.1% \
  -clean \
  -dissolve
  -o '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/blocks_simplified/water_simplified.json' format=geojson force
```

To change the color of water areas: 
`-each 'color="#FFF"' where='ALAND == "0"' \`



```
cd '/Users/cervas/My Drive/GitHub/Data Files'
mapshaper -i 'Census/PA2020.pl/GIS/tracts/tracts.json' name=tracts \
  -i 'Census/PA2020.pl/GIS/tracts/tracts.json' name=Blacks \
  -i 'Census/PA2020.pl/GIS/tracts/tracts.json' name=Asians \
  -i 'Census/PA2020.pl/GIS/tracts/tracts.json' name=Hispanics \
  -i 'Census/PA2020.pl/GIS/tracts/tracts.json' name=Minorities \
  -i 'Census/PA2020.pl/GIS/cb_2021_us_state_500k.json' name=PA \
  -filter target="PA" 'GEOID=="42"' \
  -i Census/PA2020.pl/GIS/blocks_simplified/PA_Counties.json name=counties \
  -each 'density = Math.sqrt(TOTAL / (ALAND20/2589988))' target=tracts \
  -info target=tracts \
  -classify target="tracts" field=density save-as=fill key-name="legend_Density" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=10,15,25,40,50,60,70,80 colors='#ffffe5','#fff7bc','#fee391','#fec44f','#fe9929','#ec7014','#cc4c02','#993404','#662506' null-value="#fbf3e8" \
  -classify target="Blacks" field=black_per save-as=fill key-name="legend_Black" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=0.1,0.2,0.3,0.4,0.5 colors='#eff3ff','#c6dbef','#9ecae1','#6baed6','#3182bd','#08519c' null-value="#eff3ff" \
  -classify target="Hispanics" field=his_per save-as=fill key-name="legend_Hispanic" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=0.1,0.2,0.3,0.4,0.5 colors='#edf8e9','#c7e9c0','#a1d99b','#74c476','#31a354','#006d2c' null-value="#ecf7e9" \
  -classify target="Asians" field=asian_per save-as=fill key-name="legend_Asian" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=0.1,0.2,0.3,0.4,0.5 colors='#feedde','#fdd0a2','#fdae6b','#fd8d3c','#e6550d','#a63603' null-value="#feedde" \
  -classify target="Minorities" field=minority_p save-as=fill key-name="legend_Minorities" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=0.1,0.2,0.3,0.4,0.5 colors='#f7f7f7','#d9d9d9','#bdbdbd','#969696','#636363','#252525' null-value="#f7f7f7" \
  -each target="counties" 'type="counties"' \
  -proj EPSG:3652 target="Blacks,Asians,Hispanics,Minorities,tracts,PA,counties" \
  -style target="counties" fill=none stroke=#000 stroke-width=0.0 stroke-opacity=0.25 \
  -style target="PA" fill=none stroke=#000 stroke-width=1 \
  -clip target="Blacks" source=PA \
  -clip target="Asians" source=PA \
  -clip target="Hispanics" source=PA \
  -clip target="Minorities" source=PA \
  -dots target=tracts fields=TOTAL per-dot=100 colors="#662506" r=0.2 evenness=0 + name=dot_Total \
  -dots target=tracts fields=BLACK per-dot=100 colors="#08519c" r=0.2 evenness=0 + name=dot_Blacks \
  -o target="Blacks,PA" maps/Black_PA_2020.svg format=svg svg-data='NAME,cntyname,BLACK,black_per' combine-layers \
  -o target="tracts,PA" maps/Density_PA_2020.svg format=svg svg-data='NAME,cntyname,density,TOTAL' combine-layers \
  -o target="Hispanics,PA" maps/Hispanics_PA_2020.svg format=svg svg-data='NAME,cntyname,HISPANIC,his_per' combine-layers \
  -o target="Asians,PA" maps/Asians_PA_2020.svg format=svg svg-data='NAME,cntyname,ASIAN,asian_per' combine-layers \
  -o target="Minorities,PA" maps/Minorities_PA_2020.svg format=svg svg-data='NAME,cntyname,minority_p' combine-layers \
  -o target="dot_Total,PA" maps/dots_Total_PA_2020.svg format=svg combine-layers \
  -o target="dot_Blacks,PA" maps/dots_Black_PA_2020.svg format=svg combine-layers
```


```
mapshaper -i '/Users/cervas/My Drive/Projects/Redistricting/2022/PA/GIS/precincts.json' name='precincts' \
  -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/cb_2021_us_state_500k.json' name=PA \
  -i '/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/LDPC_gis/WP_Counties.json' name=counties \
  -filter target="PA" 'GEOID=="42"' \
  -proj EPSG:3652 target='counties,precincts,PA' \
  -clip target="precincts" source=PA \
  -clip target="counties" source=PA \
  -innerlines target="counties" \
  -style target="counties" stroke=#fff stroke-width=1.0 stroke-opacity=0.5 \
  -each 'margin = Y20PRESD-Y20PRESR' target=precincts \
  -each 'density = (Y20PRESD+Y20PRESR)/(ALAND20/2589988)' target=precincts \
  -classify target="precincts" field=margin save-as=fill key-name="legend_Political" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" breaks=-1000,-750,-500,-250,-1,1,250,500,750,1000 colors='#ca0020','#ffffff','#0571b0' null-value="#fff" \
  -style target="precincts" opacity=density/330 \
  -dots target=precincts fields='Y20PRESD,Y20PRESR' per-dot=10 colors="#445e96,#ba3a33" r=0.2 evenness=0 + name=dot_DEM \
  -style target="PA" fill=none stroke=#000 stroke-width=1 \
  -o target="precincts,counties,PA" "/Users/cervas/My Drive/Projects/Redistricting/2022/PA/GIS/PA_2020_precinct.svg" format=svg combine-layers \
  -o target="dot_DEM,counties,PA" "/Users/cervas/My Drive/Projects/Redistricting/2022/PA/GIS/PA_2020_precinct_dots.svg" format=svg combine-layers  
```


```
mapshaper -i "GIS/2021-10-14 LRC Data Release No. 2 (with prisoner reallocations)/Geography/WP_Municipalities_reallocated.shp" \
  -proj EPSG:3652 \
  -each 'density = P0010001 / (ALAND20/2589988)' \
  -each 'sqrtdensity = Math.sqrt(density)' \
  -classify field=sqrtdensity save-as=fill nice colors=OrRd classes=9 null-value="#fff" \
  -each 'type="muni"' \
  -i GIS/blocks_simplified/PA_Counties.json \
  -each 'type="counties"' \
  -proj EPSG:3652 \
  -style fill=none stroke=#000 stroke-width=0.5 opacity=0.25 \
  -i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Cartographic/2021/cb_2021_us_all_500k/cb_2021_us_state_500k/cb_2021_us_state_500k.shp' \
  -filter 'GEOID=="42"' \
  -proj EPSG:3652 \
  -style fill=none stroke=#000 stroke-width=1 \
  -o blocks_simplified/PA_muni.svg format=svg svg-data=TOTAL combine-layers
```

`mapshaper blocks_simplified/PA_blocks20_simplified.json -info`

`mapshaper blocks_simplified/PA_blocks20_simplified.json -calc 'min(TOTAL)' -calc 'median(TOTAL)' -calc 'mean(TOTAL)' -calc 'max(TOTAL)' -calc 'sum(TOTAL)'``


# Generate a tract-level Shapefile of populated areas by dissolving census blocks with non-zero population.
```
mapshaper blocks/*.shp \
  -each 'TRACT=GEOID.substr(0,11)' \
  -filter 'TOTAL > 0' \
  -dissolve TRACT sum-fields=TOTAL \
  -o blocks_simplified/out.json
```

`-merge-layers force target=water, {NAME OF LAYER 2}``

```
mapshaper -i "/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/2021-10-14 LRC Data Release No. 2 (with prisoner reallocations)/Geography/WP_Tracts_reallocated.shp" name=map \
  -join "/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/PL_diff.P1.csv" keys=GEOID20,GEO_ID string-fields=GEO_ID \
  -proj EPSG:3652 \
  -each 'diff=P0010001-P001001' \
  -classify field=diff save-as=fill breaks=0,500,1000 colors=#ca0020,#f4a582,#bababa,#404040 null-value="#fff" \
  -o /Users/cervas/Downloads/PA_tract_diff.svg format=svg svg-data=diff
```


# Nordenbergmander
```
mapshaper -i "/Users/cervas/My Drive/Projects/Redistricting/2022/PA/data/Plans/PA-LRC-House-Preliminary.geojson" name=LRCpre \
  -i "/Users/cervas/My Drive/GitHub/Data Files/Census/PA2020.pl/GIS/Certified-Geography/WP_Municipalities.shp" name=muni \
  -proj target="muni,LRCpre" EPSG:3652 \
  -style target=muni fill=none stroke=#000 stroke-width=0.5 stroke-opacity=0.25 \
  -style target=LRCpre fill=none stroke=#000 stroke-width=1 \
  -filter target=LRCpre 'NAME == "84"' + name=HD84 \
  -clip target=muni source=HD84 + name=HD84muni \
  -o target="HD84muni,HD84" '/Users/cervas/Downloads/LRCpre84.svg' format=svg combine-layers
```
