# Administrative areas

Retrieve polygon geometries of administrative areas in Germany. All
administrative levels are supported at different spatial resolutions.

- `bkg_admin` interfaces a WFS that allows prefiltering but provides no
  historical data and allows a maximum scale of 1:250,000.

- `bkg_admin_archive` allows access to historical data but has no
  prefiltering.

- `bkg_admin_highres` (`vg25`) allows access to high-resolution data
  going as low as 1:25,000 but allows no prefiltering.

These functions interface the `vg*` products of the BKG.

## Usage

``` r
bkg_admin(
  ...,
  level = "krs",
  scale = c("250", "1000", "2500", "5000"),
  key_date = c("0101", "1231"),
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  filter = NULL,
  epsg = 3035,
  properties = NULL,
  max = NULL
)

bkg_admin_archive(
  level = "krs",
  scale = c("250", "1000", "2500", "5000"),
  key_date = c("0101", "1231"),
  year = "latest",
  timeout = 120,
  update_cache = FALSE
)

bkg_admin_highres(
  level = "krs",
  year = "latest",
  layer = NULL,
  timeout = 600,
  update_cache = FALSE
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
  also
  [`wfs_filter`](https://jslth.github.io/ffm/reference/wfs_filter.md).

- level:

  Administrative level to download. Must be one of `"sta"` (Germany),
  `"lan"` (federal states), `"rbz"` (governmental districts), `"krs"`
  (districts), `"vwg"` (administrative associations), `"gem"`
  (municipalities), `"li"` (boundary lines), or `"pk"` (municipality
  centroids). Defaults to districts.

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

- filter:

  A character string containing a valid CQL or XML filter. This string
  is appended to the query constructed through `...`. Use this argument
  to construct more complex filters. Defaults to `NULL`.

- epsg:

  An EPSG code specifying a coordinate reference system of the output.
  If you're unsure what this means, try running `sf::st_crs(...)$epsg`
  on a spatial object that you are working with. Defaults to 3035.

- properties:

  Vector of columns to include in the output.

- max:

  Maximum number of results to return.

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

- layer:

  The `vg25` product used in `bkg_admin_highres` contains a couple of
  metadata files. You can set a layer name to read these files,
  otherwise the main file is read.

## Value

An sf dataframe with multipolygon geometries and different columns
depending on the geometry type. Areal geometries generally have the
following columns:

- `objid`: Unique object identifier

- `beginn`: Creation of the object in the DLM

- `ade`: Integer representing the administrative level. Can be one of

  - 1: Germany

  - 2: Federal state

  - 3: Governmental district

  - 4: District

  - 5: Administrative association

  - 6: Municipality

- `gf`: Integer representing the geofactor; whether an area is
  "structured" or not. Land is structured if it is part of a state or
  other administrative unit but is not further divided into
  administrative units. Can be one of

  - 1: Unstructured, waterbody

  - 2: Structured, waterbody

  - 3: Unstructured, land

  - 4: Structured, land

- `bsg`: Special areas, can be 1 (Germany) or 9 (Lake Constance)

- `ars`: Territorial code (Amtlicher Regionalschlüssel). The ARS is
  stuctured hierarchically as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-9: Administrative association

  - Position 10-12: Municipality

- `ags`: Official municipality key (Amtlicher Gemeindeschlüssel).
  Related to the ARS but shortened to omit position 6 to 9. Structured
  as follows:

  - Position 1-2: Federal state

  - Position 3: Government region

  - Position 4-5: District

  - Position 6-8: Municipality

- `sdv_ars`: ARS of the seat of administration

- `gen`: Geographical name

- `bez`: Label of the administrative unit

- `ibz`: Identifier of the label

- `bem`: Comment on the label

- `nbd`: Formation of the geographical name. Can be "ja" if the label is
  part of the name or "nein" otherwise.

- `nuts`: NUTS identifier based on the Eurostat regional classification

- `ars_0`: ARS identifier with trailing zeroes

- `ags_0`: AGS identifier with trailing zeroes

- `wsk`: Legally relevant date for the effectiveness of administrative
  changes

- `sn_l`: Federal state component of the ARS

- `sn_r`: Governmental district component of the ARS

- `sn_k`: District component of the ARS

- `sn_v1`: First part of the administrative association component of the
  ARS

- `sn_v2`: Second part of the administrative association component of
  the ARS

- `sn_g`: Municipality component of the ARS

- `fk_3`: Purpose of the third key position. If `"R"`, indicates the
  government region, if `"K"`, indicates the district

- `dkm_id`: Identifier in the digital landscape model (DLM250)

- `ewz`: Number of inhabitants

- `kfl`: Land register area in square kilometers

Boundary geometries (`"li"`) can have additional columns:

- `agz`: Type of border. Can be one of

  - 1: National border

  - 2: State border

  - 3: Governmental district border

  - 4: District border

  - 5: Administrative association border

  - 6: Municipality border

  - 9: Coastline

- `rdg`: Legal definition of a border. Can be 1 (determined), 2 (not
  determined) or 9 (coastline)

- `gm5`: Border characteristic of administrative association borders
  (AGZ 5). Used to describe the purpose of these borders. Can be 0
  (characteristics by AGZ) or 8 (non-association border)

- `gmk`: Border characteristic by coast/ocean. Specifies whether a
  border runs a long a waterbody. Can be one of

  - 7: borders on the ocean

  - 8: auxiliary borders on the ocean

  - 9: borders at the coastline

  - 0: no characteristics

- `dlm_id`: Identifier in the digital landscape model (DLM250)

Point geometries (`"pk"`) have the following additional columns:

- `otl`: Name of the locality in the digital landscale model (DLM250)

- `lon_dez`: Decimal longitude

- `lat_dez`: Decimal latitude

- `lon_gms`: Geographical longitude

- `lat_gms`: Geographical latitude

## Query language

By default, WFS requests use CQL (Contextual Query Language) queries for
simplicity. CQL queries only work together with GET requests. This means
that when the URL is longer than 2048 characters, they fail. While POST
requests are much more flexible and able to accommodate long queries,
XML is really a pain to work with and I'm not confident in my approach
to construct XML queries. You can control whether to send GET or POST
requests by setting `options(ffm_query_language = "XML")` or
`options(ffm_query_language = "CQL")`.

## See also

[`vg250-ew`
documentation](https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/vg250.pdf)

[`vg250-ew` MIS
record](https://mis.bkg.bund.de/trefferanzeige?docuuid=4A9DCE2B-DCCA-4939-BA01-54364D11C46D)

[`bkg_nuts`](https://jslth.github.io/ffm/reference/bkg_nuts.md) for
retrieving EU administrative areas

[`bkg_admin_hierarchy`](https://jslth.github.io/ffm/reference/bkg_admin_hierarchy.md)
for the administrative hierarchy

[`bkg_ror`](https://jslth.github.io/ffm/reference/bkg_ror.md),
[`bkg_grid`](https://jslth.github.io/ffm/reference/bkg_grid.md),
[`bkg_kfz`](https://jslth.github.io/ffm/reference/bkg_kfz.md),
[`bkg_authorities`](https://jslth.github.io/ffm/reference/bkg_authorities.md)
for non-administrative regions

Datasets:
[`admin_data`](https://jslth.github.io/ffm/reference/admin_data.md),
[`nuts_data`](https://jslth.github.io/ffm/reference/nuts_data.md)

## Examples

``` r
# You can use R-like operators to query the WFS
bkg_admin(ags %LIKE% "05%") # districts in NRW
#> Simple feature collection with 53 features and 26 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4031313 ymin: 3029642 xmax: 4283898 ymax: 3269981
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 53 × 27
#>    objid      beginn       ade    gf   bsg lkz   ars   ags   sdv_ars gen   bez  
#>    <chr>      <date>     <int> <int> <int> <chr> <chr> <chr> <chr>   <chr> <chr>
#>  1 DEBKGVG20… 2025-01-03     4     4     1 NW    05111 05111 051110… Düss… Krei…
#>  2 DEBKGVG20… 2025-01-03     4     4     1 NW    05112 05112 051120… Duis… Krei…
#>  3 DEBKGVG20… 2025-01-03     4     4     1 NW    05113 05113 051130… Essen Krei…
#>  4 DEBKGVG20… 2025-01-03     4     4     1 NW    05114 05114 051140… Kref… Krei…
#>  5 DEBKGVG20… 2020-03-09     4     4     1 NW    05116 05116 051160… Mönc… Krei…
#>  6 DEBKGVG20… 2025-01-03     4     4     1 NW    05117 05117 051170… Mülh… Krei…
#>  7 DEBKGVG20… 2025-01-03     4     4     1 NW    05119 05119 051190… Ober… Krei…
#>  8 DEBKGVG20… 2025-01-03     4     4     1 NW    05120 05120 051200… Rems… Krei…
#>  9 DEBKGVG20… 2020-11-17     4     4     1 NW    05122 05122 051220… Soli… Krei…
#> 10 DEBKGVG20… 2025-04-11     4     4     1 NW    05124 05124 051240… Wupp… Krei…
#> # ℹ 43 more rows
#> # ℹ 16 more variables: ibz <int>, bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
bkg_admin(sn_l == "05") # does the same thing
#> Simple feature collection with 53 features and 26 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4031313 ymin: 3029642 xmax: 4283898 ymax: 3269981
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 53 × 27
#>    objid      beginn       ade    gf   bsg lkz   ars   ags   sdv_ars gen   bez  
#>    <chr>      <date>     <int> <int> <int> <chr> <chr> <chr> <chr>   <chr> <chr>
#>  1 DEBKGVG20… 2025-01-03     4     4     1 NW    05111 05111 051110… Düss… Krei…
#>  2 DEBKGVG20… 2025-01-03     4     4     1 NW    05112 05112 051120… Duis… Krei…
#>  3 DEBKGVG20… 2025-01-03     4     4     1 NW    05113 05113 051130… Essen Krei…
#>  4 DEBKGVG20… 2025-01-03     4     4     1 NW    05114 05114 051140… Kref… Krei…
#>  5 DEBKGVG20… 2020-03-09     4     4     1 NW    05116 05116 051160… Mönc… Krei…
#>  6 DEBKGVG20… 2025-01-03     4     4     1 NW    05117 05117 051170… Mülh… Krei…
#>  7 DEBKGVG20… 2025-01-03     4     4     1 NW    05119 05119 051190… Ober… Krei…
#>  8 DEBKGVG20… 2025-01-03     4     4     1 NW    05120 05120 051200… Rems… Krei…
#>  9 DEBKGVG20… 2020-11-17     4     4     1 NW    05122 05122 051220… Soli… Krei…
#> 10 DEBKGVG20… 2025-04-11     4     4     1 NW    05124 05124 051240… Wupp… Krei…
#> # ℹ 43 more rows
#> # ℹ 16 more variables: ibz <int>, bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
bkg_admin(gen %LIKE% "Ber%") # districts starting with Ber*
#> Simple feature collection with 4 features and 26 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4082950 ymin: 2710124 xmax: 4576603 ymax: 3290780
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 4 × 27
#>   objid beginn       ade    gf   bsg lkz   ars   ags   sdv_ars gen   bez     ibz
#>   <chr> <date>     <int> <int> <int> <chr> <chr> <chr> <chr>   <chr> <chr> <int>
#> 1 DEBK… 2025-04-11     4     4     1 HE    06431 06431 064310… Berg… Land…    43
#> 2 DEBK… 2025-04-11     4     4     1 RP    07231 07231 072310… Bern… Land…    43
#> 3 DEBK… 2021-12-13     4     4     1 BY    09172 09172 091720… Berc… Land…    43
#> 4 DEBK… 2025-04-11     4     4     1 BE    11000 11000 110000… Berl… Krei…    40
#> # ℹ 15 more variables: bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>

