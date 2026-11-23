# Technical Notes — Philippine Forest Cover by Region (2020)

## Project contents

- `ph_forest_cover_2020.csv`: regional forest-cover observations and official regional land-area denominators.
- `ph_regions.geojson`: geoBoundaries Philippines ADM1 boundaries, 2020 vintage.
- `00_prepare_boundaries.R`: validates the 17 boundary features and creates `ph_regions.gpkg`.
- `ph_forest_cover.R`: joins the regional data to the prepared boundaries and exports the PNG and SVG map.
- `DATA_RECONCILIATION.md`: transparent record of small aggregate discrepancies.

## Boundary data

The supplied GeoJSON contains 17 unique ADM1 features, all with geometries, in EPSG:4326. Its `shapeName` values match the crosswalk in `00_prepare_boundaries.R`; the 2020 boundary uses `ARMM`, which the script maps to the CSV key `BARMM`.

Boundary metadata for geoBoundaries PHL ADM1 identifies:
- Boundary vintage: 2020
- Administrative level: ADM1 (Regions)
- Source agencies: National Mapping and Resource Information Authority (NAMRIA), Philippine Statistics Authority (PSA), and OCHA Philippines
- Boundary licence: Creative Commons Attribution 3.0 Intergovernmental Organisations (CC BY 3.0 IGO)

The boundary-data licence is separate from the MIT licence covering this project's original code. Retain the boundary attribution when redistributing the GeoJSON or maps derived from it.

## Denominator definitions

| Measure | Denominator / definition | Reference |
|---|---|---|
| National, incl. mangrove (calculated) | 29,588,367 ha PSA land-cover total; forest incl. mangrove 7,225,907 ha | 24.4% |
| PSA published reference | 29,588,367 ha classified land-cover total; open + closed forest | 23.4% (reported; approximately 23.37% using the underlying ratio) |
| Regional map | Official regional land-area denominators; forest cover includes mangrove | Calculated separately for each region |

The sum of official regional land areas in the CSV is 34,768,149 ha. This is not the national classified land-cover denominator. Therefore, the national reference percentages are annotations and are not calculated as weighted averages of the regional percentages.

## Data reconciliation and rounding

The CSV's `forest_cover_ha` column is retained as the supplied regional aggregate and is used to calculate the mapped percentage. The three forest-class columns are also retained as supplied. They do not sum exactly to the aggregate in five rows:

| Region | Closed + open + mangrove (ha) | Reported forest aggregate (ha) | Difference (class sum minus aggregate) |
|---|---:|---:|---:|
| REGION IV-A | 272,634 | 272,635 | -1 |
| REGION V | 208,458 | 208,459 | -1 |
| REGION VIII | 538,952 | 538,953 | -1 |
| REGION IX | 173,126 | 173,127 | -1 |
| REGION XII | 293,690 | 293,689 | +1 |

Consequently:
- Sum of the regional `forest_cover_ha` aggregates: **7,225,908 ha**.
- Sum of the three class columns across regions: **7,225,905 ha**.
- National total stated in the supplied notes: **7,225,907 ha**.

These figures differ by only 1–3 ha. The differences have been reconciled: the five ±1 ha regional residuals add up exactly to the 3 ha national gap, consistent with independent rounding of each forest class to the nearest hectare in the source tables; see [`DATA_RECONCILIATION.md`](DATA_RECONCILIATION.md). The source values are kept unchanged. The map uses the supplied `forest_cover_ha` aggregate consistently, while the R script reports the class-sum differences as a diagnostic.

The `forest_pct` column in the CSV is rounded to two decimal places. The R script recalculates the mapped percentage from `forest_cover_ha / total_land_ha_official` so that the map uses unrounded ratios.

## Methods wording

> Regional forest-cover percentages were calculated by dividing the reported regional forest-cover aggregate (closed forest, open forest, and mangrove forest) by the corresponding official regional land area. National PSA reference percentages are reported separately because the national classified land-cover denominator and the sum of official regional land areas represent different accounting conventions. Small hectare-level differences between the reported regional aggregate and the sum of the three displayed forest classes are rounding residuals in the source tables and are documented in DATA_RECONCILIATION.md.

## Reproducibility

Run from the project root in RStudio:

```r
install.packages(c("tidyverse", "sf", "scales", "svglite"))
source("00_prepare_boundaries.R")
source("ph_forest_cover.R")
```

Expected outputs:
- `ph_regions.gpkg`
- `output/ph_forest_cover_2020.png`
- `output/ph_forest_cover_2020.svg`

The R scripts include checks for the 17 region keys, duplicate/missing regions, geometry validity, and complete polygon-to-data joins.

## Sources

- Philippine Statistics Authority (PSA), Land Asset Accounts 2015–2020, statistical tables and technical notes (source workbook should be retained with the research materials).
- PSA, ENRAD Table 1.22, Forest Cover of the Philippines by Forest Type, by Region and Province: 2010, 2015, 2020.
- geoBoundaries API metadata, Philippines ADM1: https://www.geoboundaries.org/api/current/gbOpen/PHL/ADM1/
- geoBoundaries project: https://www.geoboundaries.org/
