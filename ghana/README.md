
# Ghana Dictionary Transformation

This script transforms the "Ghana Dictionary" into a standardized format. It reads a dictionary data frame from a given input path (CSV or XLSX), reconfigures the "Format" and "Value" entries, splits multi-line entries, removes empty rows, renames the columns according to specified conventions, and writes the transformed data frame to the specified output path.

## Overview

The script performs the following transformations:
  1. **Standardizes Column Names**: Converts column names to uppercase and trims whitespace.
  2. **Splits Multi-line Entries**: Splits entries in the `format_value` column into multiple rows based on newline characters.
  3. **Reconfigures "Format" and "Value" Entries**: 
    - Splits and relocates entries from `format_value` into `RESPONSE_FORMAT` and `RESPONSE_VALUE` columns.
  4. **Removes Empty Rows**: Checks and removes rows where all entries are `NA`, `NULL`, or whitespace.
  5. **Detects and Handles Rows with Only First Column Filled**: Moves the value in the first column to `PRIMARY_KEY` of the subsequent row and removes the detected rows.
  6. **Renames Columns**: Renames columns to conform to a standardized format and drops unnecessary columns.

## Specific Transformations

- **Input File Reading**: Reads the input file (CSV or XLSX) and loads it into a data frame.
- **Column Name Standardization**: 
    - Converts all column names to uppercase.
    - Trims any leading or trailing whitespace.
- **Splitting Multi-line Entries**:
    - Splits entries in the `format_value` column into multiple rows based on newline characters.
- **Reconfiguring Entries**:
    - Splits entries from `format_value` into `RESPONSE_FORMAT` and `RESPONSE_VALUE` using various delimiters.
- **Removing Empty Rows**: 
    - Defines a function to check if a row is empty.
    - Filters out rows identified as empty.
- **Detecting and Handling Rows with Only First Column Filled**: 
    - Moves the value in the first column to `PRIMARY_KEY` of the subsequent row.
    - Removes the detected rows.
- **Replacing NAs with Empty Strings**: 
    - Explicitly replaces all NAs in the data frame with empty strings.
- **Renaming and Dropping Columns**:
    - Renames columns to conform to a standardized format:
        - `PRIMARY_KEY`, `PRIMARY_CID`
        - `SECONDARY_KEY`, `SECONDARY_CID`
        - `QUESTION_KEY`, `QUESTION_CID`
        - `QUESTION_SOURCE`, `QUESTION_NAME`
        - `RESPONSE_KEY`, `RESPONSE_CID`
        - `RESPONSE_TYPE`, `RESPONSE_LENGTH`
        - `RESPONSE_FORMAT`, `RESPONSE_VALUE`
        - `QUESTION_DERIVATION`, `QUESTION_CORE`
    - Drops the original columns.

## Usage

### Requirements

- R
- R Packages: `dplyr`, `readxl`, `writexl`, `janitor`, `stringr`

### Example Usage

```r
library(dplyr)
library(readxl)
library(writexl)
library(janitor)
library(stringr)

input_path <- "ghana/raw_ghana_dictionary.xlsx"  # or .csv
output_path <- "ghana/transformed_ghana_dictionary.xlsx"  # or .csv
df <- transform_ghana_dicitonary(input_path, output_path)
```
