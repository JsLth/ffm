# Filtering

## Attribute filters

`ffm` supports certain R expressions for filtering WFS servers. These
expressions are not evaluated as-is but are converted to valid CQL or
XML in the background. Each filter expects a left-hand side consisting
of the name of a column in the output, an operator (e.g. `==`), and a
right-hand side consisting of values to filter. It can look like this:

``` r
bkg_admin(gen == "Berlin")
#> Simple feature collection with 1 feature and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4531042 ymin: 3253866 xmax: 4576603 ymax: 3290780
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 1 × 26
#>   objid   beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2 sn_g 
#>   <chr>   <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 DEBKGV… 2023-10-03     4     4     1 11000 11000 110000… Berl… Krei…    40 --    ja    11    0     00    00    00    000  
#> # ℹ 7 more variables: fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
```

This code downloads all districts where the column `gen` (the
geographical name) equals the string “Berlin”. While this might seem
intuitive at first, it can be quite frustrating to figure out which
columns there are to filter by and what values you can use as filters.
You have two options to find out. First, (probably) all attributes are
documented in the R documentation of the respective function as well as
the official documentation linked at the bottom of each function
reference page. Second, and more pragmatically, you can use the `max`
argument to control how many rows should be queried. In the following
example you can get a glance at how the output is structured.

``` r
bkg_admin(max = 10)
#> Simple feature collection with 10 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4181887 ymin: 3361471 xmax: 4406278 ymax: 3551489
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 10 × 26
#>    objid  beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2 sn_g 
#>    <chr>  <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 DEBKG… 2022-12-19     4     4     1 01001 01001 010010… Flen… Krei…    40 --    ja    01    0     01    00    00    000  
#>  2 DEBKG… 2022-12-19     4     4     1 01002 01002 010020… Kiel  Krei…    40 --    ja    01    0     02    00    00    000  
#>  3 DEBKG… 2024-04-03     4     4     1 01003 01003 010030… Lübe… Krei…    40 --    ja    01    0     03    00    00    000  
#>  4 DEBKG… 2022-12-19     4     4     1 01004 01004 010040… Neum… Krei…    40 --    ja    01    0     04    00    00    000  
#>  5 DEBKG… 2024-04-03     4     4     1 01051 01051 010510… Dith… Kreis    42 --    ja    01    0     51    00    00    000  
#>  6 DEBKG… 2024-04-03     4     4     1 01053 01053 010530… Herz… Kreis    42 --    ja    01    0     53    00    00    000  
#>  7 DEBKG… 2024-04-03     4     4     1 01054 01054 010540… Nord… Kreis    42 --    ja    01    0     54    00    00    000  
#>  8 DEBKG… 2024-04-03     4     4     1 01055 01055 010550… Osth… Kreis    42 --    ja    01    0     55    00    00    000  
#>  9 DEBKG… 2023-10-03     4     4     1 01056 01056 010560… Pinn… Kreis    42 --    ja    01    0     56    00    00    000  
#> 10 DEBKG… 2023-10-03     4     4     1 01057 01057 010570… Plön  Kreis    42 --    ja    01    0     57    00    00    000  
#> # ℹ 7 more variables: fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
```

While some columns are pretty obvious, others (e.g., `ade` or `gf`) may
warrant a look in the documentation.

A second consideration is which operator to use. Generally, there are 9
operators that can be used: `==`, `!=`, `<`, `>`, `<=`, `>=`, `%LIKE%`,
`%ILIKE%`, and `%in%`. Other operators are not supported by CQL or XML
and will emit an error:

``` r
bkg_admin(bem && 1)
#> Error in `FUN()`:
#> ! Operator `&&` is not supported in `bem && 1`.
#> ℹ Try one of the following operators: ==, !=, <, >, >=, <=, %LIKE%, %ILIKE%, and %in%.
```

While most operators are equivalent to their use in R, `%LIKE%` and
`%ILIKE%` stems from SQL and allows for wildcard matching in strings.
Instead of `*`, it uses `%` as a wildcard operator.

``` r
bkg_admin(gen %LIKE% "Ber%")
#> Simple feature collection with 4 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4082950 ymin: 2710124 xmax: 4576603 ymax: 3290780
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 4 × 26
#>   objid   beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2 sn_g 
#>   <chr>   <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#> 1 DEBKGV… 2024-04-03     4     4     1 06431 06431 064310… Berg… Land…    43 --    ja    06    4     31    00    00    000  
#> 2 DEBKGV… 2023-10-03     4     4     1 07231 07231 072310… Bern… Land…    43 --    ja    07    2     31    00    00    000  
#> 3 DEBKGV… 2021-12-13     4     4     1 09172 09172 091720… Berc… Land…    43 --    ja    09    1     72    00    00    000  
#> 4 DEBKGV… 2023-10-03     4     4     1 11000 11000 110000… Berl… Krei…    40 --    ja    11    0     00    00    00    000  
#> # ℹ 7 more variables: fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
```

Unlike the previous example, this query does not return Berlin but all
districts that start with “Ber”.

