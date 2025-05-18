#' Quasigeoid
#' @description
#' Retrieves the "German Combined Quasigeoid", the official height reference
#' surface of the German land survey above the reference ellipsoid (GRS80).
#'
#' A quasigeoid is an approximation of the geoid surface used to define normal
#' heights above the earth's surface that is based on more practical assumptions
#' than a true geoid. It defines heights in meters that can be more meaningful
#' than ellipsoidal heights in many applications like surveying, hydrological
#' modeling, engineering, or spatial analysis.
#'
#' This function interfaces the \code{quasigeoid} product of the BKG.
#'
#' @param region Subterritory of Germany. \code{"all"} returns the data for
#' all of Germany, \code{"coast"} returns only coastal regions and \code{"no"},
#' \code{"nw"}, \code{"s"} and \code{"w"} refer to cardinal directions. Defaults
#' to \code{"all"}.
#' @inheritParams bkg_nuts
#'
#' @returns A \code{\link[terra:rast]{SpatRaster}} containing normal heights
#' for the specified \code{region}. The data comes in EPSG:4258 and a
#' resolution of 30" x 45" (approximately 0.9 x 0.9 km).
#'
#' @export
#'
#' @examplesIf ffm_run_examples() && rlang::is_installed("terra")
#' library(terra)
#' qgeoid <- bkg_quasigeoid(region = "no")
#' terra::plot(qgeoid)
bkg_quasigeoid <- function(year = "latest",
                           region = c("all", "coast", "no", "nw", "s", "w"),
                           timeout = 120,
                           update_cache = FALSE) {
  rlang::check_installed("terra")
  region <- rlang::arg_match(region)
  region <- switch(
    region,
    all = "de",
    coast = "k\u00fcste",
    region
  )
  file <- sprintf("quasigeoid.geo89.%s.zip", region)

  out_path <- bkg_download(
    file = file,
    product = "quasigeoid",
    year = year,
    group = "sonstige",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, "tif")[1]
  terra::rast(out_path)
}
