% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/bkg_wcs.R
\name{bkg_wcs}
\alias{bkg_wcs}
\title{BKG WCS}
\usage{
bkg_wcs(
  coverage_id,
  endpoint = coverage_id,
  version = "2.0.1",
  method = NULL,
  format = "image/tiff;application=geotiff",
  epsg = 3035,
  interpolation = NULL,
  ...
)
}
\arguments{
\item{coverage_id}{Coverage ID. When in doubt, inspect the
\code{GetCapabilities} of the service.}

\item{endpoint}{Endpoint to interface. Note that \code{wcs_} is appended
and only the rest of the product name must be provided. For example,
\code{wcs_dgm200_inspire} becomes \code{dgm200_inspire}. Defaults to the
value of \code{coverage_id}.}

\item{version}{Service version of the WCS. Defaults to \code{2.0.1}.}

\item{method}{HTTP method to use for the request. \code{GET} requests
provide parameters using URL queries. Filters must be provided as CQL
queries. While this is less error-prone, it allows a maximum number of
only 2048 characters. Especially when providing more sophisticated spatial
queries, \code{GET} queries are simply not accepted by the services. In
these cases it makes sense to use \code{POST} requests instead.

If \code{NULL}, the method is inferred from the type of filter query
provided to \code{filter} (either XML or CQL). If no filter is provided,
the method is inferred from \code{getOption("ffm_query_language")}.}

\item{format}{Content type of the output. This value heavily depends
the endpoint queried. Defaults to \code{"image/tiff;application=geotiff"}.}

\item{epsg}{Numeric value giving the EPSG identifier of the coordinate
reference system (CRS). The EPSG code is automatically formatted in a
OGC-compliant manner. Note that not all EPSG codes are supported. Inspect
the \code{GetCapabilities} of the target service to find out which
EPSG codes are available. Defaults to EPSG:3035.}

\item{interpolation}{Method used to interpolate the coverage raster.
Allowed methods depend on the capabilities of the WCS.}

\item{...}{Further parameters passed to the WFS query. In case of
\code{POST} requests, additional namespaces that may be necessary to query
the WFS. Argument names are interpreted as the prefix (e.g.
\code{xmlns:wfs}) and argument values as namespace links.}
}
\value{
A \code{\link[terra:rast]{SpatRaster}}.
}
\description{
Low-level interface to BKG-style web coverage services (WCS). This function
is used in all high-level functions of \code{ffm} that depend on a WCS,
e.g., \code{\link{bkg_dem}}.
}
\examples{
\dontshow{if (getFromNamespace("ffm_run_examples", ns = "ffm")()) (if (getRversion() >= "3.4") withAutoprint else force)(\{ # examplesIf}
# Boundaries can be provided using two subset arguments
bkg_wcs(
  "dgm200_inspire__EL.GridCoverage",
  endpoint = "dgm200_inspire",
  subset = "E(548282,552280)",
  subset = "N(5800943,5804942)"
)
\dontshow{\}) # examplesIf}
}
