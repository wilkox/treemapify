library(treemapify)
context("treemapify() function")

test_that("treemapify() returns expected layout", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "Nom.GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  expect_identical(treeMapCoordinates, G20ExpectedCoordinates)
})
