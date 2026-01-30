#' Digital landscape model (DLM)
#' @description
#' Retrieve objects from the digital landscape model (DLM). DLMs are a
#' description of topographical objects of a landscape. Many other services
#' from the BKG are derived from the DLM.
#'
#' Although this function lets you download each feature type in the DLM, you
#' still need to know about what data is available and what the features in the
#' output actually mean. Since the DLM gets pretty complicated, you are advised
#' to take a look at the
#' \href{https://www.adv-online.de/GeoInfoDok/Aktuelle-Anwendungsschemata/AAA-Anwendungsschema-7.1.2-Referenz-7.1/OK_AAA-Anwendungsschema_7125415.html?imgUid=78f7a5be-17ae-4819-393b-216067bef8a0&uBasVariant=11111111-1111-1111-1111-111111111111}{GeoInfoDok}
#' object type catalog.
#'
#' This function interfaces the \code{dlm*} products of the BKG.
#'
#' @param type Feature type of the DLM. Can either be the identifier
#' (e.g., 41010) or its description (e.g., Siedlungsflaeche). The description
#' can either be prefixed with \code{AX_} or not. Providing an identifier
#' directly is generally faster as the description needs to be matched
#' by requesting the \code{GetCapabilities} endpoint of the service.
#'
#' Note that not all feature types are available for all shapes (see the
#' \code{shape} argument). To see all available feature types, you can run
#' \code{bkg_feature_types("dlm250")} or \code{bkg_feature_types("dlm1000")}.
#'
#' @param shape Geometry type of the feature type. Must be one of \code{"point"},
#' \code{"line"}, or \code{"polygon"}. Defaults to \code{"point"}. Not all
#' shapes are available for all feature types.
#' @param scale Scale of the geometries. Can be \code{"250"}
#' (1:250,000) or \code{"1000"} (1:1,000,000). Defaults to \code{"250"}.
#' @inheritParams bkg_admin
#' @inheritSection bkg_admin Query language
#'
#' @returns An sf tibble with the geometry suggested by \code{shape}.
#' The columns can vary depending of the selected feature type. The meanings
#' of the columns can also change depending on the feature type. Check out
#' the GeoInfoDok object type catalog for a detailed documentation of the
#' DLM metadata. Some more general columns are included for all feature types;
#' these include:
#' `r rd_properties_list(id, land, modellart, objart, objart_txt, objid, beginn, ende, objart_z, objid_z)`
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/dlm250.pdf}{\code{dlm250 documentation}}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=d6d50b87-b896-4696-9efb-66d1adc62337}{\code{dlm250} MIS record}
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' # Retrieve all train tracks in Leipzig
#' library(sf)
#' lzg <- st_sfc(st_point(c(12.37475, 51.340333)), crs = 4326)
#' lzg <- st_buffer(st_transform(lzg, 3035), dist = 10000, endCapStyle = "SQUARE")
#'
#' tracks <- bkg_dlm("Bahnstrecke", shape = "line", poly = lzg)
#' tracks
#'
#' plot(lzg)
#' plot(tracks$geometry, add = TRUE)
#'
#' # Filter all tracks that are not rail cargo
#' bkg_dlm("Bahnstrecke", shape = "line", poly = lzg, bkt == "1102")
#'
#' # Directly providing the identifier is faster
#' bkg_dlm("42014", shape = "line", poly = lzg)
bkg_dlm <- function(type,
                    ...,
                    shape = c("point", "line", "polygon"),
                    scale = c("250", "1000"),
                    bbox = NULL,
                    poly = NULL,
                    predicate = "intersects",
                    filter = NULL,
                    epsg = 3035,
                    properties = NULL,
                    max = NULL) {
  scale <- rlang::arg_match(scale)
  shape <- rlang::arg_match(shape)
  shape <- switch(shape, point = "f", line = "l", polygon = "p")
  type <- construct_dlm_type(type, shape = shape, scale = scale)

  filter <- wfs_filter(
    ...,
    filter = filter,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )

  bkg_wfs(
    type_name = type,
    endpoint = sprintf("dlm%s", scale),
    epsg = epsg,
    properties = properties,
    filter = filter,
    count = max
  )
}


construct_dlm_type <- function(type, shape, scale) {
  if (!grepl("^[0-9]+$", type)) {
    if (!startsWith(type, "AX_")) {
      type <- paste0("AX_", type)
    }

    all_types <- bkg_feature_types(sprintf("dlm%s", scale))
    is_type <- all_types$abstract %in% type
    if (!any(is_type)) {
      cli::cli_abort(c(
        "DLM feature type {.val {type}} does not exist.",
        "i" = paste(
          "You can use `bkg_feature_types(\"dlm{scale}\")`",
          "to find out which types are available."
        )
      ))
    }
    type <- all_types[is_type, ]$name

    if (length(type) > 1) {
      all_shapes <- regex_match(type, "_([fpl])$", i = 2)

      if (!shape %in% all_shapes) {
        alts <- setdiff(shape, c("f", "l", "p"))
        cli::cli_abort(c(
          "Shape {.val {shape}} is not available for feature type {.val {type}}.",
          "i" = "Consider changing `shape` to {.or {alts}}."
        ))
      }

      type <- type[all_shapes %in% shape]
    }
  } else {
    type <- sprintf("dlm250:objart_%s_%s", type, shape)
  }

  type
}
