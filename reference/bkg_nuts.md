# NUTS regions

Retrieve polygons of NUTS regions.

This function interfaces the `nuts*` products of the BKG.

## Usage

``` r
bkg_nuts(
  level = c("1", "2", "3"),
  scale = c("250", "1000", "2500", "5000"),
  key_date = c("0101", "1231"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)
```

## Arguments

- level:

  NUTS level to download. Can be `"1"` (federal states), `"2"`
  (inconsistent, something between states and government regions), or
  `"3"` (districts). Defaults to federal states.

- scale:

  Scale of the geometries. Can be `"250"` (1:250,000), `"1000"`
  (1:1,000,000), `"2500"` (1:2,500,000) or `"5000"` (1:5,000,000). If
  `"250"`, population data is included in the output. Defaults to
  `"250"`.

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

An sf dataframe with multipolygon geometries and the following columns:

- `GF`: Integer representing the geofactor; whether an area is
  "structured" or not. Land is structured if it is part of a state or
  other administrative unit but is not further divided into
  administrative units. Can be one of

  - 1: Unstructured, waterbody

  - 2: Structured, waterbody

  - 3: Unstructured, land

  - 4: Structured, land

- `NUTS_LEVEL`: NUTS level. Can be one of

  - 1: NUTS-1; federal states

  - 2: NUTS-2; inconsistent, somewhere between government regions and
    federal states

  - 3: NUTS-3; districts

- `NUTS_CODE`: Hierarchical key of the NUTS region. Can have a different
  number of characters depending on the NUTS level:

  - NUTS-1: three digits

  - NUTS-2: four digits

  - NUTS-3: five digits

- `NUTS_NAME`: Geographical name of the NUTS region

## Note

This function does not query a WFS so you are only able to download
entire datasets without the ability to filter beforehand.

## See also

[`nuts250`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/nuts250.pdf)

[`nuts250` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=D38F5B40-9209-4DC0-82BC-57FB575D29D7)

[`bkg_admin`](https://jslth.github.io/ffm/reference/bkg_admin.md) for
retrieving German administrative areas

Datasets:
[`admin_data`](https://jslth.github.io/ffm/reference/admin_data.md),
[`nuts_data`](https://jslth.github.io/ffm/reference/nuts_data.md)

## Examples

``` r
# Download NUTS state data from 2020
bkg_nuts(scale = "5000", year = 2020)
#> Simple feature collection with 16 features and 3 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280353.1 ymin: 5235878 xmax: 921261.6 ymax: 6101302
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 16 × 4
#>    NUTS_LEVEL NUTS_CODE NUTS_NAME                                       geometry
#>         <int> <chr>     <chr>                                 <MULTIPOLYGON [m]>
#>  1          1 DE1       Baden-Württemberg      (((579018.4 5345197, 578730 5342…
#>  2          1 DE2       Bayern                 (((792217.3 5346780, 787582.4 53…
#>  3          1 DE3       Berlin                 (((791413.7 5842844, 790893.8 58…
#>  4          1 DE4       Brandenburg            (((819216.5 5702544, 817838.5 57…
#>  5          1 DE5       Bremen                 (((471012 5933445, 468446.4 5938…
#>  6          1 DE6       Hamburg                (((464521.5 5978903, 462755.7 59…
#>  7          1 DE7       Hessen                 (((492636.7 5483361, 491362.4 54…
#>  8          1 DE8       Mecklenburg-Vorpommern (((813435.5 6003613, 813323.1 60…
#>  9          1 DE9       Niedersachsen          (((529970.5 5722449, 526897.9 57…
#> 10          1 DEA       Nordrhein-Westfalen    (((469921.3 5816808, 476396.4 58…
#> 11          1 DEB       Rheinland-Pfalz        (((398199.1 5437440, 394903.6 54…
#> 12          1 DEC       Saarland               (((356384.3 5448971, 356828.6 54…
#> 13          1 DED       Sachsen                (((869314.7 5719837, 870358.6 57…
#> 14          1 DEE       Sachsen-Anhalt         (((682263.4 5665628, 679699.4 56…
#> 15          1 DEF       Schleswig-Holstein     (((579561.1 5937947, 578707.1 59…
#> 16          1 DEG       Thüringen              (((727655.1 5626574, 728299.4 56…

# Download the latest NUTS district data
bkg_nuts(level = "3")
#> Simple feature collection with 428 features and 4 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280371.1 ymin: 5235856 xmax: 921292.4 ymax: 6101444
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 428 × 5
#>       GF NUTS_LEVEL NUTS_CODE NUTS_NAME                                 geometry
#>    <int>      <int> <chr>     <chr>                           <MULTIPOLYGON [m]>
#>  1     4          3 DE111     Stuttgart, Stadtkreis (((516514.1 5412585, 516501…
#>  2     4          3 DE112     Böblingen             (((507605.3 5393882, 507674…
#>  3     4          3 DE113     Esslingen             (((530167.9 5376192, 529989…
#>  4     4          3 DE114     Göppingen             (((546693.5 5376179, 546296…
#>  5     4          3 DE115     Ludwigsburg           (((525746.8 5426306, 525785…
#>  6     4          3 DE116     Rems-Murr-Kreis       (((536207.7 5401707, 536137…
#>  7     4          3 DE117     Heilbronn, Stadtkreis (((508553.4 5450760, 508678…
#>  8     4          3 DE118     Heilbronn, Landkreis  (((525039.4 5446468, 525384…
#>  9     4          3 DE119     Hohenlohekreis        (((560682.9 5459435, 560710…
#> 10     4          3 DE11A     Schwäbisch Hall       (((585283 5434640, 585236.5…
#> # ℹ 418 more rows
```
