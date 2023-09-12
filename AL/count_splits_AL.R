
# Define the paths to the required files
plan <- "/Users/cervas/Library/Mobile Documents/com~apple~CloudDocs/Downloads/block-assignments.csv"
 custom_geo <- "/Users/cervas/My Drive/GitHub/createMaps/AL/city_block_equiv.csv"
 cd2021 <- "/Users/cervas/My Drive/GitHub/createMaps/AL/plans/AL 2021 Plan Congressional.csv"
 cd2021min <- "/Users/cervas/My Drive/GitHub/createMaps/AL/plans/AL 2021 Congressional - Minimum Change.csv"
 cd2023 <- "/Users/cervas/My Drive/GitHub/createMaps/AL/plans/AL 2023 Plan Congressional.csv"
 cd2023min <- "/Users/cervas/My Drive/GitHub/createMaps/AL/plans/AL 2023 Congressional - Minimum Change.csv"
 census_blocks <- "/Users/cervas/My Drive/GitHub/Data Files/Census/AL2020.pl/clean data/blocks.csv"
 
 # Call the countSplits function with the specified arguments
 countSplits(plan = plan, census_blocks = census_blocks, custom_geo = custom_geo, plan_id="GEOID20", block_id="GEOID20", custom_geo_id="block")
 countSplits(plan = cd2021, census_blocks = census_blocks, custom_geo = custom_geo, plan_id="GEOID20", block_id="GEOID20", custom_geo_id="block")
 countSplits(plan = cd2021min, census_blocks = census_blocks, custom_geo = custom_geo, plan_id="GEOID20", block_id="GEOID20", custom_geo_id="block")
 countSplits(plan = cd2023, census_blocks = census_blocks, custom_geo = custom_geo, plan_id="GEOID20", block_id="GEOID20", custom_geo_id="block")
 countSplits(plan = cd2023min, census_blocks = census_blocks, custom_geo = custom_geo, plan_id="GEOID20", block_id="GEOID20", custom_geo_id="block")
 