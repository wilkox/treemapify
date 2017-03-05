#' @title Text labels for treemap groups.
#' @export
#'
#' @description
#'
#' Requires ‘area’ and ‘group’ ‘group.label’ aesthetics. Strange things will
#' happen if ‘group’ and ‘group.label’ don't carve the data into the same
#' groups, or if \code{geom_treemap_group_text} is given a different dataset or
#' area aesthetic than the \code{geom_treemap} it is drawn over.
#'
#' \code{geom_treemap_group_text} uses \code{geom_fit_text} from the
#' \code{ggfittext} package to fit text to the group All text drawing options
#' available in \code{ggfittext} (e.g. expanding text to fill a group) are also
#' available here.
#'
#' @param padding.x,padding,y Unit object, giving horizontal or vertical padding
#' between text and edge of tile. Defaults to 1 mm.
#' @param place Where should the text be drawn within the group? One of
#' ‘topleft’, ‘top’, ‘topright’ etc. Defaults to ‘bottom’.
#' @param min.size Number, in points. Text that would need to be drawn smaller
#' than this size to fit in the group will be hidden. Defaults to 4 pt.
#' @param fill.text Logical; should text be expanded to fill the entire group?
#' Defaults to false.
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for \code{geom_rect}.
#'
#' @seealso geom_treemap, geom_treemap_group_border
#'
#' @section Aesthetics:
#'
#' \itemize{
#'   \item area (required)
#'   \item label (required)
#'   \item colour
#'   \item size
#'   \item alpha
#'   \item family
#'   \item fontface
#'   \item angle
#' }
geom_treemap_group_text <- function(
  mapping = NULL,
  data = NULL,
  stat = "identity",
  position = "identity",
  na.rm = FALSE,
  show.legend = FALSE,
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
  draw_key = draw_key_text,

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
