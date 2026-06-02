source('https://raw.githubusercontent.com/jcervas/R-Functions/refs/heads/main/census-scripts/decennialAPI/decennialAPI.R')
source('https://raw.githubusercontent.com/jcervas/R-Functions/refs/heads/main/coreRetention/coreRetention.R')
census_key <- "95fe940d2fe95c12900a6f024c35f29fac6f28ee"

readBlock <- function(x, id = "GEOID20", plan = "District") {
  col_spec <- setNames(list("character"), id)
  a <- read.csv(x, colClasses = col_spec)
  names(a)[2] <- plan
  return(a)
}

df <- readBlock(
     '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/sc-2020.csv',
     plan="SC2022")

df1 <- readBlock(
     '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/sc-H5683.csv',
     plan="SC_H5683")

sc <- merge(df,df1, by="GEOID20")

head(sc)

sc_blocks <- 
decennialAPI(
     state="SC", 
     geo="block", 
     table="P1",
     api_key = census_key)

sc_blocks$GEOID20 <- paste0(sc_blocks$state,sc_blocks$county,sc_blocks$tract,sc_blocks$block)

sc_full <- merge(sc, data.frame(GEOID20=sc_blocks$GEOID20,total=sc_blocks$P1_001N))

district_core_table(
  df        = sc_full,
  base_plan = "SC2022",
  plan_cols = c("SC2022","SC_H5683"),
  pop_col   = "total",
  digits    = 1
)

flag_district <- function(data, value, col_old, col_new,
                       labels = c(
                         unchanged = "unchanged",
                         subtracted = "subtracted",
                         added = "added"
                       )) {

  # keep rows where the value appears in either column
  tmp <- data[data[[col_old]] == value | data[[col_new]] == value, ]

  # classify direction
  tmp$direction <- ifelse(
    tmp[[col_old]] == value & tmp[[col_new]] == value,
    labels["unchanged"],
    ifelse(
      tmp[[col_old]] == value & tmp[[col_new]] != value,
      labels["subtracted"],
      labels["added"]
    )
  )

  tmp
}

# Usage
write.csv(flag_district(sc_full, 6, "SC2022", "SC_H5683"), '/Users/cervas/Downloads/sc_06.csv')


# Mapshaper Commands

mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/SC/sc_block.json' \
-i '/Users/cervas/Downloads/sc_06.csv' string-fields=GEOID20 \
-target sc_block \
-proj albersusa densify \
-filter 'ALAND20 == 0 && AWATER20 != 0' + name=water \
-style fill='rgba(160,216,242,1)' stroke=none \
-target sc_block \
-dissolve target=sc_block + name=state \
-style fill=none stroke=#000 \
-join target=sc_block source=sc_06 keys=GEOID20,GEOID20 \
-filter target=sc_block 'direction=="added"' + name=added \
-dissolve \
-style fill=lightgreen stroke=none \
-filter target=sc_block 'direction=="subtracted"' + name=subtracted \
-dissolve \
-style fill=red stroke=none \
-filter target=sc_block 'direction=="unchanged"' + name=unchanged \
-dissolve \
-style fill=gray stroke=none \
-each target=sc_block 'flag = direction=="added" || direction=="unchanged"' \
-filter flag + name=new_district \
-dissolve target=new_district \
-style fill=none stroke=#000 \
-o target=subtracted,unchanged,added,new_district,state '/Users/cervas/Downloads/sc-06.svg'