## Spatial filters

Besides attribute filters, `ffm` is also able to construct spatial
filters. This means you can include or exclude certain areas of your
output before downloading by providing a boundary box or a polygon
geometry. You can do this by either providing a rectangular box,
e.g. like this:

``` r
bbox <- c(xmin = 700000, ymin = 5900000, xmax = 850000, ymax = 6000000)

bkg_admin(bbox = bbox, predicate = "intersects")
#> Simple feature collection with 12 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4360521 ymin: 3280077 xmax: 4617795 ymax: 3514034
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 12 × 26
#>    objid  beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2 sn_g 
#>    <chr>  <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 DEBKG… 2024-04-03     4     4     1 12065 12065 120650… Ober… Land…    43 --    ja    12    0     65    00    00    000  
#>  2 DEBKG… 2024-04-03     4     4     1 12068 12068 120680… Ostp… Land…    43 --    ja    12    0     68    00    00    000  
#>  3 DEBKG… 2024-04-03     4     4     1 12070 12070 120700… Prig… Land…    43 --    ja    12    0     70    00    00    000  
#>  4 DEBKG… 2024-04-03     4     4     1 12073 12073 120730… Ucke… Land…    43 --    ja    12    0     73    00    00    000  
#>  5 DEBKG… 2023-10-03     4     4     1 13003 13003 130030… Rost… Krei…    40 --    ja    13    0     03    00    00    000  
#>  6 DEBKG… 2024-04-03     4     4     1 13071 13071 130710… Meck… Land…    43 --    ja    13    0     71    00    00    000  
#>  7 DEBKG… 2024-04-03     4     4     1 13072 13072 130720… Rost… Land…    43 --    ja    13    0     72    00    00    000  
#>  8 DEBKG… 2024-04-03     4     4     1 13073 13073 130730… Vorp… Land…    43 --    ja    13    0     73    00    00    000  
#>  9 DEBKG… 2024-04-03     4     4     1 13075 13075 130750… Vorp… Land…    43 --    ja    13    0     75    00    00    000  
#> 10 DEBKG… 2024-04-03     4     4     1 13076 13076 130760… Ludw… Land…    43 --    ja    13    0     76    00    00    000  
#> 11 DEBKG… 2023-10-03     4     2     1 13003 13003 130030… Rost… Krei…    40 --    ja    13    0     03    00    00    000  
#> 12 DEBKG… 2023-10-03     4     2     1 13075 13075 130750… Vorp… Land…    43 --    ja    13    0     75    00    00    000  
#> # ℹ 7 more variables: fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
```

