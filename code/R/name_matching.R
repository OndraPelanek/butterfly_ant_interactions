# Normalisation of published butterfly names and matching against the GBIF
# Backbone snapshot. Pure functions without file input or output; used by
# s01_prepare_traits and s02_prepare_ranges.

#' Normalise a published scientific name to an underscore-free "Genus epithet".
#' Removes subgenus brackets, "(as xxx)", "?", quotation marks, authorities in
#' brackets and everything after the epithet. Returns NA for placeholders
#' (sp., spp., nr., aff., indet.). `rank_flag` reports trinomials.
#' @param x Character vector of published names.
#' @return Data frame with input, normalised, genus, epithet and rank_flag.
normalise_name <- function(x) {
  x0 <- x
  x <- gsub("[_]", " ", x)
  x <- gsub("“|”|\"|‘|’", "", x)
  x <- gsub("[(][^)]*[)]", " ", x)             # subgenus brackets, (as ...), (incl. ...)
  x <- gsub("\\[[^]]*\\]", " ", x)              # [as ...]
  x <- gsub("[?]", " ", x)
  x <- gsub("^[+]\\s*", "", x)
  x <- gsub("\\s+", " ", trimws(x))
  w <- strsplit(x, " ")
  genus <- vapply(w, function(z) if (length(z) >= 1) z[1] else NA_character_, "")
  epithet <- vapply(w, function(z) if (length(z) >= 2) z[2] else NA_character_, "")
  third <- vapply(w, function(z) if (length(z) >= 3) z[3] else NA_character_, "")
  genus <- sub("^([A-Z])([A-Za-z-]*)$", "\\1\\2", genus)
  ok <- grepl("^[A-Z][a-z-]+$", genus) & grepl("^[a-z][a-z-]+$", epithet) &
    !epithet %in% c("sp", "spp", "nr", "aff", "cf", "indet", "ssp", "near", "group")
  out <- ifelse(ok, paste(genus, epithet), NA_character_)
  flag <- ifelse(ok & !is.na(third) & grepl("^[a-z][a-z-]+$", third) &
                   !third %in% c("sp", "spp", "gr", "group", "nr", "aff", "as", "incl"),
                 "infraspecific_in_name", NA_character_)
  data.frame(input = x0, normalised = out, genus = ifelse(ok, genus, NA),
             epithet = ifelse(ok, epithet, NA), rank_flag = flag,
             stringsAsFactors = FALSE)
}

#' Orthographic variants of an epithet (Latin gender endings, -ii/-i, -ae/-i).
epithet_variants <- function(e) {
  v <- e
  swap <- function(pat, rep) if (grepl(pat, e)) sub(pat, rep, e)
  v <- c(v, swap("us$", "a"), swap("us$", "um"), swap("a$", "us"), swap("a$", "um"),
         swap("um$", "us"), swap("um$", "a"), swap("is$", "e"), swap("e$", "is"),
         swap("ii$", "i"), swap("i$", "ii"), swap("ae$", "i"), swap("i$", "ae"),
         swap("ius$", "ia"), swap("ia$", "ius"), swap("ior$", "ius"),
         swap("or$", "oris"), swap("ensis$", "ense"), swap("ensis$", "iensis"),
         swap("oides$", "oidea"), swap("ana$", "anus"), swap("anus$", "ana"))
  unique(v[!is.na(v)])
}

