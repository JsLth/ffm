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
                    method = c("GET", "POST"),
                    format = "application/json",
                    layer = NULL,
                    epsg = NULL,
                    properties = NULL,
                    ...) {
  method <- rlang::arg_match(method)

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
      ...
    ),
    GET = bkg_wfs_get_query(
      req,
      type_name,
      version = version,
      format = format,
      epsg = epsg,
      properties = properties,
      ...
    )
  )

  if (nchar(req$url) > 2048) {
    cli::cli_abort(c(
      "Query is too large to be handled by CQL queries.",
      "i" = "Consider setting `options(ffm_query_language = \"XML\")`.",
      "i" = "Alternatively, try to reduce the size of your query."
    ))
  }

  if (isTRUE(getOption("bkg_debug", FALSE))) {
    cli::cli_verbatim(utils::URLdecode(req$url))
  }

  req <- httr2::req_error(req, body = get_resp_error_details)

  if (!grepl("xml|gml", format)) {
    resp <- httr2::req_perform(req)
    res <- httr2::resp_body_string(resp)
    sf::read_sf(res)
  } else {
    sf::read_sf(req$url, layer = layer)
  }


}


bkg_wfs_post_query <- function(req,
                               type_name,
                               version = "2.0.0",
                               format = "application/json",
                               epsg = 3035,
                               properties = NULL,
                               filter = NULL,
                               count = NULL) {
  httr2::req_body_raw(req, as.character(make_wfs_xml(
    type_name,
    version = version,
    format = format,
    epsg = epsg,
    properties = properties,
    filter = filter,
    count = count
  )))
}


bkg_wfs_get_query <- function(req,
                              type_name,
                              version = "2.0.0",
                              format = "application/json",
                              epsg = 3035,
                              properties = NULL,
                              ...) {
  req <- httr2::req_url_query(
    req,
    service = "wfs",
    version = version,
    request = "GetFeature",
    outputFormat = format,
    srsName = epsg,
    PropertyName = properties,
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


get_resp_error_details <- function(resp) {
  content <- httr2::resp_body_string(resp)
  msg <- NULL

  code <- if (grepl("exceptionCode", content, fixed = TRUE)) {
    regex_match(content, "exceptionCode=\"(.*?)\"", i = 2)
  }

  if (is.null(code) && grepl("code=", content, fixed = TRUE)) {
    code <- regex_match(content, "code=\"(.*?)\"", i = 2)
  }

  msg <- if (grepl("ExceptionText", content, fixed = TRUE)) {
    regex_match(content, "<ows:ExceptionText>(.*?)</ows:ExceptionText>", i = 2)
  }

  paste(c(code, msg), collapse = ": ") %zchar% NULL
}


