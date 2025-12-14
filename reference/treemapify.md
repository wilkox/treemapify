# Generate a treemap layout.

`treemapify()` returns a data frame of tile coordinates for a treemap
layout of a set of observations. This is only useful if you wish to draw
the treemap without the help of the `ggplot2` geoms, or for some edge
cases such as creating interactive treemaps with 'R Shiny' (see e.g.
<https://stackoverflow.com/q/45021775>). The easiest way to draw a
treemap with the 'treemapify' package is to use the provided 'ggplot2'
geoms, such as
[`geom_treemap()`](https://wilkox.org/treemapify/reference/geom_treemap.md).

`data` must be a tidy data frame, i.e. each row must represent a single
observation and each column a single variable. You must provide the name
of the variable that will be represented by the area of each treemap
tile with `area`. Optionally, you can also select up to three variables
(with `subgroup`, `subgroup2` and `subgroup3`) to generate a layout in
which the tiles are clustered into subgroups nested up to three levels
deep.

Four layout algorithms are provided. With the default 'squarified'
algorithm (`layout = "squarified"`), the priority is ensuring the tiles
have an aesthetically pleasing aspect ratio; that is, they are not too
narrow or too short. In this algorithm, tile placement proceeds from one
corner, placing the tiles in either rows or columns until all the tiles
are placed. See Bruls et al. (1999) for the full algorithm.

There are two variants on the 'squarified' algorithm. 'scol' forces tile
placement to begin with a column, regardless of the effect on aspect
ratio; 'srow' forces tile placement to been with a row. This will also
apply to all subgroups. After the first row or column, the remaining
tiles will be placed so as to optimise aspect ratios, as with the
default algorithm.

With the 'fixed' layout algorithm (`layout = "fixed"`), the plot area is
divided into vertical columns, which are each filled with an equal
number of tiles beginning at the starting corner. Unlike the
'squarified' algorithm, with the 'fixed' algorithm the relative
positions of the tiles are fixed by their order in the input data frame.
This can result in aesthetically unpleasing layouts, but it allows
side-by-side comparisons or animations to be created.

`treemapify_fixed` is an alias for `treemapify(layout = "fixed")`.

## Usage

``` r
treemapify(
  data,
  area,
  subgroup,
  subgroup2,
  subgroup3,
  layout = "squarified",
  start = "bottomleft",
  fill = NULL,
  label = NULL,
  group = NULL,
  fixed = NULL,
  xlim = c(0, 1),
  ylim = c(0, 1)
)

treemapify_fixed(...)
```

## Arguments

- data:

  A tidy data frame.

- area:

  Name of the variable (a column in `data`) to be mapped to the area of
  treemap tiles.

- subgroup, subgroup2, subgroup3:

  Optionally, names of variables (columns in `data`) by which the tiles
  should be grouped, at up to three nested levels.

- layout:

  The layout algorithm, one of either 'squarified' (the default),
  'scol', 'srow' or 'fixed'. See Details for full details on the
  different layout algorithms.

- start:

  The corner in which to start placing the tiles. One of 'bottomleft'
  (the default), 'topleft', 'topright' or 'bottomright'.

- label, fill:

  Deprecated. Will be removed in later versions.

- group:

  Deprecated. Use `subgroup` instead. Will be removed in later versions.

- fixed:

  Deprecated. Use `layout = "fixed"` instead. Will be removed in later
  versions.

- xlim, ylim:

  The boundaries of the treemap in the x and y dimensions. Must be a
  numeric vector of length two; both default to `c(0, 1)`.

- ...:

  Additional arguments to be passed to `treemapify()`.

## Details

`treemapify` is for generating a data frame of raw treemap coordinates.
If you want to draw a treemap with 'ggplot2', use
[`geom_treemap()`](https://wilkox.org/treemapify/reference/geom_treemap.md)
instead.

## References

Bruls, M., Huizing, K., & van Wijk, J. (1999). Squarified Treemaps (pp.
33-42).Proceedings of the Joint Eurographics and IEEE TCVG Symposium on
Visualization. <https://www.win.tue.nl/~vanwijk/stm.pdf>

## See also

[`geom_treemap()`](https://wilkox.org/treemapify/reference/geom_treemap.md)

## Examples

``` r
treemapify(G20, area = "gdp_mil_usd")
#>           region        country   hdi econ_classification hemisphere      ymax
#> 14        Europe European Union 0.876            Advanced   Northern 0.5113668
#> 2  North America  United States 0.937            Advanced   Northern 1.0000000
#> 7           Asia          China 0.699          Developing   Northern 0.3561040
#> 8           Asia          Japan 0.912            Advanced   Northern 0.3561040
#> 15        Europe        Germany 0.920            Advanced   Northern 0.5681398
#> 16        Europe         France 0.893            Advanced   Northern 0.5681398
#> 17        Europe United Kingdom 0.875            Advanced   Northern 0.5681398
#> 5  South America         Brazil 0.730          Developing   Southern 0.7290108
#> 12       Eurasia         Russia 0.788          Developing   Northern 0.8647700
#> 18        Europe          Italy 0.881            Advanced   Northern 1.0000000
#> 10          Asia          India 0.554          Developing   Northern 0.7141474
#> 3  North America         Canada 0.911            Advanced   Northern 0.7141474
#> 20       Oceania      Australia 0.938            Advanced   Southern 0.8762440
#> 4  North America         Mexico 0.775          Developing   Northern 1.0000000
#> 9           Asia    South Korea 0.909            Advanced   Northern 0.8458414
#> 11          Asia      Indonesia 0.629          Developing   Southern 0.8458414
#> 13       Eurasia         Turkey 0.722          Developing   Northern 0.9263225
#> 19   Middle East   Saudi Arabia 0.782          Developing   Northern 1.0000000
#> 6  South America      Argentina 0.811          Developing   Southern 0.9310513
#> 1         Africa   South Africa 0.629          Developing   Southern 1.0000000
#>         ymin      xmin      xmax gdp_mil_usd
#> 14 0.0000000 0.0000000 0.4461327    16414483
#> 2  0.5113668 0.0000000 0.4461327    15684750
#> 7  0.0000000 0.4461327 0.7672295     8227037
#> 8  0.0000000 0.7672295 1.0000000     5963969
#> 15 0.3561040 0.4461327 0.6690342     3400579
#> 16 0.3561040 0.6690342 0.8400295     2608699
#> 17 0.3561040 0.8400295 1.0000000     2440505
#> 5  0.5681398 0.4461327 0.6531338     2395968
#> 12 0.7290108 0.4461327 0.6531338     2021960
#> 18 0.8647700 0.4461327 0.6531338     2014079
#> 10 0.5681398 0.6531338 0.8268406     1824832
#> 3  0.5681398 0.8268406 1.0000000     1819081
#> 20 0.7141474 0.6531338 0.7853311     1541797
#> 4  0.8762440 0.6531338 0.7853311     1177116
#> 9  0.7141474 0.7853311 0.9073179     1155872
#> 11 0.7141474 0.9073179 1.0000000      878198
#> 13 0.8458414 0.7853311 0.9225305      794468
#> 19 0.9263225 0.7853311 0.9225305      727307
#> 6  0.8458414 0.9225305 1.0000000      474954
#> 1  0.9310513 0.9225305 1.0000000      384315
```
