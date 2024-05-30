
# Dictionary Transformation Repository

This repository contains scripts and data for transforming various dictionaries into standardized formats. Each subfolder within the repository corresponds to a different dictionary and contains the necessary raw data, transformation scripts, and the resulting transformed data.

## Overview

Each subfolder within this repository contains:

1. **Raw Dictionary Files**: The original dictionary data in both CSV and XLSX formats.
2. **Transformation Script**: An R script that performs the necessary transformations to convert the raw dictionary into the standardized format.
3. **Transformed Dictionary**: The resulting transformed dictionary data after running the transformation script.

## Requirements

- R
- R Packages: `dplyr`, `readxl`, `writexl`, `janitor`, `stringr`

## Repository Structure

```
.
├── README.md
├── brcpp
│   ├── README.md
│   ├── raw_brcpp_dictionary.csv
│   ├── raw_brcpp_dictionary.xlsx
│   └── transform_brcpp_dictionary.R
├── ghana
│   ├── README.md
│   ├── raw_ghana_dictionary.csv
│   ├── raw_ghana_dictionary.xlsx
│   ├── transform_ghana_dictionary.R
│   ├── transformed_ghana_dictionary.xlsx
│   └── transformed_ghana_dictionary.xlsx.xlsx
├── plco
│   ├── README.md
│   ├── raw_plco_dictionary.csv
│   ├── raw_plco_dictionary.xlsx
│   └── transform_plco_dictionary.R
└── generations
    ├── README.md
    ├── raw_generations_dictionary.csv
    ├── raw_generations_dictionary.xlsx
    ├── transform_generations_dictionary.R
    └── transformed_generations_dictionary.xlsx
```
