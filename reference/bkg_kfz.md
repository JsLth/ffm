# Vehicle registration plates

Retrieve motor vehicle registration plate regions in Germany.
Registration plate regions are discerned by their area code
(*Unterscheidungszeichen*) which indicate the place where a vehicle was
registered. These regions partially overlap with districts but are not
entirely identical.

This function interfaces the `wfs_kfz250` product of the BKG.

## Usage

``` r
bkg_kfz(
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

An sf dataframe with multipolygon geometries and the following columns:

- `debkgid`: Identifier in the digital landscape model DLM250

- `nnid`: National name identifier

- `name`: Name of the geographical object

- `ars`: Territorial code (Amtlicher Regionalschlüssel). The ARS is
  stuctured hierarchically as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-9: Administrative association

  - Position 10-12: Municipality

- `oba`: Name of the ATKIS object type

- `kfz`: Vehicle registration area code, comma-separated in case of
  multiple codes

- `geola`: Geographical longitude

- `geobr`: Geographical latitude

- `gkre`: Gauß-Krüger easting

- `gkho`: Gauß-Krüger northing

- `utmre`: UTM easting

- `utmho`: UTM northing

## See also

[`kfz250`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/kfz250.pdf)

[`kfz250` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=171BF073-C17B-47F7-891F-F27E5EDD7643)

[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md)

Other non-administrative regions:
[`bkg_area_codes()`](https://jslth.github.io/ffm/reference/bkg_area_codes.md),
[`bkg_authorities()`](https://jslth.github.io/ffm/reference/bkg_authorities.md),
[`bkg_grid`](https://jslth.github.io/ffm/reference/bkg_grid.md),
[`bkg_ror()`](https://jslth.github.io/ffm/reference/bkg_ror.md)

## Examples

``` r
library(ggplot2)

kfz <- bkg_kfz(ars %LIKE% "053%")
ggplot(kfz) +
  geom_sf(fill = NA) +
  geom_sf_text(aes(label = kfz)) +
  theme_void()
```
