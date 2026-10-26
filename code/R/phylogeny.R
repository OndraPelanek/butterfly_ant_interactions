# Published trees, their tip names and phylogenetic generalised least squares
# (PGLS), and the matching of tree tips to species; used by s01_prepare_traits and
# s04_fit_models to s06_summarise_results.

#' Read one published phylogeny without changing it
#'
#' The file extension determines whether `ape::read.nexus()` or
#' `ape::read.tree()` is used. Multi-tree files are rejected because each
#' study contributes one published tree.
#' @param path Path to a Newick or NEXUS tree.
#' @return An object of class `phylo`.
read_published_tree <- function(path) {
  if (!file.exists(path)) stop("Tree file not found: ", path)
  extension <- tolower(tools::file_ext(path))
  first_line <- readLines(path, n = 1L, warn = FALSE)
  nexus_content <- length(first_line) && grepl(
    "^[[:space:]]*#NEXUS", first_line, ignore.case = TRUE
  )
  tree <- if (extension %in% c("nex", "nexus") || nexus_content) {
    ape::read.nexus(path)
  } else {
    ape::read.tree(path)
  }
  if (inherits(tree, "multiPhylo")) {
    stop("Expected one published tree, but the file contains ", length(tree), ".")
  }
  if (!inherits(tree, "phylo")) stop("File did not parse as one phylo object: ", path)
  tree
}

#' Standardise species labels for conservative exact matching
#'
#' Only formatting is changed: underscores become spaces and repeated
#' whitespace is collapsed. No synonym, spelling or genus substitutions are
#' made.
#' @param x Character vector of species names or tree-tip labels.
#' @return Normalised character vector.
standardise_species_label <- function(x) {
  x <- gsub("_", " ", as.character(x), fixed = TRUE)
  trimws(gsub("[[:space:]]+", " ", x))
}

#' Recover species names from published tree-tip schemas
#'
#' Simple `Genus_species` labels are standardised directly. Kawahara et al.
#' tips contain specimen, family, subfamily and tribe fields before the genus
#' and species fields. Yumnam and Kodandaramaiah append optional subspecies
#' fields and a three-letter uppercase subfamily code. These published schemas
#' are parsed by position without changing the raw trees. This is schema
#' parsing rather than taxonomic name correction.
#' @param x Character vector of raw tree-tip labels.
#' @return Standardised candidate binomials.
species_name_from_tip <- function(x) {
  parse_one <- function(label) {
    fields <- strsplit(label, "_", fixed = TRUE)[[1]]
    if (length(fields) >= 7L && grepl("idae$", fields[3])) {
      return(paste(fields[6:7], collapse = " "))
    }
    if (length(fields) >= 3L && grepl("^[A-Z]{3}$", fields[length(fields)])) {
      return(paste(fields[1:2], collapse = " "))
    }
    standardise_species_label(label)
  }
  vapply(as.character(x), parse_one, character(1), USE.NAMES = FALSE)
}

#' Prune a published tree to analysis species and relabel its tips
#'
#' @param tree Published phylogeny.
#' @param crosswalk Curated one-to-one crosswalk for the tree.
#' @param species_names Analysis species names to retain.
#' @param branch_treatment Published branch lengths, Grafen lengths calculated
#'   after pruning, or Grafen lengths calculated on the complete source tree
#'   before pruning.
#' @return A `phylo` whose tip labels equal the analysis species names.
prepare_analysis_tree <- function(
    tree, crosswalk, species_names,
    branch_treatment = c("published", "grafen", "grafen_full")) {
  branch_treatment <- match.arg(branch_treatment)
  map <- crosswalk[
    crosswalk$matched & crosswalk$analysis_species %in% species_names,
    c("analysis_species", "tree_tip_original"), drop = FALSE
  ]
  map <- map[match(species_names, map$analysis_species), , drop = FALSE]
  if (anyNA(map$tree_tip_original) || anyDuplicated(map$tree_tip_original) ||
      anyDuplicated(map$analysis_species)) {
    stop("Tree preparation requires a complete one-to-one crosswalk.")
  }
  source_tree <- tree
  if (branch_treatment == "grafen_full") {
    source_tree <- ape::compute.brlen(source_tree, method = "Grafen", power = 1)
  }
  output <- ape::drop.tip(
    source_tree, setdiff(source_tree$tip.label, map$tree_tip_original)
  )
  replacement <- map$analysis_species[match(output$tip.label, map$tree_tip_original)]
  if (anyNA(replacement)) stop("A retained tree tip could not be relabelled.")
  output$tip.label <- replacement
  if (branch_treatment == "grafen") {
    output <- ape::compute.brlen(output, method = "Grafen", power = 1)
  }
  if (!setequal(output$tip.label, species_names) ||
      ape::Ntip(output) != length(species_names)) {
    stop("Tree and model rows are not one-to-one after pruning.")
  }
  output
}

