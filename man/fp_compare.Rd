\name{fp_compare}
\alias{fp_compare}
\title{Compare fitting propensity of two paired models}
\description{
Computes the paired difference in fitting propensity, a bootstrap confidence
interval, a region summary over a threshold grid, the Jaccard overlap of the
below-threshold sets, and the number of sign flips across the grid.
}
\usage{
fp_compare(fmin_focal, fmin_comparator,
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
           R = 2000, seed = NULL)
}
\arguments{
\item{fmin_focal, fmin_comparator}{Paired numeric vectors of \code{fmin} values.}
\item{df_focal, df_comparator}{Degrees of freedom.}
\item{q_focal, q_comparator}{Numbers of free parameters.}
\item{n_obs}{Sample size used in fitting.}
\item{label_focal, label_comparator}{Model labels.}
\item{statistic}{Fit statistic; currently \code{"fmin"}.}
\item{threshold}{Fit threshold.}
\item{formula_n}{Formula N for RMSEA; required when \code{statistic = "rmsea"}.}
\item{data_space}{\code{"positive_manifold"} or \code{"full_elliptope"}; required.}
\item{convergence}{\code{"force"} or \code{"default"}.}
\item{convergence_rate_focal, convergence_rate_comparator}{Default convergence rates.}
\item{improper_rate_focal, improper_rate_comparator}{Improper-solution rates.}
\item{grid}{Threshold grid for the region summary.}
\item{R}{Number of bootstrap resamples.}
\item{seed}{Optional seed for the bootstrap.}
}
\value{
An object of class \code{fp_compare}: a list with \code{delta_fp},
\code{delta_ci}, \code{delta_region}, \code{jaccard}, \code{n_flip},
\code{common_n}, \code{informative}, \code{conditions}, and \code{warnings}.
}
\examples{
set.seed(1)
f <- runif(500, 3, 5)
c <- runif(500, 4, 6)
fp_compare(f, c,
           df_focal = 88, df_comparator = 98,
           q_focal = 48, q_comparator = 38,
           n_obs = 1000,
           data_space = "full_elliptope",
           convergence = "force")
}
\seealso{\code{\link{fp_judge}}, \code{\link{fp_reference}}}
