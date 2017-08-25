#' Generate a treemap layout.
#'
#' `treemapify` and `treemapify_fixed` produce a set of raw coordinates used to
#' draw a treemap from a data frame of observations. To draw a treemap with
#' 'ggplot2', use `geom_treemap` instead.
#'
#' `treemapify` and `treemapify_fixed` return a data frame of tile coordinates
#' for the treemap. This is only useful if you wish to draw the treemap without
#' 'ggplot2', or for some edge cases such as treemaps drawn in 'R Shiny' (see
#' e.g. \url{https://stackoverflow.com/q/45021775}). The easiest way to draw a
#' treemap with this package is to use the provided 'ggplot2' geoms, such as
#' `geom_treemap`.
#'
#' Input data frame must be in tidy format, i.e. each row must represent a
#' single observation and each column a single variable. You must provide, as
#' arguments, the names of the variables that will be represented by the area
#' and fill colour of treemap tiles. Optionally, you can also select a variable
#' by which to group the tiles within the treemap layout, and a variable that
#' will be preserved as a label for each tile.
#'
#' Two algorithms for the tile layout are provided. With the default
#' 'squarified' algorithm (`treemapify`), the priority is ensuring the tiles
#' have an aesthetically pleasing aspect ratio; that is, they are not too narrow
#' or too short. In this algorithm, tile placement proceeds from the bottom left
#' corner, moving alternately rightwards and upwards until all tiles are placed.
#' See Bruls et al. (1999) for the full algorithm.
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
#' @param fill Name of the variable (a column in `data`) to be mapped to the
#' fill colour of treemap tiles.
#' @param group Optionally, name of the variable (a column in `data`) by which
#' the tiles will be grouped; that is, in the final treemap layout, these tiles
#' will be kept together.
#' @param label Optionally, name of the variable (a column in `data`) giving
#' tile labels that will be preserved in the output data frame.
#' @param xlim,ylim Optional two-element vectors specifying the x and y limits
#' of the plot area into which the treemap is to be drawn.
#'
#' @seealso geom_treemap
#'
#' @examples
#'
#' treemapify(G20, area = "gdp_mil_usd", fill = "hdi", group = "region",
#'            label = "country")
#'
#'
#' treemapify_fixed(G20, area = "gdp_mil_usd", fill = "hdi", group = "region",
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
  fill,
  group,
  label,
  xlim = c(0,100),
  ylim = c(0,100)
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

  # Handle groups, if so requested
  if (missing(group) == FALSE) {

    # Build the treeMapData data frame
    if (missing(label)) {
      treeMapData <- data.frame(area = data[area],
                                fill = data[fill],
                                group = data[group])
      names(treeMapData) <- c("area", "fill", "group")
    } else {
      treeMapData <- data.frame(area = data[area],
                                fill = data[fill],
                                group = data[group],
                                label = data[label])
      names(treeMapData) <- c("area", "fill", "group", "label")
    }

    # Scale areas to sum to total plot area
    plotArea <- prod(diff(xlim), diff(ylim))
    scaleFactor <- plotArea / sum(as.numeric(treeMapData$area))
    treeMapData$area <- scaleFactor * treeMapData$area

    # To get the placement for each group, sum the area and generate a treemap
    # that places each group
    groupData <- plyr::ddply(treeMapData, "group", plyr::summarise,
                       area = sum(as.numeric(area)),
                       fill = group[1])
    groupTreeMap <- treemapify(groupData, area = "area",
                               fill = "fill",
                               xlim = xlim,
                               ylim = ylim)

    # Build the output data frame
    if (missing(label)) {
      treeMap <- data.frame(area = numeric(),
                            fill = factor(),
                            group = factor(),
                            xmin = numeric(),
                            xmax = numeric(),
                            ymin = numeric(),
                            ymax = numeric())
    } else {
      treeMap <- data.frame(area = numeric(),
                            fill = factor(),
                            group = factor(),
                            label = character(),
                            xmin = numeric(),
                            xmax = numeric(),
                            ymin = numeric(),
                            ymax = numeric())
    }

    # For each group, generate a treemap within the area allocated for the
    # group
    for (thisGroup in groupTreeMap[["fill"]]) {
      xmin <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["xmin"])
      xmax <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["xmax"])
      ymin <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["ymin"])
      ymax <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["ymax"])
      thisGroupData <- treeMapData[treeMapData[,"group"] == thisGroup,]
      if (missing(label)) {
        thisGroupRects <- treemapify(thisGroupData,
                                     fill = "fill",
                                     area = "area",
                                     xlim = c(xmin, xmax),
                                     ylim = c(ymin, ymax))
      } else {
        thisGroupRects <- treemapify(thisGroupData,
                                     fill = "fill",
                                     area = "area",
                                     label = "label",
                                     xlim = c(xmin, xmax),
                                     ylim = c(ymin, ymax))
      }
      thisGroupRects["group"] <- thisGroup
      treeMap <- rbind(treeMap, thisGroupRects)
    }

    # Add the fill name as an attribute - useful for plotting later
    attr(treeMap, "fillName") <- fill

    # Return the grouped treemap
    treeMap$area <- NULL
    return(treeMap)
  }

  # Build the treeMapData data frame
  if (missing(label)) {
    treeMapData <- data.frame(area = data[area],
                              fill = data[fill])
    names(treeMapData) <- c("area", "fill")
  } else {
    treeMapData <- data.frame(area = data[area],
                              fill = data[fill],
                              label = data[label])
    names(treeMapData) <- c("area", "fill", "label")
  }

  # Sorted by area, largest to smallest
  treeMapData <- treeMapData[with(treeMapData, order(-area)), ]

  # Scale areas to sum to total plot area
  plotArea <- prod(diff(xlim), diff(ylim))
  scaleFactor <- plotArea / sum(as.numeric(treeMapData$area))
  treeMapData$area <- scaleFactor * treeMapData$area

  # This is the "master" output data frame, holding the locations of all the
  # treemap rects
  if (missing(label)) {
    treeMap <- data.frame(area = numeric(),
                          fill = factor(),
                          xmin = numeric(),
                          xmax = numeric(),
                          ymin = numeric(),
                          ymax = numeric())
  } else {
    treeMap <- data.frame(area = numeric(),
                          fill = factor(),
                          label = character(),
                          xmin = numeric(),
                          xmax = numeric(),
                          ymin = numeric(),
                          ymax = numeric())
  }

  # These variables track the empty space remaining in the tree map
  emptyxMin <- xlim[1]
  emptyxMax <- xlim[2]
  emptyyMin <- ylim[1]
  emptyyMax <- ylim[2]

  # This tells us the row number of the top unplaced rect
  stackPointer <- 1

  # Keep making new rows until all rects are placed
  continue <- TRUE
  while (continue) {

    # This tracks how many rects are currently being tested in the row -
    # initialise with 1
    nInRow <- 1

    # Determine subdivide direction for the row
    emptyx <- emptyxMax - emptyxMin
    emptyy <- emptyyMax - emptyyMin
    if (emptyx > emptyy) {
      subdivideDirection <- "horizontal"
    } else if (emptyx < emptyy) {
      subdivideDirection <- "vertical"
    } else if (emptyx == emptyy) {
      subdivideDirection <- "horizontal"

    }

    # Get the long dimension for the row
    if (subdivideDirection == "horizontal") {
      rowLongDimension = emptyyMax - emptyyMin
    } else {
      rowLongDimension = emptyxMax - emptyxMin
    }

    # This holds the aspect ratio for the last number-of-rects-in-row tried.
    # Initialise with infinity so first row isn't rejected
    lastAspectRatio <- Inf

    # This stores the stack pointer for the start of this row
    stackPointerRow <- stackPointer

    # Try increasing numbers of rects in the row, until the best-ish solution
    # is found
    while (continue) {

      # Initialise a trial row
      if (missing(label)) {
        treeMapRow <- data.frame(area = numeric(),
                                 fill = factor(),
                                 xmin = numeric(),
                                 xmax = numeric(),
                                 ymin = numeric(),
                                 ymax = numeric())
      } else {
        treeMapRow <- data.frame(area = numeric(),
                                 fill = factor(),
                                 label = character(),
                                 xmin = numeric(),
                                 xmax = numeric(),
                                 ymin = numeric(),
                                 ymax = numeric())
      }

      # Reset the stack pointer to the start of this row
      stackPointer <- stackPointerRow

      # Get the total area that will be filled by this row
      totalRowArea <- sum(as.numeric(treeMapData$area[stackPointer:(stackPointer + nInRow - 1)]))

      # Get the short dimension for the row
      rowShortDimension <- totalRowArea / rowLongDimension

      # This tracks the current index along the row's long dimension at which
      # to place the next rect
      if (subdivideDirection == "horizontal") {
        rowPlacePointer <- emptyyMin
      } else {
        rowPlacePointer <- emptyxMin
      }

      # This stores the current worst aspect ratio
      aspectRatio <- numeric()

      # Fill the row with the specified number of rects
      for (i in 1:nInRow) {

        # Pop a rect from the stack to place
        thisRect <- treeMapData[stackPointer,]
        stackPointer <- stackPointer + 1

        # Figure out the rect subdivide length
        rectSubdivideLength <- thisRect$area / rowShortDimension

        # Store the coordinates for the rect
        if (subdivideDirection == "horizontal") {
          rectxMin <- emptyxMin
          rectxMax <- emptyxMin + rowShortDimension
          rectyMin <- rowPlacePointer
          rectyMax <- rowPlacePointer + rectSubdivideLength
          rowPlacePointer <- rectyMax # Move up the rect placement pointer
        } else {
          rectxMin <- rowPlacePointer
          rectxMax <- rowPlacePointer + rectSubdivideLength
          rowPlacePointer <- rectxMax # Move up the rect placement pointer
          rectyMin <- emptyyMin
          rectyMax <- emptyyMin + rowShortDimension
        }

        # Store the new rect in the row
        if (missing(label)) {
          newRect <- data.frame(area = thisRect$area,
                                fill = thisRect$fill,
                                xmin = rectxMin,
                                xmax = rectxMax,
                                ymin = rectyMin,
                                ymax = rectyMax)
        } else {
          newRect <- data.frame(area = thisRect$area,
                                fill = thisRect$fill,
                                label = thisRect$label,
                                xmin = rectxMin,
                                xmax = rectxMax,
                                ymin = rectyMin,
                                ymax = rectyMax)
                            }
                            treeMapRow <- rbind(treeMapRow, newRect)

        # Update the aspect ratio if this rect contains the worst one so far
        # in the row
        aspectRatio <- max(c(aspectRatio, rowShortDimension / rectSubdivideLength, rectSubdivideLength/ rowShortDimension))
      }

      # If the aspect ratio is worse than the last number of rects tried, roll
      # back by 1 and consider this row done
      if (aspectRatio > lastAspectRatio) {

        # Roll back the stack pointer
        stackPointer <- stackPointer - 1

        # Add the previous (i.e. best) row to the master output
        treeMap <- rbind(treeMap, previousRow)

        # Recalculate empty space for next round
        if (subdivideDirection == "horizontal") {
          # Empty space in y dimension will not have changed
          # Max in y dimension will not have changed
          emptyxMin <- emptyxMin + previousShortDimension

        } else {
          # Empty space in x dimension will not have changed
          # Max in x dimension will not have changed
          emptyyMin <- emptyyMin + previousShortDimension
        }

        # Don't try adding any more rects to row
        continue <- FALSE

      # If the aspect ratio has improved, roll on
      } else {

        # If there are still rects left to place, prepare for the next round
        if (stackPointer - 1 < nrow(treeMapData)) {

          # Increment the number of rects to try
          nInRow <- nInRow + 1

          # Save the aspect ratio for comparison
          lastAspectRatio <- aspectRatio

          # Save the row and its short dimension (for resizing empty space) in
          # case it turns out to be the best
          previousRow <- treeMapRow
          previousShortDimension <- rowShortDimension

        # If there are no rects left to place, add the row to the master
        # output and exit
        } else {

          treeMap <- rbind(treeMap, treeMapRow)
          continue <- FALSE
        }
      }
    }

    # If this row has resulted in all rects being placed, exit
    if (stackPointer - 1 == nrow(treeMapData)) {
      continue <- FALSE
    } else {
      continue <- TRUE
    }
  }

  # Add the fill name as an attribute - useful for plotting later
  attr(treeMap, "fillName") <- fill

  # Ta-da
  treeMap$area <- NULL
  return(treeMap)
}