#' Profile Pagel's lambda over its admissible interval
#'
#' A dense grid identifies the globally best region over `[0, 1]`; bounded
#' optimisation then refines that grid maximum. The approximate 95% interval
#' contains values no more than `qchisq(0.95, 1) / 2` log-likelihood units
#' below the global maximum, with endpoints clipped at zero and one. As a check,
#' lambda is also optimised directly over the whole interval, which can stop at a
#' local maximum; this value (`legacy_lambda`) and its difference from the
#' profile maximum are returned.
#' @param fit_at_lambda Function fitting a model at one fixed lambda.
#' @param grid_size Number of equally spaced profile points, including bounds.
#' @param tolerance Local optimisation and root-finding tolerance.
#' @return Best model, lambda, profile interval, the whole-interval check and the profile.
profile_pagel_lambda <- function(
    fit_at_lambda, grid_size = 101L, tolerance = 1e-5) {
  if (grid_size < 21L) stop("Lambda profiling requires at least 21 grid points.")
  # Retain scalar likelihoods, not every fitted covariance matrix. A full
  # model at each trial can exhaust memory for hundreds of species. Repeated
  # grid/profile evaluations reuse these scalars; only the selected model is
  # fitted again and returned at the end.
  likelihood_cache <- new.env(parent = emptyenv())
  log_likelihood <- function(lambda) {
    key <- sprintf("%.12f", lambda)
    if (exists(key, envir = likelihood_cache, inherits = FALSE)) {
      return(get(key, envir = likelihood_cache, inherits = FALSE))
    }
    fit <- try(fit_at_lambda(lambda), silent = TRUE)
    value <- if (inherits(fit, "try-error")) -Inf else as.numeric(stats::logLik(fit))
    assign(key, value, envir = likelihood_cache)
    value
  }
  grid <- seq(0, 1, length.out = grid_size)
  grid_ll <- vapply(grid, log_likelihood, numeric(1))
  if (!any(is.finite(grid_ll))) stop("No finite likelihood on the lambda grid.")
  best_grid <- which.max(grid_ll)
  left <- grid[max(1L, best_grid - 1L)]
  right <- grid[min(grid_size, best_grid + 1L)]
  refined <- if (left < right) {
    stats::optimize(
      function(x) -log_likelihood(x), c(left, right), tol = tolerance
    )
  } else {
    list(minimum = grid[best_grid], objective = -grid_ll[best_grid])
  }
  candidates <- unique(c(0, grid[best_grid], refined$minimum, 1))
  candidate_ll <- vapply(candidates, log_likelihood, numeric(1))
  lambda <- candidates[which.max(candidate_ll)]
  maximum <- max(candidate_ll)

  # Check: direct optimisation over the whole interval (it can stop at a local maximum)
  legacy <- stats::optimize(
    function(x) -log_likelihood(x), c(0, 1), tol = tolerance
  )
  legacy_candidates <- unique(c(0, legacy$minimum, 1))
  legacy_ll <- vapply(legacy_candidates, log_likelihood, numeric(1))
  legacy_lambda <- legacy_candidates[which.max(legacy_ll)]

  cutoff <- maximum - stats::qchisq(0.95, df = 1) / 2
  profile_grid <- sort(unique(c(grid, lambda)))
  profile_ll <- vapply(profile_grid, log_likelihood, numeric(1))
  best_index <- which.min(abs(profile_grid - lambda))
  eligible <- is.finite(profile_ll) & profile_ll >= cutoff
  lower_index <- best_index
  while (lower_index > 1L && eligible[lower_index - 1L]) {
    lower_index <- lower_index - 1L
  }
  lambda_lower <- if (lower_index == 1L && eligible[1L]) 0 else {
    stats::uniroot(
      function(x) log_likelihood(x) - cutoff,
      c(profile_grid[lower_index - 1L], profile_grid[lower_index]),
      tol = tolerance
    )$root
  }
  upper_index <- best_index
  while (upper_index < length(profile_grid) && eligible[upper_index + 1L]) {
    upper_index <- upper_index + 1L
  }
  lambda_upper <- if (
      upper_index == length(profile_grid) && eligible[length(profile_grid)]) {
    1
  } else {
    stats::uniroot(
      function(x) log_likelihood(x) - cutoff,
      c(profile_grid[upper_index], profile_grid[upper_index + 1L]),
      tol = tolerance
    )$root
  }
  list(
    model = fit_at_lambda(lambda), lambda = lambda,
    lambda_lower = lambda_lower, lambda_upper = lambda_upper,
    legacy_lambda = legacy_lambda,
    legacy_difference = abs(lambda - legacy_lambda),
    maximum_log_likelihood = maximum, cutoff_log_likelihood = cutoff,
    profile = data.frame(
      lambda = profile_grid, log_likelihood = profile_ll,
      within_95 = profile_ll >= cutoff
    )
  )
}

