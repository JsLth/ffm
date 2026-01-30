# BKG WCS

Low-level interface to BKG-style web coverage services (WCS). This
function is used in all high-level functions of `ffm` that depend on a
WCS, e.g.,
[`bkg_dem`](https://jslth.github.io/ffm/reference/bkg_dem.md).

## Usage

``` r
bkg_wcs(
  coverage_id,
  endpoint = coverage_id,
  version = "2.0.1",
  method = NULL,
  format = "image/tiff;application=geotiff",
  epsg = 3035,
  interpolation = NULL,
  ...
)
```

## Arguments

- coverage_id:

  Coverage ID. When in doubt, inspect the `GetCapabilities` of the
  service.

- endpoint:

  Endpoint to interface. Note that `wcs_` is appended and only the rest
  of the product name must be provided. For example,
  `wcs_dgm200_inspire` becomes `dgm200_inspire`. Defaults to the value
  of `coverage_id`.

- version:

  Service version of the WCS. Defaults to `2.0.1`.

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
  queried. Defaults to `"image/tiff;application=geotiff"`.

- epsg:

  Numeric value giving the EPSG identifier of the coordinate reference
  system (CRS). The EPSG code is automatically formatted in a
  OGC-compliant manner. Note that not all EPSG codes are supported.
  Inspect the `GetCapabilities` of the target service to find out which
  EPSG codes are available. Defaults to EPSG:3035.

- interpolation:

  Method used to interpolate the coverage raster. Allowed methods depend
  on the capabilities of the WCS.

- ...:

  Further parameters passed to the WFS query. In case of `POST`
  requests, additional namespaces that may be necessary to query the
  WFS. Argument names are interpreted as the prefix (e.g. `xmlns:wfs`)
  and argument values as namespace links.

## Value

A [`SpatRaster`](https://rspatial.github.io/terra/reference/rast.html).

## Examples

``` r
# Boundaries can be provided using two subset arguments
bkg_wcs(
  "dgm200_inspire__EL.GridCoverage",
  endpoint = "dgm200_inspire",
  subset = "E(548282,552280)",
  subset = "N(5800943,5804942)"
)
#> class       : SpatRaster 
#> size        : 20, 20, 1  (nrow, ncol, nlyr)
#> resolution  : 200, 200  (x, y)
#> extent      : 548300, 552300, 5800900, 5804900  (xmin, xmax, ymin, ymax)
#> coord. ref. : ETRS89 / UTM zone 32N (EPSG:25832) 
#> source      : file1f91362b1173 
#> name        : file1f91362b1173 
```
