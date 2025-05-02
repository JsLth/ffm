cql_filter <- function(...,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "intersects",
                       default_crs = 25832) {
  rlang::check_dots_unnamed()
  dots <- rlang::enquos(...)

  ops <- vapply(dots, cql_operators, FUN.VALUE = character(1))
  geom_filter <- cql_spatial(
    bbox = bbox,
    poly = poly,
    predicate = predicate,
    default_crs = default_crs
  )

  all_filters <- c(ops, geom_filter)
  filter <- paste(all_filters, collapse = " AND ", recycle0 = TRUE) %zchar% NULL
  class(filter) <- "cql_filter"
  filter
}


#' @export
print.cql_filter <- function(x, ...) {
  cat(x, "\n", ...)
  invisible(x)
}


cql_spatial <- function(bbox = NULL,
                        poly = NULL,
                        predicate = "intersects",
                        default_crs = 25832) {
  if (!is.null(poly)) {
    poly <- sf::st_union(poly)
    poly <- cql_predicate(
      poly,
      predicate = predicate,
      default_crs = default_crs
    )
  }

  if (!is.null(bbox)) {
    bbox <- sf::st_as_sfc(sf::st_bbox(bbox))
    bbox <- cql_predicate(
      bbox,
      predicate = predicate,
      default_crs = default_crs
    )
  }

  c(poly, bbox)
}


cql_predicate <- function(poly,
                          predicate = "intersects",
                          geom = "geom",
                          default_crs = 25832) {
  if (!is.na(sf::st_crs(poly))) {
    poly <- sf::st_transform(poly, crs = default_crs)
  }

  wkt <- sf::st_as_text(sf::st_geometry(poly))
  poly <- sprintf("%s(%s, %s)", predicate, geom, wkt)
}


cql_operators <- function(quo) {
  query <- parse_pseudo_query(quo)
  rhs <- query$rhs
  lhs <- query$lhs
  operator <- query$operator
  rhs_is_scalar <- length(rhs) == 1

  if (!operator %in% names(cql_all_operators)) {
    expr <- rlang::expr_deparse(rlang::quo_get_expr(quo))
    cli::cli_abort(c(
      "Operator `{operator}` is not supported in `{expr}`.",
      "i" = "Try one of the following operators: {names(cql_all_operators)}."
    ))
  }

  if (is.character(rhs)) {
    rhs <- sQuote(rhs, q = FALSE)
  } else {
    rhs <- format(rhs, scientific = FALSE)
  }

  rhs <- paste(rhs, collapse = ", ")

  if (!rhs_is_scalar) {
    rhs <- sprintf("(%s)", rhs)
  }

  operator <- do.call(switch, c(list(operator), cql_all_operators))
  paste(lhs, operator, rhs)
}


cql_all_operators <- list(
  "==" = "=",
  "!=" = "<>",
  "<" = "<",
  ">" = ">",
  ">=" = ">=",
  "<=" = "<=",
  "%LIKE%" = "LIKE",
  "%ILIKE%" = "ILIKE",
  "%in%" = "IN"
)
