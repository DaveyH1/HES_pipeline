library(tidyverse)
library(tidylog)
source("src/clean.R")

library(furrr)
plan(multiprocess)


# Derive column containing filename data was extracted from.
# Requires a dataframe and a filename as a string.
# Returns a modified dataframe.
derive_extract <- function(data, filename) {
  return(mutate(data, "FILENAME" = filename))
}


# Derive a column flagging missing data in another column.
# Requires a dataframe, a column to check for NAs and a new column 
# name, both as strings.
# Returns a modified dataframe.
derive_missing <- function(data, missing_col, new_col) {
  return(mutate_if_present(data, c(missing_col), 
                    funs(!! paste0(new_col) := ifelse(is.na(eval(parse(text=missing_col))), TRUE, FALSE))))
}


# Derive ETHNIC5 column, summarising patient ethnicity, if ETHNOS column present.
# Requires a dataframe.
# Returns a modifed dataframe.
derive_ethnicity <- function(data) {
  return(mutate_if_present(data, "ETHNOS", 
                    list(ETHNIC5 = 
                           ~case_when(ETHNOS == "A" |
                                       ETHNOS == "B" |
                                       ETHNOS == "C" ~ "White",
                                     ETHNOS == "D" |
                                       ETHNOS == "E" |
                                       ETHNOS == "F" |
                                       ETHNOS == "G" ~ "Mixed",
                                     ETHNOS == "H" |
                                       ETHNOS == "J" |
                                       ETHNOS == "K" |
                                       ETHNOS == "L" ~ "Asian/Asian British",
                                     ETHNOS == "M" |
                                       ETHNOS == "N" |
                                       ETHNOS == "P" ~ "Black/Black British",
                                     ETHNOS == "R" |
                                       ETHNOS == "S" ~ "Chinese/Other",
                                     is.na(ETHNOS) ~ "Unknown"))))
}


# Derive PROCODE3 column, as the first three letters of PROCODE, if present.
# Requires a dataframe.
# Returns a modified dataframe.
derive_procode3 <- function(data) {
  return(mutate_if_present(data, "PROCODE", list(PROCODE3 = ~substr(., 1, 3))))
}


# Derive ROWQUALITY column, by scoring for NAs in a selection of columns, if all present.
# Requires a dataframe and a column name or vector of column names as strings
# Returns a modifed dataframe.
derive_row_quality <- function(data, cols) {
  if(all(cols %in% names(data))) {
    mutate(data, ROWQUALITY = data %>%
             dplyr::select(one_of(cols)) %>%
             future_map(is.na) %>%
             future_pmap_dbl(sum))
  } else {
    data
  }
}

# Derives additional columns for all HES datasets.
# Requires a dataframe and a filename.
# Returns a modified dataframe.
derive_HES <- function(data, filename) {
  APC_cols <- c(c("ADMIMETH", "ADMISORC", "DISDEST", "DISMETH", "STARTAGE", "MAINSPEF",
                "TRETSPEF", "SITETRET", "OPERTN_01"),
                generate_numbered_headers("DIAG_", 14))
  AE_cols <- c(c("AEARRIVALMODE", "AEATTENDCAT", "AEATTENDDISP", "AEDEPTTYPE", 
                 "ARRIVALAGE", "ARRIVALTIME","CONCLTIME", "DEPTIME", "INITTIME"), 
               generate_numbered_headers("INVEST_", 12), 
               generate_numbered_headers("TREAT_", 12))
  OP_cols <- c("APPTAGE", "FIRSTATT", "OUTCOME", "PRIORITY", "REFSOURC", "SERVTYPE",
               "SITETRET", "STAFFTYP")
  return(data %>%
           derive_extract(filename) %>%
           derive_missing("ENCRYPTED_HESID", "ENCRYPTED_HESID_MISSING") %>%
           derive_missing("ARRIVALDATE", "ARRIVALDATE_MISSING") %>%
           derive_missing("ADMIDATE", "ADMIDATE_MISSING") %>%
           derive_missing("APPTDATE", "APPTDATE_MISSING") %>%
           derive_ethnicity() %>%
           derive_procode3() %>%
           derive_missing("PROCODE3", "PROCODE3_MISSING") %>%
           derive_row_quality(APC_cols) %>%
           derive_row_quality(AE_cols) %>%
           derive_row_quality(OP_cols))
}

