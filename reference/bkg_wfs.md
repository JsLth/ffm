# BKG WFS

Low-level interface to BKG-style web feature services (WFS). This
function is used in all high-level functions of `ffm` that depend on a
WFS, e.g.,
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md).

`bkg_feature_types` lists all available feature types for a given
endpoint.

## Usage

``` r
bkg_wfs(
  type_name,
  endpoint = type_name,
  version = "2.0.0",
  method = NULL,
  format = "application/json",
  layer = NULL,
  epsg = 3035,
  properties = NULL,
  filter = NULL,
  server = sgx_base(),
  ...
)

bkg_feature_types(endpoint, server = sgx_base())
```

## Arguments

- type_name:

  Feature type of the WFS to retrieve. You can use `bkg_feature_types`
  to retrieve a list of feature type names for a given endpoint.

- endpoint:

  Endpoint to interface. Note that `wfs_` is appended and only the rest
  of the product name must be provided. For example, `wfs_vg250` becomes
  `vg250`. Defaults to the value of `type_name`.

- version:

  Service version of the WFS. Usually 2.0.0, but some services still use
  1.0.0 or 1.1.0.

- method:

  HTTP method to use for the request. `GET` requests provide parameters
  using URL queries. Filters must be provided as CQL queries. While this
  is less error-prone, it allows a maximum number of only 2048
  characters. Especially when providing more sophisticated spatial
  queries, `GET` queries are simply not accepted by the services. In
  these cases it makes sense to use `POST` requests instead.

  If `NULL`, the method is inferred from the type of filter query
  provided to `filter` (either XML or CQL). If no filter is provided,
  the method is inferred from `getOption("ffm_query_language")`.

- format:

  Content type of the output. This value heavily depends the endpoint
  queried. Most services allow `application/json` but some only support
  GML outputs. When in doubt, inspect the `GetCapabilities` of the
  target service. Defaults to `"application/json"`.

- layer:

  If `format` specifies a GML output, `layer` specifies which layer from
  the downloaded GML file to read. Only necessary if the GML file
  actually contains multiple layers. Defaults to `NULL`.

- epsg:

  Numeric value giving the EPSG identifier of the coordinate reference
  system (CRS). The EPSG code is automatically formatted in a
  OGC-compliant manner. Note that not all EPSG codes are supported.
  Inspect the `GetCapabilities` of the target service to find out which
  EPSG codes are available. Defaults to EPSG:3035.

- properties:

  Names of columns to include in the output. Defaults to `NULL` (all
  columns).

- filter:

  A WFS filter query (CQL or XML) created by
  [`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md).

- server:

  WFS server domain to use. Defaults to the SGX spatial data center of
  the BKG.

- ...:

  Further parameters passed to the WFS query. In case of `POST`
  requests, additional namespaces that may be necessary to query the
  WFS. Argument names are interpreted as the prefix (e.g. `xmlns:wfs`)
  and argument values as namespace links.

## Value

An sf tibble

## See also

[`bkg_wcs`](https://jslth.github.io/ffm/reference/bkg_wcs.md) for a
low-level WCS interface

[`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md) for
filter constructors

## Examples

``` r
bkg_feature_types("vg5000_0101")
#> # A tibble: 7 × 3
#>   name                   title                   abstract               
#>   <chr>                  <chr>                   <chr>                  
#> 1 vg5000_0101:vg5000_lan Bundesland              Bundesland             
#> 2 vg5000_0101:vg5000_gem Gemeinde                Gemeinde               
#> 3 vg5000_0101:vg5000_li  Grenzlinien             Grenzlinien            
#> 4 vg5000_0101:vg5000_krs Kreis                   Kreis                  
#> 5 vg5000_0101:vg5000_rbz Regierungsbezirk        Regierungsbezirk       
#> 6 vg5000_0101:vg5000_sta Staat                   Staat                  
#> 7 vg5000_0101:vg5000_vwg Verwaltungsgemeinschaft Verwaltungsgemeinschaft

bkg_wfs(
  "vg5000_lan",
  endpoint = "vg5000_0101",
  count = 5,
  properties = "gen",
  epsg = 4326
)[-1]
#> Simple feature collection with 5 features and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 5.866 ymin: 50.3227 xmax: 11.5977 ymax: 55.0571
#> Geodetic CRS:  WGS 84
#> # A tibble: 5 × 2
#>   gen                                                                   geometry
#>   <chr>                                                       <MULTIPOLYGON [°]>
#> 1 Schleswig-Holstein  (((8.7131 54.6776, 8.7068 54.6716, 8.6869 54.6709, 8.6813…
#> 2 Hamburg             (((8.4593 53.9573, 8.4326 53.9449, 8.4203 53.9473, 8.438 …
#> 3 Niedersachsen       (((6.8655 53.5847, 6.8527 53.59, 6.8637 53.5967, 6.8753 5…
#> 4 Bremen              (((8.5625 53.5491, 8.5233 53.592, 8.5099 53.6031, 8.5185 …
#> 5 Nordrhein-Westfalen (((8.9697 51.5058, 8.8907 51.482, 8.921 51.4457, 8.9195 5…

# Filters are created using `wfs_filter()`
bkg_wfs(
  "vg5000_krs",
  endpoint = "vg5000_0101",
  properties = "gen",
  filter = wfs_filter(sn_l == 10)
)[-1]
#> Simple feature collection with 6 features and 1 field
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4057338 ymin: 2892729 xmax: 4132336 ymax: 2951744
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 6 × 2
#>   gen                                                                   geometry
#>   <chr>                                                       <MULTIPOLYGON [m]>
#> 1 Regionalverband Saarbrücken (((4090660 2904942, 4092223 2901447, 4091999 2900…
#> 2 Merzig-Wadern               (((4078929 2926191, 4077635 2927692, 4074266 2926…
#> 3 Neunkirchen                 (((4111255 2917867, 4109992 2917974, 4109230 2919…
#> 4 Saarlouis                   (((4098717 2933513, 4101455 2934901, 4101490 2932…
#> 5 Saarpfalz-Kreis             (((4122248 2915965, 4120329 2917230, 4120301 2920…
#> 6 St. Wendel                  (((4105098 2950381, 4106357 2951744, 4108456 2950…
```
