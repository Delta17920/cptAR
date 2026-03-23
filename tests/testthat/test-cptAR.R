# Tests for the cptAR wrapper function

set.seed(42)
# Create a simple time series with a shift in AR(1) parameter
n <- 100
sim_data <- as.numeric(c(
  arima.sim(list(ar = 0.8), n = n/2, sd = 1),
  arima.sim(list(ar = -0.5), n = n/2, sd = 1)
))

test_that("cptAR input validation catches errors", {
  # Non-numeric data
  expect_error(cptAR(c("a", "b", "c")), "must be a numeric vector")

  # Missing values
  expect_error(cptAR(c(1, 2, NA, 4)), "cannot contain missing values")

  # Invalid order
  expect_error(cptAR(sim_data, order = 3), "exactly 1 or 2")

  # Invalid trend
  expect_error(cptAR(sim_data, trend = "yes"), "logical value")

  # Data too short
  expect_error(cptAR(c(1, 2), order = 1), "too short")
  expect_error(cptAR(c(1, 2, 3), order = 2), "too short")
})

test_that("cptAR fits AR1 models correctly", {
  # Without trend
  res1 <- cptAR(sim_data, order = 1, trend = FALSE)
  expect_s4_class(res1, "cpt.reg")
  expect_true(length(changepoint::cpts(res1)) > 0)

  # With trend
  res2 <- cptAR(sim_data, order = 1, trend = TRUE)
  expect_s4_class(res2, "cpt.reg")
})

test_that("cptAR fits AR2 models correctly", {
  # Without trend
  res1 <- cptAR(sim_data, order = 2, trend = FALSE)
  expect_s4_class(res1, "cpt.reg")

  # With trend
  res2 <- cptAR(sim_data, order = 2, trend = TRUE,minseglen = 5)
  expect_s4_class(res2, "cpt.reg")
})
