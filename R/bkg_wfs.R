#' BKG WFS
#' @description
#' Low-level interface to BKG-style web feature services (WFS). This function
#' is used in all high-level functions of \code{ffm} that depend on a WFS,
#' e.g., \code{\link{bkg_admin}}.
#'
#' \code{bkg_feature_types} lists all available feature types for a given
#' endpoint.
#'
#' @param type_name Feature type of the WFS to retrieve. You can use
#' \code{bkg_feature_types} to retrieve a list of feature type names for a
#' given endpoint.
#' @param endpoint Endpoint to interface. Note that \code{wfs_} is appended
#' and only the rest of the product name must be provided. For example,
#' \code{wfs_vg250} becomes \code{vg250}. Defaults to the value of
#' \code{type_name}.
#' @param version Service version of the WFS. Usually 2.0.0, but some services
#' still use 1.0.0 or 1.1.0.
#' @param method HTTP method to use for the request. \code{GET} requests
#' provide parameters using URL queries. Filters must be provided as CQL
#' queries. While this is less error-prone, it allows a maximum number of
#' only 2048 characters. Especially when providing more sophisticated spatial
#' queries, \code{GET} queries are simply not accepted by the services. In
#' these cases it makes sense to use \code{POST} requests instead.
#'
#' If \code{NULL}, the method is inferred from the type of filter query
#' provided to \code{filter} (either XML or CQL). If no filter is provided,
#' the method is inferred from \code{getOption("ffm_query_language")}.
#' @param format Content type of the output. This value heavily depends
#' the endpoint queried. Most services allow \code{application/json} but some
#' only support GML outputs. When in doubt, inspect the \code{GetCapabilities}
#' of the target service. Defaults to \code{"application/json"}.
#' @param layer If \code{format} specifies a GML output, \code{layer}
#' specifies which layer from the downloaded GML file to read. Only necessary
#' if the GML file actually contains multiple layers. Defaults to \code{NULL}.
#' @param epsg Numeric value giving the EPSG identifier of the coordinate
#' reference system (CRS). The EPSG code is automatically formatted in a
#' OGC-compliant manner. Note that not all EPSG codes are supported. Inspect
#' the \code{GetCapabilities} of the target service to find out which
#' EPSG codes are available. Defaults to EPSG:3035.
#' @param properties Names of columns to include in the output. Defaults to
#' \code{NULL} (all columns).
#' @param filter A WFS filter query (CQL or XML) created by
#' \code{\link{wfs_filter}}.
#' @param ... Further parameters passed to the WFS query. In case of
#' \code{POST} requests, additional namespaces that may be necessary to query
#' the WFS. Argument names are interpreted as the prefix (e.g.
#' \code{xmlns:wfs}) and argument values as namespace links.
#'
#' @returns An sf tibble
#'
#' @export
#'
#' @seealso
#' \code{\link{bkg_wcs}} for a low-level WCS interface
#'
#' \code{\link{wfs_filter}} for filter constructors
#'
#' @examplesIf getFromNamespace("ffm_run_examples", ns = "ffm")()
#' bkg_feature_types("vg5000_0101")
#'
#' bkg_wfs(
#'   "vg5000_lan",
#'   endpoint = "vg5000_0101",
#'   count = 5,
#'   properties = "gen",
#'   epsg = 4326
#' )[-1]
#'
#' # Filters are created using `wfs_filter()`
#' bkg_wfs(
#'   "vg5000_krs",
#'   endpoint = "vg5000_0101",
#'   properties = "gen",
#'   filter = wfs_filter(sn_l == 10)
#' )[-1]
bkg_wfs <- function(type_name,
                    endpoint = type_name,
                    version = "2.0.0",
                    method = NULL,
                    format = "application/json",
                    layer = NULL,
                    epsg = 3035,
                    properties = NULL,
                    filter = NULL,
                    ...) {
  method <- method %||%
    switch(class(filter)[1], xml_filter = "POST", cql_filter = "GET") %||%
    switch(query_lang(), cql = "GET", xml = "POST")

  if (!is.null(epsg)) {
    epsg <- sprintf("EPSG:%s", epsg)
  }

  if (!is.null(properties)) {
    properties <- c(properties, "geom")
  }

  req <- httr2::request(sgx_base())
  req <- httr2::req_url_path(req, sprintf("wfs_%s", endpoint))

  req <- switch(
    method,
    POST = bkg_wfs_post_query(
      req,
      type_name,
      version = version,
      format = format,
      epsg = epsg,
      properties = properties,
      filter = filter,
      ...
    ),
    GET = bkg_wfs_get_query(
      req,
      type_name,
      version = version,
      format = format,
      epsg = epsg,
      properties = properties,
      filter = filter,
      ...
    )
  )

  if (nchar(req$url) > 2048) {
    cli::cli_abort(c(
      "Query is too large to be handled by CQL queries.",
      "i" = "Consider setting `options(ffm_query_language = \"xml\")`.",
      "i" = "Alternatively, try to reduce the size of your query."
    ))
  }

  if (isTRUE(getOption("ffm_debug", FALSE))) {
    switch(
      method,
      GET = cli::cli_verbatim(utils::URLdecode(req$url)),
      POST = cli::cli_verbatim(req$body$data)
    )
  }

  req <- httr2::req_error(
    req,
    is_error = is_wfs_error,
    body = get_resp_error_details
  )

  req <- maybe_retry(req)

  if (grepl("json", format)) {
    resp <- httr2::req_perform(req)
    res <- httr2::resp_body_string(resp)
    sf::read_sf(res)
  } else {
    tempf <- tempfile()
    on.exit(unlink(tempf))
    resp <- httr2::req_perform(req, path = tempf)
    if (is.null(layer)) {
      sf::read_sf(tempf)
    } else {
      sf::read_sf(tempf, layer = layer)
    }
  }
}


