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
  data$area <- data$area / sum(data$area) * 100 * 100

  # Prepare output columns
  data$xmin <- data$xmax <- data$ymin <- data$ymax <- rep(NA, nrow(data))

  # Place each rect
  # Algorithm: the layout for an increasing number of rects is determined by
  # splitting the space occupied by the ‘previous’ rect first horizontally, then
  # vertically.
  xlim <- c(0, 100)
  ylim <- c(0, 100)
  for (i in 1:nrow(data)) {

    # Placing an odd-numbered rect
    if (i %% 2 == 1) {

      # If this is the last rect to place
      if (i == nrow(data)) {

        # Fill the remaining area with this rect
        data[i, "xmin"] <- xlim[1]
        data[i, "xmax"] <- xlim[2]
        data[i, "ymin"] <- ylim[1]
        data[i, "ymax"] <- ylim[2]

      # If this is not the last rect to place
      } else {

        # This rect can occupy the full width of the remaining area; its height
        # is determined by its area
        data[i, "xmin"] <- xlim[1]
        data[i, "xmax"] <- xlim[2]
        width <- xlim[2] - xlim[1]
        height <- data[i, "area"] / width
        data[i, "ymin"] <- ylim[1]
        data[i, "ymax"] <- ylim[1] + height

        # Update remaining area
        ylim <- c(data[i, "ymax"], ylim[2])
      }

    # Placing an even-numbered rect
    } else {

      # If this is the last rect to place
      if (i == nrow(data)) {

        # Fill the remaining area with this rect
        data[i, "xmin"] <- xlim[1]
        data[i, "xmax"] <- xlim[2]
        data[i, "ymin"] <- ylim[1]
        data[i, "ymax"] <- ylim[2]

      # If this is not the last rect to place
      } else {

        # This rect can occupy the full height of the remaining area; its width
        # is determined by its area
        data[i, "ymin"] <- ylim[1]
        data[i, "ymax"] <- ylim[2]
        height <- ylim[2] - ylim[1]
        width <- data[i, "area"] / height
        data[i, "xmin"] <- xlim[1]
        data[i, "xmax"] <- xlim[1] + width

        # Update remaining area
        xlim <- c(data[i, "xmax"], xlim[2])
      }
    }
  }
}
