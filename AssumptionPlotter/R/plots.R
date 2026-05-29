#' AssumptionPlotter Plot
#'
#' @details
#' This function creates the plots in the Plots tab of AssumptionPlotter
#' @param data Selected dataset.
#' @param missing_data Selected dataset's missing data.
#' @param participant Participant to be plotted.
#' @param variables All variables to be plotted (that start with "var_").
#' @param include_na Plot NA's
#' @param impute Method for imputing NA's.
#' @param add_trend Include a linear regression line showing the trend in the data.
#' @param theme Decide what theme the plot should have.
#' @param palette Choose color scheme of plot. Only supports RColorBrewer palettes for now.
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @import RColorBrewer
#'
#'
hey <- data_plot(contreras_2020,
          missing_contreras_2020,
          1,
          names(contreras_2020)[startsWith(names(contreras_2020), "var_")],
          7,
          FALSE,
          "none",
          FALSE,
          "classic",
          magma)

library(RColorBrewer)
library(ggplot2)
library(dplyr)


re_df <- reconstruct_data(geschwind_2013,missing_geschwind_2013)

plot_ild(re_df,
         10720,
         names(geschwind_2013)[startsWith(names(geschwind_2013), "var_")],
         10,
         10,
         include_na = FALSE,
         impute = "none",
         add_trend = T,
         trend_type = "lm",
         theme_choice = "classic",
         palette = RColorBrewer::brewer.pal(n = 8, name = "Paired")
         )


plot_ild <- function(
    df,
    participant,
    variables,
    expected_days,
    beeps_per_day,
    include_na = FALSE,
    impute = "none",
    add_trend = FALSE,
    trend_type = "lm",
    theme_choice = "minimal",
    palette = NULL
){

  df <- df %>%
    filter(id == participant)

  keep_cols <- c(
    "day",
    "beep",
    variables
  )

  df <- df[,keep_cols]

  #############################
  # NA handling
  #############################

  if(impute!="none"){

    for(v in variables){

      if(impute=="mean"){

        df[[v]][is.na(df[[v]])] <-
          mean(
            df[[v]],
            na.rm=TRUE
          )

      }

      if(impute == "mode"){

        mode_val <- names(
          sort(table(df[[v]]), decreasing = TRUE)
        )[1]

        # preserve type
        if(is.numeric(df[[v]])) {
          mode_val <- as.numeric(mode_val)
        }

        df[[v]][is.na(df[[v]])] <- mode_val
      }

    }

  }

  # if(!include_na){
  #
  #   df <- tidyr::drop_na(df)
  #
  # }

  #############################
  # create x position
  #############################

  # df <- df %>%
  #
  #   arrange(
  #     day,
  #     beep
  #   ) %>%
  #
  #   mutate(
  #
  #     plot_x =
  #
  #       (day-1)*beeps_per_day +
  #
  #       beep
  #
  #   )

  #print(df)

  df[variables] <- lapply(df[variables], as.numeric)

  full_grid <- expand.grid(
    day = 1:expected_days,
    beep = 1:beeps_per_day
  )

  full_grid <- full_grid %>%
    mutate(plot_x = (day - 1) * beeps_per_day + beep)

  df <- full_grid %>%
    left_join(df, by = c("day", "beep"))

  df <- df %>%
    arrange(plot_x)

  #print(df)

  #############################
  # reshape
  #############################



  # long_df <-
  #
  #   pivot_longer(
  #     df,
  #
  #     cols =
  #       all_of(variables),
  #
  #     names_to =
  #       "variable",
  #
  #     values_to =
  #       "value"
  #
  #   )
  long_df <- df %>%
    pivot_longer(
      cols = starts_with("var_"),
      names_to = "variable",
      values_to = "value"
    )

  #print(long_df)

  #############################
  # separator lines
  #############################

  day_lines <-

    seq(

      beeps_per_day+.5,

      max(long_df$plot_x),

      by=
        beeps_per_day

    )

  #############################
  # plot
  #############################

  p <-

    ggplot(

      long_df,

      aes(

        x=plot_x,

        y=value,

        color=variable

      )

    )+

    geom_line()+

    geom_point()+

    geom_vline(

      xintercept=
        day_lines,

      alpha=.15

    )+
    ylab("Value")+
    xlab("Time")

  #############################
  # trend
  #############################

  if(add_trend){

    p <- p +

      geom_smooth(

        method=
          trend_type,
        se=FALSE,
        linetype="solid"

      )

  }

  #############################
  # repeat beep labels
  #############################

  breaks <- sort(
    unique(
      long_df$plot_x
    )
  )

  labels <-

    rep(

      1:beeps_per_day,

      length.out=
        length(
          breaks
        )

    )

  p <-

    p +

    scale_x_continuous(

      breaks=
        breaks,

      labels=
        labels

    )

  #############################
  # y scaling
  #############################

  p <-

    p +

    coord_cartesian(

      ylim=c(

        min(
          long_df$value,
          na.rm=TRUE
        ),
        # if(all(is.na(long_df$value))) return(ggplot() + theme_void()),

        max(
          long_df$value,
          na.rm=TRUE
        )

      )

    )

  #############################
  # themes
  #############################

  p <-

    switch(

      theme_choice,

      minimal=
        p+
        theme_minimal(),

      classic=
        p+
        theme_classic(),

      bw=
        p+
        theme_bw(),

      p

    )

  if(!is.null(palette)){

    p <- p +

      scale_color_manual(
        values=palette
      )

  }

  return(p)

}










reconstruct_data <- function(df, missing_df){

  library(dplyr)

  # if nothing missing
  if(nrow(missing_df) == 0){
    return(df)
  }

  # 1. Standardise missing_df column names
  missing_rows <- missing_df %>%
    rename(
      day  = days,
      beep = beeps
    ) %>%
    mutate(
      time = NA
    )

  # 2. Ensure same column structure as df
  # (add missing variable columns as NA)
  for(col in setdiff(names(df), names(missing_rows))){

    missing_rows[[col]] <- NA

  }

  # 3. Reorder columns to match df exactly
  missing_rows <- missing_rows[, names(df)]

  # 4. Bind together
  full_df <- bind_rows(df, missing_rows)

  # 5. Arrange properly
  full_df %>%
    arrange(id, day, beep)
}

