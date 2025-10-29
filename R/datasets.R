#' German NUTS \code{MULTIPOLYGON}s
#'
#' @description
#' Three \code{\link[sf:st_sf]{sf}} dataframes containing all geometries of
#' German NUTS1, NUTS2, and NUTS3 regions, respectively. The reference year
#' is 2023.
#'
#' These datasets can be very useful for quickly retrieving pre-loaded
#' boundaries without download.
#'
#' @format For the dataframe format, see \code{\link{bkg_nuts}}.
#' @source © BKG (2025) dl-de/by-2-0, data sources:
#' \url{https://sgx.geodatenzentrum.de/web_public/gdz/datenquellen/datenquellen_vg_nuts.pdf}
#' @seealso \code{\link{bkg_nuts}}
#' @family datasets
#' @name nuts_data
#'
#' @examples
#' bkg_nuts1
"bkg_nuts1"


#' @rdname nuts_data
"bkg_nuts2"


#' @rdname nuts_data
"bkg_nuts3"


#' German administrative boundaries
#'
#' @description
#' Three \code{\link[sf:st_sf]{sf}} dataframes containing all geometries of
#' German districts, federal states, and the country, respectively. The
#' reference year is 2023.
#'
#' @format For the dataframe format, see \code{\link{bkg_admin}}.
#' @source © BKG (2025) dl-de/by-2-0, data sources:
#' \url{https://sgx.geodatenzentrum.de/web_public/gdz/datenquellen/Datenquellen_vg_nuts.pdf}
#' @seealso \code{\link{bkg_admin}}
#' @family datasets
#' @name admin_data
#'
#' @examples
#' bkg_krs
"bkg_krs"


#' @rdname admin_data
"bkg_states"


#' @rdname admin_data
"bkg_germany"
