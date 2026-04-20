# run_all.R — run the full analysis pipeline end-to-end.
# Run from the project root:  Rscript R/run_all.R

scripts <- c(
  "R/01_load.R",
  "R/02_propensity.R",
  "R/03_match.R",
  "R/04_balance.R",
  "R/05_estimate.R"
)

for (s in scripts) {
  cat("\n=====", s, "=====\n")
  source(s, echo = FALSE)
}

cat("\nDone. See figures/, tables/, and data/derived/.\n")
