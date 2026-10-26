# Render the manuscript (HTML and Word) into writing/ from the notebook outputs; nothing is
# recomputed. Run from the repository root: Rscript code/render_report.R
# The Word file then receives the table layout of code/R/docx_layout.R. Close the Word document
# before rendering, otherwise it cannot be overwritten.
source(here::here("code", "R", "docx_layout.R"))
# Kenward-Roger degrees of freedom in emmeans need pbkrtest; without it emmeans silently falls
# back to other degrees of freedom.
if (!requireNamespace("pbkrtest", quietly = TRUE)) stop("pbkrtest is missing; restore the environment first.")
# Pandoc ships with RStudio; outside RStudio, use its bundled copy when none is on the PATH.
if (!rmarkdown::pandoc_available() && .Platform$OS.type == "windows") {
  candidate <- "C:/Program Files/RStudio/resources/app/bin/quarto/bin/tools"
  if (file.exists(file.path(candidate, "pandoc.exe"))) Sys.setenv(RSTUDIO_PANDOC = candidate)
}
if (!rmarkdown::pandoc_available()) stop("Pandoc is required; set RSTUDIO_PANDOC to its directory.")

report <- here::here("writing", "lycaenidae_methods_results.Rmd")
for (format in c("bookdown::html_document2", "bookdown::word_document2")) {
  output <- rmarkdown::render(report, output_format = format, quiet = TRUE,
                              envir = new.env(parent = globalenv()))
  if (format == "bookdown::word_document2") finalise_publication_docx(output)
}
