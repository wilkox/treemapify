#' Internal function for the 'squarified' treemap layout algorithm.
#'
#' @noRd
treemap_squarified <- function(data, area, xlim = c(0, 1), ylim = c(0, 1), layout = "squarified") {

  # Preserve area column
  if ("area_preserved_squarified" %in% names(data)) cli::cli_abort("{.val area_preserved_squarified} column is present")
  data$area_preserved_squarified <- data[[area]]

  # Remove any rows where area <= 0
  data <- data[data[[area]] > 0, ]

  # Stop if there are no rows
  if (nrow(data) == 0) {
    cli::cli_abort("Must provide some rows with area > 0")
  }

  # Sort the data by area, largest to smallest
  data <- data[order(-data[[area]]), ]

  # Scale areas to sum to plot area
  plot_area <- diff(xlim) * diff(ylim)
  data[area] <- plot_area * data[area] / sum(data[area])

  # Generate the tile layout, in either row- or column-first order
  if (layout == "squarified") {
    tile_f <- next_tile_f(xlim[1], xlim[2], ylim[1], ylim[2])
  } else if (layout == "srow") {
    tile_f <- tile_row
  } else if (layout == "scol") {
    tile_f <- tile_column
  }
  layout <- tile_f(
    data,
    area,
    xmin = xlim[1],
    xmax = xlim[2],
    ymin = ylim[1],
    ymax = ylim[2],
    layout = layout
  )

  # Remove the 'column' column
  layout["column"] <- NULL

  # Restore the area column
  layout[[area]] <- layout$area_preserved_squarified
  layout$area_preserved_squarified <- NULL

  # Return layout
  layout
}

#' For a set of tile areas to be placed in a row of defined dimensions, return
#' the worst aspect ratio.
#'
#' @noRd
worst_ar <- function(areas, long_dim) {

  # Calculate the short dimension of the row
  short_dim <- sum(areas) / long_dim

  # Calculate the tile dimensions along the long axis
  tile_long_dims <- areas / short_dim

  # Calculate the tile aspect ratios
  aspect_ratios <- tile_long_dims / short_dim
  aspect_ratios <- ifelse(aspect_ratios < 1, 1 / aspect_ratios, aspect_ratios)

  # Return the worst aspect ratio
  max(aspect_ratios)
}

#' Select the next tiling direction based on the aspect ratio of the remaining
#' area
#'
#' @noRd
next_tile_f <- function(xmin, xmax, ymin, ymax) {

  if (diff(c(xmin, xmax)) >= diff(c(ymin, ymax))) {
    return(tile_column)
  } else {
    return(tile_row)
  }
}

#' Place tiles in an area of defined dimensions, beginning with a row.
#'
#' @noRd
tile_row <- function(data, area, xmin, xmax, ymin, ymax, layout) {

  # For each possible number of tiles in the row, calculate the worst aspect
  # ratio of a tile in the row and select the number of tiles that provides
  # the least worst ratio
  row_n <- which.min(vapply(
    seq_len(nrow(data)),
    function(x) worst_ar(data[[area]][1:x], xmax - xmin),
    FUN.VALUE = double(1)
  ))

  # Determine the coordinates for the selected number of tiles
  tiles <- data[1:row_n, ]
  row_long_dimension <- xmax - xmin
  row_short_dimension <- sum(tiles[[area]]) / row_long_dimension
  tiles$xdim <- tiles[[area]] / row_short_dimension
  tiles$xmax <- xmin + cumsum(tiles$xdim)
  tiles$xmin <- tiles$xmax - tiles$xdim
  tiles$ymin <- ymin
  tiles$ymax <- ymin + row_short_dimension
  tiles$xdim <- NULL
  tiles[[area]] <- NULL

  # Update the remaining area
  ymin <- ymin + row_short_dimension

  # Remove the placed tiles from the data frame
  data <- data[-1:-row_n, ]

  # If there are no more tiles to place, return the tile coordinates
  if (nrow(data) == 0) {
    return(tiles)

  # If there are more tiles to place, fill in the remaining area with the
  # appropriate function
  } else {
    tile_f <- next_tile_f(xmin, xmax, ymin, ymax)
    return(rbind(tiles, tile_f(data, area, xmin, xmax, ymin, ymax, layout)))
  }
}

#' Place tiles in an area of defined dimensions, beginning with a column.
#'
#' @noRd
tile_column <- function(data, area, xmin, xmax, ymin, ymax, layout) {

  # For each possible number of tiles in the column, calculate the worst
  # aspect ratio of a tile in the column and select the number of tiles that
  # provides the least worst ratio
  column_n <- which.min(vapply(
    seq_len(nrow(data)),
    function(x) worst_ar(data[[area]][1:x], ymin - ymax),
    FUN.VALUE = double(1)
  ))

  # Determine the coordinates for the selected number of tiles
  tiles <- data[1:column_n, ]
  column_long_dimension <- ymax - ymin
  column_short_dimension <- sum(tiles[[area]]) / column_long_dimension
  tiles$ydim <- tiles[[area]] / column_short_dimension
  tiles$ymax <- ymin + cumsum(tiles$ydim)
  tiles$ymin <- tiles$ymax - tiles$ydim
  tiles$xmin <- xmin
  tiles$xmax <- xmin + column_short_dimension
  tiles$ydim <- NULL
  tiles[[area]] <- NULL

  # Update the remaining area
  xmin <- xmin + column_short_dimension

  # Remove the placed tiles from the data frame
  data <- data[-1:-column_n, ]

  # If there are no more tiles to place, return the tile coordinates
  if (nrow(data) == 0) {
    return(tiles)

  # If there are more tiles to place, fill in the remaining area with the
  # appropriate function
  } else {
    tile_f <- next_tile_f(xmin, xmax, ymin, ymax)
    return(rbind(tiles, tile_f(data, area, xmin, xmax, ymin, ymax, layout)))
  }
}
