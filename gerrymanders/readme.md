<!--
# Documentation for Gerrymander Map Generation Workflow

This script provides a step-by-step workflow for generating SVG maps that visualize the worst gerrymandered states for 2025 using Mapshaper. The process involves:

1. **Setting the Working Directory**: Ensures all file paths are relative to the project folder.
2. **Loading Data**: Imports county boundaries (`counties-albers-med.json`) and gerrymander data (`gerrymanders.csv`).
3. **Joining Data**: Merges state geometries with gerrymander data using state abbreviations as keys.
4. **Styling Layers**: Applies visual styles to state lines and fills for clear map distinction.
5. **Exporting Output**: Outputs the final styled map as an SVG file for visualization.

The resulting SVG (`images/gerrymanders.svg`) can be embedded in documentation or reports to illustrate the identified gerrymandered states.

-->
# Create Worst Gerrymanders (2025) for PGP

Change to the project directory:
```sh
cd '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/gerrymanders'
```

Run R Script to create data with gerrymandered states
```r
Rscript source("https://raw.githubusercontent.com/jcervas/createMaps/refs/heads/main/gerrymanders/gerrymander_map.r", encoding = "UTF-8")
```

Run Mapshaper to generate the map:

## Load county boundaries and gerrymander data

- Load county boundaries
- Load CSV with gerrymander data (sourced from gerrymander.princeton.edu)
- Join gerrymander data to state geometries # Match on state abbreviation
```sh
mapshaper \
    -i 'counties-albers-med.json' \
    -i 'gerrymanders.csv' \
    -join target=states source=gerrymanders.csv keys='ST,abv' \
```

## Style the map layers # Style state lines # Style state fills 
```sh
-style target=statelines fill=none stroke='#b0c4b1' stroke-width=1 stroke-dasharray="0 3 0" \
-style target=states fill=color stroke='#b0c4b1' stroke-width=1 \
```

## Export the styled map as an SVG file
```sh
-o target=statelines,states 'images/gerrymanders.svg'
```

## 2025 Worst Gerrymandered States

![](images/gerrymanders.svg)    
**Sources:** Map adapted from The New York Times; data from Princeton Gerrymandering Project Report Cards.
