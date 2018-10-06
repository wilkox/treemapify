context("treemapify()")

test_that("treemapify() works with basic parameters", {
  expect_silent(
    treemapify(
      G20,
      area = "gdp_mil_usd",
      fixed = TRUE
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
