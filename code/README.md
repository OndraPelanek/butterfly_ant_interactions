# Analysis code

The analysis consists of six R Markdown notebooks, run in numerical order, a script that renders the manuscript and a few shared R functions. Each notebook is a documented, self-contained analysis: it reads the raw data and the outputs of earlier notebooks, writes its outputs to its own folder in `data/intermediate/`, and saves its rendered HTML in `results/`.

| File | Purpose | Principal output |
|----|----|----|
| `setup_environment.R` | Restore the recorded package library | Project `renv` package library |
| `s01_prepare_traits.Rmd` | Combine the per-source evidence ledgers, match names to the GBIF Backbone, cluster duplicate species, apply the classification rules and decision registers, and add phylogenetic rule defaults and wingspan | `data/intermediate/s01_prepare_traits/species_traits.csv`, `evidence_ledger.csv` and the released dataset in `release/` |
| `s02_prepare_ranges.Rmd` | Clean the GBIF occurrences (taxonomy, metadata, coordinate tests, native regions, introductions and outliers), thin the records and estimate range size and its stability; validate against expert ranges | `data/intermediate/s02_prepare_ranges/range_metrics.csv` and `records_final.rds` |
| `s03_build_species_tables.Rmd` | Combine traits, ranges and the revised genus classification into the analysis tables, and summarise the Daru (2025) modelled ranges | `data/intermediate/s03_build_species_tables/species_table.csv` |
| `s04_fit_models.Rmd` | Fit the taxonomic mixed models, the spatial GAM and regional-background models, species- and genus-level PGLS and joint phylogenetic spatial models | Model results in `data/intermediate/s04_fit_models/`, including `main_models.rds` |
| `s05_check_robustness.Rmd` | Partner-breadth diagnostics, rarefied ranges, regional and lineage omissions, carnivory, origins of parasitism, cleaning sensitivity and Box-Cox models; Fig. S3 | Tables in `data/intermediate/s05_check_robustness/`; Fig. S3 copied to `results/s05_check_robustness/` |
| `s06_summarise_results.Rmd` | Assemble the report and supplement tables and draw the report figures | Tables in `data/intermediate/s06_summarise_results/`; figures copied to `results/s06_summarise_results/` |
| `render_report.R` | Render the manuscript to HTML and Word, then apply the Word table layout | `writing/lycaenidae_methods_results.{html,docx}` |
| `run_all.R` | Knit all notebooks in order, each in a fresh R session, then render the manuscript; optional first and last notebook (`Rscript code/run_all.R s04`) | All of the above |

Run `Rscript code/run_all.R` from the repository root, knit each notebook in RStudio, or run `resrepo::knit_to_results("code/s01_prepare_traits.Rmd")` from the repository root. All notebooks have the same structure: an introduction, a setup (packages, variables, folders and functions), one section per analysis step with its inputs and outputs, and a record of the R session. Each section reads its inputs from disk and removes its objects at the end, so the sections are independent of each other apart from the setup. Random seeds are fixed, so reruns reproduce the outputs.

The literature search, the extraction of evidence from publications and the frozen API responses are not part of the code: their results are raw inputs (see the [data README](../data/README.md)). `s01_prepare_traits.Rmd` and `s02_prepare_ranges.Rmd` document in chunks that are not run how the GBIF Backbone snapshot, the GBIF download and the native-region layers were obtained.

## Shared functions

`R/` holds the functions used by more than one notebook; functions needed by one notebook only are defined in that notebook.

| File | Contents | Used by |
|----|----|----|
| `write_table.R` | Writing the output tables | all notebooks |
| `name_matching.R` | Reading the GBIF Backbone snapshot, name normalisation and matching | s01, s02, s03, s04 |
| `projections.R` | Equal Earth projection and grids | s02, s03, s04, s05, s06 |
| `range_metrics.R` | Range measures and their stability (some used only by the parallel workers of s02, which source this file) | s02, s03, s05, s06 |
| `thinning.R` | Spatial thinning | s02, s06 |
| `trait_evidence_corrections.R` | Partner breadth without the attack and questionable records of Fiedler (1991) | s03, s05 |
| `models.R` | Taxonomic mixed models with estimated means and contrasts | s04, s05, s06 |
| `geography.R` | Presence cells, the regional range-size background, the spherical GAM and great-circle distances | s04, s05, s06 |
| `phylogeny.R` | Reading the published trees, matching their tips to species, and PGLS | s01, s04, s05, s06 |
| `report_figures.R` | Inventory of the report figures and their copying to `results/` | s05, s06, manuscript |
| `manuscript.R`, `docx_layout.R` | Tables, numbers and figures of the manuscript, and the Word table layout | manuscript |
