# 01_load.R — load raw data, define treatment/outcome/confounders,
# and write a cleaned data frame to data/derived/.
#
# Edit the CONFIG block when the instructor hands us the real dataset.

suppressPackageStartupMessages({
  library(dplyr)
})

# ---- CONFIG ---------------------------------------------------------------
DATA_PATH     <- "data/raw/nswdata_clean.csv"
TREATMENT     <- "trainning"   # binary 0/1 treatment indicator
OUTCOME       <- "earning78"   # post-treatment outcome
# Confounders to adjust for. Revisit this list with subject-matter reasoning
# in the report — don't just keep the placeholder set.
CONFOUNDERS   <- c("age", "education", "race", "married", "nodegree", "earning75")
DERIVED_PATH  <- "data/derived/analysis.csv"
# ---------------------------------------------------------------------------

dir.create("data/derived", showWarnings = FALSE, recursive = TRUE)

raw <- read.csv(DATA_PATH)

# Drop the unnamed row-index column produced by read.csv on this file.
raw <- raw[, !grepl("^X$|^X\\.1$|^$", names(raw))]
raw <- raw[, names(raw) != ""]

stopifnot(TREATMENT %in% names(raw), OUTCOME %in% names(raw))
stopifnot(all(CONFOUNDERS %in% names(raw)))

analysis <- raw |>
  mutate(
    treat = as.integer(.data[[TREATMENT]]),
    y     = as.numeric(.data[[OUTCOME]])
  ) |>
  select(treat, y, all_of(CONFOUNDERS))

stopifnot(all(analysis$treat %in% c(0, 1)))

write.csv(analysis, DERIVED_PATH, row.names = FALSE)

cat("Loaded", nrow(analysis), "rows.\n")
cat("Treated:", sum(analysis$treat == 1),
    "  Control:", sum(analysis$treat == 0), "\n")
