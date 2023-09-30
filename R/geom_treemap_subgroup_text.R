#' 'ggplot2' geoms to add text labels to treemap subgroups.
#'
#' When `geom_treemap()` is used with the `subgroup`, `subgroup2` or
#' `subgroup3` aesthetic to subgroup treemap tiles,
#' `geom_treemap_subgroup_text()`, `geom_treemap_subgroup2_text()` or
#' `geom_treemap_subgroup3_text()` can be used to add a text label to each
#' subgroup at the appropriate level.
#'
#' `geom_treemap_subgroup_text()` geoms require `area`, `label` and `subgroup`
#' (or `subgroup2`, `subgroup3`) aesthetics. Several other standard 'ggplot2'
#' aesthetics are supported (see Aesthetics).
#'
#' `geom_treemap_subgroup_text()` geoms use the 'ggfittext' package to fit text
#' to the subgroup. All text drawing options available in
#' `ggfittext::geom_fit_text()` (growing, reflowing, etc.) are also available
#' here. For full details on how these options work, see the documentation for
#' `ggfittext::geom_fit_text()`.
#'
#' The `layout` argument is used to set the treemap layout algorithm. All
#' 'treemapify' geoms added to a plot should have the same value for `layout`
#' and `start`, or they will not share a common layout (see `geom_treemap()`
#' for details on the layout algorithms).
#'
#' @param padding.x,padding.y `grid::unit()` object, giving horizontal or
#' vertical padding between text and edge of tile. Defaults to 1 mm.
#' @param place Where inside the box to place the text. Default is `bottom`;
#' other options are `topleft`, `top`, `topright`, etc.
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
#' geom arguments as for `ggplot2::geom_text`.
#' @param level One of 'subgroup', 'subgroup2' or 'subgroup3', giving the
#' subgrouping level for which to draw text labels. It is recommended to use
#' the aliases `geom_treemap_subgroup2_text()` and
#' `geom_treemap_subgroup3_text()` instead of this argument.
#' @param fixed Deprecated. Use `layout = "fixed"` instead. Will be removed in
#' later versions.
#'
#' @seealso [geom_treemap()], [geom_treemap_subgroup_border()]
#'
#' @section Aesthetics:
#'
#' - area (required)
#' - subgroup, subgroup2 or subgroup3 (required; the value of this variable
#' will be the text label)
#' - colour
#' - size
#' - alpha
#' - family
#' - fontface
#' - angle
#' 
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi,
#'                                   subgroup = hemisphere, subgroup2 = region)) +
#'   geom_treemap() +
#'   geom_treemap_subgroup_text(place = "centre", grow = TRUE, alpha = 0.5) +
#'   geom_treemap_subgroup2_text()
#'
#' @export
geom_treemap_subgroup_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = FALSE,
  inherit.aes = TRUE,
  padding.x = grid::unit(1, "mm"),
  padding.y = grid::unit(1, "mm"),
  place = "bottom",
  min.size = 4,
  grow = FALSE,
  reflow = FALSE,
  fixed = NULL,
  layout = "squarified",
  start = "bottomleft",
  level = "subgroup",
  ...
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomSubgroupText,
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
      level = level,
      ...
    )
  )
}

#' GeomTreemapSubgroupText
#' @noRd
#' @import grid
#' @import ggfittext
GeomSubgroupText <- ggplot2::ggproto(
  "GeomSubgroupText",
  ggplot2::Geom,
  required_aes = c("area"),
  default_aes = ggplot2::aes(
    colour = "grey20",
    size = 36,
    alpha = 1,
    family = "",
    fontface = 1,
    angle = 0,
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
    place = "bottom",
    fixed = NULL,
    layout = "squarified",
    start = "bottomleft",
    level = "subgroup"
  ) {

    data <- coord$transform(data, panel_scales)

    # Check that subgrouping level is valid and in data
    levels <- c("subgroup", "subgroup2", "subgroup3")
    if (!level %in% levels) {
      cli::cli_abort("{.arg level} must be one of {.val subgroup}, {.val subgroup2}, or {.val subgroup3}")
    }
    if (!level %in% names(data)) {
      cli::cli_abort("Can't draw text for subgroup level {.val {level}} as it is not a plot aesthetic")
    }

    # Collapse data to groups at selected subgroup level
    levels <- levels[1:(which(levels == level))]
    bys <- lapply(levels, function(x) data[[x]])
    areasums <- aggregate(data$area, by = bys, FUN = sum)
    names(areasums) <- c(levels, "area")
    aesthetics <- c(
      "colour",
      "size",
      "alpha",
      "family",
      "fontface",
      "angle",
      "lineheight"
    )
    for (aesthetic in aesthetics) {
      values <- data[[aesthetic]]
      names(values) <- data[[level]]
      areasums[aesthetic] <- values[as.character(areasums[[level]])]
    }
    data <- areasums

    # Generate treemap layout for data
    params <- list(
      data = data,
      area = "area",
      fixed = fixed,
      layout = layout,
      start = start
    )
    for (l in levels[1:(length(levels) - 1)]) { params[l] <- l }
    data <- do.call(treemapify, params)
    names(data)[names(data) == level] <- "label"

    # Standardise the place argument
    if (place %in% c("middle", "center")) {
      place <- "centre"
    }

    # Use treemapify's fittexttree to draw text
    grob <- grid::gTree(
      data = data,
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      grow = grow,
      reflow = reflow,
      cl = "fittexttree"
    )

    grob$name <- grid::grobName(grob, "geom_treemap_subgroup_text")
    grob
  }
)

#' @rdname geom_treemap_subgroup_text
#' @export
geom_treemap_subgroup2_text <- function(...) { 
  geom_treemap_subgroup_text(level = "subgroup2", ...)
}

#' @rdname geom_treemap_subgroup_text
#' @export
geom_treemap_subgroup3_text <- function(...) { 
  geom_treemap_subgroup_text(level = "subgroup3", ...)
}
