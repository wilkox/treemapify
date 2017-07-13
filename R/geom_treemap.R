#' @title A treemap
#' @export
#'
#' @description
#'
#' Draw a treemap, where each observation is represented by a tile scaled by an
#' area aesthetic.
#'
#' ‘area’ is the only required aesthetic. Other aesthetics are accepted as for
#' \code{geom_rect}. See \code{geom_treemap_text} to label tiles.
#'
#' An optional ‘subgroup’ aesthetic will cause the tiles to be clustered in
#' subgroups within the treemap. See \code{geom_treemap_subgroup_border} and
#' \code{geom_treemap_subgroup_text} to draw a border around subgroups and label
#' them respectively.
#'
#' With the default tile layout algorithm (\code{fixed = F}), tile placement
#' proceeds from the bottom left corner, moving alternately rightwards and
#' upwards until all tiles are placed. See Bruls et al. (1999) for the full
#' algorithm.
#'
#' With the fixed tile layout algorithm (\code{fixed = T}), tile placement fills
#' columns from left to right, beginning at the bottom of each column. However,
#' unlike with the default algorithm, the order in which tiles are placed is
#' fixed by their order in the input data frame. While this can result in some
#' aesthetically unpleasing tiles, it allows side-by-side comparisons or
#' animations to be created. If the fixed algorithm is used for geom_treemap, it
#' should also be used for all other treemap geoms in the plot or they will not
#' share a common layout.
#'
#' @section Aesthetics:
#'
#' \itemize{
#'   \item area (required)
#'   \item alpha
#'   \item colour
#'   \item fill
#'   \item linetype
#'   \item subgroup
#' }
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for \code{geom_rect}.
#' @param fixed Logical, indicating whether the fixed layout algorithm
#' should be used. Defaults to false.
#'
#' @seealso geom_treemap_text, geom_treemap_subgroup_border,
#' geom_treemap_subgroup_text
#'
#' @references
#' The default tile layout uses the Squarified Treemap algorithm of Mark Bruls,
#' Kees Huizing and Jarke van Wijk:
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42). Presented at the In Proceedings of the Joint Eurographics and IEEE
#' TCVG Symposium on Visualization.
#' \url{http://www.win.tue.nl/~vanwijk/stm.pdf}
geom_treemap <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  fixed = F,
  ...
) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomTreemap,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      fixed = fixed,
      ...
    )
  )
}

#' GeomTreemap
#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomTreemap <- ggproto(
  "GeomTreemap",
  Geom,
  required_aes = c("area"),
  default_aes = aes(
    colour = "grey",
    fill = "grey35",
    size = 0.5,
    linetype = 1,
    alpha = 1
  ),
  draw_key = draw_key_rect,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    fixed = F
  ) {

    data <- coord$transform(data, panel_scales)
    data$id <- 1:nrow(data)

    # Generate treemap layout for data
    params <- list(
      data = data,
      area = "area",
      fill = "fill",
      xlim = c(0, 1),
      ylim = c(0, 1),
      label = "id"
    )
    if ("subgroup" %in% names(data)) {
      params$group <- "subgroup"
    }
    if (fixed) {
      layout <- do.call(treemapify_fixed, params)
    } else {
      layout <- do.call(treemapify, params)
    }

    # Merge layout back into main data
    names(layout)[names(layout) == "label"] <- "id"
    layout <- layout[c("id", "xmin", "xmax", "ymin", "ymax")]
    data <- merge(data, layout, by = "id")

    # Draw rects
    grob <- grid::rectGrob(
      x = data$xmin,
      width = data$xmax - data$xmin,
      y = data$ymax,
      height = data$ymax - data$ymin,
      default.units = "native",
      just = c("left", "top"),
      gp = grid::gpar(
        col = data$colour,
        fill = alpha(data$fill, data$alpha),
        lwd = data$size,
        lty = data$linetype,
        lineend = "butt"
      )
    )
    grob$name <- grid::grobName(grob, "geom_treemap")
    grob
  }
)
