test_that("treemapify() works with basic parameters", {
  expect_silent(
    treemapify(
      G20,
      area = "gdp_mil_usd",
      layout = "fixed"
    )
  )
  expect_silent(
    treemapify(
      G20,
      area = "gdp_mil_usd",
      subgroup = "hemisphere",
      subgroup2 = "region",
      subgroup3 = "econ_classification",
      start = "topright",
      layout = "srow",
      xlim = c(-100, pi * 7),
      ylim = c(0.4, 1235)
    )
  )
})

test_that("treemapify() returns a warning for deprecated arguments", {
  expect_warning(
    treemapify(G20, area = "gdp_mil_usd", label = "country"),
    "deprecated"
  )
  expect_warning(
    treemapify(G20, area = "gdp_mil_usd", fill = "country"),
    "deprecated"
  )
  expect_warning(
    treemapify(G20, area = "gdp_mil_usd", group = "region"),
    "deprecated"
  )
  expect_warning(
    treemapify(G20, area = "gdp_mil_usd", fixed = TRUE),
    "deprecated"
  )
})

test_that("treemapify() returns an error when passed an invalid layout algorithm", {
  expect_error(
    treemapify(G20, area = "gdp_mil_usd", layout = "fake"),
    "Invalid value"
  )
})

test_that("treemapify() returns an error when passed an invalid start corner", {
  expect_error(
    treemapify(G20, area = "gdp_mil_usd", start = "topLeft"),
    "Invalid value"
  )
})

test_that("treemapify() returns an error when passed non-existent columns", {
  expect_error(
    treemapify(G20, area = "fake"),
    "not found in data"
  )
  expect_error(
    treemapify(G20, area = "gdp_mil_usd", subgroup = "fake"),
    "not found in data"
  )
  expect_error(
    treemapify(
      G20,
      area = "gdp_mil_usd",
      subgroup = "region",
      subgroup2 = "fake"
    ),
    "not found in data"
  )
  expect_error(
    treemapify(
      G20,
      area = "gdp_mil_usd",
      subgroup = "region",
      subgroup2 = "hemisphere",
      subgroup3 = "fake"
    ),
    "not found in data"
  )
})

test_that("treemapify() returns an error for invalid xlim or ylim arguments", {
  expect_error(treemapify(G20, area = "gdp_mil_usd", xlim = c(1, 2, 3)), "xlim")
  expect_error(treemapify(G20, area = "gdp_mil_usd", xlim = c(3, 2, 1)), "xlim")
  expect_error(
    treemapify(G20, area = "gdp_mil_usd", xlim = c("a", "b")),
    "xlim"
  )
  expect_error(treemapify(G20, area = "gdp_mil_usd", ylim = c(1, 2, 3)), "ylim")
  expect_error(treemapify(G20, area = "gdp_mil_usd", ylim = c(3, 2, 1)), "ylim")
  expect_error(
    treemapify(G20, area = "gdp_mil_usd", ylim = c("a", "b")),
    "ylim"
  )
})

test_that("treemapify() keeps tiles within xlim/ylim for every start corner", {
  xlim <- c(2, 5)
  ylim <- c(10, 20)
  for (start in c("bottomleft", "topleft", "topright", "bottomright")) {
    lay <- treemapify(
      G20,
      area = "gdp_mil_usd",
      xlim = xlim,
      ylim = ylim,
      start = start
    )
    expect_gte(min(lay$xmin, lay$xmax), xlim[1])
    expect_lte(max(lay$xmin, lay$xmax), xlim[2])
    expect_gte(min(lay$ymin, lay$ymax), ylim[1])
    expect_lte(max(lay$ymin, lay$ymax), ylim[2])
  }
})

test_that("treemapify() drops rows with a missing area and warns", {
  G20na <- G20
  G20na$gdp_mil_usd[3] <- NA

  expect_warning(
    treemapify(G20na, area = "gdp_mil_usd"),
    "Dropping 1 row"
  )

  lay <- suppressWarnings(treemapify(G20na, area = "gdp_mil_usd"))
  expect_identical(nrow(lay), nrow(G20) - 1L)
  expect_false(anyNA(lay[c("xmin", "xmax", "ymin", "ymax")]))

  # Multiple missing-area rows are reported with a pluralised message
  G20na$gdp_mil_usd[5] <- NA
  expect_warning(
    treemapify(G20na, area = "gdp_mil_usd"),
    "Dropping 2 rows"
  )
})

test_that("treemapify returns areas", {
  expect_identical(
    {
      "gdp_mil_usd" %in%
        names(treemapify(G20, area = "gdp_mil_usd", layout = "fixed"))
    },
    TRUE
  )
  expect_identical(
    {
      "gdp_mil_usd" %in%
        names(treemapify(G20, area = "gdp_mil_usd", layout = "squarified"))
    },
    TRUE
  )
})

test_that("treemapify() returns the documented layout columns", {
  for (layout in c("squarified", "scol", "srow", "fixed")) {
    lay <- treemapify(G20, area = "gdp_mil_usd", layout = layout)
    # The four tile-boundary columns are always present
    expect_true(all(c("xmin", "xmax", "ymin", "ymax") %in% names(lay)))
    # Every input column, including the area column, is retained
    expect_true(all(names(G20) %in% names(lay)))
  }
})

test_that("treemapify() silently drops rows with zero or negative area", {
  G20zn <- G20
  G20zn$gdp_mil_usd[1] <- 0
  G20zn$gdp_mil_usd[2] <- -5

  for (layout in c("squarified", "fixed")) {
    expect_silent(
      lay <- treemapify(G20zn, area = "gdp_mil_usd", layout = layout)
    )
    expect_identical(nrow(lay), nrow(G20) - 2L)
  }
})

test_that("treemapify() errors when every area is zero or negative", {
  G20allzero <- G20
  G20allzero$gdp_mil_usd <- rep(0, nrow(G20allzero))

  for (layout in c("squarified", "fixed")) {
    expect_error(
      treemapify(G20allzero, area = "gdp_mil_usd", layout = layout),
      "area > 0"
    )
  }
})

test_that("treemapify() row order follows the layout algorithm", {
  # The squarified layouts sort tiles by area, largest first
  for (layout in c("squarified", "scol", "srow")) {
    lay <- treemapify(G20, area = "gdp_mil_usd", layout = layout)
    expect_identical(lay$gdp_mil_usd, sort(G20$gdp_mil_usd, decreasing = TRUE))
  }

  # The fixed layout preserves the input row order
  lay <- treemapify(G20, area = "gdp_mil_usd", layout = "fixed")
  expect_identical(lay$country, G20$country)
})
