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

dodgerblue.30 <- rgb(30, 144, 255, 76.5, max =255)
indianred.30 <- rgb(205, 92, 92, 76.5, max =255)
indianred.75 <- rgb(205, 92, 92, 191, max =255)