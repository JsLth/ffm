#' WFS filters
#' @description
#' Utility functions to construct XML or CQL queries. These functions are the
#' backend of the \code{filter} argument in the filter capabilities of all
#' \code{ffm} functions that interact with a WFS (e.g., \code{\link{bkg_admin}},
#' \code{\link{bkg_clc}} or \code{bkb_geonames}).
#'
#' @inheritParams bkg_admin
#' @param default_crs A WFS defines a default CRS in which coordinates for
#' spatial filtering have to be provided. For BKG services, this is usually
#' EPSG:25832. All sf objects provided through \code{bbox} or \code{poly} are first
#' transformed to this CRS before creating the query.
#' @param lang Query language to use for constructing the query. One of
#' \code{"cql"} and \code{"xml"}. By default, almost all \code{ffm} functions
#' use CQL because it is simpler and less prone to errors. However, CQL is
#' limited in terms of query size. Especially when providing a \code{poly},
#' URLs can become so long that the WFS server will decline them. XML can be a
#' valid alternative to construct large queries. Additionally, some services
#' like the one used by \code{\link{bkg_geonames}} only support XML. If
#' \code{NULL}, defaults to \code{getOption("ffm_query_language")}.
#'
#' @returns A CQL query or an XML query depending on the \code{lang} argument.
#'
#' @export
#'
#' @examples
#' # CQL and XML support mostly the same things
#' wfs_filter(ags %LIKE% "05%", lang = "cql")
#' wfs_filter(ags %LIKE% "05%", lang = "xml")
#'
#' bbox <- c(xmin = 5, ymin = 50, xmax = 7, ymax = 52)
#' wfs_filter(bbox = bbox, lang = "cql")
#' wfs_filter(bbox = bbox, lang = "xml")
wfs_filter <- function(...,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "intersects",
                       default_crs = 25832,
                       lang = NULL) {
  lang <- lang %||% getOption("ffm_query_language", "cql")
  filter_fun <- switch(lang, cql = cql_filter, xml = xml_filter)

  filter_fun(
    ...,
    bbox = bbox,
    poly = poly,
    predicate = predicate,
    default_crs = default_crs
  )
}


parse_pseudo_query <- function(quo) {
  env <- rlang::quo_get_env(quo)
  expr <- rlang::quo_get_expr(quo)

  if (!rlang::is_call(expr, n = 2)) {
    cli::cli_abort(c(
      "Invalid filter query provided.",
      "i" = paste(
        "A filter query must contain a property name of the left, a",
        "supported operator in the middle and a vector on the right."
      )
    ))
  }

  if (!rlang::is_symbol(expr[[2]])) {
    cli::cli_abort(paste(
      "The left-hand side of queries passed to `...` must be",
      "the name of a single column in the output."
    ))
  }

  operator <- rlang::as_label(expr[[1]])
  lhs <- rlang::as_label(expr[[2]])
  rhs <- expr[[3]]
  rhs <- rlang::eval_bare(rhs, env = env)



  list(lhs = lhs, rhs = rhs, operator = operator)
}
