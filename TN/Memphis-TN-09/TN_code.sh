TN Code § 2-16-102 (2024): https://law.justia.com/codes/tennessee/title-2/chapter-16/section-2-16-102/


df <- read.csv('/Users/cervas/Downloads/TN-redist-ALARM/TN_cd_2020_stats.csv')

result <- df[ave(df$pop_black, df$draw, FUN = max) == df$pop_black, ]
result$per_black <- result$pop_black/result$total_pop

summary(result$per_black)
sum(1 * result$per_black > 0.5)


result <- df[ave(df$vap_black, df$draw, FUN = max) == df$vap_black, ]
result$per_bvap <- result$vap_black/result$total_vap

summary(result$per_bvap)
sum(1 * result$per_bvap > 0.5)

table(result$pr_dem)


hist(result$per_black,
     main = "", 
     xlab = "Percent Black", 
     col = "lightblue", 
     border = "white",
     yaxt = "n",
     xaxt = "n")

# Add a rug plot to indicate individual data points (optional)
rug(result$per_black, col = "black")

# Add the custom y-axis
axis(side = 1, las = 1, at = seq(0.4,0.6,0.05), labels = c("40","45", "50", "55", "60%"), cex.axis = 0.65)
axis(side = 2, las = 2, at = seq(0,2500,500), labels = c("0","500", "1,000", "1,500", "2,000", "2,500"), cex.axis = 0.65)

df$pres20_dem <- df$pre_20_dem_bid/(df$pre_20_dem_bid+df$pre_20_rep_tru)
result_partisan <- df[ave(df$pres20_dem, df$draw, FUN = max) == df$pres20_dem, ]




INPUT_DIR='/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/Memphis-TN-09/GIS'
ROOT_DIR="$(dirname "$INPUT_DIR")"
OUTPUT_DIR="$ROOT_DIR/svg"
LOG_FILE="$OUTPUT_DIR/mapshaper_errors.log"

mkdir -p "$OUTPUT_DIR"

for f in "$INPUT_DIR"/*.geojson; do

  filebase="${f##*/}"
  base="${filebase%.geojson}"

  mapshaper \
    -i "$f" name=states \
    -proj merc densify \
    -filter 'id == "9"' + name=Memphis \
    -frame bbox='-10053315,4138086,-9599584,4368830' width=400 offset=4% name=rectangle \
    -target states \
    -clip rectangle \
    -each 'labelled = this.area > 0' \
    -points inner + name=labels \
    -filter labelled \
    -target states \
    -lines + name=borders \
    -style target=labels label-text=id dy=4 fill='#aaa' font-size=13px \
    -style target=labels fill='#666' font-size=20px where='id=="9"' \
    -style target=states fill='id == "9" ? "#ececec" : "#fafafa"' \
    -style target=borders stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' \
    -style target=Memphis fill=none stroke='#555' stroke-width=1.2 \
    -style target=rectangle fill='#f1f1f1' \
    -target rectangle,states,borders,Memphis,labels \
    -o "$OUTPUT_DIR/$base.svg"

done

echo "Done."


  mapshaper \
    -i "$INPUT_DIR/Tennessee_093_to_094-1972_1974.geojson" name=states \
    -proj merc densify \
    -filter 'id == "8"' + name=Memphis \
    -frame bbox='-10053315,4138086,-9599584,4368830' width=400 offset=4% name=rectangle \
    -target states \
    -clip rectangle \
    -each 'labelled = this.area > 0' \
    -points inner + name=labels \
    -filter labelled \
    -target states \
    -lines + name=borders \
    -style target=labels label-text=id dy=4 fill='#aaa' font-size=13px \
    -style target=labels fill='#666' font-size=20px where='id=="9"' \
    -style target=states fill='id == "8" ? "#ececec" : "#fafafa"' \
    -style target=borders stroke='#c5c5c5' stroke-width='TYPE=="inner" ? 1 : 0.7' \
    -style target=Memphis fill=none stroke='#555' stroke-width=1.2 \
    -style target=rectangle fill='#f1f1f1' \
    -target rectangle,states,borders,Memphis,labels \
    -o "$OUTPUT_DIR/Tennessee_093_to_094-1972_1974.svg"


