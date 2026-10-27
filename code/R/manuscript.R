# Tables, numbers and figures of the manuscript
# (writing/lycaenidae_manuscript.Rmd).

#' Read a required manuscript results table
#' @param path Path to an existing CSV output.
#' @return Data frame; missing results stop rendering rather than inserting blanks.
read_report_table <- function(path) {
  if (!file.exists(path)) stop("Run the analysis first; required manuscript input missing: ", path)
  read.csv(path, na.strings = c("", "NA"), check.names = FALSE)
}

#' Read a required manuscript results object (RDS)
#' @param path Path to an existing RDS output.
#' @return The stored object; a missing file stops rendering with the same message as read_report_table().
read_report_rds <- function(path) {
  if (!file.exists(path)) stop("Run the analysis first; required manuscript input missing: ", path)
  readRDS(path)
}

#' Format a computed number for manuscript prose
#' @param x One finite number.
#' @param digits Number of decimal places.
#' @return Formatted character scalar with thousands separators.
report_number <- function(x, digits = 0L) {
  stopifnot(length(x) == 1L, is.finite(x))
  formatC(x, format = "f", digits = digits, big.mark = ",")
}

#' Include a required manuscript figure
#' @param name Figure name from the inventory in code/R/report_figures.R.
#' @return knitr graphics inclusion object.
report_figure <- function(name) {
  path <- report_figure_path(name)
  if (!file.exists(path)) stop("Required report figure missing: ", path)
  knitr::include_graphics(normalizePath(path, winslash = "/"), rel_path = FALSE)
}

#' Format a p-value for a publication table
#' @param x Numeric p-value.
#' @param digits Decimal places for values at least 0.001.
#' @return Markdown text; significant values are bold.
format_table_p <- function(x, digits = 3L) {
  label <- ifelse(is.na(x), "",
    ifelse(x < 0.001, "<.001", sub("^0", "", formatC(
      x, format = "f", digits = digits
    ))))
  ifelse(!is.na(x) & x < 0.05, paste0("**", label, "**"), label)
}

#' Assemble publication tables for log10 range-size mixed models
#'
#' The fit table reports overall tests and variance explained. The estimates
#' table back-transforms marginal means and the partner-breadth slope to the
#' original range scale, where the slope is a multiplicative change per
#' additional recorded ant genus.
#' @param models Named fitted models from `fit_log_range_models()`.
#' @param coefficients Tidy fixed-effect table.
#' @param means Back-transformed estimated marginal means.
#' @param metadata Model-level metadata and R2 values.
#' @return Named list with compact `fit` and `estimates` data frames.
publication_log_model_sections <- function(models, coefficients, means, metadata) {
  measure_labels <- c(area = "Area", lat = "Lat", lon = "Lon")
  type_labels <- c(n = "Non-ant", f = "Fac.", m = "Mut.", p = "Par.")
  fit_rows <- estimate_rows <- list()
  index <- 1L
  for (measure in names(measure_labels)) {
    for (predictors in c("type", "breadth")) {
      key <- paste(measure, predictors, sep = "_")
      model <- models[[key]]
      meta <- metadata[
        metadata$measure == measure & metadata$predictors == predictors,
      ][1, ]
      tests <- suppressMessages(as.data.frame(stats::anova(
        model, ddf = "Satterthwaite"
      )))
      tests$term <- rownames(tests)
      p_column <- grep("Pr\\(", names(tests), value = TRUE)[1]
      p_for <- function(term) {
        value <- tests[tests$term == term, p_column]
        if (length(value)) value[1] else NA_real_
      }
      slope <- coefficients[
        coefficients$measure == measure &
          coefficients$predictors == predictors &
          coefficients$term == "partner_breadth_centered",
      ]
      fit_rows[[index]] <- data.frame(
        Predictors = sprintf(
          "%s (n=%s)",
          if (predictors == "type") "Type" else "Type + breadth",
          format(meta$n, big.mark = ",", scientific = FALSE)
        ),
        Metric = measure_labels[[measure]],
        "R²m / R²c" = sprintf("%.3f / %.3f", meta$marginal_r2, meta$conditional_r2),
        `Type p` = format_table_p(p_for("interaction_type")),
        `Breadth ratio` = if (nrow(slope)) sprintf(
          "%.3f (%.3f–%.3f)", slope$range_ratio[1],
          slope$ratio_lower[1], slope$ratio_upper[1]
        ) else "",
        `Breadth p` = if (nrow(slope)) format_table_p(slope$p_value[1]) else "",
        check.names = FALSE
      )

      mean_rows <- means[
        means$measure == measure & means$predictors == predictors,
      ]
      cells <- setNames(rep("", length(type_labels)), names(type_labels))
      for (type in intersect(names(cells), as.character(mean_rows$interaction_type))) {
        item <- mean_rows[as.character(mean_rows$interaction_type) == type, ][1, ]
        scale_factor <- if (measure == "area") 1e6 else 1
        digits <- if (measure == "area") 2 else 0
        format_estimate <- function(value) {
          format(
            round(value / scale_factor, digits), nsmall = digits,
            big.mark = ",", scientific = FALSE, trim = TRUE
          )
        }
        cells[type] <- sprintf(
          "%s (%s–%s)",
          format_estimate(item$geometric_estimate),
          format_estimate(item$geometric_lower),
          format_estimate(item$geometric_upper)
        )
      }
      estimate_rows[[index]] <- data.frame(
        `Model / metric` = paste(
          if (predictors == "type") "Type" else "Type + breadth",
          measure_labels[[measure]], sep = " / "
        ),
        `Non-associated` = cells["n"], Facultative = cells["f"], Mutualist = cells["m"],
        Parasite = cells["p"], check.names = FALSE
      )
      index <- index + 1L
    }
  }
  list(fit = do.call(rbind, fit_rows), estimates = do.call(rbind, estimate_rows))
}

