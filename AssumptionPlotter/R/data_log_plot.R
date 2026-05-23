#' Scatter plot of data points
#'
#' @param x (Simulated) data denoting position of data point on the x-axis.
#' @param y (Simulated) data denoting position of data point on the y-axis.
#' @param type What shape your data should be in.
#' @param pch Shape of your data points in the plot.
#' @param col1 Color of your data points in the plot.
#' @param col2 Color of your logistic curve in the plot.
#' @param incl_mean Whether you want the mean of your data points displayed.
#' @return A plot showing how well your data points follow the logistic function.
#' @export
#' @examples
#' data_log_plot(x = rnorm(10,0,1), y = rbinom(10,1,0.4))

data_log_plot <- function(x, y, type = "logistic", pch = 16, col1 =rgb(0,0,0,0.6),
                          col2 = rgb(1,0,0,1), incl_mean = TRUE) {
  if(type == "logistic") {
    # fit logistic model
    fit <- glm(y ~ x, family = binomial)

    # scatter plot
    plot(x, y,
         pch = pch,
         col = col1,
         xlab = "x",
         ylab = "Outcome")

    # prediction grid
    xgrid <- seq(min(x), max(x), length.out = 500)

    # predicted probabilities
    pred <- predict(fit,
                    newdata = data.frame(x = xgrid),
                    type = "response")

    # draw sigmoid curve
    lines(xgrid, pred, col = "red", lwd = 3)

    if(incl_mean) {
      abline(v = mean(x), lty = 2, col= "gray40")
      text(.1+mean(x), )
    }

  }else {
    stop("The function only supports the logistic function at the moment")
  }
}



