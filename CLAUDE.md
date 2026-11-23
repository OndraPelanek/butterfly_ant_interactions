# butterfly_ant_interactions — notes for Claude

Analysis and manuscript on ant-interaction strategy, partner breadth and range size in lycaenid butterflies (target journal: Global Ecology and Biogeography). Read `README.md` for the workflow, the software environment and the data, and read the README of the folder you work in (`code/`, `data/`, `writing/`).

## Scope
- Before working in any directory, read the scoped instructions along the path from the repository root to that directory, even when the session starts at the root. In Claude Code, look for `CLAUDE.md`. In Codex, check `AGENTS.override.md`, `AGENTS.md` and `CLAUDE.md` in that order and use the first non-empty file in each directory. Apply each file within its own subtree, with the closest file taking precedence where instructions conflict. Check again when work moves into a new subtree.
- For the manuscript, the Supporting Information, figures for the report and any longer prose, follow `writing/CLAUDE.md` as well.
- Work only on the notebook or text you were asked about. Change shared code (`code/R/`) only when asked; then keep the change minimal and validate it by rerunning the notebooks that use it (`code/README.md` lists which notebook uses which file).
- Within that scope, don't ask permission for routine actions (editing its files, rendering its notebooks, running its models within the laptop's limits).
- Other Claude sessions may work in parallel in this checkout: don't edit, re-render or stop anything of theirs.
- The earlier repository `lycaenidae_ant_interactions` (until 2026-10-24) stays unchanged. All new work happens here.
- Decisions with scientific consequences (which species, records or data sources to include, how an interaction type is coded, cleaning thresholds, which analyses enter the main text): recommend with evidence and let Ondrej decide.

## Data and environment
- Every path via `resrepo::path_resrepo()` (skill `resrepo`). `data/raw` and `data/intermediate` are links into the versions store on OneDrive; `results/` and `writing/` stay local. Never run `init_resrepo()`, `version_setup()`, `version_add()`, `renv::init()` or upgrade packages. Branch switches and merges run git hooks that delete and recreate the data links: do not switch branches or merge without telling Ondrej.
- renv: the library is inside the repository (`renv/library`), because the Claude desktop app virtualises `%LOCALAPPDATA%` and anything installed there is invisible to Ondrej's RStudio. `renv.lock` pins the packages the results were produced with (R 4.5.2, renv 1.2.3): do not restore, snapshot or install without Ondrej, and tell him to restart R after any environment change. `.Rprofile` skips renv's slow library check at start-up (`RENV_CONFIG_SYNCHRONIZED_CHECK=FALSE`) and sets a UTF-8 locale.
- `data/raw` holds the frozen inputs (evidence ledgers, decision registers, GBIF snapshots, expert ranges): add new files, but don't delete or overwrite existing ones. Working outputs go to `data/intermediate/<notebook_basename>/` (for example `data/intermediate/s02_prepare_ranges/`).
- Outputs are expensive (run times in `README.md`: s02 about 1 h, s04 about 2.5 h, s05 about 50 min): never delete or overwrite `data/intermediate` to test something. Emptying it also stops the manuscript from rendering until the rerun ends. Test in a scratch copy with a short path (Windows paths over 260 characters fail; for example `%TEMP%/b25`) and compare outputs with the saved ones (md5 or values). Deleting `data/intermediate/s02_prepare_ranges/ranges/checkpoints/` makes the next s02 run recompute all ranges (about 10 h).
- Move superseded outputs into a dated archive folder instead of deleting them; a removed analysis goes to `archive/<what>_<date>/` with a short README.md, never into the bin.
- Check free RAM and disk before heavy jobs (s02 needs several GB). Long runs go in the background with a log file, are resumable (`Rscript code/run_all.R s04` resumes from s04) and need the laptop kept awake.
- OneDrive files can be online-only placeholders. "The cloud file provider exited unexpectedly" means the sync client hung: restart it (`Stop-Process -Name OneDrive`, then `Start-Process "C:\Program Files\Microsoft OneDrive\OneDrive.exe" /background`) and pin the folder you need with `attrib +P -U <folder> /S /D`.

