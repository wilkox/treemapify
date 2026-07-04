context("treemapify()")

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
  expect_error(treemapify(G20, area = "gdp_mil_usd", layout = "fake"), "Invalid value")
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
    treemapify(G20, area = "gdp_mil_usd", subgroup = "region", subgroup2 = "fake"),
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
  expect_error(treemapify(G20, area = "gdp_mil_usd", xlim = c("a", "b")), "xlim")
  expect_error(treemapify(G20, area = "gdp_mil_usd", ylim = c(1, 2, 3)), "ylim")
  expect_error(treemapify(G20, area = "gdp_mil_usd", ylim = c(3, 2, 1)), "ylim")
  expect_error(treemapify(G20, area = "gdp_mil_usd", ylim = c("a", "b")), "ylim")
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

test_that("treemapify returns areas", {
  expect_identical({"gdp_mil_usd" %in% names(treemapify(G20, area = "gdp_mil_usd", layout = "fixed"))}, TRUE)
  expect_identical({"gdp_mil_usd" %in% names(treemapify(G20, area = "gdp_mil_usd", layout = "squarified"))}, TRUE)
})
