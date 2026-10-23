# data-raw

`build-reference.R` regenerates `inst/extdata/fp_reference.csv` from the O6
simulation grid. The raw RDS files are not part of this repository; they live
in the study workspace (`stage0/pilot/main-grid/` and
`stage0/pilot/main-grid-c0/`). Set `base` in the script to that path before
running it.

The bundled CSV is the authoritative reference table for the released package.
The pre-registered design and the study results are available at
<https://doi.org/10.17605/OSF.IO/VG627>.

## Ordinal reference rows

`build-ordinal-reference.R` appends the ordinal rows (p = 16, 5 categories,
n = 1,000, `wlsmv_fmin`) to `inst/extdata/fp_reference.csv`. It reads the O6
ordinal grid (`stage0/pilot/ordinal-grid/ordinal_grid.csv`), which is not
bundled. The ordinal grid is 98.2%-99.5% improper; the reference rows carry the
improper rate.
