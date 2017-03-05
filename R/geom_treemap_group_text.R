geom_treemap_group_text <- function(
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
    geom = GeomTreemapGroupText,
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
GeomTreemapGroupText <- ggproto(
  "GeomTreemapGroupText",
  Geom,
  required_aes = c("area", "group", "group.label"),
  default_aes = aes(
    colour = "grey20",
    fill = "white",
    size = 36,
    alpha = 1,
    family = "",
    fontface = 1,
    angle = 0
  ),
  draw_key = draw_key_blank,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    padding.x = unit(1, "mm"),
    padding.y = unit(1, "mm"),
    min.size = 4,
    fill.text = F,
    place = "bottom"
  ) {

    data <- coord$transform(data, panel_scales)
    data$id <- 1:nrow(data)

    # Sum areas by group
    data <- ddply(data, .(
      group,
      group.label,
      PANEL,
      colour,
      size,
      alpha,
      family,
      fontface,
      angle
    ), summarise, area = sum(as.numeric(area)), fill = head(fill, 1))
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
    names(data)[names(data) == "group.label"] <- "label"

    # Use treemapify's fittexttree to draw text
    grob <- grid::gTree(
      data = data,
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      fill.text = fill.text,
      cl = "fittexttree"
    )

    grob$name <- grid::grobName(grob, "geom_treemap_group_text")
    grob
  }
)