# To query population and area, the key date must be December 31
bkg_admin(ewz > 500000, key_date = "1231") # districts over 500k people
#> Simple feature collection with 21 features and 27 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4037375 ymin: 2773147 xmax: 4598913 ymax: 3429696
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 21 × 28
#>    objid      beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz
#>    <chr>      <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int>
#>  1 DEBKGVG20… 2023-10-03     4     4     1 02000 02000 020000… Hamb… Krei…    40
#>  2 DEBKGVG20… 2023-10-03     4     4     1 03241 03241 032410… Regi… Land…    45
#>  3 DEBKGVG20… 2023-10-03     4     4     1 04011 04011 040110… Brem… Krei…    40
#>  4 DEBKGVG20… 2023-10-03     4     4     1 05111 05111 051110… Düss… Krei…    40
#>  5 DEBKGVG20… 2022-12-19     4     4     1 05112 05112 051120… Duis… Krei…    40
#>  6 DEBKGVG20… 2022-12-19     4     4     1 05113 05113 051130… Essen Krei…    40
#>  7 DEBKGVG20… 2022-12-19     4     4     1 05315 05315 053150… Köln  Krei…    40
#>  8 DEBKGVG20… 2021-09-12     4     4     1 05334 05334 053340… Städ… Kreis    46
#>  9 DEBKGVG20… 2023-10-03     4     4     1 05382 05382 053820… Rhei… Kreis    42
#> 10 DEBKGVG20… 2023-10-03     4     4     1 05562 05562 055620… Reck… Kreis    42
#> # ℹ 11 more rows
#> # ℹ 17 more variables: bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, ewz <int>, kfl <dbl>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>
bkg_admin(kfl <= 100, key_date = "1231") # districts with low land register area
#> Simple feature collection with 74 features and 27 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 4097402 ymin: 2719179 xmax: 4603283 ymax: 3531335
#> Projected CRS: ETRS89-extended / LAEA Europe
#> # A tibble: 74 × 28
#>    objid      beginn       ade    gf   bsg ars   ags   sdv_ars gen   bez     ibz
#>    <chr>      <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int>
#>  1 DEBKGVG20… 2022-12-19     4     4     1 01001 01001 010010… Flen… Krei…    40
#>  2 DEBKGVG20… 2022-12-19     4     4     1 01004 01004 010040… Neum… Krei…    40
#>  3 DEBKGVG20… 2022-12-19     4     4     1 03401 03401 034010… Delm… Krei…    40
#>  4 DEBKGVG20… 2022-12-19     4     4     1 05117 05117 051170… Mülh… Krei…    40
#>  5 DEBKGVG20… 2022-12-19     4     4     1 05119 05119 051190… Ober… Krei…    40
#>  6 DEBKGVG20… 2019-06-12     4     4     1 05120 05120 051200… Rems… Krei…    40
#>  7 DEBKGVG20… 2020-11-17     4     4     1 05122 05122 051220… Soli… Krei…    40
#>  8 DEBKGVG20… 2021-11-16     4     4     1 05316 05316 053160… Leve… Krei…    40
#>  9 DEBKGVG20… 2022-12-19     4     4     1 05916 05916 059160… Herne Krei…    40
#> 10 DEBKGVG20… 2022-12-19     4     4     1 06413 06413 064130… Offe… Krei…    40
#> # ℹ 64 more rows
#> # ℹ 17 more variables: bem <chr>, nbd <chr>, sn_l <chr>, sn_r <chr>,
#> #   sn_k <chr>, sn_v1 <chr>, sn_v2 <chr>, sn_g <chr>, fk_s3 <chr>, nuts <chr>,
#> #   ars_0 <chr>, ags_0 <chr>, wsk <date>, ewz <int>, kfl <dbl>, dlm_id <chr>,
#> #   geometry <MULTIPOLYGON [m]>

