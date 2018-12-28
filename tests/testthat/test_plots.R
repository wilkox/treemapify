context("visual tests of plots")

test_that("plots look the way they should", {
  vdiffr::expect_doppelganger("Basic treemap", {
    ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)) +
      geom_treemap() +
      geom_treemap_text()
  })

  vdiffr::expect_doppelganger("Fixed layout", {
    ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)) +
      geom_treemap(layout = "fixed") +
      geom_treemap_text(layout = "fixed")
  })

  vdiffr::expect_doppelganger("scol layout", {
    ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)) +
      geom_treemap(layout = "scol") +
      geom_treemap_text(layout = "scol")
  })

  vdiffr::expect_doppelganger("srow layout", {
    ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)) +
      geom_treemap(layout = "srow") +
      geom_treemap_text(layout = "srow")
  })

  vdiffr::expect_doppelganger("squarified layout starting from top right", {
    ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)) +
      geom_treemap(layout = "squarified", start = "topright") +
      geom_treemap_text(layout = "squarified", start = "topright")
  })

  vdiffr::expect_doppelganger("srow layout starting from bottom right with subgroups", {
    ggplot2::ggplot(G20, ggplot2::aes(
      area = gdp_mil_usd,
      fill = hdi,
      label = country,
      subgroup = region
    )) +
      geom_treemap(layout = "srow", start = "bottomright") +
      geom_treemap_text(layout = "srow", start = "bottomright") +
      geom_treemap_subgroup_text(layout = "srow", start = "bottomright") +
      geom_treemap_subgroup_border(layout = "srow", start = "bottomright")
  })

  vdiffr::expect_doppelganger("correct colours for subgroup text", {
    ggplot2::ggplot(G20, ggplot2::aes(
      area = gdp_mil_usd,
      fill = hdi,
      subgroup = hemisphere,
      subgroup2 = region,
      subgroup3 = country
    )) + 
      geom_treemap() +
      geom_treemap_subgroup3_text(ggplot2::aes(colour = region))
  })

  vdiffr::expect_doppelganger("correct colours for subgroup text, differently", {
    ggplot2::ggplot(G20, ggplot2::aes(
      area = gdp_mil_usd,
      fill = hdi,
      subgroup = hemisphere,
      subgroup2 = region,
      subgroup3 = country
    )) + 
      geom_treemap() + 
      geom_treemap_subgroup3_text(ggplot2::aes(colour = econ_classification))
  })
})
