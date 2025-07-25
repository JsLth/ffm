% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bkg_nuts.R
\name{bkg_nuts}
\alias{bkg_nuts}
\title{NUTS regions}
\usage{
bkg_nuts(
  level = c("1", "2", "3"),
  scale = c("250", "1000", "2500", "5000"),
  key_date = c("0101", "1231"),
  year = "latest",
  allow_local = TRUE,
  timeout = 120,
  update_cache = FALSE
)
}
\arguments{
\item{level}{NUTS level to download. Can be \code{"1"} (federal states),
\code{"2"} (inconsistent, something between states and government regions),
or \code{"3"} (districts). Defaults to federal states.}

\item{scale}{Scale of the geometries. Can be \code{"250"}
(1:250,000), \code{"1000"} (1:1,000,000), \code{"2500"} (1:2,500,000)
or \code{"5000"} (1:5,000,000). If \code{"250"}, population data is included
in the output. Defaults to \code{"250"}.}

\item{key_date}{For \code{resolution \%in\% c("250", "5000")}, specifies the key
date from which to download administrative data. Can be either \code{"0101"}
(January 1) or \code{"1231"} (December 31). The latter is able to
georeference statistical data while the first integrates changes made
in the new year. If \code{"1231"}, population data is attached, otherwise
not. Note that population data is not available at all scales (usually
250 and 1000). Defaults to "0101".}

\item{year}{Version year of the dataset. You can use \code{latest} to
retrieve the latest dataset version available on the BKG's geodata center.
Older versions can be browsed using the
\href{https://daten.gdz.bkg.bund.de/produkte/}{archive}.}

\item{allow_local}{If \code{TRUE}, allows special datasets to be loaded
locally. If \code{FALSE}, always downloads from the internet. For
\code{bkg_nuts}, the datasets from \code{\link{nuts_data}} can be loaded.
This only applies if \code{scale = "5000"}, \code{key_date = "1231"},
and \code{year = "2023"}.}

\item{timeout}{Timeout value for the data download passed to
\code{\link[httr2]{req_timeout}}. Adjust this if your internet connection is
slow or you are downloading larger datasets.}

\item{update_cache}{By default, downloaded files are cached in the
\code{tempdir()} directory of R. When downloading the same data again,
the data is not downloaded but instead taken from the cache. Sometimes
this can be not the desired behavior. If you want to overwrite the cache,
pass \code{TRUE}. Defaults to \code{FALSE}, i.e. always adopt the cache
if possible.}
}
\value{
An sf dataframe with multipolygon geometries and the following
columns:

\itemize{
\item{\code{GF}}: Integer representing the geofactor; whether an area is
"structured" or not. Land is structured if it is part of a state or other
administrative unit but is not further divided into administrative units.
Can be one of \itemize{
\item{1: Unstructured, waterbody}
\item{2: Structured, waterbody}
\item{3: Unstructured, land}
\item{4: Structured, land}
}
\item{\code{NUTS_LEVEL}}: NUTS level. Can be one of \itemize{
\item{1: NUTS-1; federal states}
\item{2: NUTS-2; inconsistent, somewhere between government regions and
federal states}
\item{3: NUTS-3; districts}
}
\item{\code{NUTS_CODE}}: Hierarchical key of the NUTS region. Can have a different number
of characters depending on the NUTS level: \itemize{
\item{NUTS-1: three digits}
\item{NUTS-2: four digits}
\item{NUTS-3: five digits}
}
\item{\code{NUTS_NAME}}: Geographical name of the NUTS region
}
}
\description{
Retrieve polygons of NUTS regions.

This function interfaces the \code{nuts*} products of the BKG.
}
\note{
This function does not query a WFS so you are only able to download
entire datasets without the ability to filter beforehand.
}
\examples{
\dontshow{if (getFromNamespace("ffm_run_examples", ns = "ffm")()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Download NUTS state data from 2020
bkg_nuts(scale = "5000", year = 2020)

# Download the latest NUTS district data
bkg_nuts(level = "3")
\dontshow{\}) # examplesIf}
}
\seealso{
\href{https://sgx.geodatenzentrum.de/web_public/gdz/dokumentation/deu/nuts250.pdf}{\code{nuts250} documentation}

\href{https://mis.bkg.bund.de/trefferanzeige?docuuid=D38F5B40-9209-4DC0-82BC-57FB575D29D7}{\code{nuts250} MIS record}

\code{\link{bkg_admin}} for retrieving German administrative areas

Datasets: \code{\link{admin_data}}, \code{\link{nuts_data}}
}
