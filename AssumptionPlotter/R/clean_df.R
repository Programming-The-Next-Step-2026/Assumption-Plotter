#' Edit dataset to fit plotting
#'
#' @details
#' This function edits data files (from openESM). Technically,
#' the openesm::get_data function should read the files. However,
#' because the function fails to connect to zenodo, some datasets have been
#' manually saved in the package. To make the plotting smooth, this function
#' cleans the files further for analysis. To load additional datasets, go to the
#' dedicated zenodo webpage from openESM, copy the link for the dataset, and
#' paste it in the app (in the data tab under the option "paste link"). You will
#' also need to include some additional information from the dedicated openESM
#' page. If the format is correct, the analysis should still work. Make sure to
#' NOT pick the raw data. You can also add your own df as long as it is a csv
#' and the columns have the correct names.
#' The function also adds a column indicating whether a beep has been missed.
#' @param df The data frame.
#' @param id_col Provide the name of the id column
#' @param day_col Name of day column.
#' @param exp_day Expected days of the study.
#' @param beep_col Name of beep column.
#' @param exp_beep Expected beeps per day.
#' @param variables A vector containing the names of all columns to be analysed.
#' Each variable must be within quotation marks.
#' @import dplyr
#' @return Data file with all possible days and beeps and with a column indicating
#' whether a beep was missed.
#' @export
#' @examples
#' \dontrun{
#'
#' "menghini_2023_orig" <- readr::read_tsv("https://zenodo.org/records/17347538/files/0022_menghini_ts.tsv?download=1")
#' names <- colnames(menghini_2023_orig)[c(9:17,22:28)]
#'
#' menghini_2023 <- clean_df(
#'   df = menghini_2023_orig,
#'   id_col = "id",
#'   day_col = "day",
#'   exp_day = 3,
#'   beep_col = "beep",
#'   exp_beep = 7,
#'   variables = names
#' )
#' }


clean_df <- function(df,
                     id_col = "id",
                     day_col = "day",
                     exp_day,
                     beep_col = "beep",
                     exp_beep,
                     variables){

  # Remove any rows where id, day, or beep is missing a value
  df <- df %>%
    select(any_of(c(id_col, day_col, beep_col, variables))) %>%
    filter(
      !is.na(.data[[id_col]]),
      !is.na(.data[[day_col]]),
      !is.na(.data[[beep_col]])
    )

  # Only select defined variables
  df <- df %>%
    select(any_of(c(id_col, day_col, beep_col, variables)))


  # Change variable names incase original had different one
  df_std <- df %>%
    rename(
      id = all_of(id_col),
      day = all_of(day_col),
      beep = all_of(beep_col)
    )


  # Impute missing day x beep combinations with NA's
  new_df <- df_std %>%
    complete(
      id,
      day = 1:exp_day,
      beep = 1:exp_beep
    ) %>%
    left_join(df_std, by = c("id", "day", "beep", variables))


  # create variable that indicates whether a row has NA's
  new_df <- new_df %>%
    mutate(
      missing = if_any(all_of(variables), is.na)
    )


  # order data according to first all participant then days then beeps
  new_df <- new_df %>%
    arrange(id, day, beep) %>%
    relocate(missing, .after = beep)

  return(new_df)
}
