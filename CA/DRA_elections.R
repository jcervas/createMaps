# Folder with your CSVs
folder <- '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/CA/CA-2026/cleaned_csvs'
files  <- list.files(folder, pattern = "\\.csv$", full.names = TRUE)

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


write.csv(twoparty_wide, '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/CA/CA-2026.csv', row.names = FALSE)

ca2022 <- read.csv('/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/CA/CA-2022.csv')
ca2026 <- read.csv('/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/CA/CA-2026.csv')


# assume ca2022 and ca2026 are already loaded

# exclude the ID column for comparison
cols <- setdiff(names(ca2022), "ID")

# create logical comparison matrix
compare_mat <- (ca2022[, cols] < 0.5) & (ca2026[, cols] > 0.5)

# replace TRUE/FALSE with color codes
comparison_df <- as.data.frame(ifelse(compare_mat, "#CEEAFD", "#EEEEEE"))

# reattach the ID column
comparison_df <- cbind(ID = ca2022$ID, comparison_df)

# remove dots from column names
names(comparison_df) <- gsub("\\.", "", names(comparison_df))

# view result
comparison_df


write.csv(comparison_df, '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/CA/data/district_changes.csv', row.names=F)


