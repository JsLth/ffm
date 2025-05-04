bkg_dlm <- function(feature,
                    ...,
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
    type_name = feature,
    endpoint = "dlm250_inspire",
    layer = NULL,
    format = "text/xml; subtype=gml/3.2.1",
    epsg = epsg,
    properties = properties,
    filter = filter,
    count = max
  )
}


bkg_dlm_features <- function() {
  httr2::url_modify(
    "https://sgx.geodatenzentrum.de/",
    path = "wfs_dlm250_inspire",
    query = "request=GetCapabilities&service=wfs"
  )
}
