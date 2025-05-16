#' Non-administrative regions
#' @description
#' Retrieve areal data related to what the BKG calls non-administrative
#' regions. This includes:
#'
#' \itemize{
#'  \item{\code{bkg_ror}: Raumordnungsregionen (Spatial planning regions)}
#'  \item{\code{bkg_rg}: Reisegebiete (Travel areas)}
#'  \item{\code{bkg_amr}: Arbeitsmarktregionen (Labor market regions)}
#'  \item{\code{bkg_bkr}: Braunkohlereviere (Lignite regions)}
#'  \item{\code{bkg_krg}: Kreisregionen (District regions)}
#'  \item{\code{bkg_mbe}: BBSR Mittelbereiche (BBSR middle areas)}
#'  \item{\code{bkg_ggr}: Großstadtregionen (City regions)}
#'  \item{\code{bkg_kmr}: Metropolregionen (Metropolitan regions)}
#'  \item{\code{bkg_mkro}: Verdichtungsräume (Conurbations)}
#' }
#'
#' @inheritParams bkg_nuts
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/ge5000.pdf}{\code{ge5000 documentation}}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=A79091B8-5E32-4300-8B19-517195FF8084}{\code{ge5000} MIS record}
#'
#' @family non-administrative regions
bkg_ror <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/ror/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_rg <- function(scale = c("250", "1000", "2500", "5000"),
                   year = "latest",
                   timeout = 120,
                   update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/rg/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_amr <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/amr/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_bkr <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/bkr/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_krg <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/krg/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_mbe <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/mbe/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_ggr <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/ggr/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


#' @rdname bkg_ror
#' @export
bkg_kmr <- function(scale = c("250", "1000", "2500", "5000"),
                    year = "latest",
                    timeout = 120,
                    update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/kmr/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}



#' @rdname bkg_ror
#' @export
bkg_mkro <- function(scale = c("250", "1000", "2500", "5000"),
                     year = "latest",
                     timeout = 120,
                     update_cache = FALSE) {
  out_path <- download_ge(scale, timeout, update_cache)
  out_path <- unzip_ext(out_path, shp_exts, regex = "/mkro/")
  out_path <- out_path[has_file_ext(out_path, "shp")]
  sf::read_sf(out_path, drivers = "ESRI Shapefile", quiet = TRUE)
}


download_ge <- function(scale, timeout, update_cache) {
  scale <- rlang::arg_match(scale)
  file <- sprintf("ge%s.utm32s.shape.zip", scale)
  product <- sprintf("ge%s", scale)
  out_path <- bkg_download(
    file,
    product = product,
    year = year,
    group = "sonstige",
    timeout = timeout,
    update_cache = update_cache
  )
}
