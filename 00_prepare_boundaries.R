# ==============================================================================
# PREP: Build ph_regions.gpkg from the geoBoundaries PH ADM1 file
# Source: geoBoundaries (gbOpen, CC BY 4.0), 17 regions, 2020 vintage
# Note: the 2020 boundary file labels BARMM as "ARMM" (the same territory;
# BARMM succeeded ARMM in 2019). It is mapped to BARMM here.
# Run once, BEFORE ph_forest_cover.R.
# ==============================================================================
library(sf)

regions_raw <- st_read("ph_regions.geojson", quiet = TRUE)

# Crosswalk: geoBoundaries shapeName -> CSV region keys
key <- c(
  "NCR"                 = "NCR",
  "CAR"                 = "CAR",
  "Ilocos Region"       = "REGION I",
  "Cagayan Valley"      = "REGION II",
  "Central Luzon"       = "REGION III",
  "Calabarzon"          = "REGION IV-A",
  "Mimaropa"            = "REGION IV-B",
  "Bicol Region"        = "REGION V",
  "Western Visayas"     = "REGION VI",
  "Central Visayas"     = "REGION VII",
  "Eastern Visayas"     = "REGION VIII",
  "Zamboanga Peninsula" = "REGION IX",
  "Northern Mindanao"   = "REGION X",
  "Davao Region"        = "REGION XI",
  "Soccsksargen"        = "REGION XII",
  "Caraga"              = "REGION XIII",
  "ARMM"                = "BARMM"
)

regions_raw$name <- unname(key[regions_raw$shapeName])

# Guardrail: all 17 regions must map before writing
stopifnot(
  nrow(regions_raw) == 17,
  !any(is.na(regions_raw$name))
)

ph <- regions_raw[, "name"]
st_write(ph, "ph_regions.gpkg", layer = "regions", append = FALSE)
cat("ph_regions.gpkg written with", nrow(ph), "regions.\n")
cat("Next: run ph_forest_cover.R\n")

# Boundary source attribution (add to NOTES.md or figure caption as needed):
# "Region boundaries: geoBoundaries (gbOpen), CC BY 4.0, 2020 vintage."
