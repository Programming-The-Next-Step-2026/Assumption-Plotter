test_that("data_log_plot gives a plot without error", {
  data <- simulate_logistic(50)

  expect_silent(
    data_log_plot(data$x, data$y)
  )

})
