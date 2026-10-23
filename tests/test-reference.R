library(fpSEM)

r <- fp_reference(summary = NULL)
stopifnot(is.data.frame(r), nrow(r) > 0)
stopifnot(all(c("model", "df", "data_space", "statistic", "convergence", "fp") %in% names(r)))
stopifnot(all(c("single", "region") %in% unique(r$summary)))

r2 <- fp_reference(model = "B4", data_space = "full_elliptope", convergence = "force")
stopifnot(nrow(r2) >= 2)
stopifnot(all(r2$model == "B4"))
stopifnot(all(r2$data_space == "full_elliptope"))

r3 <- fp_reference(convergence = "default", informative_only = TRUE)
if (nrow(r3) > 0) stopifnot(all(r3$n_draws >= 100))

r4 <- fp_reference(model = "B4", summary = "single", convergence = "force")
stopifnot(nrow(r4) >= 1)
stopifnot(all(is.finite(r4$fp)))

# ordinal reference rows
ro <- fp_reference(model = "B4", data_space = "ordinal_positive_manifold", statistic = "wlsmv_fmin")
stopifnot(nrow(ro) >= 1)
stopifnot(all(ro$statistic == "wlsmv_fmin"))
