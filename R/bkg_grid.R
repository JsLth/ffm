#' INSPIRE grids
#' @description
#' Retrieve geometries of INSPIRE-compliant grid geometries (also called
#' "GeoGitter"). \code{bkg_grid_fast()} is much faster than \code{bkg_grid_full()}
#' by downloading heavily compressed versions grids. This happens at the cost
#' of data richness as \code{bkg_grid_fast()} only contains the geometries and
#' nothing else. Note that the \code{arrow} package needs to be installed to
#' use \code{bkg_grid_fast()}.
#'
#' Note that the output contains point geometries. Most of the times, you
#' want to work with rasters instead. To convert a given object \code{out},
#' type the following (\code{terra} package required):
#'
#' \preformatted{terra::rast(out)}
#'
#' @param year Version of the grid. Can be \code{"2015"}, \code{"2017"},
#' \code{"2018"} or \code{"2019"}. For \code{bkg_grid_fast}, \code{"latest"}
#' downloads the latest version of the grid.
#' @param resolution Cell size of the grid. Can be \code{"100m"}, \code{"250m"},
#' \code{"1km"}, \code{"5km"}, \code{"10km"}, or \code{"100km"}.
#' @inheritParams bkg_nuts
#'
#' @returns \code{bkg_grid_fast} returns an sf dataframe with point geometries
#' and no features. \code{bkg_grid_full} also returns point geometries but
#' with the following additional features:
#'
#' `r rd_properties_list(x_sw, y_sw, f_staat, f_land, f_wasser, p_staat, p_land, p_wasser, ags)`
#'
#' Note that \code{ags} is only included for resolutions \code{"100m"} and
#' \code{"250m"}
#'
#' @export
#'
#' @details
#' The following table gives a rough idea of how much less data
#' \code{bkg_grid_fast} needs to download for each resolution compared to
#' \code{bkg_grid_full}.
#'
#' \tabular{lll}{
#' \strong{Size} \tab \strong{fast} \tab \strong{full}\cr
#' 100km \tab 0.78 kB \tab 933 kB    \cr
#' 10km  \tab 2.68 kB \tab 1,015 kB   \cr
#' 5km   \tab 3.53 kB \tab 1,253 kB   \cr
#' 1km   \tab 28.7 kB \tab 5,249 kB   \cr
#' 500m  \tab 133 kB  \tab 15,902 kB \cr
#' 250m  \tab 289 kB  \tab 53,900 kB \cr
#' 100m  \tab 1,420 kB \tab 291,000 kB
#'}
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/geogitter.pdf}{GeoGitter documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=02A7E63D-CAAA-4DED-B6FF-1F1E73FAF883}{GeoGitter MIS record}
#'
#' @family non-administrative regions
#' @name bkg_grid
#'
#' @examples \donttest{# Return a bare-bones version of the INSPIRE grid
#' grid <- bkg_grid_fast(year = "2019", resolution = "100km")
#'
#' # Return a fully detailed version instead
#' grid_full <- bkg_grid_full(resolution = "5km")
#'
#' plot(grid)
#'
#' # Convert grid to SpatRaster
#' if (requireNamespace("terra")) {
#'   library(terra)
#'   raster <- rast(vect(grid_full["p_wasser"]), type = "xyz")
#'   plot(raster, main = "Share of water area")
#' }}
bkg_grid_fast <- function(year = c("2019", "2018", "2017", "2015"),
                          resolution = c("100km", "10km", "5km", "1km", "250m", "100m"),
                          timeout = 600,
                          update_cache = FALSE) {
  rlang::check_installed("arrow", reason = "to quickly download INSPIRE grids.")
  year <- rlang::arg_match(year)
  resolution <- rlang::arg_match(resolution)
  file <- sprintf("grid_%s_%s.parquet", year, resolution)
  url <- "https://github.com/jslth/z22data/raw/refs/heads/main/grids/"
  path <- download(
    paste0(url, file),
    timeout = timeout,
    update_cache = update_cache
  )
  grid <- arrow::read_parquet(path)
  sf::st_as_sf(grid, coords = c("x", "y"), crs = 3035)
}


#' @rdname bkg_grid
#' @export
bkg_grid_full <- function(year = "latest",
                          resolution = c("100km", "10km", "5km", "1km", "250m", "100m"),
                          timeout = 600,
                          update_cache = FALSE) {
  resolution <- rlang::arg_match(resolution)
  file <- sprintf("DE_Grid_ETRS89-LAEA_%s.csv.zip", resolution)
  out_path <- bkg_download(
    file = file,
    product = "geogitter",
    year = year,
    group = "sonstige",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, "csv")
  out <- utils::read.csv2(out_path)

  # fix column names in csv; this is not necessary for shp or gpkg
  names(out) <- c(
    "inspire", "x_sw", "y_sw", "x_mp", "y_mp", "f_staat", "f_land", "f_wasser",
    "p_staat", "p_land", "p_wasser", if (resolution %in% c("100m", "250m")) "ags"
  )
  sf::st_as_sf(out, coords = c("x_mp", "y_mp"), crs = 3035)
}
