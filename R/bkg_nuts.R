#' NUTS regions
#' @description
#' Retrieve polygons of NUTS regions.
#'
#' This function interfaces the \code{nuts*} products of the BKG.
#'
#' @param level NUTS level to download. Can be \code{"1"} (federal states),
#' \code{"2"} (inconsistent, something between states and government regions),
#' or \code{"3"} (districts). Defaults to federal states.
#' @param timeout Timeout value for the data download passed to
#' \code{\link[httr2]{req_timeout}}. Adjust this if your internet connection is
#' slow or you are downloading larger datasets.
#' @param year Version year of the dataset. You can use \code{latest} to
#' retrieve the latest dataset version available on the BKG's geodata center.
#' Older versions can be browsed using the
#' \href{https://daten.gdz.bkg.bund.de/produkte/}{archive}.
#' @param update_cache By default, downloaded files are cached in the
#' \code{tempdir()} directory of R. When downloading the same data again,
#' the data is not downloaded but instead taken from the cache. Sometimes
#' this can be not the desired behavior. If you want to overwrite the cache,
#' pass \code{TRUE}. Defaults to \code{FALSE}, i.e. always adopt the cache
#' if possible.
#' @inheritParams bkg_admin
#'
#' @returns An sf dataframe with multipolygon geometries and the following
#' columns:
#'
#' `r rd_properties_list(gf, nuts_level, nuts_code, nuts_name, case = "upper")`
#'
#' @note
#' This function does not query a WFS so you are only able to download
#' entire datasets without the ability to filter beforehand.
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/nuts250.pdf}{\code{nuts250} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=D38F5B40-9209-4DC0-82BC-57FB575D29D7}{\code{nuts250} MIS record}
#'
#' \code{\link{bkg_admin}} for retrieving German administrative areas
#'
#' Datasets: \code{\link{admin_data}}, \code{\link{nuts_data}}
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' # Download NUTS state data from 2020
#' bkg_nuts(scale = "5000", year = 2020)
#'
#' # Download the latest NUTS district data
#' bkg_nuts(level = "3")
bkg_nuts <- function(level = c("1", "2", "3"),
                     scale = c("250", "1000", "2500", "5000"),
                     key_date = c("0101", "1231"),
                     year = "latest",
                     timeout = 120,
                     update_cache = FALSE) {
  level <- rlang::arg_match(level)
  scale <- rlang::arg_match(scale)
  key_date <- rlang::arg_match(key_date)

  if (scale %in% c("250", "1000")) {
    product <- sprintf("nuts%s_%s", scale, key_date)
  } else {
    key_date <- "1231"
    product <- sprintf("nuts%s", scale)
  }

  key_date_fmt <- switch(key_date, "0101" = "01-01", "1231" = "12-31")
  file <- sprintf("nuts%s_%s.utm32s.shape.zip", scale, key_date_fmt)
  out_path <- bkg_download(
    file,
    product = product,
    year = year,
    group = "vg",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, shp_exts, regex = sprintf(
    "(nuts)?%s_n(uts)?%s", scale, level
  ))
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}
