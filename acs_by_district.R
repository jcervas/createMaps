#!/usr/bin/env Rscript
# ============================================================
# acs_by_district.R
# Aggregates ACS 5-year tract-level estimates to 120th Congress
# district boundaries using DRA block assignment files.
#
# Output: acs_by_district.csv  (one row per state-district)
#
# Variables aggregated:
#   pop          B01003_001E  Total population
#   income       B19013_001E  Median household income (pop-wtd mean of tract medians)
#   whiteNH      B03002_003E  White alone, not Hispanic
#   black        B03002_004E  Black alone, not Hispanic
#   asian        B03002_006E  Asian alone, not Hispanic
#   hispanic     B03002_012E  Hispanic or Latino
#   medianHome   B25077_001E  Median home value (pop-wtd mean of tract medians)
#   bach         B15003_022E  Bachelor's degree
#   master       B15003_023E  Master's degree
#
# Requires: tidycensus, tidyverse
# Set CENSUS_API_KEY env var or call census_api_key() first.
# ============================================================

if (!requireNamespace("tidycensus", quietly = TRUE)) {
  install.packages("tidycensus", repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(tidycensus)
  library(tidyverse)
})

census_api_key("95fe940d2fe95c12900a6f024c35f29fac6f28ee")

BAF_DIR  <- "/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/dra-block-assignments/2022-2026/congress"
OUT_FILE <- "/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/acs_by_district.csv"
ACS_YEAR <- 2023   # most recent ACS 5-year

ACS_VARS <- c(
  pop        = "B01003_001",
  income     = "B19013_001",
  whiteNH    = "B03002_003",
  black      = "B03002_004",
  asian      = "B03002_006",
  hispanic   = "B03002_012",
  medianHome = "B25077_001",
  bach       = "B15003_022",
  master     = "B15003_023"
)

# ── State FIPS lookup ──────────────────────────────────────────────────────────
state_fips <- tigris::fips_codes %>%
  distinct(state, state_code) %>%
  rename(abbr = state, fips = state_code)

# ── Pick most recent BAF per state ────────────────────────────────────────────
baf_files <- tibble(path = list.files(BAF_DIR, pattern = "\\.csv$", full.names = TRUE)) %>%
  mutate(
    fname = basename(path),
    abbr  = str_extract(fname, "^[A-Z]+"),
    year  = as.integer(str_extract(fname, "[0-9]{4}"))
  ) %>%
  group_by(abbr) %>%
  slice_max(year, n = 1, with_ties = FALSE) %>%
  ungroup()

message(sprintf("Found BAF files for %d states (most recent plan per state).", nrow(baf_files)))

