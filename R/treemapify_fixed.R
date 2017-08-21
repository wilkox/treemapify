#' @rdname treemapify
#' @export
treemapify_fixed <- function(
  data,
  area,
  fill,
  group,
  label,
  xlim = c(0, 100),
  ylim = c(0, 100)
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
  if (missing(fill)) {
    stop("fill is a required argument", call. = F)
  }
  if (!fill %in% names(data)) {
    stop("Fill aesthetic ", fill, " not found in data", call. = F)
  }
  if (!missing(group)) {
    if (!group %in% names(data)) {
      stop("Group aesthetic ", group, " not found in data", call. = F)
    }
    if (!is.factor(data[[group]])) {
      data[[group]] <- factor(data[[group]])
    }
  }
  if (!missing(label)) {
    if (!label %in% names(data)) {
      stop("Label aesthetic ", label, " not found in data", call. = F)
    }
    if (!is.factor(data[[label]])) {
      data[[label]] <- factor(data[[label]])
    }
  }

  # If a group has been specified, generate a group layout then fit each rect
  # inside each group
  if (!missing(group)) {

    # Prepare input for group layout
    groupdata <- data.frame(
      area = data[[area]],
      fill = data[[group]]
    )
    groupdata <- plyr::ddply(groupdata, ~ fill, plyr::summarise, area = sum(area))

    # Calculate group layout
    grouplayout <- treemapify_fixed(groupdata, area = "area", fill = "fill", xlim = xlim, ylim = ylim)

    # Split the input data
    splitdata <- split(data, data[[group]])

    # Function to generate layout for each group
    label_is_missing <- missing(label)
    lay_out_group <- function(groupname) {

      if (label_is_missing) {
        treemapify_fixed(
          data = splitdata[[groupname]],
          area = area,
          fill = fill,
          xlim = c(
            grouplayout[grouplayout$fill == groupname, "xmin"],
            grouplayout[grouplayout$fill == groupname, "xmax"]
          ),
          ylim = c(
            grouplayout[grouplayout$fill == groupname, "ymin"],
            grouplayout[grouplayout$fill == groupname, "ymax"]
          )
        )

      } else {
        treemapify_fixed(
          data = splitdata[[groupname]],
          area = area,
          fill = fill,
          xlim = c(
            grouplayout[grouplayout$fill == groupname, "xmin"],
            grouplayout[grouplayout$fill == groupname, "xmax"]
          ),
          ylim = c(
            grouplayout[grouplayout$fill == groupname, "ymin"],
            grouplayout[grouplayout$fill == groupname, "ymax"]
          ),
          label = label
        )
      }
    }

    # Generate layout for each group and return
    return(plyr::ldply(names(splitdata), lay_out_group))
  }

  # Prepare output data frame
  if (missing(label)) {
    labelcol <- rep(NA, nrow(data))
  } else {
    labelcol <- data[[label]]
  }
  data <- data.frame(
    area = data[[area]],
    fill = data[[fill]],
    label = labelcol
  )

  # Normalise area
  data$area <- data$area / sum(data$area)

  # Prepare output columns
  data$xmin <- data$xmax <- data$ymin <- data$ymax <- rep(NA, nrow(data))

  # Place each rect
  # Algorithm: the area is divided into columns. The number of rects in a full
  # column is set as the square root of the next perfect square >= n. Columns are
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
    width <- sum(data[data$column == data[i, "column"], "area"]) * diff(xlim)

    # The xmin of the column is set by the sum of the areas of the preceeding
    # columns
    xmin <- (sum(data[data$column < data[i, "column"], "area"]) * diff(xlim)) + xlim[1]

    # Set rect x dimensions
    data[i, "xmin"] <- xmin
    data[i, "xmax"] <- xmin + width

    # The height of the rect is set by the area divided by the width
    height <- (data[i, "area"] * diff(xlim) * diff(ylim)) / width

    # The ymin of the rect is set by the sum of the areas of the preceding rects
    # within this column divided by the column width
    ymin <- (sum(data[data$column == data[i, "column"] & rownames(data) < i, "area"]) * diff(xlim) * diff(ylim) / width) + ylim[1]

    # Set rect y dimensions
    data[i, "ymin"] <- ymin
    data[i, "ymax"] <- ymin + height
  }

  # Remove column
  data$column <- NULL

  # Remove label if not provided
  if (missing(label)) {
    data$label <- NULL
  }

  data
}
