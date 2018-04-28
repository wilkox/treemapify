context("geoms")

test_that("geoms don't throw an error or warning", {
  expect_error( {
    ggplot2::ggplot(G20, ggplot2::aes(
      fill = hdi,
      area = gdp_mil_usd,
      subgroup = econ_classification,
      subgroup2 = hemisphere,
      subgroup3 = region,
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
      geom_treemap_subgroup2_border(linetype = "dashed") +
      geom_treemap_subgroup3_border(linetype = "dashed") +
      geom_treemap_subgroup_text(grow = F, place = "bottomleft", size = 10, reflow = T) +
      geom_treemap_subgroup_text(
        level = "subgroup2",
        grow = F,
        place = "bottomleft",
        size = 10,
        reflow = T
      ) +
      geom_treemap_subgroup_text(
        level = "subgroup3",
        grow = F,
        place = "bottomleft",
        size = 10,
        reflow = T
      ) +
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

context("zero-area tiles")

G20_onezero <- G20
G20_onezero[1, "hdi"] <- 0
G20_allzero <- G20
G20_allzero$hdi <- rep(0, nrow(G20_allzero))

test_that("data with a single zero-area tile doesn't throw an error", {
  expect_silent({
    ggplot2::ggplot(G20_onezero, ggplot2::aes(fill = gdp_mil_usd, area = hdi)) +
      geom_treemap()
  })
  expect_silent({
    ggplot2::ggplot(G20_onezero, ggplot2::aes(fill = gdp_mil_usd, area = hdi)) +
      geom_treemap(fixed = T)
  })
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
