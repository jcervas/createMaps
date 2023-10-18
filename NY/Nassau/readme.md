# Code to create map of Nassau County

```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/censusAPI/decennialAPI.R")
blocks <- decennialAPI(state="NY", geo="block", table="P1")
columns_to_remove <- grep("A$", colnames(blocks))
data_filtered <- blocks[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/NY/blockscsv.csv")
```

ny <- decennialAPI(state="NY", geo="block", table="P4", variables=c("P4_001N","P4_005N"))
ny$GEOID20 <- paste0(ny$state, ny$county, ny$tract, ny$block)
write.csv(ny, "/Users/cervas/My Drive/GitHub/createMaps/NY/P4-blocks-csv.csv", row.names=F)

```
cd '/Users/cervas/My Drive/GitHub/createMaps/NY/Nassau'
mapshaper-xl 2gb \
-i '/Users/cervas/My Drive/Projects/Redistricting/2023/Nassau/data/Plans/nassau-county-adopted-2023.geojson' name=nassau-2023-enacted \
-style fill=none stroke=#000 \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/NY/tl_2020_36_tabblock20.shp' name=blocks \
-simplify 0.1 \
-filter 'COUNTYFP20 == "059"' \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/blocks-csv.csv' name=blocks-csv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/P4-blocks-csv.csv' name=P4-blocks-csv string-fields=GEOID20 \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-cart.json' name=us-cart \
-filter target=us-cart 'STUSPS == "NY"' \
-join target=blocks source=blocks-csv keys=GEOID20,GEOID20 \
-join target=blocks source=P4-blocks-csv keys=GEOID20,GEOID20 \
-each target=blocks 'density = P1_001N / (ALAND20/2589988)' \
-each target=blocks 'minority = (P4_001N - P4_005N)/P4_001N * 100' \
-classify target=blocks field=minority save-as=fill nice colors='#ffffff,#f0f0f0,#d9d9d9,#bdbdbd,#969696' breaks=10,25,50,75 null-value="#fff" key-name="legend-blocks-minority" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-dissolve target=blocks field=fill \
-clip source=us-cart target=blocks \
-clip source=us-cart target=nassau-2023-enacted \
-proj target=blocks,nassau-2023-enacted '+proj=lcc +lat_1=41.03333333333333 +lat_2=40.66666666666666 +lat_0=40.16666666666666 +lon_0=-74 +x_0=300000 +y_0=0 +ellps=GRS80 +units=m +no_defs' \
-o target=blocks,border,nassau-2023-enacted 'images/minority-blocks.svg'
```
