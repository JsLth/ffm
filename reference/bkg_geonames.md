# Geographical objects and endonyms

Get geographic names including toponyms and endonyms. `bkg_geonames`
retrieves the geographical "objects" based on the digital landscape
model (DLM). These objects contain a set of metadata and a national name
identifier (NNID). These NNIDs can be used to join with the endonyms
related to a geographical object (`bkg_endonyms`).

These functions interface the `wfs_gnde` product of the BKG.

## Usage

``` r
bkg_geonames(
  ...,
  names = TRUE,
  ags = FALSE,
  dlm = FALSE,
  status = FALSE,
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  filter = NULL,
  epsg = 3035,
  properties = NULL,
  max = NULL
)

bkg_endonyms(..., filter = NULL, properties = NULL, max = NULL)
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

- names:

  If `TRUE`, includes endonyms of the geographical objects in the output
  using `bkg_endonyms`. Technically, this can be `FALSE`, because the
  endpoint only returns meta data on geographical names by default. If
  this argument is `TRUE`, the output is merged with the endonym table
  requiring an additional request. Defaults to `TRUE`.

- ags:

  If `TRUE`, resolves AGS codes to geographical names using
  [`bkg_ags`](https://jslth.github.io/ffm/reference/bkg_ags.md). Note
  that setting this to `TRUE` requires an additional web request.
  Defaults to `FALSE`.

- dlm:

  If `TRUE`, adds the DLM identifier corresponding to the national name
  identifiers (NNID) of the output using
  [`bkg_dlm`](https://jslth.github.io/ffm/reference/bkg_dlm.md). Note
  that setting this to `TRUE` requires an additional web request.
  Defaults to `FALSE`.

- status:

  If `TRUE`, adds the date of the objects last edit to the output. Note
  that setting this to `TRUE` requires an additional web request.
  Defaults to `FALSE`.

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

- `nnid`: National name identifier

- `landesCode`: Country identifier; 276 is Germany.

- `beschreibung`: Optional details

- `geoLaenge`: Geographical longitude

- `geoBreite`: Geographical latitude

- `hoehe`: Elevation above sea level

- `hoeheger`: Computed elevation above sea level

- `groesse`: Undocumented, but I guess this relates to the suggested
  print size of the labels

- `ewz`: Number of inhabitants

- `ewzger`: Computed number of inhabitants

- `ags`: Official municipality key (Amtlicher Gemeindeschlüssel).
  Related to the ARS but shortened to omit position 6 to 9. Structured
  as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-8: Municipality

- `gemteil`: Whether the place is part of a municipality

- `virtuell`: Whether the place is a real or virtual locality

- `ars`: Territorial code (Amtlicher Regionalschlüssel). The ARS is
  stuctured hierarchically as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-9: Administrative association

  - Position 10-12: Municipality

If `ags = TRUE`, adds the output of
[`bkg_ags`](https://jslth.github.io/ffm/reference/bkg_ags.md). If
`dlm = TRUE`, adds a column `dlm_id` containing identifiers of
[`bkg_dlm`](https://jslth.github.io/ffm/reference/bkg_dlm.md).

`bkg_endonyms` contains the following columns:

- `name`: Name of the geographical object

- `geschlecht`: If applicable, the grammatical gender of a geographical
  name

These are also included in the output of `bkg_geonames` if
`names = TRUE`.

## Details

These functions make use of the GN-DE WFS, just like
[`bkg_ags`](https://jslth.github.io/ffm/reference/bkg_ags.md),
[`bkg_ars`](https://jslth.github.io/ffm/reference/bkg_ags.md), and
[`bkg_area_codes`](https://jslth.github.io/ffm/reference/bkg_area_codes.md).
The infrastructure behind it is actually quite sophisticated and this
function may not live up to these standards. You can use
[`bkg_feature_types`](https://jslth.github.io/ffm/reference/bkg_wfs.md)
and [`bkg_wfs`](https://jslth.github.io/ffm/reference/bkg_wfs.md) to
manually explore the service's endpoints if required.

## Query language

While other WFS interfaces like
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md) allow
querying using CQL or XML, `bkg_geonames` and `bkg_endonyms` (using the
GNDE service) ONLY support XML. This has implications for the allowed
query filters (see
[`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md)).

## See also

[`wfs_gnde` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=f1fe5b66-25d6-44c7-b26a-88625aca9573)

[`wfs_gnde`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/wfs-gnde.pdf)

[`bkg_ags`](https://jslth.github.io/ffm/reference/bkg_ags.md) and
[`bkg_ars`](https://jslth.github.io/ffm/reference/bkg_ags.md) for
geographical names of administrative areas

## Examples

``` r
# Plot geographical objects in Cologne
library(sf)
library(ggplot2)
cgn <- st_sfc(st_point(c(6.956944, 50.938056)), crs = 4326)
cgn <- st_buffer(st_transform(cgn, 3035), dist = 500)

cgn_names <- bkg_geonames(poly = cgn)
st_geometry(cgn_names) <- st_centroid(st_geometry(cgn_names))
cgn_names <- cgn_names[lengths(st_intersects(cgn_names, cgn)) > 0, ]
ggplot(cgn_names) + geom_sf_text(aes(label = name)) + theme_void()
```
