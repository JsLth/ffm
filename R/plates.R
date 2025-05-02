#' License plate regions
#' @description
#' description
#'
#' @inheritParams bkg_admin
#'
#'
bkg_plates <- function(...,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "intersects",
                       epsg = 3035,
                       properties = NULL,
                       max = NULL) {
  filter <- cql_filter(
    ...,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )

  bkg_wfs(
    "kfz250",
    version = "1.1.0",
    maxfeatures = max,
    cql_filter = filter,
    epsg = epsg,
    properties = properties,
    ...
  )
}
