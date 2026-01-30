#' BKG WCS
#' @description
#' Low-level interface to BKG-style web coverage services (WCS). This function
#' is used in all high-level functions of \code{ffm} that depend on a WCS,
#' e.g., \code{\link{bkg_dem}}.
#'
#' @param coverage_id Coverage ID. When in doubt, inspect the
#' \code{GetCapabilities} of the service.
#' @param endpoint Endpoint to interface. Note that \code{wcs_} is appended
#' and only the rest of the product name must be provided. For example,
#' \code{wcs_dgm200_inspire} becomes \code{dgm200_inspire}. Defaults to the
#' value of \code{coverage_id}.
#' @param version Service version of the WCS. Defaults to \code{2.0.1}.
#' @param format Content type of the output. This value heavily depends
#' the endpoint queried. Defaults to \code{"image/tiff;application=geotiff"}.
#' @param interpolation Method used to interpolate the coverage raster.
#' Allowed methods depend on the capabilities of the WCS.
#' @inheritParams bkg_wfs
#'
#' @returns A \code{\link[terra:rast]{SpatRaster}}.
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' # Boundaries can be provided using two subset arguments
#' bkg_wcs(
#'   "dgm200_inspire__EL.GridCoverage",
#'   endpoint = "dgm200_inspire",
#'   subset = "E(548282,552280)",
#'   subset = "N(5800943,5804942)"
#' )
bkg_wcs <- function(coverage_id,
                    endpoint = coverage_id,
                    version = "2.0.1",
                    method = NULL,
                    format = "image/tiff;application=geotiff",
                    epsg = 3035,
                    interpolation = NULL,
                    ...) {
  method <- method %||%
    switch(default_query_lang(), cql = "GET", xml = "POST")

  req <- httr2::request(sgx_base())
  req <- httr2::req_url_path(req, sprintf("wcs_%s", endpoint))

  req <- switch(
    method,
    POST = req,
    GET = bkg_wcs_get_query(
      req,
      coverage_id,
      version = version,
      format = format,
      epsg = epsg,
      interpolation = interpolation,
      ...
    )
  )

  if (nchar(req$url) > 2048) {
    cli::cli_abort(c(
      "Query is too large to be handled by CQL queries.",
      "i" = "Consider setting `options(ffm_query_language = \"xml\")`.",
      "i" = "Alternatively, try to reduce the size of your query."
    ))
  }

  if (isTRUE(getOption("ffm_debug", FALSE))) {
    switch(
      method,
      GET = cli::cli_verbatim(utils::URLdecode(req$url)),
      POST = cli::cli_verbatim(req$body$data)
    )
  }

  req <- httr2::req_error(req, body = get_resp_error_details)
  tempf <- tempfile()
  resp <- httr2::req_perform(req, path = tempf)
  terra::rast(tempf)
}


bkg_wcs_get_query <- function(req,
                              coverage_id,
                              version = "2.0.1",
                              format = "image/tiff;application=geotiff",
                              epsg = 3035,
                              interpolation = NULL,
                              ...) {
  httr2::req_url_query(
    req,
    service = "WCS",
    version = version,
    request = "GetCoverage",
    coverageid = coverage_id,
    outputFormat = format,
    srsName = epsg,
    interpolation = interpolation,
    ...,
    .multi = "comma"
  )
}


wcs_subset <- function(bbox, default_crs = 25832) {
  if (inherits(bbox, c("sf", "sfc"))) {
    bbox <- sf::st_transform(bbox, default_crs)
  }

  bbox <- sf::st_bbox(bbox)
  list(
    e = sprintf("E(%s,%s)", bbox["xmin"], bbox["xmax"]),
    n = sprintf("N(%s,%s)", bbox["ymin"], bbox["ymax"])
  )
}
