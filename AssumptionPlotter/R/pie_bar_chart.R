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

