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
