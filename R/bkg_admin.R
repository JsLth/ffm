#' Administrative areas
#' @description
#' Retrieve polygon geometries of administrative areas in Germany. All
#' administrative levels are supported at different spatial resolutions.
#'
#' @param level Administrative level to download. Must be one of
#' \code{"sta"} (Germany), \code{"lan"} (federal states), \code{"rbz"}
#' (governmental districts), \code{"krs"} (districts), \code{"vwg"}
#' (administrative associations), \code{"gem"} (municipalities),
#' \code{"li"} (boundary lines), or \code{"pk"} (municipality centroids).
#' Defaults to districts.
#' @param resolution Resolution of the geometries. Can be \code{"250"}
#' (1:250,000), \code{"1000"} (1:1,000,000), \code{"2500"} (1:2,500,000)
#' or \code{"5000"} (1:5,000,000). If \code{"250"}, population data is included
#' in the output. Defaults to \code{"250"}.
#' @param key_date For \code{resolution \%in\% c("250", "5000")}, specifies the key
#' date from which to download administrative data. Can be either \code{"0101"}
#' (January 1) or \code{"3112"} (December 31). The latter is able to
#' georeference statistical data while the first integrates changes made
#' in the new year. If \code{resolution == "250"}, the \code{key_date} value also
#' determines whether to include population data. If \code{"3112"}, population
#' data is attached, otherwise not. Defaults to "0101".
#' @param ... Used to construct CQL filters. Dot arguments accept an R-like
#' syntax that is converted to CQL queries internally. These queries basically
#' consist of a property name on the left, an aribtrary vector on the right,
#' and an operator that links both sides. If multiple queries are provided,
#' they will be chained with \code{AND}. The following operators and their
#' respective equivalents in CQL and XML are supported:
#'
#' \tabular{lll}{
#' \strong{R} \tab \strong{CQL} \tab \strong{XML}\cr
#' \code{==} \tab \code{=} \tab \code{PropertyIsEqualTo}\cr
#' \code{!=} \tab \code{<>} \tab \code{PropertyIsNotEqualTo}\cr
#' \code{<} \tab \code{<} \tab \code{PropertyIsLessThan}\cr
#' \code{>} \tab \code{>} \tab \code{PropertyIsGreaterThan}\cr
#' \code{>=} \tab \code{>=} \tab \code{PropertyIsGreaterThanOrEqualTo}\cr
#' \code{<=} \tab \code{<=} \tab \code{PropertyIsLessThanOrEqualTo}\cr
#' \code{\%LIKE\%} \tab \code{LIKE} \tab \code{PropertyIsLike}\cr
#' \code{\%ILIKE\%} \tab \code{ILIKE}\cr \tab\cr
#' \code{\%in\%} \tab \code{IN} \tab \code{PropertyIsEqualTo} and \code{Or}
#'}
#'
#' To construct more complex queries, you can use the \code{filter} argument
#' to pass CQL queries directly. Also note that you can switch between
#' CQL and XML queries using \code{options(ffm_query_language = "xml")}.
#' @param epsg An EPSG code specifying a coordinate reference system of the
#' output. If you're unsure what this means, try running
#' \code{sf::st_crs(...)$epsg} on a spatial object that you are working with.
#' Defaults to 3035.
#' @param properties Vector of columns to include in the output.
#' @param max Maximum number of results to return.
#' @inheritParams wfs_filter
#'
#' @returns An sf dataframe with multipolygon geometries and different columns
#' depending on the geometry type.
#' Areal geometries generally have the following columns:
#' `r rd_properties_list(objid, beginn, ade, gf, bsg, ars, ags, sdv_ars, gen, bez, ibz, bem, nbd, nuts, ars_0, ags_0, wsk, sn_l, sn_r, sn_k, sn_v1, sn_v2, sn_g, fk_3, dkm_id, ewz, kfl)`
#'
#' Boundary geometries (\code{"li"} can have additional columns:
#' `r rd_properties_list(agz, rdg, gm5, gmk, dlm_id)`
#'
#' Point geometries (\code{"pk"}) have the following additional columns:
#' `r rd_properties_list(otl, lon_dez, lat_dez, lon_gms, lat_gms)`
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/vg250.pdf}{\code{vg250-ew} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=4A9DCE2B-DCCA-4939-BA01-54364D11C46D}{MIS record for \code{vg250-ew}}
#'
#' \code{\link{bkg_nuts}} for retrieving EU administrative areas
#'
#' @export
#'
#' @section Query language:
#' By default, WFS requests use CQL (Contextual Query Language) queries for
#' simplicity. CQL queries only work together with GET requests. This means
#' that when the URL is longer than 2048 characters, they fail.
#' While POST requests are much more flexible and able to accommodate long
#' queries, XML is really a pain to work with and I'm not confident in my
#' approach to construct XML queries. You can control whether to send GET or
#' POST requests by setting \code{options(ffm_query_language = "XML")}
#' or \code{options(ffm_query_language = "CQL")}.
#'
#' @examples
#' # You can use R-like operators to query the WFS
#' bkg_admin(ags %LIKE% "05%") # districts in NRW
#' bkg_admin(sn_l == "05") # does the same thing
#' bkg_admin(gen %LIKE% "Ber%") # districts starting with Ber*
#' bkg_admin(ewz > 100000) # districts over 100k people
#' bkg_admin(kfl <= 100) # districts with low land register area
bkg_admin <- function(...,
                      level = "krs",
                      scale = c("250", "1000", "2500", "5000"),
                      key_date = "0101",
                      bbox = NULL,
                      poly = NULL,
                      predicate = "intersects",
                      filter = NULL,
                      epsg = 3035,
                      properties = NULL,
                      max = NULL) {
  all_levels <- c("sta", "lan", "rbz", "krs", "vwg", "gem", "li", "pk")
  level <- rlang::arg_match(level, all_levels)
  scale <- rlang::arg_match(scale)

  filter <- wfs_filter(
    ...,
    filter = filter,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )
  filter <- paste(c(dot_filter, filter), collapse = " AND ")

  endpoint <- sprintf("vg%s", scale)
  service <- sprintf("%s_%s", endpoint, level)

  if (scale == 250 && identical(key_date, "3112")) {
    endpoint <- paste0(endpoint, "-ew")
  }

  if (scale == 5000) {
    endpoint <- sprintf("%s_%s", endpoint, key_date)
  }

  bkg_wfs(
    service,
    endpoint = endpoint,
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' NUTS regions
#' @description
#' Retrieve polygons of NUTS regions.
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
#' @export
#'
#' @examples \donttest{# Download NUTS state data from 2020
#' bkg_nuts(scale = "5000", year = 2020)
#'
#' # Download the latest NUTS district data
#' bkg_nuts(level = "3")}
bkg_nuts <- function(level = c("1", "2", "3"),
                     scale = c("250", "1000", "2500", "5000"),
                     key_date = c("0101", "3112"),
                     year = "latest",
                     timeout = 120,
                     update_cache = FALSE) {
  level <- rlang::arg_match(level)
  scale <- rlang::arg_match(scale)
  key_date <- rlang::arg_match(key_date)
  key_date_fmt <- switch(key_date, "0101" = "01-01", "3112" = "31-12")
  file <- sprintf("nuts%s_%s.utm32s.shape.zip", scale, key_date_fmt)
  product <- sprintf("nuts%s_%s", scale, key_date)
  out_path <- bkg_download(
    file,
    product = product,
    year = year,
    group = "vg",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, shp_exts, regex = sprintf("NUTS%s", level))
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}
