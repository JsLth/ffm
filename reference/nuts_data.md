# German NUTS `MULTIPOLYGON`s

Three [`sf`](https://r-spatial.github.io/sf/reference/sf.html)
dataframes containing all geometries of German NUTS1, NUTS2, and NUTS3
regions, respectively. The reference year is 2023.

These datasets can be very useful for quickly retrieving pre-loaded
boundaries without download.

## Usage

``` r
bkg_nuts1

bkg_nuts2

bkg_nuts3
```

## Format

For the dataframe format, see
[`bkg_nuts`](https://jslth.github.io/ffm/reference/bkg_nuts.md).

An object of class `sf` (inherits from `tbl_df`, `tbl`, `data.frame`)
with 38 rows and 7 columns.

An object of class `sf` (inherits from `tbl_df`, `tbl`, `data.frame`)
with 400 rows and 7 columns.

## Source

© BKG (2025) dl-de/by-2-0, data sources:
<https://sgx.geodatenzentrum.de/web_public/gdz/datenquellen/datenquellen_vg_nuts.pdf>

## See also

[`bkg_nuts`](https://jslth.github.io/ffm/reference/bkg_nuts.md)

Other datasets:
[`admin_data`](https://jslth.github.io/ffm/reference/admin_data.md)

## Examples

``` r
bkg_nuts1
#> Simple feature collection with 16 features and 6 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280353.1 ymin: 5235878 xmax: 921261.6 ymax: 6101302
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 16 × 7
#>    OBJID            BEGINN        GF NUTS_LEVEL NUTS_CODE NUTS_NAME             
#>    <chr>            <date>     <int>      <int> <chr>     <chr>                 
#>  1 DEBKGNU5000000C8 2021-10-04     9          1 DE1       Baden-Württemberg     
#>  2 DEBKGNU5000000C9 2021-10-04     9          1 DE2       Bayern                
#>  3 DEBKGNU5000000CA 2021-10-04     9          1 DE3       Berlin                
#>  4 DEBKGNU5000000CB 2021-10-04     9          1 DE4       Brandenburg           
#>  5 DEBKGNU5000000CC 2021-10-04     9          1 DE5       Bremen                
#>  6 DEBKGNU5000000CD 2021-10-04     9          1 DE6       Hamburg               
#>  7 DEBKGNU5000000CE 2021-10-04     9          1 DE7       Hessen                
#>  8 DEBKGNU5000000CF 2021-10-04     9          1 DE8       Mecklenburg-Vorpommern
#>  9 DEBKGNU5000000CG 2021-10-04     9          1 DE9       Niedersachsen         
#> 10 DEBKGNU5000000CH 2021-10-04     9          1 DEA       Nordrhein-Westfalen   
#> 11 DEBKGNU5000000CI 2021-10-04     9          1 DEB       Rheinland-Pfalz       
#> 12 DEBKGNU5000000CJ 2021-10-04     9          1 DEC       Saarland              
#> 13 DEBKGNU5000000CK 2021-10-04     9          1 DED       Sachsen               
#> 14 DEBKGNU5000000CL 2021-10-04     9          1 DEE       Sachsen-Anhalt        
#> 15 DEBKGNU5000000CM 2021-10-04     9          1 DEF       Schleswig-Holstein    
#> 16 DEBKGNU5000000CN 2021-10-04     9          1 DEG       Thüringen             
#> # ℹ 1 more variable: geometry <MULTIPOLYGON [m]>
```
