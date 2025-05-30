% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bkg_dlm.R
\name{bkg_dlm}
\alias{bkg_dlm}
\title{Digital landscape model (DLM)}
\usage{
bkg_dlm(
  type,
  ...,
  shape = c("point", "line", "polygon"),
  scale = c("250", "1000"),
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
\item{type}{Feature type of the DLM. Can either be the identifier
(e.g., 41010) or its description (e.g., Siedlungsflaeche). The description
can either be prefixed with \code{AX_} or not. Providing an identifier
directly is generally faster as the description needs to be matched
by requesting the \code{GetCapabilities} endpoint of the service.

Note that not all feature types are available for all shapes (see the
\code{shape} argument). To see all available feature types, you can run
\code{bkg_feature_types("dlm250")} or \code{bkg_feature_types("dlm1000")}.}

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

\item{shape}{Geometry type of the feature type. Must be one of \code{"point"},
\code{"line"}, or \code{"polygon"}. Defaults to \code{"point"}. Not all
shapes are available for all feature types.}

\item{scale}{Scale of the geometries. Can be \code{"250"}
(1:250,000) or \code{"1000"} (1:1,000,000). Defaults to \code{"250"}.}

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
An sf tibble with the geometry suggested by \code{shape}.
The columns can vary depending of the selected feature type. The meanings
of the columns can also change depending on the feature type. Check out
the GeoInfoDok object type catalog for a detailed documentation of the
DLM metadata. Some more general columns are included for all feature types;
these include:
\itemize{
\item{\code{id}}: Identifier of an object
\item{\code{land}}: ISO-2 code of the country, usually DE
\item{\code{modellart}}: Model type
\item{\code{objart}}: Feature type of the digital landscape model (DLM)
\item{\code{objart_txt}}: Title of the feature type
\item{\code{objid}}: Unique object identifier
\item{\code{beginn}}: Creation of the object in the DLM
\item{\code{ende}}: Deletion of the object from the DLM
\item{\code{objart_z}}: Object type of the composite object (ZUSO)
\item{\code{objid_z}}: Object type of the composite object (ZUSO)
}
}
\description{
Retrieve objects from the digital landscape model (DLM). DLMs are a
description of topographical objects of a landscape. Many other services
from the BKG are derived from the DLM.

Although this function lets you download each feature type in the DLM, you
still need to know about what data is available and what the features in the
output actually mean. Since the DLM gets pretty complicated, you are advised
to take a look at the
\href{https://www.adv-online.de/GeoInfoDok/Aktuelle-Anwendungsschemata/AAA-Anwendungsschema-7.1.2-Referenz-7.1/binarywriterservlet?imgUid=f2f70989-a7b6-0581-9393-b216067bef8a&uBasVariant=11111111-1111-1111-1111-111111111111}{GeoInfoDok}
object type catalog.

This function interfaces the \code{dlm*} products of the BKG.
}
\section{Query language}{

By default, WFS requests use CQL (Contextual Query Language) queries for
simplicity. CQL queries only work together with GET requests. This means
that when the URL is longer than 2048 characters, they fail.
While POST requests are much more flexible and able to accommodate long
queries, XML is really a pain to work with and I'm not confident in my
approach to construct XML queries. You can control whether to send GET or
POST requests by setting \code{options(ffm_query_language = "XML")}
or \code{options(ffm_query_language = "CQL")}.
}

\examples{
\dontshow{if (getFromNamespace("ffm_run_examples", ns = "ffm")()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Retrieve all train tracks in Leipzig
library(sf)
lzg <- st_sfc(st_point(c(12.37475, 51.340333)), crs = 4326)
lzg <- st_buffer(st_transform(lzg, 3035), dist = 10000, endCapStyle = "SQUARE")

tracks <- bkg_dlm("Bahnstrecke", shape = "line", poly = lzg)
tracks

plot(lzg)
plot(tracks$geometry, add = TRUE)

# Filter all tracks that are not rail cargo
bkg_dlm("Bahnstrecke", shape = "line", poly = lzg, bkt == "1102")

# Directly providing the identifier is faster
bkg_dlm("42014", shape = "line", poly = lzg)
\dontshow{\}) # examplesIf}
}
\seealso{
\href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/dlm250.pdf}{\code{dlm250 documentation}}

\href{https://mis.bkg.bund.de/trefferanzeige?docuuid=d6d50b87-b896-4696-9efb-66d1adc62337}{\code{dlm250} MIS record}
}
