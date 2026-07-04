context("geoms")

test_that("geoms work with basic parameters", {
  expect_silent( {
    p <- ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      subgroup2 = hemisphere,
      subgroup3 = region,
      label = country
    )) +
      geom_treemap(layout = "scol", start = "bottomright") +
      geom_treemap_text(
        grow = T,
        place = "top",
        fontface = "bold",
        reflow = F,
        layout = "srow",
        start = "bottomright"
      ) +
      geom_treemap_subgroup_border(
        linetype = "dashed",
        layout = "squarified",
        start = "bottomright"
      ) +
      geom_treemap_subgroup2_border(
        linetype = "dashed",
        layout = "fixed",
        start = "bottomright"
      ) +
      geom_treemap_subgroup3_border(
        linetype = "dashed",
        layout = "fixed",
        start = "bottomright"
      ) +
      geom_treemap_subgroup_text(
        grow = F,
        place = "bottomleft",
        size = 10,
        reflow = T,
        layout = "srow",
        start = "bottomright"
      ) +
      geom_treemap_subgroup2_text(
        grow = F,
        place = "bottomleft",
        size = 10,
        reflow = T,
        layout = "scol",
        start = "bottomright"
      ) +
      geom_treemap_subgroup3_text(
        grow = F,
        place = "bottomleft",
        size = 10,
        reflow = T,
        layout = "scol",
        start = "bottomright"
      ) +
      ggplot2::facet_grid(econ_classification ~ region) +
      ggplot2::scale_colour_gradient(low = "red", high = "green")
    print(p)
  })
})

test_that("geom_treemap_subgroup_text works with a colour aesthetic", {
  expect_silent( {
    p <- ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, subgroup = hemisphere, subgroup2 = region, subgroup3 = country)) +
      treemapify::geom_treemap() +
      treemapify::geom_treemap_subgroup3_text(ggplot2::aes(colour = region))
    print(p)
  } )
})

test_that("geom_treemap_subgroup_border works when an inherited aesthetic varies within subgroups", {
  # region (the colour aesthetic) has more unique values than hemisphere (the
  # subgroup), so collapsing to subgroup level must map colours by name rather
  # than assign all unique values (#54)
  p <- ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, subgroup = hemisphere)) +
    treemapify::geom_treemap() +
    treemapify::geom_treemap_subgroup_border(ggplot2::aes(colour = region))
  expect_no_error(ggplot2::ggplotGrob(p))
})

test_that("geom_treemap_subgroup_border does not affect legend key sizing", {
  # The border layer inherits the fill aesthetic and so would join the fill
  # legend, where its large default size inflates the legend keys and overrides
  # theme(legend.key.size). Defaulting show.legend = FALSE keeps it out of the
  # legend, so adding a border must leave the legend box unchanged (#36, #58).
  d <- data.frame(
    area = c(1, 2, 3, 4, 5, 6),
    fill = c("a", "b", "c", "d", "e", "f"),
    subgroup = c("x", "x", "x", "y", "y", "y")
  )

  guidebox_height <- function(p) {
    g <- ggplot2::ggplotGrob(p)
    i <- which(g$layout$name == "guide-box-right")
    sum(grid::convertHeight(g$grobs[[i]]$heights, "mm", valueOnly = TRUE))
  }

  base <- ggplot2::ggplot(d, ggplot2::aes(area = area, fill = fill, subgroup = subgroup)) +
    treemapify::geom_treemap() +
    ggplot2::theme(legend.key.size = grid::unit(0.3, "cm"))
  with_border <- base + treemapify::geom_treemap_subgroup_border(size = 20)

  expect_false(isTRUE(treemapify::geom_treemap_subgroup_border()$show.legend))
  expect_equal(guidebox_height(with_border), guidebox_height(base))
})
