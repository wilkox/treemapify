#load ggplot2
library(ggplot2)

#work with a subset of the midwest data set
testData <- midwest[c("county","area","percollege")][1:20,]

#rename "area: to "landarea" to prevent confusion
names(testData) <- c("county", "landarea", "percollege")

#make a sorted list by area
testData <- testData[with(testData, order(-landarea)), ]

#scale areas to sum to 10,000 (i.e. 100 x 100)
scaleFactor <- 10000 / sum(testData$landarea)
testData$landarea <- scaleFactor * testData$landarea

#this is the "master" output data frame, holding the locations of all the treemap rects
treeMap <- data.frame(county=factor(), landarea=numeric(), percollege=numeric(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())

#these variables track the empty space remaining in the tree map
emptyxMin <- 0
emptyxMax <- 100
emptyyMin <- 0
emptyyMax <- 100

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
    treeMapRow <- data.frame(county=factor(), landarea=numeric(), percollege=numeric(), xmin=numeric(), xmax=numeric(), ymin=numeric(), ymax=numeric())

    #reset the stack pointer to the start of this row
    stackPointer <- stackPointerRow

    #get the total area that will be filled by this row
    totalRowArea <- sum(testData$landarea[stackPointer:(stackPointer + nInRow - 1)])

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
      thisRect <- testData[stackPointer,]
      stackPointer <- stackPointer + 1

      #figure out the rect subdivide length
      rectSubdivideLength <- thisRect$landarea / rowShortDimension
      
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
      newRect <- data.frame(county=thisRect$county, landarea=thisRect$landarea, percollege=thisRect$percollege, xmin=rectxMin, xmax=rectxMax, ymin=rectyMin, ymax=rectyMax)
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

      #TODO
      print(previousRow)
      print("New empty dimensions")
      print(c("emptyxMin", emptyxMin))
      print(c("emptyxMax", emptyxMax))
      print(c("emptyyMin", emptyyMin))
      print(c("emptyyMax", emptyyMax))

      #don't try adding any more rects to row
      continue <- FALSE

    #if the aspect ratio has improved, roll on
    } else {

      #if there are still rects left to place, prepare for the next round
      if (stackPointer - 1 < nrow(testData)) {

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

        #TODO
        print(treeMapRow)
        treeMap <- rbind(treeMap, treeMapRow)
        continue <- FALSE
      }
    }
  }

  #if this row has resulted in all rects being placed, exit
  if (stackPointer - 1 == nrow(testData)) {
    continue <- FALSE
  } else {
    continue <- TRUE
  }
}

#set up the 100 by 100 plot area
p <- ggplot(treeMap)
p <- p + coord_cartesian(xlim = c(0, 100), ylim = c(0,100)) 
p <- p + geom_rect(aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=county))
