# Publication overlay for verified ant-evidence coding errors; used by
# s03_build_species_tables and s05_check_robustness.
# Frozen acquisition files remain unchanged. This function changes host_breadth
# only, after verifying the original value against the qualifying ledger rows.
# The primary policy also excludes Fiedler (1991) Table 19 records
# with a question mark after the ant name; the legend identifies these as
# questionable determinations or doubtful records. The optional FALSE value
# is retained only to audit the isolated, unambiguous attack-record defect.
publication_trait_correction <- function(x, ledger, exclude_questionable = TRUE) {
  required <- c("accepted_key", "source_id", "locator", "claim_type",
                "ant_name_verbatim", "ant_count_group", "ant_qualifies")
  stopifnot(all(required %in% names(ledger)), "host_breadth" %in% names(x))
  qualifying <- !is.na(ledger$ant_qualifies) & as.character(ledger$ant_qualifies) == "TRUE"
  table19 <- ledger$source_id == "fiedler1991" &
    grepl("^Table 19,", ledger$locator) & ledger$claim_type == "ant_association"
  table19[is.na(table19)] <- FALSE
  attacked <- table19 & grepl("attack", ledger$ant_name_verbatim, ignore.case = TRUE)
  attacked[is.na(attacked)] <- FALSE
  # The only explicit attacked token in the current frozen ledger is verified
  # against PDF page 204 (printed page 202), row Ogyris genoveva.
  a <- ledger[attacked, , drop = FALSE]
  stopifnot(nrow(a) == 1L, a$accepted_key == "5138973",
            a$ant_name_verbatim == "Iridomyrmex purpureus (attacked)",
            a$locator == paste0("Table 19, PDF page 204 (printed p. 202), row 11; ",
                               "printed as 'Ogyris genoveva'"))
  # A question mark immediately before the epithet means uncertain species
  # determination, so it does not alone make genus-level evidence doubtful.
  prefix_species_uncertain <- grepl("^[A-Z][A-Za-z.]+[[:space:]]+\\?[a-z]",
                                    ledger$ant_name_verbatim)
  prefix_species_uncertain[is.na(prefix_species_uncertain)] <- FALSE
  questionable <- table19 & grepl("\\?", ledger$ant_name_verbatim) &
    !prefix_species_uncertain
  questionable[is.na(questionable)] <- FALSE
  exclude <- attacked | (exclude_questionable & questionable)
  adjusted <- ledger
  adjusted$ant_qualifies[exclude] <- FALSE
  adjusted$association_kind[attacked] <- "attack-only"
  if (exclude_questionable) adjusted$association_kind[questionable] <- "doubtful-record"
  group_count <- function(k, keep) {
    g <- unique(ledger$ant_count_group[ledger$accepted_key == k & keep])
    length(g[!is.na(g) & nzchar(g)])
  }
  changed_keys <- unique(ledger$accepted_key[exclude & !is.na(ledger$accepted_key)])
  audit <- do.call(rbind, lapply(changed_keys, function(k) {
    before <- group_count(k, qualifying)
    after <- group_count(k, qualifying & !exclude)
    data.frame(gbif_key = k, before = before, after = after,
      excluded_evidence_ids = paste(ledger$evidence_id[ledger$accepted_key == k & exclude], collapse = ";"),
      excluded_count_groups = paste(unique(ledger$ant_count_group[ledger$accepted_key == k & exclude]), collapse = ";"),
      remaining_count_groups = paste(sort(unique(ledger$ant_count_group[ledger$accepted_key == k & qualifying & !exclude])), collapse = ";"),
      changes_breadth = before != after, stringsAsFactors = FALSE)
  }))
  id <- if ("pool_key" %in% names(x)) as.character(x$pool_key) else as.character(x$gbif_key)
  original <- x
  for (j in seq_len(nrow(audit))) {
    rows <- which(id == audit$gbif_key[j])
    if (length(rows)) {
      value <- as.numeric(x$host_breadth[rows])
      # Reapplying this overlay to canonical publication tables is harmless.
      # Any value apart from the frozen-ledger before/after values is an error.
      admissible <- !is.na(value) & value %in% c(audit$before[j], audit$after[j])
      if (audit$after[j] == 0L) admissible <- admissible | is.na(value)
      stopifnot(all(admissible))
      x$host_breadth[rows] <- if (audit$after[j] > 0L) audit$after[j] else NA_real_
    }
  }
  stopifnot(identical(original[, setdiff(names(x), "host_breadth"), drop = FALSE],
                      x[, setdiff(names(x), "host_breadth"), drop = FALSE]))
  attr(x, "trait_correction_audit") <- audit
  attr(x, "corrected_evidence_ledger") <- adjusted
  attr(x, "questionable_evidence_rows") <- ledger[questionable, , drop = FALSE]
  x
}
