#the ggplotify function
ggplotify <- function(treeMap, label.groups=TRUE) {

    #Libraries
    require(ggplot2)
    require(plyr)
    require(reshape2)

  #check the arguments
  if (missing(treeMap) || is.data.frame(treeMap) == FALSE) {
    stop("Must provide a data frame")
  }

  xlim <- c(min(treeMap["xmin"]), max(treeMap["xmax"]))
  ylim <- c(min(treeMap["ymin"]), max(treeMap["ymax"]))

  p <- ggplot(treeMap)
  p <- p + coord_cartesian(xlim = xlim, ylim = ylim) 
  p <- p + geom_rect(aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax, fill=fill))
  p <- p + geom_rect(aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), fill=NA, colour="grey", size=0.2)
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
    p <- p + geom_rect(data=groupRects, mapping=aes(xmin=xmin, xmax=xmax, ymin=ymin, ymax=ymax), colour="grey", fill=NA, size=1.2) 
    p <- p + theme(panel.border = element_rect(size=2, fill=NA, colour="grey"))
  }

  #optionally add group labels
  if (label.groups == TRUE && "group" %in% colnames(treeMap)) {

    if ("label" %in% colnames(treeMap)) {
      groupLabels <- ddply(treeMap, c("group"), summarise, 
        x <- max(xmax) - ((max(xmax) - min(xmin)) * 0.5),
        y <- min(ymin) + 2,
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

    #add label aesthetic columns
    treeMap["labelx"] <- NA
    treeMap["labely"] <- NA
    treeMap["labelsize"] <- NA

    #select an appropriate size
    treeMap <- ddply(treeMap, "label", mutate,

      #place in top left
      labelx = xmin + 1,
      labely = ymax - 1,

      labelsize = (xmax - xmin) / (nchar(as.character(label))),
    )
    treeMap

    p <- p + geom_text(data=treeMap, aes(label=label, x=labelx, y=labely, size=labelsize), hjust=0, vjust=1, colour="white") + scale_size(range=c(1,8), guide=FALSE)
  }

  return(p)
}
