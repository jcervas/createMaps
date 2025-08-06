# Read fips data
fips <- read.csv('/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/Data/fips.csv', colClasses=c(fips="character"))

# Data for D/F states
    state <- c("FL", "GA", "IL", "KS", "LA", "NC", "NM", "NV", "OH", "OR", "SC", "TN", "TX", "UT", "WI")
    color <- "#EA655D"

fips$color <- ifelse(fips$abv %in% state, color, "none")  # Default color for other states

write.csv(fips, '/Users/cervas/Library/Mobile Documents/com~apple~CloudDocs/Downloads/gerrymanders.csv', row.names=FALSE)

