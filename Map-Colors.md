# Map Colors
<svg fill="none" viewBox="0 0 600 300" width="600" height="300" xmlns="http://www.w3.org/2000/svg">
  <foreignObject width="100%" height="100%">
    <div xmlns="http://www.w3.org/1999/xhtml">
      <style>
        @keyframes hi  {
            0% { transform: rotate( 0.0deg) }
           10% { transform: rotate(14.0deg) }
           20% { transform: rotate(-8.0deg) }
           30% { transform: rotate(14.0deg) }
           40% { transform: rotate(-4.0deg) }
           50% { transform: rotate(10.0deg) }
           60% { transform: rotate( 0.0deg) }
          100% { transform: rotate( 0.0deg) }
        }

        @keyframes gradient {
          0% {
            background-position: 0% 50%;
          }
          50% {
            background-position: 100% 50%;
          }
          100% {
            background-position: 0% 50%;
          }
        }

        .container {
          background: linear-gradient(-45deg, #ee7752, #e73c7e, #23a6d5, #23d5ab);
          background-size: 400% 400%;
          animation: gradient 15s ease infinite;

          width: 100%;
          height: 300px;

          display: flex;
          justify-content: center;
          align-items: center;
          color: white;

          font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol";
        }

        .hi {
          animation: hi 1.5s linear -0.5s infinite;
          display: inline-block;
          transform-origin: 70% 70%;
        }

        @media (prefers-reduced-motion) {
          .container {
            animation: none;
          }

          .hi {
            animation: none;
          }
        }
      </style>

      <div class="container">
        <h1>Hi there, my name is Nikola <div class="hi">👋</div></h1>
      </div>
    </div>
  </foreignObject>
</svg>
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
