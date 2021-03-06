# HES pipeline

Open-source R pipeline to clean and process patient-level Hospital Episode 
Statistics (HES) & ONS Civil Registrations data, with the aim to produce 
analysis-ready datasets for a defined programme of analyses.

#### Project Status: Development

## Project Description

[Hospital Episode Statistics (HES)](https://digital.nhs.uk/data-and-information/data-tools-and-services/data-services/hospital-episode-statistics) is a database containing 
details of all hosptial admissions, A&E attendances and outpatient appointments 
at NHS hospitals in England.

Before it can be used for analysis, HES data requires cleaning (e.g. duplicate 
removal) and quality control as well as additional derived variables and tables. 
The complexity of HES. the large number of variables and the size of the data 
sets can makes this a challenging task.

This cleaning and processing workflow will be designed to ensure that the HES
data is processed consistently and reproducably, and that every one of our
pre-approved analysis projects work with the cleaned data sets.

## Data Source

We are planning to use HES data linked to Civil Registrations (deaths) covering
the last 10 years as well as quarterly data updated for the next three years. 
Our data application has been approved by the NHS Digital [Data Access Request 
Service (DARS)](https://digital.nhs.uk/services/data-access-request-service-dars) and development of this pipeline has now 
commenced.

The data will be accessed in The Health Foundation's Secure Data Environment; a 
secure data analysis facility (accredited with the ISO27001 information security
standard, and recognised for the NHS Digital Data Security and Protection
Toolkit). No information that could directly identify a patient or other 
individual will be used.

## How does it work?

As the data prepared in this pipeline is not publically available, the code 
cannot be used to replicate the database. However, with modifications the code 
will be able to be used on other patient-level HES extracts to prepare the 
datasets for analysis. For more information on how the pipeline works please 
refer to the [process document](doc/process.md).

## Installation

Download the HES Pipeline by either downloading or 
[cloning the repo](https://github.com/HFAnalyticsLab/HES_pipeline.git).

## Requirements

The HES pipeline was built under R version 3.6.2 -- "Dark and Stormy Night".

The following R packages are required to run the HES pipeline:
*  data.table (1.12.2)
*  tidyverse (1.2.1)
*  DBI (1.0.0)
*  plyr (1.8.4)
*  tidylog (0.2.0)
*  furrr (0.1.0)
*  logger (0.1)

## Usage

Currently the pipeline is designed to run in an RStudio session. From the R
console compile the code:

`> source("pipeline.R")`

Then call `pipeline()`, providing as arguments a path to the data directory, a 
path to a directory for an SQLite database, a vector of dataset codes, a path 
to a csv with expected columns, inlcuding dataset codes and data types, an 
optional vector of the number of rows to be read at a time per datasets, and,
if required,and a boolean to enable coercion. The data will be processed and 
written to the database. N.B. This is a slow process and takes up a fair amount 
of memory to run.

Example run:

`> pipeline(data_path = "/home/user/raw-data/", 
            database_path = "/home/user/database-dir/", 
            data_set_codes = c("FOO", "BAR"), 
            chunk_sizes = c(2000000, 5000000), 
            expected_headers_file = "/home/user/expected_columns.csv", 
            coerce = TRUE)`

## License

This project is licensed under the [MIT License](https://github.com/HFAnalyticsLab/HES_pipeline/blob/master/LICENSE)
