# Non-administrative regions

Retrieve areal data related to what the BKG calls non-administrative
regions. This includes:

- `bkg_ror`: Raumordnungsregionen (Spatial planning regions)

- `bkg_rg`: Reisegebiete (Travel areas)

- `bkg_amr`: Arbeitsmarktregionen (Labor market regions)

- `bkg_bkr`: Braunkohlereviere (Lignite regions)

- `bkg_krg`: Kreisregionen (District regions)

- `bkg_mbe`: BBSR Mittelbereiche (BBSR middle areas)

- `bkg_ggr`: Großstadtregionen (City regions)

- `bkg_kmr`: Metropolregionen (Metropolitan regions)

- `bkg_mkro`: Verdichtungsräume (Conurbations)

These functions interface the `ge*` product of the BKG.

## Usage

``` r
bkg_ror(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_rg(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_amr(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_bkr(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_krg(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_mbe(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_ggr(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_kmr(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_mkro(
  scale = c("250", "1000", "2500", "5000"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)
```

## Arguments

- scale:

  Scale of the geometries. Can be `"250"` (1:250,000), `"1000"`
  (1:1,000,000), `"2500"` (1:2,500,000) or `"5000"` (1:5,000,000). If
  `"250"`, population data is included in the output. Defaults to
  `"250"`.

- year:

  Version year of the dataset. You can use `latest` to retrieve the
  latest dataset version available on the BKG's geodata center. Older
  versions can be browsed using the
  [archive](https://daten.gdz.bkg.bund.de/produkte/).

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

An sf tibble with multipolygon geometries and two features, a regional
identifier and the region endonyms.

## See also

[`ge5000 documentation`](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/ge5000.pdf)

[`ge5000` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=A79091B8-5E32-4300-8B19-517195FF8084)

Other non-administrative regions:
[`bkg_area_codes()`](https://jslth.github.io/ffm/reference/bkg_area_codes.md),
[`bkg_authorities()`](https://jslth.github.io/ffm/reference/bkg_authorities.md),
[`bkg_grid`](https://jslth.github.io/ffm/reference/bkg_grid.md),
[`bkg_kfz()`](https://jslth.github.io/ffm/reference/bkg_kfz.md)
