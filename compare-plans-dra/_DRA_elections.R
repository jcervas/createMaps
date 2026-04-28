cd '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/OH/data/elections'

mkdir -p old_cleaned_dra
mkdir -p new_cleaned_dra

for f in 2022-map-dra/*.csv; do
  out="./old_cleaned_dra/$(basename "$f")"
  awk -F',' '
    NR==1 { print; next }
    {
      id = $1
      gsub(/^ *"|" *$/, "", id)
      if (id != "" && id != "Un") print
    }
  ' "$f" > "$out"
done

for f in 2026-map-dra/*.csv; do
  out="./new_cleaned_dra/$(basename "$f")"
  awk -F',' '
    NR==1 { print; next }
    {
      id = $1
      gsub(/^ *"|" *$/, "", id)
      if (id != "" && id != "Un") print
    }
  ' "$f" > "$out"
done


R
# Folder with your CSVs
folder <- '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/OH/data/elections'
subfolder <- c('old_cleaned_dra','new_cleaned_dra')

for (i in seq_along(subfolder)) {
  files  <- list.files(file.path(folder, subfolder[i]), pattern = "\\.csv$", full.names = TRUE)

  # Read a CSV *reliably*: remove BOM, strip trailing commas, and provide explicit headers
  safe_read <- function(path) {
    lines <- readLines(path, warn = FALSE)

    # 1) strip UTF-8 BOM if present
    if (length(lines) && grepl("^\ufeff", lines[1])) {
      lines[1] <- sub("^\ufeff", "", lines[1])
    }

    # 2) strip trailing commas on every line (incl. header-safe)
    lines <- sub(",\\s*$", "", lines)

    # 3) parse header explicitly, then read the rest with header = FALSE
    hdr <- strsplit(lines[1], ",", fixed = TRUE)[[1]]
    hdr <- trimws(hdr)

    # Recompose cleaned CSV text
    body <- paste(lines[-1], collapse = "\n")
    txt  <- paste(paste(hdr, collapse = ","), body, sep = "\n")

    # 4) read with explicit col.names to prevent row name shenanigans
    read.csv(text = txt,
             header = TRUE,            # header now matches exactly
             stringsAsFactors = FALSE,
             quote = "\"",
             comment.char = "",
             check.names = TRUE,       # "Total Pop" -> "Total.Pop" (safe)
             row.names = NULL)
  }

  # Build a named list of Dem vectors from all files
  elect_list <- setNames(lapply(files, function(f) {
    dat <- safe_read(f)}), basename(files))


  # Compute two-party share (Dem / (Dem + Rep)) for each dataset
  twoparty_wide <- Reduce(function(x, y) merge(x, y, by = "ID", all = TRUE),
                          lapply(names(elect_list), function(nm) {
                            df <- elect_list[[nm]]
                            
                            # Compute two-party vote share safely
                            df$TwoParty <- with(df, ifelse((Dem + Rep) > 0, Dem / (Dem + Rep), NA))
                            
                            # Keep ID + computed share
                            out <- df[, c("ID", "TwoParty")]
                            names(out)[2] <- nm  # rename to filename
                            out
                          }))

  # Optionally simplify column names
  names(twoparty_wide)[-1] <- sub("\\.csv$", "", names(twoparty_wide)[-1])

  # Reorder columns alphabetically (excluding ID)
  twoparty_wide <- twoparty_wide[, c("ID", sort(names(twoparty_wide)[-1]))]

  # Inspect the wide two-party data frame
  head(twoparty_wide)


  filename <- if (i == 1) "map_old.csv" else "map_new.csv"

  write.csv(
    twoparty_wide,
    file.path(folder, filename),
    row.names = FALSE
  )
}

map_old <- read.csv(file.path(folder, 'map_old.csv'))
map_new <- read.csv(file.path(folder, 'map_new.csv'))

colSums(1 * (map_old[,-1] > 0.5))
colSums(1 * (map_new[,-1] > 0.5))

cat(
  "OLD MAP:\n",
  "GOP Seats:", dim(map_old)[1] - mean(colSums(1 * (map_old[,-1] > 0.5))),
  "\nDEM Seats:", mean(colSums(1 * (map_old[,-1] > 0.5))), "\n"
)

cat(
  "NEW MAP:\n",
  "GOP Seats:", dim(map_new)[1] - mean(colSums(1 * (map_new[,-1] > 0.5))),
  "\nDEM Seats:", mean(colSums(1 * (map_new[,-1] > 0.5))), "\n"
)

old_seats <- dim(map_old)[1] - mean(colSums(map_old[,-1] > 0.5))
new_seats <- dim(map_new)[1] - mean(colSums(map_new[,-1] > 0.5))

net <- new_seats - old_seats

cat(
  "NET SEAT CHANGE:\n",
  ifelse(net > 0,
         paste0("GOP +", round(net, 2)),
         paste0("DEM +", round(abs(net), 2)))
)




# assume map_old and map_new are already loaded

  # exclude the ID column for comparison
  cols <- setdiff(names(map_old), "ID")

  # create logical comparison matrix
  compare_mat <- (map_old[, cols] < 0.5) & (map_new[, cols] > 0.5)

# replace TRUE/FALSE with color codes
comparison_df <- as.data.frame(ifelse(compare_mat, "#1375B7", "#EEEEEE"))
comparison_df_stroke <- as.data.frame(ifelse(compare_mat, "#000000", "none"))

# reattach the ID column
comparison_df <- cbind(ID = map_old$ID, comparison_df)
comparison_df_stroke <- cbind(ID = map_old$ID, comparison_df_stroke)

# remove dots from column names
names(comparison_df) <- gsub("\\.", "", names(comparison_df))
names(comparison_df_stroke) <- gsub("\\.", "", names(comparison_df_stroke))
names(comparison_df_stroke)[-1] <- paste0(names(comparison_df_stroke)[-1], "stroke")

# view result
comparison_df

write.csv(comparison_df, file.path(folder,'district_changes.csv'), row.names=F)
write.csv(comparison_df_stroke, file.path(folder,'district_changes_stroke.csv'), row.names=F)





# Create a comparison data frame
res <- data.frame(
  Election = names(colSums(1 * (map_old[,-1] < .5))),
  OldPlan = colSums(1 * (map_old[,-1] < .5)),
  NewPlan = colSums(1 * (map_new[,-1] < .5))
)

res$NewPlan - res$OldPlan

res$Change <- res$NewPlan - res$OldPlan

# clean labels: "president.2016" -> "Pres 16"
office <- sub("\\..*", "", res$Election)
year   <- substr(sub(".*\\.", "", res$Election), 3, 4)

short <- paste0(substr(office, 1, 4), " ", year)

# order by year
ord <- order(as.numeric(sub(".*\\.", "", res$Election)), decreasing = TRUE)

barplot(res$Change[ord],
        names.arg = short[ord],
        horiz = TRUE,
        col = ifelse(res$Change[ord] < 0, "blue", "red"),
        xlab = "Change in Majority Party Districts",
        las = 1)
abline(v = 0, lty = 2)


source('https://raw.githubusercontent.com/jcervas/R-Functions/refs/heads/main/sv-hyp.R')

# Fit seat–vote relationship to empirical statewide data
sv_plot_base(theme="dark")
points(x=colMeans(map_old)[-1], y=colMeans(1 * (map_old>.5))[-1], col="#C41230")
points(x=colMeans(map_new)[-1], y=colMeans(1 * (map_new>.5))[-1], col="white")
sv_curve(v=colMeans(map_old)[-1], s=colMeans(1 * (map_old>.5))[-1], col="#C41230")
sv_curve(v=colMeans(map_new)[-1], s=colMeans(1 * (map_new>.5))[-1], col="white")




sv_plot(
  sv_curve(v=colMeans(map_new)[-1], s=colMeans(1 * (map_new>.5))[-1], col="black")
  )
