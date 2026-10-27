# Ant-interaction strategy, partner breadth and range size in lycaenid butterflies

This repository contains the analysis used to test whether the strategy of the interaction between lycaenid butterflies and ants (none, facultative, obligate mutualism or obligate parasitism) and the number of recorded ant-partner genera are associated with geographic range size across Lycaenidae. The workflow builds a source-traceable interaction dataset from a literature evidence database, estimates range sizes from cleaned GBIF occurrences, fits taxonomic, spatial and phylogenetic models, checks their robustness, and renders the manuscript with every reported number computed from these results.

## Workflow

Six R Markdown notebooks in `code/` are run in numerical order:

1.  [`s01_prepare_traits.Rmd`](code/s01_prepare_traits.Rmd) combines per-source evidence ledgers, matches names to the GBIF Backbone, clusters duplicate species and classifies each species' interaction strategy and recorded partner breadth.
2.  [`s02_prepare_ranges.Rmd`](code/s02_prepare_ranges.Rmd) cleans the GBIF occurrence download, estimates three range-size measures and their stability under subsampling, and validates them against expert ranges.
3.  [`s03_build_species_tables.Rmd`](code/s03_build_species_tables.Rmd) combines traits, ranges and the revised genus classification into the analysis tables and summarises the modelled ranges of Daru (2025).
4.  [`s04_fit_models.Rmd`](code/s04_fit_models.Rmd) fits the taxonomic mixed models, the spatial and regional-background models, and the species- and genus-level phylogenetic and joint phylogenetic-spatial models.
5.  [`s05_check_robustness.Rmd`](code/s05_check_robustness.Rmd) runs the robustness and sensitivity checks reported in the Supporting Information.
6.  [`s06_summarise_results.Rmd`](code/s06_summarise_results.Rmd) assembles the report tables and draws the report figures.

Each notebook documents its analysis steps beside the code, reads the raw data and the outputs of earlier notebooks, and writes its outputs to its own folder in `data/intermediate`. The manuscript ([`writing/lycaenidae_manuscript.Rmd`](writing/lycaenidae_manuscript.Rmd)) reads these outputs and the report figures in `results/`. The [code README](code/README.md) describes the notebooks and the shared functions in `code/R`, the [data README](data/README.md) the raw and generated data, and the [writing README](writing/README.md) the manuscript files.

## Reproducing the analysis

### 1. Get the code

Clone the repository and work from its root folder, for example by opening the folder as a project in RStudio:

``` bash
git clone https://github.com/OndraPelanek/butterfly_ant_interactions.git
```

On Windows, keep the path of the repository folder below about 120 characters: a few package files have long paths, and Windows limits paths to 260 characters.

### 2. Restore the software environment

Use R 4.5.2. The packages are recorded with `renv`; in a fresh R session at the repository root, run

``` r
source("code/setup_environment.R")
restore_environment()
```

and restart R afterwards. The packages are installed in the project library `renv/library`, which Git ignores. Rendering also needs Pandoc, which is bundled with RStudio.

The results were produced with this environment:

| Component | Version |
|---|---|
| Operating system | Windows 11 (64-bit) |
| R | 4.5.2 (2025-10-31, ucrt) |
| R packages | 212 packages recorded in [`renv.lock`](renv.lock) (renv 1.2.3), all of them used by the code directly or as dependencies |
| Geospatial libraries | GDAL 3.11.0, PROJ 9.6.0 and GEOS 3.13.1, bundled with the Windows builds of `sf` and `terra` |
| Pandoc | 3.6.3 (bundled with RStudio) |

Each rendered notebook ends with its full session information, including the geospatial library versions. Some locked package versions are no longer available as precompiled binaries, so `restore_environment()` builds them from source; on Windows this needs [Rtools 4.5](https://cran.r-project.org/bin/windows/Rtools/rtools45/rtools.html). On Linux and macOS, `sf` and `terra` use the GDAL, PROJ and GEOS versions installed on the system, which can cause small numerical differences.

### 3. Get the data

The data are in the [project OneDrive folder](https://universityofcambridgecloud-my.sharepoint.com/:f:/g/personal/op319_cam_ac_uk/IgDLJVyKBmtwQpxPKGmZyKi-AVbjnqvMmhI8hk3BliF_JPo?e=lr3vOX) (access-controlled; sign in with the Microsoft account the folder was shared with). Download the complete folder with OneDrive's **Download** option (about 4 GB) and extract it outside the repository, keeping its structure:

``` text
<data folder>/
├── starting/raw/            raw data (about 2.4 GB)
└── initial/intermediate/    outputs of all six notebooks (about 1.6 GB)
```

Then link the data to the repository, giving the full path of the folder that contains `starting` and `initial`:

``` r
resrepo::version_relink(resources_path = "C:/path/to/<data folder>")
```

This creates the local links `data/raw` and `data/intermediate`; the data stay outside the repository ([`resrepo` workflow for sharing versioned repositories](https://evolecolgroup.github.io/resrepo/articles/sharing_resrepo.html)). The raw data, their sources and licences are described in the [data README](data/README.md) and in a README in each raw-data folder.

### 4. Rerun the notebooks (optional)

The download already contains the outputs of all notebooks, so the manuscript can be rendered directly (step 5). To recompute everything from the raw data, run from the repository root

``` bash
Rscript code/run_all.R
```

This knits the six notebooks in order, each in a fresh R session, and then renders the manuscript (step 5); it stops at the first notebook that fails. `Rscript code/run_all.R s04` resumes from `s04`, and `Rscript code/run_all.R s02 s03` runs only `s02` and `s03`. Alternatively, knit the notebooks one by one in RStudio (**Knit**), restarting R between them. Each rendered notebook is saved in `results/<notebook>/`.

Approximate run times on a 16 GB laptop: `s01` 1 min, `s02` 1 h, `s03` 15 min, `s04` 2.5 h, `s05` 50 min and `s06` 10 min. Random seeds are fixed, so a rerun reproduces the results.

-   A rerun overwrites `data/intermediate`; keep a separate copy of the download if the published outputs are needed unchanged.
-   `s02` needs several GB of free memory; close memory-intensive programs. If it is interrupted, rerunning it resumes from the range calculations already saved in `data/intermediate/s02_prepare_ranges/ranges/checkpoints/`.
-   Prevent the computer from sleeping during the long notebooks, and do not keep output files open (for example in Excel) while a notebook writes them.

### 5. Render the manuscript

Close the Word document if it is open, then run from the repository root

``` bash
Rscript code/render_report.R
```

or knit `writing/lycaenidae_manuscript.Rmd` in RStudio. This writes the HTML and Word documents to `writing/`. Every number in the text is computed from the notebook outputs, and checks in the manuscript stop the rendering if a worded claim no longer matches the results; a stopped rendering therefore points to a sentence that needs revising. The notebooks `s05` and `s06` copy the report figures to `results/`, from where the manuscript includes them ([`code/R/report_figures.R`](code/R/report_figures.R)).

## Repository contents

-   `code/`: setup script, analysis notebooks, the script that reruns everything, report renderer and shared R functions (`code/R/`)
-   `data/`: data README, data-source inventory, version metadata and links to raw and generated data
-   `results/`: exported report figures (and locally rendered notebooks)
-   `writing/`: manuscript source, bibliography and Word template
