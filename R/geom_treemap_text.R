#' A 'ggplot2' geom to add text labels to treemap tiles
#'
#' `geom_treemap_text` can be used to add a text label to each tile in a treemap
#' created with `geom_treemap`.
#'
#' `geom_treemap_text` requires `area` and `label` aesthetics. Several other
#' standard 'ggplot2' aesthetics are supported (see Aesthetics).
#'
#' `geom_treemap_text` uses the 'ggfittext' package to fit text to tiles. All
#' text drawing options available in `ggfittext::geom_fit_text` (growing,
#' reflowing, etc.) are also available here. For full details on how these
#' options work, see the documentation for `ggfittext::geom_fit_text`.
#'
#' All `treemapify` geoms added to a plot should have the same value for
#' `fixed`, or they will not share a common layout (see `geom_treemap` for
#' details on the layout algorithms).
#'
#' @param padding.x,padding.y `grid::unit` object, giving horizontal or vertical
#' padding between text and edge of tile. Defaults to 1 mm.
#' @param place Where inside the box to place the text. Default is `bottom`;
#' other options are `topleft`, `top`, `topright`, etc.
#' @param min.size Minimum font size, in points. If provided, text that would
#' need to be shrunk below this size to fit the box will not be drawn. Defaults
#' to 4 pt.
#' @param grow If `TRUE`, text will be grown as well as shrunk to fill the box.
#' @param reflow If `TRUE`, text will be reflowed (wrapped) to better fit the
#' box.
#' @param fixed If `TRUE`, the alternative 'fixed' tile layout algorithm will be
#' used.
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_text`.
#'
#' @seealso geom_treemap
#'
#' @section Aesthetics:
#'
#' \itemize{
#'   \item area (required)
#'   \item label (required)
#'   \item subgroup
#'   \item colour
#'   \item size
#'   \item alpha
#'   \item family
#'   \item fontface
#'   \item angle
#' }
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
  grow = F,
  reflow = F,
  fixed = F,
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
    grow = F,
    reflow = F,
    fixed = F,
    place = "centre",
    subgroup = NA
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
