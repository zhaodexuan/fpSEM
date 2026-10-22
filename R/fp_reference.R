# fp_reference: load the bundled reference table

#' Load the bundled fitting-propensity reference table
#'
#' The table is generated from the O6 simulation grid: 14 force-converged
#' cells and 8 default-convergence cells, each summarized at a single threshold
#' (`fmin < 4.0`) and over the region `fmin` in [3, 6].
#'
#' @param model Optional character vector of model names (`"B3"`, `"B4"`,
#'   `"B5"`, `"CF4"`, `"higher"`, `"single"`).
#' @param df Optional degrees of freedom.
#' @param data_space Optional `"positive_manifold"` or `"full_elliptope"`.
#' @param statistic Fit statistic; default `"fmin"`.
#' @param convergence Optional `"force"` or `"default"`.
#' @param summary Optional `"single"` or `"region"`.
#' @param informative_only If `TRUE`, drop rows with fewer than 100 draws.
#'
#' @return A data frame with one row per model x data space x convergence x
#'   summary. Columns include `model`, `p`, `q`, `df`, `data_space`,
#'   `statistic`, `summary`, `threshold`, `convergence`, `R`, `n_draws`, `fp`,
#'   `ci_lo`, `ci_hi`, `fp_min`, `fp_max`, `convergence_rate`,
#'   `improper_rate`, `informative`, and `package_version`.
#' @export
fp_reference <- function(model = NULL, df = NULL, data_space = NULL,
                         statistic = "fmin", convergence = NULL,
                         summary = "single", informative_only = TRUE) {
  path <- system.file("extdata", "fp_reference.csv", package = "fpSEM")
  if (!nzchar(path)) stop("reference table not found; reinstall fpSEM")
  x <- utils::read.csv(path, stringsAsFactors = FALSE)

  if (!is.null(model)) x <- x[x$model %in% model, , drop = FALSE]
  if (!is.null(df)) x <- x[x$df %in% df, , drop = FALSE]
  if (!is.null(data_space)) x <- x[x$data_space %in% data_space, , drop = FALSE]
  if (!is.null(statistic)) x <- x[x$statistic %in% statistic, , drop = FALSE]
  if (!is.null(convergence)) x <- x[x$convergence %in% convergence, , drop = FALSE]
  if (!is.null(summary)) x <- x[x$summary %in% summary, , drop = FALSE]
  if (informative_only && "informative" %in% names(x))
    x <- x[x$informative, , drop = FALSE]

  rownames(x) <- NULL
  x
}
