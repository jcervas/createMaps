# createMaps

This repository houses code to create maps in mapshaper.org.

Instructions to install `mapshaper` for terminal: 

Download GIS files: https://www.census.gov/geographies/mapping-files/time-series/geo/tiger-line-file.2020.html#list-tab-790442341


### Code to gather census data

```{r}
source("https://raw.githubusercontent.com/jcervas/R-Functions/main/censusAPI/censusAPI.R")
state_fips <- c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FL",
              "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME",
              "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH",
              "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI",
              "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY")
census <- list()
for (i in 1:length(state_fips)) {
  census[[i]] <- decennialAPI(state=state_fips[i], geo="tract", table="P1")
  }
census <- do.call(rbind,census)
columns_to_remove <- grep("A$", colnames(census))
data_filtered <- census[, -columns_to_remove]
data_filtered$GEOID20 <- gsub("1000000US", "", data_filtered$GEO_ID)
data_filtered$GEOID20 <- gsub("1400000US", "", data_filtered$GEO_ID)
# data_filtered$blkgrp <- substr(data_filtered$GEOID20, 1, 12)
write.csv(data_filtered, "/Users/cervas/My Drive/GitHub/createMaps/tractscsv.csv")
```

```
cd '/Users/cervas/My Drive/GitHub/createMaps'
mapshaper \
-i '/Users/cervas/My Drive/GitHub/createMaps/us-tracts-originial.json' name=us-tracts \
-simplify 0.05 \
-i '/Users/cervas/My Drive/GitHub/createMaps/tractscsv.csv' string-fields=GEOID20 name=tracts-csv \
-join target=us-tracts source=tracts-csv keys=GEOID20,GEOID20 \
-each target=us-tracts 'density = P4_001N / (ALAND20/2589988)' \
-classify target=us-tracts field=density save-as=fill nice colors=greys classes=9 key-name="legend_density_tracts" key-style="simple" key-tile-height=10 key-width=320 key-font-size=10 key-last-suffix="" \
-o '/Users/cervas/My Drive/GitHub/createMaps/us-tracts.geojson'
```
