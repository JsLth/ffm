# Administrative hierarchy

Retrieve polygon geometries of municipalities in Germany with details on
their relationships to administrative areas of higher levels in the
territorial hierarchy. The output of this functions contains the
identifiers and names of the NUTS1 to NUTS3 areas that each municipality
belongs to.

This function interfaces the `vz250` product of the BKG.

## Usage

``` r
bkg_admin_hierarchy(
  key_date = c("0101", "1231"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)
```

## Arguments

- key_date:

  For `resolution %in% c("250", "5000")`, specifies the key date from
  which to download administrative data. Can be either `"0101"`
  (January 1) or `"1231"` (December 31). The latter is able to
  georeference statistical data while the first integrates changes made
  in the new year. If `"1231"`, population data is attached, otherwise
  not. Note that population data is not available at all scales (usually
  250 and 1000). Defaults to "0101".

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

An sf tibble with multipolygon geometries similar to the output of
[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md)`(level = "gem")`.
The tibble additionally contains columns `NUTS*_CODE` and `NUTS*_NAME`
giving the identifiers and names of the administrative areas the
municipalities belong to.

## See also

[`vz250`
documentation](https://sg.geodatenzentrum.de/web_public/gdz/dokumentation/deu/vz250.pdf)

## Examples

``` r
bkg_admin_hierarchy()
#> Simple feature collection with 11126 features and 28 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280371.1 ymin: 5235856 xmax: 921292.4 ymax: 6101487
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 11,126 × 29
#>       GF ARS_G AGS_G GEN_G BEZ_G IBZ_G ARS_V GEN_V BEZ_V IBZ_V ARS_K GEN_K BEZ_K
#>    <int> <chr> <chr> <chr> <chr> <int> <chr> <chr> <chr> <int> <chr> <chr> <chr>
#>  1     4 0100… 0100… Flen… Stadt    60 0100… Flen… Amts…    80 01001 Flen… Krei…
#>  2     4 0100… 0100… Kiel  Stadt    60 0100… Kiel  Amts…    80 01002 Kiel  Krei…
#>  3     4 0100… 0100… Lübe… Stadt    60 0100… Lübe… Amts…    80 01003 Lübe… Krei…
#>  4     4 0100… 0100… Neum… Stadt    60 0100… Neum… Amts…    80 01004 Neum… Krei…
#>  5     4 0105… 0105… Brun… Stadt    61 0105… Brun… Amts…    85 01051 Dith… Kreis
#>  6     4 0105… 0105… Heide Stadt    61 0105… Heide Amts…    85 01051 Dith… Kreis
#>  7     4 0105… 0105… Aver… Geme…    64 0105… Burg… Amt      50 01051 Dith… Kreis
#>  8     4 0105… 0105… Bric… Geme…    64 0105… Burg… Amt      50 01051 Dith… Kreis
#>  9     4 0105… 0105… Buch… Geme…    64 0105… Burg… Amt      50 01051 Dith… Kreis
#> 10     4 0105… 0105… Burg… Geme…    64 0105… Burg… Amt      50 01051 Dith… Kreis
#> # ℹ 11,116 more rows
#> # ℹ 16 more variables: IBZ_K <int>, ARS_R <chr>, GEN_R <chr>, BEZ_R <chr>,
#> #   IBZ_R <int>, ARS_L <chr>, GEN_L <chr>, BEZ_L <chr>, IBZ_L <int>,
#> #   NUTS3_CODE <chr>, NUTS3_NAME <chr>, NUTS2_CODE <chr>, NUTS2_NAME <chr>,
#> #   NUTS1_CODE <chr>, NUTS1_NAME <chr>, geometry <MULTIPOLYGON [m]>
```
