# ==============================================================================
# PROJECT: Philippine Forest Cover by Region (2020)
# PURPOSE: Regional choropleth with explicit regional/national denominator
#          distinction. The map design retains the supplied reference figure.
# INPUTS: ph_forest_cover_2020.csv and ph_regions.gpkg
# RUN AFTER: 00_prepare_boundaries.R
# ==============================================================================

# Required packages:
# install.packages(c("tidyverse", "sf", "scales", "svglite"))

library(tidyverse)
library(sf)
library(scales)

# === 1. LOAD AND VALIDATE THE FOREST-COVER DATA ================================

csv_file <- "ph_forest_cover_2020.csv"
gpkg_file <- "ph_regions.gpkg"

if (!file.exists(csv_file)) stop("Missing input file: ", csv_file)
if (!file.exists(gpkg_file)) {
  stop("Missing ", gpkg_file,
       ". Run source('00_prepare_boundaries.R') first.")
}

forest <- read_csv(csv_file, show_col_types = FALSE) |>
  mutate(
    across(
      c(closed_forest_ha, open_forest_ha, mangrove_ha,
        forest_cover_ha, total_land_ha_official),
      as.numeric
    ),
    forest_pct_calculated = 100 * forest_cover_ha / total_land_ha_official
  )

required_columns <- c(
  "region", "region_name", "closed_forest_ha", "open_forest_ha",
  "mangrove_ha", "forest_cover_ha", "total_land_ha_official"
)
missing_columns <- setdiff(required_columns, names(forest))
if (length(missing_columns) > 0L) {
  stop("CSV is missing required columns: ",
       paste(missing_columns, collapse = ", "))
}

if (nrow(forest) != 17L ||
    anyNA(forest$region) ||
    anyDuplicated(forest$region) ||
    anyNA(forest$forest_cover_ha) ||
    anyNA(forest$total_land_ha_official) ||
    any(forest$total_land_ha_official <= 0) ||
    any(forest$forest_cover_ha < 0) ||
    any(forest$forest_cover_ha > forest$total_land_ha_official)) {
  stop("Forest-cover CSV failed the 17-region or numeric-value checks.")
}

expected_regions <- c(
  "NCR", "CAR", "REGION I", "REGION II", "REGION III",
  "REGION IV-A", "REGION IV-B", "REGION V", "REGION VI",
  "REGION VII", "REGION VIII", "REGION IX", "REGION X",
  "REGION XI", "REGION XII", "REGION XIII", "BARMM"
)

if (!setequal(forest$region, expected_regions)) {
  stop("CSV region keys do not match the expected 17 Philippine regions.")
}

# The three forest-class columns are retained exactly as supplied.
# Their row sums differ from the supplied aggregate by +/- 1 ha in five
# regions. See DATA_RECONCILIATION.md; do not silently overwrite source values.
forest <- forest |>
  mutate(
    class_sum_ha = closed_forest_ha + open_forest_ha + mangrove_ha,
    class_vs_reported_ha = class_sum_ha - forest_cover_ha
  )

rounding_check <- forest |>
  filter(class_vs_reported_ha != 0) |>
  select(region, class_sum_ha, forest_cover_ha, class_vs_reported_ha)

if (nrow(rounding_check) > 0L) {
  message("Note: class sums and reported regional aggregates differ in ",
          nrow(rounding_check),
          " row(s); see DATA_RECONCILIATION.md.")
  print(rounding_check)
}

# Diagnostic totals. These are not substituted for the national PSA reference.
forest |>
  summarise(
    regions = n(),
    reported_regional_forest_ha = sum(forest_cover_ha),
    sum_of_forest_class_columns_ha = sum(class_sum_ha),
    sum_of_official_regional_land_ha = sum(total_land_ha_official),
    unweighted_mean_regional_pct = mean(forest_pct_calculated),
    regional_land_weighted_pct =
      100 * sum(forest_cover_ha) / sum(total_land_ha_official)
  ) |>
  print()

# National reference values, retained as separately defined PSA conventions.
national_forest_pct_30M <- 24.09
national_forest_pct_PSA <- 23.4

# === 2. LOAD AND VALIDATE THE PREPARED REGIONAL BOUNDARIES =====================

