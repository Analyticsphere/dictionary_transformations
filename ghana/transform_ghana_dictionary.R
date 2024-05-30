#' Transform a Data Dictionary
#'
#' This function reads a data dictionary from a specified input file (CSV or XLSX),
#' processes it by splitting format and value fields, reorders columns, and writes the
#' transformed dictionary to an output file (CSV or XLSX).
#'
#' @param input_path Path to the input file (CSV or XLSX).
#' @param output_path Path to the output file (CSV or XLSX).
#' @return A transformed data frame.
#' @examples
#' \dontrun{
#' transform_ghana_dictionary("input.xlsx", "output.xlsx")
#' transform_ghana_dictionary("input.csv", "output.csv")
#' }
#' @export
transform_ghana_dictionary <- function(input_path, output_path) {
  library(dplyr)
  library(readxl)
  library(writexl)
  library(janitor)
  library(stringr)
  library(tidyr)
  
  # Determine file extension
  input_extension <- tools::file_ext(input_path)
  output_extension <- tools::file_ext(output_path)
  
  # [1] Load dictionary data frame ---------------------------------------------
  # Read dictionary based on file extension
  if (input_extension == "csv") {
    df <- read.csv(input_path, stringsAsFactors = FALSE)
  } else if (input_extension == "xlsx") {
    df <- read_excel(input_path)
  } else {
    stop("Unsupported input file format. Please use .csv or .xlsx.")
  }
  
  # Standardize column names
  df <- df %>% clean_names()
  
  # [2] Split "format_value" field ----------------------------------------------
  # Function to check if the authors of the dictionary intended for no format to 
  # be given (Note: This is tricky and won't work for all cases! So this is a 
  # very conservative check)
  is_not_format_value <- function(x) {
    cleaned_x <- tolower(trimws(x))
    is.na(x) | cleaned_x == "no format"
  }
  
  # Function to split strings into format and value
  split_format_value <- function(x) {
    cleaned <- str_trim(x)
    if (str_detect(cleaned, "=")) {
      parts <- str_split(cleaned, "=", simplify = TRUE)
    } else if (str_detect(cleaned, "\\)")) {
      parts <- str_split(cleaned, "\\)", simplify = TRUE)
      parts[1] <- paste0(parts[1], ")")  # Add the closing parenthesis back to the format part
    } else {
      parts <- c("", cleaned)
    }
    parts <- str_trim(parts)  # Trim any whitespace from the split parts
    return(parts)
  }
  
  # Split the format_value into multiple rows based on newline characters
  df <- df %>%
    separate_rows(format_value, sep = "\n") %>%
    mutate(format_value = str_trim(format_value)) # Trim whitespace again
  
  # Apply the function to check validity and create new columns
  df <- df %>%
    rowwise() %>%
    mutate(
      parts = if_else(is_not_format_value(format_value), 
                      list(c("", format_value)), 
                      list(split_format_value(format_value)))
    ) %>%
    unnest_wider(parts, names_sep = "_") %>%
    rename(
      RESPONSE_FORMAT = parts_1, 
      RESPONSE_VALUE = parts_2
    ) %>%
    ungroup() %>% # Ungroup after row-wise operations
    select(-format_value)
  
  # [3] Detect rows where only the first column has an entry --------------------
  # Function to check if only the first column has an entry and the rest are empty or whitespace
  only_first_column_filled <- function(row) {
    !is.na(row[1]) && row[1] != "" && all(sapply(row[-1], function(x) is.na(x) || trimws(x) == ""))
  }
  
  # Get the indices of rows where only the first column has an entry
  indices_only_first_column_filled <- which(apply(df, 1, only_first_column_filled))
  
  # Create PRIMARY_KEY and PRIMARY_CID columns before moving values
  df <- df %>%
    mutate(PRIMARY_KEY = "", PRIMARY_CID = "")
  
  # Move the value to PRIMARY_KEY of the subsequent row and remove the detected rows
  for (index in indices_only_first_column_filled) {
    if (index < nrow(df)) {
      df$PRIMARY_KEY[index + 1] <- df[index, 1]
    }
  }
  
  # Remove the detected rows
  df <- df[-indices_only_first_column_filled, ]
  
  # Add new columns with blank values where appropriate
  df <- df %>% 
    mutate(
      SECONDARY_KEY            = data_type_by_category,
      SECONDARY_CID            = "",
      QUESTION_KEY             = question_text,
      QUESTION_CID             = "",
      QUESTION_SOURCE          = data_source, 
      QUESTION_NAME            = variable_name,
      RESPONSE_KEY             = "",
      RESPONSE_CID             = "",
      RESPONSE_TYPE            = variable_type,
      RESPONSE_LENGTH          = variable_length,
      QUESTION_DERIVATION      = derived_variable_macro_code,
      QUESTION_CORE            = core_variables_added_on_6_21_2019
    )
  
  # Reorder columns
  df <- df %>%
    select(PRIMARY_KEY, PRIMARY_CID, 
           SECONDARY_KEY, SECONDARY_CID, 
           RESPONSE_KEY, RESPONSE_CID, RESPONSE_TYPE, RESPONSE_LENGTH,
           RESPONSE_FORMAT, RESPONSE_VALUE,
           QUESTION_DERIVATION, 
           QUESTION_KEY, QUESTION_CID, 
           QUESTION_SOURCE, QUESTION_NAME, 
           QUESTION_CORE)
  
  # Write the transformed dataframe to the output path
  if (output_extension == "csv") {
    write.csv(df, output_path, row.names = FALSE)
  } else if (output_extension == "xlsx") {
    write_xlsx(df, output_path)
  } else {
    stop("Unsupported output file format. Please use .csv or .xlsx.")
  }
  
  return(df)
}

input_path  <- 'Ghana/raw_ghana_dictionary.csv'
output_path <- 'Ghana/transformed_ghana_dictionary.xlsx'
df <- transform_ghana_dictionary(input_path, output_path)
