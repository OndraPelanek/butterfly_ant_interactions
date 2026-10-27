# Manuscript files

This directory contains the manuscript source (`lycaenidae_manuscript.Rmd`), with the main text and the Supporting Information, and its rendered Word and HTML documents.

Every number in the text is computed from the notebook outputs in `data/intermediate/` (mainly `s04_fit_models/` to `s06_summarise_results/`), and `stopifnot()` checks in the setup chunks stop rendering if a worded claim no longer matches the results. Figures are read from `results/s05_check_robustness/` and `results/s06_summarise_results/` through the inventory in [`code/R/report_figures.R`](../code/R/report_figures.R); the graphical abstract is read from `data/raw/illustrations/`.

From the repository root, run:

```bash
Rscript code/render_report.R
```

This renders the HTML and Word documents here and then applies the Word table layout (`code/R/docx_layout.R`). On Windows with Microsoft Word installed, a hidden Word instance also updates the table of contents; set `LYCAENIDAE_SKIP_TOC_UPDATE=1` to skip this. **Knit** in RStudio does the same. Rendering reads existing results; it does not rerun the analysis. Close the Word output before rendering to avoid a permission-denied error.

Keep `lycaenidae_references.bib`, `docx_template.docx` and `caption_style.lua` beside the report source; they control the references, the Word styles and the caption layout. `.Rprofile` activates the project environment when RStudio knits from this folder. Table widths are measured in Calibri, so the Word layout matches the reference version only where Calibri is installed. Rendered documents are excluded from Git; the Word template is explicitly allowed.
