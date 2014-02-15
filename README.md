#Note to anybody stumbling across this repo

This README is a work in progress. The code pretty much works though. Go ahead and try it out.

#TODO
- Finish walkthrough (need better example data)
- Credit squarify paper
- Full description of function options
- Thin lines between rects

---

Treemapify makes it easier to draw treemaps with R and ggplot2.

---

#Walkthrough

##Installing dependancies, sourcing treemapify

- Install ggplot2, plyr and devtools if you don't have them already.

```R
> install.packages("ggplot2")
> install.packages("plyr")
> install.packages("devtools")
```

- Source the treemapify functions.

```R
> library(devtools)
> source_url("https://raw.github.com/wilkox/treemapify/master/treemapify.R")
```

##Some example data

For any treemap, you'll need a data frame containing at least the following columns:
  - A numeric column, which will determine the area of each treemap rectangle; and
  - Another numeric column, which will determine the fill colour of each treemap rectangle.

For this example, we'll also use a couple of optional columns:
  - A factor column, containing the labels for each rectangle; and
  - A factor column, containg group names to group the rectangles.

Let's plot some economic data for the G-20 group of nations.

```R
> source_url("https://raw.github.com/wilkox/treemapify/master/examples/G20.R")
> G20
	Region         Country Trade.mil.USD Nom.GDP.mil.USD PPP.GDP.mil.USD
1         Africa    South Africa        208000          384315          582391
2  North America   United States       3969000        15684750        15684750
3  North America          Canada        962600         1819081         1488311
4  North America          Mexico        756800         1177116         1758896
5  South America          Brazil        494800         2395968         2355586
6  South America       Argentina        152690          474954          743121
7           Asia           China       3801000         8227037        12405670
8           Asia           Japan       1649800         5963969         4627891
9           Asia     South Korea       1068700         1155872         1613921
10          Asia           India        809400         1824832         4684372
11          Asia       Indonesia        384100          878198         1216738
12       Eurasia          Russia        900600         2021960         2513299
13       Eurasia          Turkey        370800          794468         1123380
14        Europe         Germany       2768000         3400579         3197069
15        Europe          France       1226400         2608699         2254067
16        Europe  United Kingdom       1127000         2440505         2336295
17        Europe           Italy        953000         2014079         1832916
18   Middle East    Saudi Arabia        518300          727307          906806
19       Oceania       Australia        522000         1541797          970764
Nom.GDP.per.capita.USD PPP.GDP.per.capita.USD   HDI Population
1                    7506                  11375 0.629   53000000
2                   49922                  49922 0.937  316173000
3                   52231                  42734 0.911   34088000
4                   10247                  15311 0.775  112211789
5                   12078                  11875 0.730  201032714
6                   11576                  18112 0.811   40117096
7                    6075                   9161 0.699 1339724852
8                   46735                  36265 0.912  127390000
9                   23112                  32272 0.909   50004441
10                   1491                   3829 0.554 1210193422
11                   3592                   4977 0.629  237556363
12                  14246                  17708 0.788  143400000
13                  10609                  15001 0.722   72561312
14                  41512                  39028 0.920   81757600
15                  41140                  35547 0.893   65447374
16                  38588                  36941 0.875   62041708
17                  33115                  30136 0.881   60325805
18                  25084                  31275 0.782   27123977
19                  67722                  42640 0.938   22328632
Economic.classification
1               Developing
2                 Advanced
3                 Advanced
4               Developing
5               Developing
6               Developing
7               Developing
8                 Advanced
9                 Advanced
10              Developing
11              Developing
12              Developing
13              Developing
14                Advanced
15                Advanced
16                Advanced
17                Advanced
18              Developing
19                Advanced

```

(The perceptive reader will note there are only 19 rows in the data frame --- we've excluded the EU as it's not really a country.)

##The `treemapify` function

The `treemapify` function takes a data frame and generates coordinates for a treemap where each observation is represented by a rectangle. In this example, each observation is a country; the rectangle's area will be mapped to the country's nominal GDP, while the fill colour will be mapped to the Human Development Index (HDI). We'll also group the countries by region.

```R
> treeMapCoordinates <- treemapify(G20, area="Nom.GDP.mil.USD", fill="HDI", label="Country", group="Region")>
> treeMapCoordinates
	fill           label     xmin      xmax     ymin      ymax         group
1  0.937   United States  0.00000  55.53147  0.00000  50.85900 North America
2  0.911          Canada 55.53147  66.13943  0.00000  30.87803 North America
3  0.775          Mexico 55.53147  66.13943 30.87803  50.85900 North America
4  0.699           China  0.00000  30.14595 50.85900 100.00000          Asia
5  0.912           Japan 30.14595  66.13943 50.85900  80.69502          Asia
6  0.554           India 30.14595  47.16687 80.69502 100.00000          Asia
7  0.909     South Korea 47.16687  66.13943 80.69502  91.66519          Asia
8  0.629       Indonesia 47.16687  66.13943 91.66519 100.00000          Asia
9  0.920         Germany 66.13943 100.00000  0.00000  18.08373        Europe
10 0.893          France 66.13943  83.63368 18.08373  44.93459        Europe
11 0.875  United Kingdom 83.63368 100.00000 18.08373  44.93459        Europe
12 0.881           Italy 66.13943 100.00000 44.93459  55.64513        Europe
13 0.730          Brazil 66.13943  83.23194 55.64513  80.88603 South America
14 0.811       Argentina 66.13943  83.23194 80.88603  85.88954 South America
15 0.788          Russia 83.23194 100.00000 55.64513  77.35809       Eurasia
16 0.722          Turkey 83.23194 100.00000 77.35809  85.88954       Eurasia
17 0.938       Australia 66.13943  85.81447 85.88954 100.00000       Oceania
18 0.782    Saudi Arabia 85.81447  95.09571 85.88954 100.00000   Middle East
19 0.629    South Africa 95.09571 100.00000 85.88954 100.00000        Africa
```

The "xmin", "xmax", "ymin" and "ymax" columns give the boundaries of each rectangle. Note that the funciont has also provided coordinates and sizes for text labels for each observation.

For publication-quality graphics, it's recommended that you stop at this point and use the coordinates provided to draw your own plot with custom parameters. For quick-and-dirty exploratory graphics, however, treemapify provides an additional function to draw the treemap with ggplot2.

##The `ggplotify` function

As the name suggests, this function takes a data frame of treemap coordinates produced by `treemapify` and produces a ggplot object containing a graphical layout of the treemap.

```R
> treeMapPlot <- ggplotify(treeMapCoordinates)
> print(treeMapPlot)
```

![Treemap of midwest data, produced with ggplotify](examples/midwest.png)


#G20 Data
The G20 dataset is from the Wikipedia article [G-20 major economies](http://en.wikipedia.org/wiki/G-20_major_economies), which is released under the [Creative Commons Attribution-Share-Alike License 3.0](Creative Commons Attribution-Share-Alike License 3.0).
