context("visual tests of plots")

test_that("plots look the way they should", {
  expect_doppelganger("Basic treemap", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)
    ) +
      geom_treemap() +
      geom_treemap_text()
  })

  expect_doppelganger("Fixed layout", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)
    ) +
      geom_treemap(layout = "fixed") +
      geom_treemap_text(layout = "fixed")
  })

  expect_doppelganger("scol layout", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)
    ) +
      geom_treemap(layout = "scol") +
      geom_treemap_text(layout = "scol")
  })

  expect_doppelganger("srow layout", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)
    ) +
      geom_treemap(layout = "srow") +
      geom_treemap_text(layout = "srow")
  })

  expect_doppelganger("squarified layout starting from top right", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(area = gdp_mil_usd, fill = hdi, label = country)
    ) +
      geom_treemap(layout = "squarified", start = "topright") +
      geom_treemap_text(layout = "squarified", start = "topright")
  })

  expect_doppelganger("srow layout starting from bottom right with subgroups", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = gdp_mil_usd,
        fill = hdi,
        label = country,
        subgroup = region
      )
    ) +
      geom_treemap(layout = "srow", start = "bottomright") +
      geom_treemap_text(layout = "srow", start = "bottomright") +
      geom_treemap_subgroup_text(layout = "srow", start = "bottomright") +
      geom_treemap_subgroup_border(layout = "srow", start = "bottomright")
  })

  expect_doppelganger("correct colours for subgroup text", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = gdp_mil_usd,
        fill = hdi,
        subgroup = hemisphere,
        subgroup2 = region,
        subgroup3 = country
      )
    ) +
      geom_treemap() +
      geom_treemap_subgroup3_text(ggplot2::aes(colour = region))
  })

  expect_doppelganger("correct colours for subgroup text, differently", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = gdp_mil_usd,
        fill = hdi,
        subgroup = hemisphere,
        subgroup2 = region,
        subgroup3 = country
      )
    ) +
      geom_treemap() +
      geom_treemap_subgroup3_text(ggplot2::aes(colour = econ_classification))
  })

  expect_doppelganger("understands variants of 'centre'", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = gdp_mil_usd,
        fill = hdi,
        label = country,
        subgroup = region
      )
    ) +
      geom_treemap(layout = "srow", start = "bottomright") +
      geom_treemap_text(
        layout = "srow",
        start = "bottomright",
        place = "center"
      ) +
      geom_treemap_subgroup_text(
        layout = "srow",
        start = "bottomright",
        place = "middle"
      ) +
      geom_treemap_subgroup_border(layout = "srow", start = "bottomright")
  })

  expect_doppelganger("understands variants of 'centre' with subgroups", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = 1,
        label = country,
        subgroup = hemisphere,
        subgroup2 = region,
        subgroup3 = econ_classification
      )
    ) +
      geom_treemap() +
      geom_treemap_subgroup3_border(colour = "blue", size = 1) +
      geom_treemap_subgroup2_border(colour = "white", size = 3) +
      geom_treemap_subgroup_border(colour = "red", size = 5) +
      geom_treemap_subgroup_text(
        place = "middle",
        colour = "red",
        alpha = 0.5,
        grow = T
      ) +
      geom_treemap_subgroup2_text(
        colour = "white",
        alpha = 0.5,
        fontface = "italic"
      ) +
      geom_treemap_subgroup3_text(place = "top", colour = "blue", alpha = 0.5) +
      geom_treemap_text(colour = "white", place = "middle", reflow = T)
  })

  expect_doppelganger("colour is drawn correctly in legend", {
    ggplot2::ggplot(
      G20,
      ggplot2::aes(
        area = gdp_mil_usd,
        fill = region,
        color = econ_classification,
        linetype = econ_classification
      )
    ) +
      geom_treemap() +
      ggplot2::scale_color_manual(values = c("red", "black")) +
      ggplot2::scale_linetype_manual(values = c(1, 3)) +
      ggplot2::guides(
        color = ggplot2::guide_legend(
          override.aes = list(color = c("red", "black"))
        )
      )
  })
})

test_that("pattern fills work", {
  skip_if_not_installed("svglite", "2.1.3")
  skip_if_not_installed("fontquiver", "0.2.1")
  skip_if_not_installed("sysfonts", "0.8.9")
  skip_if_not_installed("showtext", "0.9.7")

  # vdiffr uses an internal version of svglite to draw SVGs, which is not kept
  # in sync with the released version. So, vdiffr still does not support
  # gradient and pattern fills. This alternative writer aims to support
  # gradients and patterns, but also maintain stable fonts across platforms, to
  # prevent snapshot mismatches.
  #
  # https://github.com/r-lib/vdiffr/issues/132#issuecomment-1545074881
  svglite_writer = function(plot, file, title = "") {
    liberation_sans = fontquiver::font_styles("Liberation", "Sans")
    symbola = fontquiver::font("Symbola", "Symbols", "Regular")
    sysfonts::font_add(
      "Liberation Sans",
      regular = liberation_sans$Regular$ttf,
      bold = liberation_sans$Bold$ttf,
      italic = liberation_sans$Italic$ttf,
      bolditalic = liberation_sans$`Bold Italic`$ttf,
      symbol = symbola$ttf
    )

    svglite::svglite(file)
    showtext::showtext_begin()
    on.exit({
      showtext::showtext_end()
      grDevices::dev.off()
    })

    print(
      plot +
        ggplot2::labs(title = title) +
        ggplot2::theme_test(base_family = "Liberation Sans")
    )
  }

  vdiffr::expect_doppelganger(
    "linearGradient fills",
    {
      patterns <- list(
        linearGradient(c("red", "blue"), group = FALSE),
        linearGradient(c("yellow", "orange"), group = FALSE),
        linearGradient(c("purple", "white"), group = FALSE),
        linearGradient(c("pink", "green"), group = FALSE)
      )
      G4 <- G20[1:4, ]
      ggplot2::ggplot(G4, ggplot2::aes(area = gdp_mil_usd, fill = country)) +
        geom_treemap() +
        ggplot2::scale_fill_manual(values = patterns)
    },
    writer = svglite_writer
  )

  vdiffr::expect_doppelganger(
    "chequer pattern fill",
    {
      chequer_pattern <- pattern(
        rectGrob(
          x = c(0.25, 0.75),
          y = c(0.25, 0.75),
          width = 0.5,
          height = 0.5
        ),
        width = unit(5, "mm"),
        height = unit(5, "mm"),
        extend = "repeat",
        gp = gpar(fill = "limegreen")
      )
      ggplot2::ggplot(G20, ggplot2::aes(area = gdp_mil_usd, fill = country)) +
        geom_treemap(fill = chequer_pattern)
    },
    writer = svglite_writer
  )
})
