# Philippine Forest Cover by Region (2020)

A reproducible R workflow for mapping 2020 forest-cover percentages across the 17 Philippine administrative regions.

## Run

```r
install.packages(c("tidyverse", "sf", "scales", "svglite"))
source("00_prepare_boundaries.R")
source("ph_forest_cover.R")
```

The first script validates the GeoJSON and creates `ph_regions.gpkg`. The second script validates the data-to-boundary join and exports PNG and SVG maps in `output/`.

See `NOTES.md` and `DATA_RECONCILIATION.md` for denominator definitions, data caveats, source attribution, and reproducibility details.
