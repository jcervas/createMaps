NY

```

-clip clip
-each target=ny "cx=$.innerX, cy=$.innerY"
-points target=ny x=cx y=cy + name=district-labels
-style target=district-labels label-text=CD118FP
-style fill=none stroke=#fff stroke-width=0.5

-proj '+proj=tmerc +lat_0=40 +lon_0=-76.58333333333333 +k=0.999938 +x_0=250000 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs '

-each 'density = TOTAL / (ALAND/2589988)' target=NY_blocks20_simplified-each 'density = TOTAL / (ALAND/2589988)' target=NY_blocks20_simplified
-each 'sqrtdensity = Math.sqrt(density)'

-classify field=sqrtdensity save-as=fill breaks=10,20,40,80,160,320 colors=Greys classes=9 null-value="#fff"
```
