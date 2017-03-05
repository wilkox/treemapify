context("geoms")

test_that("geoms don't throw an error", {
  expect_error( {
    ggplot(G20, aes(
      fill = HDI,
      area = GDP.mil.USD,
      colour = Population,
      subgroup = Econ.classification,
      label = Country
    )) +
      geom_treemap() +
      geom_treemap_text(
        fill.text = T,
        place = "top",
        fontface = "bold"
      ) +
      geom_treemap_subgroup_border(linetype = "dashed") +
      geom_treemap_subgroup_text(fill.text = F, place = "bottomleft", size = 10) +
      facet_grid(Econ.classification ~ Region) +
      scale_colour_gradient(low = "red", high = "green")
  } , NA)

})
