# Seaports

Retrieve seaports to the North and Baltic Sea in Northern Germany.

## Usage

``` r
bkg_seaports(
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

- `betreiber`: Operator of the seaport

- `homepage`: Homepage of the operator

- `typ`: Type of seaport. Can be "Seehafen" (seaport) or "See- und
  Binnenhafen" (sea and inland port)

- `art`: Type of seaport by freight. Can be:

  - Güter: Goods

  - Güter und Passagiere: Goods and passengers

  - Passagiere: Passengers

- `quelle`: Source of the information. Can be:

  - BSH: Federal Maritime and Hydrographic Agency

  - MarWiLo: Maritime Wirtschaft & Logistik

  - ZDS-Seehäfen: Zentralverband der deutschen Seehafenbetriebe

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
[`bkg_stations()`](https://jslth.github.io/ffm/reference/bkg_stations.md),
[`bkg_trauma_centers()`](https://jslth.github.io/ffm/reference/bkg_trauma_centers.md)

## Examples

``` r
# Get only seaports that co-function as inland ports
ports <- bkg_seaports(typ == "See- und Binnenhafen")
germany <- bkg_admin(level = "sta", scale = "5000", gf == 9)
plot(germany$geometry)
plot(ports$geometry, add = TRUE)
```
