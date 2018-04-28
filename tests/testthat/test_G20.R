context("G20")

test_that("G20 dataset is included", {
  expect_equal(names(G20), c("region", "country", "gdp_mil_usd", "hdi", "econ_classification", "hemisphere"))
})
