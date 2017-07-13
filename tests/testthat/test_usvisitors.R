context("usvisitors")

test_that("usvisitors dataset is included", {
  expect_equal(names(usvisitors), c("category", "subcategory", "year", "average_stay_nights", "visitors"))
})
