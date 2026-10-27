# Word layout of the rendered manuscript: table rows do not split across pages, Heading 1 and 2
# stay with the next paragraph, table column widths, cell margins and font sizes fit the page
# (layouts registered by report_table()), paragraphs after tables get space before them, and the
# contents are updated with the text marked as British English. Used by code/render_report.R and
# the knit hook of writing/lycaenidae_manuscript.Rmd.
finalise_publication_docx <- function(path, layouts = getOption("report_table_layouts", list())) {
  for (p in c("xml2", "zip"))
    if (!requireNamespace(p, quietly = TRUE)) stop("Missing Word layout dependency: ", p)
  path <- normalizePath(path, winslash = "/", mustWork = TRUE)
  scratch <- tempfile("docx-layout-")
  dir.create(scratch)
  scratch <- normalizePath(scratch, winslash = "/", mustWork = TRUE)
  on.exit(unlink(scratch, recursive = TRUE), add = TRUE)
  utils::unzip(path, exdir = scratch)
  ns <- c(w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main")
  document_path <- file.path(scratch, "word/document.xml")
  document <- xml2::read_xml(document_path)
  for (row in xml2::xml_find_all(document, "//w:tr", ns)) {
    props <- xml2::xml_find_first(row, "./w:trPr", ns)
    if (inherits(props, "xml_missing")) props <- xml2::xml_add_child(row, "w:trPr", .where = 0)
    if (inherits(xml2::xml_find_first(props, "./w:cantSplit", ns), "xml_missing"))
      xml2::xml_add_child(props, "w:cantSplit")
  }
  # Table layouts: report_table() registers, by header row, the tables that need narrow cell margins
  # and/or a 7.5-pt font to fit the page; apply the same font size and margins here.
  found <- character()
  for (tbl in xml2::xml_find_all(document, "//w:body/w:tbl", ns)) {
    header <- xml2::xml_find_first(tbl, "./w:tr", ns)
    key <- paste(trimws(vapply(xml2::xml_find_all(header, "./w:tc", ns), xml2::xml_text, "")), collapse = "|")
    if (!key %in% names(layouts)) next
    lay <- layouts[[key]]; found <- c(found, key)
    tbl_pr <- xml2::xml_find_first(tbl, "./w:tblPr", ns)
    mar <- xml2::xml_find_first(tbl_pr, "./w:tblCellMar", ns)
    if (inherits(mar, "xml_missing")) mar <- xml2::xml_add_child(tbl_pr, "w:tblCellMar")
    for (side in c("left", "right")) {
      node <- xml2::xml_find_first(mar, paste0("./w:", side), ns)
      if (inherits(node, "xml_missing")) node <- xml2::xml_add_child(mar, paste0("w:", side))
      xml2::xml_set_attrs(node, c("w:w" = as.character(lay[["margin"]]), "w:type" = "dxa"))
    }
    if (lay[["size"]] == 8.5) next                     # the template's table font size
    half_points <- as.character(round(2 * lay[["size"]]))
    for (run in xml2::xml_find_all(tbl, ".//w:r | .//w:pPr", ns)) {
      r_pr <- xml2::xml_find_first(run, "./w:rPr", ns)
      if (inherits(r_pr, "xml_missing")) r_pr <- if (xml2::xml_name(run) == "r") xml2::xml_add_child(run, "w:rPr", .where = 0) else xml2::xml_add_child(run, "w:rPr")
      # schema order: sz and szCs precede highlight, u, effect, ..., vertAlign, lang
      later <- c("highlight", "u", "effect", "bdr", "shd", "fitText", "vertAlign", "rtl", "cs", "em", "lang",
                 "eastAsianLayout", "specVanish", "oMath")
      for (tag in c("szCs", "sz")) {
        node <- xml2::xml_find_first(r_pr, paste0("./w:", tag), ns)
        if (inherits(node, "xml_missing")) {
          anchor <- xml2::xml_find_first(r_pr, paste0("./w:", c(if (tag == "sz") "szCs", later), collapse = " | "), ns)
          node <- if (inherits(anchor, "xml_missing")) xml2::xml_add_child(r_pr, paste0("w:", tag)) else
            xml2::xml_add_sibling(anchor, paste0("w:", tag), .where = "before")
        }
        xml2::xml_set_attr(node, "w:val", half_points)
      }
    }
  }
  # Absolute column widths. Pandoc writes the grid relative to its own default width, with the table at
  # 100% and no cell widths, so Word stretches columns unevenly (narrow columns stay narrow and wrap). Scale each
  # table's grid to the text width of its page section and write the widths on the table, grid and every cell.
  body_children <- xml2::xml_children(xml2::xml_find_first(document, "//w:body", ns))
  pending <- list()
  for (child in body_children) {
    if (xml2::xml_name(child) == "tbl") pending[[length(pending) + 1L]] <- child
    sect <- if (xml2::xml_name(child) == "sectPr") child else xml2::xml_find_first(child, "./w:pPr/w:sectPr", ns)
    if (inherits(sect, "xml_missing")) next
    page <- xml2::xml_find_first(sect, "./w:pgSz", ns); margin <- xml2::xml_find_first(sect, "./w:pgMar", ns)
    text_width <- as.numeric(xml2::xml_attr(page, "w")) - as.numeric(xml2::xml_attr(margin, "left")) -
      as.numeric(xml2::xml_attr(margin, "right"))
    for (tbl in pending) {
      cols <- xml2::xml_find_all(tbl, "./w:tblGrid/w:gridCol", ns)
      grid <- as.numeric(xml2::xml_attr(cols, "w"))
      twips <- round(grid / sum(grid) * text_width)
      twips[length(twips)] <- text_width - sum(twips[-length(twips)])
      for (i in seq_along(cols)) xml2::xml_set_attr(cols[[i]], "w:w", as.character(twips[i]))
      tbl_w <- xml2::xml_find_first(tbl, "./w:tblPr/w:tblW", ns)
      xml2::xml_set_attrs(tbl_w, c("w:type" = "dxa", "w:w" = as.character(text_width)))
      for (row in xml2::xml_find_all(tbl, "./w:tr", ns)) {
        cells <- xml2::xml_find_all(row, "./w:tc", ns)
        if (length(cells) != length(twips)) stop("Table row with merged cells: column widths cannot be set")
        for (i in seq_along(cells)) {
          tc_pr <- xml2::xml_find_first(cells[[i]], "./w:tcPr", ns)
          if (inherits(tc_pr, "xml_missing")) tc_pr <- xml2::xml_add_child(cells[[i]], "w:tcPr", .where = 0)
          tc_w <- xml2::xml_find_first(tc_pr, "./w:tcW", ns)
          if (inherits(tc_w, "xml_missing")) tc_w <- xml2::xml_add_child(tc_pr, "w:tcW", .where = 0)
          xml2::xml_set_attrs(tc_w, c("w:w" = as.character(twips[i]), "w:type" = "dxa"))
        }
      }
    }
    pending <- list()
  }
  if (length(pending)) stop("Tables after the last section break")
  # Body text that directly follows a table gets 8 pt of space above it, so it does not touch the table's bottom rule.
  for (p in xml2::xml_find_all(document, "//w:body/w:tbl/following-sibling::*[1][self::w:p]", ns)) {
    p_pr <- xml2::xml_find_first(p, "./w:pPr", ns)
    if (inherits(p_pr, "xml_missing")) p_pr <- xml2::xml_add_child(p, "w:pPr", .where = 0)
    style <- xml2::xml_attr(xml2::xml_find_first(p_pr, "./w:pStyle", ns), "val")
    if (!is.na(style) && style %in% c("ReportTableCaption", "ReportCaption")) next
    spacing <- xml2::xml_find_first(p_pr, "./w:spacing", ns)
    if (inherits(spacing, "xml_missing")) {
      after_style <- xml2::xml_find_first(p_pr, "./w:pStyle | ./w:keepNext | ./w:keepLines | ./w:pageBreakBefore | ./w:widowControl | ./w:numPr | ./w:pBdr | ./w:shd | ./w:tabs | ./w:suppressAutoHyphens", ns)
      spacing <- if (inherits(after_style, "xml_missing")) xml2::xml_add_child(p_pr, "w:spacing", .where = 0) else
        xml2::xml_add_sibling(xml2::xml_find_all(p_pr, "./w:pStyle | ./w:keepNext | ./w:keepLines | ./w:pageBreakBefore | ./w:widowControl | ./w:numPr | ./w:pBdr | ./w:shd | ./w:tabs | ./w:suppressAutoHyphens", ns)[[length(xml2::xml_find_all(p_pr, "./w:pStyle | ./w:keepNext | ./w:keepLines | ./w:pageBreakBefore | ./w:widowControl | ./w:numPr | ./w:pBdr | ./w:shd | ./w:tabs | ./w:suppressAutoHyphens", ns))]], "w:spacing", .where = "after")
    }
    xml2::xml_set_attr(spacing, "w:before", "160")
  }
  if (length(setdiff(names(layouts), found))) stop("Table layouts without a matching Word table: ", paste(setdiff(names(layouts), found), collapse = "; "))
  xml2::write_xml(document, document_path)
  styles_path <- file.path(scratch, "word/styles.xml")
  styles <- xml2::read_xml(styles_path)
  headings <- xml2::xml_find_all(styles,
    "//w:style[@w:styleId='Heading1' or @w:styleId='Heading2']", ns)
  stopifnot(length(headings) == 2L)
  for (heading in headings) {
    props <- xml2::xml_find_first(heading, "./w:pPr", ns)
    if (inherits(props, "xml_missing")) props <- xml2::xml_add_child(heading, "w:pPr")
    keep <- xml2::xml_find_first(props, "./w:keepNext", ns)
    if (inherits(keep, "xml_missing")) keep <- xml2::xml_add_child(props, "w:keepNext")
    xml2::xml_set_attr(keep, "w:val", "1")
  }
  xml2::write_xml(styles, styles_path)
  replacement <- file.path(scratch, "repacked.docx")
  entries <- list.files(scratch, recursive = TRUE, all.files = TRUE, no.. = TRUE)
  zip::zipr(replacement, entries, root = scratch, include_directories = FALSE, mode = "mirror")
  stopifnot(all(c("[Content_Types].xml", "_rels/.rels", "word/document.xml", "word/styles.xml") %in%
                  zip::zip_list(replacement)$filename))
  copied <- FALSE
  for (attempt in seq_len(3L)) {
    copied <- suppressWarnings(file.copy(replacement, path, overwrite = TRUE))
    if (copied) break
    Sys.sleep(0.25)
  }
  stopifnot(copied)
  update_docx_toc(path)
  invisible(path)
}

# Fill the contents page numbers before the file is opened. The TOC field is written 'dirty', and Word fills a
# dirty field while it opens the file, before pagination is complete, so every entry can show page 1. On Windows
# with Word installed, a separate hidden Word instance repaginates, updates the TOC and saves; only that instance
# is closed, never other Word windows. Elsewhere, or with LYCAENIDAE_SKIP_TOC_UPDATE=1, the dirty field is left
# for Word to fill (right-click, Update Field).
update_docx_toc <- function(path) {
  if (.Platform$OS.type != "windows" || nzchar(Sys.getenv("LYCAENIDAE_SKIP_TOC_UPDATE"))) return(invisible(FALSE))
  script <- tempfile(fileext = ".ps1")
  on.exit(unlink(script), add = TRUE)
  writeLines(c(
    "param([string]$doc_path)",
    "$before = @(Get-Process WINWORD -ErrorAction SilentlyContinue | ForEach-Object Id)",
    "try { $word = New-Object -ComObject Word.Application } catch { 'no-word'; exit 0 }",
    "$mine = @(Get-Process WINWORD -ErrorAction SilentlyContinue | ForEach-Object Id) | Where-Object { $before -notcontains $_ }",
    "if (-not $mine) { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null; 'shared-instance'; exit 0 }",
    "try {",
    "  $word.Visible = $false; $word.DisplayAlerts = 0",
    "  $doc = $word.Documents.Open($doc_path, $false, $false, $false)",
    "  $doc.Repaginate()",
    "  foreach ($toc in $doc.TablesOfContents) { $toc.Update() }",
    # Word writes regenerated contents entries in its own editing language (often en-US); the template
    # default is English (United Kingdom), so mark the whole main text as en-GB (wdEnglishUK = 2057)
    "  $doc.Content.LanguageID = 2057",
    "  $doc.Save(); $doc.Close(0); $word.Quit(); 'updated'",
    "} catch { 'failed: ' + $_.Exception.Message } finally {",
    "  try { [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null } catch {}",
    "  Start-Sleep -Seconds 1",
    "  foreach ($id in $mine) { Stop-Process -Id $id -Force -ErrorAction SilentlyContinue }",
    "}"), script)
  out <- suppressWarnings(system2("powershell.exe", c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File",
    shQuote(script), shQuote(normalizePath(path))), stdout = TRUE, stderr = TRUE))
  status <- tail(out, 1L)
  if (!identical(status, "updated"))
    message("Contents page numbers not pre-filled (", paste(status, collapse = " "),
            "); Word fills them on opening (right-click the contents, Update Field).")
  invisible(identical(status, "updated"))
}
