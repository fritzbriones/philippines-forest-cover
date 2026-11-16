# Philippine Forest Cover by Region (2020)

A reproducible R-based geospatial workflow for mapping forest-cover distribution across the 17 administrative regions of the Philippines.

![Philippine Forest Cover by Region (2020)](ph_forest_cover_2020.png)

*Figure 1. Regional forest-cover distribution in the Philippines, 2020. The map displays each region's reported forest-cover aggregate as a percentage of its official regional land area.*

**Map files:** [PNG (300 DPI)](ph_forest_cover_2020.png) · [SVG (vector)](ph_forest_cover_2020.svg)

---

## Project overview

This project combines regional forest-cover statistics with Philippine administrative boundaries to produce a reproducible regional choropleth map for 2020.

The repository includes the source dataset, geographic boundary file, R scripts for boundary preparation and mapping, and documentation of the analytical decisions and data limitations.

### Objectives

- Visualize forest-cover percentages across the 17 Philippine administrative regions.
- Integrate regional statistical observations with geographic administrative boundaries.
- Provide a reproducible R workflow for preparing boundaries, validating joins, and generating map outputs.
- Document the data sources, denominator choices, assumptions, and known discrepancies.

## Data sources

### Forest-cover statistics

Regional forest-cover values are based on Philippine Statistics Authority (PSA) statistical materials, including the forest-cover-by-region-and-province table and the PSA Land Asset Accounts release. See **References** for the source records.

### Administrative boundaries

The boundary file is from geoBoundaries, gbOpen, Philippines ADM1 (regions), representing the 2020 boundary vintage. The geoBoundaries metadata identifies 17 administrative units and names the National Mapping and Resource Information Authority (NAMRIA), Philippine Statistics Authority (PSA), and OCHA Philippines as source agencies. The boundary data carries a CC BY 3.0 IGO license.

The 2020 boundary file labels the Bangsamoro region using the historical name `ARMM`. The preparation script maps that feature to the analytical key `BARMM` used in the forest-cover CSV.

## Method

Regional forest-cover percentage is calculated as:

\[
\text{Forest cover (\%)} =
\frac{\text{Reported regional forest cover (ha)}}
{\text{Official regional land area (ha)}} \times 100
\]

The supplied regional forest-cover aggregate is used for the mapped percentage. The dataset's forest-cover aggregate includes closed forest, open forest, and mangrove forest.

### Interpreting the national reference figures

The map includes national figures as contextual annotations only. They are not weighted averages of the regional percentages.

- **23.4%** is the PSA's published 2020 figure for open and closed forest cover relative to the national classified land-cover total of 29,588,367 hectares. This PSA headline figure refers to open and closed forest; it should not be treated as identical to the regional aggregate used here, which includes mangrove.
- **24.09%** is a separate project-level ratio based on the national forest-cover total and a 30-million-hectare convention described in the technical notes. It is not presented as the PSA's published 23.4% statistic.

The sum of the official regional land-area denominators in the supplied CSV is not the same as the national classified land-cover denominator. These figures therefore represent different accounting conventions and should not be directly interchanged.

## Repository contents

| File | Purpose |
|---|---|
| `README.md` | Project overview, workflow, and citation information |
| `00_prepare_boundaries.R` | Validates the 17 regional boundary features and creates the GeoPackage |
| `ph_forest_cover.R` | Validates the dataset-to-boundary join, calculates percentages, and creates the map |
| `ph_regions.geojson` | geoBoundaries Philippines ADM1 source boundaries |
| `ph_forest_cover_2020.csv` | Regional forest-cover observations and official regional land-area denominators |
| `ph_forest_cover_2020.png` | Root-level PNG used for the README map preview |
| `ph_forest_cover_2020.svg` | Root-level vector map |
| `NOTES.md` | Technical notes, denominators, provenance, and methodological details |
| `DATA_RECONCILIATION.md` | Record of hectare-level discrepancies in the supplied data |
| `LICENSE` | License for the project's original code |

The `ph_regions.gpkg` file is generated locally by the preparation script. The `output/` directory is also generated when the mapping script runs.

## Reproduce the map

### Requirements

- R and RStudio
- Internet access for initial R package installation
- The repository files listed above

Install the required packages in R:

```r
install.packages(c("tidyverse", "sf", "scales", "svglite"))
```

### Run in order

Open the repository folder as your RStudio project, or set the R working directory to the repository root.

**1. Prepare and validate the regional boundaries**

```r
source("00_prepare_boundaries.R")
```

This script:

- Reads `ph_regions.geojson`.
- Checks for the expected `shapeName` field and 17 regional features.
- Validates the region-name crosswalk, including `ARMM` to `BARMM`.
- Checks and repairs invalid geometries when necessary.
- Creates and reads back `ph_regions.gpkg` to verify the 17 mapped region keys.

**2. Generate the forest-cover map**

```r
source("ph_forest_cover.R")
```

This script:

