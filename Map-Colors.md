# Map Colors

**Democrat Win**    
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #CEEAFD   | <img src="colors/CEEAFD.svg" width="15" height="15"> |
| #92BDE0   | <img src="colors/92BDE0.svg" width="15" height="15"> |
| #5295CC   | <img src="colors/5295CC.svg" width="15" height="15"> |
| #1375B7   | <img src="colors/1375B7.svg" width="15" height="15"> |

**Republican Win**  
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #FCE0E0   | <img src="colors/FCE0E0.svg" width="15" height="15"> |
| #EAA9A9   | <img src="colors/EAA9A9.svg" width="15" height="15"> |
| #DB7171   | <img src="colors/DB7171.svg" width="15" height="15"> |
| #C93135   | <img src="colors/C93135.svg" width="15" height="15"> |

### Example in mapshaper.org
```-classify field=dem save-as=fill breaks=.2,.35,.5,.65,.8 colors '#C93135,#DB7171,#EAA9A9,#CEEAFD,#5295CC,#08306B' null-value="#fff" key-name="legend-partisanship" key-style="simple" key-tile-height=10 key-width=200 key-font-size=10 key-last-suffix="%"```

## R Colors for Parties
```{r}
dodgerblue.30 <- rgb(30, 144, 255, 76.5, max =255)  
indianred.30 <- rgb(205, 92, 92, 76.5, max =255)  
indianred.75 <- rgb(205, 92, 92, 191, max =255)
```


-colorizer name=fillDEMColor breaks='60,70,80' colors='#CEEAFD,#92BDE0,#5295CC,#1375B7'
-svg-style target=DEM fill='fillDEMColor(winning_pct_display)' \

-colorizer name=fillGOPColor breaks='60,70,80' colors='#FCE0E0,#EAA9A9,#DB7171,#C93135'
-svg-style target=GOP fill='fillGOPColor(winning_pct_display)' \


## CNN Colors

| Party / Category         | Win Color                                                                                                                               | Flip Color                                                         | Lead Gradient (0–5%, 5–10%, 10%+)                                                                                                                                                                          |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Democratic (DEM)**     | ![#008AEF](https://readme-swatches.vercel.app/008AEF) `#008AEF`                                                                      | ![#66B9F5](https://via.placeholder.com/10/66B9F5?text=+) `#66B9F5` | ![#A6D6F9](https://via.placeholder.com/10/A6D6F9?text=+) `#A6D6F9`, ![#73BFF6](https://via.placeholder.com/10/73BFF6?text=+) `#73BFF6`, ![#40A7F3](https://via.placeholder.com/10/40A7F3?text=+) `#40A7F3` |
| **Republican (REP)**     | ![#CC0000](https://via.placeholder.com/10/CC0000?text=+) `#CC0000`                                                                      | ![#CD5D5D](https://via.placeholder.com/10/CD5D5D?text=+) `#CD5D5D` | ![#ED9A9A](https://via.placeholder.com/10/ED9A9A?text=+) `#ED9A9A`, ![#E37373](https://via.placeholder.com/10/E37373?text=+) `#E37373`, ![#D94040](https://via.placeholder.com/10/D94040?text=+) `#D94040` |
| **Green (GRN)**          | ![#6BBD11](https://via.placeholder.com/10/6BBD11?text=+) `#6BBD11`                                                                      | ![#A6D770](https://via.placeholder.com/10/A6D770?text=+) `#A6D770` | ![#CBE8AC](https://via.placeholder.com/10/CBE8AC?text=+) `#CBE8AC`, ![#AEDB7C](https://via.placeholder.com/10/AEDB7C?text=+) `#AEDB7C`, ![#90CD4D](https://via.placeholder.com/10/90CD4D?text=+) `#90CD4D` |
| **Libertarian (LIB)**    | ![#FF8E02](https://via.placeholder.com/10/FF8E02?text=+) `#FF8E02`                                                                      | ![#FFBB67](https://via.placeholder.com/10/FFBB67?text=+) `#FFBB67` | ![#FFD7A6](https://via.placeholder.com/10/FFD7A6?text=+) `#FFD7A6`, ![#FFC174](https://via.placeholder.com/10/FFC174?text=+) `#FFC174`, ![#FFAA41](https://via.placeholder.com/10/FFAA41?text=+) `#FFAA41` |
| **Independent (IND)**    | ![#7A20A1](https://via.placeholder.com/10/7A20A1?text=+) `#7A20A1`                                                                      | ![#AF79C7](https://via.placeholder.com/10/AF79C7?text=+) `#AF79C7` | ![#D0B1DE](https://via.placeholder.com/10/D0B1DE?text=+) `#D0B1DE`, ![#B684CB](https://via.placeholder.com/10/B684CB?text=+) `#B684CB`, ![#9B58B9](https://via.placeholder.com/10/9B58B9?text=+) `#9B58B9` |
| **Traditional (TRD)**    | ![#7A20A1](https://via.placeholder.com/10/7A20A1?text=+) `#7A20A1`                                                                      | ![#AF79C7](https://via.placeholder.com/10/AF79C7?text=+) `#AF79C7` | ![#D0B1DE](https://via.placeholder.com/10/D0B1DE?text=+) `#D0B1DE`, ![#B684CB](https://via.placeholder.com/10/B684CB?text=+) `#B684CB`, ![#9B58B9](https://via.placeholder.com/10/9B58B9?text=+) `#9B58B9` |
| **Ballot – YES**         | ![#077A63](https://via.placeholder.com/10/077A63?text=+) `#077A63`                                                                      | —                                                                  | ![#DAEBE8](https://via.placeholder.com/10/DAEBE8?text=+) `#DAEBE8`, ![#B5D7D0](https://via.placeholder.com/10/B5D7D0?text=+) `#B5D7D0`, ![#83BCB1](https://via.placeholder.com/10/83BCB1?text=+) `#83BCB1` |
| **Ballot – NO**          | ![#522349](https://via.placeholder.com/10/522349?text=+) `#522349`                                                                      | —                                                                  | ![#E5DEE4](https://via.placeholder.com/10/E5DEE4?text=+) `#E5DEE4`, ![#CBBDC8](https://via.placeholder.com/10/CBBDC8?text=+) `#CBBDC8`, ![#A891A4](https://via.placeholder.com/10/A891A4?text=+) `#A891A4` |
| **Approve / Disapprove** | ![#077A63](https://via.placeholder.com/10/077A63?text=+) `#077A63` / ![#522349](https://via.placeholder.com/10/522349?text=+) `#522349` | —                                                                  | —                                                                                                                                                                                                          |
| **Not Yet Called**       | ![#D3D3D3](https://via.placeholder.com/10/D3D3D3?text=+) `#D3D3D3`                                                                      | —                                                                  | —                                                                                                                                                                                                          |
| **Undecided**            | ![#B1B1B1](https://via.placeholder.com/10/B1B1B1?text=+) `#B1B1B1`                                                                      | —                                                                  | —                                                                                                                                                                                                          |
