`%l0%` <- function(x, y) if (length(x) == 0) y else x
`%||%` <- function(x, y) if (is.null(x)) y else x
ggname <- function(prefix, grob) {
  grob$name <- grid::grobName(grob, prefix)
  grob
}
