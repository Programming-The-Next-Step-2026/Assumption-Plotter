test_that("simulate_logistic gives dataframe", {
  data <- simulate_logistic(20)

  expect_s3_class(data, "data.frame")

  expect_equal(nrow(data),20)
})


