xml_filter <- function(...,
                       filter = NULL,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "intersects",
                       geom_property = "geom",
                       default_crs = 25832) {
  rlang::check_dots_unnamed()
  dots <- rlang::enquos(...)

  if (!is.null(filter)) {
    filter <- chr_as_xml(filter)
    filter <- xml2::as_list(filter, ns = xml2::xml_ns(filter))
  }

  ops <- unbox(lapply(dots, xml_operators)) %__% NULL
  geom_filter <- xml_spatial(
    bbox = bbox,
    poly = poly,
    predicate = predicate,
    geom = geom_property,
    default_crs = default_crs
  )

  filter_expr <- c(ops, filter, geom_filter)
  if (length(filter_expr) > 1) {
    filter_expr <- make_node("fes:And", filter_expr)
  }

  filter <- make_node("fes:Filter", filter_expr)
  new_filter(filter, type = "xml")
}


chr_as_xml <- function(x) {
  x <- sprintf(
    paste(
      '<wfs:GetFeature xmlns:wfs="http://www.opengis.net/wfs/2.0"',
      'xmlns:fes="http://www.opengis.net/fes/2.0">%s</wfs:GetFeature>'
    ),
    x
  )

  xml2::as_xml_document(x)
}


list_as_xml <- function(x, find = NULL) {
  x <- make_node(
    "wfs:GetFeature",
    x,
    attrs = list(
      `xmlns:fes` = "http://www.opengis.net/fes/2.0",
      `xmlns:gml` = "http://www.opengis.net/gml/3.2"
    )
  )
  x <- xml2::as_xml_document(unclass(x))

  if (!is.null(find)) {
    x <- xml2::xml_find_first(x, find)
  }

  x
}


#' @export
print.xml_filter <- function(x, ...) {
  x <- list_as_xml(x, find = ".//fes:Filter")
  cat(as.character(x))
}


xml_spatial <- function(bbox = NULL,
                        poly = NULL,
                        predicate = "intersects",
                        geom = "geom",
                        default_crs = 25832) {
  if (!is.null(poly)) {
    poly <- sf::st_union(poly)
    poly <- xml_predicate(
      poly,
      predicate = predicate,
      geom = geom,
      default_crs = default_crs
    )
  }

  if (!is.null(bbox)) {
    bbox <- sf::st_as_sfc(sf::st_bbox(bbox))
    bbox <- xml_predicate(
      bbox,
      predicate = predicate,
      geom = geom,
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
    make_node("fes:ValueReference", text = geom),
    gml
  ))
}


st_as_gml <- function(x) {
  tempf <- tempfile()
  sf::st_write(x, tempf, driver = "GML", quiet = TRUE)
  poly_gml <- xml2::read_xml(tempf)
  ns <- xml2::xml_ns(poly_gml)
  poly_gml <- xml2::xml_find_first(poly_gml, ".//ogr:geometryProperty", ns = ns)
  xml2::as_list(poly_gml, ns = ns)
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

  attrs <- if (identical(operator, "%LIKE%")) {
    list(
      wildCard = "%",
      singleChar = "_",
      escapeChar = "\\"
    )
  }

  operator <- do.call(switch, c(list(operator), xml_all_operators))

  query <- lapply(rhs, function(x) {
    make_node(
      sprintf("fes:%s", operator),
      xml_filter_single(lhs, x),
      attrs = attrs
    )
  })

  if (length(rhs) > 1) {
    query <- make_node("fes:Or", query)
  }

  query
}


xml_filter_single <- function(lhs, rhs, link = NULL) {
  filter <- list(
    make_node("fes:ValueReference", lhs),
    make_node("fes:Literal", rhs)
  )

  if (!is.null(link)) {
    filter <- make_node(link, filter)
  }

  filter
}


make_node <- function(name, text = list(), attrs = list()) {
  if (is.null(text)) return()
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

  query <- make_node(
    "wfs:Query",
    list(
      properties,
      filter
    ),
    attrs = list(typeNames = type_name, srsName = epsg)
  )

  root <- make_node(
    "wfs:GetFeature",
    query,
    attrs = list(
      service = "WFS",
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
