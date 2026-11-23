# Fetch the open-access full text of papers from PubMed Central and turn each
# into numbered plain text for careful reading (used to add exemplar papers to
# the scientific-writing skill).
#
# Usage (from the repository root, so that renv activates):
#   Rscript .claude/skills/scientific-writing/scripts/fetch_open_access_text.R <output_folder> <key>=<PMCID> [...]
#   e.g. ... fetch_open_access_text.R C:/temp/exemplars beyer2021=PMC8384873 krapp2021=PMC8397735
#
# Output per paper: <key>.xml (JATS full text) and <key>.txt with the title,
# abstract, every heading and paragraph in order, figure captions and back
# matter (data and code availability). Paragraphs are numbered [P1], [P2], ...
# with their word count, so that notes can point to them. References are left out.
#
# Keep the output outside the repository (scratch folder): the texts are the
# publishers' copyright even when open access. Notes in the skill paraphrase them.

library(xml2)

script_args <- commandArgs(trailingOnly = TRUE)
stopifnot("give an output folder and at least one key=PMCID" = length(script_args) >= 2)
dir_output <- script_args[1]
paper_ids <- strsplit(script_args[-1], "=", fixed = TRUE)
dir.create(dir_output, recursive = TRUE, showWarnings = FALSE)

for (paper_id in paper_ids) {
  paper_key <- paper_id[1]
  pmc_number <- sub("^PMC", "", paper_id[2])
  path_xml <- file.path(dir_output, paste0(paper_key, ".xml"))

  # 1. Download the JATS XML from NCBI (generic client name; one request per second).
  url_efetch <- paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pmc&id=",
                       pmc_number, "&rettype=xml")
  download.file(url_efetch, path_xml, quiet = TRUE,
                headers = c("User-Agent" = "Mozilla/5.0 (research script)"))
  Sys.sleep(1)

  # 2. Parse it. Papers without an open-access body come back without <body>.
  article_xml <- read_xml(path_xml)
  xml_ns_strip(article_xml)
  article <- xml_find_first(article_xml, "//article")
  body <- xml_find_first(article, ".//body")
  if (inherits(body, "xml_missing")) {
    cat(paper_key, ": no open-access full text in PMC\n")
    next
  }
  # Formulas come as MathML and LaTeX; keep the MathML text only.
  xml_remove(xml_find_all(article, ".//tex-math"))

  # 3. Title and abstracts.
  text_out <- c(paste("TITLE:", xml_text(xml_find_first(article, ".//front//article-title"))), "")
  for (abstract in xml_find_all(article, ".//front//abstract")) {
    text_out <- c(text_out, paste0("ABSTRACT (", xml_attr(abstract, "abstract-type"), "):"),
                  xml_text(xml_find_all(abstract, ".//p")), "")
  }

  # 4. Headings and paragraphs in document order (paragraphs inside figures and
  #    tables are skipped; captions are listed at the end).
  paragraph_number <- 0
  body_nodes <- xml_find_all(body, ".//sec/title | .//p[not(ancestor::fig) and not(ancestor::table-wrap)] | ./p")
  for (node in body_nodes) {
    if (xml_name(node) == "title") {
      heading_depth <- length(xml_find_all(node, "ancestor::sec"))
      text_out <- c(text_out, "", paste(strrep("#", heading_depth), xml_text(node)))
    } else {
      paragraph_number <- paragraph_number + 1
      paragraph_text <- gsub("\\s+", " ", xml_text(node))
      n_words <- length(strsplit(paragraph_text, " ", fixed = TRUE)[[1]])
      text_out <- c(text_out, paste0("[P", paragraph_number, " | ", n_words, " words] ", paragraph_text))
    }
  }

  # 5. Back matter (author contributions, data and code availability) and captions.
  for (section in xml_find_all(article, ".//back/sec | .//back/notes")) {
    text_out <- c(text_out, "", paste("## [back]", xml_text(xml_find_first(section, "./title"))),
                  gsub("\\s+", " ", xml_text(xml_find_all(section, ".//p"))))
  }
  text_out <- c(text_out, "", "FIGURE CAPTIONS:")
  for (figure in xml_find_all(article, ".//fig")) {
    text_out <- c(text_out, paste0(xml_text(xml_find_first(figure, "./label")), ": ",
                                   gsub("\\s+", " ", xml_text(xml_find_first(figure, "./caption")))))
  }

  writeLines(text_out, file.path(dir_output, paste0(paper_key, ".txt")), useBytes = TRUE)
  cat(paper_key, ":", paragraph_number, "paragraphs written\n")
}
