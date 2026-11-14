# Forest Cover by Region, Philippines (2020)

A publication-ready R choropleth of **forest-cover percentage by region**, built from the PSA Land Asset Accounts 2015–2020 (2020 closing stock) and official regional land areas.

!Forest Cover by Region, Philippines

---

## Data Profile & Scope

- **Forest measure:** closed + open + mangrove forest, 2020 closing stock (hectares), verified cell-by-cell against the PSA statistical tables.
- **Denominator:** official PSA/DENR regional land areas — **not** the national accounting total. The two systems do not reconcile by design (see ).
- **National reference:** 24.09% (incl. mangrove; 30.0M ha convention) and PSA's published 23.4% (open + closed forest on 29,588,367 ha classified total) — shown as annotations, never as a weighted mean of regions.
- **Coverage:** all 17 regions, including BARMM.
- **Boundaries:** geoBoundaries (gbOpen, CC BY 4.0), 2020 vintage.

---

## Repository Architecture

```text
00_prepare_boundaries.R      # Builds ph_regions.gpkg from ph_regions.geojson
ph_forest_cover.R            # Full pipeline: validate -> join -> map -> export
ph_forest_cover_2020.csv     # Verified data: region, forest classes, land area, forest %
ph_regions.geojson           # Region boundaries: geoBoundaries (gbOpen, CC BY 4.0), 2020 vintage
ph_forest_cover_2020.png     # Final published map (300 dpi)
ph_forest_cover_2020.svg     # Vector version for journals/slides
NOTES.md                     # Verification report + denominator definitions + methods wording
README.md
```

## How to Run

### 1. Prerequisites

```r
install.packages(c("tidyverse", "sf", "scales"))
```

### 2. Steps

1. Run `00_prepare_boundaries.R` once — it converts `ph_regions.geojson` into `ph_regions.gpkg` with the correct region keys (all 17 regions verified, guardrail included).
2. Run `ph_forest_cover.R` — it validates the data, joins it to the boundaries, and saves the map to `output/`.

The pipeline validates before mapping: 17 regions required, no missing values, forest area never exceeds land area, and a warning if any polygon fails to join.

> Note: GADM's level-1 file for the Philippines contains the 81 **provinces**, not the 17 regions — do not substitute it for `ph_regions.geojson`.

## Honest denominators

Regional percentages use official regional land areas. The national PSA land-cover total (29,588,367 ha) and the sum of official regional land areas (~34.8M ha) differ because of administrative-boundary and cadastral conventions. The national percentage is therefore presented as a PSA reference value, not a weighted average of regional percentages. Full treatment in .

Region boundaries are from geoBoundaries (gbOpen, CC BY 4.0), 2020 vintage, and are used with attribution as that license requires.

## License

Released under the MIT License. The underlying statistics are from the Philippine Statistics Authority (public sector information).
