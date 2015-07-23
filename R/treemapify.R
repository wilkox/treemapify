#' @title Generate coordinates for a treemap
#' @export
#' @family treemapify
#'
#' @description
#'
#' Takes a data frame of observations, with variables mapped to area and fill
#' colour, and produces the coordinates for a treemap expressing these
#' observations and mappings.  These coordinates can be used to draw a
#' customised treemap (recommended) or passed directly to the "ggplotify"
#' function to produce an exploratory projection.
#'
#' Input data frame must be in tidy format (see article by Hadley Wickham,
#' below), i.e. each row must represent a single observation and each column a
#' single variable.  The area and fill parameters are mandatory; grouping and
#' label factors are optional.  Note that while adding a label will not change
#' the treemap layout, adding a group will, as observations from the same group
#' will be kept together.
#'
#' Rect placement proceeds from the bottom left corner, alternating between
#' moving rightwards and moving upwards.  See Bruls et al. 1999 for the full
#' algorithm.
#'
#' @param data a tidy data frame, containing at least variables to be mapped to
#' area (size of rect) and fill (fill colour of rect).
#' @param area variable to be mapped to area; must be a column in data
#' @param fill variable to be mapped to fill; must be a column in data
#' @param group (optional) variable to be mapped to group; must be a column in
#' the data frame
#' @param label (optional) variable to be used as the label for each
#' observation; must be a column in the data frame
#' @param xlim,ylim (optional) two-element vectors specifying the x and y
#' limits of the area in which the rects will be placed
#'
#' @references
#' treemapify uses the Squarified Treemap algorithm of Mark Bruls, Kees Huizing
#' and Jarke van Wijk:
#'
#' Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
#' 33-42). Presented at the In Proceedings of the Joint Eurographics and IEEE
#' TCVG Symposium on Visualization.
#'
#' \url{http://www.win.tue.nl/~vanwijk/stm.pdf}
#'
#' "Tidy Data" is described by Hadley Wickham in an unpublished manuscript:
#' \url{http://vita.had.co.nz/papers/tidy-data.pdf}

treemapify <- function(data,
                       area,
                       fill,
                       group = FALSE,
                       label = FALSE,
                       xlim = c(0,100),
                       ylim = c(0,100)
                       ) {

  # Check arguments
  if (missing(data) || is.data.frame(data) == FALSE) {
    stop("Must provide data")
  }
  if (missing(area) || area %in% colnames(data) == FALSE) {
    stop("Must specify an area aesthetic with area=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(fill) || fill %in% colnames(data) == FALSE) {
    stop("Must specify a fill aesthetic with fill=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(group) == FALSE && group %in% colnames(data) == FALSE) {
    stop("If you want a group aesthetic (optional), it must be specified with group=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(group) == FALSE && is.factor(data[[group]]) == FALSE) {
    stop("Group aesthetic must be a factor")
  }
  if (missing(label) == FALSE && label %in% colnames(data) == FALSE) {
    stop("If you want labels (optional), they must be specified with label=\"colname\" (and the column must exist in the data frame)")
  }
  if (missing(label) == FALSE && is.factor(data[[label]]) == FALSE) {
    stop("Label column must be a factor")
  }
  if (is.numeric(xlim) == FALSE || length(xlim) != 2) {
    stop("Invalid xlim (try something like \"xlim=c(0,100)\")")
  }
  if (is.numeric(ylim) == FALSE || length(ylim) != 2) {
    stop("Invalid ylim (try something like \"ylim=c(0,100)\")")
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
    scaleFactor <- plotArea / sum(treeMapData$area)
    treeMapData$area <- scaleFactor * treeMapData$area

    # To get the placement for each group, sum the area and generate a treemap
    # that places each group
    groupData <- ddply(treeMapData, "group", summarise,
                       area = sum(area),
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
  scaleFactor <- plotArea / sum(treeMapData$area)
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
      totalRowArea <- sum(treeMapData$area[stackPointer:(stackPointer + nInRow - 1)])

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
