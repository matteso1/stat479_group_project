# 04_balance.R — covariate balance diagnostics before vs after matching.
#
# Output:
#   tables/balance_table.csv
#   figures/love_plot.png

suppressPackageStartupMessages({
})

df  <- read.csv("data/derived/analysis_ps.csv")
res <- readRDS("data/derived/matches.rds")

df$group <- df$treat + 1L
confounders <- setdiff(names(df), c("treat", "y", "pscore", "group"))
numeric_confounders <- confounders[sapply(df[confounders], is.numeric)]

details <- c("std_diff", "mean")
names(details) <- c("std_diff", "mean")

cb <- covbalance(
  .data      = df,
  grouplabel = "group",
  matches    = res$matches,
  vars       = numeric_confounders,
  details    = details
)

bal_table <- data.frame(cb$std_diff[[1]])
bal_table$covariate <- rownames(bal_table)
bal_table <- bal_table[, c("covariate", setdiff(names(bal_table), "covariate"))]

dir.create("tables", showWarnings = FALSE)
write.csv(bal_table, "tables/balance_table.csv", row.names = FALSE)

# ---- Love plot (adapted from lecture10_rdemonstration.R) ------------------
smd_before <- bal_table$std_diff_before
smd_after  <- bal_table$std_diff_after
covs       <- bal_table$covariate
ord        <- order(abs(smd_after))

dir.create("figures", showWarnings = FALSE)
png("figures/love_plot.png", width = 900, height = 600, res = 150)
par(mar = c(4, 7, 2, 2))
plot(smd_before[ord], seq_along(ord),
     pch = 1, col = "darkred",
     xlim = range(c(smd_before, smd_after, -0.2, 0.2), na.rm = TRUE),
     xlab = "Standardized Mean Difference",
     ylab = "", yaxt = "n",
     main = "Love plot: before vs after matching")
points(smd_after[ord], seq_along(ord), pch = 19, col = "steelblue")
abline(v = 0, lwd = 2)
abline(v = c(-0.1, 0.1), lty = 2, col = "gray40")
axis(2, at = seq_along(ord), labels = covs[ord], las = 1)
legend("topright",
       legend = c("Before", "After"),
       pch = c(1, 19), col = c("darkred", "steelblue"),
       bty = "n")
dev.off()

print(bal_table)
