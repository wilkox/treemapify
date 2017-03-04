geom_treemap_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = NA,
  inherit.aes = TRUE,
  padding.x = unit(1, "mm"),
  padding.y = unit(1, "mm"),
  place = "topleft",
  min.size = 4,
  fill.text = F,
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
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      fill.text = fill.text,
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
  draw_key = draw_key_rect,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    padding.x = unit(1, "mm"),
    padding.y = unit(1, "mm"),
    min.size = 4,
    fill.text = F,
    place = "centre"
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
    if (!all(data$group == -1)) {
      params$group <- "group"
    }
    layout <- do.call(treemapify, params)

    # Merge layout back into main data
    names(layout)[names(layout) == "label"] <- "id"
    layout <- layout[c("id", "xmin", "xmax", "ymin", "ymax")]
    data <- merge(data, layout, by = "id")

    # Use treemapify's fittexttree to draw text
    gt <- grid::gTree(
      data = data,
      padding.x = padding.x,
      padding.y = padding.y,
      place = place,
      min.size = min.size,
      fill.text = fill.text,
      cl = "fittexttree"
    )
    gt$name <- grid::grobName(gt, "geom_treemap_text")
    gt
  }
)

makeContent.fittexttree <- function(x) { ggfittext::makeContent.fittexttree(x) }
