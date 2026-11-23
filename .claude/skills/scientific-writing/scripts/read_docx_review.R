# Read-only: turn a Word document with tracked changes and comments into text files.
#
# Collaborators review a manuscript in Word (tracked changes and comments). This script reads the
# .docx without changing it and writes four text files that can be read, searched and compared:
#   <name>_marked.txt    text with every tracked change shown: {+AP:inserted+} and [-AP:deleted-]
#                        (initials of the author), and <<c12>>anchored text<</c12>> for comments
#   <name>_accepted.txt  the text with all tracked changes accepted
#   <name>_rejected.txt  the text with all tracked changes rejected (the version that was sent out)
#   <name>_comments.txt  one block per comment: id, author, date, line in the marked file, the
#                        anchored text, the comment and its replies
# Each line starts with the paragraph style in square brackets; table rows are one line each
# with the cells separated by " | ".
#
# Usage (from the repository root; needs the R package xml2):
#   Rscript .claude/skills/scientific-writing/scripts/read_docx_review.R <file.docx> <output_folder>
#
# To see what changed between two versions of a document (for example the rendered manuscript and
# the version returned by the co-authors), write the accepted text of both and compare them word
# by word:
#   git diff --no-index --word-diff=plain --word-diff-regex='[^[:space:]]+' -U0 a_accepted.txt b_accepted.txt
# If the rejected text of the reviewed file equals the accepted text of the version that was
# sent out, the tracked changes are the complete difference.
#
# Limits: text boxes, headers, footers and footnotes are not read; figures appear as [IMAGE].
# Do not point the output folder at the folder of the .docx and never edit the .docx: Word locks
# a file that is open, so work from a copy if Word is running.

library(xml2)

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2) stop("usage: Rscript read_docx_review.R <file.docx> <output_folder>")
path_docx <- args[1]
dir_output <- args[2]
dir.create(dir_output, recursive = TRUE, showWarnings = FALSE)
output_prefix <- file.path(dir_output, tools::file_path_sans_ext(basename(path_docx)))

# Unzip only the XML parts that are needed (the figures stay inside the .docx)
dir_unzipped <- file.path(tempdir(), "docx_review")
dir.create(dir_unzipped, showWarnings = FALSE)
suppressWarnings(utils::unzip(path_docx, exdir = dir_unzipped,
  files = c("word/document.xml", "word/comments.xml", "word/commentsExtended.xml")))
document <- read_xml(file.path(dir_unzipped, "word", "document.xml"))
ns <- c(w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main",
        w15 = "http://schemas.microsoft.com/office/word/2012/wordml")
body <- xml_find_first(document, "/w:document/w:body", ns)

# Initials of an author, for example "Alex Pigot" -> "AP" and "rjwilson" -> "RJ"
author_initials <- function(node) {
  author <- xml_attr(node, "author")
  if (is.na(author)) return("??")
  words <- strsplit(author, "[[:space:]]+")[[1]]
  if (length(words) > 1) paste(toupper(substr(words, 1, 1)), collapse = "") else toupper(substr(author, 1, 2))
}