#' Format adjusted pairwise ratios from log10 range models
#' @param contrasts Contrast table from `fit_log_range_models()`.
#' @return Long publication table with ratios, 95% confidence intervals and
#'   multiplicity-adjusted p-values.
publication_log_contrast_table <- function(contrasts) {
  labels <- c(area = "Area", lat = "Lat", lon = "Lon")
  contrast_order <- c("n - f", "n - m", "n - p", "f - m", "f - p", "m - p")
  d <- contrasts[contrasts$contrast %in% contrast_order, ]
  d$measure <- factor(d$measure, levels = names(labels), labels = labels)
  d$contrast <- factor(d$contrast, levels = contrast_order)
  d <- d[base::order(d$predictors, d$measure, d$contrast), ]
  data.frame(
    Model = ifelse(d$predictors == "type", "Type", "Type + breadth"),
    Metric = as.character(d$measure), Contrast = sub(" - ", " / ", as.character(d$contrast), fixed = TRUE),
    `Range ratio (95% CI)` = sprintf(
      "%.2f (%.2f–%.2f)", d$range_ratio, d$ratio_lower, d$ratio_upper
    ),
    `Adjusted p` = format_table_p(d$p.value),
    check.names = FALSE
  )
}

# Explicit line break inside a report_table() cell (Word and HTML; e.g. before the p-values of Table S12)
report_line_break <- "`<w:r><w:br/></w:r>`{=openxml}`<br>`{=html}"