#' Match normalised binomials against a GBIF snapshot.
#'
#' @param names character vector of normalised "Genus epithet".
#' @param acc data frame of accepted species (key, canonicalName, ...).
#' @param syn data frame of synonyms (key, canonicalName, rank, acceptedKey, ...).
#' @param dbt optional data frame of DOUBTFUL names; matching names are reported as
#'   gbif_doubtful and never accepted.
#' @return data frame, one row per input name, with match_type:
#'   accepted_exact | synonym_resolved | accepted_and_synonym | ambiguous_accepted |
#'   ambiguous_synonym | proparte_synonym | gender_variant_accepted | gender_variant_synonym |
#'   synonym_to_infraspecific | gbif_doubtful | unmatched. `accepted_key` is the accepted SPECIES key when resolvable.
match_gbif_names <- function(names, acc, syn, dbt = NULL) {
  acc_by <- split(acc, acc$canonicalName)
  syn_sp <- syn[syn$rank == "SPECIES", ]
  syn_by <- split(syn_sp, syn_sp$canonicalName)
  dbt_by <- if (is.null(dbt)) list() else split(dbt[dbt$rank == "SPECIES", ], dbt$canonicalName[dbt$rank == "SPECIES"])
  key_to_acc <- setNames(seq_len(nrow(acc)), as.character(acc$key))
  species_of <- function(accepted_key) {
    # accepted key of a synonym may be a species or a subspecies; return the species key
    i <- key_to_acc[as.character(accepted_key)]
    ifelse(is.na(i), NA_character_, as.character(acc$key[i]))
  }
  res <- lapply(names, function(b) {
    empty <- list(match_type = "unmatched", usage_key = NA, status = NA,
                  accepted_key = NA, accepted_name = NA, note = NA)
    if (is.na(b)) return(empty)
    a <- acc_by[[b]]; s <- syn_by[[b]]
    sk <- if (!is.null(s)) unique(na.omit(species_of(s$acceptedKey))) else character()
    if (!is.null(a) && nrow(a) == 1L) {
      note <- if (!is.null(s)) paste("also a GBIF synonym of", paste(unique(s$accepted), collapse = " | ")) else NA
      return(list(match_type = if (!is.null(s)) "accepted_and_synonym" else "accepted_exact",
                  usage_key = a$key, status = "ACCEPTED", accepted_key = a$key,
                  accepted_name = a$canonicalName, note = note))
    }
    if (!is.null(a) && nrow(a) > 1L)
      return(modifyList(empty, list(match_type = "ambiguous_accepted",
                                    note = "several accepted records share this name")))
    if (!is.null(s) && all(s$taxonomicStatus == "PROPARTE_SYNONYM"))
      return(modifyList(empty, list(match_type = "proparte_synonym", usage_key = s$key[1],
                                    status = "PROPARTE_SYNONYM",
                                    note = paste("pro parte synonym of:", paste(unique(s$accepted), collapse = " | ")))))
    if (!is.null(s)) {
      if (length(sk) == 1L) {
        ai <- key_to_acc[sk]
        return(list(match_type = "synonym_resolved", usage_key = s$key[1], status = "SYNONYM",
                    accepted_key = sk, accepted_name = acc$canonicalName[ai],
                    note = if (nrow(s) > 1) paste(nrow(s), "synonym records agree") else NA))
      }
      if (length(sk) > 1L)
        return(modifyList(empty, list(match_type = "ambiguous_synonym",
                                      note = paste("synonym of several accepted species:",
                                                   paste(acc$canonicalName[key_to_acc[sk]], collapse = " | ")))))
      return(modifyList(empty, list(match_type = "synonym_to_infraspecific", usage_key = s$key[1],
                                    status = "SYNONYM",
                                    note = paste("accepted taxon is not a species:", paste(unique(s$accepted), collapse = " | ")))))
    }
    if (!is.null(dbt_by[[b]]))
      return(modifyList(empty, list(match_type = "gbif_doubtful", usage_key = dbt_by[[b]]$key[1],
                                    status = "DOUBTFUL",
                                    note = "name exists in GBIF with DOUBTFUL status; never auto-accepted")))
    # orthographic variants within the same genus
    g <- sub(" .*$", "", b); e <- sub("^[^ ]+ ", "", b)
    for (v in setdiff(epithet_variants(e), e)) {
      bv <- paste(g, v)
      if (!is.null(acc_by[[bv]]) && nrow(acc_by[[bv]]) == 1L)
        return(list(match_type = "gender_variant_accepted", usage_key = acc_by[[bv]]$key,
                    status = "ACCEPTED", accepted_key = acc_by[[bv]]$key,
                    accepted_name = acc_by[[bv]]$canonicalName, note = paste("variant:", bv)))
      sv <- syn_by[[bv]]
      if (!is.null(sv)) {
        k <- unique(na.omit(species_of(sv$acceptedKey)))
        if (length(k) == 1L)
          return(list(match_type = "gender_variant_synonym", usage_key = sv$key[1], status = "SYNONYM",
                      accepted_key = k, accepted_name = acc$canonicalName[key_to_acc[k]],
                      note = paste("variant:", bv)))
      }
    }
    empty
  })
  out <- do.call(rbind, lapply(res, function(z) data.frame(lapply(z, function(q) if (is.null(q)) NA else q),
                                                         stringsAsFactors = FALSE)))
  cbind(normalised = names, out)
}

#' Read the GBIF Backbone snapshot without the riodinid genera
#'
#' Accepted species, synonyms and doubtful names of the 2 October 2026 snapshot. Riodinid
#' accepted species, synonyms in riodinid genera or pointing to riodinid species, and riodinid
#' doubtful names are dropped, as in s01_prepare_traits.
#' @param dir_data_raw Raw data folder.
#' @return list(acc, syn, dbt) of data frames, all columns as character.
read_backbone_snapshot <- function(dir_data_raw) {
  read_snapshot <- function(file) {
    read.csv(file.path(dir_data_raw, "gbif_backbone", file), colClasses = "character",
             na.strings = "")
  }
  acc <- read_snapshot("accepted_species_20261002.csv")
  syn <- read_snapshot("synonyms_20261002.csv")
  dbt <- read_snapshot("doubtful_20261002.csv")
  rio <- read.csv(file.path(dir_data_raw, "taxonomy", "riodinid_genera.csv"),
                  colClasses = "character", na.strings = "")$genus
  rio_keys <- acc$key[acc$genus %in% rio]
  list(acc = acc[!acc$genus %in% rio, ],
       syn = syn[!(syn$genus %in% rio | syn$acceptedKey %in% rio_keys), ],
       dbt = dbt[!dbt$genus %in% rio, ])
}

#' Accepted species key of each name, by strict matching to the snapshot
#'
#' Only exact accepted names and synonyms of a single accepted species are used: no
#' orthographic variants, fuzzy matches or doubtful names.
#' @param names Binomials ("Genus species").
#' @param snapshot GBIF Backbone snapshot (`read_backbone_snapshot()`).
#' @return Accepted species key of each name; NA when the name does not resolve.
resolve_accepted_key <- function(names, snapshot) {
  m <- match_gbif_names(names, snapshot$acc, snapshot$syn, snapshot$dbt)
  ifelse(m$match_type %in% c("accepted_exact", "accepted_and_synonym", "synonym_resolved"),
         m$accepted_key, NA_character_)
}
