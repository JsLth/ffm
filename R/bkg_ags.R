#' Official keys
#' @description
#' Retrieve geographical names associated with official municipality keys
#' and regional keys. To retrieve their polygon geometries, see
#' \code{\link{bkg_admin}}.
#'
#' These functions interface the \code{wfs_gnde} product of the BKG.
#'
#' @inheritParams bkg_admin
#' @returns A dataframe containing the respective identifier and geographical
#' names related to their state, government region, district and municipality.
#' \code{bkg_ars} additionally returns the name of the administrative
#' association.
#'
#' @section Query language:
#' While other WFS interfaces like \code{\link{bkg_admin}} allow querying
#' using CQL or XML, \code{bkg_ags} and \code{bkg_ars} (using the GNDE service)
#' ONLY support XML. This has implications for the allowed query filters
#' (see \code{\link{wfs_filter}}).
#'
#' @seealso
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=f1fe5b66-25d6-44c7-b26a-88625aca9573}{\code{wfs_gnde} MIS record}
#'
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/wfs-gnde.pdf}{\code{wfs_gnde} documentation}
#'
#' \code{\link{bkg_geonames}} and \code{\link{bkg_endonyms}} for geographical names
#'
#' @export
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' # Either get geographical names for identifiers
#' bkg_ars(ars == "01")
#'
#' # ... or identifiers for geographical names
#' bkg_ars(gemeinde == "Köln")
bkg_ags <- function(...,
                    filter = NULL,
                    properties = NULL,
                    max = NULL) {
  filter <- wfs_filter(..., filter = filter, lang = "xml")

  bkg_wfs(
    "gn:Ags",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Ags",
    count = max,
    properties = properties,
    filter = filter
  )[-1]
}


#' @rdname bkg_ags
#' @export
bkg_ars <- function(...,
                    filter = NULL,
                    properties = NULL,
                    max = NULL) {
  filter <- wfs_filter(..., filter = filter, lang = "xml")

  bkg_wfs(
    "gn:Ars",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Ars",
    count = max,
    properties = properties,
    filter = filter
  )[-1]
}
