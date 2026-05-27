# Map Colors

## Carnegie Mellon University Colors

### Core Colors

| Color | Hex Code | Color Swatch |
|-------|-----------|----------------|
| Carnegie Red | #C41230 | <img src="https://readme-swatches.vercel.app/C41230"> |
| Black | #000000 | <img src="https://readme-swatches.vercel.app/000000"> |
| Iron Gray | #6D6E71 | <img src="https://readme-swatches.vercel.app/6D6E71"> |
| Steel Gray | #E0E0E0 | <img src="https://readme-swatches.vercel.app/E0E0E0"> |
| White | #FFFFFF | <img src="https://readme-swatches.vercel.app/FFFFFF"> |

### Tartan Palette

| Color | Hex Code | Color Swatch |
|-------|-----------|----------------|
| Scots Rose | #EF3A47 | <img src="https://readme-swatches.vercel.app/EF3A47"> |
| Gold Thread | #FDB515 | <img src="https://readme-swatches.vercel.app/FDB515"> |
| Green Thread | #009647 | <img src="https://readme-swatches.vercel.app/009647"> |
| Teal Thread | #008F91 | <img src="https://readme-swatches.vercel.app/008F91"> |
| Blue Thread | #043673 | <img src="https://readme-swatches.vercel.app/043673"> |
| Highlands Sky Blue | #007BC0 | <img src="https://readme-swatches.vercel.app/007BC0"> |

### Campus Palette

| Color | Hex Code | Color Swatch |
|-------|-----------|----------------|
| Machinery Hall Tan | #BCB49E | <img src="https://readme-swatches.vercel.app/BCB49E"> |
| Kittanning Brick Beige | #E4DAC4 | <img src="https://readme-swatches.vercel.app/E4DAC4"> |
| Hornbostel Teal | #1F4C4C | <img src="https://readme-swatches.vercel.app/1F4C4C"> |
| Palladian Green | #719F94 | <img src="https://readme-swatches.vercel.app/719F94"> |
| Weaver Blue | #182C4B | <img src="https://readme-swatches.vercel.app/182C4B"> |
| Skibo Red | #941120 | <img src="https://readme-swatches.vercel.app/941120"> |

### Example CMU Mapshaper Palette

```bash
-colorizer name=fillCMU breaks='20,40,60,80' \
colors='#E0E0E0,#BCB49E,#C41230,#941120,#182C4B'

-style fill='fillCMU(score)' stroke='#FFFFFF' stroke-width=0.5


**Democrat Win**    
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #CEEAFD   | <img src="https://readme-swatches.vercel.app/CEEAFD"> |
| #92BDE0   | <img src="https://readme-swatches.vercel.app/92BDE0"> |
| #5295CC   | <img src="https://readme-swatches.vercel.app/5295CC"> |
| #1375B7   | <img src="https://readme-swatches.vercel.app/1375B7"> |

**Republican Win**  
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #FCE0E0   | <img src="https://readme-swatches.vercel.app/FCE0E0"> |
| #EAA9A9   | <img src="https://readme-swatches.vercel.app/EAA9A9"> |
| #DB7171   | <img src="https://readme-swatches.vercel.app/DB7171"> |
| #C93135   | <img src="https://readme-swatches.vercel.app/C93135"> |

### Example in mapshaper.org
```-classify field=dem save-as=fill breaks=.2,.35,.5,.65,.8 colors '#C93135,#DB7171,#EAA9A9,#CEEAFD,#5295CC,#08306B' null-value="#fff" key-name="legend-partisanship" key-style="simple" key-tile-height=10 key-width=200 key-font-size=10 key-last-suffix="%"```

## R Colors for Parties
```{r}
dodgerblue.30 <- rgb(30, 144, 255, 76.5, max =255)  
indianred.30 <- rgb(205, 92, 92, 76.5, max =255)  
indianred.75 <- rgb(205, 92, 92, 191, max =255)
```


-colorizer name=fillDEMColor breaks='55,60,65' colors='#CEEAFD,#92BDE0,#5295CC,#1375B7'
-style target=DEM fill='fillDEMColor(winning_pct_display)' \

-colorizer name=fillGOPColor breaks='55,60,65' colors='#FCE0E0,#EAA9A9,#DB7171,#C93135'
-style target=GOP fill='fillGOPColor(winning_pct_display)' \

<div align="left">

**CNN Colors**

### Democratic (DEM)

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/A6D6F9/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/73BFF6/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/40A7F3/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/66B9F5/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/008AEF/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="center"><sub>Flip</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Republican (REP)

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/ED9A9A/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/E37373/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/D94040/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/CD5D5D/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/CC0000/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="center"><sub>Flip</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Green (GRN)

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/CBE8AC/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/AEDB7C/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/90CD4D/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/A6D770/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/6BBD11/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="center"><sub>Flip</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Libertarian (LIB)

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/FFD7A6/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/FFC174/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/FFAA41/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/FFBB67/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/FF8E02/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="center"><sub>Flip</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Independent / Traditional (IND / TRD)

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/D0B1DE/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/B684CB/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/9B58B9/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/AF79C7/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/7A20A1/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="center"><sub>Flip</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Ballot – YES

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/DAEBE8/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/B5D7D0/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/83BCB1/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/077A63/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Ballot – NO

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/E5DEE4/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/CBBDC8/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/A891A4/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/522349/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>0–5%</sub></td>
<td align="center"><sub>5–10%</sub></td>
<td align="center"><sub>10%+</sub></td>
<td align="right"><sub>Win</sub></td>
</tr>
</table>

### Miscellaneous

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/077A63/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/522349/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/D3D3D3/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/B1B1B1/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>Approve</sub></td>
<td align="center"><sub>Disapprove</sub></td>
<td align="center"><sub>Not Called</sub></td>
<td align="right"><sub>Undecided</sub></td>
</tr>
</table>

</div>                                                          |




## New York Times Maps

[Why Neutral Maps Could Empower Black Voters as Much as the Voting Rights Act](https://www.nytimes.com/2026/05/17/upshot/redistricting-race-court-gerrymanders-elections.html)

```
-colorizer name=BlackPer breaks='40,45,50,55' colors='#fcf3e5,#ffeab0,#ffd391,#b89ab9,#866f87' 
-style fill='BlackPer(blackper)' \

-each 'fill =  blackper < 40 ? "#fcf3e5" : blackper < 45 ? "#ffeab0" : blackper < 50 ? "#ffd391" : blackper < 55 ? "#b89ab9" : "#866f87"'

-style fill=fill opacity=1 stroke=#fff stroke-width=1
```


<div align="left">

**Black voting-age population**

<table>
<tr>
<td><img src="https://singlecolorimage.com/get/fcf3e5/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/ffeab0/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/ffd391/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/b89ab9/40x14" /></td>
<td><img src="https://singlecolorimage.com/get/866f87/40x14" /></td>
</tr>
<tr>
<td align="left"><sub>40%</sub></td>
<td align="center"><sub>45%</sub></td>
<td align="center"><sub>50%</sub></td>
<td align="center"><sub>55%</sub></td>
<td align="right"><sub>60%</sub></td>
</tr>
</table>

</div>