## Shelby County Zoom

INPUT_DIR='/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/Memphis-TN-09/GIS'
ROOT_DIR="$(dirname "$INPUT_DIR")/zoom"
OUTPUT_DIR="$ROOT_DIR/svg"
LOG_FILE="$OUTPUT_DIR/mapshaper_errors.log"

mkdir -p "$OUTPUT_DIR"

for f in "$INPUT_DIR"/*.geojson; do

  filebase="${f##*/}"
  base="${filebase%.geojson}"


  mapshaper \
    -i "$f" name=states \
    -i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/us-counties.json' \
    -i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/data/GIS/tl_2020_47_place20.json' name=places \
    -filter 'NAMELSAD20=="Memphis city"' \
    -style stroke=none fill='rgba(127,127,127,0.25)' \
    -i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/data/GIS/tracts.json' \
    -each 'Blackper = TOTAL > 0 ? BLACK/TOTAL : 0' \
    -each 'Whiteper = TOTAL > 0 ? WHITE/TOTAL : 0' \
    -each 'diff = Blackper - Whiteper' \
    -points + name=tract_points \
    -style 'r=Math.abs(diff*10)' \
    -style where='WHITE>=BLACK' fill='rgba(216,179,101,0.5)' stroke='rgba(216,179,101,0.9)' \
    -style where='WHITE<BLACK' fill='rgba(90,180,172,0.5)' stroke='rgba(90,180,172,0.9)' \
    -target us-counties \
    -filter 'STUSPS=="TN"' \
    -filter 'STUSPS=="TN"' + name=TN \
    -target us-counties,states,tract_points,places \
    -proj merc densify \
    -filter target=TN 'NAMELSAD == "Shelby County"' + name=Shelby \
    -frame width=400 offset=4% name=rectangle \
    -target states \
    -clip rectangle \
    -each 'labelled = this.area > 1e1' \
    -points inner + name=labels \
    -filter labelled \
    -target TN \
    -lines \
    -style stroke='TYPE=="inner" ? "#c5c5c5" : "#000"' stroke-width='TYPE=="inner" ? 0.7 : 1' \
    -target states \
    -lines \
    -style stroke='#000' stroke-width='TYPE=="inner" ? 2 : 0' \
    -target us-counties \
    -clip rectangle \
    -style fill=#fff stroke=none \
    -style target=rectangle fill='#f1f1f1' \
    -style target=labels label-text=id dy=4 fill='#333' font-size=26px \
    -target rectangle,us-counties,TN,places,tract_points,states,labels \
    -o "$OUTPUT_DIR/$base.svg"

done

echo "Done."

mapshaper \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/data/GIS/tn_2024_gen_2020_blocks.json' \
-i '/Users/cervas/Library/CloudStorage/GoogleDrive-jcervas@andrew.cmu.edu/My Drive/GitHub/createMaps/TN/blockscsv.csv' string-fields=GEOID20 \
-join target=tn_2024_gen_2020_blocks source=blockscsv keys=GEOID20,GEOID20 \
-proj merc densify \
-each 'Blackper = P1_001N > 0 ? P1_004N/P1_001N : 0' \
-each 'Whiteper = P1_001N > 0 ? P1_003N/P1_001N : 0' \
-each 'diff = Blackper - Whiteper' \
-filter 'Blackper > 0.9' + name=black_dots \
-target tn_2024_gen_2020_blocks \
-filter 'Whiteper > 0.9' + name=white_dots \
-target white_dots \
-filter 'G24PREDHAR>=G24PRERTRU' + name=harris_white
-points \
-style 'r=Math.abs((P1_003N-P1_004N)/P1_001N)'
-style fill='rgba(216,179,101,0.5)' stroke='rgba(216,179,101,0.9)'
-target black_dots
-filter 'G24PREDHAR>=G24PRERTRU' + name=harris_black
-points
-style 'r=Math.abs((P1_003N-P1_004N)/P1_001N)'
-style fill='rgba(90,180,172,0.5)' stroke='rgba(90,180,172,0.9)'

