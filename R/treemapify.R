#' Generate a treemap layout.
#'
#' `treemapify` is for generating a data frame of raw treemap coordinates. If
#' you want to draw a treemap with 'ggplot2', use `geom_treemap()` instead.
#'
#' @description
#'
#' `treemapify()` returns a data frame of tile coordinates for a treemap layout
#' of a set of observations. This is only useful if you wish to draw the
#' treemap without the help of the `ggplot2` geoms, or for some edge cases such
#' as creating interactive treemaps with 'R Shiny' (see e.g.
#' <https://stackoverflow.com/q/45021775>). The easiest way to draw a treemap
#' with the 'treemapify' package is to use the provided 'ggplot2' geoms, such
#' as `geom_treemap()`.
#'
#' `data` must be a tidy data frame, i.e. each row must represent a single
#' observation and each column a single variable. You must provide the name of
#' the variable that will be represented by the area of each treemap tile with
#' `area`. Optionally, you can also select up to three variables (with
#' `subgroup`, `subgroup2` and `subgroup3`) to generate a layout in which the
#' tiles are clustered into subgroups nested up to three levels deep.
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
#' `treemapify_fixed` is an alias for `treemapify(layout = "fixed")`.
#'
#' @param data A tidy data frame.
#' @param area Name of the variable (a column in `data`) to be mapped to the
#' area of treemap tiles.
#' @param subgroup,subgroup2,subgroup3 Optionally, names of variables (columns
#' in `data`) by which the tiles should be grouped, at up to three nested
#' levels.
#' @param layout The layout algorithm, one of either 'squarified' (the
#' default), 'scol', 'srow' or 'fixed'. See Details for full details on the
#' different layout algorithms.
#' @param start The corner in which to start placing the tiles. One of
#' 'bottomleft' (the default), 'topleft', 'topright' or 'bottomright'.
#' @param group Deprecated. Use `subgroup` instead. Will be removed in later
#' versions.
#' @param label,fill Deprecated. Will be removed in later versions.
#' @param fixed Deprecated. Use `layout = "fixed"` instead. Will be removed in
#' later versions.
#' @param xlim,ylim The boundaries of the treemap in the x and y dimensions.
#' Must be a numeric vector of length two; both default to `c(0, 1)`.
#' @param ... Additional arguments to be passed to `treemapify()`.
#'
#' @seealso [geom_treemap()]
#'
#' @examples
#'
#' treemapify(G20, area = "gdp_mil_usd")
#'
#' @references
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42).Proceedings of the Joint Eurographics and IEEE TCVG Symposium on
#' Visualization. <https://www.win.tue.nl/~vanwijk/stm.pdf>
#'
#' @export
treemapify <- function(
  data,
  area,
  subgroup,
  subgroup2,
  subgroup3,
  layout = "squarified",
  start = "bottomleft",
  fill = NULL,
  label = NULL,
  group = NULL,
  fixed = NULL,
  xlim = c(0, 1),
  ylim = c(0, 1)
) {

  # Check arguments
  if (missing(data)) {
    cli::cli_abort("{.arg data} is required")
  }
  if (missing(area)) {
    cli::cli_abort("{.arg area} is required")
  }
  if (!area %in% names(data)) {
    cli::cli_abort("Column {.val {area}} not found in data")
  }
  if (!missing(group)) {
    cli::cli_warn("{.arg group} is deprecated, use {.arg subgroup} instead")
    subgroup <- group
  }
  if (!missing(subgroup)) {
    if (!subgroup %in% names(data)) {
      cli::cli_abort("Column {.val {subgroup}} not found in data")
    }
  }
  if (!missing(subgroup2)) {
    if (!subgroup2 %in% names(data)) {
      cli::cli_abort("Column {.val {subgroup2}} not found in data")
    }
  }
  if (!missing(subgroup3)) {
    if (!subgroup3 %in% names(data)) {
      cli::cli_abort("Column {.val {subgroup3}} not found in data")
    }
  }
  if (!missing(fill)) {
    cli::cli_warn("{.arg fill} is deprecated")
  }
  if (!missing(label)) {
    cli::cli_warn("{.arg label} is deprecated")
  }
  if (!(missing(fixed) | is.null(fixed))) {
    cli::cli_warn("{.arg fixed} is deprecated. Use {.code layout = \"fixed\"} instead.")
    if (isTRUE(fixed)) {
      layout <- "fixed"
    }
  }
  if (!layout %in% c("squarified", "scol", "srow", "fixed")) {
    cli::cli_abort("Invalid value for {.arg layout}")
  }
  if (!(is.numeric(xlim) & length(xlim) == 2 & xlim[1] < xlim[2])) {
    cli::cli_abort("{.arg xlim} must be a numeric vector of length 2, with the minimum less than the maximum")
  }
  if (!(is.numeric(ylim) & length(ylim) == 2 & ylim[1] < ylim[2])) {
    cli::cli_abort("{.arg ylim} must be a numeric vector of length 2, with the minimum less than the maximum")
  }

  # Set layout function
  if (layout %in% c("squarified", "scol", "srow")) {
    treemap_f <- treemap_squarified
  } else if (layout == "fixed") {
    treemap_f <- treemap_fixed
  }

  # Set list of subgrouping levels
  subgroups <- character()
  if (!missing(subgroup)) {
    subgroups[1] <- subgroup
  }
  if (!missing(subgroup2)) {
    subgroups[2] <- subgroup2
  }
  if (!missing(subgroup3)) {
    subgroups[3] <- subgroup3
  }

  # Work down subgrouping levels, laying out treemaps for each level
  do_layout <- function(data, subgroups, xlim = c(0, 1), ylim = c(0, 1)) {

    # If there are no subgrouping levels below this one, return a layout for
    # the given observations
    if (length(subgroups) == 0) {
      return(treemap_f(data, area, xlim, ylim, layout))

    # Otherwise, generate a layout for this subgrouping level and fill each
    # subgroup with its own layout
    } else {

      # Sum areas for groups at this subgrouping level
      this_level_data <- lapply(
        split(data, data[subgroups[[1]]], drop = TRUE),
        function(x) sum(x[area])
      )
      this_level_data <- data.frame(
        key = names(this_level_data),
        area = unlist(this_level_data)
      )

      # Generate layout for this subgrouping level
      this_level_layout <- treemap_f(this_level_data, "area", xlim, ylim, layout)

      # For each group at this subgrouping level, generate sub-layouts
      generate_sublayout <- function(group) {

        groupdata <- data[data[subgroups[1]] == group, ]

        # Skip if there are no observations with area > 0
        groupdata <- groupdata[groupdata[[area]] > 0, ]
        if (nrow(groupdata) == 0) { return() }

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
  layout <- do_layout(data, subgroups, xlim, ylim)

  # Flip the coordinates to set the starting corner
  if (start == "topleft") {
    new_ymax <- max(layout$ymax) - layout$ymin
    new_ymin <- max(layout$ymax) - layout$ymax
    layout$ymax <- new_ymax
    layout$ymin <- new_ymin
  } else if (start == "topright") {
    new_ymax <- max(layout$ymax) - layout$ymin
    new_ymin <- max(layout$ymax) - layout$ymax
    layout$ymax <- new_ymax
    layout$ymin <- new_ymin
    new_xmax <- max(layout$xmax) - layout$xmin
    new_xmin <- max(layout$xmax) - layout$xmax
    layout$xmax <- new_xmax
    layout$xmin <- new_xmin
  } else if (start == "bottomright") {
    new_xmax <- max(layout$xmax) - layout$xmin
    new_xmin <- max(layout$xmax) - layout$xmax
    layout$xmax <- new_xmax
    layout$xmin <- new_xmin
  }
  layout
}

#' @rdname treemapify
#' @export
treemapify_fixed <- function(...) {
  treemapify(fixed = TRUE, ...)
}
