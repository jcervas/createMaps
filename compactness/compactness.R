# Compactness analysis for district plans
# Measures: Polsby-Popper, Reock, Convex Hull
# Ranks districts from least to most compact within each plan

library(sf)
library(dplyr)
library(purrr)

# ── Configuration ──────────────────────────────────────────────────────────────
plans_dir <- "mid-decade-redistricting/mid-decade"
output_csv <- "compactness_results.csv"

# ── Helper: minimum bounding circle radius (for Reock) ────────────────────────
# Uses the circumscribed circle of the bounding box as an upper-bound proxy,
# or the exact MBC via iterative algorithm when lwgeom is available.
reock_score <- function(geom) {
  area <- as.numeric(st_area(geom))
  # Use minimum bounding circle if lwgeom available, else bounding box circle
  mbc <- tryCatch(
    lwgeom::st_minimum_bounding_circle(geom),
    error = function(e) NULL
  )
  if (!is.null(mbc)) {
    circle_area <- as.numeric(st_area(mbc))
  } else {
    bb <- st_bbox(geom)
    dx <- bb["xmax"] - bb["xmin"]
    dy <- bb["ymax"] - bb["ymin"]
    r <- sqrt(dx^2 + dy^2) / 2
    circle_area <- pi * r^2
  }
  area / circle_area
}

# ── Compactness scores for one sf row ─────────────────────────────────────────
compute_scores <- function(geom) {
  geom_proj <- st_transform(geom, 5070)  # CONUS Albers Equal Area

  area  <- as.numeric(st_area(geom_proj))
  perim <- as.numeric(st_length(st_cast(st_union(geom_proj), "MULTILINESTRING")))
  hull  <- st_convex_hull(geom_proj)

  pp  <- (4 * pi * area) / (perim^2)
  ch  <- area / as.numeric(st_area(hull))
  rk  <- reock_score(geom_proj)

  list(polsby_popper = round(pp, 4),
       convex_hull   = round(ch, 4),
       reock         = round(rk, 4))
}

# ── Process one plan file ──────────────────────────────────────────────────────
process_plan <- function(path) {
  plan_name <- tools::file_path_sans_ext(basename(path))
  message("Processing: ", plan_name)

  sf_obj <- tryCatch(st_read(path, quiet = TRUE), error = function(e) {
    warning("Could not read: ", path, " — ", conditionMessage(e))
    return(NULL)
  })
  if (is.null(sf_obj)) return(NULL)

  # Identify district ID column
  id_col <- intersect(c("id", "NAME", "DISTRICT", "District", "district",
                         "CD", "GEOID", "OBJECTID"), names(sf_obj))
  id_col <- if (length(id_col) > 0) id_col[1] else NULL

  rows <- lapply(seq_len(nrow(sf_obj)), function(i) {
    row <- sf_obj[i, ]
    scores <- tryCatch(compute_scores(st_geometry(row)),
                       error = function(e) list(polsby_popper = NA,
                                                convex_hull   = NA,
                                                reock         = NA))
    district_id <- if (!is.null(id_col)) as.character(row[[id_col]]) else as.character(i)
    data.frame(plan        = plan_name,
               district_id = district_id,
               polsby_popper = scores$polsby_popper,
               convex_hull   = scores$convex_hull,
               reock         = scores$reock,
               stringsAsFactors = FALSE)
  })

  bind_rows(rows)
}

# ── Run across all plans ───────────────────────────────────────────────────────
geojson_files <- list.files(plans_dir, pattern = "\\.geojson$",
                            full.names = TRUE)

results <- map_dfr(geojson_files, process_plan)

# ── Add composite ill-compactness rank ────────────────────────────────────────
# Lower scores = less compact; rank by average of the three measures (ascending)
results <- results %>%
  mutate(
    mean_compactness = rowMeans(cbind(polsby_popper, convex_hull, reock),
                                na.rm = TRUE),
    # Rank within each plan (1 = least compact district in the plan)
    rank_in_plan = ave(mean_compactness, plan,
                       FUN = function(x) rank(x, ties.method = "min"))
  ) %>%
  arrange(mean_compactness)

# ── Print summary ──────────────────────────────────────────────────────────────
cat("\n=== Most ill-compact districts (bottom 20 by mean score) ===\n")
print(head(results %>% select(plan, district_id, polsby_popper, convex_hull,
                               reock, mean_compactness), 20),
      row.names = FALSE)

cat("\n=== Plan-level summary (mean compactness per plan) ===\n")
plan_summary <- results %>%
  group_by(plan) %>%
  summarise(
    n_districts      = n(),
    mean_pp          = round(mean(polsby_popper, na.rm = TRUE), 4),
    mean_ch          = round(mean(convex_hull,   na.rm = TRUE), 4),
    mean_reock       = round(mean(reock,         na.rm = TRUE), 4),
    mean_compactness = round(mean(mean_compactness, na.rm = TRUE), 4),
    worst_district   = district_id[which.min(mean_compactness)],
    .groups = "drop"
  ) %>%
  arrange(mean_compactness)

print(plan_summary, n = Inf)

# ── Write output ───────────────────────────────────────────────────────────────
write.csv(results, output_csv, row.names = FALSE)
write.csv(plan_summary, sub("\\.csv$", "_by_plan.csv", output_csv),
          row.names = FALSE)

message("\nResults written to: ", output_csv)
message("Plan summary written to: ",
        sub("\\.csv$", "_by_plan.csv", output_csv))
