#' Official keys
#' @description
#' Retrieve geographical names associated with official municipality keys
#' and regional keys. To retrieve their polygon geometries, see
#' \code{\link{bkg_admin}}.
#'
#' @inheritParams bkg_admin
#' @returns A dataframe containing the respective identifier and geographical
#' names related to their state, government region, district and municipality.
#' \code{bkg_ars} additionally returns the name of the administrative
#' association.
#'
#' @export
#'
#' @examples
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