#' Fit and summarise one estimated-lambda PGLS
#'
#' The input data must already be the exact matched-subset LMM rows, including
#' centred partner breadth or regional background where required.
#' @param data Model data with `species`, `log10_range` and predictors.
#' @param tree Published tree.
#' @param crosswalk Curated one-to-one crosswalk.
#' @param formula Fixed-effect formula.
#' @param study,measure,predictors Output identifiers.
#' @param branch_treatment Published, prune-then-Grafen, or
#'   full-tree-Grafen-then-prune branch lengths.
#' @param breadth_reference_centered Centred value corresponding to one genus.
#' @param breadth_reference_original Original-scale breadth reference.
#' @param background_reference Original-scale mean regional background.
#' @param pairwise_adjust Multiplicity correction for interaction contrasts.
#' @param method GLS estimation method, normally REML for final estimates.
#' @param fixed_lambda Optional fixed lambda. The default profiles lambda.
#' @return Model and tidy coefficient, mean, contrast and diagnostic tables.
fit_pagel_pgls <- function(
    data, tree, crosswalk, formula, study, measure, predictors,
    branch_treatment = c("published", "grafen", "grafen_full"),
    breadth_reference_centered = 0,
    breadth_reference_original = NA_real_,
    background_reference = NA_real_, pairwise_adjust = "tukey",
    method = c("REML", "ML"), fixed_lambda = NULL) {
  branch_treatment <- match.arg(branch_treatment)
  method <- match.arg(method)
  d <- data
  d$species <- as.character(d$species)
  if (anyDuplicated(d$species)) stop("PGLS data contain duplicated species.")
  analysis_tree <- prepare_analysis_tree(
    tree, crosswalk, d$species, branch_treatment
  )
  d <- d[match(analysis_tree$tip.label, d$species), , drop = FALSE]
  if (!identical(d$species, analysis_tree$tip.label)) {
    stop("PGLS tree order and data order differ.")
  }
  rownames(d) <- d$species
  warnings <- character()
  fit_at_lambda <- function(lambda) {
    fit <- withCallingHandlers(nlme::gls(
      formula, data = d,
      correlation = ape::corPagel(
        value = lambda, phy = analysis_tree, fixed = TRUE, form = ~species
      ),
      method = method,
      control = nlme::glsControl(
        opt = "optim", maxIter = 200, msMaxIter = 200, tolerance = 1e-8
      )
    ), warning = function(warning) {
      warnings <<- c(warnings, conditionMessage(warning))
      invokeRestart("muffleWarning")
    })
    fit
  }
  if (is.null(fixed_lambda)) {
    profile <- profile_pagel_lambda(fit_at_lambda)
    lambda <- profile$lambda
    model <- profile$model
    lambda_lower <- profile$lambda_lower
    lambda_upper <- profile$lambda_upper
    legacy_lambda <- profile$legacy_lambda
    legacy_difference <- profile$legacy_difference
    lambda_estimated <- TRUE
  } else {
    if (length(fixed_lambda) != 1L || !is.finite(fixed_lambda) ||
        fixed_lambda < 0 || fixed_lambda > 1) {
      stop("fixed_lambda must be one finite value in [0, 1].")
    }
    lambda <- fixed_lambda
    model <- fit_at_lambda(lambda)
    lambda_lower <- lambda_upper <- legacy_lambda <- legacy_difference <- NA_real_
    lambda_estimated <- FALSE
    profile <- list(profile = data.frame(
      lambda = lambda, log_likelihood = as.numeric(stats::logLik(model)),
      within_95 = NA
    ))
  }
  # Keep the exact model rows inside the saved GLS object. nlme otherwise
  # retains the symbol `d` in its call, which cannot be resolved in a new R
  # session and makes getData() unsafe for downstream diagnostics.
  model$data <- d
  tt <- as.data.frame(summary(model)$tTable)
  tt$term <- rownames(tt)
  residual_df <- model$dims$N - model$dims$p
  critical <- stats::qt(0.975, residual_df)
  coefficients <- data.frame(
    study = study, branch_treatment = branch_treatment,
    measure = measure, predictors = predictors, n = nrow(d), term = tt$term,
    estimate_log10 = tt$Value, std_error = tt$Std.Error, df = residual_df,
    lower_log10 = tt$Value - critical * tt$Std.Error,
    upper_log10 = tt$Value + critical * tt$Std.Error,
    p_value = tt$`p-value`, stringsAsFactors = FALSE
  )
  coefficients$range_ratio <- 10^coefficients$estimate_log10
  coefficients$ratio_lower <- 10^coefficients$lower_log10
  coefficients$ratio_upper <- 10^coefficients$upper_log10
  coefficients$percent_difference <- 100 * (coefficients$range_ratio - 1)

  at <- list()
  if ("partner_breadth_centered" %in% names(d)) {
    at$partner_breadth_centered <- breadth_reference_centered
  }
  if ("regional_background_centered" %in% names(d)) {
    at$regional_background_centered <- 0
  }
  emm <- emmeans::emmeans(
    model, ~interaction_type, at = if (length(at)) at else NULL,
    data = d
  )
  means <- as.data.frame(stats::confint(emm))
  means$geometric_estimate <- 10^means$emmean
  means$geometric_lower <- 10^means$lower.CL
  means$geometric_upper <- 10^means$upper.CL
  means$study <- study
  means$branch_treatment <- branch_treatment
  means$measure <- measure
  means$predictors <- predictors
  means$partner_breadth_emm_reference <- breadth_reference_original
  means$regional_background_reference <- background_reference
  contrast_object <- emmeans::contrast(
    emm, method = "pairwise", adjust = pairwise_adjust
  )
  contrasts <- as.data.frame(stats::confint(contrast_object))
  contrast_tests <- as.data.frame(summary(contrast_object))
  contrasts$p.value <- contrast_tests$p.value[
    match(contrasts$contrast, contrast_tests$contrast)
  ]
  contrasts$range_ratio <- 10^contrasts$estimate
  contrasts$ratio_lower <- 10^contrasts$lower.CL
  contrasts$ratio_upper <- 10^contrasts$upper.CL
  contrasts$percent_difference <- 100 * (contrasts$range_ratio - 1)
  contrasts$study <- study
  contrasts$branch_treatment <- branch_treatment
  contrasts$measure <- measure
  contrasts$predictors <- predictors
  contrasts$adjustment <- pairwise_adjust

  normalized <- stats::residuals(model, type = "normalized")
  diagnostics <- data.frame(
    study = study, branch_treatment = branch_treatment,
    measure = measure, predictors = predictors, species = d$species,
    interaction_type = as.character(d$interaction_type),
    fitted = stats::fitted(model), residual = stats::residuals(model),
    normalized_residual = normalized, stringsAsFactors = FALSE
  )
  correlation_matrix <- nlme::corMatrix(model$modelStruct$corStruct)
  condition_number <- tryCatch(kappa(correlation_matrix), error = function(e) NA_real_)
  category_n <- table(factor(d$interaction_type, levels = c("n", "f", "m", "p")))
  # nlme sees lambda as fixed at the selected profile value. Count the
  # externally estimated parameter when exporting AIC, while retaining the
  # conditional value for provenance. REML AIC is comparable only when the
  # fixed-effect design and observations are identical.
  model_log_likelihood <- stats::logLik(model)
  likelihood_parameters <- attr(model_log_likelihood, "df") +
    as.integer(lambda_estimated)
  metadata <- data.frame(
    study = study, branch_treatment = branch_treatment,
    measure = measure, predictors = predictors, method = method, n = nrow(d),
    n_non_associated = unname(category_n["n"]),
    n_facultative = unname(category_n["f"]),
    n_mutualist = unname(category_n["m"]),
    n_parasite = unname(category_n["p"]),
    minimum_category_n = min(category_n[category_n > 0]),
    sparse_category_flag = any(category_n[category_n > 0] < 10),
    lambda = lambda,
    lambda_lower = lambda_lower, lambda_upper = lambda_upper,
    lambda_estimated = lambda_estimated,
    legacy_lambda = legacy_lambda,
    legacy_lambda_difference = legacy_difference,
    lambda_boundary = is.finite(lambda) && (lambda < 0.001 || lambda > 0.999),
    log_likelihood = as.numeric(model_log_likelihood),
    likelihood_parameters = likelihood_parameters,
    AIC_conditional_lambda = stats::AIC(model),
    AIC = -2 * as.numeric(model_log_likelihood) + 2 * likelihood_parameters,
    coefficient_intervals_conditional_on_lambda = TRUE,
    correlation_condition_number = condition_number,
    normalized_residual_mean = mean(normalized),
    normalized_residual_sd = stats::sd(normalized),
    normalized_residual_shapiro_p = if (length(normalized) <= 5000)
      stats::shapiro.test(normalized)$p.value else NA_real_,
    warning = if (length(warnings)) paste(unique(warnings), collapse = " | ") else "",
    converged = TRUE, tree_data_identical = identical(d$species, analysis_tree$tip.label),
    stringsAsFactors = FALSE
  )
  list(
    model = model, tree = analysis_tree, data = d, coefficients = coefficients,
    estimated_means = means, contrasts = contrasts,
    diagnostics = diagnostics, metadata = metadata,
    lambda_profile = transform(
      profile$profile, study = study, branch_treatment = branch_treatment,
      measure = measure, predictors = predictors, method = method
    )
  )
}

