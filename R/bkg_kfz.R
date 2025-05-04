#' Vehicle registration plates
#' @description
#' Retrieve motor vehicle registration plate regions in Germany. Registration
#' plate regions are discerned by their area code
#' (\emph{Unterscheidungszeichen}) which indicate the place where a vehicle
#' was registered. These regions partially overlap with districts but are not
#' entirely identical.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns An sf dataframe with multipolygon geometries and the following
#' columns: `r rd_properties_list(debkgid, nnid, name, ars, oba, kfz, geola, geobr, gkre, gkho, utmre, utmho)`
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/kfz250.pdf}{\code{kfz250} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=171BF073-C17B-47F7-891F-F27E5EDD7643}{\code{kfz250} MIS record}
#'
#' \code{\link{bkg_admin}}
#'
#' @examplesIf ffm_run_examples() && requireNamespace("ggplot2")
#' library(ggplot2)
#'
#' kfz <- bkg_kfz(ars %LIKE% "053%")
#' ggplot(kfz) +
#'   geom_sf(fill = NA) +
#'   geom_sf_text(aes(label = kfz)) +
#'   theme_void()
bkg_kfz <- function(...,
                    bbox = NULL,
                    poly = NULL,
                    predicate = "intersects",
                    filter = NULL,
                    epsg = 3035,
                    properties = NULL,
                    max = NULL) {
  filter <- wfs_filter(
    ...,
    filter = filter,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )

  bkg_wfs(
    "kfz250",
    version = "1.1.0",
    maxfeatures = max,
    filter = filter,
    epsg = epsg,
    properties = properties
  )[-1]
}
