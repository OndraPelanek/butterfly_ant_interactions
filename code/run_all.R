# Rerun the whole analysis: knit the six notebooks in order, each in a fresh R session, then
# render the manuscript. Run from the repository root:
#   Rscript code/run_all.R            all notebooks, then the manuscript
#   Rscript code/run_all.R s04        from s04 to s06, then the manuscript
#   Rscript code/run_all.R s01 s01    s01 only (the manuscript is rendered only when s06 is run)
# Each notebook is knitted with resrepo::knit_to_results(), as by Knit in RStudio, so its
# rendered HTML is saved in results/<notebook>/. The run stops at the first notebook that fails.

notebooks <- c("s01_prepare_traits", "s02_prepare_ranges", "s03_build_species_tables",
               "s04_fit_models", "s05_check_robustness", "s06_summarise_results")
steps <- substr(notebooks, 1, 3)

# --- Notebooks to run ---
args <- commandArgs(trailingOnly = TRUE)
from <- if (length(args) >= 1) match(args[1], steps) else 1L
to <- if (length(args) >= 2) match(args[2], steps) else length(steps)
if (is.na(from) || is.na(to) || from > to) {
  stop("Give the first and, optionally, the last notebook as ", paste(steps, collapse = ", "),
       ", for example: Rscript code/run_all.R s04")
}

# --- Repository root and Pandoc ---
if (!file.exists(".resrepo_version")) stop("Run this script from the repository root.")
# Pandoc ships with RStudio; outside RStudio, use its bundled copy when none is on the PATH.
if (!rmarkdown::pandoc_available() && .Platform$OS.type == "windows") {
  candidate <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if (file.exists(file.path(candidate, "pandoc.exe"))) Sys.setenv(RSTUDIO_PANDOC = candidate)
}
if (!rmarkdown::pandoc_available()) stop("Pandoc is required; set RSTUDIO_PANDOC to its directory.")

# --- Knit the notebooks, each in a fresh R session ---
rscript <- file.path(R.home("bin"), "Rscript")
started <- Sys.time()
for (i in from:to) {
  message(format(Sys.time(), "%Y-%m-%d %H:%M"), "  knitting ", notebooks[i])
  call <- sprintf("resrepo::knit_to_results('code/%s.Rmd')", notebooks[i])
  status <- system2(rscript, c("-e", shQuote(call)))
  if (status != 0) {
    stop(notebooks[i], " failed. After fixing it, resume with: Rscript code/run_all.R ", steps[i])
  }
}

# --- Render the manuscript after a run that includes s06 ---
if (to == length(steps)) {
  message(format(Sys.time(), "%Y-%m-%d %H:%M"), "  rendering the manuscript")
  status <- system2(rscript, file.path("code", "render_report.R"))
  if (status != 0) {
    stop("Rendering the manuscript failed. A failing check means that a worded claim no longer ",
         "matches the results; see the error message above.")
  }
}
message(format(Sys.time(), "%Y-%m-%d %H:%M"), "  finished in ",
        format(round(difftime(Sys.time(), started, units = "hours"), 2)))