#' Match the tips of a published tree to species of the GBIF Backbone snapshot
#'
#' The binomial parsed from each tip label is resolved with `resolve_accepted_key()`
#' (code/R/name_matching.R: exact accepted names and synonyms of one accepted species; no
#' orthographic variants or fuzzy matching), and the accepted key is mapped to the
#' representative key of its duplicate cluster. Tips sharing one parsed binomial are reduced
#' to the first raw label in lexical order. When tips with different binomials reach one
#' representative, only the tip named as that representative is kept; if there is none, no
#' tip is kept for it.
#' @param tree Published phylogeny.
#' @param study Short tree identifier.
#' @param snapshot GBIF Backbone snapshot (`read_backbone_snapshot()`).
#' @param representative_of Named character vector: representative key of each accepted key.
#' @return One row per tip: study, raw label, parsed binomial, accepted and representative
#'   keys, and `matched` (TRUE for the one tip kept per species).
match_tree_tips <- function(tree, study, snapshot, representative_of) {
  tips <- data.frame(study = study,
                     tree_tip_original = tree$tip.label,
                     tree_species_parsed = species_name_from_tip(tree$tip.label),
                     stringsAsFactors = FALSE)
  tips$accepted_key <- resolve_accepted_key(tips$tree_species_parsed, snapshot)
  tips$representative_key <- unname(representative_of[tips$accepted_key])

  # One tip per parsed binomial: the first raw label in lexical order
  o <- order(tips$tree_species_parsed, tips$tree_tip_original)
  first <- logical(nrow(tips))
  first[o] <- !duplicated(tips$tree_species_parsed[o])
  tips$matched <- first & !is.na(tips$representative_key)

  # Several binomials for one representative: keep only the tip named as the representative
  k <- tips$representative_key
  shared <- tips$matched & k %in% k[tips$matched][duplicated(k[tips$matched])]
  rep_name <- snapshot$acc$canonicalName[match(k, snapshot$acc$key)]
  tips$matched[which(shared & (is.na(rep_name) | tips$tree_species_parsed != rep_name))] <- FALSE
  stopifnot(!anyDuplicated(k[tips$matched]))
  tips
}
