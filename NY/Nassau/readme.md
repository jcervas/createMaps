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
cd '/Users/cervas/My Drive/GitHub/createMaps/NY/Nassau' \
mapshaper-xl 20gb \
-i '/Users/cervas/My Drive/GitHub/Data Files/GIS/Tigerline/TIGER2020PL/blocks/NY/tl_2020_36_tabblock20.shp' name=blocks \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/blocks-csv.csv' name=blocks-csv \
-i '/Users/cervas/My Drive/GitHub/createMaps/NY/P4-blocks-csv.csv' name=blocks-p4-csv \
-join target=blocks source=blocks-csv keys=GEOID20,GEOID20 \
-join target=blocks source=blocks-p4-csv keys=GEOID20,GEOID20 \
-each target=blocks 'density = P1_001N / (ALAND20/2589988)' \
-each target=blocks 'minority = (P4_001N - P4_005N)/P4_001N * 100' \
-classify target=blocks field=density save-as=fill nice colors=greys classes=9 key-name="legend-blocks-minority" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="%" \
-o 'images/minority-blocks.svg'
```
