# Regenerate inst/extdata/fp_reference.csv from the O6 simulation grid.
# This script is not run by R CMD check. The raw RDS files are not bundled;
# set `base` to the path of `stage0/pilot` in the O6 project before running.
#

base <- "../stage0/pilot"
outdir <- "fpSEM/inst/extdata"
dir.create(outdir, recursive = TRUE, showWarnings = FALSE)

qmap <- c(single = 32, CF4 = 38, higher = 40, B3 = 48, B4 = 48, B5 = 48)
grid <- seq(3, 6, by = .5)
B <- 2000
set.seed(20261022)

summarise_cell <- function(path, convergence) {
  d <- readRDS(path)
  n_all <- nrow(d)
  if (convergence == "default") {
    keep <- d$converged %in% TRUE & is.finite(d$fmin)
  } else {
    keep <- is.finite(d$fmin)
  }
  f <- d$fmin[keep]
  post <- d$post_check[keep]
  n <- length(f)
  if (n == 0) return(NULL)

  fp <- mean(f < 4)
  ci <- as.numeric(quantile(
    replicate(B, mean(sample(f, n, replace = TRUE) < 4)),
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

  list(
    n_all = n_all, n = n,
    fp = fp, ci_lo = ci[1], ci_hi = ci[2],
    fp_reg = fp_reg, reg_lo = ci_reg[1], reg_hi = ci_reg[2],
    fp_min = min(reg), fp_max = max(reg),
    improper = mean(!post)
  )
}

files <- list.files(file.path(base, "main-grid"), pattern = "\\.rds$", full.names = TRUE)
rows <- list()

for (f in files) {
  parts <- strsplit(basename(f), "_")[[1]]
  study <- parts[1]
  b <- parts[2]
  model <- sub("\\.rds$", "", parts[3])
  d0 <- readRDS(f)
  df <- d0$df[is.finite(d0$fmin)][1]
  q <- qmap[[model]]

  for (conv in c("force", "default")) {
    path <- if (conv == "force") f else file.path(base, "main-grid-c0", basename(f))
    if (!file.exists(path)) next
    res <- summarise_cell(path, conv)
    if (is.null(res)) next

    common <- list(
      model = model, study = study, p = 16L, q = as.integer(q),
      df = as.integer(df),
      data_space = if (b == "B0") "positive_manifold" else "full_elliptope",
      measure = "uniform", statistic = "fmin", formula_n = NA_integer_,
      convergence = conv, R = B, n_draws = res$n,
      convergence_rate = res$n / res$n_all,
      improper_rate = res$improper,
      informative = res$n >= 100,
      package_version = "0.1.0"
    )

    rows[[length(rows) + 1]] <- as.data.frame(c(
      common,
      list(summary = "single", threshold = 4.0,
           fp = res$fp, ci_lo = res$ci_lo, ci_hi = res$ci_hi,
           fp_min = NA_real_, fp_max = NA_real_)
    ), stringsAsFactors = FALSE)

    rows[[length(rows) + 1]] <- as.data.frame(c(
      common,
      list(summary = "region", threshold = NA_real_,
           fp = res$fp_reg, ci_lo = res$reg_lo, ci_hi = res$reg_hi,
           fp_min = res$fp_min, fp_max = res$fp_max)
    ), stringsAsFactors = FALSE)
  }
}

out <- do.call(rbind, rows)
out <- out[order(out$study, out$data_space, out$model, out$convergence,
                 out$summary), ]

write.csv(out, file.path(outdir, "fp_reference.csv"), row.names = FALSE, na = "NA")
write.csv(out, "fp_reference.csv", row.names = FALSE, na = "NA")

cat("rows:", nrow(out), "\n")
print(out[out$summary == "single" &
          out$model %in% c("B4", "CF4", "B3", "B5"),
          c("study", "data_space", "model", "df", "convergence",
            "n_draws", "fp", "ci_lo", "ci_hi", "improper_rate")],
      row.names = FALSE)
