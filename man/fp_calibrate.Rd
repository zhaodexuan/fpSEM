\name{fp_calibrate}
\alias{fp_calibrate}
\title{Calibrate an FP threshold for a paired comparison}
\description{
Proposes candidate thresholds between the two medians of paired fit values and
reports the fitting-propensity difference at each candidate. This is useful when
a fixed threshold (for example \code{fmin < 4.0}) is not on the scale of the
data, as is common for empirical or ordinal applications.
}
\usage{
fp_calibrate(fmin_focal, fmin_comparator,
             label_focal = "focal", label_comparator = "comparator",
             grid = NULL, n_grid = 9)
}
\arguments{
\item{fmin_focal, fmin_comparator}{Paired numeric vectors of fit values.}
\item{label_focal, label_comparator}{Model labels.}
\item{grid}{Optional threshold grid. If \code{NULL}, \code{n_grid} points
between the two medians are used.}
\item{n_grid}{Number of candidate thresholds when \code{grid} is \code{NULL}.}
}
\value{
A data frame of class \code{fp_calibrate} with columns \code{threshold},
\code{fp_focal}, \code{fp_comparator}, \code{delta}, and \code{jaccard}.
Attributes include \code{recommended}, \code{medians}, \code{common_n},
\code{informative}, and \code{n_flip}.
}
\examples{
set.seed(1)
f <- c(runif(400, .8, 1.1), runif(100, 1.1, 1.4))
c <- c(runif(100, .8, 1.1), runif(400, 1.1, 1.4))
fp_calibrate(f, c)
}
\seealso{\code{\link{fp_judge}}, \code{\link{fp_compare}}}
