# Writes the output tables of all notebooks.

#' Write a data frame as a UTF-8 CSV without row names, with missing values as empty fields
#'
#' @param x Data frame to write.
#' @param path Destination file; missing parent folders are created.
write_table <- function(x, path) {
  dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
  write.csv(x, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
}
