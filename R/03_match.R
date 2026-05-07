# 03_match.R — build a matched design using approxmatch (from lecture).
#
# Follows the pattern in lecture10_rdemonstration.R:
#   - construct a distance structure (Mahalanobis + propensity score)
#   - run 1:2 nearest-neighbor matching via kwaymatching()
#
# Output:
#   data/derived/matches.rds     list returned by kwaymatching
#   data/derived/matched_df.csv  long-format matched sample

suppressPackageStartupMessages({
  library(optmatch)
  library(rlemon)
})

# Override the CRAN release of approxmatch with the unreleased source the
# course ships, which exposes a `solver` argument compatible with current
# optmatch (the CRAN release tries to call a Fortran routine that no longer
# lives in optmatch). Same pattern as lecture10_rdemonstration.R.
for (f in c("multigrp_dist_struc.R", "kwaymatching.R", "nrbalancematch.R",
            "tripletmatching.R", "covbalance.R")) {
  source(file.path("R", "approxmatch", f), local = FALSE)
}

analysis <- read.csv("data/derived/analysis_ps.csv")

# approxmatch expects the group label to start at 1.
df <- analysis
df$group <- df$treat + 1L

confounders <- setdiff(names(analysis), c("treat", "y", "pscore"))

# Use numeric covariates for the Mahalanobis component. Non-numeric confounders
# (e.g., race) can be added via exactmatchon or finebalanceVars below.
numeric_confounders <- confounders[sapply(df[confounders], is.numeric)]

components <- list(
  mahal = numeric_confounders,
  prop  = numeric_confounders
)
wgts <- c(1, 1)

dist_str <- multigrp_dist_struc(
  .data      = df,
  grouplabel = "group",
  components = components,
  wgts       = wgts
)

# 1:2 nearest-neighbor matching. Index group = smaller group (treated = 2).
indexgroup <- 2L
design     <- c(2, 1)

res <- kwaymatching(
  distmat    = dist_str,
  grouplabel = "group",
  indexgroup = indexgroup,
  design     = design,
  .data      = df
  # Consider: exactmatchon = "race"  or  finebalanceVars = "race"
)

saveRDS(res, "data/derived/matches.rds")

matched_ids <- as.vector(res$matches)
matched_df  <- df[matched_ids, ]

write.csv(matched_df, "data/derived/matched_df.csv", row.names = FALSE)

cat("Matched pairs:", nrow(res$matches), "\n")
cat("Matched sample size:", nrow(matched_df), "\n")
