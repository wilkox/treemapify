#Introduction

Treemapify provides two R functions to help you make treemaps quickly and easy, especially when using ggplot2.

#Walkthrough

##Load packages and the treemapify functions

- Install ggplot2, plyr and devtools if you don't have them already.

```R
install.packages("ggplot2")
install.packages("plyr")
install.packages("devtools")
```

- Source the treemapify functions.

```R
library(devtools)
source_url("https://raw.github.com/wilkox/treemapify/master/treemapify.R")
```

##Your data

You'll need a data frame containing at least the following columns:
  - A numeric column, which will determine the area of each treemap rectangle; and
  - Another numeric column, which will determine the fill colour of each treemap rectangle.

For the purposes of this example, we'll use a couple of optional columns too:
  - A factor column, containing the labels for each rectangle; and
  - A factor column, containg group names to group the rectangles.

Here's some example data (a subset of the "midwest" dataset provided by ggplot2):

```R
> midwestData <- midwest[c("county", "state", "area", "popdensity")][seq(1, 437, 30), ]
> midwestData
county state  area popdensity
1         ADAMS    IL 0.052  1270.9615
31       GREENE    IL 0.033   464.1515
61       MARION    IL 0.035  1187.4571
91        UNION    IL 0.024   734.1250
121      DUBOIS    IN 0.026  1408.3077
151      MARION    IN 0.023 34659.0870
181  TIPPECANOE    IN 0.030  4353.2667
211    CHIPPEWA    MI 0.078   443.6410
241  LIVINGSTON    MI 0.034  3401.3235
271 SCHOOLCRAFT    MI 0.075   110.6933
301     FAYETTE    OH 0.024  1144.4167
331      MERCER    OH 0.028  1408.6786
361  WASHINGTON    OH 0.038  1638.2632
391        IRON    WI 0.047   130.9149
421    ST CROIX    WI 0.044  1142.0682
```


##TODO
- Credit squarify paper
- Full description of function options