-filter target=tn-2026-proposal 'NAME==5' + name=tn-5 \
-filter target=tn-2026-proposal 'NAME==8' + name=tn-8 \
-filter target=tn-2026-proposal 'NAME==9' + name=tn-9 \

-clip target=harris_white source=tn-5 + name=white_dem_5
-clip target=harris_white source=tn-8 + name=white_dem_8
-clip target=harris_white source=tn-9 + name=white_dem_9

-clip target=harris_black source=tn-5 + name=black_dem_5
-clip target=harris_black source=tn-8 + name=black_dem_8
-clip target=harris_black source=tn-9 + name=black_dem_9

-calc target=white_dem_5 'sum(P1_003N)'
-calc target=white_dem_8 'sum(P1_003N)'
-calc target=white_dem_9 'sum(P1_003N)'

-calc target=black_dem_5 'sum(P1_004N)'
-calc target=black_dem_8 'sum(P1_004N)'
-calc target=black_dem_9 'sum(P1_004N)'

# A Wolf in Sheep’s Clothes

> “…political-gerrymandering claims in racial garb.” — Callais v. Louisiana

Is a redraw of Tennessee’s congressional map, undertaken with the stated intention of increasing Republican representation, really a racial gerrymander?

The Supreme Court’s decision in Callais v. Louisiana overturned decades of Voting Rights Act doctrine. In the majority’s formulation, Section 2 of the Voting Rights Act imposes liability only when “the evidence supports a strong inference that the State *intentionally* drew its districts to afford minority voters less opportunity because of their race.” (*Callais*, at 26, emphasis added). In practice, the decision sharply narrows the ability of plaintiffs to challenge maps that diminish minority voting power when states can plausibly characterize their actions as partisan rather than racial.

Almost immediately, Southern states previously constrained by Section 5 of the Voting Rights Act began considering or adopting plans that dismantled districts either drawn at the insistence of federal courts or containing large minority populations.

The Court’s reasoning was explicit:

> “Thus, in considering the constitutionality of a districting scheme, courts must treat partisan advantage like any other race-neutral aim: a constitutionally permissible criterion that States may rely on as desired.” (*Callais*, at 25)

And, quoting Alexander v. South Carolina State Conference of the NAACP:

> “To prevail, the plaintiff must ‘disentangle race from politics’ by proving ‘that the former drove a district’s lines.’” *Alexander*, 602 U.S. at 9 (quoting *Cooper*, 581 U.S. at 308).

But outside of explicit admissions by mapmakers, how can an expert truly disentangle race from party?

At least statistically, the answer may be: they cannot.

So long as race and party remain highly correlated, the distinction becomes analytically unstable. If the same voters are identified simultaneously by race and by partisanship, then measures of racial dilution and partisan dilution will often produce identical results. Consider an extreme example: if 100% of Democrats in a jurisdiction were Black, then every district line that diluted Democratic voting strength would necessarily dilute Black voting strength as well. Under those circumstances, there is nothing to disentangle. The effects are mathematically inseparable. 

Yet the Court’s majority appears to require exactly that impossible separation.

Viewed another way, when race and party are highly correlated, both are already being “controlled for” simultaneously. A district that fractures Black communities while preserving Republican advantage does not become race-neutral merely because the state can describe its goals in partisan language. If the practical consequence is the destruction of minority electoral opportunity, the distinction risks becoming semantic rather than substantive.

The facts in Tennessee, particularly in the Memphis area, are unusually stark.

Only 3.2% of U.S. counties are majority-Black. Shelby County, where Memphis is, contains the eleventh-largest Black population of any county in the United States. Among large counties, only Prince George's County has a higher Black population share. According to the 2020 Census, Shelby County is 53% Black.

