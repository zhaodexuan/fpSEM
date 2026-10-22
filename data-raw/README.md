# data-raw

`build-reference.R` regenerates `inst/extdata/fp_reference.csv` from the O6
simulation grid. The raw RDS files are not part of this repository; they live
in the study workspace (`stage0/pilot/main-grid/` and
`stage0/pilot/main-grid-c0/`). Set `base` in the script to that path before
running it.

The bundled CSV is the authoritative reference table for the released package.
The pre-registered design and the study results are available at
<https://doi.org/10.17605/OSF.IO/VG627>.
