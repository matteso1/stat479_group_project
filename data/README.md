# Data

## Current placeholder
`raw/nswdata_clean.csv` — the NSW/Lalonde job-training dataset used in lecture (see
`course_files_export/Code and Data/`). 722 rows. Treatment = `trainning` (0/1),
outcome = `earning78`, pre-treatment earnings = `earning75`, covariates = `age`,
`education`, `race`, `married`, `nodegree`.

## When the instructor gives us the real dataset
1. Drop the new file in `raw/`.
2. Update the `DATA_PATH` and variable names at the top of `R/01_load.R`.
3. Re-run `R/run_all.R`.

## Notes
- Do not edit files in `raw/` by hand. Any cleaning/derivation belongs in `R/01_load.R`
  and should write to `data/derived/`.
- Large raw files should be excluded from git; the NSW placeholder is small enough
  to commit.