Politically, the county votes overwhelmingly Democratic. In the 2024 presidential election, Shelby County voters supported Kamala Harris over Donald Trump by roughly 62% to 36%.

The city of Memphis is even more heavily Black than the county overall. Memphis has approximately 400,000 Black residents and is about 63% Black by population share. The city’s total population is just below the ideal size of a congressional district, but its Black population alone is more than sufficient to elect a candidate of choice, even if the remainder of the district were entirely white.

The same is true countywide. Shelby County’s Black population approaches 500,000 residents—again, more than enough to elect candidates preferred by Black voters in any reasonably configured district centered on the county. Indeed, fracturing Shelby County between two districts, as is required under the 'one person, one vote' doctrine, would still provide Black voters an opportunity to elect their candidates in at least one district. The Black population is graphically compact, as shown in Figure X.

All of this is to say that Memphis and Shelby County are not merely areas with substantial Black populations. They are heavily Black jurisdictions in which minority voters naturally possess the numerical strength to elect their preferred candidates. Any effort to divide these populations across multiple districts necessarily diminishes that power. White Democrats in the region are largely irrelevant to this question; Black voters alone possess sufficient electoral strength to constitute an effective voting bloc.

## A Century of Districting Tradition

Historically, Tennessee recognized this reality.

From 1922 until 1966, Tennessee’s congressional district centered on Memphis included all of Shelby County. Before Baker v. Carr established the principle of equal population, districts varied substantially in size, but Shelby County nonetheless remained intact.

Even after modern reapportionment rules took effect, Tennessee consistently maintained at least one congressional district wholly contained within Shelby County until the 2021 redistricting cycle.

Following the 2020 Census, Tennessee modestly expanded the district by adding approximately 30,000 residents from the county immediately north of Shelby County in order to equalize population. Otherwise, the Shelby County core of the district remained essentially unchanged.

The proposed post-*Callais* configuration bears little resemblance to any district previously used in Tennessee history—not merely post-Voting Rights Act, but even pre-Voting Rights Act.

## Simulations and the Probability of Minority Opportunity Districts

The Court would almost certainly require more than demographic arithmetic alone to establish a racial gerrymander. Fortunately, political scientists and mathematicians have developed rigorous methods for evaluating whether a districting plan departs dramatically from neutral baselines.

Co-principal investigators Kosuke Imai, Christopher T. Kenny, Cory McCartan, and Tyler Simko have archived thousands of simulated congressional maps for Tennessee. Their simulations generate counterfactual district plans using neutral districting criteria and then compare enacted plans against those baselines.

Among the 5,000 simulated plans, together with the legislature’s enacted 2021 plan, 4,945 contain at least one district in which Black residents comprise a majority of the population. In other words, only 1.1% of plans fail to produce such a district.

But Black voters need not constitute an absolute majority to elect candidates of choice. Differential turnout, coalition voting, and white crossover support often permit minority-preferred candidates to prevail in districts that are substantially below 50% Black.

The simulation data also include partisan election performance for several statewide contests: the 2016 presidential election, the 2020 presidential election, and the 2020 U.S. Senate election. Across all 15,003 district-election combinations generated by the simulations, the white-preferred candidate defeats the Black-preferred candidate only four times. Moreover, no simulated district ever produces more than a single loss for the Black-preferred candidate across the three elections.

The implication is difficult to avoid. Under virtually any neutrally drawn congressional plan, Tennessee naturally produces at least one district in which Black voters possess meaningful electoral influence. A plan that entirely eliminates such a district is not an ordinary political outcome emerging from geography or chance. It is an extreme outlier.

And when an extreme outlier systematically dismantles the voting power of one of the nation’s largest Black population centers, the distinction between “racial” and “partisan” intent becomes increasingly difficult to sustain.

The Fifteenth Amendment promises that the right to vote shall not be denied or abridged on account of race. A districting plan that predictably and intentionally eliminates Black electoral opportunity in Memphis raises the question of whether that promise still retains meaningful force after *Callais*.






