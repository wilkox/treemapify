#' A 'ggplot2' geom to draw a treemap.
#'
#' A treemap is a rectangular plot divided into tiles, each of which represents
#' a single observation. The relative area of each tile expresses a continuous
#' variable.
#'
#' `geom_treemap()` requires an `area` aesthetic. It will ignore any aesthetics
#' relating to the x and y axes (e.g. `xmin` or `y`), as the x and y axes are
#' not meaningful in a treemap. Several other standard 'ggplot2' aesthetics are
#' supported (see Aesthetics). To add text labels to tiles, see
#' `geom_treemap_text()`.
#'
#' An optional `subgroup` aesthetic will cause the tiles to be clustered in
#' subgroups within the treemap. See `geom_treemap_subgroup_border()` and
#' `geom_treemap_subgroup_text()` to draw borders around subgroups and label
#' them, respectively. Up to three nested levels of subgrouping are supported,
#' with `subgroup2` and `subgroup3` aesthetics and respective
#' `geom_treemap_subgroup2_border()` etc. geoms.
#'
#' Four layout algorithms are provided. With the default 'squarified' algorithm
#' (`layout = "squarified"`), the priority is ensuring the tiles have an
#' aesthetically pleasing aspect ratio; that is, they are not too narrow or too
#' short. In this algorithm, tile placement proceeds from one corner, placing
#' the tiles in either rows or columns until all the tiles are placed. See
#' Bruls et al. (1999) for the full algorithm.
#'
#' There are two variants on the 'squarified' algorithm. 'scol' forces tile
#' placement to begin with a column, regardless of the effect on aspect ratio;
#' 'srow' forces tile placement to been with a row. This will also apply to all
#' subgroups. After the first row or column, the remaining tiles will be placed
#' so as to optimise aspect ratios, as with the default algorithm.
#'
#' With the 'fixed' layout algorithm (`layout = "fixed"`), the plot area is
#' divided into vertical columns, which are each filled  with an equal number
#' of tiles beginning at the starting corner. Unlike the 'squarified'
#' algorithm, with the 'fixed' algorithm the relative positions of the tiles
#' are fixed by their order in the input data frame. This can result in
#' aesthetically unpleasing layouts, but it allows side-by-side comparisons or
#' animations to be created.
#'
#' All 'treemapify' geoms added to a plot should have the same value for
#' `layout` and `start`, or they will not share a common layout.
#'
#' @section Aesthetics:
#'
#' - area (required)
#' - alpha
#' - colour
#' - fill
#' - linetype
#' - subgroup
#' - subgroup2
#' - subgroup3
#'
#' @param mapping,data,stat,position,na.rm,show.legend,inherit.aes,... Standard
#' geom arguments as for `ggplot2::geom_rect()`.
#' @param layout The layout algorithm, one of either 'squarified' (the
#' default), 'scol', 'srow' or 'fixed'. See Details for full details on the
#' different layout algorithms.
#' @param start The corner in which to start placing the tiles. One of
#' 'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.
#' @param fixed Deprecated. Use `layout = "fixed"` instead. Will be removed in
#' later versions.
#' @param radius corner radius (default 0pt)
#'
#' @seealso [geom_treemap_text()], [geom_treemap_subgroup_border()],
#' [geom_treemap_subgroup_text()]
#'
#' @references
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42). Proceedings of the Joint Eurographics and IEEE TCVG Symposium on
#' Visualization. <https://vanwijk.win.tue.nl/stm.pdf>
#'
#' @examples
#'
#' ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = region)) +
#'  geom_treemap()
#'
#' @importFrom ggplot2 alpha
#' @author David Wilkins (david@@wilkox.org)
#' @author Bob Rudis (bob@@rud.is)
#' @export
geom_treemap <- function(
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
  radius = grid::unit(0, "pt"),
  ...
) {
  ggplot2::layer(
    data = data,
    mapping = mapping,
    stat = stat,
    geom = GeomTreemap,
    position = position,
    show.legend = show.legend,
    inherit.aes = inherit.aes,
    params = list(
      na.rm = na.rm,
      fixed = fixed,
      layout = layout,
      start = start,
      radius = radius,
      ...
    )
  )
}


#' Round rect key glyph for legend
#'
#' @param data A single row data frame containing the scaled aesthetics to
#' display in this key
#' @param params A list of additional parameters supplied to the geom.
#' @param size Width and height of key in mm.
#' @importFrom grid roundrectGrob
#' @author Bob Rudis (bob@@rud.is)
#' @export
draw_key_rrect <- function(data, params, size) {
  grid::roundrectGrob(
    r = min(params$radius, unit(3, "pt")),
    default.units = "native",
    width = 0.9,
    height = 0.9,
    name = "lkey",
    gp = grid::gpar(
      col = data$colour %l0% "white",
      fill = ggplot2::fill_alpha(
        data$fill %||% data$colour %||% "grey20",
        data$alpha
      ),
      lty = data$linetype %||% 1
    )
  )
}

#' GeomTreemap
#'
#' @rdname treemapify-ggproto
#' @format NULL
#' @usage NULL
#' @export
GeomTreemap <- ggplot2::ggproto(
  "GeomTreemap",
  ggplot2::Geom,
  required_aes = c("area"),
  default_aes = ggplot2::aes(
    colour = "grey",
    fill = "grey35",
    size = 0.5,
    linetype = 1,
    alpha = 1
  ),

  draw_key = draw_key_rrect,

  draw_panel = function(
    data,
    panel_scales,
    coord,
    fixed = NULL,
    layout = "squarified",
    start = "bottomleft",
    radius = grid::unit(0, "pt")
  ) {
    data <- coord$transform(data, panel_scales)

    # Generate treemap layout for data
    tparams <- list(
      data = data,
      area = "area",
      fixed = fixed,
      layout = layout,
      start = start
    )
    for (x in intersect(c("subgroup", "subgroup2", "subgroup3"), names(data))) {
      tparams[x] <- x
    }
    data <- do.call(treemapify, tparams)

    lapply(seq_along(data$xmin), function(i) {
      grid::roundrectGrob(
        x = data$xmin[i],
        width = data$xmax[i] - data$xmin[i],
        y = data$ymax[i],
        height = data$ymax[i] - data$ymin[i],
        default.units = "native",
        r = radius,
        just = c("left", "top"),
        gp = grid::gpar(
          col = data$colour[i],
          fill = ggplot2::fill_alpha(data$fill[i], data$alpha[i]),
          lwd = data$size[i],
          lty = data$linetype[i]
        )
      )
    }) -> gl

    grobs <- do.call(grid::gList, gl)

    ggname("geom_treemap", grid::grobTree(children = grobs))
  }
)