ph_regions <- st_read(gpkg_file, layer = "regions", quiet = TRUE) |>
  st_transform(4326)

if (!"name" %in% names(ph_regions)) {
  stop("GeoPackage must contain the crosswalked 'name' field.")
}
if (nrow(ph_regions) != 17L ||
    anyNA(ph_regions$name) ||
    anyDuplicated(ph_regions$name)) {
  stop("Prepared boundary file must contain 17 unique, named regions.")
}

missing_in_map <- setdiff(expected_regions, ph_regions$name)
extra_in_map <- setdiff(ph_regions$name, expected_regions)
if (length(missing_in_map) || length(extra_in_map)) {
  stop(
    "Boundary/CSV mismatch. Missing: ",
    paste(missing_in_map, collapse = ", "),
    "; extra: ", paste(extra_in_map, collapse = ", ")
  )
}

# Join using the common region key produced by 00_prepare_boundaries.R.
map_data <- ph_regions |>
  left_join(
    forest |>
      select(region, forest_cover_ha, total_land_ha_official,
             forest_pct_calculated),
    by = c("name" = "region")
  )

if (nrow(map_data) != 17L || anyNA(map_data$forest_pct_calculated)) {
  stop("Not all 17 boundary polygons matched a forest-cover observation.")
}

# === 3. DRAW THE MAP ===========================================================

final_map <- ggplot(map_data, aes(fill = forest_pct_calculated)) +
  geom_sf(color = "white", linewidth = 0.15) +
  scale_fill_viridis_c(
    option = "viridis",
    name = "Forest cover\n(% of official\nregional land area)",
    labels = label_number(suffix = "%"),
    na.value = "grey85"
  ) +
  coord_sf(datum = NA) +
  annotate(
    "label",
    x = 118.8, y = 5.8,
    label = paste0(
      "National PSA reference:\n",
      national_forest_pct_30M,
      "% (incl. mangrove; 30.0M ha convention)\n",
      national_forest_pct_PSA,
      "% (PSA: open + closed forest,\n29,588,367 ha classified total)"
    ),
    size = 2.6, hjust = 0, lineheight = 0.9,
    fill = "white", color = "grey30", alpha = 0.9
  ) +
  theme_minimal(base_size = 11) +
  theme(
    legend.position = "right",
    plot.title = element_text(face = "bold", size = 14),
    plot.subtitle = element_text(color = "grey30", size = 10),
    plot.caption = element_text(size = 7, hjust = 0, lineheight = 1.1),
    plot.margin = margin(15, 15, 15, 15)
  ) +
  labs(
    title = "Forest Cover by Region, Philippines (2020)",
    subtitle = paste(
      "Closing stock of closed, open, and mangrove forest",
      "as a share of official regional land area"
    ),
    caption = paste0(
      "Forest data: PSA Land Asset Accounts 2015-2020 (2020 closing stock); ",
      "regional land areas: official PSA/DENR figures.\n",
      "Regional percentages use official regional land areas as denominators. ",
      "The sum of regional land areas (~34.77M ha) exceeds the national ",
      "classified land-cover total (29,588,367 ha) because the measures use ",
      "different administrative and land-accounting conventions.\n",
      "The national values are PSA reference figures, not weighted averages ",
      "of the regional percentages. Regional forest cover includes mangrove; ",
      "the published 23.4% PSA reference refers to open and closed forest.\n",
      "Boundaries: geoBoundaries, gbOpen, Philippines ADM1, 2020 vintage; ",
      "source agencies: NAMRIA, PSA and OCHA Philippines; ",
      "boundary data licence: CC BY 3.0 IGO."
    )
  )

print(final_map)

# === 4. EXPORT =================================================================

if (!dir.exists("output")) dir.create("output", recursive = TRUE)

ggsave(
  "output/ph_forest_cover_2020.png",
  plot = final_map, width = 10, height = 12, dpi = 300, bg = "white"
)
ggsave(
  "output/ph_forest_cover_2020.svg",
  plot = final_map, width = 10, height = 12, bg = "white"
)

cat("SUCCESS: map exported to output/ph_forest_cover_2020.png and .svg\n")
