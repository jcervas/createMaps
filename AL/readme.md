
```
-filter target=clip STATEFP==01
-style target=clip fill=none stroke=#000 opacity=1 stroke-opacity=1

-dissolve target=pop COUNTYF + name=county
-style target=county fill=none stroke-opacity=0.5 stroke=#fff stroke-width=0.5

-each 'blackper=BLACK/TOTAL'
-classify field=blackper save-as=fill nice colors=Greys breaks=.1,.25,.5,2,3,4,5 null-value="#fff"


-style target=cd stroke-width=2


-proj target=* '+proj=tmerc +lat_0=30 +lon_0=-87.5 +k=0.9999333333333333 +x_0=600000.0000000001 +y_0=0 +ellps=GRS80 +datum=NAD83 +to_meter=0.3048006096012192 +no_defs '


```
