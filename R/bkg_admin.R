#' Administrative areas
#' @description
#' Retrieve polygon geometries of administrative areas in Germany. All
#' administrative levels are supported at different spatial resolutions.
#'
#' \itemize{
#'  \item{\code{bkg_admin} interfaces a WFS that allows prefiltering but
#'  provides no historical data and allows a maximum scale of 1:250,000.}
#'  \item{\code{bkg_admin_archive} allows access to historical data but
#'  has no prefiltering.}
#'  \item{\code{bkg_admin_highres} (\code{vg25}) allows access to
#'  high-resolution data going as low as 1:25,000 but allows no prefiltering.}
#' }
#'
#' These functions interface the \code{vg*} products of the BKG.
#'
#' @param level Administrative level to download. Must be one of
#' \code{"sta"} (Germany), \code{"lan"} (federal states), \code{"rbz"}
#' (governmental districts), \code{"krs"} (districts), \code{"vwg"}
#' (administrative associations), \code{"gem"} (municipalities),
#' \code{"li"} (boundary lines), or \code{"pk"} (municipality centroids).
#' Defaults to districts.
#' @param scale Scale of the geometries. Can be \code{"250"}
#' (1:250,000), \code{"1000"} (1:1,000,000), \code{"2500"} (1:2,500,000)
#' or \code{"5000"} (1:5,000,000). If \code{"250"}, population data is included
#' in the output. Defaults to \code{"250"}.
#' @param key_date For \code{resolution \%in\% c("250", "5000")}, specifies the key
#' date from which to download administrative data. Can be either \code{"0101"}
#' (January 1) or \code{"1231"} (December 31). The latter is able to
#' georeference statistical data while the first integrates changes made
#' in the new year. If \code{"1231"}, population data is attached, otherwise
#' not. Note that population data is not available at all scales (usually
#' 250 and 1000). Defaults to "0101".
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
#' See also \code{\link{wfs_filter}}.
#' @param epsg An EPSG code specifying a coordinate reference system of the
#' output. If you're unsure what this means, try running
#' \code{sf::st_crs(...)$epsg} on a spatial object that you are working with.
#' Defaults to 3035.
#' @param properties Vector of columns to include in the output.
#' @param max Maximum number of results to return.
#' @param allow_local If \code{TRUE}, allows special datasets to be loaded
#' locally. If \code{FALSE}, always downloads from the internet. For
#' \code{bkg_admin}, the datasets from \code{\link{admin_data}} can be loaded.
#' This only applies if \code{scale = "5000"}, \code{key_date = "1231"},
#' and \code{level %in% c("krs", "sta", "lan")}.
#' @param layer The \code{vg25} product used in \code{bkg_admin_highres}
#' contains a couple of metadata files. You can set a layer name to read these
#' files, otherwise the main file is read.
#' @inheritParams wfs_filter
#' @inheritParams bkg_nuts
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
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=4A9DCE2B-DCCA-4939-BA01-54364D11C46D}{\code{vg250-ew} MIS record}
#'
#' \code{\link{bkg_nuts}} for retrieving EU administrative areas
#'
#' \code{\link{bkg_admin_hierarchy}} for the administrative hierarchy
#'
#' \code{\link{bkg_ror}}, \code{\link{bkg_grid}}, \code{\link{bkg_kfz}},
#' \code{\link{bkg_authorities}} for non-administrative regions
#'
#' Datasets: \code{\link{admin_data}}, \code{\link{nuts_data}}
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
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' # You can use R-like operators to query the WFS
#' bkg_admin(ags %LIKE% "05%") # districts in NRW
#' bkg_admin(sn_l == "05") # does the same thing
#' bkg_admin(gen %LIKE% "Ber%") # districts starting with Ber*
#'
#' # To query population and area, the key date must be December 31
#' bkg_admin(ewz > 500000, key_date = "1231") # districts over 500k people
#' bkg_admin(kfl <= 100, key_date = "1231") # districts with low land register area
#'
#' # Using `gf == 9`, you can exclude waterbodies like oceans
#' states <- bkg_admin(scale = "5000", level = "lan", gf == 9)
#' plot(states$geometry)
#'
#' # Download historical data
#' bkg_admin_archive(scale = "5000", level = "sta", year = "2021")
#'
#' \dontrun{
#' # Download high-resolution data (takes a long time!)
#' bkg_admin_highres(level = "lan")
#' }
bkg_admin <- function(...,
                      level = "krs",
                      scale = c("250", "1000", "2500", "5000"),
                      key_date = c("0101", "1231"),
                      bbox = NULL,
                      poly = NULL,
                      predicate = "intersects",
                      filter = NULL,
                      epsg = 3035,
                      properties = NULL,
                      allow_local = TRUE,
                      max = NULL) {
  all_levels <- c("sta", "lan", "rbz", "krs", "vwg", "gem", "li", "pk")
  level <- rlang::arg_match(level, all_levels)
  scale <- rlang::arg_match(scale)
  key_date <- rlang::arg_match(key_date)

  if (isTRUE(allow_local) &&
      scale %in% "5000" &&
      level %in% c("krs", "lan", "sta") &&
      key_date %in% "1231") {
    dataset <- switch(level, krs = bkg_krs, lan = bkg_states, sta = bkg_germany)
    dataset <- local_filter(
      dataset,
      ...,
      poly = poly,
      bbox = bbox,
      predicate = predicate,
      epsg = epsg,
      properties = properties
    )
    return(dataset)
  }

  filter <- wfs_filter(
    ...,
    filter = filter,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )

  endpoint <- sprintf("vg%s", scale)
  service <- sprintf("%s_%s", endpoint, level)

  if (scale == "250" && identical(key_date, "1231")) {
    endpoint <- paste0(endpoint, "-ew")
  }

  if (scale == "5000") {
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


#' @rdname bkg_admin
#' @export
bkg_admin_archive <- function(level = "krs",
                              scale = c("250", "1000", "2500", "5000"),
                              key_date = c("0101", "1231"),
                              year = "latest",
                              timeout = 120,
                              update_cache = FALSE) {
  all_levels <- c("sta", "lan", "rbz", "krs", "vwg", "gem", "li", "pk")
  level <- rlang::arg_match(level, all_levels)
  scale <- rlang::arg_match(scale)
  key_date <- rlang::arg_match(key_date)

  product <- sprintf("vg%s", scale)
  can_ew <- scale %in% c("250", "1000")
  has_ew <- can_ew && identical(key_date, "1231")

  if (has_ew) {
    product <- paste0(product, "-ew")
  }

  if (can_ew) {
    product <- paste0(product, "_ebenen")
  }

  if (!scale %in% "2500") {
    product <- paste0(product, "_", key_date)
  } else {
    key_date <- "1231"
  }

  key_date_fmt <- switch(key_date, "0101" = "01-01", "1231" = "12-31")
  file <- sprintf(
    "vg%s%s_%s.utm32s.shape%s.zip",
    scale,
    if (has_ew) "-ew" else "",
    key_date_fmt,
    if (can_ew || scale %in% "5000") ".ebenen" else ""
  )
  out_path <- bkg_download(
    file,
    product = product,
    year = year,
    group = "vg",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, shp_exts, regex = sprintf("VG%s_%s", scale, level))
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_admin
#' @export
bkg_admin_highres <- function(level = "krs",
                              year = "latest",
                              layer = NULL,
                              timeout = 600,
                              update_cache = FALSE) {
  all_levels <- c("sta", "lan", "rbz", "krs", "vwg", "gem", "li")
  level <- rlang::arg_match(level, all_levels)

  out_path <- bkg_download(
    "vg25.utm32s.gpkg.zip",
    product = "vg25_ebenen",
    year = year,
    group = "vg",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, "gpkg")
  out_path <- out_path[has_file_ext(out_path, "gpkg")]
  sf::read_sf(
    out_path,
    drivers = "GPKG",
    quiet = TRUE,
    layer = layer %||% sprintf("vg25_%s", level)
  )
}


#' Administrative hierarchy
#' @description
#' Retrieve polygon geometries of municipalities in Germany with details on
#' their relationships to administrative areas of higher levels in the
#' territorial hierarchy. The output of this functions contains the identifiers
#' and names of the NUTS1 to NUTS3 areas that each municipality belongs to.
#'
#' @inheritParams bkg_nuts
#'
#' @returns An sf tibble with multipolygon geometries similar to the output
#' of \code{\link{bkg_admin}(level = "gem")}. The tibble additionally contains
#' columns \code{NUTS*_CODE} and \code{NUTS*_NAME} giving the identifiers and
#' names of the administrative areas the municipalities belong to.
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' bkg_admin_hierarchy()
bkg_admin_hierarchy <- function(key_date = c("0101", "1231"),
                                year = "latest",
                                timeout = 120,
                                update_cache = FALSE) {
  key_date <- rlang::arg_match(key_date)
  key_date_fmt <- switch(key_date, "0101" = "01-01", "3112" = "12-31")
  file <- sprintf("vz250_%s.utm32s.shape.zip", key_date_fmt)
  product <- sprintf("vz250_%s", key_date)
  out_path <- bkg_download(
    file,
    product = product,
    year = year,
    group = "vg",
    timeout = timeout,
    update_cache = update_cache
  )

  out_path <- unzip_ext(out_path, shp_exts)
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}
