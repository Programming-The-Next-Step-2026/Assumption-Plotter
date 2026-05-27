#' Launch shiny app
#'
#' @import shiny
#' @details
#' Finding and launching the main app for the AssumptionPlotter package.
#'
#' @export
#' @examples
#' run_plotter()
#'

run_plotter <- function(){
  app_dir <- system.file("app", package = "AssumptionPlotter")
  runApp(app_dir)
}

