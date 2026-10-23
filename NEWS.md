# fpSEM 0.2.0

* Added `wlsmv_fmin` as a statistic and ordinal data spaces.
* Added `fp_calibrate()` for data-driven threshold selection.
* Improper-solution warnings are now graded (>5%, >25%, >95%).
* Added ordinal reference rows (p = 16, 5 categories, n = 1,000).

# fpSEM 0.1.0

* Initial release.
* `fp_judge()` returns a fitting-propensity estimate with its full condition set.
* `fp_compare()` returns paired Delta_FP, a region summary, Jaccard overlap, and
  the number of sign flips.
* `fp_reference()` loads a bundled reference table with 44 rows (22 cells x
  two summaries).
* Continuous-data `fmin`; ordinal kernels (WLSMV/SISQUOC) are not yet included.
