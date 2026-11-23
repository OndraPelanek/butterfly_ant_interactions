# Build references/functions.md for a skill from a package's help pages, so the
# reference matches the version the notebooks actually use. Rerun after the package
# is updated (PowerShell, from the repository root so renv activates):
#
#   Rscript .claude/skills/<skill>/scripts/make_function_reference.R <package> .claude/skills/<skill>/references/functions.md [source_dir]
#
# - If <package> is installed in the project library, its installed help pages are used.
# - If it is NOT installed, give the local source clone as [source_dir]: the man/*.Rd
#   files and NAMESPACE of that clone are used instead (the header says so).
# For each help topic it keeps title, description, usage, arguments (and format for
# datasets); details, value and examples are in ?function or the source man/*.Rd.
# Same script in every package skill of this repository (tidysdm/pastclim/rcisgem
# copies are older variants without the source fallback).

args <- commandArgs(trailingOnly = TRUE)
pkg <- args[1]
out <- args[2]
src <- if (length(args) >= 3) args[3] else NA_character_
stopifnot(!is.na(pkg), !is.na(out))
installed <- requireNamespace(pkg, quietly = TRUE)
if (!installed && (is.na(src) || !dir.exists(file.path(src, "man"))))
  stop(pkg, " is not installed: give its source clone as the third argument")

quote_type <- if (.Platform$OS.type == "windows") "cmd" else "sh"
git_head <- function(dir) {
  if (is.na(dir) || !dir.exists(file.path(dir, ".git"))) return(NA_character_)
  res <- suppressWarnings(system2("git", c("-C", shQuote(dir, type = quote_type), "log", "-1",
                                           "--format=%h_%ad", "--date=short"), stdout = TRUE, stderr = FALSE))
  branch <- suppressWarnings(system2("git", c("-C", shQuote(dir, type = quote_type), "rev-parse",
                                              "--abbrev-ref", "HEAD"), stdout = TRUE, stderr = FALSE))
  if (length(res)) paste0(branch[1], " ", res[1]) else NA_character_
}

if (installed) {
  db <- tools::Rd_db(pkg)
  s3 <- getNamespaceInfo(pkg, "S3methods")
  datasets <- utils::data(package = pkg)$results[, "Item"]
  exports <- c(getNamespaceExports(pkg), if (nrow(s3)) paste(s3[, 1], s3[, 2], sep = "."), datasets)
  desc <- utils::packageDescription(pkg)
  version <- desc$Version
  provenance <- paste0("installed version ", version,
                       if (!is.null(desc$RemoteType)) paste0("; RemoteType ", desc$RemoteType),
                       if (!is.null(desc$RemoteUrl)) paste0("; RemoteUrl `", desc$RemoteUrl, "`"),
                       if (!is.null(desc$RemoteRef)) paste0("; RemoteRef ", desc$RemoteRef),
                       if (!is.null(desc$RemoteSha)) paste0("; RemoteSha ", substr(desc$RemoteSha, 1, 7)))
  if (!is.na(src)) provenance <- paste0(provenance, "; source clone ", git_head(src),
                                        " (may differ from the installed copy)")
} else {
  rd_files <- list.files(file.path(src, "man"), "\\.Rd$", full.names = TRUE)
  db <- stats::setNames(lapply(rd_files, tools::parse_Rd), basename(rd_files))
  ns <- parseNamespaceFile(basename(normalizePath(src)), dirname(normalizePath(src)))
  s3 <- ns$S3methods
  datasets <- if (dir.exists(file.path(src, "data")))
    tools::file_path_sans_ext(list.files(file.path(src, "data"))) else character(0)
  exports <- c(ns$exports, if (length(s3) && nrow(s3)) paste(s3[, 1], s3[, 2], sep = "."), datasets)
  version <- read.dcf(file.path(src, "DESCRIPTION"), fields = "Version")[1, 1]
  provenance <- paste0("**NOT installed in the project library**: read from the source clone `",
                       normalizePath(src, winslash = "/"), "` (", git_head(src), "), DESCRIPTION version ", version)
}

# Plain-text rendering of one help topic, without underlined headings
rd_text <- function(rd) {
  tools::Rd2txt_options(underline_titles = FALSE, width = 90)
  con <- textConnection("txt", "w", local = TRUE)
  on.exit(close(con))
  tools::Rd2txt(rd, out = con, options = list(underline_titles = FALSE))
  txt
}

# Keep only the sections an agent needs to choose and call a function
keep_sections <- c("Description:", "Usage:", "Arguments:", "Format:")
all_headers <- c("Description:", "Usage:", "Arguments:", "Details:", "Value:", "Note:",
                 "References:", "See Also:", "Examples:", "Author(s):", "Format:",
                 "Source:", "Methods (by class):", "Functions:", "Fields:")
compact_topic <- function(txt) {
  txt <- sub("\\s+$", "", txt)
  header_rows <- which(trimws(txt) %in% all_headers)
  title <- trimws(paste(txt[seq_len(max(1, header_rows[1] - 1))], collapse = " "))
  body <- character(0)
  for (i in seq_along(header_rows)) {
    h <- trimws(txt[header_rows[i]])
    if (!h %in% keep_sections) next
    end <- if (i < length(header_rows)) header_rows[i + 1] - 1 else length(txt)
    section <- txt[(header_rows[i] + 1):end]
    section <- section[nzchar(trimws(section)) | c(FALSE, head(nzchar(trimws(section)), -1))]
    body <- c(body, paste0("**", sub(":$", "", h), "**"), "```", section, "```")
  }
  list(title = title, body = body)
}

aliases_of <- function(rd) {
  tags <- vapply(rd, function(x) attr(x, "Rd_tag"), character(1))
  unlist(lapply(rd[tags == "\\alias"], as.character))
}

topics <- lapply(names(db), function(f) {
  rd <- db[[f]]
  al <- aliases_of(rd)
  list(file = f, aliases = al, exported = intersect(al, exports), text = rd_text(rd))
})
is_fun <- vapply(topics, function(t) length(t$exported) > 0, logical(1))
topics <- topics[is_fun][order(vapply(topics[is_fun], function(t) t$exported[1], ""))]

lines <- c(
  paste0("# ", pkg, " ", version, ": function reference"),
  "",
  paste0("Generated by `scripts/make_function_reference.R` on ", format(Sys.Date()), " from the help pages: ",
         provenance, ". Each entry gives title, description, usage and arguments; for details, value and ",
         "examples use `?function` or the package source `man/*.Rd`. Datasets are marked (dataset)."),
  "",
  "## Contents",
  "",
  vapply(topics, function(t) {
    ct <- compact_topic(t$text)
    tag <- if (any(t$exported %in% datasets)) " (dataset)" else ""
    paste0("- `", paste(t$exported, collapse = "`, `"), "`", tag, ": ", ct$title)
  }, character(1)),
  ""
)
for (t in topics) {
  ct <- compact_topic(t$text)
  lines <- c(lines, paste0("## ", paste(t$exported, collapse = ", ")), "",
             paste0("*", ct$title, "*"), "", ct$body, "")
}
writeLines(lines, out, useBytes = TRUE)
cat("wrote", out, ":", length(topics), "topics,", length(lines), "lines\n")
