% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/geom_treemap_subgroup_border.R
\name{geom_treemap_subgroup_border}
\alias{geom_treemap_subgroup_border}
\alias{geom_treemap_subgroup2_border}
\alias{geom_treemap_subgroup3_border}
\title{'ggplot2' geoms to draw a border around a subgroup of treemap tiles.}
\usage{
geom_treemap_subgroup_border(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  fixed = NULL,
  layout = "squarified",
  start = "bottomleft",
  level = "subgroup",
  ...
)

geom_treemap_subgroup2_border(...)

geom_treemap_subgroup3_border(...)
}
\arguments{
\item{mapping, data, stat, position, na.rm, show.legend, inherit.aes, ...}{Standard
geom arguments as for \code{ggplot2::geom_rect()}.}

\item{fixed}{Deprecated. Use \code{layout = 'fixed'} instead. Will be removed in
later versions.}

\item{layout}{The layout algorithm, one of either 'squarified' (the
default), 'scol', 'srow' or 'fixed'. See Details for full details on the
different layout algorithms.}

\item{start}{The corner in which to start placing the tiles. One of
'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.}

\item{level}{One of 'subgroup', 'subgroup2' or 'subgroup3', giving the
subgrouping level for which to draw borders. It is recommended to use the
aliases \code{geom_treemap_subgroup2_border()} and \code{geom_treemap_subgroup3_border()}
instead of this argument.}
}
\description{
When \code{geom_treemap()} is used with a \code{subgroup}, \code{subgroup2} or \code{subgroup3}
aesthetic to subgroup treemap tiles, \code{geom_treemap_subgroup_border},
\code{geom_treemap_subgroup2_border()} or \code{geom_treemap_subgroup3_border()} can
be used to draw a border around each subgroup at the appropriate level.
}
\details{
\code{geom_treemap_subgroup_border()} geoms require \code{area} and \code{subgroup} (or
\verb{subgroup2, }subgroup3`) aesthetics. Several other standard 'ggplot2'
aesthetics are supported (see Aesthetics).

Note that 'ggplot2' draws plot layers in the order they are added to the
plot. This means that if you add a \code{geom_treemap_subgroup_border()} layer
followed by a \code{geom_treemap_subgroup2_border()} layer, the second layer will
be drawn on top of the first and may hide it.

The \code{layout} argument is used to set the treemap layout algorithm. All
'treemapify' geoms added to a plot should have the same value for \code{layout}
and \code{start}, or they will not share a common layout (see \code{geom_treemap()} for
details on the layout algorithms).
}
\section{Aesthetics}{

\itemize{
\item area (required)
\item subgroup, subgroup2 or subgroup3 (required)
\item colour
\item size
\item linetype
\item alpha
}
}

\examples{

ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi,
                                  subgroup = hemisphere, subgroup2 = region)) +
  geom_treemap() +
  geom_treemap_subgroup2_border(colour = "white") +
  geom_treemap_subgroup_border()

}
\seealso{
\code{\link[=geom_treemap]{geom_treemap()}}, \code{\link[=geom_treemap_subgroup_text]{geom_treemap_subgroup_text()}}
}
