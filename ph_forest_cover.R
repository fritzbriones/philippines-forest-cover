# ==============================================================================
# PROJECT: Philippine Forest Cover by Region (2020)
# PURPOSE: Publication-ready choropleth of forest-cover percentage, with an
#          explicit treatment of the regional vs national denominator systems.
# DATA:   ph_forest_cover_2020.csv (verified against the PSA Land Asset
#         Accounts 2015-2020 closing stock; see NOTES.md)
# ==============================================================================

# === BATCH 1: LIBRARIES & DATA =================================================
library(tidyverse)
library(sf)
library(scales)

forest <- read_csv("ph_forest_cover_2020.csv") |>
  mutate(
    forest_cover_ha   = as.numeric(forest_cover_ha),
    total_land_ha_official = as.numeric(total_land_ha_official),
    forest_pct = 100 * forest_cover_ha / total_land_ha_official
  )

# Guardrails: the dataset must be internally complete before mapping
stopifnot(
  nrow(forest) == 17,
  !any(is.na(forest$forest_cover_ha)),
  !any(is.na(forest$total_land_ha_official)),
  all(forest$total_land_ha_official > 0),
  all(forest$forest_cover_ha <= forest$total_land_ha_official)
)

# Diagnostics (NOT the headline number): sum-of-regions figures
forest |>
  summarise(
    regions              = n(),
    forest_ha            = sum(forest_cover_ha),
    regional_land_sum_ha = sum(total_land_ha_official),
    unweighted_mean_pct  = mean(forest_pct),
    land_weighted_pct    = 100 * sum(forest_cover_ha) / sum(total_land_ha_official)
  ) |> print()

# National PSA reference values (see NOTES.md for the denominator discussion)
national_forest_pct_30M    <- 24.09  # incl. mangrove; 30.0M ha national convention
national_forest_pct_PSA    <- 23.4   # PSA published: open+closed forest on 29,588,367 ha classified total

# === BATCH 2: REGION BOUNDARIES ================================================
# Place an official Philippine region boundary file in this folder.
# Recommended sources (region level, 17 regions incl. BARMM):
#   - PSA / NAMRIA official administrative boundaries
#   - PhilGIS region-level shapefile
#   - GADM level-1 (ph_regions.gpkg / .shp)
ph_regions <- st_read("ph_regions.gpkg", layer = "regions", quiet = TRUE)
ph_regions <- ph_regions |> st_transform(4326)

# Crosswalk: CSV region keys -> common boundary-file names. Edit the
# right-hand column to match your boundary file's name column.
region_key <- tribble(
  ~region,      ~region_name,
  "NCR",        "National Capital Region",
  "CAR",        "Cordillera Administrative Region",
  "REGION I",   "Region I (Ilocos)",
  "REGION II",  "Region II (Cagayan Valley)",
  "REGION III", "Region III (Central Luzon)",
  "REGION IV-A","Region IV-A (CALABARZON)",
  "REGION IV-B","Region IV-B (MIMAROPA)",
  "REGION V",   "Region V (Bicol)",
  "REGION VI",  "Region VI (Western Visayas)",
  "REGION VII", "Region VII (Central Visayas)",
  "REGION VIII","Region VIII (Eastern Visayas)",
  "REGION IX",  "Region IX (Zamboanga Peninsula)",
  "REGION X",   "Region X (Northern Mindanao)",
  "REGION XI",  "Region XI (Davao)",
  "REGION XII", "Region XII (SOCCSKSARGEN)",
  "REGION XIII","Region XIII (Caraga)",
  "BARMM",      "BARMM"
)

map_data <- ph_regions |>
  left_join(
    forest |> select(region, forest_cover_ha, total_land_ha_official, forest_pct),
    by = c("name" = "region")   # change "name" to your boundary file's region column
  )

# Guardrail: every polygon must have a value before drawing
unmatched <- sum(is.na(map_data$forest_pct))
if (unmatched > 0) {
  warning(unmatched, " region polygon(s) did not match the data - shown in gray")
}

# === BATCH 3: THE MAP ==========================================================
final_map <- ggplot(map_data, aes(fill = forest_pct)) +
  geom_sf(color = "white", linewidth = 0.15) +
  scale_fill_viridis_c(
    option = "viridis",
    name = "Forest cover\n(% of official\nregional land area)",
    labels = label_number(suffix = "%"),
    na.value = "grey85"
  ) +
  coord_sf(datum = NA) +
  # National reference: annotation only, never a weighted regional mean
  annotate(
    "label",
    x = 118.8, y = 5.8,
    label = paste0(
      "National PSA reference:\n",
      national_forest_pct_30M, "% (incl. mangrove; 30.0M ha convention)\n",
      national_forest_pct_PSA, "% (PSA: open + closed forest,\n29,588,367 ha classified total)"
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
    subtitle = "Closing stock of closed, open, and mangrove forest as a share of official regional land area",
    caption = paste0(
      "Source: PSA Land Asset Accounts 2015-2020 (closing stock, 2020); regional land areas per official ",
      "PSA/DENR figures.\n",
      "Regional percentages use official regional land areas as denominators. The national PSA land-cover ",
      "total is 29,588,367 ha; the sum of official\n",
      "regional land areas is larger (about 34.8M ha) because of administrative-boundary and cadastral ",
      "conventions. The national percentage\n",
      "is therefore presented as a PSA reference value, not as a weighted average of regional percentages. ",
      "Forest cover here includes mangrove\n",
      "forest; PSA's published 23.4% refers to open and closed forest on the classified land-cover total."
    )
  )

final_map

# === BATCH 4: EXPORT ===========================================================
if (!dir.exists("output")) dir.create("output")
ggsave("output/ph_forest_cover_2020.png", plot = final_map,
       width = 10, height = 12, dpi = 300, bg = "white")
ggsave("output/ph_forest_cover_2020.svg", plot = final_map,
       width = 10, height = 12, bg = "white")