# Text of a paragraph or of any run container, for one mode:
#   "marked" shows tracked changes and comment anchors, "accepted" keeps insertions and drops
#   deletions, "rejected" does the opposite.
walk_text <- function(node, mode) {
  parts <- character()
  for (child in xml_children(node)) {
    child_name <- xml_name(child)
    if (child_name == "r") {
      # A run: text, tabs, breaks, and markers for comments, footnotes and figures
      run_parts <- vapply(xml_children(child), function(item) {
        switch(xml_name(item),
          t = xml_text(item), delText = xml_text(item), tab = "\t", br = " / ", cr = " / ",
          noBreakHyphen = "-", softHyphen = "",
          commentReference = if (mode == "marked") paste0("<<cref", xml_attr(item, "id"), ">>") else "",
          footnoteReference = paste0("[fn", xml_attr(item, "id"), "]"),
          drawing = "[IMAGE]", pict = "[IMAGE]", object = "[OBJECT]", "")
      }, character(1))
      parts <- c(parts, paste(run_parts, collapse = ""))
    } else if (child_name %in% c("ins", "moveTo")) {
      inner <- paste(walk_text(child, mode), collapse = "")
      if (mode == "marked" && nzchar(inner)) parts <- c(parts, paste0("{+", author_initials(child), ":", inner, "+}"))
      if (mode == "accepted") parts <- c(parts, inner)
    } else if (child_name %in% c("del", "moveFrom")) {
      inner <- paste(walk_text(child, mode), collapse = "")
      if (mode == "marked" && nzchar(inner)) parts <- c(parts, paste0("[-", author_initials(child), ":", inner, "-]"))
      if (mode == "rejected") parts <- c(parts, inner)
    } else if (child_name == "commentRangeStart") {
      if (mode == "marked") parts <- c(parts, paste0("<<c", xml_attr(child, "id"), ">>"))
    } else if (child_name == "commentRangeEnd") {
      if (mode == "marked") parts <- c(parts, paste0("<</c", xml_attr(child, "id"), ">>"))
    } else if (child_name %in% c("hyperlink", "smartTag", "sdt", "sdtContent", "fldSimple", "customXml")) {
      parts <- c(parts, walk_text(child, mode))
    }
  }
  parts
}

# One record per paragraph and per table row, with the text in the three modes
records <- list()
table_number <- 0L
add_paragraph <- function(p) {
  mark_node <- xml_find_first(p, "w:pPr/w:rPr", ns)
  mark <- ""   # a tracked insertion or deletion of the paragraph break itself
  if (!is.na(mark_node)) {
    if (!is.na(xml_find_first(mark_node, "w:ins", ns))) mark <- "ins"
    if (!is.na(xml_find_first(mark_node, "w:del", ns))) mark <- "del"
  }
  style <- xml_attr(xml_find_first(p, "w:pPr/w:pStyle", ns), "val")
  records[[length(records) + 1L]] <<- list(
    style = if (is.na(style)) "" else style, mark = mark, is_table = FALSE,
    marked = paste(walk_text(p, "marked"), collapse = ""),
    accepted = paste(walk_text(p, "accepted"), collapse = ""),
    rejected = paste(walk_text(p, "rejected"), collapse = ""))
}
collect <- function(container) {
  for (element in xml_children(container)) {
    if (xml_name(element) == "p") {
      add_paragraph(element)
    } else if (xml_name(element) == "tbl") {
      table_number <<- table_number + 1L
      for (row_number in seq_along(xml_find_all(element, "w:tr", ns))) {
        row <- xml_find_all(element, "w:tr", ns)[[row_number]]
        cell_text <- lapply(c("marked", "accepted", "rejected"), function(mode) {
          vapply(xml_find_all(row, "w:tc", ns), function(cell) {
            paste(vapply(xml_find_all(cell, ".//w:p", ns), function(p) paste(walk_text(p, mode), collapse = ""),
                         character(1)), collapse = " / ")
          }, character(1))
        })
        row_mark <- if (!is.na(xml_find_first(row, "w:trPr/w:ins", ns))) "rowins"
                    else if (!is.na(xml_find_first(row, "w:trPr/w:del", ns))) "rowdel" else ""
        records[[length(records) + 1L]] <<- list(
          style = sprintf("TABLE%02d row%03d", table_number, row_number), mark = row_mark, is_table = TRUE,
          marked = paste(cell_text[[1]], collapse = " | "), accepted = paste(cell_text[[2]], collapse = " | "),
          rejected = paste(cell_text[[3]], collapse = " | "))
      }
    } else if (xml_name(element) %in% c("sdt", "sdtContent")) {
      collect(element)
    }
  }
}
collect(body)

