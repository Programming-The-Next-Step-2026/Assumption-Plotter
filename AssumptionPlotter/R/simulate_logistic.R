#' Simulate data for logistic regression
#'
#' @param n Number of observations
#' @param beta0 Intercept
#' @param beta1 Slope
#' @return A data frame with simulated data
#' @export
#' @examples
#' simulate_logistic(n = 100, beta0 = 0, beta1 = 1)
simulate_logistic <- function(n = 100, beta0 = 0, beta1 = 1) {
  x <- rnorm(n)
  p <- 1 / (1 + exp(-(beta0 + beta1 * x)))
  y <- rbinom(n, 1, p)
  data.frame(x = x, y = y)
}