# ── Process each state ────────────────────────────────────────────────────────
results <- map_dfr(seq_len(nrow(baf_files)), function(i) {
  row   <- baf_files[i, ]
  abbr  <- row$abbr
  fips  <- state_fips$fips[state_fips$abbr == abbr]
  if (length(fips) == 0) { message("  Skipping ", abbr, " — no FIPS found"); return(NULL) }

  message(sprintf("[%d/%d] %s (%s plan)", i, nrow(baf_files), abbr, row$year))

  # 1. Load BAF: block → district
  baf <- read_csv(row$path, col_types = cols(GEOID20 = col_character(), District = col_integer()),
                  show_col_types = FALSE) %>%
    mutate(tract_fips = str_sub(GEOID20, 1, 11))

  # 2. Get 2020 block populations for weighting
  message("   Getting block populations...")
  blk_pop <- tryCatch(
    get_decennial(geography = "block", variables = "P1_001N",
                  state = abbr, year = 2020, output = "wide", show_col_types = FALSE) %>%
      select(GEOID, pop20 = P1_001N),
    error = function(e) { message("   Block pop failed: ", e$message); NULL }
  )
  if (is.null(blk_pop)) return(NULL)

  # 3. Build tract→district crosswalk (population-weighted)
  crosswalk <- baf %>%
    left_join(blk_pop, by = c("GEOID20" = "GEOID")) %>%
    mutate(pop20 = replace_na(pop20, 0)) %>%
    group_by(tract_fips, District) %>%
    summarise(tract_dist_pop = sum(pop20), .groups = "drop") %>%
    group_by(tract_fips) %>%
    mutate(weight = tract_dist_pop / sum(tract_dist_pop)) %>%
    ungroup()

  # 4. Get ACS tract data
  # CT switched to new Planning Region county codes in 2022 ACS; 2020 blocks use old codes.
  # Use 2021 ACS for CT so tract GEOIDs match the BAF block GEOIDs.
  acs_year_state <- if (abbr == "CT") 2021L else ACS_YEAR
  message(sprintf("   Getting ACS tract data (year %d)...", acs_year_state))
  tracts <- tryCatch(
    get_acs(geography = "tract", variables = ACS_VARS,
            state = abbr, year = acs_year_state, output = "wide") %>%
      select(GEOID, ends_with("E")) %>%
      rename_with(~ str_remove(., "E$")) %>%
      mutate(across(where(is.numeric), ~ replace_na(., 0))),
    error = function(e) { message("   ACS tract failed: ", e$message); NULL }
  )
  if (is.null(tracts)) return(NULL)

  # 5. Join and aggregate to district
  tracts %>%
    left_join(crosswalk, by = c("GEOID" = "tract_fips")) %>%
    filter(!is.na(District)) %>%
    group_by(District) %>%
    summarise(
      pop        = sum(pop        * weight, na.rm = TRUE),
      # Medians: population-weighted average of tract medians (approximation)
      income     = weighted.mean(if_else(income     > 0, income,     NA_real_), tract_dist_pop * weight, na.rm = TRUE),
      medianHome = weighted.mean(if_else(medianHome > 0, medianHome, NA_real_), tract_dist_pop * weight, na.rm = TRUE),
      whiteNH    = sum(whiteNH  * weight, na.rm = TRUE),
      black      = sum(black    * weight, na.rm = TRUE),
      asian      = sum(asian    * weight, na.rm = TRUE),
      hispanic   = sum(hispanic * weight, na.rm = TRUE),
      bach       = sum(bach     * weight, na.rm = TRUE),
      master     = sum(master   * weight, na.rm = TRUE),
      .groups = "drop"
    ) %>%
    mutate(
      state    = abbr,
      district = str_pad(District, 2, pad = "0"),
      `state-district` = paste0(abbr, "-", district)
    ) %>%
    select(`state-district`, state, district, pop, income, medianHome,
           whiteNH, black, asian, hispanic, bach, master)
})

# ── At-large states not in BAF ────────────────────────────────────────────────
# (AK, DE, ND, SD, VT, WY — single at-large district)
at_large_states <- c("AK", "DE", "ND", "SD", "VT", "WY")
at_large_missing <- setdiff(at_large_states, baf_files$abbr)

if (length(at_large_missing) > 0) {
  message("\nFetching at-large states from ACS API: ", paste(at_large_missing, collapse = ", "))
  al_results <- map_dfr(at_large_missing, function(abbr) {
    message("  ", abbr)
    tryCatch({
      d <- get_acs(geography = "congressional district", variables = ACS_VARS,
                   state = abbr, year = ACS_YEAR, output = "wide") %>%
        select(ends_with("E")) %>%
        rename_with(~ str_remove(., "E$")) %>%
        slice(1)
      tibble(
        `state-district` = paste0(abbr, "-01"),   # GeoJSON uses 01 for at-large
        state = abbr, district = "01",
        pop = d$pop, income = d$income, medianHome = d$medianHome,
        whiteNH = d$whiteNH, black = d$black, asian = d$asian,
        hispanic = d$hispanic, bach = d$bach, master = d$master
      )
    }, error = function(e) { message("  Failed: ", e$message); NULL })
  })
  results <- bind_rows(results, al_results)
}

# ── Round and write ────────────────────────────────────────────────────────────
results <- results %>%
  mutate(across(c(pop, income, medianHome, whiteNH, black, asian, hispanic, bach, master),
                ~ round(., 0))) %>%
  arrange(`state-district`)

message(sprintf("\nWriting %d districts to %s", nrow(results), OUT_FILE))
write_csv(results, OUT_FILE)

# Summary
message("\nSample output:")
print(head(results, 6))
message("\nDone.")
