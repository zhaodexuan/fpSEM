\name{fp_judge}
\alias{fp_judge}
\title{Fitting propensity for one model}
\description{
Computes the proportion of fitted \code{fmin} values below a threshold, with a
bootstrap confidence interval and an explicit condition set. The function
refuses to return a single number without the statistic, threshold, degrees of
freedom, data space, and convergence policy.
}
\usage{
fp_judge(fmin, df, q, n_obs,
         statistic = c("fmin", "srmr", "rmsea", "wlsmv_fmin"),
         threshold, formula_n = NULL, data_space,
         convergence = c("default", "force"),
         convergence_rate = NA_real_, improper_rate = NA_real_,
         common_n = NULL, R = 2000, seed = NULL)
}
\arguments{
\item{fmin}{Numeric vector of fitted \code{fmin} values, one per draw.}
\item{df}{Model degrees of freedom.}
\item{q}{Number of free parameters.}
\item{n_obs}{Sample size used in fitting (\code{sample.nobs}).}
\item{statistic}{One of \code{"fmin"}, \code{"srmr"}, \code{"rmsea"}, or \code{"wlsmv_fmin"}.}
\item{threshold}{Fit threshold, for example 4.0 for \code{fmin} or .05 for SRMR.}
\item{formula_n}{Formula N for RMSEA; required when \code{statistic = "rmsea"}.}
\item{data_space}{One of \code{"positive_manifold"}, \code{"full_elliptope"}, \code{"ordinal"}, \code{"ordinal_positive_manifold"}, \code{"ordinal_full_elliptope"}, or \code{"data_informed"}; required.}
\item{convergence}{\code{"default"} or \code{"force"}.}
\item{convergence_rate}{Default convergence rate, if known.}
\item{improper_rate}{Proportion of returned solutions with \code{post.check = FALSE}.}
\item{common_n}{Number of common draws; defaults to \code{length(fmin)}.}
\item{R}{Number of bootstrap resamples.}
\item{seed}{Optional seed for the bootstrap.}
}
\value{
An object of class \code{fp_judge}: a list with \code{statistic},
\code{threshold}, \code{df}, \code{q}, \code{n_obs}, \code{formula_n},
\code{data_space}, \code{measure}, \code{convergence}, \code{fp},
\code{fp_ci}, \code{fp_tail}, \code{convergence_rate}, \code{common_n},
\code{improper_rate}, \code{informative}, \code{conditions}, and
\code{warnings}.
}
\examples{
set.seed(1)
f <- c(runif(400, 3, 5), runif(100, 5, 8))
fp_judge(f, df = 88, q = 48, n_obs = 1000, threshold = 4,
         data_space = "full_elliptope", convergence = "force",
         improper_rate = .99)
}
\seealso{\code{\link{fp_compare}}, \code{\link{fp_reference}}}
