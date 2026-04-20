# 05_estimate.R — ATE estimation on the matched sample.
#
# Output:
#   tables/ate_estimate.csv

matched_df <- read.csv("data/derived/matched_df.csv")

Y <- matched_df$y
Z <- matched_df$treat

tau_hat <- mean(Y[Z == 1]) - mean(Y[Z == 0])

# Paired SE: build treated/control vectors in pair order from matches.rds
res <- readRDS("data/derived/matches.rds")
pair_ids <- res$matches   # rows = pairs, cols = groups

# group 2 = treated (treat + 1 = 2), group 1 = control
df <- read.csv("data/derived/analysis_ps.csv")
y_treat <- df$y[pair_ids[, which(colnames(pair_ids) == "2")]]
y_ctrl  <- df$y[pair_ids[, which(colnames(pair_ids) == "1")]]

# Fallback if colnames aren't "1"/"2"
if (length(y_treat) == 0 || length(y_ctrl) == 0) {
  y_treat <- df$y[pair_ids[, 1]]
  y_ctrl  <- df$y[pair_ids[, 2]]
}

diffs  <- y_treat - y_ctrl
se     <- sd(diffs) / sqrt(length(diffs))
ci_lo  <- mean(diffs) - 1.96 * se
ci_hi  <- mean(diffs) + 1.96 * se

out <- data.frame(
  estimand = "ATE (matched, difference-in-means)",
  estimate = tau_hat,
  paired_mean_diff = mean(diffs),
  paired_se = se,
  ci_lower_95 = ci_lo,
  ci_upper_95 = ci_hi,
  n_pairs = length(diffs)
)

dir.create("tables", showWarnings = FALSE)
write.csv(out, "tables/ate_estimate.csv", row.names = FALSE)

print(out)
