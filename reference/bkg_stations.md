# Stations and stops

Retrieve data on public transport stations and stops in Germany.
Stations and stops are hierarchical. This means that stations represent
the structural facilities as hierarchically superior objects and stops
are hierarchically inferiors parts of a station (e.g., a single platform
at a bus stop).

## Usage

``` r
bkg_stations(
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

A dataframe with the following columns:

- `name`: Geographical name of the POI

- `gemeinde`: Municipality name

- `verwaltung`: Administrative association name

- `kreis`: District name

- `regierungs`: Government region name

- `bundesland`: Federal state name

- `stop_id`: Identifier of the station or stop

- `parent_st`: Identifier of the parent station if applicable

- `verkehrsm`: Vehicle used at the station, comma-separated and sorted
  alphabetically

- `art`: Hierarchical position of a station. Can be:

  - Station: A physical structure and hierarchically superior

  - Haltestelle: Part of a structure and hierarchically inferior

- `tag_f_awo`: Mean departures per day in a work week

- `tag_f_wo`: Mean departures per day in a full week

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
[`bkg_trauma_centers()`](https://jslth.github.io/ffm/reference/bkg_trauma_centers.md)

## Examples

``` r
# Get all long-distance train stations
bkg_stations(verkehrsm %LIKE% "%Fernzug%", art == "Station")
#> Simple feature collection with 137 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4118289 ymin: 2699754 xmax: 4630711 ymax: 3532670
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 137 × 14
#>    stop_id     name  parent_st verkehrsm art   tag_f_awo tag_f_wo ars   gemeinde
#>    <chr>       <chr> <chr>     <chr>     <chr>     <int>    <int> <chr> <chr>   
#>  1 de:08136:1… Aale… NA        Fernzug,… Stat…       154      151 0813… Aalen   
#>  2 de:08211:1… Bade… NA        Bus, Fer… Stat…       613      551 0821… Baden-B…
#>  3 de:08115:7… Böbl… NA        Bus, Fer… Stat…       985      879 0811… Böbling…
#>  4 de:08115:4… Bond… NA        Bus, Fer… Stat…       195      172 0811… Bondorf 
#>  5 de:08127:2… Crai… NA        Fernzug,… Stat…        81       78 0812… Crailsh…
#>  6 de:08136:2… Ellw… NA        Fernzug,… Stat…        51       52 0813… Ellwang…
#>  7 de:08335:6… Enge… NA        Bus, Fer… Stat…       232      204 0833… Engen   
#>  8 de:08237:7… Euti… NA        Bus, Fer… Stat…       123      104 0823… Eutinge…
#>  9 de:08115:5… Gäuf… NA        Bus, Fer… Stat…       147      128 0811… Gäufeld…
#> 10 de:08117:1… Göpp… NA        Bus, Fer… Stat…       791      684 0811… Göpping…
#> # ℹ 127 more rows
#> # ℹ 5 more variables: verwaltung <chr>, kreis <chr>, regierungs <chr>,
#> #   bundesland <chr>, geometry <POINT [m]>

# Get all platforms of long-distance train stations
bkg_stations(verkehrsm %LIKE% "%Fernzug%", art == "Haltestelle")
#> Simple feature collection with 543 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4045363 ymin: 2699754 xmax: 4630650 ymax: 3534754
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 543 × 14
#>    stop_id     name  parent_st verkehrsm art   tag_f_awo tag_f_wo ars   gemeinde
#>    <chr>       <chr> <chr>     <chr>     <chr>     <int>    <int> <chr> <chr>   
#>  1 de:08136:1… Aale… de:08136… Fernzug,… Halt…        43       42 0813… Aalen   
#>  2 de:08136:1… Aale… de:08136… Fernzug,… Halt…        33       35 0813… Aalen   
#>  3 ::stop0162… Aale… de:08136… Bus, Fer… Halt…        NA       NA 0813… Aalen   
#>  4 de:08211:1… Bade… de:08211… Fernzug,… Halt…        25       23 0821… Baden-B…
#>  5 de:08211:1… Bade… de:08211… Fernzug,… Halt…        27       25 0821… Baden-B…
#>  6 de:08211:1… Bahn… de:08211… Fernzug,… Halt…        50       47 0821… Baden-B…
#>  7 de:08115:7… Böbl… de:08115… Fernzug,… Halt…        61       56 0811… Böbling…
#>  8 de:08115:7… Böbl… de:08115… Fernzug,… Halt…       103       98 0811… Böbling…
#>  9 de:08115:4… Bond… de:08115… Fernzug,… Halt…        45       41 0811… Bondorf 
#> 10 de:08115:4… Bond… de:08115… Fernzug,… Halt…        53       48 0811… Bondorf 
#> # ℹ 533 more rows
#> # ℹ 5 more variables: verwaltung <chr>, kreis <chr>, regierungs <chr>,
#> #   bundesland <chr>, geometry <POINT [m]>

