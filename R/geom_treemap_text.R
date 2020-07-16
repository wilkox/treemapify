#' A 'ggplot2' geom to add text labels to treemap tiles.
#'
#' `geom_treemap_text()` can be used to add a text label to each tile in a
#' treemap created with `geom_treemap()`.
#'
#' `geom_treemap_text()` requires `area` and `label` aesthetics. Several other
#' standard 'ggplot2' aesthetics are supported (see Aesthetics).
#'
#' `geom_treemap_text()` uses the 'ggfittext' package to fit text to tiles. All
#' text drawing options available in `ggfittext::geom_fit_text()` (growing,
#' reflowing, etc.) are also available here. For full details on how these
#' options work, see the documentation for `ggfittext::geom_fit_text()`.
#'
#' The `layout` argument is used to set the treemap layout algorithm. All
#' 'treemapify' geoms added to a plot should have the same value for `layout`
#' and `start`, or they will not share a common layout (see `geom_treemap()`
#' for details on the layout algorithms).
#'
#' @param padding.x,padding.y `grid::unit()` object, giving horizontal or
#' vertical padding between text and edge of tile. Defaults to 1 mm.
#' @param place Where inside the box to place the text. Default is 'bottom';
#' other options are 'topleft', 'top', 'topright', etc.
#' @param min.size Minimum font size, in points. If provided, text that would
#' need to be shrunk below this size to fit the box will not be drawn. Defaults
#' to 4 pt.
#' @param grow If `TRUE`, text will be grown as well as shrunk to fill the box.
#' @param reflow If `TRUE`, text will be reflowed (wrapped) to better fit the
#' box.
#' @param layout The layout algorithm, one of either 'squarified' (the
#' default), 'scol', 'srow' or 'fixed'. See Details for full details on the
#' different layout algorithms.
#' @param start The corner in which to start placing the tiles. One of
#' 'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_text()`.
#' @param fixed Deprecated. Use `layout = "fixed"` instead. Will be removed in
#' later versions.
#'
#' @seealso [geom_treemap()]
#'
#' @section Aesthetics:
#'
#' - area (required)
#' - label (required)
#' - subgroup, subgroup2 or subgroup3
#' - colour
#' - size
#' - alpha
#' - family
#' - fontface
#' - angle
#'
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd,
#'                                   fill = econ_classification,
#'                                   label = country)) +
#'   geom_treemap() +
#'   geom_treemap_text()
#'
#' @export
geom_treemap_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = TRUE,
  padding.x = grid::unit(1, "mm"),
  padding.y = grid::unit(1, "mm"),
  place = "topleft",
  min.size = 4,
  grow = FALSE,
  reflow = FALSE,
  fixed = NULL,
  layout = "squarified",
  start = "bottomleft",
  ...
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomTreemapText,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      grow = grow,
      reflow = reflow,
      fixed = fixed,
      layout = layout,
      start = start,
      ...
    )
  )
}

#' GeomTreemapText
#' @noRd
#' @import grid
#' @import ggfittext
GeomTreemapText <- ggplot2::ggproto(
  "GeomTreemapText",
  ggplot2::Geom,
  required_aes = c("area", "label"),
  default_aes = ggplot2::aes(
    colour = "black",
    size = 18,
    alpha = 1,
    family = "",
    fontface = 1,
    angle = 0,
    fill = "white",
    lineheight = 0.9
  ),
  draw_key = ggplot2::draw_key_text,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    padding.x = grid::unit(1, "mm"),
    padding.y = grid::unit(1, "mm"),
    min.size = 4,
    grow = FALSE,
    reflow = FALSE,
    fixed = NULL,
    layout = "squarified",
    start = "bottomleft",
    place = "centre"
  ) {

    data <- coord$transform(data, panel_scales)

    # Generate treemap layout for data
    params <- list(
      data = data,
      area = "area",
      fixed = fixed,
      layout = layout,
      start = start
    )
    for (subgrouplevel in c("subgroup", "subgroup2", "subgroup3")) {
      if (subgrouplevel %in% names(data)) {
        params[subgrouplevel] <- subgrouplevel
      }
    }
    data <- do.call(treemapify, params)

    # Standardise the place argument
    if (place %in% c("middle", "center")) {
      place <- "centre"
    }

    # Use ggfittext's fittexttree to draw text
    gt <- grid::gTree(
      data = data,
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      grow = grow,
      reflow = reflow,
      cl = "fittexttree"
    )
    gt$name <- grid::grobName(gt, "geom_treemap_text")
    gt
  }
)
