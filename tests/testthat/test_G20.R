context("G20 data frame")

test_that("G20 data frame is present", {
  expect_equal(
    names(G20),
    c(
      "region",
      "country",
      "gdp_mil_usd",
      "hdi",
      "econ_classification",
      "hemisphere"
    )
  )
  expect_equal(nrow(G20), 20)
})
