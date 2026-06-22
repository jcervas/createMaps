#!/usr/bin/env Rscript
# ============================================================
# acs_by_state.R
# Pulls state-level ACS 5-year estimates for the district-guess
# game's STATE-PHASE clues (the QuickFacts-style facts shown
# while the player is still guessing the state).
#
# Output: acs_by_state.csv  (one row per state, 50 + DC)
#
# Variables (mirrors census.gov/quickfacts):
#   pop             B01003_001   Total population
#   whiteNH_pct     B03002_003 / B03002_001
#   black_pct       B03002_004 / B03002_001
#   asian_pct       B03002_006 / B03002_001
#   hispanic_pct    B03002_012 / B03002_001
#   foreignBorn_pct B05002_013 / B05002_001
#   medianRent      B25064_001   Median gross rent ($)
#   bachPlus_pct    (B15003_022+023+024+025) / B15003_001  (age 25+)
#   meanTravelTime  B08013_001 / B08012_001  (minutes)
#   landAreaSqMi    TIGER ALAND (from tigris::states), m^2 -> sq mi
#
# Requires: tidycensus, tidyverse, tigris
# Set CENSUS_API_KEY env var (preferred) or census_api_key() below.
# ============================================================

if (!requireNamespace("tidycensus", quietly = TRUE)) {
  install.packages("tidycensus", repos = "https://cloud.r-project.org")
}
suppressPackageStartupMessages({
  library(tidycensus)
  library(tidyverse)
  library(tigris)
})
options(tigris_use_cache = TRUE)

# Prefer the env var; fall back to the shared key used by acs_by_district.R.
key <- Sys.getenv("CENSUS_API_KEY")
if (nzchar(key)) census_api_key(key) else
  census_api_key("95fe940d2fe95c12900a6f024c35f29fac6f28ee")

OUT_FILE <- "/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/acs_by_state.csv"
ACS_YEAR <- 2024   # most recent ACS 5-year

ACS_VARS <- c(
  pop          = "B01003_001",
  race_total   = "B03002_001",
  whiteNH      = "B03002_003",
  black        = "B03002_004",
  asian        = "B03002_006",
  hispanic     = "B03002_012",
  fb_total     = "B05002_001",
  foreignBorn  = "B05002_013",
  medianRent   = "B25064_001",
  edu_total    = "B15003_001",
  bach         = "B15003_022",
  master       = "B15003_023",
  prof         = "B15003_024",
  doctorate    = "B15003_025",
  travel_agg   = "B08013_001",
  travel_wrk   = "B08012_001"
)

message("Fetching state-level ACS ", ACS_YEAR, " 5-year estimates...")
# output="wide" yields estimate columns suffixed with "E" (e.g. popE) and margins
# with "M". Reference the "E" columns directly — renaming is fragile because
# tidyselect's ends_with("E") also matches the NAME column.
raw <- get_acs(geography = "state", variables = ACS_VARS,
               year = ACS_YEAR, output = "wide")

# ── Land area (sq mi) from TIGER ALAND (square meters) ────────────────────────
message("Fetching state land areas from TIGER...")
land <- tigris::states(cb = TRUE, year = 2023, progress_bar = FALSE) %>%
  sf::st_drop_geometry() %>%
  transmute(GEOID = GEOID,
            landAreaSqMi = round(as.numeric(ALAND) / 2589988.110336))

# ── State abbreviation lookup ─────────────────────────────────────────────────
state_abbr <- tigris::fips_codes %>%
  distinct(state_code, state) %>%
  rename(GEOID = state_code, abbr = state)

pct <- function(num, den) round(100 * num / den, 1)

out <- raw %>%
  left_join(land,       by = "GEOID") %>%
  left_join(state_abbr, by = "GEOID") %>%
  transmute(
    state           = abbr,
    name            = NAME,
    pop             = round(popE),
    whiteNH_pct     = pct(whiteNHE,  race_totalE),
    black_pct       = pct(blackE,    race_totalE),
    asian_pct       = pct(asianE,    race_totalE),
    hispanic_pct    = pct(hispanicE, race_totalE),
    foreignBorn_pct = pct(foreignBornE, fb_totalE),
    medianRent      = round(medianRentE),
    bachPlus_pct    = pct(bachE + masterE + profE + doctorateE, edu_totalE),
    meanTravelTime  = round(travel_aggE / travel_wrkE, 1),
    landAreaSqMi    = landAreaSqMi
  ) %>%
  filter(!is.na(state)) %>%
  arrange(state)

message(sprintf("Writing %d states to %s", nrow(out), OUT_FILE))
write_csv(out, OUT_FILE)

message("\nSample output:")
print(head(out, 6))
message("\nDone.")
