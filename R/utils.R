`%l0%` <- function(x, y) if (length(x) == 0) y else x
`%||%` <- function(x, y) if (is.null(x)) y else x
ggname <- function(prefix, grob) {
  grob$name <- grid::grobName(grob, prefix)
  grob
}

#' Base ggproto classes for treemapify extension to ggplot2
#'
#' @seealso ggplot2::ggproto
#' @keywords internal
#' @name treemapify-ggproto
NULL
