# CLAUDE.md

treemapify is an R package providing ggplot2 geoms for drawing treemaps,
published on CRAN.

## Structure

- `R/` — package source: the geoms (`geom_treemap*.R`), the layout
  algorithms (`treemap_squarified.R`, `treemap_fixed.R`), the
  [`treemapify()`](https://wilkox.org/treemapify/dev/reference/treemapify.md)
  layout function, the `G20` dataset, and utilities.
- `tests/testthat/` — testthat tests, including vdiffr visual-regression
  snapshots under `_snaps/`.
- `vignettes/` — the package vignette (knitr/rmarkdown).
- `man/` — roxygen2-generated documentation; do not edit by hand.

## Conventions and pitfalls

- Australian/British English throughout (`Language: en-GB`): “colour”,
  “centre”.
- Documentation is roxygen2 with markdown enabled. NEVER run
  `devtools::document()` — prompt David to run it.
- Do not edit files in `man/`; they are generated from the roxygen
  blocks in `R/`.
- Visual tests use vdiffr snapshots; updating them needs interactive
  approval (`vdiffr::manage_cases()`), so do not edit snapshot files
  directly.

## Release documentation

- The README shows an animated treemap
  (`man/figures/animated_treemap.gif`) produced by a gganimate chunk in
  `README.Rmd`. It is regenerated whenever the README is knit
  (`devtools::build_readme()`), so it must be rebuilt with the rest of
  the documentation for every release. Rendering it needs the
  `gganimate`, `gapminder`, and `gifski` packages, which are used only
  for the README and are not declared in DESCRIPTION.
