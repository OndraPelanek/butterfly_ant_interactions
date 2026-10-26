# RStudio's Knit may start R in writing/; activate the project environment
# from the repository root before the report's output format is loaded.
local({
  writing_directory <- getwd()
  setwd("..")
  tryCatch(sys.source(".Rprofile", envir = globalenv()), finally = setwd(writing_directory))
})
