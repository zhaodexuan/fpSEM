# Contributing to fpSEM

Thanks for your interest. Please open an issue before a large pull request so
that we can agree on the scope.

## Development workflow

1. Fork the repository and create a branch.
2. Make the change and add a test under `tests/`.
3. Run:

   ```r
   R CMD build .
   R CMD check --no-manual fpSEM_0.1.0.tar.gz
   ```

4. Open a pull request with a short description and the check result.

## Design constraints

The output contract is part of the package, not an implementation detail.
Please do not add a code path that returns a single FP number, a pass/fail
verdict, or a silent default for `data_space`, `threshold`, `df`, or
`formula_n`. If a change affects the contract, open an issue first.

## Style

- Base R is preferred; the package has no runtime dependencies beyond `stats`
  and `utils`.
- Keep functions small and return named lists with classes.
- Document exported functions in `man/`.
