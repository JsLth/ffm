#' Geographical objects and endonyms
#' @description
#' Get geographic names including toponyms and endonyms. \code{bkg_geonames}
#' retrieves the geographical "objects" based on the digital landscape model
#' (DLM). These objects contain a set of metadata and a national name identifier
#' (NNID). These NNIDs can be used to join with the endonyms related to a
#' geographical object (\code{bkg_endonyms}).
#'
#' @param names If \code{TRUE}, includes endonyms of the geographical
#' objects in the output using \code{bkg_endonyms}. Technically, this can be
#' \code{FALSE}, because the endpoint only returns meta data on geographical
#' names by default. If this argument is \code{TRUE}, the output is merged with
#' the endonym table requiring an additional request. Defaults to \code{TRUE}.
#' @param ags If \code{TRUE}, resolves AGS codes to geographical names
#' using \code{\link{bkg_ags}}. Note that setting this to \code{TRUE} requires
#' an additional web request. Defaults to \code{FALSE}.
#' @param dlm If \code{TRUE}, adds the DLM identifier corresponding to the
#' national name identifiers (NNID) of the output using \code{\link{bkg_dlm}}.
#' Note that setting this to \code{TRUE} requires an additional web request.
#' Defaults to \code{FALSE}.
#' @param status If \code{TRUE}, adds the date of the objects last edit to
#' the output. Note that setting this to \code{TRUE} requires an additional
#' web request. Defaults to \code{FALSE}.
#' @inheritParams bkg_admin
#'
#' @returns A dataframe containing the following columns:
#' `r rd_properties_list(nnid, landesCode, beschreibung, geoLaenge, geoBreite, hoehe, hoeheger, groesse, ewz, ewzger, ags, gemteil, virtuell, ars)`
#'
#' If \code{ags = TRUE}, adds the output of \code{\link{bkg_ags}}. If
#' \code{dlm = TRUE}, adds a column \code{dlm_id} containing identifiers of
#' \code{\link{bkg_dlm}}.
#'
#' \code{bkg_endonyms} contains the following columns:
#' `r rd_properties_list(name, geschlecht)`
#'
#' These are also included in the output of \code{bkg_geonames} if
#' \code{names = TRUE}.
#'
#' @details
#' These functions make use of the GN-DE WFS, just like \code{\link{bkg_ags}},
#' \code{\link{bkg_ars}}, and \code{\link{bkg_area_codes}}. The infrastructure
#' behind it is actually quite sophisticated and this function may not live
#' up to these standards. You can use \code{\link{bkg_feature_types}} and
#' \code{\link{bkg_wfs}} to manually explore the service's endpoints if
#' required.
#'
#' @seealso
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=f1fe5b66-25d6-44c7-b26a-88625aca9573}{\code{wfs_gnde} MIS record}
#'
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/wfs-gnde.pdf}{\code{wfs_gnde} documentation}
#'
#' \code{\link{bkg_ags}} and \code{\link{bkg_ars}} for geographical names
#' of administrative areas
#'
#' @export
#'
#' @examplesIf ffm_run_examples()
#' # Plot geographical objects in Cologne
#' library(sf)
#' library(ggplot2)
#' cgn <- st_sfc(st_point(c(6.956944, 50.938056)), crs = 4326)
#' cgn <- st_buffer(st_transform(cgn, 3035), dist = 500)
#'
#' cgn_names <- bkg_geonames(poly = cgn)
#' st_geometry(cgn_names) <- st_centroid(st_geometry(cgn_names))
#' cgn_names <- sf::st_filter(cgn_names, cgn, .predicate = sf::st_within)
#' ggplot(cgn_names) + geom_sf_text(aes(label = name)) + theme_void()
bkg_geonames <- function(...,
                         names = TRUE,
                         ags = FALSE,
                         dlm = FALSE,
                         status = FALSE,
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
    geom_property = "box",
    predicate = predicate,
    lang = "xml"
  )

  res <- bkg_wfs(
    "gn:GnObjekt",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "GnObjekt",
    filter = filter,
    epsg = epsg,
    properties = properties,
    count = max
  )[-1]

  if (names) {
    names <- bkg_endonyms(nnid %in% unique(res$nnid))
    res <- merge(res, names[c("nnid", "name", "geschlecht")], by = "nnid")
  }

  if (ags) {
    ags <- bkg_ags(ags %in% unique(res$ags))
    res <- merge(res, ags, by = "ags")
  }

  if (dlm) {
    res$dlm_id <- nnid_to_dlm(res$nnid)
  }

  if (status) {
    res$status <- nnid_last_changed(res$nnid)
  }

  res <- res[!names(res) %in% c("tukelement", "rs")]
  res <- res[c(setdiff(names(res), "box"), "box")]
  sf::st_as_sf(as_df(res[!grepl("_href", names(res))]))
}


#' @rdname bkg_geonames
#' @export
bkg_endonyms <- function(...,
                         filter = NULL,
                         properties = NULL,
                         max = NULL) {
  filter <- wfs_filter(..., filter = filter, lang = "xml")

  res <- bkg_wfs(
    "gn:Endonym",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Endonym",
    filter = filter,
    properties = properties,
    count = max
  )[-1]

  res[!grepl("_href", names(res))]
}


nnid_to_dlm <- function(nnid) {
  filter <- wfs_filter(nnid %in% unique(nnid), lang = "xml")

  edits <- bkg_wfs(
    "gn:DlmLink",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "DlmLink",
    filter = filter
  )[-1]

  edits$ui_ID[match(nnid, edits$nnid)]
}


nnid_last_changed <- function(nnid) {
  filter <- wfs_filter(nnid %in% unique(nnid), lang = "xml")

  edits <- bkg_wfs(
    "gn:Bearbeitung",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Bearbeitung",
    filter = filter
  )[-1]

  edits$datum[match(nnid, edits$nnid)]
}
