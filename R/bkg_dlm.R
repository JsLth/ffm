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
  doc <- xml2::read_xml("https://sgx.geodatenzentrum.de/wfs_dlm250_inspire?request=GetCapabilities&service=wfs")
  types <- xml2::xml_find_all(doc, ".//wfs:FeatureType")
  names <- xml2::xml_text(xml2::xml_find_all(types, ".//wfs:Name"))
  titles <- xml2::xml_text(xml2::xml_find_all(types, ".//wfs:Title"))
  as_df(data.frame(name = names, title = titles))
}
