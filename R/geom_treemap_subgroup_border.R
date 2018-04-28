#' A 'ggplot2' geom to draw a border around a subgroup of treemap tiles.
#'
#' When `geom_treemap` is used with the 'subgroup' aesthetic to subgroup
#' treemap tiles, `geom_treemap_subgroup_border` can be used to draw a
#' border around each subgroup.
#'
#' `geom_treemap_subgroup_border` requires `area` and `subgroup` aesthetics.
#' Several other standard 'ggplot2' aesthetics are supported (see Aesthetics).
#'
#' All `treemapify` geoms added to a plot should have the same value for
#' `fixed`, or they will not share a common layout (see `geom_treemap` for
#' details on the layout algorithms).
#'
#' @seealso geom_treemap, geom_treemap_subgroup_text
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_rect`.
#' @param fixed If `TRUE`, the alternative 'fixed' tile layout algorithm will be
#' used.
#'
#' @section Aesthetics:
#'
#' \itemize{
#'   \item area (required)
#'   \item subgroup (required)
#'   \item colour
#'   \item size
#'   \item linetype
#'   \item alpha
#' }
#'
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi,
#'                                   subgroup = region)) +
#'   geom_treemap() +
#'   geom_treemap_subgroup_border()
#'
#' @export
geom_subgroup_border <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  fixed = F,
  subgroup = "subgroup",
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
      ...
    )
  )
}

#' GeomTreemapSubgroupBorder
#' @noRd
GeomSubgroupBorder <- ggplot2::ggproto(
  "GeomSubgroupBorder",
  ggplot2::Geom,
  required_aes = c("area", "subgroup"),
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
    fixed = F,
    subgroup = "subgroup"
  ) {

    data <- coord$transform(data, panel_scales)

    # Collapse data to groups at selected subgroup level
    areasums <- unlist(lapply(split(data, data$subgroup), function(x) sum(x$area)))
    areasums <- data.frame(subgroup = names(areasums), area = areasums)
    data <- unique(data[c("subgroup", "PANEL", "colour", "size", "linetype", "alpha")])
    data <- merge(data, areasums, by = "subgroup")

    # Generate treemap layout for data
    params <- list(
      data = data,
      area = "area",
      subgroup = subgroup,
      fixed = fixed
    )
    if ("subgroup" %in% names(data)) {
      params$subgroup <- "subgroup"
    }
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
