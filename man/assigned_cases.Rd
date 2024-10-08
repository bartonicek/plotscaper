% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/message_senders.R
\name{assigned_cases}
\alias{assigned_cases}
\title{Get assigned cases}
\usage{
assigned_cases(x, group = 1)
}
\arguments{
\item{x}{A \code{plotscaper} scene}

\item{group}{The group to retrieve the cases of (can be: 1, 2, or 3)}
}
\value{
A numeric vector of case ids
}
\description{
This function returns the cases of the data which
are assigned to a specific permanent group within
a \code{plotscaper} scene.
}