# Get all stops with high traffic
bkg_stations(tag_f_awo > 1000, art == "Station")
#> Simple feature collection with 463 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4042093 ymin: 2751521 xmax: 4584718 ymax: 3520149
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 463 × 14
#>    stop_id     name  parent_st verkehrsm art   tag_f_awo tag_f_wo ars   gemeinde
#>    <chr>       <chr> <chr>     <chr>     <chr>     <int>    <int> <chr> <chr>   
#>  1 de:08426:6… Bibe… NA        Bus, Zug… Stat…      1017      849 0842… Biberac…
#>  2 de:08116:2… Essl… NA        Bus       Stat…      1025      909 0811… Essling…
#>  3 de:08311:6… Frei… NA        Bus, Hoc… Stat…      1538     1379 0831… Freibur…
#>  4 de:08221:1… Heid… NA        Bus       Stat…      1239     1126 0822… Heidelb…
#>  5 de:08221:1… Heid… NA        Bus, Str… Stat…      1614     1484 0822… Heidelb…
#>  6 de:08221:1… Heid… NA        Bus, Hoc… Stat…      1999     1807 0822… Heidelb…
#>  7 de:08221:1… Heid… NA        Bus       Stat…      1274     1148 0822… Heidelb…
#>  8 de:08221:1… Heid… NA        Bus       Stat…      1234     1119 0822… Heidelb…
#>  9 de:08221:1… Heid… NA        Bus, Str… Stat…      1262     1145 0822… Heidelb…
#> 10 de:08121:1… Heil… NA        Bus, S-B… Stat…      1030      908 0812… Heilbro…
#> # ℹ 453 more rows
#> # ℹ 5 more variables: verwaltung <chr>, kreis <chr>, regierungs <chr>,
#> #   bundesland <chr>, geometry <POINT [m]>

# Get all bus stops with low traffic
bkg_stations(tag_f_awo < 1, verkehrsm %LIKE% "%Bus%", art == "Station")
#> Simple feature collection with 428 features and 13 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4051619 ymin: 2713127 xmax: 4640909 ymax: 3504994
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 428 × 14
#>    stop_id     name  parent_st verkehrsm art   tag_f_awo tag_f_wo ars   gemeinde
#>    <chr>       <chr> <chr>     <chr>     <chr>     <int>    <int> <chr> <chr>   
#>  1 de:08136:1… Ebna… NA        Bus       Stat…         0        2 0813… Aalen   
#>  2 de:08417:3… Onst… NA        Bus       Stat…         0        1 0841… Albstadt
#>  3 de:08417:3… Onst… NA        Bus       Stat…         0        2 0841… Albstadt
#>  4 de:08119:6… Klei… NA        Bus       Stat…         0        2 0811… Aspach  
#>  5 de:08119:5… Lipp… NA        Bus       Stat…         0        2 0811… Auenwald
#>  6 de:08425:2… Blau… NA        Bus       Stat…         0        1 0842… Blaubeu…
#>  7 de:08425:2… Blau… NA        Bus       Stat…         0        1 0842… Blaubeu…
#>  8 de:08115:4… Böbl… NA        Bus       Stat…         0        1 0811… Böbling…
#>  9 de:08337:6… Bonn… NA        Bus       Stat…         0        1 0833… Bonndor…
#> 10 de:08337:5… Günd… NA        Bus       Stat…         0        1 0833… Bonndor…
#> # ℹ 418 more rows
#> # ℹ 5 more variables: verwaltung <chr>, kreis <chr>, regierungs <chr>,
#> #   bundesland <chr>, geometry <POINT [m]>
```
