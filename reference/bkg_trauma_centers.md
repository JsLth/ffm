# Trauma centers

Retrieve data on trauma centers in Germany. A trauma center is a
hospital certified by the German Society for Trauma Surgery (DGU) that
is able to provide maximum care for heavily injured people. Trauma
centers are organized in a hierarchical regional network that ranges
from local to transregional centers.

## Usage

``` r
bkg_trauma_centers(
  ...,
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  filter = NULL,
  epsg = 3035,
  properties = NULL,
  max = NULL
)
```

## Arguments

- ...:

  Used to construct CQL filters. Dot arguments accept an R-like syntax
  that is converted to CQL queries internally. These queries basically
  consist of a property name on the left, an aribtrary vector on the
  right, and an operator that links both sides. If multiple queries are
  provided, they will be chained with `AND`. The following operators and
  their respective equivalents in CQL and XML are supported:

  |           |         |                                  |
  |-----------|---------|----------------------------------|
  | **R**     | **CQL** | **XML**                          |
  | `==`      | `=`     | `PropertyIsEqualTo`              |
  | `!=`      | `<>`    | `PropertyIsNotEqualTo`           |
  | `<`       | `<`     | `PropertyIsLessThan`             |
  | `>`       | `>`     | `PropertyIsGreaterThan`          |
  | `>=`      | `>=`    | `PropertyIsGreaterThanOrEqualTo` |
  | `<=`      | `<=`    | `PropertyIsLessThanOrEqualTo`    |
  | `%LIKE%`  | `LIKE`  | `PropertyIsLike`                 |
  | `%ILIKE%` | `ILIKE` |                                  |
  | `%in%`    | `IN`    | `PropertyIsEqualTo` and `Or`     |

  To construct more complex queries, you can use the `filter` argument
  to pass CQL queries directly. Also note that you can switch between
  CQL and XML queries using `options(ffm_query_language = "xml")`. See
  also
  [`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md).

- bbox:

  An sf geometry or a boundary box vector of the format
  `c(xmin, ymin, xmax, ymax)`. Used as a geometric filter to include
  only those geometries that relate to `bbox` according to the predicate
  specified in `predicate`. If an sf geometry is provided, coordinates
  are automatically transformed to ESPG:25832 (the default CRS),
  otherwise they are expected to be in EPSG:25832.

- poly:

  An sf geometry. Used as a geometric filter to include only those
  geometries that relate to `poly` according to the predicate specified
  in `predicate`. Coordinates are automatically transformed to
  ESPG:25832 (the default CRS).

- predicate:

  A spatial predicate that is used to relate the output geometries with
  the object specified in `bbox` or `poly`. For example, if
  `predicate = "within"`, and `bbox` is specified, returns only those
  geometries that lie within `bbox`. Can be one of `"equals"`,
  `"disjoint"`, `"intersects"`, `"touches"`, `"crosses"`, `"within"`,
  `"contains"`, `"overlaps"`, `"relate"`, `"dwithin"`, or `"beyond"`.
  Defaults to `"intersects"`.

- filter:

  A character string containing a valid CQL or XML filter. This string
  is appended to the query constructed through `...`. Use this argument
  to construct more complex filters. Defaults to `NULL`.

- epsg:

  An EPSG code specifying a coordinate reference system of the output.
  If you're unsure what this means, try running `sf::st_crs(...)$epsg`
  on a spatial object that you are working with. Defaults to 3035.

- properties:

  Vector of columns to include in the output.

- max:

  Maximum number of results to return.

## Value

A dataframe containing the following columns:

- `name`: Geographical name of the POI

- `gemeinde`: Municipality name

- `verwaltung`: Administrative association name

- `kreis`: District name

- `regierungs`: Government region name

- `bundesland`: Federal state name

- `poi_id`: Unique primary key of a point of interest

- `tz_nummer`: Unique primary key of the trauma center

- `strasse`: Street

- `hn`: House number

- `plz`: Zip code

- `ort`: Place name

- `netwerk`: Name of the regional trauma center network

- `abteilung`: Name of the medical department

- `typ`: Type of trauma center. Can be:

  - LTZ: local trauma center

  - RTZ: regional trauma center

  - ÜTZ: transregional trauma center

## Query language

By default, WFS requests use CQL (Contextual Query Language) queries for
simplicity. CQL queries only work together with GET requests. This means
that when the URL is longer than 2048 characters, they fail. While POST
requests are much more flexible and able to accommodate long queries,
XML is really a pain to work with and I'm not confident in my approach
to construct XML queries. You can control whether to send GET or POST
requests by setting `options(ffm_query_language = "XML")` or
`options(ffm_query_language = "CQL")`.

## See also

[`wfs_poi_open`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf)

[`wfs_poi_open` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA)

Other points of interest:
[`bkg_airports()`](https://jslth.github.io/ffm/reference/bkg_airports.md),
[`bkg_crossings()`](https://jslth.github.io/ffm/reference/bkg_crossings.md),
[`bkg_heliports()`](https://jslth.github.io/ffm/reference/bkg_heliports.md),
[`bkg_kilometrage()`](https://jslth.github.io/ffm/reference/bkg_kilometrage.md),
[`bkg_seaports()`](https://jslth.github.io/ffm/reference/bkg_seaports.md),
[`bkg_stations()`](https://jslth.github.io/ffm/reference/bkg_stations.md)

## Examples

``` r
# Get only trauma centers specializing on orthopedics
bkg_trauma_centers(abteilung %LIKE% "%orthopäd%")
#> Simple feature collection with 21 features and 16 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4062805 ymin: 2708345 xmax: 4488060 ymax: 3396631
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 21 × 17
#>    poi_id     tz_nummer name  strasse hn    plz   ort   netzwerk abteilung typ  
#>    <chr>      <chr>     <chr> <chr>   <chr> <chr> <chr> <chr>    <chr>     <chr>
#>  1 DEBKGPOI0… TZ-00268  Städ… Moltke… 90    76133 Karl… TraumaN… Klinik f… ÜTZ  
#>  2 DEBKGPOI0… TZ-00181  Klin… Auenst… 6     82467 Garm… TraumaN… Abteilun… RTZ  
#>  3 DEBKGPOI0… TZ-00701  Kran… Simons… 55    91207 Lauf… TraumaN… Unfallch… LTZ  
#>  4 DEBKGPOI0… TZ-00368  HELI… Steine… 5     81241 Münc… TraumaN… Klinik f… RTZ  
#>  5 DEBKGPOI0… TZ-00417  Sana… Langer… 12    91257 Pegn… TraumaN… Unfallch… LTZ  
#>  6 DEBKGPOI0… TZ-00456  Klin… Ansbac… 131   91541 Roth… TraumaN… Unfall- … LTZ  
#>  7 DEBKGPOI0… TZ-00675  Askl… Tangst… 400   22417 Hamb… TraumaN… Unfall- … ÜTZ  
#>  8 DEBKGPOI0… TZ-00253  Krei… Lieben… 1     34369 Hofg… TraumaN… Chirurgi… LTZ  
#>  9 DEBKGPOI0… TZ-00271  Elis… Weinbe… 7     34117 Kass… TraumaN… Abteilun… LTZ  
#> 10 DEBKGPOI0… TZ-00314  St.V… Auf de… NA    65549 Limb… TraumaN… Unfall- … RTZ  
#> # ℹ 11 more rows
#> # ℹ 7 more variables: ars <chr>, gemeinde <chr>, verwaltung <chr>, kreis <chr>,
#> #   regierungs <chr>, bundesland <chr>, geometry <POINT [m]>

# Get only local trauma centers
bkg_trauma_centers(typ == "LTZ")
#> Simple feature collection with 284 features and 16 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4044367 ymin: 2724853 xmax: 4659794 ymax: 3486644
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 284 × 17
#>    poi_id     tz_nummer name  strasse hn    plz   ort   netzwerk abteilung typ  
#>    <chr>      <chr>     <chr> <chr>   <chr> <chr> <chr> <chr>    <chr>     <chr>
#>  1 DEBKGPOI0… TZ-00039  Zoll… Tübing… 30    72336 Bali… TraumaN… Klinik f… LTZ  
#>  2 DEBKGPOI0… TZ-00619  Krei… Eduard… 6     75365 Calw  TraumaN… Klinik f… LTZ  
#>  3 DEBKGPOI0… TZ-00621  Land… Garten… 21    74564 Crai… TraumaN… Orthopäd… LTZ  
#>  4 DEBKGPOI0… TZ-00708  Kran… Rutesh… 50    71229 Leon… TraumaN… Klinik f… LTZ  
#>  5 DEBKGPOI0… TZ-00717  Ther… Basser… 1     68165 Mann… TraumaN… Unfallch… LTZ  
#>  6 DEBKGPOI0… TZ-00357  Neck… Knopfw… 1     74821 Mosb… TraumaN… Klinik f… LTZ  
#>  7 DEBKGPOI0… TZ-00358  RKH … Herman… 34    75417 Mühl… TraumaN… Sektion … LTZ  
#>  8 DEBKGPOI0… TZ-00382  Klin… Röntge… 20    72202 Nago… TraumaN… Klinik f… LTZ  
#>  9 DEBKGPOI0… TZ-00733  medi… Hedelf… 166   73760 Ostf… TraumaN… Klinik f… LTZ  
#> 10 DEBKGPOI0… TZ-00747  HELI… Kranke… 30    78628 Rott… TraumaN… Unfallch… LTZ  
#> # ℹ 274 more rows
#> # ℹ 7 more variables: ars <chr>, gemeinde <chr>, verwaltung <chr>, kreis <chr>,
#> #   regierungs <chr>, bundesland <chr>, geometry <POINT [m]>

if (requireNamespace("ggplot2")) {
  library(ggplot2)
  centers <- bkg_trauma_centers()
  ggplot() +
  geom_sf(
    data = centers[centers$typ %in% "LTZ",],
    size = 1,
    color = "lightblue1"
  ) +
  geom_sf(
    data = centers[centers$typ %in% "RTZ",],
    size = 2,
    color = "lightblue3"
  ) +
  geom_sf(
    data = centers[centers$typ %in% "ÜTZ",],
    size = 3,
    color = "lightblue4"
  ) +
  theme_void()
}
```
