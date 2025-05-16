#' Regions of authority
#' @description
#' Retrieve regions of administrative responsibility for job centers,
#' employment agencies, offices of employment agencies, regional
#' directorates of the Federal Employment Agency as well as local, regional,
#' and higher regional courts.
#'
#' @param authority Type of authority for which to retrieve regions of
#' responsibility. Must be one of \code{"employment_agencies"},
#' \code{"employment_offices"}, \code{"job_centers"}, \code{"directorates"},
#' \code{"local_courts"}, \code{"regional_courts"}, or
#' \code{"higher_regional_courts"}.
#' @inheritParams bkg_admin
#'
#' @returns An sf tibble with multipolygon geometries and the following
#' columns:
#'
#' \itemize{
#'  \item{\code{id}: Identifier of the authority region}
#'  \item{\code{dst_id}: Identifier of the authority office}
#'  \item{\code{uebergeord}: Name of the superior authority}
#'  \item{\code{name}: Name of the authority}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/bzb-open.pdf}{\code{bzb-open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=8A7C5BC0-F323-43C8-A80B-1B87B0A128C7}{\code{bzb-open} MIS record}
#'
#' @family non-administrative regions
#'
#' @examplesIf ffm_run_examples()
#' # Get only local courts that are subordinates of the regional court Cottbus
#' bkg_authorities(
#'   authority = "local_courts",
#'   uebergeord %LIKE% "%Cottbus",
#'   uebergeord %LIKE% "Landgericht%"
#' )
bkg_authorities <- function(authority,
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

  authority <- switch(
    authority,
    employment_agencies = "ba_arbeitsagenturen",
    employment_offices = "ba_geschaefsstellen",
    job_centers = "ba_jobcenter",
    directorates = "ba_regionaldirektionen",
    local_courts = "gerichte_amtsgerichte",
    regional_courts = "gerichte_landgerichte",
    higher_regional_courts = "gerichte_oberlandesgerichte"
  )

  bkg_wfs(
    sprintf("bzb-open:%s", authority),
    endpoint = "bzb_open",
    version = "2.0.0",
    maxfeatures = max,
    filter = filter,
    epsg = epsg,
    properties = properties
  )
}
