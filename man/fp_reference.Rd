\name{fp_reference}
\alias{fp_reference}
\title{Load the bundled fitting-propensity reference table}
\description{
Loads the reference table generated from the O6 simulation grid: 14
force-converged cells and 8 default-convergence cells, each summarized at a
single threshold (\code{fmin < 4.0}) and over the region \code{fmin} in
\eqn{[3, 6]}.
}
\usage{
fp_reference(model = NULL, df = NULL, data_space = NULL,
             statistic = "fmin", convergence = NULL,
             summary = "single", informative_only = TRUE)
}
\arguments{
\item{model}{Optional character vector of model names: \code{"B3"},
\code{"B4"}, \code{"B5"}, \code{"CF4"}, \code{"higher"}, or \code{"single"}.}
\item{df}{Optional degrees of freedom.}
\item{data_space}{Optional \code{"positive_manifold"} or \code{"full_elliptope"}.}
\item{statistic}{Fit statistic; default \code{"fmin"}.}
\item{convergence}{Optional \code{"force"} or \code{"default"}.}
\item{summary}{Optional \code{"single"} or \code{"region"}.}
\item{informative_only}{If \code{TRUE}, drop rows with fewer than 100 draws.}
}
\value{
A data frame with columns \code{model}, \code{study}, \code{p}, \code{q},
\code{df}, \code{data_space}, \code{measure}, \code{statistic},
\code{summary}, \code{threshold}, \code{formula_n}, \code{convergence},
\code{R}, \code{n_draws}, \code{fp}, \code{ci_lo}, \code{ci_hi},
\code{fp_min}, \code{fp_max}, \code{convergence_rate},
\code{improper_rate}, \code{informative}, and \code{package_version}.
}
\examples{
head(fp_reference(model = "B4", convergence = "force"))
}
\seealso{\code{\link{fp_judge}}, \code{\link{fp_compare}}}
