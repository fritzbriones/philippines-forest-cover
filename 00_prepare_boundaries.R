# ==============================================================================
# PREPARATION: Build ph_regions.gpkg from the geoBoundaries Philippines ADM1 file
# Boundary vintage: 2020 | 17 regions | EPSG:4326
# Run this script once before ph_forest_cover.R.
# ==============================================================================

# Required package:
# install.packages("sf")

library(sf)

boundary_file <- "ph_regions.geojson"
output_file   <- "ph_regions.gpkg"

if (!file.exists(boundary_file)) {
  stop("Missing ", boundary_file,
       ". Place ph_regions.geojson in the project root folder.")
}

regions_raw <- st_read(boundary_file, quiet = TRUE)

# geoBoundaries PHL ADM1 shapeName -> region key used in the CSV.
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

expected_regions <- unname(key)

# Validate schema and exact feature coverage before writing.
if (!"shapeName" %in% names(regions_raw)) {
  stop("The boundary file has no 'shapeName' field.")
}
if (nrow(regions_raw) != 17L) {
  stop("Expected 17 ADM1 features; found ", nrow(regions_raw), ".")
}
if (anyDuplicated(regions_raw$shapeName)) {
  stop("Duplicate shapeName values found in the boundary file.")
}

unknown_names <- setdiff(regions_raw$shapeName, names(key))
missing_names <- setdiff(names(key), regions_raw$shapeName)

if (length(unknown_names) > 0L) {
  stop("Unmapped boundary names: ", paste(unknown_names, collapse = ", "))
}
if (length(missing_names) > 0L) {
  stop("Expected boundary names missing: ", paste(missing_names, collapse = ", "))
}

regions_raw$name <- unname(key[regions_raw$shapeName])

if (anyNA(regions_raw$name) || anyDuplicated(regions_raw$name)) {
  stop("Region crosswalk produced missing or duplicate region keys.")
}
if (!setequal(regions_raw$name, expected_regions)) {
  stop("Mapped region keys do not exactly match the expected 17 CSV regions.")
}

# GeoJSON coordinates are expected in WGS84. Preserve/standardize CRS.
if (is.na(st_crs(regions_raw))) {
  st_crs(regions_raw) <- 4326
} else {
  regions_raw <- st_transform(regions_raw, 4326)
}

# Repair only invalid geometries; leave valid geometries unchanged.
valid <- st_is_valid(regions_raw)
if (any(is.na(valid) | !valid)) {
  regions_raw <- st_make_valid(regions_raw)
}
if (any(!st_is_valid(regions_raw))) {
  stop("One or more geometries remain invalid after st_make_valid().")
}

ph <- regions_raw[, "name"]

# Replace an earlier GeoPackage cleanly.
if (file.exists(output_file)) {
  file.remove(output_file)
}
st_write(ph, output_file, layer = "regions", quiet = TRUE)

# Read-back verification confirms the file was written correctly.
check <- st_read(output_file, layer = "regions", quiet = TRUE)
stopifnot(
  nrow(check) == 17L,
  !anyNA(check$name),
  !anyDuplicated(check$name),
  setequal(check$name, expected_regions)
)

cat("SUCCESS: ", output_file, " written with 17 validated regions.\n", sep = "")
cat("Next: run source('ph_forest_cover.R')\n")
