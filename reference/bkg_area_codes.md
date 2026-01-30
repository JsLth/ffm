# Area code regions

Retrieves area code regions (*Vorwahlgebiete*) in Germany. Area code
regions are based on the number of registered telephone numbers.

This function interfaces the `wfs_gnde` product of the BKG.

## Usage

``` r
bkg_area_codes(
  ...,
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  filter = NULL,
  epsg = 3035,
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

- max:

  Maximum number of results to return.

## Value

An sf dataframe containing polygon geometries and the area code
(`vorwahl`) associated with the region.

## Query language

While other WFS interfaces like
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md) allow
querying using CQL or XML, `bkg_area_codes` ONLY supports XML. This has
implications for the allowed query filters (see
[`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md)).

## See also

[`wfs_gnde` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=f1fe5b66-25d6-44c7-b26a-88625aca9573)

[`wfs_gnde`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/wfs-gnde.pdf)

[`bkg_geonames`](https://jslth.github.io/ffm/reference/bkg_geonames.md)
and
[`bkg_endonyms`](https://jslth.github.io/ffm/reference/bkg_geonames.md)
for geographical names

Other non-administrative regions:
[`bkg_authorities()`](https://jslth.github.io/ffm/reference/bkg_authorities.md),
[`bkg_grid`](https://jslth.github.io/ffm/reference/bkg_grid.md),
[`bkg_kfz()`](https://jslth.github.io/ffm/reference/bkg_kfz.md),
[`bkg_ror()`](https://jslth.github.io/ffm/reference/bkg_ror.md)

## Examples

``` r
vorwahlen <- bkg_area_codes(vorwahl %LIKE% "0215%")
plot(vorwahlen$geometry)
```
