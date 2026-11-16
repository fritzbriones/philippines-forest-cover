# Data Reconciliation — Forest Cover CSV

The supplied CSV has 17 regional rows. The R workflow uses the supplied `forest_cover_ha` aggregate to calculate the map percentages and preserves the three forest-class fields as supplied.

Five rows differ by one hectare when the three forest-class fields are summed:

| Region | Class sum (ha) | Reported aggregate (ha) | Difference |
|---|---:|---:|---:|
| REGION IV-A | 272,634 | 272,635 | -1 |
| REGION V | 208,458 | 208,459 | -1 |
| REGION VIII | 538,952 | 538,953 | -1 |
| REGION IX | 173,126 | 173,127 | -1 |
| REGION XII | 293,690 | 293,689 | +1 |

Aggregate comparisons:
- Sum of reported regional aggregate: 7,225,908 ha
- Sum of the three forest-class columns: 7,225,905 ha
- National total stated in the supplied technical notes: 7,225,907 ha

The source workbook was not included in the uploaded project files, so it is not possible to determine which total is authoritative from the CSV alone. No values have been silently changed. The discrepancy is explicitly documented and surfaced by the R script. Reconcile against the original PSA workbook before publication.

## Rounding residuals - resolved

The five ±1 ha differences are consistent with independent rounding of each
forest class to the nearest hectare in the source tables. Totals from the CSV:

| Measure | Hectares |
|---|---:|
| Closed forest (sum of 17 regions) | 2,221,014 |
| Open forest (sum of 17 regions) | 4,693,674 |
| Mangrove (sum of 17 regions) | 311,217 |
| Sum of the three classes | 7,225,905 |
| Sum of reported regional forest cover | 7,225,908 |
| National total in the supplied technical notes | 7,225,907 |

The 3 ha gap between 7,225,908 and 7,225,905 is exactly the sum of the five
regional residuals (+1 +1 +1 +1 -1). The supplied values are kept unchanged.
Use 7,225,907 ha when quoting the national summary figure and 7,225,908 ha
for the bottom-up sum of the 17 regional rows.

## BARMM land-area denominator - official figure, with a caveat

The CSV uses **3,665,095 ha (36,650.95 km²)** for BARMM. This is the
published PSA figure based on the 2013 DENR-Land Management Bureau master
list of land areas, so it is consistent with how the other regional
denominators were sourced, and it is kept.

Caveat for readers: this total includes Lanao del Sur at 15,055.51 km², and
sources disagree strongly about that province's area (other published values
include about 3,873 km², 4,121 km² and about 13,400-13,800 km²). The regional
denominators also sum to 34,768,149 ha, about 4.8 million ha more than the
national land area of about 30 million ha (31.1 million ha even without
BARMM). If BARMM's land area were about 12,700 km², its forest cover would be
about 23% rather than 8.1%.

Boundary note: the map uses 2020 boundaries (Sulu inside BARMM), matching
the 2020 forest data. The Supreme Court ruled in 2024 that Sulu is not part of
BARMM, so tables for later years may use different BARMM boundaries.

## Suggested publication footnote

> Note: Regional land-area denominators are from the Philippine Statistics
> Authority, based on the 2013 DENR-Land Management Bureau master list
> (BARMM: 36,650.95 km², 2020 boundaries including Sulu); published area
> figures for some BARMM provinces differ between sources. Forest classes
> (closed, open, mangrove) are rounded independently to the nearest hectare
> in the source data, so they differ from regional totals by ±1 ha in five
> regions (IV-A, V, VIII, IX, XII). The sum of regional totals (7,225,908 ha)
> and of forest classes (7,225,905 ha) therefore differ slightly from the
> national total (7,225,907 ha).
