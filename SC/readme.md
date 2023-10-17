SC

```
cd '/Users/cervas/My Drive/GitHub/createMaps/SC/images/legends'
mapshaper \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=ST \
-filter STATEFP==45 \
-i '/Users/cervas/My Drive/GitHub/createMaps/SC/SC-cd-2022.geojson' name=SC-cd \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-roads.json' name=roads \
-style stroke-opacity=0.05 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-tracts.geojson' name=pop \
-filter STATEFP20==45 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-urban.json' name=urban \
-dissolve target=pop COUNTYFP20 + name=county \
-style target=county fill=none stroke-opacity=0.5 stroke=#fff stroke-width=0.5 \
-classify target=pop field=density save-as=fill nice colors=greys classes=5 key-name="legend_densitySC_tracts" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-dots target=pop fields=P1_001N save-as=fill r=0.5 per-dot=100 copy-fields=P1_001N + name=pop-dots \
-style target=pop-dots fill=#ccc opacity=0.5 \
-proj target=urban,pop,pop-dots,roads,county,ST,SC-cd '+proj=lcc +lat_1=34.83333333333334 +lat_2=32.5 +lat_0=31.83333333333333 +lon_0=-81 +x_0=609600 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048 +no_defs' \
-style target=ST fill=none stroke=#000 opacity=1 stroke-opacity=1 \
-clip target=SC-cd source=ST \
-clip target=county source=ST \
-clip target=pop source=ST \
-clip target=urban source=ST \
-clip target=roads source=ST \
-innerlines target=SC-cd + name=cd-lines \
-each target=SC-cd "cx=$.innerX, cy=$.innerY" \
-points target=SC-cd x=cx y=cy + name=district-labels \
-style target=district-labels label-text=id  text-anchor=start font-size=13px font-weight=800 line-height=16px font-family=arial class="g-text-shadow p" \
-style target=SC-cd fill=color stroke=none \
-o target=pop-dots,roads,county,cd-lines,district-labels,ST '/Users/cervas/My Drive/GitHub/createMaps/SC/images/SC-pop-dots.svg' \
-o target=urban,SC-cd,county,district-labels,ST '/Users/cervas/My Drive/GitHub/createMaps/SC/images/SC-cd.svg'
```

![](SC-cd.png)
