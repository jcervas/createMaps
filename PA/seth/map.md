cd "/Users/cervas/My Drive/Academic/Advising/bolden-seth/thesis/data"
mapshaper \
-i '/Users/cervas/Library/Mobile Documents/com~apple~CloudDocs/Downloads/tl_2020_42_cousub20/tl_2020_42_cousub20.shp' name=muni \
-i '/Users/cervas/My Drive/Academic/Advising/bolden-seth/thesis/data/all_merged.csv' string-fields=COUSUB20 name=all_merged \
-join target=muni source=all_merged keys=GEOID20,COUSUB20 \
-filter target=muni "countyclass=='urban'" + name=urban \
-filter target=muni "countyclass=='rural'" + name=rural \
-classify target=urban field=municipalclass colors=Purples \
-classify target=rural field=municipalclass colors=Greens \
-o target=urban,rural '/Users/cervas/My Drive/Academic/Advising/bolden-seth/thesis/data/all_merged.svg'