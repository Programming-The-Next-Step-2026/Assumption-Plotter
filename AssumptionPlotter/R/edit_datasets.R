#' Edit dataset to fit plotting
#'
#' @details
#' This function edits the data files (from openESM). Technically, the openesm::get_data function should read the files. However, because the function fails to connect to zenodo, some datasets have been manually saved in the package. To make the plotting smooth, this function cleans the files further for analysis. Load additional datasets, go to the dedicated zenodo webpage from openESM, copy the link for the dataset, and add the dataset manually in the app. If the format is correct, the analysis should still work. Make sure to NOT pick the raw data.
#' @param df The data frame. Note that the df should be in wide format.
#' @param id_col Provide the index for which column the participant ID is in. If there is no participant ID (the data frame is for only one participant), write "none".
#' @param day_col Index number for the column containing the days.
#' @param exp_day Expected days of the study.
#' @param beep_col Index number of the column containing the beeps for the day.
#' @param exp_beep Expected beeps per day.
#' @param variables A vector containing the names of all columns to be analysed. Each variable must be within quotation marks.
#' @import dplyr
#' @returns Creates a data file in the data folder of the package.
#' @export
#' @examples
#' \dontrun{
#'
#' "menghini_2023_orig" <- readr::read_tsv("https://zenodo.org/records/17347538/files/0022_menghini_ts.tsv?download=1")
#' names <- colnames(menghini_2023_orig)[c(9:17,22:28)]
#' menghini <- edit_df(df = menghini_2023_orig, id_col = 1, day_col = 3, exp_day = 3, beep_col = 5, exp_beep = 7, variables = names)
#' menghini_2023 <- menghini[[1]]
#' usethis::use_data(menghini_2023)
#' missing_menghini_2023 <- menghini[[2]]
#' usethis::use_data(missing_menghini_2023)
#' }

edit_df <- function(df, id_col, day_col, exp_day, beep_col, exp_beep, variables){

  time <- numeric()

  missing <- data.frame(
    id = c(),
    beeps = numeric(),
    days = numeric()
  )

  participants <- unique(df[[id_col]])

  for(i in 1:length(participants)){
    sub_df <- df[df[[id_col]]==participants[i],]

    expected_pairs <- expand.grid(
      beeps = 1:exp_beep,
      days = 1:exp_day
    )

    actual_pairs <- data.frame(
      beeps = sub_df[[beep_col]],
      days = sub_df[[day_col]]
    )
    miss <- anti_join(expected_pairs, actual_pairs, by = c("beeps", "days"))

    add <- data.frame(
      id = rep(participants[i], times=nrow(miss)),
      days = miss$days,
      beeps = miss$beeps
    )

    missing <- rbind(missing, add)

    time <- c(time,1:nrow(sub_df))

  }


  new_df <- data.frame(
    ID = df[,id_col],
    time = time,
    day = df[,day_col],
    beep = df[,beep_col]
  )

  new_var <- paste0("var_", variables)

  for(i in 1:length(new_var)){
    new_df[new_var[i]] <- df[[variables[i]]]
  }


  dfs <- list(new_df, missing)
  return(dfs)

}

