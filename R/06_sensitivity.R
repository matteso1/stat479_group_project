# 06_sensitivity.R — robustness checks on the matched ATE.
#
# We rerun the matching pipeline under two perturbations:
#   (a) 1:2 nearest-neighbor instead of 1:1
#   (b) PS trimming to the [0.05, 0.95] interval before re-matching 1:1
#
# Both are reported as paired-style estimates so they can be compared head
# to head with the primary 1:2 design from 03_match.R / 05_estimate.R.
#
# Output:
#   tables/sensitivity.csv

suppressPackageStartupMessages({
  library(optmatch)
  library(rlemon)
})

for (f in c("multigrp_dist_struc.R", "kwaymatching.R", "nrbalancematch.R",
            "tripletmatching.R", "covbalance.R")) {
  source(file.path("R", "approxmatch", f), local = FALSE)
}

# --- shared helpers --------------------------------------------------------

build_dist <- function(df, num_vars) {
  multigrp_dist_struc(
    .data      = df,
    grouplabel = "group",
    components = list(mahal = num_vars, prop = num_vars),
    wgts       = c(1, 1)
  )
}

# Average control outcome within each treated unit's matched set, then take
# the mean treated-minus-control gap. This gives a paired-pair flavor for
# both 1:1 and 1:k designs without committing to a particular variance
# formula. We report a sd-of-pair-differences SE for clarity.
paired_estimate <- function(matches_mat, df) {
  treat_col <- grep("^group_2", colnames(matches_mat))
  ctrl_cols <- grep("^group_1", colnames(matches_mat))
  stopifnot(length(treat_col) == 1, length(ctrl_cols) >= 1)

  # kwaymatching returns row-name strings, not positional indices. Look up
  # outcomes by row name to stay correct even when df has been subsetted.
  y_treat <- df[matches_mat[, treat_col], "y"]

  if (length(ctrl_cols) == 1) {
    y_ctrl_mean <- df[matches_mat[, ctrl_cols], "y"]
  } else {
    ctrl_outcomes <- sapply(ctrl_cols, function(j) df[matches_mat[, j], "y"])
    y_ctrl_mean   <- rowMeans(ctrl_outcomes)
  }

  diffs <- y_treat - y_ctrl_mean
  list(
    estimate = mean(diffs),
    se       = sd(diffs) / sqrt(length(diffs)),
    n_pairs  = length(diffs)
  )
}

# --- load ------------------------------------------------------------------

ana <- read.csv("data/derived/analysis_ps.csv")
ana$group <- ana$treat + 1L

confounders <- setdiff(names(ana), c("treat", "y", "pscore", "group"))
num_conf    <- confounders[sapply(ana[confounders], is.numeric)]

results <- list()

# --- (a) 1:1 nearest-neighbor matching -------------------------------------

dist_a <- build_dist(ana, num_conf)
res_a  <- kwaymatching(
  distmat    = dist_a,
  grouplabel = "group",
  indexgroup = 2L,
  design     = c(1, 1),    # 1 control per treated
  .data      = ana
)
est_a  <- paired_estimate(res_a$matches, ana)
results[["1:1 NN matching"]] <- est_a

# --- (b) PS-trimmed 1:1 matching -------------------------------------------

trim_lo <- 0.05
trim_hi <- 0.95
keep    <- ana$pscore >= trim_lo & ana$pscore <= trim_hi
ana_t   <- ana[keep, , drop = FALSE]
n_drop  <- nrow(ana) - nrow(ana_t)

dist_b <- build_dist(ana_t, num_conf)
res_b  <- kwaymatching(
  distmat    = dist_b,
  grouplabel = "group",
  indexgroup = 2L,
  design     = c(1, 1),
  .data      = ana_t
)
est_b  <- paired_estimate(res_b$matches, ana_t)
results[[sprintf("1:1 NN, PS trimmed [%.2f, %.2f]", trim_lo, trim_hi)]] <- est_b

# --- write summary ---------------------------------------------------------

primary <- read.csv("tables/ate_estimate.csv")
primary_row <- data.frame(
  design      = "1:2 NN matching (primary)",
  estimate_kg = primary$estimate,
  se_kg       = primary$paired_se,
  ci_lower    = primary$ci_lower_95,
  ci_upper    = primary$ci_upper_95,
  n_pairs     = primary$n_pairs,
  notes       = ""
)

sens_rows <- do.call(rbind, lapply(names(results), function(nm) {
  e <- results[[nm]]
  data.frame(
    design      = nm,
    estimate_kg = e$estimate,
    se_kg       = e$se,
    ci_lower    = e$estimate - 1.96 * e$se,
    ci_upper    = e$estimate + 1.96 * e$se,
    n_pairs     = e$n_pairs,
    notes       = if (grepl("trimmed", nm)) sprintf("dropped %d units", n_drop) else ""
  )
}))

out <- rbind(primary_row, sens_rows)
dir.create("tables", showWarnings = FALSE)
write.csv(out, "tables/sensitivity.csv", row.names = FALSE)

cat("Sensitivity comparison:\n")
print(out)
