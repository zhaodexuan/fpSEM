# fpSEM

**Fitting propensity for structural equation models.**

`fpSEM` is an R package for computing and comparing *fitting propensity* (FP):
the tendency of a model to fit diverse data patterns. A model can fit a dataset
well because it is close to the truth, or because it can fit almost anything.
`fpSEM` makes the second possibility explicit, and it refuses to return a single
FP number without the conditions that make it interpretable.

This package is the software companion to a manuscript in preparation on
fitting propensity in factor models. The study design and results are
pre-registered on OSF: <https://doi.org/10.17605/OSF.IO/VG627>.

## Why this package

Two models can differ in fit for reasons that have nothing to do with which one
is closer to the data-generating process. They can differ in the number of free
parameters, in the data space on which FP is computed, in how non-converged
draws are handled, in how the threshold is summarized, and in which fit
statistic is used. `fpSEM` treats these as *design choices*, not as nuisance
details, and returns them alongside every estimate.

## Installation

```r
# install.packages("remotes")
remotes::install_github("zhaodexuan/fpSEM")
```

For a local source checkout:

```r
install.packages(".", repos = NULL, type = "source")
```

## Quick start

```r
library(fpSEM)

# Bundled reference values (p = 16, fmin < 4.0)
fp_reference(model = "B4", data_space = "full_elliptope", convergence = "force")

# One model
set.seed(1)
f <- c(runif(400, 3, 3.9), runif(100, 4.5, 6))
fp_judge(
  fmin = f, df = 88, q = 48, n_obs = 1000,
  threshold = 4,
  data_space = "full_elliptope",
  convergence = "force",
  improper_rate = .99
)

# Two paired models
fp_compare(
  fmin_focal = f, fmin_comparator = rev(f),
  df_focal = 88, df_comparator = 98,
  q_focal = 48, q_comparator = 38,
  n_obs = 1000,
  data_space = "full_elliptope",
  convergence = "force"
)
```

## The output contract

`fp_judge()` and `fp_compare()` enforce five rules:

1. **No single number.** The result is a condition set, not a verdict.
2. **No pass/fail.** The result has `informative` and `warnings`, not
   `significant` or `correct`.
3. **No silent defaults.** Missing `data_space`, `threshold`, `df`, or (for
   RMSEA) `formula_n` is an error.
4. **Small common samples are uninformative.** If `common_n < 100`, `fp` and
   `delta_fp` are `NA`, and a warning is issued.
5. **Improper solutions are visible.** If `improper_rate > .95`, a warning is
   issued. "Converged" and "admissible" are different concepts.

`fp_compare()` also warns when the single-threshold and region summaries differ
by more than 10%, or when they have opposite signs.

## What's new in 0.2.0

- `wlsmv_fmin` as a statistic and ordinal data spaces.
- `fp_calibrate()` for data-driven threshold selection.
- Graded improper-solution warnings (>5%, >25%, >95%).
- Eight ordinal reference rows (B0/B1 x B4/CF4).

## Reference table

`fp_reference()` loads `inst/extdata/fp_reference.csv`, with continuous and
ordinal rows:

- 44 continuous rows: 14 force-converged cells and 8 default-convergence cells,
  each with a `single` (`fmin < 4.0`) and a `region` (`fmin` in [3, 6]) summary.
- 8 ordinal rows: B0/B1 x B4/CF4 x `single`/`region`, `wlsmv_fmin`, p = 16,
  5 categories, n = 1,000.

The continuous table was generated at `p = 16`, with `sample.nobs = 1000` and
lavaan 0.7.3. The ordinal grid converged 1,000/1,000 in every cell but
98.2%-99.5% of solutions were improper; read the `improper_rate` column before
using the ordinal rows. Recompute for other dimensions.

## Reproducibility

The bundled table was generated from the O6 simulation grid (5,000 draws per
cell; lavaan 0.7.3). The raw RDS files are not bundled, because they belong to
the study repository. `data-raw/build-reference.R` documents the generation;
`data-raw/README.md` explains the layout. The pre-registered design is at
<https://doi.org/10.17605/OSF.IO/VG627>.

## Status

Version 0.2.0 supports continuous-data `fmin` and ordinal WLSMV
`wlsmv_fmin`/`SRMR`. The ordinal grid converged 1,000/1,000 in every cell, but
98.2%-99.5% of solutions were improper; ordinal reference values are therefore
FP under improper solutions. SISQUOC/Bayesian ordinal FP is not yet included.
The package is not yet on CRAN.

## Citation

If you use `fpSEM` in academic work, please cite the package and the companion
manuscript. See `CITATION.cff`.

## Contributing

Issues and pull requests are welcome. See `CONTRIBUTING.md`. Please run
`R CMD check --no-manual` before submitting a pull request.

## License

MIT (c) 2026 Dexuan Zhao. See `LICENSE.md`.
