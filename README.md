
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ffm

<!-- badges: start -->

[![R-CMD-check](https://github.com/jslth/ffm/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jslth/ffm/actions/workflows/R-CMD-check.yaml)
[![Codecov test
coverage](https://codecov.io/gh/jslth/ffm/graph/badge.svg)](https://app.codecov.io/gh/jslth/ffm)
[![CRAN
status](https://www.r-pkg.org/badges/version/ffm)](https://CRAN.R-project.org/package=ffm)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![Downloads](https://cranlogs.r-pkg.org/badges/ffm)](https://CRAN.R-project.org/package=ffm)
[![CodeFactor](https://www.codefactor.io/repository/github/jslth/ffm/badge/main)](https://www.codefactor.io/repository/github/jslth/ffm/overview/main)
<!-- badges: end -->

`{ffm}` is an R package that provides quick and easy access to data from
the geodata center of Germany’s Federal Agency for Cartography and
Geodesy (BKG). The BKG is the official provider of spatial data in
Germany and provides quite a few datasets as open data. These data range
from administrative areas to earth observation data and are often
crucial when working with regional statistics from Germany. Part of the
motivation for this package stems from frustration when working areal
identifiers returned by packages like `{wiesbaden}` or `{restatis}` and
not being able to quickly link them to their spatial representations.

The name `ffm` is based on the colloquial short name of Frankfurt am
Main where the BKG’s headquarters are located.

## Gallery

The following examples were created using `{ffm}`. You can see their
code in the `examples/` directory.

<div style="display: flex; gap: 10px;">

<img src="man/figures/munic_access.png" height="500vw"/>
<img src="man/figures/hesse_relief.png" height="500vw"/>

</div>

## Installation

You can install the development version of ffm from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("jslth/ffm")
```

## Example

Retrieving data is pretty straightforward:

``` r
library(ffm)
districts <- bkg_admin(level = "krs", scale = "5000")
```

<details>

<summary>

Code for the plot
</summary>

``` r
library(ggplot2)

ggplot(districts) +
  geom_sf(fill = NA) +
  theme_void()
```

</details>

<img src="man/figures/README-unnamed-chunk-3-1.png" width="100%" />

The package makes it easy to go deeper than just getting the data. In
many functions, you can use spatial filters.

``` r
districts <- bkg_admin(
  level = "krs",
  scale = "5000",
  bbox = c(xmin = 700000, ymin = 5900000, xmax = 850000, ymax = 6000000),
  predicate = "intersects"
)
districts$label <- ifelse(
  districts$bez == "Kreisfreie Stadt",
  paste("Stadt", districts$gen),
  districts$gen
)
```

<details>

<summary>

Code for the plot
</summary>

``` r
library(ggrepel)

ggplot(districts) +
  geom_sf(fill = NA) +
  geom_text_repel(
    aes(label = label, geometry = geometry),
    stat = "sf_coordinates",
    size = 3
  ) +
  theme_void()
```

</details>

<img src="man/figures/README-unnamed-chunk-5-1.png" width="100%" />

Attribute filters are supported using a R-like syntax.

``` r
munics <- bkg_admin(
  level = "gem",
  key_date = "3112",
  sn_l %in% c("08", "09")
)
```

<details>

<summary>

Code for the plot
</summary>

``` r
munics$popdens <- munics$ewz / munics$kfl
munics$popdens[munics$popdens == 0] <- NA
ggplot(munics) +
  geom_sf(aes(fill = popdens), color = NA) +
  scale_fill_viridis_b("Population / km²", transform = "log10") +
  ggtitle("Population density in Southern Germany") +
  theme_void()
```

</details>

<img src="man/figures/README-unnamed-chunk-7-1.png" width="100%" />
