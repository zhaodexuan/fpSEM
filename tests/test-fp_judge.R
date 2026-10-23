library(fpSEM)

set.seed(1)
f <- c(runif(400, 3, 3.9), runif(100, 4.5, 6))

j <- fp_judge(
  fmin = f, df = 88, q = 48, n_obs = 1000,
  statistic = "fmin", threshold = 4,
  data_space = "full_elliptope", convergence = "force",
  convergence_rate = 1, improper_rate = .99
)
stopifnot(inherits(j, "fp_judge"))
stopifnot(abs(j$fp - .8) < .05)
stopifnot(length(j$fp_ci) == 2)
stopifnot(j$fp_ci[1] < j$fp, j$fp < j$fp_ci[2])
stopifnot(grepl("fmin<4", j$conditions))
stopifnot(any(grepl("improper", j$warnings)))

# common_n < 100 must return NA and informative = FALSE
j2 <- fp_judge(
  fmin = f[1:50], df = 88, q = 48, n_obs = 1000,
  statistic = "fmin", threshold = 4,
  data_space = "full_elliptope", convergence = "default"
)
stopifnot(is.na(j2$fp), isFALSE(j2$informative))
stopifnot(any(grepl("common_n", j2$warnings)))

# missing data_space must error
e1 <- tryCatch(
  fp_judge(f, 88, 48, 1000, threshold = 4),
  error = function(e) conditionMessage(e)
)
stopifnot(grepl("data_space", e1))

# RMSEA without formula_n must error
e2 <- tryCatch(
  fp_judge(f, 88, 48, 1000, statistic = "rmsea", threshold = .05,
           data_space = "full_elliptope"),
  error = function(e) conditionMessage(e)
)
stopifnot(grepl("formula_n", e2))


# ordinal statistic and data space
j3 <- fp_judge(
  fmin = f, df = 88, q = 48, n_obs = 1000,
  statistic = "wlsmv_fmin", threshold = 1.2,
  data_space = "ordinal_positive_manifold", convergence = "force",
  improper_rate = .99
)
stopifnot(inherits(j3, "fp_judge"))
stopifnot(grepl("wlsmv_fmin", j3$conditions))
stopifnot(grepl("ordinal_positive_manifold", j3$conditions))
