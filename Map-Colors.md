# Map Colors

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
-svg-style target=DEM fill='fillDEMColor(winning_pct_display)' \

-colorizer name=fillGOPColor breaks='55,60,65' colors='#FCE0E0,#EAA9A9,#DB7171,#C93135'
-svg-style target=GOP fill='fillGOPColor(winning_pct_display)' \


## CNN Colors

| Party / Category         | Win Color                                                                                                                         | Flip Color                                                      | Lead Gradient (0–5%, 5–10%, 10%+)                                                                                                                                                                 |
| ------------------------ | --------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Democratic (DEM)**     | ![#008AEF](https://readme-swatches.vercel.app/008AEF) `#008AEF`                                                                   | ![#66B9F5](https://readme-swatches.vercel.app/66B9F5) `#66B9F5` | ![#A6D6F9](https://readme-swatches.vercel.app/A6D6F9) `#A6D6F9`, ![#73BFF6](https://readme-swatches.vercel.app/73BFF6) `#73BFF6`, ![#40A7F3](https://readme-swatches.vercel.app/40A7F3) `#40A7F3` |
| **Republican (REP)**     | ![#CC0000](https://readme-swatches.vercel.app/CC0000) `#CC0000`                                                                   | ![#CD5D5D](https://readme-swatches.vercel.app/CD5D5D) `#CD5D5D` | ![#ED9A9A](https://readme-swatches.vercel.app/ED9A9A) `#ED9A9A`, ![#E37373](https://readme-swatches.vercel.app/E37373) `#E37373`, ![#D94040](https://readme-swatches.vercel.app/D94040) `#D94040` |
| **Green (GRN)**          | ![#6BBD11](https://readme-swatches.vercel.app/6BBD11) `#6BBD11`                                                                   | ![#A6D770](https://readme-swatches.vercel.app/A6D770) `#A6D770` | ![#CBE8AC](https://readme-swatches.vercel.app/CBE8AC) `#CBE8AC`, ![#AEDB7C](https://readme-swatches.vercel.app/AEDB7C) `#AEDB7C`, ![#90CD4D](https://readme-swatches.vercel.app/90CD4D) `#90CD4D` |
| **Libertarian (LIB)**    | ![#FF8E02](https://readme-swatches.vercel.app/FF8E02) `#FF8E02`                                                                   | ![#FFBB67](https://readme-swatches.vercel.app/FFBB67) `#FFBB67` | ![#FFD7A6](https://readme-swatches.vercel.app/FFD7A6) `#FFD7A6`, ![#FFC174](https://readme-swatches.vercel.app/FFC174) `#FFC174`, ![#FFAA41](https://readme-swatches.vercel.app/FFAA41) `#FFAA41` |
| **Independent (IND)**    | ![#7A20A1](https://readme-swatches.vercel.app/7A20A1) `#7A20A1`                                                                   | ![#AF79C7](https://readme-swatches.vercel.app/AF79C7) `#AF79C7` | ![#D0B1DE](https://readme-swatches.vercel.app/D0B1DE) `#D0B1DE`, ![#B684CB](https://readme-swatches.vercel.app/B684CB) `#B684CB`, ![#9B58B9](https://readme-swatches.vercel.app/9B58B9) `#9B58B9` |
| **Traditional (TRD)**    | ![#7A20A1](https://readme-swatches.vercel.app/7A20A1) `#7A20A1`                                                                   | ![#AF79C7](https://readme-swatches.vercel.app/AF79C7) `#AF79C7` | ![#D0B1DE](https://readme-swatches.vercel.app/D0B1DE) `#D0B1DE`, ![#B684CB](https://readme-swatches.vercel.app/B684CB) `#B684CB`, ![#9B58B9](https://readme-swatches.vercel.app/9B58B9) `#9B58B9` |
| **Ballot – YES**         | ![#077A63](https://readme-swatches.vercel.app/077A63) `#077A63`                                                                   | —                                                               | ![#DAEBE8](https://readme-swatches.vercel.app/DAEBE8) `#DAEBE8`, ![#B5D7D0](https://readme-swatches.vercel.app/B5D7D0) `#B5D7D0`, ![#83BCB1](https://readme-swatches.vercel.app/83BCB1) `#83BCB1` |
| **Ballot – NO**          | ![#522349](https://readme-swatches.vercel.app/522349) `#522349`                                                                   | —                                                               | ![#E5DEE4](https://readme-swatches.vercel.app/E5DEE4) `#E5DEE4`, ![#CBBDC8](https://readme-swatches.vercel.app/CBBDC8) `#CBBDC8`, ![#A891A4](https://readme-swatches.vercel.app/A891A4) `#A891A4` |
| **Approve / Disapprove** | ![#077A63](https://readme-swatches.vercel.app/077A63) `#077A63` / ![#522349](https://readme-swatches.vercel.app/522349) `#522349` | —                                                               | —                                                                                                                                                                                                 |
| **Not Yet Called**       | ![#D3D3D3](https://readme-swatches.vercel.app/D3D3D3) `#D3D3D3`                                                                   | —                                                               | —                                                                                                                                                                                                 |
| **Undecided**            | ![#B1B1B1](https://readme-swatches.vercel.app/B1B1B1) `#B1B1B1`                                                                   | —                                                               | —                                                                                                                                                                                                 |




<div align="left">

**Black voting-age population**

<table cellspacing="0" cellpadding="0" border="0">
<tr>
<td bgcolor="#fcf3e5" width="40" height="14">![#008AEF](https://readme-swatches.vercel.app/008AEF) `#008AEF`</td>
<td bgcolor="#ffeab0" width="40" height="14"></td>
<td bgcolor="#ffd391" width="40" height="14"></td>
<td bgcolor="#b89ab9" width="40" height="14"></td>
<td bgcolor="#866f87" width="40" height="14"></td>
</tr>
<tr>
<td align="left"><sub>35%</sub></td>
<td align="center"><sub>45%</sub></td>
<td align="center"><sub>50%</sub></td>
<td align="center"><sub>55%</sub></td>
<td align="right"><sub>60%</sub></td>
</tr>
</table>

</div>
