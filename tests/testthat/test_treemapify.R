library(treemapify)
context("treemapify")

test_that("treemapify doesn't thrown an error", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "Nom.GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  expect_error(treeMapCoordinates, NA)
})

test_that("treemapify doesn't thrown an error", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "Population",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  expect_error(treeMapCoordinates, NA)
})

context("ggplotify")

test_that("ggplotify doesn't thrown an error", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "Nom.GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  treemap <- ggplotify(treeMapCoordinates)
  expect_error(treemap, NA)
})
