# Contributions

This file documents who did what on the group project, per course policy.

## Group members

- Anushka Dwivedi (ADWIVEDI6@wisc.edu)
- Hyunbin Jung (HJUNG89@wisc.edu)
- Pusti Jesrani (JESRANI@wisc.edu)
- Nils Matteson (NOMATTESON@wisc.edu)

## Work performed

All technical and written work in this submission was performed by Nils
Matteson:

- Project scaffolding, repository setup, README, and `.gitignore`.
- Dataset selection (NHEFS via `causaldata`), data snapshot, and confounder
  selection (`R/01_load.R`).
- Propensity-score model and overlap diagnostics (`R/02_propensity.R`,
  `figures/overlap_*.png`).
- Vendoring of the unreleased `approxmatch` package and the 1:1 nearest-
  neighbor matching pipeline (`R/03_match.R`, `R/approxmatch/`).
- Balance diagnostics, standardized mean differences, and Love plot
  (`R/04_balance.R`, `figures/love_plot.png`, `tables/balance_table.csv`).
- Matched ATE estimation with paired SE / CI (`R/05_estimate.R`,
  `tables/ate_estimate.csv`).
- Sensitivity analyses: 1:2 nearest-neighbor and propensity-score trimmed
  designs (`R/06_sensitivity.R`, `tables/sensitivity.csv`).
- Final write-up in LaTeX (`report/report.tex`) and the knit-on-demand
  `report/report.Rmd` companion.

## Coordination

The other listed group members did not respond to outreach (group chat,
email, Canvas message) prior to the deadline and did not contribute code,
analysis, or written content. The course staff (TA Cameron Jones,
Prof. Bikram Karmakar) were notified before the submission deadline.
