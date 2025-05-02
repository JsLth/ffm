xml_filter <- function(...,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "intersects",
                       default_crs = 25832) {
  rlang::check_dots_unnamed()
  dots <- rlang::enquos(...)

  ops <- unbox(lapply(dots, xml_operators, link = if (length(dots) > 1) "And"))
  geom_filter <- xml_spatial(
    bbox = bbox,
    poly = poly,
    predicate = predicate,
    default_crs = default_crs
  )

  filter <- make_node("fes:Filter", c(ops, geom_filter))
  class(filter) <- "xml_filter"
  filter
}


#' @export
print.xml_filter <- function(x, ...) {
  x <- make_node(
    "wfs:GetFeature",
    x,
    attrs = list(`xmlns:fes` = "http://www.opengis.net/fes/2.0")
  )
  x <- as_xml_document(unclass(x))
  x <- xml2::xml_find_first(x, ".//fes:Filter")
  cat(as.character(x))
}


xml_spatial <- function(bbox = NULL,
                        poly = NULL,
                        predicate = "intersects",
                        default_crs = 25832) {
  if (!is.null(poly)) {
    poly <- sf::st_union(poly)
    poly <- xml_predicate(
      poly,
      predicate = predicate,
      default_crs = default_crs
    )
  }

  if (!is.null(bbox)) {
    bbox <- sf::st_as_sfc(sf::st_bbox(bbox))
    bbox <- xml_predicate(
      bbox,
      predicate = predicate,
      default_crs = default_crs
    )
  }

  c(poly, bbox)
}


xml_predicate <- function(poly,
                          predicate = "intersects",
                          geom = "geom",
                          default_crs = 25832) {
  if (!is.na(sf::st_crs(poly))) {
    poly <- sf::st_transform(poly, crs = default_crs)
  } else {
    sf::st_crs(poly) <- default_crs
  }

  gml <- st_as_gml(sf::st_geometry(poly))
  make_node(sprintf("fes:%s", to_title(predicate)), list(
    make_node("fes:ValueReference", text = "geom"),
    gml
  ))
}


st_as_gml <- function(x) {
  tempf <- tempfile()
  sf::st_write(x, tempf, driver = "GML", quiet = TRUE)
  poly_gml <- xml2::read_xml(tempf)
  poly_gml <- xml2::xml_find_first(
    poly_gml,
    ".//gml:Polygon",
    ns = xml2::xml_ns(poly_gml)
  )
  xml2::as_list(poly_gml)
}


xml_operators <- function(quo, link = NULL) {
  query <- parse_pseudo_query(quo)
  rhs <- query$rhs
  lhs <- query$lhs
  operator <- query$operator

  if (!operator %in% names(xml_all_operators)) {
    expr <- rlang::expr_deparse(rlang::quo_get_expr(quo))
    cli::cli_abort(c(
      "Operator `{operator}` is not supported in `{expr}`.",
      "i" = "Try one of the following operators: {names(xml_all_operators)}."
    ))
  }

  operator <- do.call(switch, c(list(operator), xml_all_operators))

  query <- make_node(
    sprintf("fes:%s", operator),
    lapply(rhs, xml_filter_single, lhs, link = if (length(rhs) > 1) "Or")
  )

  if (!is.null(link)) {
    query <- make_node("And", query)
  }

  query
}


xml_filter_single <- function(rhs, lhs, link = NULL) {
  filter <- list(
    make_node("fes:ValueReference", lhs),
    make_node("fes:Literal", rhs)
  )

  if (!is.null(link)) {
    filter <- make_node(link, filter)
  }

  filter
}


make_node <- function(name, text = NULL, attrs = list()) {
  text <- if (is.list(text)) text else list(text)
  attributes(text) <- attrs
  node <- list(text)
  names(node) <- name
  list(node)
}


make_wfs_xml <- function(type_name,
                         version = "2.0.0",
                         format = "application/json",
                         epsg = 3035,
                         properties = NULL,
                         filter = NULL,
                         count = NULL) {
  if (!is.null(properties)) {
    properties <- lapply(
      properties,
      function(prop) make_node("wfs:PropertyName", prop)
    )
  }

  if (!is.null(filter)) {
    filter <- make_node("fes:Filter", filter)
  }

  query <- make_node(
    "wfs:Query",
    list(
      properties
    ),
    attrs = list(typeNames = type_name, srsName = epsg)
  )

  root <- make_node(
    "wfs:GetFeature",
    query,
    attrs = list(
      service = "wfs",
      version = version,
      outputFormat = format,
      `xmlns:wfs` = "http://www.opengis.net/wfs/2.0",
      `xmlns:fes` = "http://www.opengis.net/fes/2.0",
      `xmlns:gml` = "http://www.opengis.net/gml/3.2",
      `xmlns:xsi` = "http://www.w3.org/2001/XMLSchema-instance",
      count = count
    )
  )

  xml2::as_xml_document(root)
}


xml_all_operators <- list(
  "==" = "PropertyIsEqualTo",
  "!=" = "PropertyIsNotEqualTo",
  ">" = "PropertyIsGreaterThan",
  "<" = "PropertyIsLessThan",
  ">=" = "PropertyIsGreaterThanOrEqualTo",
  "<=" = "PropertyIsLessThanOrEqualTo",
  "%LIKE%" = "PropertyIsLike",
  "%in%" = "PropertyIsEqualTo"
)
