# Official keys

Retrieve geographical names associated with official municipality keys
and regional keys. To retrieve their polygon geometries, see
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md).

These functions interface the `wfs_gnde` product of the BKG.

## Usage

``` r
bkg_ags(..., filter = NULL, properties = NULL, max = NULL)

bkg_ars(..., filter = NULL, properties = NULL, max = NULL)
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

- filter:

  A character string containing a valid CQL or XML filter. This string
  is appended to the query constructed through `...`. Use this argument
  to construct more complex filters. Defaults to `NULL`.

- properties:

  Vector of columns to include in the output.

- max:

  Maximum number of results to return.

## Value

A dataframe containing the respective identifier and geographical names
related to their state, government region, district and municipality.
`bkg_ars` additionally returns the name of the administrative
association.

## Query language

While other WFS interfaces like
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md) allow
querying using CQL or XML, `bkg_ags` and `bkg_ars` (using the GNDE
service) ONLY support XML. This has implications for the allowed query
filters (see
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

## Examples

``` r
# Either get geographical names for identifiers
bkg_ars(ars == "01")
#> # A tibble: 1 × 6
#>   ars   bundesland        regierungsbezirk kreis verwaltungsgemeinsch…¹ gemeinde
#>   <chr> <chr>             <chr>            <chr> <chr>                  <chr>   
#> 1 01    Schleswig-Holste… NA               NA    NA                     NA      
#> # ℹ abbreviated name: ¹​verwaltungsgemeinschaft

# ... or identifiers for geographical names
bkg_ars(gemeinde == "Köln")
#> # A tibble: 1 × 6
#>   ars          bundesland regierungsbezirk kreis verwaltungsgemeinsch…¹ gemeinde
#>   <chr>        <chr>      <chr>            <chr> <chr>                  <chr>   
#> 1 053150000000 Nordrhein… Köln             Köln  Köln                   Köln    
#> # ℹ abbreviated name: ¹​verwaltungsgemeinschaft
```
