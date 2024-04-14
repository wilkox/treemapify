#' Internal function for the 'fixed' treemap layout algorithm.
#' 
#' @noRd
treemap_fixed <- function(data, area, xlim = c(0, 1), ylim = c(0, 1), layout = NULL) {

  # Preserve area column
  if ("area_preserved_fixed" %in% names(data)) cli::cli_abort("{.val area_preserved_fixed} column is present")
  data$area_preserved_fixed <- data[[area]]

  # Remove any rows where area <= 0
  data <- data[data[[area]] > 0, ]

  # Stop if there are no rows
  if (nrow(data) == 0) cli::cli_abort("Must provide some rows with area > 0")

  # Scale areas to sum to the plot area
  data[area] <- data[area] / sum(data[area])

  # Place each tile
  # Algorithm: the area is to divided into columns. The number of tiles in a
  # full column is set as the square root of the next perfect square >= n.
  # Columns are then filled sequentially from left to right, bottom to top,
  # with the width of the column set proportional to the sum area of the column
  # tiles and the height divided between the tiles following their areas.

  # Select number of tiles per column
  tiles_per_column <- ceiling(sqrt(nrow(data)))
  data$column <- ceiling(seq_len(nrow(data)) / tiles_per_column)

  # Place each tile
  for (i in seq_len(nrow(data))) {

    # The width of the column is set by the sum of the areas of all column tiles
    # as a proportion of the total area
    width <- sum(data[data$column == data[i, "column"], area])

    # The xmin of the column is set by the sum of the areas of the preceding
    # columns
    xmin <- sum(data[data$column < data[i, "column"], area])

    # Set tile x dimensions
    data[i, "xmin"] <- xmin
    data[i, "xmax"] <- xmin + width

    # The height of the tile is set by the area divided by the width
    height <- data[i, area] / width

    # The ymin of the tile is set as the ymax of any preceding tile within this
    # column
    data[i, "ymax"] <- 0
    ymin <- max(data[data$column == data[i, "column"], "ymax"], na.rm = TRUE)

    # Set tile y dimensions
    data[i, "ymin"] <- ymin
    data[i, "ymax"] <- ymin + height
  }

  # Remove column column
  data$column <- NULL

  # Rescale values to the plot area
  width <- diff(xlim)
  height <- diff(ylim)
  data$xmin <- xlim[1] + (data$xmin * width)
  data$xmax <- xlim[1] + (data$xmax * width)
  data$ymin <- ylim[1] + (data$ymin * height)
  data$ymax <- ylim[1] + (data$ymax * height)

  # Restore the area column
  data[[area]] <- data$area_preserved_fixed
  data$area_preserved_fixed <- NULL

  # Return layout
  data
}
