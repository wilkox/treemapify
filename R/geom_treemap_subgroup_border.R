#' 'ggplot2' geoms to draw a border around a subgroup of treemap tiles.
#'
#' When `geom_treemap` is used with a `subgroup`, `subgroup2` or `subgroup3`
#' aesthetic to subgroup treemap tiles, `geom_treemap_subgroup_border`,
#' `geom_treemap_subgroup2_border` or `geom_treemap_subgroup3_border` can be
#' used to draw a border around each subgroup at the appropriate level.
#'
#' `geom_treemap_subgroup_border` geoms require `area` and `subgroup` (or
#' `subgroup2, `subgroup3`) aesthetics. Several other standard 'ggplot2'
#' aesthetics are supported (see Aesthetics).
#'
#' Note that 'ggplot2' draws plot layers in the order they are added to the
#' plot. This means that if you add a `geom_treemap_subgroup_border` layer
#' followed by a `geom_treemap_subgroup2_border` layer, the second layer will
#' be drawn on top of the first and may hide it.
#'
#' The `layout` argument is used to set the treemap layout algorithm. All
#' `treemapify` geoms added to a plot should have the same value for `layout`
#' and `start`, or they will not share a common layout (see `geom_treemap` for
#' details on the layout algorithms).
#'
#' @seealso geom_treemap, geom_treemap_subgroup_text
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_rect`.
#' @param layout The layout algorithm, one of either "squarified" (the
#' default), "scol", "srow" or "fixed". See Details for full details on the
#' different layout algorithms.
#' @param start The corner in which to start placing the tiles. One of
#' 'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.
#' @param level One of 'subgroup', 'subgroup2' or 'subgroup3', giving the
#' subgrouping level for which to draw borders. It is recommended to use the
#' aliases `geom_treemap_subgroup2_border` and `geom_treemap_subgroup3_border`
#' instead of this argument.
#' @param fixed Deprecated. Use `layout = "fixed"` instead. Will be removed in
#' later versions.
#'
#' @section Aesthetics:
#'
#' \itemize{
#'   \item area (required)
#'   \item subgroup, subgroup2 or subgroup3 (required)
#'   \item colour
#'   \item size
#'   \item linetype
#'   \item alpha
#' }
#'
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi,
#'                                   subgroup = hemisphere, subgroup2 = region)) +
#'   geom_treemap() +
#'   geom_treemap_subgroup2_border(colour = "white") +
#'   geom_treemap_subgroup_border()
#'
#' @export
geom_treemap_subgroup_border <- function(
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
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomSubgroupBorder,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      fixed = fixed,
      layout = layout,
      start = start,
      level = level,
      ...
    )
  )
}

#' GeomTreemapSubgroupBorder
#' @noRd
GeomSubgroupBorder <- ggplot2::ggproto(
  "GeomSubgroupBorder",
  ggplot2::Geom,
  required_aes = c("area"),
  default_aes = ggplot2::aes(
    colour = "grey50",
    fill = "",
    size = 4,
    linetype = 1,
    alpha = 1
  ),
  draw_key = ggplot2::draw_key_blank,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    fixed = NULL,
    layout = "squarified",
    start = "bottomleft",
    level = "subgroup"
  ) {

    data <- coord$transform(data, panel_scales)

    # Check that subgrouping level is valid and in data
    levels <- c("subgroup", "subgroup2", "subgroup3")
    if (!level %in% levels) {
      stop(
        "`level` must be one of 'subgroup', 'subgroup2' or 'subgroup3'",
        call. = FALSE
      )
    }
    if (!level %in% names(data)) {
      stop(
        "Can't draw a border for subgroup level ", 
        level, 
        " as it is not a plot aesthetic", 
        call. = FALSE
      )
    }

    # Collapse data to groups at selected subgroup level
    levels <- levels[1:(which(levels == level))]
    bys <- lapply(levels, function(x) data[[x]])
    areasums <- aggregate(data$area, by = bys, FUN = sum)
    names(areasums) <- c(levels, "area")
    aesthetics <- c("colour", "size", "linetype", "alpha")
    for (aesthetic in aesthetics) {
      areasums[aesthetic] <- unique(data[[aesthetic]])
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
        fill = NA,
        lwd = data$size,
        lty = data$linetype,
        lineend = "butt"
      )
    )
    grob$name <- grid::grobName(grob, "geom_treemap_subgroup_border")
    grob
  }
)

#' @rdname geom_treemap_subgroup_border
#' @export
geom_treemap_subgroup2_border <- function(...) { 
  geom_treemap_subgroup_border(level = "subgroup2", ...)
}

#' @rdname geom_treemap_subgroup_border
#' @export
geom_treemap_subgroup3_border <- function(...) { 
  geom_treemap_subgroup_border(level = "subgroup3", ...)
}
