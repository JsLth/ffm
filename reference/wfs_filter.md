# WFS filters

Utility functions to construct XML or CQL queries. These functions are
the backend of the `filter` argument in the filter capabilities of all
`ffm` functions that interact with a WFS (e.g.,
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md),
[`bkg_clc`](https://jslth.github.io/ffm/reference/bkg_clc.md) or
`bkb_geonames`).

## Usage

``` r
wfs_filter(
  ...,
  filter = NULL,
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  geom_property = "geom",
  default_crs = 25832,
  lang = NULL
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
  also `wfs_filter`.

- filter:

  A character string containing a valid CQL or XML filter. This string
  is appended to the query constructed through `...`. Use this argument
  to construct more complex filters. Defaults to `NULL`.

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

- geom_property:

  Name of the geometry property included in the WFS. In most cases, this
  is `"geom"`, but there are some exceptions.

- default_crs:

  A WFS defines a default CRS in which coordinates for spatial filtering
  have to be provided. For BKG services, this is usually EPSG:25832. All
  sf objects provided through `bbox` or `poly` are first transformed to
  this CRS before creating the query.

- lang:

  Query language to use for constructing the query. One of `"cql"` and
  `"xml"`. By default, almost all `ffm` functions use CQL because it is
  simpler and less prone to errors. However, CQL is limited in terms of
  query size. Especially when providing a `poly`, URLs can become so
  long that the WFS server will decline them. XML can be a valid
  alternative to construct large queries. Additionally, some services
  like the one used by
  [`bkg_geonames`](https://jslth.github.io/ffm/reference/bkg_geonames.md)
  only support XML. If `NULL`, defaults to
  `getOption("ffm_query_language")`.

## Value

A CQL query or an XML query depending on the `lang` argument.

## Examples

``` r
# CQL and XML support mostly the same things
wfs_filter(ags %LIKE% "05%", lang = "cql")
#> ags LIKE '05%' 
wfs_filter(ags %LIKE% "05%", lang = "xml")
#> <fes:Filter>
#>   <fes:PropertyIsLike wildCard="%" singleChar="_" escapeChar="\">
#>     <fes:ValueReference>ags</fes:ValueReference>
#>     <fes:Literal>05%</fes:Literal>
#>   </fes:PropertyIsLike>
#> </fes:Filter> 

bbox <- c(xmin = 5, ymin = 50, xmax = 7, ymax = 52)
wfs_filter(bbox = bbox, lang = "cql")
#> intersects(geom, POLYGON ((5 50, 7 50, 7 52, 5 52, 5 50))) 
wfs_filter(bbox = bbox, lang = "xml")
#> <fes:Filter>
#>   <fes:Intersects>
#>     <fes:ValueReference>geom</fes:ValueReference>
#>     <gml:Polygon srsName="urn:ogc:def:crs:EPSG::25832" gml:id="file1f916b1e5497.geom.0">
#>       <gml:exterior>
#>         <gml:LinearRing>
#>           <gml:posList>5 50 7 50 7 52 5 52 5 50</gml:posList>
#>         </gml:LinearRing>
#>       </gml:exterior>
#>     </gml:Polygon>
#>   </fes:Intersects>
#> </fes:Filter> 

# Using `filter`, more complex queries can be built
wfs_filter(ars %LIKE% "%0", filter = "regierungs NOT IS NULL")
#> ars LIKE '%0' AND regierungs NOT IS NULL 

wfs_filter(
  filter = "<fes:Not>
    <fes:PropertyIsNull>
      <fes:ValueReference>aussprache</fes:ValueReference>
    </fes:PropertyIsNull>
  </fes:Not>",
  lang = "xml"
)
#> <fes:Filter>
#>   <fes:Not>
#>     <fes:PropertyIsNull>
#>       <fes:ValueReference>aussprache</fes:ValueReference>
#>     </fes:PropertyIsNull>
#>   </fes:Not>
#> </fes:Filter> 
```
