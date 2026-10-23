library(fpSEM)

set.seed(2)
f <- c(runif(400, 3, 3.9), runif(100, 4.5, 6))
c <- c(runif(100, 3, 3.9), runif(400, 4.5, 6))

x <- fp_compare(
  fmin_focal = f, fmin_comparator = c,
  df_focal = 88, df_comparator = 98,
  q_focal = 48, q_comparator = 38,
  n_obs = 1000,
  data_space = "full_elliptope", convergence = "force",
  improper_rate_focal = .99, improper_rate_comparator = .99
)
stopifnot(inherits(x, "fp_compare"))
stopifnot(abs(x$delta_fp - .6) < .06)
stopifnot(x$delta_ci[1] > 0)
stopifnot(x$common_n == 500)
stopifnot(x$jaccard >= 0, x$jaccard <= 1)

# fewer than 100 common draws must return NA
x2 <- fp_compare(
  fmin_focal = f[1:50], fmin_comparator = c[1:50],
  df_focal = 88, df_comparator = 98,
  q_focal = 48, q_comparator = 38,
  n_obs = 1000,
  data_space = "full_elliptope", convergence = "default"
)
stopifnot(is.na(x2$delta_fp), isFALSE(x2$informative))

# unequal lengths must error
e <- tryCatch(
  fp_compare(f, c[1:10], 88, 98, 48, 38, 1000,
             data_space = "full_elliptope"),
  error = function(e) conditionMessage(e)
)
stopifnot(grepl("paired", e))


# ordinal statistic and data space
x3 <- fp_compare(
  fmin_focal = f, fmin_comparator = c,
  df_focal = 88, df_comparator = 98,
  q_focal = 48, q_comparator = 38,
  n_obs = 1000,
  statistic = "wlsmv_fmin", threshold = 1.2,
  data_space = "ordinal_full_elliptope", convergence = "force"
)
stopifnot(inherits(x3, "fp_compare"))
stopifnot(grepl("wlsmv_fmin", x3$conditions))
