# Heliports

Get heliports in Germany. Based on data from third-party providers and
image classification of aerial imagery.

## Usage

``` r
bkg_heliports(
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

- `code`: Identifier of the heliport

- `name_bkg`: Name of the landing site according to BKG

- `name_dfs`: Name of the landing size according to Deutsche
  Flugsicherung (DFS)

- `airport_pk`: Identifier according to the LFS aviation manual

- `befestigun`: Pavement type of the landing site. Can be:

  - befestigt: paved

  - teilweise befestigt: partially paved

  - unbefestigt: unpaved

- `kennzeich`: Marking of the landing size. Can be:

  - gekennzeichnet: marked

  - nicht gekennzeichnet: not marked

- `lage`: Location of the landing size. Can be:

  - D: Roof

  - F: Field

  - PG: Platform next to a hospital

  - W: Pasture

  - LP: Landing site

  - PP: Parking lot

  - LP / W: Paved landing size on pasture

  - F / W: Field or pasture

  - LP / Str.: Landing size next to a street

- `typ`: Type of heliport. Can be:

  - H: Heliport

  - HH: Heliport at a hospital

  - MH: Military heliport

- `typ2`: Additional heliport type for landing sites with an air rescue
  station. Can be:

  - HRLS: Helicopter air rescue station

  - ITH: Intensive transport helicopter

- `betreiber`: Operator of the heliport

- `helikopter`: Name of the helicopter belonging to the air rescue
  station

- `status`: Whether the point geometry was edited by the BKG. Can be:

  - Original: not edited

  - Verschoben: moved

  - neu: newly added

- `quelle`: Source of the information. Can be:

  - BKG: Own research by the BKG

  - DFS-Liste: Provided by DFS

  - LBA-Liste: Provided by the Federal Aviation Office (LBA)

  - MHW: Provided by the Medical Disaster Relief Organization (MHW)

  - RTH.Info: Provided by rth.info

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
[`bkg_kilometrage()`](https://jslth.github.io/ffm/reference/bkg_kilometrage.md),
[`bkg_seaports()`](https://jslth.github.io/ffm/reference/bkg_seaports.md),
[`bkg_stations()`](https://jslth.github.io/ffm/reference/bkg_stations.md),
[`bkg_trauma_centers()`](https://jslth.github.io/ffm/reference/bkg_trauma_centers.md)

## Examples

``` r
# Get only military heliports
bkg_heliports(typ == "MH")
#> Simple feature collection with 4 features and 19 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4143804 ymin: 2919793 xmax: 4544198 ymax: 3277696
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 4 × 20
#>   code  name_bkg      name_dfs airport_pk befestigun kennzeich lage  typ   typ2 
#>   <chr> <chr>         <chr>    <chr>      <chr>      <chr>     <chr> <chr> <chr>
#> 1 LR018 Bundeswehr (… Nieders… NA         befestigt  gekennze… LP    MH    HLRS 
#> 2 LR030 Hubschrauber… Berlin-… NA         befestigt  gekennze… LP    MH    NA   
#> 3 ETED  Kaiserslaute… Kaisers… 7789       befestigt  nicht ge… LP    MH    NA   
#> 4 ETIY  Landstuhl Ho… LANDSTU… 7790       befestigt  gekennze… LP    MH    NA   
#> # ℹ 11 more variables: betreiber <chr>, helikopter <chr>, status <chr>,
#> #   quelle <chr>, ars <chr>, gemeinde <chr>, verwaltung <chr>, kreis <chr>,
#> #   regierungs <chr>, bundesland <chr>, geometry <POINT [m]>

# Get only rooftop heliports
bkg_heliports(lage == "D")
#> Simple feature collection with 197 features and 19 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: 4049323 ymin: 2708512 xmax: 4668344 ymax: 3520701
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 197 × 20
#>    code   name_bkg    name_dfs airport_pk befestigun kennzeich lage  typ   typ2 
#>    <chr>  <chr>       <chr>    <chr>      <chr>      <chr>     <chr> <chr> <chr>
#>  1 LR001  BG Kliniku… Berlin … NA         befestigt  gekennze… D     HH    HLRS 
#>  2 ED1574 Universitä… Würzburg 7266       befestigt  gekennze… D     HH    NA   
#>  3 ED1577 Helios Kli… Krefeld… 7269       befestigt  gekennze… D     HH    NA   
#>  4 ED1582 Herz- und … BAD OEY… 7274       befestigt  gekennze… D     HH    NA   
#>  5 ED1588 Klinikum B… Bremerh… 7281       befestigt  gekennze… D     HH    NA   
#>  6 ED1590 Universitä… Düsseld… 7284       befestigt  gekennze… D     HH    NA   
#>  7 ED1596 BG Unfallk… Frankfu… 7290       befestigt  gekennze… D     HH    NA   
#>  8 ED1597 Klinikum F… Fulda K… 7291       befestigt  gekennze… D     HH    HLRS 
#>  9 ED1598 Klinikum G… GARMISC… 7292       befestigt  gekennze… D     HH    NA   
#> 10 ED1604 Medizinisc… HANNOVE… 7298       befestigt  gekennze… D     HH    HLRS 
#> # ℹ 187 more rows
#> # ℹ 11 more variables: betreiber <chr>, helikopter <chr>, status <chr>,
#> #   quelle <chr>, ars <chr>, gemeinde <chr>, verwaltung <chr>, kreis <chr>,
#> #   regierungs <chr>, bundesland <chr>, geometry <POINT [m]>
```
