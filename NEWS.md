# v2.5.3

## Bug fixes

- Fix issue with correct drawing of aesthetics in `geom_tremap_subgroup*_text()` (#32, thanks @jonathan-g)

# v2.5.2

## Bug fixes

- Fix issue with importing ggfittext

# v2.5.1

## Major changes

- Added new `layout` and `start` arguments to `treemapify()` and all geoms

## Minor changes

- Restore `xlim` and `ylim` options to `treemapify()`
- Add and improve tests
- Misc. code quality improvements

## Bug fixes

- Fixed bug in handling of subgroups, which should result in more aesthetically pleasing layouts
- Fix dereferencing of arguments in `treemapify()` (#22, thanks @GregorDeCillia)
- Fix deprecation of `fill`, `label` and `group` arguments in `treemapify()` to maintain backwards compatibility (thanks @GregorDeCillia)

# v2.5.0

## Major changes

- Refactor treemap layout algorithms
- Add support for nested subgroups with new `subgroup2` and `subgroup3` aesthetics, and `geom_treemap_subgroup2_border`, `geom_treemap_subgroup3_border`, `geom_treemap_subgroup2_text`, and `geom_treemap_subgroup3_text` geoms.

## Minor changes

- Add 'hemisphere' column to G20 data

## Bug fixes

- Fix typo in README (#19, thanks @mruessler)

# v2.4.0

## Minor changes

- Change R and grid dependencies to 3.1
- Remove reshape2 dependency

## Bug fixes

- Fix handling of data where some observations have area 0 (#17, thanks @py)

# v2.3.2

## Minor changes

- Documentation and misc. other changes in preparation for CRAN submission.
- Refresh and update documentation.
- Neater solution to import S3 method `makeContent.fittexttree` from
  'ggfittext'.
- Deprecate `ggplotify()`
- Add travis-ci and CRAN badges to README
- Misc. small changes in preparation for CRAN submission.

## Bug fixes
- Remove README.html so README renders correctly on GitHub
- Fix arguments to `geom_treemap_subgroup_text` so they actually work.
- Fix namespace incompatibility with ggfittext 0.4.2
- Explicit invocation of all imported functions
- Misc. small fixes in preparation for CRAN submission

# v2.3.1

## Bug fixes
- Remove wide characters causing problems in non-UTF-8 locales.

# v2.3

## Major changes
- Add ‘treemapify_fixed’ function
- Add ‘fixed’ options to geoms
- Add example of animated treemap to README

# v2.2.3

## Minor changes
- Fix ambiguity in README
- Add test for inclusion of G20 data frame

# v2.2.2

## Minor changes
- Moved plyr and reshape2 from ‘Depends’ to ‘Imports’

# v2.2.1

## Bug fixes
- Fix required `ggfittext` version.
- Fix typos.

# v2.2

## Major changes
- Add ‘reflow’ options to `geom_treemap_text` and `geom_treemap_subgroup_text`.
- Add ‘lineheight’ aesthetic to `geom_treemap_text` and `geom_treemap_subgroup_text`.

## Bug fixes
- Fix namespace error causing text not to be drawn in some circumstances.

# v2.1

## Major changes
- Rename arguments for ggfittext v0.3.

# v2.0

## Major changes
- Added `geom_treemap`, `geom_treemap_text`, `geom_treemap_subgroup_border` and
  `geom_treemap_subgroup_text` ggplot2 geoms.

# v1.1.1

## Bug fixes
- Fix integer overflow error

# v1.1

## Bug fixes
- All font sizes now consistently and correctly expressed in points.
