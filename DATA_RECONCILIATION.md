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

## To verify: BARMM land-area denominator

The CSV uses 3,665,095 ha (36,650.95 km²) as BARMM's official land area, giving 8.11% forest cover.
Published figures for BARMM's area disagree: 36,650.95 km² appears in PhilAtlas (PSA-derived, 2013),
while other descriptions of the region give roughly 12,700 km². With about 1,271,100 ha as the
denominator, BARMM's forest cover would be about 23.4% instead of 8.1%, which would change its colour
on the map and its rank among regions.

BARMM is also the main reason the regional land areas sum to 34.77 million ha, well above the
national land-cover total of about 29.6–30 million ha.

Before publication, confirm which BARMM land area the PSA Land Asset Accounts use as the denominator
for 2020 and whether the 36,650.95 km² figure includes non-land area. No values have been changed.
