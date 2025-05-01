sgx_base <- function() "https://sgx.geodatenzentrum.de/"


bkg_info <- function(product, ..., max = NULL) {
  bkg_wfs(
    sprintf("info:%s", product),
    endpoint = "info",
    version = "2.0.0",
    count = max,
    ...
  )
}


bkg_wfs <- function(type_name,
                    endpoint = type_name,
                    version = "2.0.0",
                    format = "application/json",
                    layer = NULL,
                    ...) {
  req <- httr2::request(sgx_base())
  req <- httr2::req_url_path(req, sprintf("wfs_%s", endpoint))
  req <- httr2::req_url_query(
    req,
    service = "wfs",
    version = version,
    request = "GetFeature",
    outputFormat = format,
    ...,
    .multi = "comma"
  )

  if (version == "2.0.0") {
    req <- httr2::req_url_query(req, typenames = type_name)
  } else {
    req <- httr2::req_url_query(req, typename = type_name)
  }

  if (isTRUE(getOption("bkg_debug", FALSE))) {
    cli::cli_verbatim(utils::URLdecode(req$url))
  }

  req <- httr2::req_cache(req, path = tempfile())
  req <- httr2::req_error(req, body = function(resp) {
    content <- httr2::resp_body_string(resp)

    if (grepl("exceptionCode", content, fixed = TRUE)) {
      code <- regex_match(content, "exceptionCode=\"(.*?)\"", i = 2)
    }

    if (grepl("ExceptionText", content, fixed = TRUE)) {
      msg <- regex_match(content, "<ows:ExceptionText>(.*?)</ows:ExceptionText>", i = 2)
    }

    paste(c(code, msg), collapse = ": ")
  })

  if (!grepl("xml|gml", format)) {
    resp <- httr2::req_perform(req)
    res <- httr2::resp_body_string(resp)
    sf::read_sf(res)
  } else {
    sf::read_sf(req$url, layer = layer)
  }


}


cql_filter <- function(...,
                       bbox = NULL,
                       poly = NULL,
                       predicate = "within") {
  rlang::check_dots_unnamed()
  dots <- rlang::enquos(...)

  ops <- vapply(dots, cql_operators, FUN.VALUE = character(1))
  geom_filter <- cql_spatial(bbox = bbox, poly = poly, predicate = predicate)

  all_filters <- c(ops, geom_filter)
  paste(all_filters, collapse = " AND ", recycle0 = TRUE) %zchar% NULL
}


cql_operators <- function(quo) {
  env <- rlang::quo_get_env(quo)
  expr <- rlang::quo_get_expr(quo)

  if (!rlang::is_call(expr, name = names(cql_all_operators), n = 2)) {
    cli::cli_abort(c(
      "Invalid filter query provided.",
      "i" = paste(
        "A filter query must contain a property name of the left, a",
        "supported operator in the middle and a vector on the right."
      )
    ))
  }

  operator <- rlang::as_label(expr[[1]])
  lhs <- expr[[2]]
  rhs <- expr[[3]]
  rhs <- rlang::eval_bare(rhs, env = env)
  rhs_is_scalar <- length(rhs) == 1

  if (is.character(rhs)) {
    rhs <- sQuote(rhs, q = FALSE)
  } else {
    rhs <- format(rhs, scientific = FALSE)
  }

  rhs <- paste(rhs, collapse = ", ")

  if (!rhs_is_scalar) {
    rhs <- sprintf("(%s)", rhs)
  }

  if (!rlang::is_symbol(lhs)) {
    cli::cli_abort(paste(
      "The left-hand side of queries passed to `...` must be",
      "the name of a single column in the output."
    ))
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
  "~" = "~",
  "%!~%" = "!~",
  "%LIKE%" = "LIKE",
  "%ILIKE%" = "ILIKE",
  "%in%" = "IN"
)


cql_spatial <- function(bbox = NULL, poly = NULL, predicate = "within") {
  if (!is.null(poly)) {
    poly <- cql_predicate(poly, predicate = predicate)
  }

  if (!is.null(bbox)) {
    bbox <- sf::st_as_sfc(sf::st_bbox(bbox))
    bbox <- cql_predicate(bbox, predicate = predicate)
  }

  c(poly, bbox)
}


cql_predicate <- function(poly, predicate = "within", geom = "geom") {
  wkt <- sf::st_as_text(sf::st_geometry(poly))
  poly <- sprintf("%s(%s, %s)", predicate, geom, wkt)
}


is_formula <- function(x) {
  vapply(x, inherits, logical(1), "formula")
}


defuse_dots <- function(...) {
  as.list(substitute(alist(...))[-1])
}


"%zchar%" <- function(x, y) if (!nzchar(x)) y else x
"%__%" <- function(x, y) if (!length(x)) y else x
