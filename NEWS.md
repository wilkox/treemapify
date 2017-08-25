# v2.3.2

## Minor changes

- Documentation and misc. other changes in preparation for CRAN submission.

# v2.3.1.9003

## Bug fixes

- Remove README.html so README renders correctly on GitHub

# v2.3.1.9002

## Bug fixes
- Fix arguments to `geom_treemap_subgroup_text` so they actually work.

## Minor changes
- Refresh and update documentation.
- Neater solution to import S3 method `makeContent.fittexttree` from
  'ggfittext'.
- Misc. small changes in preparation for CRAN submission.

# v2.3.1.9001

## Bug fixes
- Fix namespace incompatibility with ggfittext 0.4.2
- Explicit invocation of all imported functions
- Misc. small fixes in preparation for CRAN submission

## Minor changes
- Deprecate `ggplotify()`
- Add travis-ci and CRAN badges to README

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
