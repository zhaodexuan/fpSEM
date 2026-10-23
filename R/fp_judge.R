# fp_judge: single-model fitting propensity with explicit conditions

#' Fitting propensity for one model
#'
#' @param fmin Numeric vector of fitted `fmin` values (one per draw).
#' @param df Model degrees of freedom.
#' @param q Number of free parameters.
#' @param n_obs Sample size used in fitting (`sample.nobs`).
#' @param statistic One of `"fmin"`, `"srmr"`, `"rmsea"`, or `"wlsmv_fmin"`.
#' @param threshold Fit threshold (e.g., 4.0 for `fmin`, .05 for SRMR/RMSEA).
#' @param formula_n Formula N for RMSEA/CFI; required when `statistic = "rmsea"`.
#' @param data_space Data space (e.g., "positive_manifold", "full_elliptope", "ordinal"); required.
#' @param convergence `"default"` or `"force"`.
#' @param convergence_rate Default convergence rate, if known.
#' @param improper_rate Proportion of returned solutions with `post.check = FALSE`.
#' @param common_n Number of common draws; defaults to `length(fmin)`.
#' @param R Bootstrap resamples.
#' @param seed Optional seed.
#'
#' @return An object of class `fp_judge`: a list with the statistic, threshold,
#'   df, q, sample size, formula N, data space, convergence policy, FP estimate,
#'   bootstrap CI, tail probability, convergence rate, common draws, improper
#'   rate, an `informative` flag, a `conditions` string, and warnings.
#' @export
fp_judge <- function(fmin, df, q, n_obs,
                     statistic = c("fmin", "srmr", "rmsea", "wlsmv_fmin"),
                     threshold,
                     formula_n = NULL,
                     data_space,
                     convergence = c("default", "force"),
                     convergence_rate = NA_real_,
                     improper_rate = NA_real_,
                     common_n = NULL,
                     R = 2000, seed = NULL) {
  statistic <- match.arg(statistic)
  convergence <- match.arg(convergence)
  if (missing(threshold)) stop("threshold is required")
  if (missing(data_space)) stop("data_space is required (no default)")
  data_space <- match.arg(data_space, c(
    "positive_manifold", "full_elliptope", "ordinal",
    "ordinal_positive_manifold", "ordinal_full_elliptope",
    "data_informed"
  ))
  if (statistic == "rmsea" && is.null(formula_n))
    stop("formula_n is required for RMSEA")

  fmin <- as.numeric(fmin)
  fmin <- fmin[is.finite(fmin)]
  if (length(fmin) == 0) stop("no finite fmin values")
  if (is.null(common_n)) common_n <- length(fmin)

  fp <- mean(fmin < threshold)
  if (!is.null(seed)) set.seed(seed)
  boot <- replicate(R, mean(sample(fmin, length(fmin), replace = TRUE) < threshold))
  ci <- as.numeric(stats::quantile(boot, c(.025, .975), names = FALSE))

  informative <- common_n >= 100
  warnings <- character()
  if (common_n < 100)
    warnings <- c(warnings, "common_n < 100; estimate is uninformative")
  if (!is.na(improper_rate)) {
    if (improper_rate > .95)
      warnings <- c(warnings, "improper rate > 95%; FP describes an algorithm on random data")
    else if (improper_rate > .25)
      warnings <- c(warnings, "improper rate > 25%; a substantial share of solutions is inadmissible")
    else if (improper_rate > .05)
      warnings <- c(warnings, "improper rate > 5%; check solution admissibility")
  }

  conditions <- sprintf("%s<%s | df=%d | formula N=%s | %s | %s",
                        statistic, format(threshold), as.integer(df),
                        if (is.null(formula_n)) "NA" else as.character(formula_n),
                        convergence, data_space)

  out <- list(
    statistic = statistic, threshold = threshold,
    df = as.integer(df), q = as.integer(q), n_obs = as.integer(n_obs),
    formula_n = formula_n, data_space = data_space, measure = "uniform",
    convergence = convergence,
    fp = if (informative) fp else NA_real_,
    fp_ci = if (informative) ci else c(NA_real_, NA_real_),
    fp_tail = if (informative) 1 - fp else NA_real_,
    convergence_rate = convergence_rate,
    common_n = as.integer(common_n),
    improper_rate = improper_rate,
    informative = informative,
    conditions = conditions,
    warnings = warnings
  )
  class(out) <- "fp_judge"
  out
}

#' @export
print.fp_judge <- function(x, ...) {
  cat("FP judgment\n")
  cat(sprintf("  statistic : %s < %s\n", x$statistic, format(x$threshold)))
  cat(sprintf("  model     : df = %d, q = %d, N = %d\n", x$df, x$q, x$n_obs))
  cat(sprintf("  space     : %s, %s\n", x$data_space, x$measure))
  cat(sprintf("  convergence: %s (improper %s)\n", x$convergence,
              if (is.na(x$improper_rate)) "NA" else sprintf("%.1f%%", 100 * x$improper_rate)))
  if (x$informative) {
    cat(sprintf("  FP        : %.3f  [%.3f, %.3f]\n", x$fp, x$fp_ci[1], x$fp_ci[2]))
    cat(sprintf("  tail      : %.3f\n", x$fp_tail))
  } else {
    cat("  FP        : NA  (insufficient common draws)\n")
  }
  cat(sprintf("  conditions: %s\n", x$conditions))
  for (w in x$warnings) cat(sprintf("  warning   : %s\n", w))
  invisible(x)
}