or by providing a polygon. Polygons are generally expressed using `sf`
or `sfc` objects from the [`sf`](https://r-spatial.github.io/sf/)
package. Using polygons you can provide much more complex geometries to
filter by.

``` r
bbox <- sf::st_bbox(c(xmin = 700000, ymin = 5900000, xmax = 850000, ymax = 6000000))
poly <- sf::st_as_sfc(bbox)

bkg_admin(poly = poly, predicate = "intersects")
#> Simple feature collection with 12 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4360521 ymin: 3280077 xmax: 4617795 ymax: 3514034
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 12 × 26
#>    objid  beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2 sn_g 
#>    <chr>  <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
#>  1 DEBKG… 2024-04-03     4     4     1 12065 12065 120650… Ober… Land…    43 --    ja    12    0     65    00    00    000  
#>  2 DEBKG… 2024-04-03     4     4     1 12068 12068 120680… Ostp… Land…    43 --    ja    12    0     68    00    00    000  
#>  3 DEBKG… 2024-04-03     4     4     1 12070 12070 120700… Prig… Land…    43 --    ja    12    0     70    00    00    000  
#>  4 DEBKG… 2024-04-03     4     4     1 12073 12073 120730… Ucke… Land…    43 --    ja    12    0     73    00    00    000  
#>  5 DEBKG… 2023-10-03     4     4     1 13003 13003 130030… Rost… Krei…    40 --    ja    13    0     03    00    00    000  
#>  6 DEBKG… 2024-04-03     4     4     1 13071 13071 130710… Meck… Land…    43 --    ja    13    0     71    00    00    000  
#>  7 DEBKG… 2024-04-03     4     4     1 13072 13072 130720… Rost… Land…    43 --    ja    13    0     72    00    00    000  
#>  8 DEBKG… 2024-04-03     4     4     1 13073 13073 130730… Vorp… Land…    43 --    ja    13    0     73    00    00    000  
#>  9 DEBKG… 2024-04-03     4     4     1 13075 13075 130750… Vorp… Land…    43 --    ja    13    0     75    00    00    000  
#> 10 DEBKG… 2024-04-03     4     4     1 13076 13076 130760… Ludw… Land…    43 --    ja    13    0     76    00    00    000  
#> 11 DEBKG… 2023-10-03     4     2     1 13003 13003 130030… Rost… Krei…    40 --    ja    13    0     03    00    00    000  
#> 12 DEBKG… 2023-10-03     4     2     1 13075 13075 130750… Vorp… Land…    43 --    ja    13    0     75    00    00    000  
#> # ℹ 7 more variables: fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
```

Note how I simply converted the boundary box to an `sfc` object and
passed it as a polygon. One reason for this is because I am to lazy to
make an actual polygon geometry. The other reason is that complex
polygons can quickly push the limits of CQL queries.

## CQL versus XML queries

CQL (Common Query Language) is a query language that is often used for
WFS GET requests. It is rather simple and often almost matches the
syntax of R. XML (Extensible Markup Language) is a much more complicated
query language that is traditionally used for POST requests on WFS
servers. You can compare how filters look like by using the
[`wfs_filter()`](https://jslth.github.io/ffm/reference/wfs_filter.md)
function:

``` r
wfs_filter(gen == "Berlin", lang = "cql")
#> gen = 'Berlin'
```

``` r
wfs_filter(gen == "Berlin", lang = "xml")
#> <fes:Filter>
#>   <fes:PropertyIsEqualTo>
#>     <fes:ValueReference>gen</fes:ValueReference>
#>     <fes:Literal>Berlin</fes:Literal>
#>   </fes:PropertyIsEqualTo>
#> </fes:Filter>
```

By default `ffm` uses CQL queries because they’re much more reliable and
don’t break as easily. However, URLs cannot exceed a certain number of
characters or they are declined by the WFS server. This is particularly
critical for spatial filters with complex polygons. In the following, I
load the federal state of Baden Wurttemberg and try to retrieve all
districts that intersect its geometry.

``` r
bw <- bkg_admin(sn_l == "08", gf == 4, level = "lan")

bkg_wfs(
  "vg5000_krs",
  endpoint = "vg5000_0101",
  filter = wfs_filter(poly = bw)
)
#> Error in `bkg_wfs()`:
#> ! Query is too large to be handled by CQL queries.
#> ℹ Consider setting `options(ffm_query_language = "xml")`.
#> ℹ Alternatively, try to reduce the size of your query.
```

As the error tells us, you can switch between CQL and XML using
`options(ffm_query_language = "xml")`. This option switches to XML
queries for all requests made. Alternatively, you can use the `lang`
argument of
[`wfs_filter()`](https://jslth.github.io/ffm/reference/wfs_filter.md).
Using XML queries, the complex spatial filter of Baden Wurttemberg
becomes feasible:

``` r
options(ffm_query_language = "xml")

bkg_wfs(
  "vg5000_krs",
  endpoint = "vg5000_0101",
  filter = wfs_filter(poly = bw)
)
```

    #> Simple feature collection with 64 features and 25 fields
    #> Geometry type: MULTIPOLYGON
    #> Dimension:     XY
    #> Bounding box:  xmin: 4134332 ymin: 2684102 xmax: 4397824 ymax: 3014572
    #> Projected CRS: ETRS89-extended / LAEA Europe
    #> # A tibble: 64 × 26
    #>    id     objid beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz bem   nbd   sn_l  sn_r  sn_k  sn_v1 sn_v2
    #>    <chr>  <chr> <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr> <chr> <chr> <chr> <chr> <chr> <chr>
    #>  1 vg500… DEBK… 2019-10-03     4     9     1 06431 06431 064310… Berg… Land…    43 --    ja    06    4     31    00    00   
    #>  2 vg500… DEBK… 2019-10-03     4     9     1 06437 06437 064370… Oden… Land…    43 --    nein  06    4     37    00    00   
    #>  3 vg500… DEBK… 2019-10-03     4     9     1 07311 07311 073110… Fran… Krei…    40 --    ja    07    3     11    00    00   
    #>  4 vg500… DEBK… 2019-10-03     4     9     1 07314 07314 073140… Ludw… Krei…    40 --    ja    07    3     14    00    00   
    #>  5 vg500… DEBK… 2019-10-03     4     9     1 07318 07318 073180… Spey… Krei…    40 --    ja    07    3     18    00    00   
    #>  6 vg500… DEBK… 2019-10-03     4     9     1 07334 07334 073340… Germ… Land…    43 --    ja    07    3     34    00    00   
    #>  7 vg500… DEBK… 2019-10-03     4     9     1 07338 07338 073140… Rhei… Land…    43 --    nein  07    3     38    00    00   
    #>  8 vg500… DEBK… 2019-10-03     4     9     1 08111 08111 081110… Stut… Stad…    41 --    ja    08    1     11    00    00   
    #>  9 vg500… DEBK… 2019-10-03     4     9     1 08115 08115 081150… Böbl… Land…    43 --    ja    08    1     15    00    00   
    #> 10 vg500… DEBK… 2019-10-03     4     9     1 08116 08116 081160… Essl… Land…    43 --    ja    08    1     16    00    00   
    #> # ℹ 54 more rows
    #> # ℹ 7 more variables: sn_g <chr>, fk_s3 <chr>, nuts <chr>, ars_0 <chr>, ags_0 <chr>, wsk <date>,
    #> #   geometry <MULTIPOLYGON [m]>
