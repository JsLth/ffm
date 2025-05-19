#' Area code regions
#' @description
#' Retrieves area code regions (\emph{Vorwahlgebiete}) in Germany. Area code
#' regions are based on the number of registered telephone numbers.
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
