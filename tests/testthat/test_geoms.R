context("geoms")

test_that("geoms don't throw an error or warning", {
  expect_error( {
    ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      label = country
    )) +
      geom_treemap() +
      geom_treemap_text(
        grow = T,
        place = "top",
        fontface = "bold",
        reflow = F
      ) +
      geom_treemap_subgroup_border(linetype = "dashed") +
      geom_treemap_subgroup_text(grow = F, place = "bottomleft", size = 10, reflow = T) +
      ggplot2::facet_grid(econ_classification ~ region) +
      ggplot2::scale_colour_gradient(low = "red", high = "green")
  } , NA)

  expect_warning( {
    ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      label = country
    )) +
      geom_treemap() +
      geom_treemap_text(
        grow = T,
        place = "top",
        fontface = "bold",
        reflow = F
      ) +
      geom_treemap_subgroup_border(linetype = "dashed") +
      geom_treemap_subgroup_text(grow = F, place = "bottomleft", size = 10, reflow = T) +
      ggplot2::facet_grid(econ_classification ~ region) +
      ggplot2::scale_colour_gradient(low = "red", high = "green")
  } , NA)

})

context("geoms with fixed options")

test_that("geoms with fixed options don't throw an error or warning", {
  expect_error( {
    ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      label = country
    )) +
      geom_treemap(fixed = T) +
      geom_treemap_text(
        grow = T,
        place = "top",
        fontface = "bold",
        reflow = F,
        fixed = T
      ) +
      geom_treemap_subgroup_border(linetype = "dashed", fixed = T) +
      geom_treemap_subgroup_text(grow = F, place = "bottomleft", size = 10, reflow = T, fixed = T) +
      ggplot2::facet_grid(econ_classification ~ region) +
      ggplot2::scale_colour_gradient(low = "red", high = "green")
  } , NA)

  expect_warning( {
    ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      label = country
    )) +
      geom_treemap(fixed = T) +
      geom_treemap_text(
        grow = T,
        place = "top",
        fontface = "bold",
        reflow = F,
        fixed = T
      ) +
      geom_treemap_subgroup_border(linetype = "dashed", fixed = T) +
      geom_treemap_subgroup_text(grow = F, place = "bottomleft", size = 10, reflow = T, fixed = T) +
      ggplot2::facet_grid(econ_classification ~ region) +
      ggplot2::scale_colour_gradient(low = "red", high = "green")
  } , NA)
})
