# Restore the project package library from the renv lockfile.
# Source this file from the repository root, then call restore_environment()
# in a fresh R session before running the notebooks or rendering the report.

project_root <- normalizePath(".", winslash = "/", mustWork = TRUE)
lockfile <- file.path(project_root, "renv.lock")

if (!file.exists(file.path(project_root, ".resrepo_version")) ||
    !file.exists(lockfile)) {
  stop("Run this script from the butterfly_ant_interactions repository root.")
}

options(repos = c(CRAN = "https://cloud.r-project.org"))

if (!requireNamespace("renv", quietly = TRUE)) {
  sys.source(file.path(project_root, "renv", "activate.R"), envir = globalenv())
}

if (!requireNamespace("renv", quietly = TRUE)) {
  stop("Could not activate renv. Restart R at the repository root and try again.")
}

restore_environment <- function() {
  renv::restore(project = project_root, lockfile = lockfile, prompt = FALSE)
  renv::status(project = project_root, lockfile = lockfile)
  message("The package environment has been restored. Restart R before analysis.")
  invisible(lockfile)
}
