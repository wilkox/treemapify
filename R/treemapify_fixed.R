#' @title Generate coordinates for a treemap with a fixed layout
#' @export
#' @family treemapify
#'
#' @description
#'

treemapify_fixed <- function(
  data,
  area,
  group
) {

  # Check arguments
  if (missing(data)) {
    stop("data is a required argument", call. = F)
  }
  if (missing(area)) {
    stop("area is a required argument", call. = F)
  }
  if (!area %in% names(data)) {
    stop("Area aesthetic ", area, " not found in data", call. = F)
  }
  if (!missing(group)) {
    if (!group %in% names(data)) {
      stop("Group aesthetic ", group, " not found in data", call. = F)
    }
    if (!is.factor(data[[group]])) {
      data[[group]] <- factor(data[[group]])
    }
  }

  if (!missing(group)) {
    stop("groups not yet implemented", call. = F)
  }

  # Normalise area
  data <- data.frame(area = data[[area]])
  data$area <- data$area / sum(data$area)

  # Prepare output columns
  data$xmin <- data$xmax <- data$ymin <- data$ymax <- rep(NA, nrow(data))

  # Place each rect
  # Algorithm: the area is divided into columns. The number of rects in a full
  # column is set as the square root of the next perfect square ≥ n. Columns are
  # then filled sequentially from left to right, bottom to top, with the width
  # of the column set proportional to the sum area of the column rects and the
  # height divided between the rects following their areas.

  # Select number of rects per column
  rects_per_column <- ceiling(sqrt(nrow(data)))
  data$column <- ceiling(1:nrow(data) / rects_per_column)

  # Place each rect
  for (i in 1:nrow(data)) {

    # The width of the column is set by the sum of the areas of all column rects
    # as a proportion of the total area
    width <- sum(data[data$column == data[i, "column"], "area"]) * 100

    # The xmin of the column is set by the sum of the areas of the preceeding
    # columns
    xmin <- 100 * sum(data[data$column < data[i, "column"], "area"])

    # Set rect x dimensions
    data[i, "xmin"] <- xmin
    data[i, "xmax"] <- xmin + width

    # The height of the rect is set by the area divided by the width
    height <- (data[i, "area"] * 10000) / width

    # The ymin of the rect is set by the sum of the areas of the preceding rects
    # within this column divided by the column width
    ymin <- sum(data[data$column == data[i, "column"] & rownames(data) < i, "area"]) * 10000 / width

    # Set rect y dimensions
    data[i, "ymin"] <- ymin
    data[i, "ymax"] <- ymin + height
  }

}
