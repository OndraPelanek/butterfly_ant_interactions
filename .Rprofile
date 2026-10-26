# Avoid a slow full-library synchronization scan at every project startup.
Sys.setenv(RENV_CONFIG_SYNCHRONIZED_CHECK = "FALSE")
# Read UTF-8 tables correctly even if R starts in a non-UTF-8 locale (Windows).
if (.Platform$OS.type == "windows" && !l10n_info()[["UTF-8"]]) invisible(Sys.setlocale("LC_CTYPE", ".UTF-8"))

source("renv/activate.R")
