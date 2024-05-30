# Generations Dictionary Transformation

This script transforms the "Generations Dictionary" into the "Connect Dictionary Format".
It reads a dictionary data frame from a given input path (CSV or XLSX), reconfigures the "Format" and "Value" entries, removes empty rows, renames the columns according to specified conventions, and writes the transformed data frame to the specified output path.

## Overview

The script performs the following transformations:

1.  **Standardizes Column Names**: Converts column names to uppercase and trims whitespace.

2.  **Reconfigures "Format" and "Value" Entries**:

    1.  Adds `VALUE` and `FORMAT` columns with placeholders.

    2.  Reorders columns by specifying the order of column names.

    3.  Splits and relocates entries from `VARNAME` and `DESCRIPTION` columns into `VALUE` and `FORMAT` columns.

3.  **Removes Empty Rows**: Checks and removes rows where all entries are `NA`, `NULL`, or whitespace.

4.  **Replaces NAs with Empty Strings**: Ensures that no NAs are carried over to the final dataframe by replacing all NAs with empty strings.

5.  **Renames Columns**: Renames columns to conform to the "Connect Dictionary Format" and drops unnecessary columns.

## Specific Transformations

-   **Input File Reading**: Reads the input file (CSV or XLSX) and loads it into a data frame.
-   **Column Name Standardization**:
    -   Converts all column names to uppercase.
    -   Trims any leading or trailing whitespace.
-   **Reconfiguring Entries**:
    -   Adds `VALUE` and `FORMAT` columns initialized with empty strings.
    -   Reorders columns to place `VALUE` and `FORMAT` in the specified positions.
    -   Identifies rows where `VARNAME` is "VALUE" and `DESCRIPTION` is "FORMAT", and relocates subsequent entries from `VARNAME` and `DESCRIPTION` into `VALUE` and `FORMAT`.
-   **Removing Empty Rows**:
    -   Defines a function to check if a row is empty.
    -   Filters out rows identified as empty.
-   **Replacing NAs with Empty Strings**:
    -   Explicitly replaces all NAs in the data frame with empty strings.
-   **Renaming and Dropping Columns**:
    -   Renames columns according to the "Connect Dictionary Format":
        -   `PRIMARY_KEY` from `FILENAME`
        -   `QUESTION_LABEL` from `LABEL`
        -   `QUESTION_NAME` from `VARNAME`
        -   `QUESTION_DESCRIPTION` from `DESCRIPTION`
        -   `RESPONSE_KEY` from `FORMAT`
        -   `RESPONSE_VALUE` from `VALUE`
        -   `QUESTION_DERIVATION` from `Q_DERIVED_FROM`
        -   `QUESTION_NOTES` from `NOTES`
    -   Drops the original columns (`FILENAME`, `VARNAME`, `DESCRIPTION`, `VALUE`, `FORMAT`, `Q_DERIVED_FROM`, `LABEL`, `NOTES`).

## Usage

### Requirements

-   R
-   R Packages: `dplyr`, `readxl`, `writexl`, `janitor`, `stringr`

### Example Usage

``` r
library(dplyr)
library(readxl)
library(writexl)
library(janitor)
library(stringr)

input_path <- "generations/raw_generations_dictionary.xlsx"  # or .csv
output_path <- "generations/transformed_generations_dictionary.xlsx"  # or .csv
df <- transform_generations_dictionary(input_path, output_path)
```
