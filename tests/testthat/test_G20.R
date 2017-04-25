context("G20")

test_that("G20 dataset is included", {
  expect_equal(names(G20), c("Region", "Country", "GDP.mil.USD", "HDI", "Econ.classification"))
})
