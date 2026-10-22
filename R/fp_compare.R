# fp_compare: paired comparison of two models' fitting propensity

#' Compare fitting propensity of two paired models
#'
#' @param fmin_focal,fmin_comparator Paired numeric vectors of `fmin` values.
#' @param df_focal,df_comparator Degrees of freedom.
#' @param q_focal,q_comparator Numbers of free parameters.
#' @param n_obs Sample size used in fitting.
#' @param label_focal,label_comparator Model labels.
#' @param statistic Fit statistic; currently `"fmin"`.
#' @param threshold Fit threshold.
#' @param formula_n Formula N for RMSEA; required when `statistic = "rmsea"`.
#' @param data_space `"positive_manifold"` or `"full_elliptope"`; required.
#' @param convergence `"force"` or `"default"`.
#' @param convergence_rate_focal,convergence_rate_comparator Default convergence rates.
#' @param improper_rate_focal,improper_rate_comparator Improper-solution rates.
#' @param grid Threshold grid for the region summary.
#' @param R Bootstrap resamples.
#' @param seed Optional seed.
#'
#' @return An object of class `fp_compare`: a list with Delta_FP, its bootstrap
#'   CI, Delta_region, Jaccard overlap, the number of sign flips across the
#'   grid, common draws, an `informative` flag, a `conditions` string, and
#'   warnings.
#' @export
fp_compare <- function(fmin_focal, fmin_comparator,
                       df_focal, df_comparator,
                       q_focal, q_comparator,
                       n_obs,
                       label_focal = "focal", label_comparator = "comparator",
                       statistic = "fmin", threshold = 4.0,
                       formula_n = NULL,
                       data_space, convergence = c("force", "default"),
                       convergence_rate_focal = NA_real_,
                       convergence_rate_comparator = NA_real_,
                       improper_rate_focal = NA_real_,
                       improper_rate_comparator = NA_real_,
                       grid = seq(3, 6, by = .5),
                       R = 2000, seed = NULL) {
  convergence <- match.arg(convergence)
  if (missing(data_space)) stop("data_space is required (no default)")
  if (statistic == "rmsea" && is.null(formula_n))
    stop("formula_n is required for RMSEA")
  if (length(fmin_focal) != length(fmin_comparator))
    stop("focal and comparator vectors must be paired (equal length)")

  ok <- is.finite(fmin_focal) & is.finite(fmin_comparator)
  f <- as.numeric(fmin_focal[ok])
  c <- as.numeric(fmin_comparator[ok])
  common_n <- length(f)

  delta_fp <- mean(f < threshold) - mean(c < threshold)
  delta_t <- vapply(grid, function(t) mean(f < t) - mean(c < t), numeric(1))
  delta_region <- mean(delta_t)
  n_flip <- sum(diff(sign(delta_t)) != 0)
  denom <- mean(f < threshold | c < threshold)
  jaccard <- if (denom == 0) NA_real_ else mean(f < threshold & c < threshold) / denom

  if (!is.null(seed)) set.seed(seed)
  boot <- replicate(R, {
    idx <- sample.int(common_n, common_n, replace = TRUE)
    mean(f[idx] < threshold) - mean(c[idx] < threshold)
  })
  ci <- as.numeric(stats::quantile(boot, c(.025, .975), names = FALSE))

  informative <- common_n >= 100
  warnings <- character()
  if (common_n < 100)
    warnings <- c(warnings, "common_n < 100; comparison is uninformative")
  if (any(c(improper_rate_focal, improper_rate_comparator) > .95, na.rm = TRUE))
    warnings <- c(warnings, "improper rate > 95%; FP describes an algorithm on random data")
  if (is.finite(delta_fp) && is.finite(delta_region) &&
      sign(delta_fp) != 0 && sign(delta_region) != 0 &&
      sign(delta_fp) != sign(delta_region))
    warnings <- c(warnings, "Delta_FP and Delta_region have opposite signs")
  if (is.finite(delta_fp) && abs(delta_fp) > 0 &&
      abs(delta_fp - delta_region) / abs(delta_fp) > .10)
    warnings <- c(warnings, "single-threshold summary differs from region summary by > 10%")

  conditions <- sprintf("%s<%s | df=%d vs %d | formula N=%s | %s | %s",
                        statistic, format(threshold),
                        as.integer(df_focal), as.integer(df_comparator),
                        if (is.null(formula_n)) "NA" else as.character(formula_n),
                        convergence, data_space)

  out <- list(
    focal = label_focal, comparator = label_comparator,
    statistic = statistic, threshold = threshold,
    df_focal = as.integer(df_focal), df_comparator = as.integer(df_comparator),
    q_focal = as.integer(q_focal), q_comparator = as.integer(q_comparator),
    n_obs = as.integer(n_obs),
    formula_n = formula_n, data_space = data_space, measure = "uniform",
    convergence = convergence,
    convergence_rate_focal = convergence_rate_focal,
    convergence_rate_comparator = convergence_rate_comparator,
    common_n = common_n,
    delta_fp = if (informative) delta_fp else NA_real_,
    delta_ci = if (informative) ci else c(NA_real_, NA_real_),
    delta_region = delta_region,
    jaccard = jaccard,
    n_flip = n_flip,
    improper_rate_focal = improper_rate_focal,
    improper_rate_comparator = improper_rate_comparator,
    informative = informative,
    conditions = conditions,
    warnings = warnings
  )
  class(out) <- "fp_compare"
  out
}

#' @export
print.fp_compare <- function(x, ...) {
  cat("FP comparison\n")
  cat(sprintf("  focal     : %s (df = %d, q = %d)\n", x$focal, x$df_focal, x$q_focal))
  cat(sprintf("  comparator: %s (df = %d, q = %d)\n", x$comparator, x$df_comparator, x$q_comparator))
  cat(sprintf("  statistic : %s < %s\n", x$statistic, format(x$threshold)))
  cat(sprintf("  space     : %s | %s\n", x$data_space, x$convergence))
  cat(sprintf("  common n  : %d\n", x$common_n))
  if (x$informative) {
    cat(sprintf("  Delta_FP  : %+.3f  [%+.3f, %+.3f]\n", x$delta_fp, x$delta_ci[1], x$delta_ci[2]))
  } else {
    cat("  Delta_FP  : NA  (insufficient common draws)\n")
  }
  cat(sprintf("  Delta_reg : %+.3f\n", x$delta_region))
  cat(sprintf("  Jaccard   : %s\n", if (is.na(x$jaccard)) "NA" else sprintf("%.3f", x$jaccard)))
  cat(sprintf("  n_flip    : %d\n", x$n_flip))
  cat(sprintf("  conditions: %s\n", x$conditions))
  for (w in x$warnings) cat(sprintf("  warning   : %s\n", w))
  invisible(x)
}
