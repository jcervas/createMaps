# createMaps

This repository houses code to create maps in mapshaper.org.

Instructions to install `mapshaper` for terminal: 

Download GIS files: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2020.html#list-tab-790442341


### Code to gather census data

```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/censusAPI/censusAPI.R")
census <- censusAPI(state="*", geo="tract", table="P1")
columns_to_remove <- grep("A$", colnames(census))
data_filtered <- census[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
# data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/tractscsv.csv")
```
