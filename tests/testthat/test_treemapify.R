context("treemapify")

test_that("treemapify doesn't thrown an error or warning", {
  treeMapCoordinates <- treemapify(
    G20,
    area = "gdp_mil_usd",
    fill = "hdi",
    label = "country",
    group = "region"
  )
  expect_error(treeMapCoordinates, NA)
  expect_warning(treeMapCoordinates, NA)
})

context("treemapify_fixed")

test_that("treemapify_fixed doesn't thrown an error or warning", {
  treeMapCoordinates <- treemapify_fixed(
    G20,
    area = "gdp_mil_usd",
    fill = "hdi",
    label = "country",
    group = "region"
  )
  expect_error(treeMapCoordinates, NA)
  expect_warning(treeMapCoordinates, NA)
})
