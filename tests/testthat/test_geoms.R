context("geoms")

test_that("geoms don't throw an error", {
  expect_error( {
    ggplot(G20, aes(
      fill = HDI,
      colour = Nom.GDP.mil.USD,
      area = Population,
      group = Economic.classification,
      group.label = Economic.classification,
      label = Country
    )) +
      geom_treemap() +
      geom_treemap_text(
        fill.text = T,
        place = "top",
        fontface = "bold"
      ) +
      geom_treemap_group_border(linetype = "dashed") +
      geom_treemap_group_text(fill.text = F, place = "bottomleft", size = 10) +
      facet_grid(Economic.classification ~ Region) +
      scale_colour_gradient(low = "red", high = "green")
  } , NA)

})
