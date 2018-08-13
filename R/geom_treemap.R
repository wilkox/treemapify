#' A 'ggplot2' geom to draw a treemap.
#'
#' A treemap is a rectangular plot divided into tiles, each of which represents
#' a single observation. The relative area of each tile expresses a continuous
#' variable.
#'
#' `geom_treemap` requires an `area` aesthetic. It will ignore any aesthetics
#' relating to the x and y axes (e.g. `xmin` or `y`), as the x and y axes are
#' not meaningful in a treemap. Several other standard 'ggplot2' aesthetics are
#' supported (see Aesthetics). To add text labels to tiles, see
#' `geom_treemap_text`.
#'
#' An optional `subgroup` aesthetic will cause the tiles to be clustered in
#' subgroups within the treemap. See `geom_treemap_subgroup_border` and
#' `geom_treemap_subgroup_text` to draw borders around subgroups and label
#' them, respectively. Up to three nested levels of subgrouping are supported,
#' with `subgroup2` and `subgroup3` aesthetics and respective
#' `geom_treemap_subgroup2_border` etc. geoms.
#'
#' Three layout algorithms are provided. With the default 'squarified'
#' algorithm, the priority is ensuring the tiles have an aesthetically pleasing
#' aspect ratio; that is, they are not too narrow or too short. In this
#' algorithm, tile placement proceeds from one corner, placing the tiles
#' alternately in rows then in columns until all the tiles are placed.
#' Alternatively, with `layout = "scol"`, the squarified algorithm can be used
#' but beginning with a column. See Bruls et al. (1999) for the full algorithm. 
#'
#' With the 'fixed' layout algorithm (`layout = "fixed"`), the plot area is
#' divided into vertical columns, which are each filled  with an equal number
#' of tiles beginning at the starting corner. Unlike the 'squarified'
#' algorithm, with the 'fixed' algorithm the relative positions of the tiles
#' are fixed by their order in the input data frame. This can result in
#' aesthetically unpleasing tiles, but it allows side-by-side comparisons or
#' animations to be created.
#'
#' All `treemapify` geoms added to a plot should have the same value for
#' `layout` and `start`, or they will not share a common layout.
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
#'   \item subgroup2
#'   \item subgroup3
#' }
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_rect`.
#' @param fixed Use `layout` instead. Will be deprecated in a later version.
#' @param layout The treemap layout algorithm. One of 'srow' (squarified,
#' row-first; the default), 'scol' (squarified, column-first) or 'fixed'.
#' @param start The corner in which to start placing the tiles. One of
#' 'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.
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
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = region)) +
#'  geom_treemap()
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
  fixed = FALSE,
  layout = "srow",
  start = "bottomleft",
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
      layout = layout,
      start = start,
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
    fixed = FALSE,
    layout = "srow",
    start = "bottomleft"
  ) {

    data <- coord$transform(data, panel_scales)

    # Generate treemap layout for data
    tparams <- list(
      data = data,
      area = "area",
      fixed = fixed,
      layout = layout,
      start = start
    )
    for (x in intersect(c("subgroup", "subgroup2", "subgroup3"), names(data))) {
      tparams[x] <- x
    }
    data <- do.call(treemapify, tparams)

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
        fill = ggplot2::alpha(data$fill, data$alpha),
        lwd = data$size,
        lty = data$linetype,
        lineend = "butt"
      )
    )
    grob$name <- grid::grobName(grob, "geom_treemap")
    grob
  }
)
