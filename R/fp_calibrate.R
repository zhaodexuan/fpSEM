# fp_calibrate: data-driven threshold selection for a paired comparison

#' Calibrate an FP threshold for a paired comparison
#'
#' @param fmin_focal,fmin_comparator Paired numeric vectors of fit values.
#' @param label_focal,label_comparator Model labels.
#' @param grid Optional threshold grid. If `NULL`, `n_grid` points between the
#'   two medians are used.
#' @param n_grid Number of candidate thresholds when `grid` is `NULL`.
#'
#' @return A data frame of class `fp_calibrate` with columns `threshold`,
#'   `fp_focal`, `fp_comparator`, `delta`, and `jaccard`. Attributes:
#'   `recommended`, `medians`, `common_n`, `informative`, `n_flip`.
#' @export
fp_calibrate <- function(fmin_focal, fmin_comparator,
                         label_focal = "focal", label_comparator = "comparator",
                         grid = NULL, n_grid = 9) {
  if (length(fmin_focal) != length(fmin_comparator))
    stop("focal and comparator vectors must be paired (equal length)")
  ok <- is.finite(fmin_focal) & is.finite(fmin_comparator)
  f <- as.numeric(fmin_focal[ok])
  c <- as.numeric(fmin_comparator[ok])
  if (length(f) == 0) stop("no finite paired values")

  med_f <- stats::median(f)
  med_c <- stats::median(c)
  lo <- min(med_f, med_c)
  hi <- max(med_f, med_c)
  if (!is.finite(lo) || !is.finite(hi)) stop("medians are not finite")
  if (hi <= lo) hi <- lo + max(abs(lo) * .1, .01)
  if (is.null(grid)) grid <- seq(lo, hi, length.out = n_grid)
  grid <- sort(unique(as.numeric(grid)))

  rows <- lapply(grid, function(t) {
    fp_f <- mean(f < t)
    fp_c <- mean(c < t)
    denom <- mean(f < t | c < t)
    jac <- if (denom == 0) NA_real_ else mean(f < t & c < t) / denom
    data.frame(threshold = t, fp_focal = fp_f, fp_comparator = fp_c,
               delta = fp_f - fp_c, jaccard = jac)
  })
  out <- do.call(rbind, rows)
  out <- out[order(out$threshold), , drop = FALSE]
  rownames(out) <- NULL

  attr(out, "recommended") <- grid[which.min(abs(grid - (med_f + med_c) / 2))]
  attr(out, "medians") <- c(focal = med_f, comparator = med_c)
  attr(out, "common_n") <- length(f)
  attr(out, "informative") <- length(f) >= 100
  attr(out, "n_flip") <- sum(diff(sign(out$delta)) != 0)
  class(out) <- c("fp_calibrate", "data.frame")
  out
}

#' @export
print.fp_calibrate <- function(x, ...) {
  cat("FP threshold calibration\n")
  cat(sprintf("  medians: focal=%.3f comparator=%.3f\n",
              attr(x, "medians")[1], attr(x, "medians")[2]))
  cat(sprintf("  common n: %d%s\n", attr(x, "common_n"),
              if (isTRUE(attr(x, "informative"))) "" else " (uninformative: < 100)"))
  print.data.frame(x, row.names = FALSE)
  cat(sprintf("  recommended threshold: %.3f\n", attr(x, "recommended")))
  cat(sprintf("  n_flip across candidates: %d\n", attr(x, "n_flip")))
  if (!isTRUE(attr(x, "informative")))
    cat("  warning: common_n < 100; calibration is uninformative\n")
  invisible(x)
}
