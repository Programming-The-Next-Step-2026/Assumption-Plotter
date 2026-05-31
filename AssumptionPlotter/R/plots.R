#' AssumptionPlotter Plot
#'
#' @details
#' This function creates the plots in the Plots tab of AssumptionPlotter
#' @param df Selected dataset.
#' @param participant Participant to be plotted.
#' @param variables All variables to be plotted.
#' @param expected_days Expected days of the study
#' @param beeps_per_day Expected beeps per day
#' @param include_day Option to include day labels.
#' @param include_day_line Option to include day lines.
#' @param impute Method for imputing NA's.
#' @param add_trend Include a regression line showing the trend in the data.
#' @param trend_type Type of trend line to be passed to geom_smooth().
#' @param theme_choice Decide what theme the plot should have.
#' @param palette Chooses either no palette or custom.
#' @param palette_options Palette options. Any of grDevices::hcl.pals().
#' @param text_font What text font the plot should have.
#' @param axis_text_size Adjust the text size of the plot's axes.
#' @param legend_text_size Adjust the text size of the legend.
#' @return Interactive plot in AssumptionPlotter.
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @import grDevices
#' @export
#' @examples
#' \dontrun{
#' assumption_plot(
#'   df,
#'   participant,
#'   variables,
#'   expected_days,
#'   beeps_per_day,
#'   include_day = TRUE,
#'   include_day_line = TRUE,
#'   impute = c("none", "mean", "mode"),
#'   add_trend = FALSE,
#'   trend_type = c("lm", "loess"),
#'   theme_choice = c("classic", "minimal", "bw", "dark"),
#'   palette = c("none", "custom"),
#'   palette_option = "Reds",
#'   text_font = c("sans", "serif", "mono"),
#'   axis_text_size = 12,
#'   legend_text_size = 12
#' )
#' }
#'

assumption_plot <- function(
    df,
    participant,
    variables,
    expected_days,
    beeps_per_day,
    include_day = TRUE,
    include_day_line = TRUE,
    impute = "none",
    add_trend = FALSE,
    trend_type = "lm",
    theme_choice = "classic",
    palette = "none",
    palette_option = "Reds",
    text_font = "sans",
    axis_text_size = 12,
    legend_text_size = 12){

  # Create error message for when all variables are deselected

  if(length(variables)==0){
    stop("The plot cannot render when no variables are selected")
  }

  # Subset data
  ## In the future it would be cool to implement the option to plot multiple
  ## participants at once (so you can compare them).
  df <- df %>%
    filter(id == participant)


  # Keep relevant variables
  keep_cols <- c(
    "id",
    "day",
    "beep",
    "missing",
    variables
  )

  df <- df[,keep_cols]


  # Specify imputation method (per variable)
  if(impute!="none"){

    for(v in variables){

      if(impute=="mean"){

        df[[v]][is.na(df[[v]])] <-mean(df[[v]],na.rm=TRUE)
      }

      if(impute == "mode"){

        mode_val <- names(sort(table(df[[v]]), decreasing = TRUE))[1]

        if(is.numeric(df[[v]])) {
          mode_val <- as.numeric(mode_val)
        }

        df[[v]][is.na(df[[v]])] <- mode_val
      }

    }

  }


  # Ensure that all variables are numeric
  df[variables] <- lapply(df[variables], as.numeric)


  # Create plotting index
  df <- df %>%
    mutate(
      plot_x = (day - 1) * beeps_per_day + beep
    ) %>%
    arrange(plot_x)


  # Make df long format (required for plotting with ggplot)
  long_df <- df %>%
    pivot_longer(
      cols = -c(id, day, beep, missing, plot_x),
      names_to = "Variables", # Risky name since name is same as argument
      values_to = "value"
    )


  # Create location of vertical day lines on the x-axis
  day_lines <- seq(beeps_per_day+.5, # Make line appear between last and first day
                  max(long_df$plot_x),
                  by = beeps_per_day)

  # Create location of days
  ## Note that this is not ideal currently. Might make sense to define max days
  ## and beeps by participant. Whether to plot predetermined expected days and
  ## beeps for all participants or a specific one could be plot argument.

  day_labels <- data.frame(
    day = 1:expected_days,
    x = (0:(expected_days - 1)) * beeps_per_day +
      (beeps_per_day + 1) / 2,
    label = paste("Day", 1:expected_days)
  )


  # Initialize plot
  p <- ggplot2::ggplot(long_df, aes(x = plot_x, y = value, color = Variables))+
    geom_line()+
    geom_point()+
    ylab("Value")+
    xlab("Time")


  # Option to include day labels
  if(include_day){
    p <- p +
      geom_label(
        data = day_labels,
        aes(x = x, y = Inf, label = label),
        inherit.aes = FALSE,
        vjust = 1.5,
        size = 4,
        alpha = .8
      )
  }


  # Option to include lines separating days
  if(include_day_line){
    p <- p +
      geom_vline(xintercept = day_lines, alpha = .15, linetype = "dashed")
  }

  # Option to add a trend line
  if(add_trend){

    p <- p +
      geom_smooth(method = trend_type,
                  se = FALSE)
  }


  # Create x-axis tick labels
  breaks <- sort(unique(long_df$plot_x))

  labels <-rep(1:beeps_per_day, length.out = length(breaks))

  ## Edit x-axis tick labels
  p <- p +
    scale_x_continuous(breaks = breaks, labels = labels)


  # Ensure that y-lim is large enough to show all data points of all variables
  p <- p +
    coord_cartesian(ylim = c(
      min(long_df$value, na.rm = TRUE),
      max(long_df$value, na.rm = TRUE)
    ))


  # Switch themes
  p <- switch(theme_choice,
              minimal = p + theme_minimal(base_family = text_font),
              classic = p + theme_classic(base_family = text_font),
              bw = p + theme_bw(base_family = text_font),
              dark = p + theme_dark(base_family = text_font),
              p)


  # Switch the colors of the plot

  ## Get number of variables
  nr_var <- length(variables)

  p <- switch(palette,
              none = p + scale_color_hue(),
              custom = p + scale_color_manual(values =
                                                grDevices::hcl.colors(nr_var, palette_option,
                                                                      rev=TRUE)),
              p)


  # Edit font sizes

  p <- p +
    theme(
      text = element_text(size = axis_text_size),
      axis.title = element_text(size = axis_text_size+2),
      axis.text = element_text(size = axis_text_size),
      legend.title = element_text(size = legend_text_size+2),
      legend.text = element_text(size = legend_text_size)
    )



  # Return plot
  return(p)

}





