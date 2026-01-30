#' Area code regions
#' @description
#' Retrieves area code regions (\emph{Vorwahlgebiete}) in Germany. Area code
#' regions are based on the number of registered telephone numbers.
#'
#' This function interfaces the \code{wfs_gnde} product of the BKG.
#'
#' @inheritParams bkg_admin
#'
#' @section Query language:
#' While other WFS interfaces like \code{\link{bkg_admin}} allow querying
#' using CQL or XML, \code{bkg_area_codes} ONLY supports XML. This has
#' implications for the allowed query filters (see \code{\link{wfs_filter}}).
#'
#' @returns An sf dataframe containing polygon geometries and the area code
#' (\code{vorwahl}) associated with the region.
#'
#' @seealso
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=f1fe5b66-25d6-44c7-b26a-88625aca9573}{\code{wfs_gnde} MIS record}
#'
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/wfs-gnde.pdf}{\code{wfs_gnde} documentation}
#'
#' \code{\link{bkg_geonames}} and \code{\link{bkg_endonyms}} for geographical names
#'
#' @family non-administrative regions
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' vorwahlen <- bkg_area_codes(vorwahl %LIKE% "0215%")
#' plot(vorwahlen$geometry)
bkg_area_codes <- function(...,
                           bbox = NULL,
                           poly = NULL,
                           predicate = "intersects",
                           filter = NULL,
                           epsg = 3035,
                           max = NULL) {
  filter <- wfs_filter(
    ...,
    filter = filter,
    bbox = bbox,
    poly = poly,
    predicate = predicate,
    lang = "xml"
  )

  res <- bkg_wfs(
    "gn:VorwahlGebiet",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "VorwahlGebiet",
    filter = filter,
    epsg = epsg,
    count = max
  )[-1]

  sf::st_sf(vorwahl = res$vorwahl, geometry = res$geom)
}
