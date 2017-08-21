#' A ggplot2 geom to draw a treemap.
#'
#' \code{geom_treemap()} provides a plot layer that divides the plot into tiles
#' representing dataset observations. The relative area of each tile expresses
#' an 'area' aesthetic.
#'
#' \code{geom_treemap()} requires an 'area' aesthetic. It won't accept any
#' aesthetics relating to the x and y axes (e.g. 'xmin' or 'y'), as the x and y
#' axes are not meaningful in a treemap. Several other standard ggplot2
#' aesthetics are supported (see Aesthetics). To add text labels to tiles, see
#' \code{geom_treemap_text}.
#'
#' An optional 'subgroup' aesthetic will cause the tiles to be clustered in
#' subgroups within the treemap. See \code{geom_treemap_subgroup_border} and
#' \code{geom_treemap_subgroup_text} to draw borders around subgroups and label
#' them, respectively.
#'
#' Two algorithms for the tile layout are provided. With the default
#' 'squarified' algorithm (\code{fixed = F}), the priority is ensuring the tiles
#' have an aesthetically pleasing aspect ratio; that is, they are not too narrow
#' or too short. In this algorithm, tile placement proceeds from the bottom left
#' corner, moving alternately rightwards and upwards until all tiles are placed.
#' See Bruls et al. (1999) for the full algorithm.
#'
#' With the alternative 'fixed' layout algorithm (\code{fixed = T}), the plot
#' area is divided into vertical columns, each of which from left to right is
#' then filled with an even number of tiles beginning at the bottom of the
#' column. Unlike with the default 'squarified' algorithm, the relative
#' positions of the tiles are fixed by their order in the input data frame.
#' While this can result in aesthetically unpleasing tiles, it allows
#' side-by-side comparisons or animations to be created. If the \code{fixed = T}
#' argument is used for \code{geom_treemap()}, it should also be used for all
#' other treemap geoms included in the plot or they will not share a common
#' layout.
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
#' @param fixed If 'TRUE', the alternative 'fixed' tile layout algorithm will be
#' used.
#'
#' @seealso geom_treemap_text, geom_treemap_subgroup_border,
#' geom_treemap_subgroup_text
#'
#' @references
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42). Proceedings of the Joint Eurographics and IEEE TCVG Symposium on
#' Visualization. \url{http://www.win.tue.nl/~vanwijk/stm.pdf}
#'
#' @export
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
  ggplot2::layer(
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
#' @noRd
GeomTreemap <- ggplot2::ggproto(
  "GeomTreemap",
  ggplot2::Geom,
  required_aes = c("area"),
  default_aes = ggplot2::aes(
    colour = "grey",
    fill = "grey35",
    size = 0.5,
    linetype = 1,
    alpha = 1
  ),
  draw_key = ggplot2::draw_key_rect,

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
