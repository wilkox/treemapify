context("treemapify")

test_that("treemapify doesn't thrown an error or warning", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  expect_error(treeMapCoordinates, NA)
  expect_warning(treeMapCoordinates, NA)
})

context("treemapify_fixed")

test_that("treemapify_fixed doesn't thrown an error or warning", {
  treeMapCoordinates <- treemapify_fixed(
    G20,
    area = "GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  expect_error(treeMapCoordinates, NA)
  expect_warning(treeMapCoordinates, NA)
})

context("ggplotify")

test_that("ggplotify doesn't thrown an error or warning", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "GDP.mil.USD",
    fill = "HDI",
    label = "Country",
    group = "Region"
  )
  treemap <- ggplotify(treeMapCoordinates)
  expect_error(treemap, NA)
  expect_warning(treemap, NA)
})
