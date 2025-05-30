#' Digital elevation model
#' @description
#' Retrieve the digital elevation model (DEM) for the territory of Germany.
#'
#' @param bbox An sf geometry or a boundary box vector of the format
#' \code{c(xmin, ymin, xmax, ymax)}. Used as a geometric filter to mask the
#' coverage raster. If an sf geometry is provided, coordinates
#' are automatically transformed to ESPG:25832 (the default CRS), otherwise
#' they are expected to be in EPSG:25832.
#' @param interpolation Interpolation method to preprocess the raster.
#' Can be \code{"nearest-neighbor"}, \code{"linear"}, or \code{"cubic"}.
#' Does not seem to work currently - despite being listed as a capability of
#' the WCS.
#' @param epsg An EPSG code specifying a coordinate reference system of the
#' output. If you're unsure what this means, try running
#' \code{sf::st_crs(...)$epsg} on a spatial object that you are working with.
#' Defaults to 3035.
#'
#' @returns A \code{\link[terra:rast]{SpatRaster}} containing elevation data.
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")() && rlang::is_installed("terra")
#' library(sf)
#'
#' # Elevation around Hanover
#' han <- st_sfc(st_point(c(9.738611, 52.374444)), crs = 4326)
#' han <- st_buffer(st_transform(han, 3035), dist = 2000)
#' dem <- bkg_dem(bbox = han)
#' terra::plot(dem)
bkg_dem <- function(bbox = NULL, interpolation = NULL, epsg = 3035) {
  rlang::check_installed("terra", "query web coverage services (WCS).")
  if (!is.null(bbox)) {
    bbox <- wcs_subset(bbox)
  }

  out <- bkg_wcs(
    "dgm200_inspire__EL.GridCoverage",
    endpoint = "dgm200_inspire",
    epsg = epsg,
    interpolation = interpolation,
    subset = bbox$e,
    subset = bbox$n
  )
  terra::project(out, sprintf("EPSG:%s", epsg)) # Workaround because srsName does not work
}
