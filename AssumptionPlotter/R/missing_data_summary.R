#' @importFrom dplyr group_by summarise desc slice_head slice_tail


rank_participants <- function(df, show = 5){

  keep_cols <- c("id", "missing")
  df <- df[,keep_cols]

  df <- df %>%
    dplyr::group_by(id) %>%
    dplyr::summarise(
      missing_sum = sum(missing, na.rm = TRUE),
      missing_prop = mean(missing, na.rm = TRUE)
    ) %>%
    arrange(desc(missing_sum))

  if(show > nrow(df)){
    stop("Selected rows exceed number of participants")
  }

  most <- df %>%
    slice_head(n = show)

  least <- df %>%
    slice_tail(n = show) %>%
    arrange(missing_sum)

  rank_df <- data.frame(
    "ID_most" = as.character(most$id),
    "sum_most" = most$missing_sum,
    "prop_most" = paste0(round(most$missing_prop*100),"%"),
    "ID_least" = as.character(least$id),
    "sum_least" = least$missing_sum,
    "prop_least" = paste0(round(least$missing_prop*100),"%")
  )

  colnames(rank_df) <- c("ID most:",
                         "Sum",
                         "Percent",
                         "ID least:",
                         "Sum",
                         "Percent")

  return(rank_df)

}


