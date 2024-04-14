context("treemap_squarified()")

G20_onezero <- G20_allzero <- G20
G20_onezero[1, "gdp_mil_usd"] <- 0
G20_allzero$gdp_mil_usd <- rep(0, nrow(G20_allzero))

test_that("treemap_squarified() correctly handles tiles with areas of 0", {
  expect_silent(treemap_squarified(G20_onezero, area = "gdp_mil_usd"))
  expect_error(treemap_squarified(G20_allzero, area = "gdp_mil_usd"), "area > 0")
})

context("treemap_fixed()")

test_that("treemap_fixed() correctly handles tiles with areas of 0", {
  expect_silent(treemap_fixed(G20_onezero, area = "gdp_mil_usd"))
  expect_error(treemap_fixed(G20_allzero, area = "gdp_mil_usd"), "area > 0")
})


test_that("layout functions return areas", {

  expect_identical({"gdp_mil_usd" %in% names(treemap_fixed(G20, area = "gdp_mil_usd"))}, TRUE)
  expect_identical({"gdp_mil_usd" %in% names(treemap_squarified(G20, area = "gdp_mil_usd"))}, TRUE)

})
