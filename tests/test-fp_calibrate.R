library(fpSEM)

set.seed(3)
f <- c(runif(400, .8, 1.1), runif(100, 1.1, 1.4))
c <- c(runif(100, .8, 1.1), runif(400, 1.1, 1.4))

x <- fp_calibrate(f, c)
stopifnot(inherits(x, "fp_calibrate"), is.data.frame(x))
stopifnot(nrow(x) >= 3)
stopifnot(all(c("threshold", "fp_focal", "fp_comparator", "delta", "jaccard") %in% names(x)))
stopifnot(attr(x, "recommended") >= min(x$threshold))
stopifnot(attr(x, "recommended") <= max(x$threshold))
stopifnot(attr(x, "common_n") == 500)

# fewer than 100 common draws is flagged
y <- fp_calibrate(f[1:50], c[1:50])
stopifnot(isFALSE(attr(y, "informative")))

# unequal lengths must error
e <- tryCatch(
  fp_calibrate(f, c[1:10]),
  error = function(e) conditionMessage(e)
)
stopifnot(grepl("paired", e))
