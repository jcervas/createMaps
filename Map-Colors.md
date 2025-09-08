# Map Colors

<style>
  .box {
  float: left;
  height: 20px;
  width: 20px;
  margin-bottom: 15px;
  border: 1px solid black;
  clear: both;
}

.CEEAFD {
  background-color: #CEEAFD;
}

.green {
  background-color: green;
}

.blue {
  background-color: blue;
}
</style>

Democrat Win
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #CEEAFD   |<div class="box CEEAFD"></div> |
| #92BDE0   |![Color Swatch](https://place-hold.it/20/92BDE0/92BDE0) |
| #5295CC   |![Color Swatch](https://place-hold.it/20/5295CC/5295CC) |
| #1375B7   |![Color Swatch](https://place-hold.it/20/1375B7/1375B7) |

Republican Win
| Hex Code  | Color Swatch   |
|-----------|----------------|
| #FCE0E0   | ![#FCE0E0](https://place-hold.it/20/FCDDDD/FCDDDD) |
| #EAA9A9   | ![#EAA9A9](https://place-hold.it/20/EAA9A9/EAA9A9) |
| #DB7171   | ![#DB7171](https://place-hold.it/20/DB7171/DB7171) |
| #C93135   | ![#C93135](https://place-hold.it/20/C93135/C93135) |

### Example in mapshaper.org
```-classify target=nassau-blocks field=DemVoteShare save-as=fill nice colors='#C93135,#FCE0E0,#CEEAFD,#1375B7' breaks=30,40,50,60,70 null-value="#fff" key-name="legend-partisanship" key-style="simple" key-tile-height=10 key-width=200 key-font-size=10 key-last-suffix="%"```
