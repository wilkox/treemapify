context("geoms")

test_that("geoms don't throw an error", {
  expect_error( {
    ggplot(G20, aes(
      fill = HDI,
      area = GDP.mil.USD,
      subgroup = Econ.classification,
      label = Country
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
      facet_grid(Econ.classification ~ Region) +
      scale_colour_gradient(low = "red", high = "green")
  } , NA)

})
