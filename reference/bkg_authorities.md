# Regions of authority

Retrieve regions of administrative responsibility for job centers,
employment agencies, offices of employment agencies, regional
directorates of the Federal Employment Agency as well as local,
regional, and higher regional courts.

This function interfaces the `wfs_bzb-open` product of the BKG.

## Usage

``` r
bkg_authorities(
  authority,
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

- authority:

  Type of authority for which to retrieve regions of responsibility.
  Must be one of `"employment_agencies"`, `"employment_offices"`,
  `"job_centers"`, `"directorates"`, `"local_courts"`,
  `"regional_courts"`, or `"higher_regional_courts"`.

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

An sf tibble with multipolygon geometries and the following columns:

- `id`: Identifier of the authority region

- `dst_id`: Identifier of the authority office

- `uebergeord`: Name of the superior authority

- `name`: Name of the authority

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

[`bzb-open`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/bzb-open.pdf)

[`bzb-open` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=8A7C5BC0-F323-43C8-A80B-1B87B0A128C7)

Other non-administrative regions:
[`bkg_area_codes()`](https://jslth.github.io/ffm/reference/bkg_area_codes.md),
[`bkg_grid`](https://jslth.github.io/ffm/reference/bkg_grid.md),
[`bkg_kfz()`](https://jslth.github.io/ffm/reference/bkg_kfz.md),
[`bkg_ror()`](https://jslth.github.io/ffm/reference/bkg_ror.md)

## Examples

``` r
# Get only local courts that are subordinates of the regional court Cottbus
bkg_authorities(
  authority = "local_courts",
  uebergeord %LIKE% "%Cottbus",
  uebergeord %LIKE% "Landgericht%"
)
#> Simple feature collection with 6 features and 5 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4532108 ymin: 3145434 xmax: 4650859 ymax: 3262405
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 6 × 6
#>   id            dest_ge_nr mjbw_ge_nr uebergeord name                   geometry
#>   <chr>         <chr>      <chr>      <chr>      <chr>        <MULTIPOLYGON [m]>
#> 1 gerichte_amt… 121104     22010104   Landgeric… Amts… (((4555550 3212841, 4555…
#> 2 gerichte_amt… 121302     22010106   Landgeric… Amts… (((4553875 3257338, 4554…
#> 3 gerichte_amt… 121101     22010101   Landgeric… Amts… (((4537996 3199068, 4538…
#> 4 gerichte_amt… 121102     22010160   Landgeric… Amts… (((4625944 3222238, 4625…
#> 5 gerichte_amt… 121102     22010102   Landgeric… Amts… (((4622937 3211905, 4623…
#> 6 gerichte_amt… 121105     22010105   Landgeric… Amts… (((4583233 3187580, 4583…
```
