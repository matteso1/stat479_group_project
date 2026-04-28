# 01_load.R — load NHEFS, define treatment / outcome / confounders, and write
# a cleaned data frame to data/derived/.
#
# Treatment: qsmk     = 1 if respondent quit smoking between 1971 and 1982
# Outcome:   wt82_71  = weight change in kg over the same window (1982 - 1971)
# Source:    NHEFS (NHANES I Epidemiologic Follow-up Study). The classic
#            running example in Hernán & Robins, "Causal Inference: What If".
#            Bundled in the causaldata R package as `nhefs_complete`. We
#            snapshot it to data/raw/ on first run for reproducibility.

suppressPackageStartupMessages({
  library(dplyr)
})

# ---- CONFIG ---------------------------------------------------------------
RAW_PATH      <- "data/raw/nhefs.csv"
TREATMENT     <- "qsmk"
OUTCOME       <- "wt82_71"
# Confounders: pre-treatment baseline characteristics measured in 1971,
# matching the standard adjustment set in Hernán & Robins ch. 12.
#   sex             0 = male, 1 = female
#   age             years at baseline (1971)
#   race            0 = white, 1 = black / other
#   education       5-level ordinal (less than HS up to college+)
#   smokeintensity  cigarettes per day at baseline
#   smokeyrs        years smoking at baseline
#   exercise        3-level ordinal (much / moderate / little)
#   active          3-level ordinal (very active / moderately / inactive)
#   wt71            baseline weight in kg
CONFOUNDERS   <- c("sex", "age", "race", "education",
                   "smokeintensity", "smokeyrs",
                   "exercise", "active", "wt71")
DERIVED_PATH  <- "data/derived/analysis.csv"
# ---------------------------------------------------------------------------

dir.create("data/raw",     showWarnings = FALSE, recursive = TRUE)
dir.create("data/derived", showWarnings = FALSE, recursive = TRUE)

# First-run snapshot from the causaldata package, then read from disk on
# subsequent runs so the pipeline doesn't depend on a network round-trip.
if (!file.exists(RAW_PATH)) {
  if (!requireNamespace("causaldata", quietly = TRUE)) {
    stop("Install once with: install.packages('causaldata')")
  }
  nhefs_complete <- NULL
  utils::data("nhefs_complete", package = "causaldata", envir = environment())
  write.csv(nhefs_complete, RAW_PATH, row.names = FALSE)
  cat("Snapshotted causaldata::nhefs_complete to", RAW_PATH, "\n")
}

raw <- read.csv(RAW_PATH)

stopifnot(TREATMENT %in% names(raw), OUTCOME %in% names(raw))
stopifnot(all(CONFOUNDERS %in% names(raw)))

# Coerce factor / character covariates to numeric encodings the matching
# pipeline can compute Mahalanobis distance on.
#   - sex: "0" male, "1" female                              -> 0/1
#   - race: "0" white, "1" black/other                       -> 0/1
#   - education: 1..5 (ordinal)                              -> 1..5
#   - exercise: "0" much .. "2" little (ordinal)             -> 0..2
#   - active:   "0" very active .. "2" inactive (ordinal)    -> 0..2
to_int <- function(x) suppressWarnings(as.integer(as.character(x)))

n_raw <- nrow(raw)

analysis <- raw |>
  mutate(
    treat          = as.integer(.data[[TREATMENT]]),
    y              = as.numeric(.data[[OUTCOME]]),
    sex            = to_int(sex),
    race           = to_int(race),
    education      = to_int(education),
    exercise       = to_int(exercise),
    active         = to_int(active),
    smokeintensity = as.numeric(smokeintensity),
    smokeyrs       = as.numeric(smokeyrs),
    age            = as.numeric(age),
    wt71           = as.numeric(wt71)
  ) |>
  select(treat, y, all_of(CONFOUNDERS)) |>
  na.omit()

stopifnot(all(analysis$treat %in% c(0, 1)))

write.csv(analysis, DERIVED_PATH, row.names = FALSE)

cat("Raw rows:", n_raw,
    "  Complete-case rows used:", nrow(analysis),
    "  (dropped", n_raw - nrow(analysis), ")\n")
cat("Treated (quit):", sum(analysis$treat == 1),
    "  Control (still smoking):", sum(analysis$treat == 0), "\n")
