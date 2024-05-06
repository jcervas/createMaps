# Seth's Classification Scheme

`
cd "/Users/cervas/My Drive/GitHub/createMaps/PA/seth"
mapshaper \
-i '/Users/cervas/My Drive/GitHub/createMaps/PA/seth/tl_2020_42_cousub20.json' name=muni \
-proj EPSG:3652 \
-i '/Users/cervas/My Drive/GitHub/createMaps/PA/seth/all_merged.csv' string-fields=COUSUB20 name=all_merged \
-join target=muni source=all_merged keys=GEOID20,COUSUB20 \
-filter target=muni "countyclass=='urban'" + name=urban \
-filter target=muni "countyclass=='rural'" + name=rural \
-classify target=urban field=municipalclass colors=Purples key-name="legend_urbancounty" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 \
-classify target=rural field=municipalclass colors=Greens key-name="legend_ruralcounty" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 \
-o target=urban,rural '/Users/cervas/My Drive/GitHub/createMaps/PA/seth/classification-map.svg'
`

<img src="class.png">
