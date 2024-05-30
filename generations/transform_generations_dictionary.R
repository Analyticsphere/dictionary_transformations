library(dplyr)
library(readxl)
library(writexl)
library(janitor)
library(stringr)

#' Transform DataFrame by Reconfiguring and Renaming Columns
#'
#' This function reads a dictionary data frame from a given input path, 
#' reconfigures the "Format" and "Value" entries, removes empty rows, 
#' renames the columns according to specified conventions, and writes 
#' the transformed data frame to the specified output path.
#'
#' @param input_path A string specifying the path to the input file (.csv or .xlsx).
#' @param output_path A string specifying the path to the output file (.csv or .xlsx).
#' @return Writes the transformed data frame to the specified output path.
#' @examples
#' \dontrun{
#' transform_generations_dictionary("input.xlsx", "output.xlsx")
#' transform_generations_dictionary("input.csv", "output.csv")
#' }
#' @import dplyr
#' @import readxl
#' @import writexl
#' @import janitor
#' @import stringr
#' @export
transform_generations_dictionary <- function(input_path, output_path) {
  # Determine file extension
  input_extension <- tools::file_ext(input_path)
  output_extension <- tools::file_ext(output_path)
  
  # [1] Load dictionary data frame -----------------------------------------------
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
  
  # Function to clean column names and make them uppercase
  clean_column_names <- function(names) {
    names <- str_to_upper(str_trim(names))
    return(names)
  }
  
  # Clean column names
  colnames(df) <- clean_column_names(colnames(df))
  
  # [2] Reconfigure "Format" and "Value" Entries ---------------------------------
  # Add `VALUE` and `FORMAT` columns with placeholders
  df$VALUE  <- ""
  df$FORMAT <- ""
  
  # Reorder columns by specifying the order of column names
  df <- df[, c("FILENAME", "VARNAME", "VALUE", "FORMAT", "DESCRIPTION", 
               "Q_DERIVED_FROM", "LABEL", "NOTES")]
  
  # Get list of all rows for which "VALUE" and "FORMAT" are found in the VARNAME 
  # and DESCRIPTION columns, respectively
  index_value_format <- which(df$VARNAME == "VALUE" & df$DESCRIPTION == "FORMAT")
  
  for (i in seq_along(index_value_format)) {
    
    # Define indices of each bit
    idx_header       <- index_value_format[i] 
    idx_end_of_entry <- ifelse(i + 1 <= length(index_value_format), 
                               index_value_format[i + 1] - 2, 
                               nrow(df))
    idx_values       <- seq(idx_header + 1, idx_end_of_entry)   
    
    # Grab "VALUE" and "FORMAT" values
    value_array  <- df$VARNAME[idx_values]
    format_array <- df$DESCRIPTION[idx_values]
    
    # Remove "VALUE" and "FORMAT" headers and values from original 
    # position in spreadsheet
    df$VARNAME[idx_values]     <- ""
    df$DESCRIPTION[idx_values] <- ""
    df$VARNAME[idx_header]     <- ""
    df$DESCRIPTION[idx_header] <- ""
    
    # Put the "VALUE" and "FORMAT" values back into column
    idx_values_new <- idx_values - 2
    df$VALUE[idx_values_new]  <- value_array
    df$FORMAT[idx_values_new] <- format_array
  }
  
  # [3] Remove empty rows --------------------------------------------------------
  # Function to check if a row is empty (all NA, NULL, or whitespace)
  is_row_empty <- function(row) {
    all(is.na(row) | is.null(row) | trimws(row) == "")
  }
  
  # Apply the function to each row
  empty_rows <- apply(df, 1, is_row_empty)
  
  # Add the empty_row column
  df <- cbind(df, empty_row = empty_rows)
  
  # Remove the empty rows using dplyr
  df <- df %>% filter(!empty_row) %>% select(-empty_row)
  
  # [4] Replace NAs with empty strings -------------------------------------------
  df[is.na(df)] <- ""
  
  # [5] Rename columns to PRIMARY_KEY, PRIMARY_CID, etc --------------------------
  df <- df %>% 
    mutate(
      PRIMARY_KEY          = FILENAME,
      PRIMARY_CID          = "",
      SECONDARY_KEY        = "",
      SECONDARY_CID        = "",
      QUESTION_KEY         = "",
      QUESTION_CID         = "",
      QUESTION_LABEL       = LABEL,
      QUESTION_NAME        = VARNAME,
      QUESTION_DESCRIPTION = DESCRIPTION,
      RESPONSE_KEY         = FORMAT,
      RESPONSE_CID         = "",
      RESPONSE_VALUE       = VALUE,
      QUESTION_DERIVATION  = Q_DERIVED_FROM,
      QUESTION_NOTES       = NOTES
    ) %>%
    select(-c(FILENAME, VARNAME, DESCRIPTION, VALUE, FORMAT, Q_DERIVED_FROM, LABEL, NOTES))
  
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

# Example usage
input_path <- "generations/raw_generations_dictionary.xlsx"  # or .csv
output_path <- "generations/transformed_generations_dictionary.xlsx"  # or .csv
df <- transform_generations_dictionary(input_path, output_path)
