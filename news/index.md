# Changelog

## treemapify (development version)

## treemapify 2.6.0

CRAN release: 2025-12-14

### Major changes

- Add support for ggplot2 3.5 patterns and gradients (see
  <https://www.tidyverse.org/blog/2024/02/ggplot2-3-5-0/#patterns-and-gradients>;
  [\#50](https://github.com/wilkox/treemapify/issues/50), thanks
  [@trevorld](https://github.com/trevorld))

### Minor changes

- Change default roundrect radius in GeomTreemap to 0 pts
  ([\#48](https://github.com/wilkox/treemapify/issues/48), thanks
  [@davidhodge931](https://github.com/davidhodge931))
- Export GeomTreemap and GeomTreemapText
  ([\#48](https://github.com/wilkox/treemapify/issues/48), thanks
  [@davidhodge931](https://github.com/davidhodge931))
- treemapify() includes the area column in its output
  ([\#49](https://github.com/wilkox/treemapify/issues/49), thanks
  [@davidhodge931](https://github.com/davidhodge931))

## treemapify 2.5.6

CRAN release: 2023-09-30

### Minor changes

- Replace `i:j` with [`seq_along()`](https://rdrr.io/r/base/seq.html) or
  similar
- Update testing and continuous integration infrastructure
- Small documentation updates
- Use the cli package for errors and warnings

### Bug fixes

- Fix colour aesthetic in key for `geom_tremap()`
  ([\#47](https://github.com/wilkox/treemapify/issues/47), thanks
  [@jjbuonocore](https://github.com/jjbuonocore))

## treemapify 2.5.5

CRAN release: 2021-01-08

### Bug fixes

- Make vdiffr tests conditional
- Fix use of [`order()`](https://rdrr.io/r/base/order.html) on a data
  frame

## treemapify 2.5.4

CRAN release: 2020-11-19

### Major changes

- Increase R minimum version requirement to 3.6

### Bug fixes

- Variants on `place = "centre"` (“middle” and “center”) are now handled
  correctly

## treemapify 2.5.3

CRAN release: 2019-01-30

### Bug fixes

- Fix issue with correct drawing of aesthetics in
  `geom_tremap_subgroup*_text()`
  ([\#32](https://github.com/wilkox/treemapify/issues/32), thanks
  [@jonathan-g](https://github.com/jonathan-g)).

## treemapify 2.5.2

CRAN release: 2018-10-13

### Bug fixes

- Fix issue with importing ggfittext.

## treemapify 2.5.1

CRAN release: 2018-10-06

### Major changes

- Added new `layout` and `start` arguments to
  [`treemapify()`](https://wilkox.org/treemapify/reference/treemapify.md)
  and all geoms.

### Minor changes

- Restore `xlim` and `ylim` options to
  [`treemapify()`](https://wilkox.org/treemapify/reference/treemapify.md).
- Add and improve tests.
- Misc. code quality improvements.

### Bug fixes

- Fixed bug in handling of subgroups, which should result in more
  aesthetically pleasing layouts.
- Fix dereferencing of arguments in
  [`treemapify()`](https://wilkox.org/treemapify/reference/treemapify.md)
  ([\#22](https://github.com/wilkox/treemapify/issues/22), thanks
  [@GregorDeCillia](https://github.com/GregorDeCillia)).
- Fix deprecation of `fill`, `label` and `group` arguments in
  [`treemapify()`](https://wilkox.org/treemapify/reference/treemapify.md)
  to maintain backwards compatibility (thanks
  [@GregorDeCillia](https://github.com/GregorDeCillia)).

## treemapify 2.5.0

CRAN release: 2018-04-30

### Major changes

- Refactor treemap layout algorithms.
- Add support for nested subgroups with new `subgroup2` and `subgroup3`
  aesthetics, and `geom_treemap_subgroup2_border`,
  `geom_treemap_subgroup3_border`, `geom_treemap_subgroup2_text`, and
  `geom_treemap_subgroup3_text` geoms.

### Minor changes

- Add ‘hemisphere’ column to G20 data.

### Bug fixes

- Fix typo in README
  ([\#19](https://github.com/wilkox/treemapify/issues/19), thanks
  [@mruessler](https://github.com/mruessler)).

## treemapify 2.4.0

CRAN release: 2017-11-18

### Minor changes

- Change R and grid dependencies to 3.1.
- Remove reshape2 dependency.

### Bug fixes

- Fix handling of data where some observations have area 0
  ([\#17](https://github.com/wilkox/treemapify/issues/17), thanks
  [@py](https://github.com/py)).

## treemapify 2.3.2

CRAN release: 2017-08-28

### Minor changes

- Documentation and misc. other changes in preparation for CRAN
  submission.
- Refresh and update documentation.
- Neater solution to import S3 method `makeContent.fittexttree` from
  ‘ggfittext’.
- Deprecate `ggplotify()`
- Add travis-ci and CRAN badges to README.
- Misc. small changes in preparation for CRAN submission.

### Bug fixes

- Remove README.html so README renders correctly on GitHub.
- Fix arguments to `geom_treemap_subgroup_text` so they actually work.
- Fix namespace incompatibility with ggfittext 0.4.2.
- Explicit invocation of all imported functions.
- Misc. small fixes in preparation for CRAN submission.

## treemapify 2.3.1

### Bug fixes

- Remove wide characters causing problems in non-UTF-8 locales.

## treemapify 2.3

### Major changes

- Add ‘treemapify_fixed’ function.
- Add ‘fixed’ options to geoms.
- Add example of animated treemap to README.

## treemapify 2.2.3

### Minor changes

- Fix ambiguity in README.
- Add test for inclusion of G20 data frame.

## treemapify 2.2.2

### Minor changes

- Moved plyr and reshape2 from ‘Depends’ to ‘Imports’.

## treemapify 2.2.1

### Bug fixes

- Fix required `ggfittext` version.
- Fix typos.

## treemapify 2.2

### Major changes

- Add ‘reflow’ options to `geom_treemap_text` and
  `geom_treemap_subgroup_text`.
- Add ‘lineheight’ aesthetic to `geom_treemap_text` and
  `geom_treemap_subgroup_text`.

### Bug fixes

- Fix namespace error causing text not to be drawn in some
  circumstances.

## treemapify 2.1

### Major changes

- Rename arguments for ggfittext v0.3.

## treemapify 2.0

### Major changes

- Added `geom_treemap`, `geom_treemap_text`,
  `geom_treemap_subgroup_border` and `geom_treemap_subgroup_text`
  ggplot2 geoms.

## treemapify 1.1.1

### Bug fixes

- Fix integer overflow error

## treemapify 1.1

### Bug fixes

- All font sizes now consistently and correctly expressed in points.
