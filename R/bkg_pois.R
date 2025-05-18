#' Airports
#' @description
#' Retrieve international, regional, and special airports in Germany. Small
#' landing sites are not included.
#'
#' These functions interface the \code{wfs_poi_open} product of the BKG.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe containing the following columns: \itemize{
#'   \item{\code{name}}: Geographical name of the POI
#'   \item{\code{gemeinde}}: Municipality name
#'   \item{\code{verwaltung}}: Administrative association name
#'   \item{\code{kreis}}: District name
#'   \item{\code{regierungs}}: Government region name
#'   \item{\code{bundesland}}: Federal state name
#'   \item{\code{poi_id}: Unique primary key of a point of interest}
#'   \item{\code{icao_code}: ICAO code of the airport}
#'   \item{\code{typ}: Type of airport. Can be one of the following: \itemize{
#'     \item{international: International airport}
#'     \item{regional: Regional airport}
#'     \item{Sonderflughafen: Special airport}
#'   }}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get all airports in NRW
#' airports <- bkg_airports(ars %LIKE% "05%")
#' nrw <- bkg_admin(level = "lan", sn_l == "05")
#' plot(nrw$geometry)
#' plot(airports$geometry, add = TRUE, pch = 16)
bkg_airports <- function(...,
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
    "flughaefen",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Border crossings
#' @description
#' Retrieve border crossings in Germany. A road is a border crossing if it
#' touches an international border and it continues on the foreign side.
#' This includes ferry connections but not dirt roads.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe with the following columns: \itemize{
#'  \item{\code{name}}: Geographical name of the POI
#'  \item{\code{gemeinde}}: Municipality name
#'  \item{\code{verwaltung}}: Administrative association name
#'  \item{\code{kreis}}: District name
#'  \item{\code{regierungs}}: Government region name
#'  \item{\code{bundesland}}: Federal state name
#'  \item{\code{ort}: Name of the nearest place}
#'  \item{\code{strasse}: Number or label of the border-crossing street}
#'  \item{\code{typ}: Type of checkpoint; always "Straßenverkehr"}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get all border crossings in Bavaria
#' crossings <- bkg_crossings(bundesland == "Bayern")
#' plot(crossings$geometry, pch = 16)
bkg_crossings <- function(...,
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
    "grenzuebergaenge",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Stations and stops
#' @description
#' Retrieve data on public transport stations and stops in Germany. Stations
#' and stops are hierarchical. This means that stations represent the
#' structural facilities as hierarchically superior objects and stops are
#' hierarchically inferiors parts of a station (e.g., a single platform
#' at a bus stop).
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe with the following columns: \itemize{
#'  \item{\code{name}}: Geographical name of the POI
#'  \item{\code{gemeinde}}: Municipality name
#'  \item{\code{verwaltung}}: Administrative association name
#'  \item{\code{kreis}}: District name
#'  \item{\code{regierungs}}: Government region name
#'  \item{\code{bundesland}}: Federal state name
#'  \item{\code{stop_id}: Identifier of the station or stop}
#'  \item{\code{parent_st}: Identifier of the parent station if applicable}
#'  \item{\code{verkehrsm}: Vehicle used at the station, comma-separated
#'  and sorted alphabetically}
#'  \item{\code{art}: Hierarchical position of a station. Can be: \itemize{
#'    \item{Station: A physical structure and hierarchically superior}
#'    \item{Haltestelle: Part of a structure and hierarchically inferior}
#'  }}
#'  \item{\code{tag_f_awo}: Mean departures per day in a work week}
#'  \item{\code{tag_f_wo}: Mean departures per day in a full week}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get all long-distance train stations
#' bkg_stations(verkehrsm %LIKE% "%Fernzug%", art == "Station")
#'
#' # Get all platforms of long-distance train stations
#' bkg_stations(verkehrsm %LIKE% "%Fernzug%", art == "Haltestelle")
#'
#' # Get all stops with high traffic
#' bkg_stations(tag_f_awo > 1000, art == "Station")
#'
#' # Get all bus stops with low traffic
#' bkg_stations(tag_f_awo < 1, verkehrsm %LIKE% "%Bus%", art == "Station")
bkg_stations <- function(...,
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
    "haltestellen",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Heliports
#' @description
#' Get heliports in Germany. Based on data from third-party providers and image
#' classification of aerial imagery.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe with the following columns: \itemize{
#'  \item{\code{name}}: Geographical name of the POI
#'  \item{\code{gemeinde}}: Municipality name
#'  \item{\code{verwaltung}}: Administrative association name
#'  \item{\code{kreis}}: District name
#'  \item{\code{regierungs}}: Government region name
#'  \item{\code{bundesland}}: Federal state name
#'  \item{\code{code}: Identifier of the heliport}
#'  \item{\code{name_bkg}: Name of the landing site according to BKG}
#'  \item{\code{name_dfs}: Name of the landing size according to Deutsche
#'  Flugsicherung (DFS)}
#'  \item{\code{airport_pk}: Identifier according to the LFS aviation manual}
#'  \item{\code{befestigun}: Pavement type of the landing site. Can be: \itemize{
#'    \item{befestigt: paved}
#'    \item{teilweise befestigt: partially paved}
#'    \item{unbefestigt: unpaved}
#'  }}
#'  \item{\code{kennzeich}: Marking of the landing size. Can be: \itemize{
#'    \item{gekennzeichnet: marked}
#'    \item{nicht gekennzeichnet: not marked}
#'  }}
#'  \item{\code{lage}: Location of the landing size. Can be: \itemize{
#'    \item{D: Roof}
#'    \item{F: Field}
#'    \item{PG: Platform next to a hospital}
#'    \item{W: Pasture}
#'    \item{LP: Landing site}
#'    \item{PP: Parking lot}
#'    \item{LP / W: Paved landing size on pasture}
#'    \item{F / W: Field or pasture}
#'    \item{LP / Str.: Landing size next to a street}
#'  }}
#'  \item{\code{typ}: Type of heliport. Can be: \itemize{
#'    \item{H: Heliport}
#'    \item{HH: Heliport at a hospital}
#'    \item{MH: Military heliport}
#'  }}
#'  \item{\code{typ2}: Additional heliport type for landing sites with an
#'  air rescue station. Can be: \itemize{
#'    \item{HRLS: Helicopter air rescue station}
#'    \item{ITH: Intensive transport helicopter}
#'  }}
#'  \item{\code{betreiber}: Operator of the heliport}
#'  \item{\code{helikopter}: Name of the helicopter belonging to the
#'  air rescue station}
#'  \item{\code{status}: Whether the point geometry was edited by the BKG.
#'  Can be: \itemize{
#'    \item{Original: not edited}
#'    \item{Verschoben: moved}
#'    \item{neu: newly added}
#'  }}
#'  \item{\code{quelle}: Source of the information. Can be: \itemize{
#'    \item{BKG: Own research by the BKG}
#'    \item{DFS-Liste: Provided by DFS}
#'    \item{LBA-Liste: Provided by the Federal Aviation Office (LBA)}
#'    \item{MHW: Provided by the Medical Disaster Relief Organization (MHW)}
#'    \item{RTH.Info: Provided by rth.info}
#'  }}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get only military heliports
#' bkg_heliports(typ == "MH")
#'
#' # Get only rooftop heliports
#' bkg_heliports(lage == "D")
bkg_heliports <- function(...,
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
    "heliports",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Kilometrage
#' @description
#' Get kilometrages of German federal motorways. Kilometrages are markers
#' for each kilometer of a highway. They can be used to create
#' linear referencing systems (LRS).
#'
#' @returns A dataframe containing the following columns: \itemize{
#'  \item{\code{name}}: Geographical name of the POI
#'  \item{\code{gemeinde}}: Municipality name
#'  \item{\code{verwaltung}}: Administrative association name
#'  \item{\code{kreis}}: District name
#'  \item{\code{regierungs}}: Government region name
#'  \item{\code{bundesland}}: Federal state name
#'  \item{\code{bez}: Label of the federal motorway}
#'  \item{\code{kilometer}: Kilometrage of the motorway}
#'  \item{\code{richtung}: Direction of the kilometrage}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' The \href{https://cran.r-project.org/package=rLFT}{\code{rLFT}} package for linear referencing
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get the kilometrage of the A2 motorway
#' a2 <- bkg_kilometrage(bez == "A2")
#' plot(a2["kilometer"], pch = 16)
bkg_kilometrage <- function(...,
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
    "kilometrierungen_bab",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Seaports
#' @description
#' Retrieve seaports to the North and Baltic Sea in Northern Germany.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe containing the following columns: \itemize{
#'   \item{\code{name}}: Geographical name of the POI
#'   \item{\code{gemeinde}}: Municipality name
#'   \item{\code{verwaltung}}: Administrative association name
#'   \item{\code{kreis}}: District name
#'   \item{\code{regierungs}}: Government region name
#'   \item{\code{bundesland}}: Federal state name
#'   \item{\code{poi_id}: Unique primary key of a point of interest}
#'   \item{\code{betreiber}: Operator of the seaport}
#'   \item{\code{homepage}: Homepage of the operator}
#'   \item{\code{typ}: Type of seaport. Can be "Seehafen" (seaport) or
#'     "See- und Binnenhafen" (sea and inland port)}
#'   \item{\code{art}: Type of seaport by freight. Can be: \itemize{
#'    \item{Güter: Goods}
#'    \item{Güter und Passagiere: Goods and passengers}
#'    \item{Passagiere: Passengers}
#'   }}
#'   \item{\code{quelle}: Source of the information. Can be: \itemize{
#'    \item{BSH: Federal Maritime and Hydrographic Agency}
#'    \item{MarWiLo: Maritime Wirtschaft & Logistik}
#'    \item{ZDS-Seehäfen: Zentralverband der deutschen Seehafenbetriebe}
#'   }}
#' }
#'
#' @export
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examples
#' # Get only seaports that co-function as inland ports
#' ports <- bkg_seaports(typ == "See- und Binnenhafen")
#' germany <- bkg_admin(level = "sta", scale = "5000", gf == 9)
#' plot(germany$geometry)
#' plot(ports$geometry, add = TRUE)
bkg_seaports <- function(...,
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
    "seehaefen",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}


#' Trauma centers
#' @description
#' Retrieve data on trauma centers in Germany. A trauma center is a hospital
#' certified by the German Society for Trauma Surgery (DGU) that is able to
#' provide maximum care for heavily injured people. Trauma centers are
#' organized in a hierarchical regional network that ranges from local to
#' transregional centers.
#'
#' @inheritParams bkg_admin
#' @inheritParams wfs_filter
#'
#' @returns A dataframe containing the following columns: \itemize{
#'   \item{\code{name}}: Geographical name of the POI
#'   \item{\code{gemeinde}}: Municipality name
#'   \item{\code{verwaltung}}: Administrative association name
#'   \item{\code{kreis}}: District name
#'   \item{\code{regierungs}}: Government region name
#'   \item{\code{bundesland}}: Federal state name
#'   \item{\code{poi_id}: Unique primary key of a point of interest}
#'   \item{\code{tz_nummer}: Unique primary key of the trauma center}
#'   \item{\code{strasse}: Street}
#'   \item{\code{hn}: House number}
#'   \item{\code{plz}: Zip code}
#'   \item{\code{ort}: Place name}
#'   \item{\code{netwerk}: Name of the regional trauma center network}
#'   \item{\code{abteilung}: Name of the medical department}
#'   \item{\code{typ}: Type of trauma center. Can be: \itemize{
#'    \item{LTZ: local trauma center}
#'    \item{RTZ: regional trauma center}
#'    \item{ÜTZ: transregional trauma center}
#'   }}
#' }
#'
#' @seealso
#' \href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/poi-open.pdf}{\code{wfs_poi_open} documentation}
#'
#' \href{https://mis.bkg.bund.de/trefferanzeige?docuuid=461731F5-62B1-45A9-8E7E-BF6AF93E3EFA}{\code{wfs_poi_open} MIS record}
#'
#' @family points of interest
#'
#' @examplesIf ffm_run_examples()
#' # Get only trauma centers specializing on orthopedics
#' bkg_trauma_centers(abteilung %LIKE% "%orthopäd%")
#'
#' # Get only local trauma centers
#' bkg_trauma_centers(typ == "LTZ")
#'
#' if (requireNamespace("ggplot2")) {
#'   library(ggplot2)
#'   centers <- bkg_trauma_centers()
#'   ggplot() +
#'   geom_sf(
#'     data = centers[centers$typ %in% "LTZ",],
#'     size = 1,
#'     color = "lightblue1"
#'   ) +
#'   geom_sf(
#'     data = centers[centers$typ %in% "RTZ",],
#'     size = 2,
#'     color = "lightblue3"
#'   ) +
#'   geom_sf(
#'     data = centers[centers$typ %in% "ÜTZ",],
#'     size = 3,
#'     color = "lightblue4"
#'   ) +
#'   theme_void()
#' }
bkg_trauma_centers <- function(...,
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
    "traumazentren",
    endpoint = "poi_open",
    count = max,
    properties = properties,
    epsg = epsg,
    filter = filter
  )[-1]
}
