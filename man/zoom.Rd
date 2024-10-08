% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/message_senders.R
\name{zoom}
\alias{zoom}
\title{Zoom into an area of a plot}
\usage{
zoom(x, id = NULL, coords = NULL, units = "pct")
}
\arguments{
\item{x}{A plotscaper scene or schema}

\item{id}{A string id of the plot. See \link{id}}

\item{coords}{The coordinates of a rectangle to
zoom into, in the following order: \verb{x0, y0, x1, y1}}

\item{units}{The units with which to interpret the coordinates.
Can be "pct" (percentages of the plotting region), "abs" (absolute
screen coordinates, in pixels), or "data" (data coordinates;
only works if both scales are continuous).}
}
\description{
This function zooms into a rectangular area of the specified
plot. The coordinates of the rectangular area can be specified
with either percentages of the plotting region, absolute
coordinates (pixels), or data coordinates.
}