# One output line per paragraph. A deleted paragraph break joins a paragraph with the next one when
# the changes are accepted, an inserted break when they are rejected; empty paragraphs are left out.
build_lines <- function(mode) {
  lines <- character()
  carry <- ""
  for (record in records) {
    text <- record[[mode]]
    joins <- (mode == "accepted" && record$mark == "del") || (mode == "rejected" && record$mark == "ins")
    drops <- (mode == "accepted" && record$mark == "rowdel") || (mode == "rejected" && record$mark == "rowins")
    if (drops) next
    if (joins && !record$is_table) { carry <- paste0(carry, text, " "); next }
    text <- paste0(carry, text)
    carry <- ""
    if (!nzchar(trimws(text)) && !record$is_table) next
    lines <- c(lines, sprintf("[%s] %s", record$style, text))
  }
  lines
}
marked_lines <- build_lines("marked")
writeLines(marked_lines, paste0(output_prefix, "_marked.txt"), useBytes = TRUE)
writeLines(build_lines("accepted"), paste0(output_prefix, "_accepted.txt"), useBytes = TRUE)
writeLines(build_lines("rejected"), paste0(output_prefix, "_rejected.txt"), useBytes = TRUE)

# Tracked changes per author
changes <- xml_find_all(document, "//w:ins|//w:del|//w:moveFrom|//w:moveTo", ns)
changes <- changes[xml_name(xml_parent(changes)) != "rPr"]   # skip paragraph-break marks
if (length(changes) > 0) {
  print(table(author = vapply(changes, author_initials, character(1)), kind = xml_name(changes)))
}

# Comments with their replies, the text they are anchored to and their place in the marked file
file_comments <- file.path(dir_unzipped, "word", "comments.xml")
if (file.exists(file_comments)) {
  comment_nodes <- xml_find_all(read_xml(file_comments), "/w:comments/w:comment", ns)
  comment_id <- xml_attr(comment_nodes, "id")
  comment_author <- xml_attr(comment_nodes, "author")
  comment_date <- substr(xml_attr(comment_nodes, "date"), 1, 10)
  comment_text <- vapply(comment_nodes, function(node) {
    paste(vapply(xml_find_all(node, ".//w:p", ns), function(p) paste(walk_text(p, "accepted"), collapse = ""),
                 character(1)), collapse = " // ")
  }, character(1))
  # A reply points to its parent through the paragraph identifiers of commentsExtended.xml
  paragraph_id <- vapply(comment_nodes, function(node) {
    paragraphs <- xml_find_all(node, ".//w:p", ns)
    xml_attr(paragraphs[[length(paragraphs)]], "paraId")
  }, character(1))
  parent_id <- setNames(rep(NA_character_, length(comment_id)), comment_id)
  file_extended <- file.path(dir_unzipped, "word", "commentsExtended.xml")
  if (file.exists(file_extended)) {
    for (entry in xml_find_all(read_xml(file_extended), "/w15:commentsEx/w15:commentEx", ns)) {
      this_comment <- which(paragraph_id == xml_attr(entry, "paraId"))
      parent_paragraph <- xml_attr(entry, "paraIdParent")
      if (length(this_comment) == 1L && !is.na(parent_paragraph)) {
        parent_id[comment_id[this_comment]] <- comment_id[which(paragraph_id == parent_paragraph)[1]]
      }
    }
  }
  marked_all <- paste(marked_lines, collapse = "\n")
  blocks <- character()
  for (k in which(is.na(parent_id[comment_id]))) {
    anchor <- regmatches(marked_all, regexpr(sprintf("<<c%s>>.*?<</c%s>>", comment_id[k], comment_id[k]), marked_all, perl = TRUE))
    anchor <- if (length(anchor)) gsub("<<[^>]*>>", "", anchor) else ""
    line_number <- grep(sprintf("<<c%s>>", comment_id[k]), marked_lines, fixed = TRUE)[1]
    blocks <- c(blocks, sprintf("### comment %s | %s | %s | line %s", comment_id[k], comment_author[k], comment_date[k], line_number),
                paste0("ANCHOR: ", anchor), paste0("COMMENT: ", comment_text[k]))
    for (r in which(parent_id[comment_id] == comment_id[k])) {
      blocks <- c(blocks, sprintf("  REPLY | %s | %s: %s", comment_author[r], comment_date[r], comment_text[r]))
    }
    blocks <- c(blocks, "")
  }
  writeLines(blocks, paste0(output_prefix, "_comments.txt"), useBytes = TRUE)
  cat(length(comment_id), "comments (", sum(is.na(parent_id[comment_id])), "threads )\n")
}
cat("written to", dir_output, "\n")
