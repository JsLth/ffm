# INSPIRE grids

Retrieve geometries of INSPIRE-compliant grid geometries (also called
"GeoGitter"). `bkg_grid_fast()` is much faster than `bkg_grid_full()` by
downloading heavily compressed versions grids. This happens at the cost
of data richness as `bkg_grid_fast()` only contains the geometries and
nothing else. Note that the `arrow` package needs to be installed to use
`bkg_grid_fast()`.

Note that the output contains point geometries. Most of the times, you
want to work with rasters instead. To convert a given object `out`, type
the following (`terra` package required):

    terra::rast(out)

These functions interface the `GeoGitter` product of the BKG.

## Usage

``` r
bkg_grid_fast(
  year = c("2019", "2018", "2017", "2015"),
  resolution = c("100km", "10km", "5km", "1km", "250m", "100m"),
  timeout = 600,
  update_cache = FALSE
)

bkg_grid_full(
  year = "latest",
  resolution = c("100km", "10km", "5km", "1km", "250m", "100m"),
  timeout = 600,
  update_cache = FALSE
)
```

## Arguments

- year:

  Version of the grid. Can be `"2015"`, `"2017"`, `"2018"` or `"2019"`.
  For `bkg_grid_fast`, `"latest"` downloads the latest version of the
  grid.

- resolution:

  Cell size of the grid. Can be `"100m"`, `"250m"`, `"1km"`, `"5km"`,
  `"10km"`, or `"100km"`.

- timeout:

  Timeout value for the data download passed to
  [`req_timeout`](https://httr2.r-lib.org/reference/req_timeout.html).
  Adjust this if your internet connection is slow or you are downloading
  larger datasets.

- update_cache:

  By default, downloaded files are cached in the
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) directory of R.
  When downloading the same data again, the data is not downloaded but
  instead taken from the cache. Sometimes this can be not the desired
  behavior. If you want to overwrite the cache, pass `TRUE`. Defaults to
  `FALSE`, i.e. always adopt the cache if possible.

## Value

`bkg_grid_fast` returns an sf dataframe with point geometries and no
features. `bkg_grid_full` also returns point geometries but with the
following additional features:

- `x_sw`: X coordinate of the South-West corner of a grid cell

- `y_sw`: Y coordinate of the South-West corner of a grid cell

- `f_staat`: State area in the grid cell in square meters

- `f_land`: Land area in the grid cell in square meters

- `f_wasser`: Water area in the grid cell in square meters

- `p_staat`: Share of state area in the grid cell

- `p_land`: Share of land area in the grid cell

- `p_wasser`: Share of water area in the grid cell

- `ags`: Official municipality key (Amtlicher Gemeindeschlüssel).
  Related to the ARS but shortened to omit position 6 to 9. Structured
  as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-8: Municipality

Note that `ags` is only included for resolutions `"100m"` and `"250m"`

## Details

The following table gives a rough idea of how much less data
`bkg_grid_fast` needs to download for each resolution compared to
`bkg_grid_full`.

|          |          |            |
|----------|----------|------------|
| **Size** | **fast** | **full**   |
| 100km    | 0.78 kB  | 933 kB     |
| 10km     | 2.68 kB  | 1,015 kB   |
| 5km      | 3.53 kB  | 1,253 kB   |
| 1km      | 28.7 kB  | 5,249 kB   |
| 500m     | 133 kB   | 15,902 kB  |
| 250m     | 289 kB   | 53,900 kB  |
| 100m     | 1,420 kB | 291,000 kB |

## See also

[GeoGitter
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/geogitter.pdf)

[GeoGitter MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=02A7E63D-CAAA-4DED-B6FF-1F1E73FAF883)

Other non-administrative regions:
[`bkg_area_codes()`](https://jslth.github.io/ffm/reference/bkg_area_codes.md),
[`bkg_authorities()`](https://jslth.github.io/ffm/reference/bkg_authorities.md),
[`bkg_kfz()`](https://jslth.github.io/ffm/reference/bkg_kfz.md),
[`bkg_ror()`](https://jslth.github.io/ffm/reference/bkg_ror.md)

## Examples

``` r
# Return a bare-bones version of the INSPIRE grid
grid <- bkg_grid_fast(year = "2019", resolution = "100km")

# Return a fully detailed version instead
grid_full <- bkg_grid_full(resolution = "5km")

plot(grid)


# Convert grid to SpatRaster
if (requireNamespace("terra")) {
  library(terra)
  raster <- rast(vect(grid_full["p_wasser"]), type = "xyz")
  plot(raster, main = "Share of water area")
}
#> terra 1.8.93
```
