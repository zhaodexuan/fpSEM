# Upload checklist

Before pushing to GitHub, replace the placeholders and run the local checks.

## 1. Replace placeholders

- [x] `OWNER` replaced with `zhaodexuan` in `README.md`, `CITATION.cff`, and
      `DESCRIPTION` (`URL`, `BugReports`).
- [x] Author metadata set to Dexuan Zhao / GitHub noreply email; change if
      needed.
- [ ] Optional: add the paper DOI or preprint URL to `README.md` once available.

## 2. Local checks

```r
R CMD build .
R CMD check --no-manual fpSEM_0.1.0.tar.gz
```

The check should end with `Status: OK`. The three test files under `tests/`
should run without error.

## 3. Create the repository

On GitHub, create an empty repository named `fpSEM` (do not initialize it with
a README, because this folder already has one).

## 4. Push

```bash
git init -b main
git add .
git commit -m "fpSEM 0.1.0"
git remote add origin https://github.com/OWNER/fpSEM.git
git push -u origin main
```

If Git is not installed, install Git for Windows, or use GitHub Desktop, or
upload the folder contents through the GitHub web interface.

## 5. After the first push

- [ ] Confirm that the `R-CMD-check` workflow passes on GitHub Actions.
- [ ] Add repository topics: `r`, `structural-equation-modeling`,
      `fitting-propensity`, `bifactor`, `psychometrics`.
- [ ] Optional: archive the release on Zenodo and add the DOI to `README.md`.
- [ ] Optional: add a `pkgdown` site.