#' Pie or Bar Chart of Missing Data
#'
#' @details
#' This function creates a piechart of all missing data points
#' @param df Selected dataset.
#' @param participant Participant being plotted
#' @param type Whether it should return a pie or bar chart.
#' @param plot_all Whether the function should generate a plot for everyone or only.
#' @param text_font Font style.
#' @param axis_text_size Text sixe of axes.
#' @param legend_text_size Text size of legend.
#' @param theme_choice The bar chart has the same theme as the assumption plot
#' the participant
#' @return A pie or bar chart showing the ratio of missing values for either a
#' participant or the entire dataset.
#' @import ggplot2
#' @import dplyr
#' @import tidyr
#' @export
#' @examples
#' \dontrun{
#' pie_bar_chart(
#'   df,
#'   participant,
#'   type = c("pie", "bar"),
#'   plot_all = FALSE,
#'   text_font = c("sans", "serif", "mono"),
#'   axis_text_size = 12,
#'   legend_text_size = 12,
#'   theme_choice = c("classic", "minimal", "bw", "void")
#'   )
#' }
#'
#'


pie_bar_chart <- function(df,
                      participant,
                      type = "pie",
                      plot_all = FALSE,
                      text_font = "sans",
                      axis_text_size = 12,
                      legend_text_size = 12,
                      theme_choice = "classic"){

  # Subset data if we are not plotting everyone
  if(!plot_all){
    df <- df %>%
      filter(id == participant)
  }else{
    df <- df
  }


  # Keep relevant variables
  missing <- df$missing


  # Make df
  plot_df <- data.frame(
    Missing = missing
  )

  plot_df <- df %>%
    mutate(Status = ifelse(missing, "Missing", "Included")) %>%
    dplyr::count(Status)


  # Create different types of plots
  if(type == "pie"){

    p <-
      ggplot(plot_df, aes(x = "", y = n, fill = Status)) +
      geom_bar(stat = "identity", width = 1) +
      coord_polar("y", start = 0)+
      scale_fill_manual(values =
                          c("Missing" = "red",
                            "Included" = "blue"))+
      theme_void(base_family = text_font)+
      theme(
        legend.title = element_text(size = legend_text_size+2),
        legend.text = element_text(size = legend_text_size)
      )
  } else if(type == "bar"){
    p <-
      ggplot(plot_df, aes(x = Status, y = n, fill = Status)) +
      geom_col() +
      xlab("Data points")+
      ylab("Count")+
      scale_fill_manual(values =
                          c("Missing" = "red",
                            "Included" = "blue"))


    # Change theme
    p <- switch(theme_choice,
                minimal = p + theme_minimal(base_family = text_font),
                classic = p + theme_classic(base_family = text_font),
                bw = p + theme_bw(base_family = text_font),
                void = p + theme_void(base_family = text_font),
                p)

    # Edit font size
    p <- p +
      theme(
        text = element_text(size = axis_text_size),
        axis.title = element_text(size = axis_text_size+2),
        axis.text = element_text(size = axis_text_size),
        legend.title = element_text(size = legend_text_size+2),
        legend.text = element_text(size = legend_text_size)
      )


  }

  return(p)

}


