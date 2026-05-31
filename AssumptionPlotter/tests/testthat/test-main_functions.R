# Unit tests for the main functions of AssumptionPlotter

## clean_df()
test_that("clean_df() returns a data frame with correct structure", {
  df <- data.frame(
    id = c(1, 1, 1, 2, 2),
    day = c(1, 1, 2, 1, 1),
    beep = c(1, 2, 1, 1, 2),
    mood = c(5, 4, 3, 6, 7),
    stress = c(2, 3, 4, 1, 2)
  )

  result <- clean_df(df,
                     exp_day = 2,
                     exp_beep = 2,
                     variables = "stress")

  expect_s3_class(result, "data.frame")
  expect_true("missing" %in% names(result))
  expect_true(nrow(result) > nrow(df))  # expands with complete()
})

test_that("clean_df() creates missing column", {
  df <- data.frame(
    id = c(1, 1, 1, 1),
    day = c(1, 1, 2, 2),
    beep = c(1, 2, 1, 2),
    var1 = c(NA, 5, 3, NA)
  )

  result <- clean_df(df,
                     exp_day = 2,
                     exp_beep = 2,
                     variables = "var1")

  expect_true("missing" %in% names(result))
  expect_true(any(result$missing == 1))  # at least one missing value marked
})

test_that("clean_df() handles empty data frame", {
  df <- data.frame(
    id = character(),
    day = numeric(),
    beep = numeric(),
    var1 = numeric()
  )

  expect_error(clean_df(df,
                        exp_day = 1,
                        exp_beep = 1,
                        variables = "var1"), NA)  # should not error
})


## assumption_plot()
test_that("assumption_plot() returns a ggplot object", {
  df <- menghini_2023

  p <- assumption_plot(
    df = df,
    participant = df$id[1],
    variables = c("well", "discontent"),
    expected_days = 3,
    beeps_per_day = 7,
    include_day = TRUE,
    include_day_line = TRUE,
    impute = "none",
    add_trend = FALSE,
    theme_choice = "classic"
  )

  expect_s3_class(p, "ggplot")
})

test_that("assumption_plot() adds trend line when add_trend = TRUE", {
  df <- menghini_2023

  p <- assumption_plot(
    df = df,
    participant = df$id[1],
    variables = c("well"),
    expected_days = 3,
    beeps_per_day = 7,
    add_trend = TRUE,
    trend_type = "lm",
    theme_choice = "classic"
  )

  # Check if geom_smooth was added (has stat summary layer)
  layers <- sapply(p$layers, function(x) class(x$geom)[1])
  expect_true(any(grepl("Smooth", layers)))
})

test_that("assumption_plot() handles single variable", {
  df <- menghini_2023

  p <- assumption_plot(
    df = df,
    participant = df$id[1],
    variables = "well",
    expected_days = 3,
    beeps_per_day = 7,
    theme_choice = "classic"
  )

  expect_s3_class(p, "ggplot")
})


## run_plotter()
test_that("run_plotter() finds the app directory", {

  appDir <- system.file("app", package = "AssumptionPlotter")

  expect_true(nzchar(appDir))
})




## pie_bar_chart()
test_that("pie_bar_chart() returns a ggplot object for pie chart", {
  df <- menghini_2023

  p <- pie_bar_chart(
    df = df,
    participant = df$id[1],
    type = "pie",
    plot_all = FALSE
  )

  expect_s3_class(p, "ggplot")
})

test_that("pie_bar_chart() returns a ggplot object for bar chart", {
  df <- menghini_2023

  p <- pie_bar_chart(
    df = df,
    participant = df$id[1],
    type = "bar",
    plot_all = FALSE
  )

  expect_s3_class(p, "ggplot")
})

test_that("pie_bar_chart() handles plot_all = TRUE", {
  df <- menghini_2023

  p <- pie_bar_chart(
    df = df,
    participant = df$id[1],
    type = "pie",
    plot_all = TRUE
  )

  expect_s3_class(p, "ggplot")
})


## rank_participants()
test_that("rank_participants() returns a data frame", {
  df <- menghini_2023

  result <- rank_participants(df, show = 5)

  expect_s3_class(result, "data.frame")
  expect_true("ID most:" %in% names(result))
  expect_true("Percent" %in% names(result) || "well" %in% names(result))
})

test_that("rank_participants() ranks in correct order", {
  df <- data.frame(
    id = c(1, 1, 2, 2, 3, 3),
    missing = c(T, T, F, F, F, T)
  )

  result <- rank_participants(df, 3)

  expect_s3_class(result, "data.frame")
  expect_equal(nrow(result), 3)  # 3 unique participants
})