- Reads and validates the 17 regional observations.
- Reads the prepared `ph_regions.gpkg`.
- Checks that every boundary feature matches one regional data record.
- Calculates forest-cover percentages from the hectare values and regional land-area denominators.
- Creates the choropleth and exports PNG and SVG files.

### Expected generated outputs

```text
ph_regions.gpkg

output/
├── ph_forest_cover_2020.png
└── ph_forest_cover_2020.svg
```

The R scripts write the regenerated figures to `output/`. The root-level PNG is the image embedded in this README. After checking that the regenerated map is correct, copy the generated figures to the repository root if you want the README preview and root-level map downloads to show the latest run:

```r
file.copy(
  "output/ph_forest_cover_2020.png",
  "ph_forest_cover_2020.png",
  overwrite = TRUE
)

file.copy(
  "output/ph_forest_cover_2020.svg",
  "ph_forest_cover_2020.svg",
  overwrite = TRUE
)
```

Commit the updated root-level PNG and SVG to GitHub after confirming the map.

## Validation and data limitations

The scripts include checks for:

- Exactly 17 regional boundary features and 17 regional observations.
- Missing, duplicate, or unmapped region keys.
- The expected `shapeName` boundary field.
- Geographic geometry validity.
- Complete polygon-to-data joins.

**Denominator note:** BARMM uses the official PSA figure (36,650.95 km², 2013 DENR-LMB master list); some BARMM provincial areas differ between sources. The ±1 ha class differences are rounding. Details and a ready-to-use footnote: [`DATA_RECONCILIATION.md`](DATA_RECONCILIATION.md).

### Hectare-level discrepancies

The supplied CSV contains small differences between the sum of the closed-forest, open-forest, and mangrove columns and the reported regional forest-cover aggregate in five regions. Across the 17 regions:

- Sum of reported regional forest-cover aggregates: **7,225,908 ha**.
- Sum of the three forest-class columns: **7,225,905 ha**.
- National total stated in the supplied technical notes: **7,225,907 ha**.

The original CSV values are preserved; the scripts do not silently overwrite or force these totals to agree. The discrepancy is documented in [`DATA_RECONCILIATION.md`](DATA_RECONCILIATION.md). The source workbook was not included with the project files, so the differences should be checked against the original PSA statistical workbook before publication or further statistical interpretation.

## How to cite this project

Users who reuse the repository's R workflow, adapt its map, or build on its project-specific processing steps are encouraged to cite the repository.

**APA 7th edition**

Briones, F. J. (2026). *Philippine forest cover by region (2020)* [Source code and geospatial workflow]. GitHub. https://github.com/fritzbriones/philippines-forest-cover

**In-text citation**

- Parenthetical: (Briones, 2026)
- Narrative: Briones (2026)

This is a GitHub repository citation, not a DOI-based archival citation. If a version is later archived in Zenodo or another DOI-issuing repository, use the DOI and cite the specific archived version for long-term scholarly reproducibility.

When reusing the underlying PSA statistics or geoBoundaries data, cite those original sources as well; citing this repository does not replace attribution to the data providers.

## References

geoBoundaries. (2023). *Philippines administrative boundaries, ADM1 (PHL-ADM1-36201628; 2020 vintage)* [Geospatial data]. gbOpen. https://www.geoboundaries.org/api/current/gbOpen/PHL/ADM1/

Philippine Statistics Authority. (2024, December 20). *The Philippines' open and closed forest cover grew by 2.9 percent in 2020* (Special Release No. 2024-203). https://psa.gov.ph/content/philippines-open-and-closed-forest-cover-grew-29-percent-2020

Philippine Statistics Authority. (n.d.). *Table 1.22: Forest cover of the Philippines by forest type, by region and province, 2010, 2015, and 2020* [Data set]. *Compendium of Philippine Environment Statistics, Component 1: Environmental Conditions and Quality*. Retrieved November 15, 2026, from https://psa.gov.ph/statistics/environment-statistics/node/1684083984

Runfola, D., Anderson, A., Baier, H., Crittenden, M., Dowker, E., Fuhrig, S., Goodman, S., Grimsley, G., Layko, R., Melville, G., Mulder, M., Oberman, R., Panganiban, J., Peck, A., Seitz, L., Shea, S., Slevin, H., Youngerman, R., & Hobbs, L. (2020). geoBoundaries: A global database of political administrative boundaries. *PLOS ONE, 15*(4), e0231866. https://doi.org/10.1371/journal.pone.0231866

## Licensing and attribution

The repository's MIT license applies to the original project code. It does not replace the license terms of third-party data.

The geoBoundaries Philippines ADM1 boundary data is identified in the dataset metadata as **Creative Commons Attribution 3.0 Intergovernmental Organisations (CC BY 3.0 IGO)**. Retain the boundary attribution when redistributing the original boundary file or derived products.

Consult the original PSA and geoBoundaries source records for applicable terms when redistributing source data or derivative datasets.

## Author

**Fritz Jeffry Briones**  
Philippines

GitHub: https://github.com/fritzbriones

---

*This repository is intended to support transparent, reproducible geospatial visualization and regional environmental analysis of Philippine forest-cover data.*
