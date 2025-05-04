#' Toponyms
#' @description
#' Get geographic names including toponyms and endonyms.
#'
#' @inheritParams bkg_plates
#'
#' @returns A dataframe containing the following columns:
#'
#' @export
bkg_toponyms <- function(...,
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
    predicate = predicate,
    lang = "xml"
  )

  bkg_wfs(
    "gn:GnObjekt",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "GnObjekt",
    filter = filter,
    epsg = epsg,
    properties = properties,
    count = max
  )[-1]
}


bkg_endonyms <- function(...,
                         filter = NULL,
                         properties = NULL,
                         max = NULL) {
  filter <- wfs_filter(..., filter = filter, lang = "xml")

  bkg_wfs(
    "gn:Endonym",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Endonym",
    filter = filter,
    properties = properties,
    count = max
  )[-1]
}


bkg_admin_names <- function(...,
                            filter = NULL,
                            properties = NULL,
                            max = NULL) {
  filter <- wfs_filter(..., filter = filter)

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


bkg_country_names <- function(...) {
  filter <- wfs_filter(...)

  bkg_wfs(
    "gn:Land",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Land",
    filter = filter
  )[-1]
}


bkg_languages <- function(...) {
  filter <- wfs_filter(...)

  bkg_wfs(
    "gn:Sprache",
    endpoint = "gnde",
    format = "text/xml; subtype=gml/3.2.1",
    layer = "Sprache",
    filter = filter
  )[-1]
}


all_properties <- list(
  ags = "Official municipality key (Allgemeiner Gemeindeschlüssel, AGS)",
  ars = "Official regional key (Allgemeiner Regionalschlüssel, ARS)",
  rs = "Regionalschlüssel (legacy, now called ARS)",
  nnid = "National name identifier (Nationaler Namensidentifikator)",
  landesCode = "Federal state identifier",
  beschreibung = "Description",
  geoLaenge = "Geographical length (in degrees)",
  geoBreite = "Geographical width (in degrees)",
  hoehe = "Elevation above sea level",
  hoeheger = "Computed elevation (only for localities)",
  groesse = "Size",
  ewz = "Population of administrative areas",
  ewzger = "Computed population (only for localities)",
  gemteil = "Is the object part of a municipality?",
  virtuell = "Is the object name missing a real locality?",
  tukelement = "Unknown",
  hatLand_href = "Unknown",
  hatAgs_href = "Unknown",
  hatRs_href = "Unknown",
  hatArs_href = "Unknown",
  hasObjektart_href = "Unknown",
  hatEndonym_href = "Unknown",
  hatDlmLink_href = "Unknown",
  hatBearbeitung_href = "Unknown",
  hatZusatzLink_href = "Unknown",
  hatVorwahlLink_href = "Unknown",
  box = "Smallest enclosing rectangle for an object"
)