#' Pipe table with column widths fitted to the Word page
#'
#' Pandoc gives a wide pipe table the full text width and sizes its columns from the number of dashes in the
#' separator row. The widths are computed here in inches from the measured width of the cell text in Calibri (the
#' table font of the reference document), for the text width of the page the table sits on (6.5 in portrait, 9 in
#' landscape; `options(report_table_width = )`). Each table uses the first layout in which every cell fits on one line:
#' 8.5 pt with the template's cell margins, 8.5 pt with narrow margins, or 7.5 pt with narrow margins. If none fits
#' (e.g. Table S12), the 7.5-pt layout is used and columns shrink towards a minimum in proportion to how much they can
#' give: text columns down to their longest word, effect cells ("ratio (lower-upper) p") down to the width without the
#' p-value, so that only the p-value moves to a second line. Non-default layouts are registered by header row in
#' `options("report_table_layouts")` and applied to the Word file by finalise_publication_docx().
#' @param x Data frame of formatted cells (markdown allowed, e.g. bold p-values).
#' @param align Optional alignment per column ("l", "r" or "c"); numeric columns default to right.
#' @param ... Ignored (so existing `kable()` arguments can be passed unchanged).
#' @param width Text width of the page in inches.
#' @return Markdown table as `knitr::asis_output()`.
report_table <- function(x, align = NULL, ..., width = getOption("report_table_width", 6.5)) {
  x <- as.data.frame(x, check.names = FALSE, stringsAsFactors = FALSE)
  if (is.null(align)) align <- ifelse(vapply(x, is.numeric, TRUE), "r", "l")
  stopifnot(length(align) == ncol(x), width > 0)
  # cells may contain an explicit line break (report_line_break), measured as two lines
  plain <- function(v) {
    v <- gsub(report_line_break, "\n", as.character(v), fixed = TRUE)
    v <- gsub("[*\\]", "", v); v[is.na(v)] <- ""; v
  }
  is_bold <- function(v) grepl("**", as.character(v), fixed = TRUE)
  is_p <- function(t) grepl("^[<>]?[0-9]*\\.[0-9]+$", t)          # p-value token, e.g. <.001, .025, 1.000
  measure <- function(size, padding) {
    # Calibri advance widths; Word set the PDF text 5-12% narrower than this estimate, so 0.97
    # keeps about 5% margin
    inch <- function(s, b) systemfonts::string_width(s, family = "Calibri", weight = ifelse(b, "bold", "normal"),
                                                     size = size, res = 72) / 72 * 0.97
    natural <- minimum <- numeric(ncol(x))
    for (j in seq_along(x)) {
      cells <- c(names(x)[j], as.character(x[[j]])); cells[is.na(cells)] <- ""
      txt <- plain(cells); b <- is_bold(cells)
      lines_of <- function(s) { l <- strsplit(s, "\n", fixed = TRUE)[[1]]; if (length(l)) l else "" }
      full <- vapply(seq_along(txt), function(i) max(inch(lines_of(txt[i]), b[i]), 0), 1)
      cell_min <- vapply(seq_along(txt), function(i) max(vapply(lines_of(txt[i]), function(line) {
        tok <- strsplit(line, " +")[[1]]
        if (!length(tok)) return(0)
        if (i > 1L && length(tok) >= 3L && is_p(tok[length(tok)]) && grepl("^\\(", tok[length(tok) - 1L]))
          return(inch(paste(tok[-length(tok)], collapse = " "), b[i]))   # keep "ratio (CI)" on one line
        max(inch(tok, b[i]))                                               # otherwise the longest word
      }, 1), 0), 1)
      natural[j] <- max(full, 0.1) + padding
      minimum[j] <- max(cell_min, 0.1) + padding
    }
    list(natural = natural, minimum = minimum, size = size, padding = padding)
  }
  # text columns (labels of three or more alphabetic words) may wrap between words; the others stay on one line
  words <- vapply(x, function(v) stats::median(vapply(strsplit(trimws(plain(v)), " +"), function(t) sum(grepl("[A-Za-z]", t)), 1)), 1)
  effect <- vapply(x, function(v) any(grepl("\\([-0-9.]+–[-0-9.]+\\)[ \n]\\S+$", plain(v))), TRUE)
  flex <- words >= 3 & !effect
  layouts <- list(c(8.5, 0.15), c(8.5, 0.075), c(7.5, 0.075))   # font size (pt), left + right cell margin (in)
  for (k in seq_along(layouts)) {
    m <- measure(layouts[[k]][1], layouts[[k]][2])
    if (sum(m$natural[!flex]) + sum(m$minimum[flex]) <= width) break
  }
  if (sum(m$natural) <= width) {
    w <- m$natural + (width - sum(m$natural)) * m$natural / sum(m$natural)  # spread spare width
  } else if (sum(m$natural[!flex]) + sum(m$minimum[flex]) <= width) {
    w <- m$natural                                                           # only text columns wrap
    slack <- (m$natural - m$minimum) * flex
    w <- w - slack * (sum(m$natural) - width) / sum(slack)
  } else if (sum(m$natural[!effect]) + sum(m$minimum[effect]) <= width) {
    slack <- (m$natural - m$minimum) * effect                                # labels stay on one line;
    w <- m$natural - slack * (sum(m$natural) - width) / sum(slack)          # p-values move to a second line
  } else if (sum(m$minimum) <= width) {
    slack <- m$natural - m$minimum
    w <- m$natural - slack * (sum(m$natural) - width) / sum(slack)           # shrink in proportion to slack
  } else {
    w <- m$minimum * width / sum(m$minimum)                                  # cannot fit: wrapping unavoidable
  }
  if (k > 1L) {                                    # register the layout for finalise_publication_docx()
    key <- paste(plain(names(x)), collapse = "|")
    reg <- getOption("report_table_layouts", list())
    reg[[key]] <- c(size = m$size, margin = round(m$padding / 2 * 1440))
    options(report_table_layouts = reg)
  }
  lines <- as.character(knitr::kable(x, format = "pipe", align = align, escape = FALSE, row.names = FALSE))
  # pandoc uses the dash counts as relative widths when the separator is longer than its 72-column limit
  d <- pmax(3L, round(w / sum(w) * 400))
  cell <- function(n, a) switch(a, l = paste0(":", strrep("-", n - 1L)), r = paste0(strrep("-", n - 1L), ":"),
                                paste0(":", strrep("-", n - 2L), ":"))
  lines[2] <- paste0("|", paste(mapply(cell, d, align), collapse = "|"), "|")
  knitr::asis_output(paste0("\n", paste(lines, collapse = "\n"), "\n"))
}
