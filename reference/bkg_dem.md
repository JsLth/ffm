# Digital elevation model

Retrieve the digital elevation model (DEM) for the territory of Germany.

This function interfaces the `wcs_dgm200_inspire` product of the BKG.

## Usage

``` r
bkg_dem(bbox = NULL, interpolation = NULL, epsg = 3035)
```

## Arguments

- bbox:

  An sf geometry or a boundary box vector of the format
  `c(xmin, ymin, xmax, ymax)`. Used as a geometric filter to mask the
  coverage raster. If an sf geometry is provided, coordinates are
  automatically transformed to ESPG:25832 (the default CRS), otherwise
  they are expected to be in EPSG:25832.

- interpolation:

  Interpolation method to preprocess the raster. Can be
  `"nearest-neighbor"`, `"linear"`, or `"cubic"`. Does not seem to work
  currently - despite being listed as a capability of the WCS.

- epsg:

  An EPSG code specifying a coordinate reference system of the output.
  If you're unsure what this means, try running `sf::st_crs(...)$epsg`
  on a spatial object that you are working with. Defaults to 3035.

## Value

A [`SpatRaster`](https://rspatial.github.io/terra/reference/rast.html)
containing elevation data.

## See also

[`wcs_dgm200_inspire`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/dgm200.pdf)

[`wcs_dgm200_inspire` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=B567ABDA-10CD-4335-83EA-8D8D2EA9E6B6)

## Examples

``` r
library(sf)
#> Linking to GEOS 3.12.1, GDAL 3.8.4, PROJ 9.4.0; sf_use_s2() is TRUE

# Elevation around Hanover
han <- st_sfc(st_point(c(9.738611, 52.374444)), crs = 4326)
han <- st_buffer(st_transform(han, 3035), dist = 2000)
dem <- bkg_dem(bbox = han)
terra::plot(dem)
```
