# Append ordinal reference rows to inst/extdata/fp_reference.csv
# Run from tool/: Rscript build-ordinal-reference.R

d <- read.csv("../stage0/pilot/ordinal-grid/ordinal_grid.csv",
              stringsAsFactors = FALSE)
ref <- read.csv("fpSEM_pkg/inst/extdata/fp_reference.csv",
                stringsAsFactors = FALSE)
ref <- ref[!grepl("^ordinal", ref$data_space), , drop = FALSE]

B <- 2000
set.seed(20261023)
rows <- list()

for (b in c("B0", "B1")) {
  for (m in c("B4", "CF4")) {
    z <- d[d$bspace == b & d$model == m, ]
    f <- z$fmin[is.finite(z$fmin)]
    post <- z$post_check[is.finite(z$fmin)]
    n <- length(f)
    thr <- if (b == "B0") 1.2 else 2.0
    grid <- if (b == "B0") seq(.8, 1.6, by = .05) else seq(1.6, 2.6, by = .05)

    fp <- mean(f < thr)
    ci <- as.numeric(quantile(
      replicate(B, mean(sample(f, n, replace = TRUE) < thr)),
      c(.025, .975), names = FALSE
    ))

    reg <- vapply(grid, function(t) mean(f < t), numeric(1))
    fp_reg <- mean(reg)
    ci_reg <- as.numeric(quantile(
      replicate(B, {
        fs <- sample(f, n, replace = TRUE)
        mean(vapply(grid, function(t) mean(fs < t), numeric(1)))
      }),
      c(.025, .975), names = FALSE
    ))

    common <- list(
      model = m, study = "Study1", p = 16L,
      q = if (m == "B4") 48L else 38L,
      df = if (m == "B4") 88L else 98L,
      data_space = if (b == "B0") "ordinal_positive_manifold" else "ordinal_full_elliptope",
      measure = "uniform", statistic = "wlsmv_fmin",
      formula_n = NA, convergence = "force", R = B, n_draws = n,
      convergence_rate = 1, improper_rate = mean(!post),
      informative = TRUE, package_version = "0.2.0"
    )

    rows[[length(rows) + 1]] <- as.data.frame(c(
      common,
      list(summary = "single", threshold = thr, fp = fp,
           ci_lo = ci[1], ci_hi = ci[2], fp_min = NA_real_, fp_max = NA_real_)
    ), stringsAsFactors = FALSE)

    rows[[length(rows) + 1]] <- as.data.frame(c(
      common,
      list(summary = "region", threshold = NA_real_, fp = fp_reg,
           ci_lo = ci_reg[1], ci_hi = ci_reg[2],
           fp_min = min(reg), fp_max = max(reg))
    ), stringsAsFactors = FALSE)
  }
}

out <- do.call(rbind, rows)
out <- out[, names(ref), drop = FALSE]
all <- rbind(ref, out)
write.csv(all, "fpSEM_pkg/inst/extdata/fp_reference.csv",
          row.names = FALSE, na = "NA")

cat("rows:", nrow(all), " (added", nrow(out), ")\n")
print(out[, c("model", "data_space", "summary", "threshold", "fp",
              "ci_lo", "ci_hi", "improper_rate")], row.names = FALSE)