## The analysis
- Six self-contained notebooks `code/s01_...Rmd` to `code/s06_...Rmd` (traits, ranges, species tables, models, robustness, summary), run in order with `Rscript code/run_all.R [first] [last]` or Knit. Each section reads its inputs from disk and removes its objects at the end. Random seeds are fixed.
- Shared functions live in `code/R/` only when more than one notebook uses them; a function used by one notebook stays in that notebook.
- A change of layout or comments only (blank lines, comment text, line breaks) is checked by comparing `deparse(parse(..., keep.source = FALSE))` per chunk, or `knitr::purl()` before and after; it needs no rerun. Any change of code logic is checked by rerunning the notebook and comparing outputs.
- Maps count and average species in equal-area cells (skill `crstools`: Equal Earth from `suggest_crs()`), with the same cell size in every report map (500 km). Longitude–latitude cells shrink towards the poles.
- Report figures are written by s05 and s06 to `data/intermediate/...` and copied to `results/<notebook>/` through `code/R/report_figures.R`; the manuscript reads only those copies.
- Rendering a figure with ragg after a `theme_minimal(base_size = 13)` plot changes how later figures size many small points in the same R session, so s06 draws the phylogeny figure in a fresh `Rscript` process. Keep such figures in their own process.

## Writing code (copied from Ondrej's global instructions)
- As few helper functions as possible. Write a named function only when it is necessary or will be called many, many times; otherwise code directly, with a loop or `lapply()` where something repeats.
- Prefer functions from published R packages (including our group's packages) over hand-written code.
- Keep code simple and brief, yet efficient. It must be easy for a person to read and follow.
- Comment extensively: say what each step does and why, in plain words.
- Save intermediate data and outputs as text files (CSV) wherever reasonable, so they can be read, diffed and checked; use binaries (`.rds`, rasters) only for objects that text cannot hold well (fitted models, spatial or nested objects, large arrays).
- Descriptive snake_case names that say what an object holds (`batch_table`, `usable_runs`, `scheme_pi`), with the prefixes already used (`dir_`, `path_`, `n_`) and the names the package's own vignettes use for its objects. No one-letter or vague names (`d`, `p`, `tmp`, `plan`), except `i`/`j` loop counters and `x` in one-line anonymous functions; never reuse R or knitr names (`params`, `data`, `levels`, `c`). Name chunks the same way (`load_packages`, `setup_variables`, `setup_folders`, `load_functions`).

## Writing text (copied from Ondrej's global instructions)
- Brief and clear: the point first, short sentences with one idea each, and only what the reader needs.
- Sound like Ondrej: plain, descriptive words and British spelling (colour, modelling, standardise). Leave out filler and hype ("crucially", "key insight", "robust", "seamless"), em-dash chains, lists of three for rhythm, bold labels on every paragraph, and closing sentences that repeat the paragraph.
- Phrase things positively: say what something is or does. Use contrasts such as "X, not Y" or "not X but Y" only when a reader would otherwise get it wrong.
- Give real numbers with units. In notebooks and the manuscript, compute numbers in the text with inline R (`r ...`) so that they follow the data.
- Use few colons inside sentences. Write two sentences instead, or join them with a plain word ("so", "because", "as").
- Keep one term per thing throughout a document, and give every "it", "this" and "these" a clear antecedent.
- Below each equation, give a "where" list that defines every symbol (with its unit or the value used), then a sentence or two on why it holds. Name the source and its assumptions, and check the formula against the source or a small simulation before relying on it.
- Say in the text what each figure plots (observed data or an expectation), the inputs and assumptions behind any expectation, and what each axis shows.
- Reports, papers and the manuscript follow `writing/CLAUDE.md` as well (voice, argument, claims, citations, figures); read it before writing longer prose.
- For issues, emails and comments to colleagues: first person, short and direct, with minimal runnable code where it helps, ending with the question or the proposed next step.

## Notebook style
- R Markdown with `knit: resrepo::knit_to_results` in the YAML header; sections Setup (Packages, Variables, Folders, Functions), one section per analysis step with its inputs and outputs, a short comment above each block, and a final chunk recording the R session. Follow the existing notebooks (hartebeest style): blank lines between blocks, `# --- Title ---` sub-headings, lines up to 100 characters, no `;`.
- tidyverse style. Paths in Setup use `dir_data_raw`, `dir_data_intermediate` and `dir_s01`, `dir_s02` ... for the folders of earlier notebooks.
- A chunk printing several `knitr::kable()` tables needs `results = "asis"` and explicit `print()`; otherwise only the last one appears.
- Use plain, descriptive terms, not jargon such as "manifest", also in file and object names (`input_files_md5.csv`, `batch_table.csv`).

## Git
- Ondrej does all commits and pushes; never commit and never offer to. Say in the summary that changes are uncommitted.
- `data/raw`, `data/intermediate`, `versions` and rendered HTML or Word files are git-ignored. Do not add data to git.

## This Windows laptop
- Run `Rscript` by its full path (`C:\Program Files\R\R-4.5.2\bin\x64\Rscript.exe`; from PowerShell if Git Bash misbehaves). Pandoc for rendering: `RSTUDIO_PANDOC=C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools`. Test-render into a temporary `output_dir` and `intermediates_dir`, not `results/` or `writing/`.
- PowerShell pitfalls: `Set-Content`/`Out-File -Encoding UTF8` add a byte-order mark that R cannot parse (write with the Write tool or `[IO.File]::WriteAllText(path, text, (New-Object Text.UTF8Encoding $false))`); `$` inside `Rscript -e "..."` is expanded by PowerShell, so put longer R code in a script file. Git Bash heredocs strip backslashes, so write R scripts with the Write tool.
- `render(quiet = TRUE)` hides warnings, and errors caught by `tryCatch` → `warning()` vanish with them. To debug, `knitr::purl()` the notebook, prepend `options(warn = 1)` and run it as a script with a log.
- Several Claude sessions and R jobs often run at once: check RAM, use few parallel workers, and never stop processes you did not start.

## Literature and web sources
- The evidence database rests on literature. Open full text: archive.org (`https://archive.org/stream/<id>/<id>_djvu.txt`; find items with `https://archive.org/advancedsearch.php?q=...&fl[]=identifier&output=json`), BHL, Gutenberg, zobodat, institutional repositories. Old OCR uses the long s ("f" for "s") and splits hyphenated words: search with short fragments before calling a quote unverifiable.
- Scripted downloads fail on Wiley, MDPI, ResearchGate, Taylor & Francis and Cloudflare-protected sites (check that a download starts with `%PDF`, delete HTML stubs). Wiley and MDPI full text often opens in the in-app browser. Proof-of-work checks (ALTCHA on Persée, e-periodica) must not be bypassed: list those papers for Ondrej, with a direct link and a suggested file name; his downloads land in `C:\Users\ondra\Downloads`.
- Nominatim geocoding: generic User-Agent (never Ondrej's email), at most 1 request per second.
- Research agents: give each its own output folder and scratch scripts (shared scripts got overwritten), have it write results after every source, and spot-check one quote per agent against the source before merging. Agents stopped by the usage limit keep their work and resume with `SendMessage`.

## Skills for our R packages and for writing
- `.claude/skills/<name>/` (tracked by Git) holds one skill per package and one for writing. Codex reads the same folders through `.agents/skills`, a set of local junctions that Git ignores (after a fresh clone, recreate them with `New-Item -ItemType Junction -Path .agents/skills/<name> -Target <full path of .claude/skills/<name>>`):
  - `resrepo`: paths, data versions, knitting, git hooks;
  - `crstools`: choosing the map projection (Equal Earth cells);
  - `tidysdm`: spatial thinning (`thin_by_cell()`, `thin_by_dist()`);
  - `scientific-writing`: structure and argument of papers, GEB limits (use it with `writing/CLAUDE.md`).
- Use a package's functions before writing new code, and add lessons learnt to the skill. The skills were copied from the african_diversity repository on 2026-11-23 and adapted; the skills there for pastclim, geograph, tidypopgen, tidygenclust and the CISGeM tools are not needed here.
- To build one:
  - Read the local source clone (`C:\Users\ondra\Documents\Cambridge\git\<package>`): its vignettes, `NEWS.md` and dev notes (known bugs).
  - Generate `references/functions.md` from the installed renv version with `scripts/make_function_reference.R` (copy it from an existing skill). Rerun it when the package is updated.
  - Record which version the skill describes: renv and the source clone can differ.
  - Keep `SKILL.md` under ~500 lines: the workflow (each step mapped to its function), the project's conventions (with the notebook and chunk where they live), and pitfalls with the reason for each.
  - Write a "pushy" description naming the tasks that should trigger it.

## Where to start
- `README.md` (workflow and reproduction), `code/README.md` (notebooks and shared functions), `data/README.md` (raw and generated data, file lists), `writing/README.md` (manuscript files).
