# ------------------------------------------------------------------------------
# gerrymander_map.r
#
# This script creates a data frame containing US states and territories with their
# corresponding FIPS codes and abbreviations. It then marks a subset of states
# (D/F states) with a specific color code and exports the resulting data frame
# as a CSV file.
#
# Main Steps:
# 1. Define a data frame `fips` with columns: state name, abbreviation, and FIPS code.
# 2. Specify a vector of state abbreviations (`state`) representing D/F states.
# 3. Assign a color ("#EA655D") to D/F states and "none" to all others in a new column.
# 4. Export the annotated data frame to a CSV file.
#
# Output:
# - CSV file containing state names, abbreviations, FIPS codes, and color annotation.
#
# Author: [Your Name]
# Date: [Date]
# ------------------------------------------------------------------------------
# Read fips data

fips <- data.frame(
    state = c("Alabama", "Alaska", "Arizona", "Arkansas", "California", "Colorado", "Connecticut", "Delaware", "Florida", "Georgia", "Hawaii", "Idaho", "Illinois", "Indiana", "Iowa", "Kansas", "Kentucky", "Louisiana", "Maine", "Maryland", "Massachusetts", "Michigan", "Minnesota", "Mississippi", "Missouri", "Montana", "Nebraska", "Nevada", "New Hampshire", "New Jersey", "New Mexico", "New York", "North Carolina", "North Dakota", "Ohio", "Oklahoma", "Oregon", "Pennsylvania", "Rhode Island", "South Carolina", "South Dakota", "Tennessee", "Texas", "Utah", "Vermont", "Virginia", "Washington", "West Virginia", "Wisconsin", "Wyoming", "American Samoa", "Guam", "Northern Mariana Islands", "Puerto Rico", "Virgin Islands"),
    abv = c("AL", "AK", "AZ", "AR", "CA", "CO", "CT", "DE", "FL", "GA", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "OH", "OK", "OR", "PA", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VA", "WA", "WV", "WI", "WY", "AS", "GU", "MP", "PR", "VI"),
    fips = c("01", "02", "04", "05", "06", "08", "09", "10", "12", "13", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "44", "45", "46", "47", "48", "49", "50", "51", "53", "54", "55", "56", "60", "66", "69", "72", "78"),
    stringsAsFactors = FALSE
)

# Data for D/F states
    state <- c("FL", "GA", "IL", "KS", "LA", "NC", "NM", "NV", "OH", "OR", "SC", "TN", "TX", "UT", "WI")
    color <- "#EA655D"

fips$color <- ifelse(fips$abv %in% state, color, "#fff")  # Default color for other states

write.csv(fips, 'gerrymanders.csv', row.names=FALSE)

