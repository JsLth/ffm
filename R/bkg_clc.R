#' Corine Land Cover
#' Retrieve land cover polygons in Germany based on the Corine Land Cover (CLC)
#' nomenclature. \href{https://land.copernicus.eu/en/products/corine-land-cover}{Corine Land Cover}
#' is a way to project by the European Commission to consistenly classify
#' both land cover and land use.
#'
#' @inheritParams bkg_admin
#'
#' @returns An sf dataframe with polygon geometries and the following columns:
#' \itemize{
#'  \item{\code{clc*}: CLC land cover classes for the given year. An overview
#'  of all CLC classes can be found in the
#'  \href{https://land.copernicus.eu/content/corine-land-cover-nomenclature-guidelines/html/}{Copernicus documentation}}.
#'  \item{\code{shape_length}: Circumference of the polygon in meters}
#'  \item{\code{shape_area}: Area of the polygon in square meters}
#' }
#'
#' @export
#'
#' @examples
#' # Get glaciers in Germany
#' bkg_clc(clc18 == "335")
#'
#' # Get all coastal wetlands
#' bkg_clc(clc18 %LIKE% "42%")
#'
#' # Get only wetlands in Lower Saxony
#' lowsax <- bkg_admin(level = "lan", scale = "5000", sn_l == "03", gf == 9)
#' bkg_clc(clc18 %LIKE% "4%", poly = lowsax)
bkg_clc <- function(...,
                    year = "2018",
                    bbox = NULL,
                    poly = NULL,
                    predicate = "intersects",
                    epsg = 3035,
                    properties = NULL,
                    max = NULL) {
  filter <- cql_filter(
    ...,
    bbox = bbox,
    poly = poly,
    predicate = predicate
  )

  endpoint <- sprintf("clc5_%s", year)
  bkg_wfs(
    type_name = paste0(endpoint, ":clc5"),
    endpoint = endpoint,
    epsg = epsg,
    count = max,
    properties = properties,
    cql_filter = filter
  )[-1]
}
