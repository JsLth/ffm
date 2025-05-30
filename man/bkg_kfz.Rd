% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bkg_kfz.R
\name{bkg_kfz}
\alias{bkg_kfz}
\title{Vehicle registration plates}
\usage{
bkg_kfz(
  ...,
  bbox = NULL,
  poly = NULL,
  predicate = "intersects",
  filter = NULL,
  epsg = 3035,
  properties = NULL,
  max = NULL
)
}
\arguments{
\item{...}{Used to construct CQL filters. Dot arguments accept an R-like
syntax that is converted to CQL queries internally. These queries basically
consist of a property name on the left, an aribtrary vector on the right,
and an operator that links both sides. If multiple queries are provided,
they will be chained with \code{AND}. The following operators and their
respective equivalents in CQL and XML are supported:

\tabular{lll}{
\strong{R} \tab \strong{CQL} \tab \strong{XML}\cr
\code{==} \tab \code{=} \tab \code{PropertyIsEqualTo}\cr
\code{!=} \tab \code{<>} \tab \code{PropertyIsNotEqualTo}\cr
\code{<} \tab \code{<} \tab \code{PropertyIsLessThan}\cr
\code{>} \tab \code{>} \tab \code{PropertyIsGreaterThan}\cr
\code{>=} \tab \code{>=} \tab \code{PropertyIsGreaterThanOrEqualTo}\cr
\code{<=} \tab \code{<=} \tab \code{PropertyIsLessThanOrEqualTo}\cr
\code{\%LIKE\%} \tab \code{LIKE} \tab \code{PropertyIsLike}\cr
\code{\%ILIKE\%} \tab \code{ILIKE}\cr \tab\cr
\code{\%in\%} \tab \code{IN} \tab \code{PropertyIsEqualTo} and \code{Or}
}

To construct more complex queries, you can use the \code{filter} argument
to pass CQL queries directly. Also note that you can switch between
CQL and XML queries using \code{options(ffm_query_language = "xml")}.
See also \code{\link{wfs_filter}}.}

\item{bbox}{An sf geometry or a boundary box vector of the format
\code{c(xmin, ymin, xmax, ymax)}. Used as a geometric filter to include
only those geometries that relate to \code{bbox} according to the predicate
specified in \code{predicate}. If an sf geometry is provided, coordinates
are automatically transformed to ESPG:25832 (the default CRS), otherwise
they are expected to be in EPSG:25832.}

\item{poly}{An sf geometry. Used as a geometric filter to include
only those geometries that relate to \code{poly} according to the predicate
specified in \code{predicate}. Coordinates are automatically transformed to
ESPG:25832 (the default CRS).}

\item{predicate}{A spatial predicate that is used to relate the output
geometries with the object specified in \code{bbox} or \code{poly}. For
example, if \code{predicate = "within"}, and \code{bbox} is specified,
returns only those geometries that lie within \code{bbox}. Can be one of
\code{"equals"}, \code{"disjoint"}, \code{"intersects"}, \code{"touches"},
\code{"crosses"}, \code{"within"}, \code{"contains"}, \code{"overlaps"},
\code{"relate"}, \code{"dwithin"}, or \code{"beyond"}. Defaults to
\code{"intersects"}.}

\item{filter}{A character string containing a valid CQL or XML filter. This
string is appended to the query constructed through \code{...}. Use this
argument to construct more complex filters. Defaults to \code{NULL}.}

\item{epsg}{An EPSG code specifying a coordinate reference system of the
output. If you're unsure what this means, try running
\code{sf::st_crs(...)$epsg} on a spatial object that you are working with.
Defaults to 3035.}

\item{properties}{Vector of columns to include in the output.}

\item{max}{Maximum number of results to return.}
}
\value{
An sf dataframe with multipolygon geometries and the following
columns: \itemize{
\item{\code{debkgid}}: Identifier in the digital landscape model DLM250
\item{\code{nnid}}: National name identifier
\item{\code{name}}: Name of the geographical object
\item{\code{ars}}: Territorial code (Amtlicher Regionalschlu00fcssel).
The ARS is stuctured hierarchically as follows: \itemize{
\item{Position 1-2: Federal state}
\item{Position 3: Government region}
\item{Position 4-5: District}
\item{Position 6-9: Administrative association}
\item{Position 10-12: Municipality}
}
\item{\code{oba}}: Name of the ATKIS object type
\item{\code{kfz}}: Vehicle registration area code, comma-separated in case of multiple codes
\item{\code{geola}}: Geographical longitude
\item{\code{geobr}}: Geographical latitude
\item{\code{gkre}}: Gauu00df-Kru00fcger easting
\item{\code{gkho}}: Gauu00df-Kru00fcger northing
\item{\code{utmre}}: UTM easting
\item{\code{utmho}}: UTM northing
}
}
\description{
Retrieve motor vehicle registration plate regions in Germany. Registration
plate regions are discerned by their area code
(\emph{Unterscheidungszeichen}) which indicate the place where a vehicle
was registered. These regions partially overlap with districts but are not
entirely identical.

This function interfaces the \code{wfs_kfz250} product of the BKG.
}
\examples{
\dontshow{if (getFromNamespace("ffm_run_examples", ns = "ffm")() && requireNamespace("ggplot2")) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
library(ggplot2)

kfz <- bkg_kfz(ars \%LIKE\% "053\%")
ggplot(kfz) +
  geom_sf(fill = NA) +
  geom_sf_text(aes(label = kfz)) +
  theme_void()
\dontshow{\}) # examplesIf}
}
\seealso{
\href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/kfz250.pdf}{\code{kfz250} documentation}

\href{https://mis.bkg.bund.de/trefferanzeige?docuuid=171BF073-C17B-47F7-891F-F27E5EDD7643}{\code{kfz250} MIS record}

\code{\link{bkg_admin}}

Other non-administrative regions: 
\code{\link{bkg_authorities}()},
\code{\link{bkg_grid}},
\code{\link{bkg_ror}()}
}
\concept{non-administrative regions}
