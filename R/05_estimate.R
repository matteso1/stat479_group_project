# 05_estimate.R — ATE estimation on the matched sample.
#
# Reports the simple matched-pair difference-in-means with a paired SE / CI.
#
# Output:
#   tables/ate_estimate.csv

df  <- read.csv("data/derived/analysis_ps.csv")
res <- readRDS("data/derived/matches.rds")

# res$matches is a 2-column character matrix of row indices into df.
# Column "group_2" = treated row, column "group_1.1" = matched control row.
pair_ids <- apply(res$matches, 2, as.integer)

treat_col <- grep("^group_2", colnames(res$matches))
ctrl_col  <- grep("^group_1", colnames(res$matches))
stopifnot(length(treat_col) == 1, length(ctrl_col) == 1)

y_treat <- df$y[pair_ids[, treat_col]]
y_ctrl  <- df$y[pair_ids[, ctrl_col]]

diffs   <- y_treat - y_ctrl
tau_hat <- mean(diffs)
se      <- sd(diffs) / sqrt(length(diffs))
ci_lo   <- tau_hat - 1.96 * se
ci_hi   <- tau_hat + 1.96 * se

out <- data.frame(
  estimand    = "ATE on matched sample (paired difference-in-means)",
  estimate    = tau_hat,
  paired_se   = se,
  ci_lower_95 = ci_lo,
  ci_upper_95 = ci_hi,
  n_pairs     = length(diffs),
  units       = "kg of weight change (1971 to 1982)"
)

dir.create("tables", showWarnings = FALSE)
write.csv(out, "tables/ate_estimate.csv", row.names = FALSE)

cat("Matched ATE estimate (paired difference-in-means):\n")
print(out)
cat(sprintf(
  "\n  tau_hat = %.3f kg   95%% CI = [%.3f, %.3f]   n_pairs = %d\n",
  tau_hat, ci_lo, ci_hi, length(diffs)
))
