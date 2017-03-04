geom_treemap_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  ...
) {
  layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomTreemapText,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      ...
    )
  )
}

#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomTreemapText <- ggproto(
  "GeomTreemapText",
  Geom,
  required_aes = c("area", "label"),
  default_aes = aes(
    colour = "black",
    size = 18,
    alpha = 1,
    family = "",
    angle = 0
  ),
  draw_key = draw_key_polygon,

  draw_panel = function(data, panel_scales, coord) {

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
    if (!all(data$group == -1)) {
      params$group <- "group"
    }
    layout <- do.call(treemapify, params)

    # Merge layout back into main data
    names(layout)[names(layout) == "label"] <- "id"
    layout <- layout[c("id", "xmin", "xmax", "ymin", "ymax")]
    data <- merge(data, layout, by = "id")

    print(data)

    # # Draw rects
    # grob <- rectGrob(
    #   x = data$xmin,
    #   width = data$xmax - data$xmin,
    #   y = data$ymax,
    #   height = data$ymax - data$ymin,
    #   default.units = "native",
    #   just = c("left", "top"),
    #   gp = gpar(
    #     col = data$colour,
    #     fill = alpha(data$fill, data$alpha),
    #     lwd = data$size,
    #     lty = data$linetype,
    #     lineend = "butt"
    #   )
    # )
    # grob$name <- grid::grobName(grob, "geom_treemap_text")
    # grob
  }
)