#' @rdname bkg_wfs
#' @export
bkg_feature_types <- function(endpoint) {
  req <- httr2::request(sgx_base())
  req <- httr2::req_url_path(req, sprintf("wfs_%s", endpoint))
  req <- httr2::req_url_query(req, request = "GetCapabilities", service = "wfs")
  req <- httr2::req_error(
    req,
    is_error = is_wfs_error,
    body = get_resp_error_details
  )
  resp <- httr2::req_perform(req)
  doc <- httr2::resp_body_xml(resp)

  types <- xml2::xml_find_all(doc, ".//wfs:FeatureType")
  names <- xml2::xml_text(xml2::xml_find_all(types, ".//wfs:Name"))
  titles <- xml2::xml_text(xml2::xml_find_all(types, ".//wfs:Title"))
  abstracts <- xml2::xml_text(xml2::xml_find_all(types, ".//wfs:Abstract"))
  as_df(data.frame(name = names, title = titles, abstract = abstracts))
}


bkg_wfs_post_query <- function(req,
                               type_name,
                               version = "2.0.0",
                               format = "application/json",
                               epsg = 3035,
                               properties = NULL,
                               filter = NULL,
                               count = NULL,
                               ...) {
  httr2::req_body_raw(req, as.character(make_wfs_xml(
    type_name,
    version = version,
    format = format,
    epsg = epsg,
    properties = properties,
    filter = filter,
    count = count,
    ...
  )))
}


bkg_wfs_get_query <- function(req,
                              type_name,
                              version = "2.0.0",
                              format = "application/json",
                              epsg = 3035,
                              properties = NULL,
                              filter = NULL,
                              ...) {
  req <- httr2::req_url_query(
    req,
    service = "wfs",
    version = version,
    request = "GetFeature",
    outputFormat = format,
    srsName = epsg,
    PropertyName = properties,
    cql_filter = filter,
    ...,
    .multi = "comma"
  )

  if (version == "2.0.0") {
    req <- httr2::req_url_query(req, typenames = type_name)
  } else {
    req <- httr2::req_url_query(req, typename = type_name)
  }

  req
}


# necessary because some endpoints return HTTP200 although an error occured
is_wfs_error <- function(resp) {
  grepl("ExceptionReport", httr2::resp_body_string(resp)) ||
    !identical(httr2::resp_status(resp), 200L)
}


get_resp_error_details <- function(resp) {
  content <- httr2::resp_body_xml(resp)
  parse_wfs_error(content) %||%
    parse_service_error(content)
}


parse_wfs_error <- function(xml) {
  if (identical(xml2::xml_name(xml), "ExceptionReport")) {
    exception <- xml2::xml_find_first(xml, "ows:Exception")
    code <- xml2::xml_attrs(exception)["exceptionCode"]
    text <- xml2::xml_find_first(exception, "ows:ExceptionText")
    text <- unescape_xml(xml2::xml_text(text))
    text <- strsplit(text, "\n")[[1]]
    text[1] <- paste(c(code, text[1]), collapse = ": ")
    names(text)[1] <- "x"
    names(text)[-1] <- "i"
    text
  }
}


parse_service_error <- function(xml) {
  if (identical(xml2::xml_name(xml), "ServiceExceptionReport")) {
    exception <- xml2::xml_find_first(xml, "d1:ServiceException")
    code <- xml2::xml_attr(exception, "code")
    c("x" = code)
  }
}


unescape_xml <- function(x) {
  xml2::xml_text(xml2::read_xml(sprintf("<x>%s</x>", x)))
}


maybe_retry <- function(req) {
  retries <- getOption(
    "ffm_retries",
    suppressWarnings(as.integer(Sys.getenv("FFM_RETRIES", "0"))) %|||% 0
  )

  if (retries > 0) {
    req <- httr2::req_retry(req, max_tries = retries)
  }

  req
}


sgx_base <- function() "https://sgx.geodatenzentrum.de/"
