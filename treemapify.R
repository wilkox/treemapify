#load ggplot2
library(ggplot2)
library(plyr)

#the treemapify function
treemapify <- function(dataFrame, area=NULL, fill=NULL, group=FALSE, label=FALSE, xlim=c(0,100), ylim=c(0,100)) {

  #check the arguments
  if (missing(dataFrame) || is.data.frame(dataFrame) == FALSE) {
    stop("Must provide a data frame")
  }
  if (missing(area) || area %in% colnames(dataFrame) == FALSE) {
    stop("Must specify an area aesthetic with area=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(fill) || fill %in% colnames(dataFrame) == FALSE) {
    stop("Must specify a fill aesthetic with fill=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(group) == FALSE && group %in% colnames(dataFrame) == FALSE) {
    stop("If you want a group aesthetic (optional), it must be specified with group=\"colname\" (and it must exist in the data frame)")
  }
  if (missing(group) == FALSE && is.factor(dataFrame[[group]]) == FALSE) {
    stop("Group aesthetic must be a factor")
  }
  if (missing(label) == FALSE && label %in% colnames(dataFrame) == FALSE) {
    stop("If you want labels (optional), they must be specified with label=\"colname\" (and the column must exist in the data frame)")
  }
  if (missing(label) == FALSE && is.factor(dataFrame[[label]]) == FALSE) {
    stop("Label column must be a factor")
  }
  if (is.numeric(xlim) == FALSE || length(xlim) != 2) {
    stop("Invalid xlim (try something like \"xlim=c(0,100)\")")
  }
  if (is.numeric(ylim) == FALSE || length(ylim) != 2) {
    stop("Invalid ylim (try something like \"ylim=c(0,100)\")")
  }

  #handle groups, if so requested
  if (missing(group) == FALSE) {

    #build the treeMapData data frame
    if (missing(label)) {
      treeMapData <- data.frame(area=dataFrame[area], fill=dataFrame[fill], group=dataFrame[group])
      names(treeMapData) <- c("area", "fill", "group")
    } else {
      treeMapData <- data.frame(area=dataFrame[area], fill=dataFrame[fill], group=dataFrame[group], label=dataFrame[label])
      names(treeMapData) <- c("area", "fill", "group", "label")
    }

    #scale areas to sum to total plot area
    plotArea <- prod(diff(xlim), diff(ylim))
    scaleFactor <- plotArea / sum(treeMapData$area)
    treeMapData$area <- scaleFactor * treeMapData$area

    #to get the placement for each group, sum the area
    # and generate a treemap that places each group
    groupData <- ddply(treeMapData, "group", summarise, 
      area = sum(area),
      fill = group[1]
    )
    groupTreeMap <- treemapify(groupData, area="area", fill="fill", xlim=xlim, ylim=ylim)

    #build the output data frame
    if (missing(label)) {
      treeMap <- data.frame(area=numeric(), fill=factor(), group=factor(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
    } else {
      treeMap <- data.frame(area=numeric(), fill=factor(), group=factor(), label=character(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
    }

    #for each group, generate a treemap within the area allocated for the group
    for (thisGroup in groupTreeMap[["fill"]]) {
      xmin <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["xmin"])
      xmax <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["xmax"])
      ymin <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["ymin"])
      ymax <- as.numeric(groupTreeMap[groupTreeMap[,"fill"] == thisGroup,]["ymax"])
      thisGroupData <- treeMapData[treeMapData[,"group"] == thisGroup,]
      if (missing(label)) {
        thisGroupRects <- treemapify(thisGroupData, fill="fill", area="area", xlim=c(xmin, xmax), ylim=c(ymin, ymax))
      } else {
        thisGroupRects <- treemapify(thisGroupData, fill="fill", area="area", label="label", xlim=c(xmin, xmax), ylim=c(ymin, ymax))
      }
      thisGroupRects["group"] <- thisGroup
      treeMap <- rbind(treeMap, thisGroupRects)
    }

    #add the fill name as an attribute - useful for plotting later
    attr(treeMap, "fillName") <- fill

    #return the grouped treemap
    return(treeMap)
  }

  #build the treeMapData data frame
  if (missing(label)) {
    treeMapData <- data.frame(area=dataFrame[area], fill=dataFrame[fill])
    names(treeMapData) <- c("area", "fill")
  } else {
    treeMapData <- data.frame(area=dataFrame[area], fill=dataFrame[fill], label=dataFrame[label])
    names(treeMapData) <- c("area", "fill", "label")
  }

  #sorted by area, largest to smallest
  treeMapData <- treeMapData[with(treeMapData, order(-area)), ]

  #scale areas to sum to total plot area
  plotArea <- prod(diff(xlim), diff(ylim))
  scaleFactor <- plotArea / sum(treeMapData$area)
  treeMapData$area <- scaleFactor * treeMapData$area

  #this is the "master" output data frame, holding the locations of all the treemap rects
  if (missing(label)) {
    treeMap <- data.frame(area=numeric(), fill=factor(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
  } else {
    treeMap <- data.frame(area=numeric(), fill=factor(), label=character(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
  }

  #these variables track the empty space remaining in the tree map
  emptyxMin <- xlim[1]
  emptyxMax <- xlim[2]
  emptyyMin <- ylim[1]
  emptyyMax <- ylim[2]

  #this tells us the row number of the top unplaced rect
  stackPointer <- 1

  #keep making new rows until all rects are placed
  continue <- TRUE
  while (continue) {

    #this tracks how many rects are currently being tested in the row - initialise with 1
    nInRow <- 1

    #determine subdivide direction for the row
    emptyx <- emptyxMax - emptyxMin
    emptyy <- emptyyMax - emptyyMin
    if (emptyx > emptyy) {
      subdivideDirection <- "horizontal"
    } else if (emptyx < emptyy) {
      subdivideDirection <- "vertical"
    } else if (emptyx == emptyy) {
      subdivideDirection <- "horizontal"
      
    }

    #get the long dimension for the row
    if (subdivideDirection == "horizontal") {
      rowLongDimension = emptyyMax - emptyyMin
    } else {
      rowLongDimension = emptyxMax - emptyxMin
    }

    #this holds the aspect ratio for the last number-of-rects-in-row tried
    #initialise with infinity so first row isn't rejected
    lastAspectRatio <- Inf

    #this stores the stack pointer for the start of this row
    stackPointerRow <- stackPointer

    #try increasing numbers of rects in the row, until the best-ish
    # solution is found
    while (continue) {

      #initialise a trial row
      if (missing(label)) {
        treeMapRow <- data.frame(area=numeric(), fill=factor(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
      } else {
        treeMapRow <- data.frame(area=numeric(), fill=factor(), label=character(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())
      }

      #reset the stack pointer to the start of this row
      stackPointer <- stackPointerRow

      #get the total area that will be filled by this row
      totalRowArea <- sum(treeMapData$area[stackPointer:(stackPointer + nInRow - 1)])

      #get the short dimension for the row
      rowShortDimension <- totalRowArea / rowLongDimension

      #this tracks the current index along the row's long dimension at which to place
      # the next rect
      if (subdivideDirection == "horizontal") {
        rowPlacePointer <- emptyyMin
      } else {
        rowPlacePointer <- emptyxMin
      }

      #this stores the current worst aspect ratio
      aspectRatio <- numeric()

      #fill the row with the specified number of rects
      for (i in 1:nInRow) {

        #pop a rect from the stack to place
        thisRect <- treeMapData[stackPointer,]
        stackPointer <- stackPointer + 1

        #figure out the rect subdivide length
        rectSubdivideLength <- thisRect$area / rowShortDimension
        
        #store the coordinates for the rect
        if (subdivideDirection == "horizontal") {
          rectxMin <- emptyxMin
          rectxMax <- emptyxMin + rowShortDimension
          rectyMin <- rowPlacePointer
          rectyMax <- rowPlacePointer + rectSubdivideLength
          rowPlacePointer <- rectyMax #move up the rect placement pointer
        } else {
          rectxMin <- rowPlacePointer
          rectxMax <- rowPlacePointer + rectSubdivideLength
          rowPlacePointer <- rectxMax #move up the rect placement pointer
          rectyMin <- emptyyMin
          rectyMax <- emptyyMin + rowShortDimension
        }

        #store the new rect in the row
        if (missing(label)) {
          newRect <- data.frame(area=thisRect$area, fill=thisRect$fill, xmin=rectxMin, xmax=rectxMax, ymin=rectyMin, ymax=rectyMax)
        } else {
          newRect <- data.frame(area=thisRect$area, fill=thisRect$fill, label=thisRect$label, xmin=rectxMin, xmax=rectxMax, ymin=rectyMin, ymax=rectyMax)
        }
        treeMapRow <- rbind(treeMapRow, newRect)

        #update the aspect ratio if this rect contains the worst one so far in the row
        aspectRatio <- max(c(aspectRatio, rowShortDimension / rectSubdivideLength, rectSubdivideLength/ rowShortDimension))
      }

      #if the aspect ratio is worse than the last number of rects tried,
      # roll back by 1 and consider this row done
      if (aspectRatio > lastAspectRatio) {

        #roll back the stack pointer
        stackPointer <- stackPointer - 1

        #add the previous (i.e. best) row to the master output
        treeMap <- rbind(treeMap, previousRow)

        #recalculate empty space for next round
        if (subdivideDirection == "horizontal") {
          #empty space in y dimension will not have changed
          emptyxMin <- emptyxMin + previousShortDimension
          #max in y dimension will not have changed
        } else {
          #empty space in x dimension will not have changed
          emptyyMin <- emptyyMin + previousShortDimension
          #max in x dimension will not have changed
        }

        #don't try adding any more rects to row
        continue <- FALSE

      #if the aspect ratio has improved, roll on
      } else {

        #if there are still rects left to place, prepare for the next round
        if (stackPointer - 1 < nrow(treeMapData)) {

          #increment the number of rects to try
          nInRow <- nInRow + 1

          #save the aspect ratio for comparison
          lastAspectRatio <- aspectRatio

          #save the row and its short dimension (for resizing empty space)
          # in case it turns out to be the best
          previousRow <- treeMapRow
          previousShortDimension <- rowShortDimension

        #if there are no rects less to place, add the row to the master output and exit
        } else {

          treeMap <- rbind(treeMap, treeMapRow)
          continue <- FALSE
        }
      }
    }

    #if this row has resulted in all rects being placed, exit
    if (stackPointer - 1 == nrow(treeMapData)) {
      continue <- FALSE
    } else {
      continue <- TRUE
    }
  }

  #place labels, if asked to
  if (missing(label) == FALSE) {

    #add label aesthetic columns
    treeMap["labelx"] <- NA
    treeMap["labely"] <- NA
    treeMap["labelsize"] <- NA

    #select an appropriate size
    treeMap <- ddply(treeMap, "label", mutate,

      #place in top left
      labelx = xmin + 1,
      labely = ymax - 1,

      labelsize = (1.5 * (xmax - xmin)) / nchar(as.character(label)),
    )
  }

  #add the fill name as an attribute - useful for plotting later
  attr(treeMap, "fillName") <- fill
  
  #ta-da
  return(treeMap)
}

#the ggplotify function
ggplotify <- function(treeMap, label.groups=TRUE) {

  #check the arguments
  if (missing(treeMap) || is.data.frame(treeMap) == FALSE) {
    stop("Must provide a data frame")
  }

  xlim <- c(min(treeMap["xmin"]), max(treeMap["xmax"]))
  ylim <- c(min(treeMap["ymin"]), max(treeMap["ymax"]))

  p <- ggplot(treeMap)
  p <- p + coord_cartesian(xlim = xlim, ylim = ylim) 
  p <- p + geom_rect(aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=fill))
  p <- p + theme(axis.ticks = element_blank(), axis.title = element_blank(), axis.text=element_blank())
  p <- p + guides(fill=guide_legend(title=attributes(treeMap)$fillName))

  #if the rects are grouped, add a nice border around each group
  if ("group" %in% colnames(treeMap)) {
  
    groupRects <- ddply(treeMap, c("group"), summarise, 
      xmin <- min(xmin),
      xmax <- max(xmax),
      ymin <- min(ymin),
      ymax <- max(ymax)
    )
    names(groupRects) <- c("group", "xmin", "xmax", "ymin", "ymax")
    p <- p + geom_rect(data=groupRects, mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), colour="grey", fill=NA, size=1.2) + theme(panel.border = element_rect(size=2, fill=NA, colour="grey"))
  }

  #optionally add group labels
  if (label.groups == TRUE && "group" %in% colnames(treeMap)) {

    if ("label" %in% colnames(treeMap)) {
      groupLabels <- ddply(treeMap, c("group"), summarise, 
        x <- max(xmax) - ((max(xmax) - min(xmin)) * 0.5),
        y <- min(ymin) + 1,
        size <- (max(xmax) - min(xmin)) / nchar(as.character(group[1]))
      )
    } else {
      groupLabels <- ddply(treeMap, c("group"), summarise, 
        x <- max(xmax) - ((max(xmax) - min(xmin)) * 0.5),
        y <- max(ymax) - ((max(ymax) - min(ymin)) * 0.5),
        size <- (max(xmax) - min(xmin)) / (nchar(as.character(group[1])))
      )
    }
    names(groupLabels) <- c("group", "x", "y", "size")
    p <- p + annotate("text", x=groupLabels$x, y=groupLabels$y, label=groupLabels$group, size=groupLabels$size, colour="darkgrey", fontface="bold", hjust=0.5, vjust=0)
    
  }

  #optionally add labels
  if ("label" %in% colnames(treeMap)) {
    p <- p + geom_text(aes(label=label, x=labelx, y=labely), hjust=0, vjust=1, colour="white", size=min(treeMap$labelsize))
  }

  return(p)
}
