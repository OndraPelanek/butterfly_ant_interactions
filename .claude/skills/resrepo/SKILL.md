---
name: resrepo
description: How the butterfly_ant_interactions repository is organised and how to find, read and write files in it with the resrepo R package (the group's own package, EvolEcolGroup) - path_resrepo() for every project path, find_git_root(), the data/raw and data/intermediate links into the versions store, version metadata (get_versions_in_use), the knit - resrepo::knit_to_results hook that sends rendered notebooks to results/, and the folder and naming conventions for code, data, results and writing. Use it whenever code builds a file path, decides where an output goes, renders or knits a notebook, creates a new notebook or data folder, or touches data versions, links, git hooks or .gitignore - and before ever calling init_resrepo, version_setup, version_add, version_relink, update_links or init_mirror, which must not be run without Ondrej.
---

# resrepo: paths, data versions and knitting in this repository

resrepo (Manica et al.; EvolEcolGroup, contributors include Ondrej) sets the repository's
structure. In this project it gives three things every notebook depends on:
- `path_resrepo()` for every path;
- data folders that are links into a "versions" store outside the repository;
- the `knit_to_results` hook that sends rendered notebooks to `results/`.

**Read and write through `path_resrepo()`, follow the folder conventions, and never run the
functions that restructure the repository.**

*Adapted on 2026-11-23 from the african_diversity version of this skill. Facts below were
checked in this repository on that date.*

## Version and where to look

- renv library and `renv.lock` agree: resrepo **0.3.0.9000**, installed from GitHub
  (EvolEcolGroup/resrepo, branch `dev`, commit `1b33592`). `.resrepo_version` in the root
  also reads `0.3.0.9000`.
- `references/functions.md`: all 12 exported functions (installed version), generated from
  the help pages. Regenerate (repository root):
  `Rscript .claude/skills/resrepo/scripts/make_function_reference.R resrepo .claude/skills/resrepo/references/functions.md C:/Users/ondra/Documents/Cambridge/git/resrepo`
  (the third argument is the source clone; omit it if only the installed help pages are
  needed).
- Source: `R/` in the clone `C:\Users\ondra\Documents\Cambridge\git\resrepo` (small: read
  the function before relying on an edge case). Vignettes: `resrepo.Rmd` (template, naming),
  `data_versioning.Rmd` (versions, links), `sharing_resrepo.Rmd` (cloning and relinking
  data elsewhere).
- Project rules on top of resrepo: root `README.md` (steps to reproduce), `code/README.md`
  (notebooks and shared functions), `data/README.md` (raw and generated data, file lists)
  and root `CLAUDE.md`.

## How this repository is laid out

| Path | What it is |
|---|---|
| `code/s01_...` to `s06_...Rmd` | The six notebooks, directly in `code/` (no species or area subfolders) |
| `code/R/` | Shared functions, sourced by the notebooks (`projections.R`, `range_metrics.R`, `thinning.R` ...) |
| `code/run_all.R`, `code/render_report.R`, `code/setup_environment.R` | Rerun all notebooks, render the manuscript, restore renv |
| `data/raw` | **link** to `versions/starting/raw`. Original and frozen inputs: add files, never delete or overwrite |
| `data/intermediate` | **link** to `versions/initial/intermediate`. Outputs: `data/intermediate/<notebook_basename>/` (for example `s02_prepare_ranges/`) |
| `versions` | **link** to the OneDrive store `...\OneDrive - University of Cambridge\butterfly_ant_interactions\external_data_storage\versions\` (git-ignored) |
| `data/version_meta/` | `raw_in_use.meta` = `starting`, `intermediate_in_use.meta` = `initial`, plus one `.meta` per version (tracked by git) |
| `data/metadata/` | Tracked documentation of the data sources (`data_source_list.csv`) |
| `results/<notebook_basename>/` | Report figures copied by s05 and s06, and locally rendered notebooks (HTML and `_files` are git-ignored) |
| `writing/` | Manuscript, bibliography, Word template (see `writing/CLAUDE.md`) |

`get_versions_in_use()` returns `raw = "starting"` and `intermediate = "initial"` (checked
2026-11-23). Because the notebooks sit directly in `code/`, `knit_to_results()` writes to the
flat `results/<notebook_basename>/`; with notebooks in `code/<subfolder>/` it would add the
subfolder.

## Functions: what to use, what never to run

| Function | Use? | What it does |
|---|---|---|
| `path_resrepo(path, version = NULL, check_exists = FALSE)` | **always** | `find_git_root()` + `path`, slashes normalised. Write paths without a leading slash: `path_resrepo("data/intermediate/s02_prepare_ranges")`. `check_exists = TRUE` stops if the path is missing. |
| `find_git_root(path = ".")` | yes | Walks up from the working directory (or `path`) to the folder holding `.git`. Stops if the repository is called "resrepo". |
| `path_relative(path, base = getwd())` | yes | Relative path between two absolute paths. |
| `get_versions_in_use(check_links = TRUE)` | yes (read-only) | Versions in use and a link check; a quick sanity test when paths look wrong. |
| `knit_to_results` | via YAML `knit: resrepo::knit_to_results` | Renders the Rmd in place, then **moves** `<name>.html/.pdf/.md/.docx` and `<name>_files/` to `results/<name>/`; renames `<name>.md` to `README.md`. All six notebooks have this YAML line. |
| `create_rmd(filename)` | no | resrepo's generic template. The notebooks here have their own structure (root `CLAUDE.md`): copy the nearest existing notebook instead. |
| `init_resrepo()` | **never** | Copies the template over the repository root (overwriting `README.md`, `.gitignore` ...) and **commits**. |
| `init_mirror(path)` | **never** | Creates a parallel folder tree elsewhere from resrepo's mirror template. Not used here. |
| `version_setup()` | **never** | Moves `data/raw` and `data/intermediate` into `versions/`, deletes the originals, links them, edits `.gitignore`, **commits twice** and installs git hooks. The versions here were set up on 2026-10-20 (`data/version_meta/*.meta`). |
| `version_add()` | **never** (Ondrej only) | Copies a whole data version, creates a git branch, **commits and pushes** to origin. |
| `version_relink(quiet, resources_path)`, `update_links()` | only on Ondrej's instruction | Delete and recreate the `data/` and `versions` links. This is the documented way to link a downloaded data bundle on a new machine (`resources_path` = folder holding `starting/raw` and `initial/intermediate`; root `README.md`, step 3). It also installs the git hooks (pitfall 5). |

## Knitting and outputs (project rules)

- Press **Knit** in RStudio, run `resrepo::knit_to_results("code/s04_fit_models.Rmd")` from
  the repository root, or `Rscript code/run_all.R [first] [last]`, which does the same in
  a fresh R session per notebook (and renders the manuscript at the end).
- Calling `rmarkdown::render()` directly bypasses the hook. The HTML then lands in `code/`
  next to the notebook. For test renders pass a temporary `output_dir` and
  `intermediates_dir`, so that nothing in `data/intermediate/` or `results/` changes.
- The hook moves only the rendered report and its `_files` folder. Everything a chunk writes
  needs its own `path_resrepo()` path under `data/intermediate/<notebook_basename>/` (or
  `results/` for report figures, via `code/R/report_figures.R`).
- The manuscript has its own knit hook (`writing/lycaenidae_manuscript.Rmd`: render to
  HTML and Word, then `finalise_publication_docx()`); render it with
  `Rscript code/render_report.R` or Knit.
- Folder rule from the resrepo vignette: nothing directly in `data/raw` or
  `data/intermediate`; always a first-level subfolder. Data made by a script live in a
  folder named after that script. Names are descriptive, ordered and without spaces.
- Notebook setup chunks use the project's names: `dir_data_raw <- path_resrepo("data/raw")`,
  `dir_data_intermediate <- path_resrepo("data/intermediate/<notebook_basename>")`, and
  `dir_s01`, `dir_s02` ... for the folders of earlier notebooks.

## Pitfalls (and why they matter)

1. **`path_resrepo(..., version = )` is broken.** It stops unless the path starts with
   `/data` ("version can only be specified for paths starting with /data", tested
   2026-11-23) and builds `versions/<v>/data/raw/...`, whereas the store is
   `versions/<v>/raw/...`. To reach another version, use `path_resrepo("versions/<v>/raw/...")`.
2. **Leading-slash shortcuts produce `//`**: `path_resrepo("/d/i/s02_prepare_ranges")` returns
   `.../butterfly_ant_interactions//data/intermediate/s02_prepare_ranges` (tested). It works
   for file access but breaks string comparisons and `startsWith()` checks. Use the full
   name without a leading slash.
3. **Paths depend on the working directory**: `find_git_root()` starts at `getwd()`. R started
   outside the repository, or a `setwd()` out of it, gives "not a git repository". Start R at
   the repository root (renv also needs that).
4. **Deleting through a link deletes data.** `unlink("data/raw", recursive = TRUE)`,
   `fs::dir_delete()` or `rm -rf` on `data/raw`, `data/intermediate` or `versions` can remove
   the files behind the link. Remove a link only with `fs::link_delete()`, and never
   automatically. Root `CLAUDE.md`: never delete or overwrite expensive outputs
   (s02 ranges take about 1 h, s04 about 2.5 h); archive superseded outputs in a dated
   subfolder.
5. **The resrepo git hooks are installed here** (`.git/hooks/post-checkout` and
   `post-merge`, checked 2026-11-23). After every checkout or merge they run
   `rm -rf data/raw` and `rm -rf data/intermediate` and recreate the links with
   `mklink /j` from `data/version_meta/*.meta`. They stop with an error if a data folder is a
   real directory. So do not switch branches, merge or pull without telling Ondrej, and
   check `get_versions_in_use()` and `ls data/raw` afterwards. Do not install or remove
   hooks (`version_setup()` and `version_relink()` install them).
6. **Data stay out of git**: `.gitignore` lists `versions`, `data/raw` and `data/intermediate`;
   `.renvignore` skips `versions/`, `data/` and `results/`. Rendered HTML and `_files` in
   `results/` and `writing/` are ignored too. Do not add data files to git.
7. **OneDrive placeholders**: the `versions` store is on OneDrive, so files may be online-only.
   A "cloud file provider exited unexpectedly" error comes from the sync client, not from
   resrepo.
8. **`knit_to_results` overwrites** the report of the same name in `results/<notebook>/` and
   renames `.md` to `README.md` (`rename_md = TRUE`).
9. **Do not restore or snapshot renv** without Ondrej: `renv.lock` pins the versions the
   results were produced with (root `README.md`, "Restore the software environment").
