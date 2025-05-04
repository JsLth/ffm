#' License plate regions
#' @description
#' description
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#'
bkg_plates <- function(...,
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
    properties = properties,
    ...
  )
}