# Using `gf == 9`, you can exclude waterbodies like oceans
states <- bkg_admin(scale = "5000", level = "lan", gf == 9)
plot(states$geometry)


# Download historical data
bkg_admin_archive(scale = "5000", level = "sta", year = "2021")
#> Simple feature collection with 7 features and 24 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280353.1 ymin: 5235878 xmax: 921261.6 ymax: 6106245
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 7 × 25
#>   OBJID BEGINN       ADE    GF   BSG ARS   AGS   SDV_ARS GEN   BEZ     IBZ BEM  
#>   <chr> <date>     <int> <int> <int> <chr> <chr> <chr>   <chr> <chr> <int> <chr>
#> 1 DEBK… 2021-06-20     1     9     1 0000… 0000… 110000… Deut… Bund…    10 --   
#> 2 DEBK… 2019-10-04     1     8     1 0000… 0000… 110000… Deut… Bund…    10 --   
#> 3 DEBK… 2019-10-04     1     8     1 0000… 0000… 110000… Deut… Bund…    10 --   
#> 4 DEBK… 2019-10-04     1     8     1 0000… 0000… 110000… Deut… Bund…    10 --   
#> 5 DEBK… 2019-10-04     1     8     9 --    --    --      Schw… --        0 --   
#> 6 DEBK… 2019-10-04     1     8     9 --    --    --      Öste… --        0 --   
#> 7 DEBK… 2019-10-04     1     8     9 0000… 0000… 110000… Deut… Bund…    10 --   
#> # ℹ 13 more variables: NBD <chr>, SN_L <chr>, SN_R <chr>, SN_K <chr>,
#> #   SN_V1 <chr>, SN_V2 <chr>, SN_G <chr>, FK_S3 <chr>, NUTS <chr>, ARS_0 <chr>,
#> #   AGS_0 <chr>, WSK <date>, geometry <MULTIPOLYGON [m]>

