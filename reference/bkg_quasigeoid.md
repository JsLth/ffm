# Quasigeoid

Retrieves the "German Combined Quasigeoid", the official height
reference surface of the German land survey above the reference
ellipsoid (GRS80).

A quasigeoid is an approximation of the geoid surface used to define
normal heights above the earth's surface that is based on more practical
assumptions than a true geoid. It defines heights in meters that can be
more meaningful than ellipsoidal heights in many applications like
surveying, hydrological modeling, engineering, or spatial analysis.

This function interfaces the `quasigeoid` product of the BKG.

## Usage

``` r
bkg_quasigeoid(
  year = "latest",
  region = c("all", "coast", "no", "nw", "s", "w"),
  timeout = 120,
  update_cache = FALSE
)
```

## Arguments

- year:

  Version year of the dataset. You can use `latest` to retrieve the
  latest dataset version available on the BKG's geodata center. Older
  versions can be browsed using the
  [archive](https://daten.gdz.bkg.bund.de/produkte/).

- region:

  Subterritory of Germany. `"all"` returns the data for all of Germany,
  `"coast"` returns only coastal regions and `"no"`, `"nw"`, `"s"` and
  `"w"` refer to cardinal directions. Defaults to `"all"`.

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

A [`SpatRaster`](https://rspatial.github.io/terra/reference/rast.html)
containing normal heights for the specified `region`. The data comes in
EPSG:4258 and a resolution of 30" x 45" (approximately 0.9 x 0.9 km).

## See also

[`quasigeoid`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/quasigeoid.pdf)

[`quasigeoid` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=983fac52-b7de-4f43-a6f5-91e007a6f963)

## Examples

``` r
library(terra)
qgeoid <- bkg_quasigeoid(region = "no")
terra::plot(qgeoid)
```
