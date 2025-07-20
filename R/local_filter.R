local_filter <- function(.data,
                         ...,
                         bbox = NULL,
                         poly = NULL,
                         predicate = "intersects",
                         epsg = 3035,
                         properties = NULL) {
  .data <- subset(.data, ...)
  pred_fun <- get0(sprintf("st_%s", predicate), envir = getNamespace("sf"))

  if (is.null(pred_fun)) {
    cli::cli_abort(c(
      "Argument {.var predicate} does not refer to a valid predicate function ({.val {predicate}}).",
      "See `?sf::geos_binary_pred` for a list of supported binary predicate functions."
    ))
  }

  if (!is.null(poly)) {
    poly <- sf::st_union(poly)
  }

  if (!is.null(bbox)) {
    poly <- sf::st_as_sfc(sf::st_bbox(bbox))
  }

  if (!is.null(poly)) {
    .data <- .data[lengths(pred_fun(.data, poly)) > 0]
  }

  .data <- sf::st_transform(.data, 3035)

  if (!is.null(properties)) {
    .data <- .data[properties]
  }

  .data
}
