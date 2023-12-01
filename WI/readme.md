WI

```
cd '/Users/cervas/My Drive/GitHub/createMaps/WI/images/legends'
mapshaper \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=ST \
-filter STATEFP==55 \
-i '/Users/cervas/My Drive/GitHub/createMaps/WI/WI-assembly-2022.geojson' name=WI-assembly \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-roads.json' name=roads \
-style stroke-opacity=0.05 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-tracts.geojson' name=tracts \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-tracts.geojson' name=pop \
-filter STATEFP20==55 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-urban.json' name=urban \
-dissolve target=pop COUNTYFP20 + name=county \
-style target=county fill=none stroke-opacity=0.5 stroke=#fff stroke-width=0.5 \
-classify target=pop field=density save-as=fill nice colors=greys classes=5 key-name="legend_densityWI_tracts" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-dots target=pop fields=P1_001N save-as=fill r=1 per-dot=1000 copy-fields=P1_001N + name=pop-dots \
-style target=pop-dots fill=#ccc opacity=0.5 \
-proj target=urban,tracts,pop,pop-dots,roads,county,ST,WI-assembly '++proj=lcc +lat_1=45.5 +lat_2=44.25 +lat_0=43.83333333333334 +lon_0=-90 +x_0=600000 +y_0=0 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +to_meter=0.3048006096012192 +no_defs' \
-style target=ST fill=none stroke=#000 opacity=1 stroke-opacity=1 \
-clip target=WI-assembly source=ST \
-clip target=county source=ST \
-clip target=pop source=ST \
-clip target=urban source=ST \
-clip target=roads source=ST \
-innerlines target=WI-assembly + name=assembly-lines \
-each target=WI-assembly "cx=$.innerX, cy=$.innerY" \
-points target=WI-assembly x=cx y=cy + name=district-labels \
-style target=district-labels label-text=id  text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-style target=WI-assembly fill=color stroke=none \
-o target=pop-dots,roads,county,assembly-lines,ST '/Users/cervas/My Drive/GitHub/createMaps/WI/images/WI-pop-dots.svg' \
-o target=urban,WI-assembly,county,district-labels,ST '/Users/cervas/My Drive/GitHub/createMaps/WI/images/WI-assembly.svg' \
-each target=tracts 'density = P1_001N / (ALAND20/2589988)' target=tracts \
-classify target=tracts field=density save-as=fill nice colors=OrRd classes=5 null-value="#fff" key-name="legend_popdensity" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 \
-each target=tracts 'type="tracts"' \
-clip target=tracts source=ST \
-filter target=tracts STATEFP20==55 + name=tracts-grey \
-classify target=tracts-grey field=density save-as=fill nice colors=greys classes=5 \
-dissolve target=tracts,tracts-grey fields=fill \
-simplify target=tracts,tracts-grey 0.01 \
-o target=tracts,counties,ST,cities '/Users/cervas/My Drive/GitHub/createMaps/WI/images/WI_tracts_pop.svg'
```

![](WI-assembly.png)
