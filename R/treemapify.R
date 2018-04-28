#' Generate a treemap layout.
#'
#' `treemapify` is for generating raw treemap coordinates. If you want to draw
#' a treemap with 'ggplot2', use `geom_treemap` instead.
#'
#' @description
#'
#' `treemapify` returns a data frame of tile coordinates for a treemap layout
#' of a set of observations. This is only useful if you wish to draw the
#' treemap without the help of the `ggplot2` geoms, or for some edge cases such
#' as creating interactive treemaps with 'R Shiny' (see e.g.
#' \url{https://stackoverflow.com/q/45021775}). The easiest way to draw a
#' treemap with this package is to use the provided 'ggplot2' geoms, such as
#' `geom_treemap`.
#'
#' The input data frame must be in tidy format, i.e. each row must represent a
#' single observation and each column a single variable. You must provide the
#' name of the variable that will be represented by the area of each treemap
#' tile. Optionally, you can also select up to three variables (`subgroup`, `subgroup2`
#' and `subgroup3`) to generate a layout in which subgroups of tiles are nested up to
#' three levels deep.
#'
#' Two algorithms for the tile layout are provided. With the default
#' 'squarified' algorithm, the priority is ensuring the tiles have an
#' aesthetically pleasing aspect ratio; that is, they are not too narrow or too
#' short. In this algorithm, tile placement proceeds from the bottom left
#' corner, moving alternately rightwards and upwards until all tiles are
#' placed. See Bruls et al. (1999) for the full algorithm.
#'
#' With the alternative 'fixed' layout algorithm (`fixed = TRUE`), the plot area
#' is divided into vertical columns, which are filled from left to right with an
#' equal number of tiles beginning at the bottom of each column. Unlike the
#' default 'squarified' algorithm, with the 'fixed' algorithm the relative
#' positions of the tiles are fixed by their order in the input data frame. This
#' can result in aesthetically unpleasing tiles, but it allows side-by-side
#' comparisons or animations to be created.
#'
#' @param data A tidy data frame.
#' @param area Name of the variable (a column in `data`) to be mapped to the
#' area of treemap tiles.
#' @param subgroup, subgroup2, subgroup3 Optionally, names of variables by which the tiles
#' should be grouped, at up to three levels of depth.
#' @param fixed If true, the alternative 'fixed' algorithm will be used (see
#' Details).
#'
#' @seealso geom_treemap
#'
#' @examples
#'
#' treemapify(G20, area = "gdp_mil_usd", fill = "hdi", group = "region",
#'            label = "country")
#'
#' @references
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42).Proceedings of the Joint Eurographics and IEEE TCVG Symposium on
#' Visualization. \url{http://www.win.tue.nl/~vanwijk/stm.pdf}
#'
#' @export
treemapify <- function(
  data,
  area,
  subgroup,
  subgroup2,
  subgroup3,
  fixed = FALSE
) {

  # Check for missing arguments
  if (missing(data)) {
    stop("`data` is required", call. = F)
  }
  if (missing(area)) {
    stop("`area` is required", call. = F)
  }
  if (!area %in% names(data)) {
    stop("Column", area, " not found in data", call. = F)
  }
  if (!missing(subgroup)) {
    if (!subgroup %in% names(data)) {
      stop("Column", subgroup, " not found in data", call. = F)
    }
  }
  if (!missing(subgroup2)) {
    if (!subgroup2 %in% names(data)) {
      stop("Column", subgroup2, " not found in data", call. = F)
    }
  }
  if (!missing(subgroup3)) {
    if (!subgroup3 %in% names(data)) {
      stop("Column", subgroup3, " not found in data", call. = F)
    }
  }

  # Set layout function
  treemap_f <- ifelse(fixed, treemap_fixed, treemap_squarified)

  # Set list of subgrouping levels
  subgroups <- unlist(as.list(match.call())[c("subgroup", "subgroup2", "subgroup3")])

  # Work down subgrouping levels, laying out treemaps for each level
  do_layout <- function(data, subgroups, xlim = c(0, 1), ylim = c(0, 1)) {


    # If there are no subgrouping levels below this one, return a layout for the
    # given observations
    if (length(subgroups) == 0) {
      return(treemap_f(data, area, xlim, ylim))

    # Otherwise, generate a layout for this subgrouping level and fill each subgroup
    # with its own layout
    } else {

      # Sum areas for groups at this subgrouping level
      this_level_data <- lapply(
        split(data, data[subgroups[[1]]], drop = T),
        function(x) sum(x[area])
      )
      this_level_data <- data.frame(
        key = names(this_level_data),
        area = unlist(this_level_data)
      )

      # Generate layout for this subgrouping level
      this_level_layout <- treemap_f(this_level_data, "area", xlim, ylim)

      # For each group at this subgrouping level, generate sub-layouts
      generate_sublayout <- function(group) {

        groupdata <- data[data[subgroups[1]] == group, ]

        # Generate sub-layout
        groupcoords <- this_level_layout[this_level_layout$key == group, ]
        sublayout <- do_layout(
          groupdata,
          subgroups[-1],
          xlim = c(groupcoords$xmin, groupcoords$xmax),
          ylim = c(groupcoords$ymin, groupcoords$ymax)
        )

        sublayout
      }
      groups <- as.character(unique(data[[subgroups[1]]]))
      do.call("rbind", lapply(groups, generate_sublayout))
    }
  }
  do_layout(data, subgroups)
}
