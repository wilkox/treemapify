#' @title Add text labels to treemap tiles.
#' @export
#'
#' @description
#'
#' This will draw a text label for each tile in a treemap created by
#' \code{geom_treemap}. In addition to the required 'label' aesthetic, it
#' requires an 'area' aesthetic as used in \code{geom_treemap}; if this is
#' mapped to a different column, or \code{geom_treemap} and
#' \code{geom_treemap_text} are passed different data, the text labels probably
#' won't line up with the tiles.
#'
#' \code{geom_treemap_text} uses \code{geom_fit_text} from the \code{ggfittext}
#' package to fit text to the tile. All text drawing options available in
#' \code{ggfittext} (growing, reflowing, etc.) are also available here. For full
#' details see the documentation for \code{ggfittext::geom_fit_text}.
#'
#' @param padding.x,padding,y Unit object, giving horizontal or vertical padding
#' between text and edge of tile. Defaults to 1 mm.
#' @param place Where should the text be drawn within the tile? One of
#' 'topleft', 'top', 'topright' etc. Defaults to 'topleft'.
#' @param min.size Number, in points. Text that would need to be drawn smaller
#' than this size to fit in the tile will be hidden. Defaults to 4 pt.
#' @param grow Logical; should text grow to fill the entire tile?
#' Defaults to false.
#' @param reflow Logical; should text should be reflowed (wrapped) to better fit
#' the bounding box? Defaults to false.
#' @param fixed Logical, indicating whether the fixed layout algorithm
#' should be used. Defaults to false. See \code{geom_treemap} for full details.
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for \code{geom_rect}.
#'
#' @seealso geom_treemap, geom_fit_text
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

#' @title GeomTreemapText
#' @rdname ggplot2-ggproto
#' @format NULL
#' @usage NULL
#' @export
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

#' @importFrom grid makeContent
#' @export
makeContent.fittexttree <- function(x) { ggfittext:::makeContent.fittexttree(x) }