# \donttest{
# Download high-resolution data (takes a long time!)
bkg_admin_highres(level = "lan")
#> Simple feature collection with 26 features and 25 fields
#> Geometry type: MULTIPOLYGON
#> Dimension:     XY
#> Bounding box:  xmin: 280375 ymin: 5235855 xmax: 921298 ymax: 6106245
#> Projected CRS: ETRS89 / UTM zone 32N
#> # A tibble: 26 × 26
#>    OBJID   BEGINN                ADE    GF   BSG LKZ   ARS   AGS   SDV_ARS GEN  
#>    <chr>   <dttm>              <int> <int> <int> <chr> <chr> <chr> <chr>   <chr>
#>  1 DEBKGV… 2025-02-02 00:00:00     2     9     1 SH    01    01    010020… Schl…
#>  2 DEBKGV… 2025-02-02 00:00:00     2     9     1 HH    02    02    020000… Hamb…
#>  3 DEBKGV… 2025-02-02 00:00:00     2     9     1 NI    03    03    032410… Nied…
#>  4 DEBKGV… 2025-02-02 00:00:00     2     9     1 HB    04    04    040110… Brem…
#>  5 DEBKGV… 2025-02-02 00:00:00     2     9     1 NW    05    05    051110… Nord…
#>  6 DEBKGV… 2025-02-02 00:00:00     2     9     1 HE    06    06    064140… Hess…
#>  7 DEBKGV… 2025-02-02 00:00:00     2     9     1 RP    07    07    073150… Rhei…
#>  8 DEBKGV… 2025-02-02 00:00:00     2     9     1 BW    08    08    081110… Bade…
#>  9 DEBKGV… 2025-02-02 00:00:00     2     9     1 BY    09    09    091620… Baye…
#> 10 DEBKGV… 2025-02-02 00:00:00     2     9     1 SL    10    10    100410… Saar…
#> # ℹ 16 more rows
#> # ℹ 16 more variables: BEZ <chr>, IBZ <int>, BEM <chr>, NBD <chr>, SN_L <chr>,
#> #   SN_R <chr>, SN_K <chr>, SN_V1 <chr>, SN_V2 <chr>, SN_G <chr>, FK_S3 <chr>,
#> #   NUTS <chr>, ARS_0 <chr>, AGS_0 <chr>, WSK <dttm>, geom <MULTIPOLYGON [m]>
# }
```
