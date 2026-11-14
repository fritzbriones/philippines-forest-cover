# Technical Notes — Data Verification and Denominator Definitions

## What this dataset is
`ph_forest_cover_2020.csv` contains the **2020 closing stock** of the PSA
Land Asset Accounts 2015–2020 (closed forest, open forest, mangrove forest)
for all 17 regions, verified cell-by-cell against the official statistical
tables (`Statistical Table_Land Accounts_Final.xlsx`):

- All 17 regional closing-stock values match the source workbook to the
  hectare after rounding (51 of 51 forest-class cells).
- The regional closing stocks sum **exactly** to the National table for all
  13 land-cover classes, confirming the accounts are internally consistent.
- National forest cover (closed + open + mangrove) = **7,225,907 ha**.

## Two denominator systems (the key methodological point)

| System | Denominator | Forest definition | Result |
|---|---|---|---|
| National convention | 30,000,000 ha (official PH land area) | incl. mangrove | **24.09%** |
| PSA published figure | 29,588,367 ha (sum of classified land-cover areas, 2020) | open + closed only | **23.4%** (reproduced: 23.37%) |
| Regional (this map) | Official regional land areas (sum ≈ 34.77M ha) | incl. mangrove | see CSV |

The sum of official regional land areas (~34.77M ha) exceeds both national
totals because regional cadastral/administrative areas overlap and differ
from land-classification coverage. This is a documented feature of
Philippine land statistics, not an error in the data.

Consequences, stated honestly:

1. Regional percentages are **not** population- or land-weighted components
   of the national percentage.
2. The national figure is presented on the map as a **PSA reference
   value**, never computed from the regional rows.
3. Regions with land-cover mapping gaps (notably BARMM, whose classified
   area is ~1.24M ha against an official regional area of ~3.67M ha) would
   be badly understated if the classified-area denominator were used
   instead (BARMM would jump from 8.11% to ~24%). The official regional
   land area is therefore the correct regional denominator.

## Methods wording (for a paper or report)

> Regional forest-cover shares are calculated using official regional land
> areas as denominators. The PSA Land Asset Accounts report a national
> land-cover total of 29,588,367 ha for 2020, whereas the sum of official
> regional land areas is larger because of administrative-boundary and
> land-accounting conventions. Consequently, the national forest-cover
> share is presented as a national PSA reference value and is not computed
> as a weighted average of the regional shares. Forest cover here includes
> mangrove forest; PSA's published 23.4% figure refers to open and closed
> forest on the classified land-cover total.

## Sources
- PSA Land Asset Accounts 2015–2020, technical notes and statistical
  tables (psa.gov.ph)
- PSA ENRAD Table 1.22, Forest Cover of the Philippines by Forest Type,
  by Region and Province: 2010, 2015, 2020
- Regional land areas: official PSA/DENR administrative figures
