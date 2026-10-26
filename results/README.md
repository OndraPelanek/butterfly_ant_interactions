# Results

Report figures are grouped by the notebook that generates them:

- `s05_check_robustness/`: model diagnostics (Fig. S3)
- `s06_summarise_results/`: Figs 1–4 and S1, S2 and S4–S8

Generated data, fitted objects and the original figures are stored in the corresponding versioned `data/intermediate/s0*` directory. The final chunks of `s05` and `s06` copy every figure used in the report into their results folders, and the report reads these copies. The inventory and copy function are in [`code/R/report_figures.R`](../code/R/report_figures.R).

Rendered notebooks (`results/<notebook>/<notebook>.html`) may be generated locally but are not versioned. The R Markdown sources in `code/` are the canonical analysis documents.
