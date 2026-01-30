# German administrative boundaries

Three [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
dataframes containing all geometries of German districts, federal
states, and the country, respectively. The reference year is 2023.

## Usage

``` r
bkg_krs

bkg_states

bkg_germany
```

## Format

For the dataframe format, see
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md).

An object of class `sf` (inherits from `tbl_df`, `tbl`, `data.frame`)
with 25 rows and 25 columns.

An object of class `sf` (inherits from `tbl_df`, `tbl`, `data.frame`)
with 7 rows and 25 columns.

## Source

© BKG (2025) dl-de/by-2-0, data sources:
<https://sgx.geodatenzentrum.de/web_public/gdz/datenquellen/Datenquellen_vg_nuts.pdf>

## See also

[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md)

Other datasets:
[`nuts_data`](https://jslth.github.io/ffm/reference/nuts_data.md)

## Examples

``` r
bkg_krs
#> Simple feature collection with 400 features and 24 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4031295 ymin: 2684102 xmax: 4672497 ymax: 3551313
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 400 × 25
#>    objid      beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz
#>    <chr>      <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int>
#>  1 DEBKGVG50… 2019-10-03     4     9     1 01001 01001 010010… Flen… Krei…    40
#>  2 DEBKGVG50… 2019-10-03     4     9     1 01002 01002 010020… Kiel  Krei…    40
#>  3 DEBKGVG50… 2019-10-03     4     9     1 01003 01003 010030… Lübe… Krei…    40
#>  4 DEBKGVG50… 2019-10-03     4     9     1 01004 01004 010040… Neum… Krei…    40
#>  5 DEBKGVG50… 2019-10-03     4     9     1 01051 01051 010510… Dith… Kreis    42
#>  6 DEBKGVG50… 2021-06-19     4     9     1 01053 01053 010530… Herz… Kreis    42
#>  7 DEBKGVG50… 2019-10-03     4     9     1 01054 01054 010540… Nord… Kreis    42
#>  8 DEBKGVG50… 2019-10-03     4     9     1 01055 01055 010550… Osth… Kreis    42
#>  9 DEBKGVG50… 2019-10-03     4     9     1 01056 01056 010560… Pinn… Kreis    42
#> 10 DEBKGVG50… 2019-10-03     4     9     1 01057 01057 010570… Plön  Kreis    42
#> # ℹ 390 more rows
#> # ℹ 14 more variables: bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, geometry <MULTIPOLYGON [m]>
```
