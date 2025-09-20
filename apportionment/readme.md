# Apportionment Maps

This repository contains a Mapshaper workflow to generate SVG maps of U.S. congressional apportionment changes, both for total population and for citizen voting-age population.

## Workflow

```shell
cd '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/apportionment'

mapshaper \
-i 'states.json' name=states \
-i 'apportionment-projections-sept-19-2025.csv' name=apportionment \
-dissolve target=states + name=US \
-style target=US fill=none stroke=#000 \
-filter target=states 'NAME != "District of Columbia"' \
-proj target=states albersusa \
-join target=states source=apportionment keys=NAME,State \
-filter target=states diff!=0 + name=total \
-filter target=states citizen_diff!=0 + name=citizen \
-classify target=total field=diff breaks=-4,-3,-2,-1,0,1,2,3,4 \
  colors="#850C20,#C41230,#FF086C,#FF7015,#FDB515,#E0E0E0,#00EB8B,#688758,#3A6BB5,#182C4B" \
-each target=total 'cx=this.innerX, cy=this.innerY' \
-points target=total x=cx y=cy + name=total_labels \
-style target=total_labels label-text='NAME + "\n" + diff' \
  text-anchor=middle fill=#000 stroke=none opacity=1 \
  font-size=14px font-weight=600 line-height=20px font-family=arial \
-classify target=citizen field=citizen_diff breaks=-4,-3,-2,-1,0,1,2,3,4 \
  colors="#850C20,#C41230,#FF086C,#FF7015,#FDB515,#E0E0E0,#00EB8B,#688758,#3A6BB5,#182C4B" \
  key-name="legend" key-style="dataviz" key-tile-height=10 key-width=320 \
  key-font-size=10 key-last-suffix='+' \
-each target=citizen 'cx=this.innerX, cy=this.innerY' \
-points target=citizen x=cx y=cy + name=citizen_labels \
-style target=citizen_labels label-text='NAME + "\n" + citizen_diff' \
  text-anchor=middle fill=#000 stroke=none opacity=1 \
  font-size=14px font-weight=600 line-height=20px font-family=arial \
-style target=citizen,total stroke=#ddd \
-style target=states stroke=#ddd fill=#fff \
-o target=states,total,US,total_labels 'total.svg' \
-o target=states,citizen,US,citizen_labels 'citizens.svg'
```

## Description

- **Input data**  
  - `cb_2024_us_state_500k.shp` → Census TIGER/Line 2024 state boundaries (500k scale)  
  - `apportionment-projections-sept-19-2025.csv` → projected seat changes by state  

- **Processing**  
  - Creates a U.S. outline for context  
  - Removes Washington, D.C.  
  - Reprojects to Albers USA  
  - Joins projection data to states  
  - Filters into two layers:  
    - `total` → apportionment changes from total population  
    - `citizen` → apportionment changes from citizen voting-age population  
  - Classifies states into bins with a custom color scheme  
  - Generates centroid-based labels for both maps  
  - Styles labels and boundaries for clarity  

- **Outputs**  
  - `total.svg` → apportionment changes by total population  
  - `citizens.svg` → apportionment changes by citizen population (includes legend)  

## Color Palette

| Break | Hex | Description |
|-------|------|-------------|
| ≤ -4  | `#850C20` | Dark, deep red |
| -3    | `#C41230` | Strong vivid red |
| -2    | `#FF086C` | Bright pink |
| -1    | `#FF7015` | Vivid orange |
| 0     | `#FDB515` | Yellow-orange |
| No change | `#E0E0E0` | Light gray |
| +1    | `#00EB8B` | Bright spring green |
| +2    | `#688758` | Olive green |
| +3    | `#3A6BB5` | Medium blue |
| ≥ +4  | `#182C4B` | Dark navy blue |

![Legend](legend.svg)

## Maps

### Total Population
![Total Apportionment](total.svg)

### Citizen Voting-Age Population
![Citizen Apportionment](citizens.svg)
