# 02_propensity.R — estimate the propensity score and produce overlap plots.
#
# Output:
#   data/derived/analysis_ps.csv  (adds pscore column)
#   figures/overlap_density.png
#   figures/overlap_histogram.png

suppressPackageStartupMessages({
  library(ggplot2)
})

analysis <- read.csv("data/derived/analysis.csv")

confounders <- setdiff(names(analysis), c("treat", "y"))
ps_formula  <- as.formula(
  paste("treat ~", paste(confounders, collapse = " + "))
)

ps_model <- glm(ps_formula, data = analysis, family = binomial())
analysis$pscore <- predict(ps_model, type = "response")

write.csv(analysis, "data/derived/analysis_ps.csv", row.names = FALSE)

# ---- Overlap diagnostics --------------------------------------------------
dir.create("figures", showWarnings = FALSE)

p_density <- ggplot(analysis, aes(x = pscore, fill = factor(treat))) +
  geom_density(alpha = 0.5) +
  labs(x = "Estimated propensity score", y = "Density",
       fill = "Treated", title = "Propensity score overlap (density)") +
  theme_minimal()

ggsave("figures/overlap_density.png", p_density, width = 7, height = 4, dpi = 150)

p_hist <- ggplot(analysis, aes(x = pscore, fill = factor(treat))) +
  geom_histogram(position = "identity", alpha = 0.5, bins = 30) +
  labs(x = "Estimated propensity score", y = "Count",
       fill = "Treated", title = "Propensity score overlap (histogram)") +
  theme_minimal()

ggsave("figures/overlap_histogram.png", p_hist, width = 7, height = 4, dpi = 150)

cat("PS model fit. Range of pscore:",
    round(range(analysis$pscore), 3), "\n")
