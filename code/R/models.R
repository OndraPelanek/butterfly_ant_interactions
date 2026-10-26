# Taxonomic mixed models of log10 range size with their estimated means and
# contrasts; used by s04_fit_models to s06_summarise_results.

#' Fit the log10 range-size mixed models
#'
#' The function fits one model for interaction
#' type and a second model for ant-associated species with recorded partner
#' breadth. Partner breadth is centred within the analysed sample so type
#' contrasts refer to an observed, meaningful value. Pairwise comparisons use
#' Tukey adjustment, and estimates are returned both on the log10 scale and as
#' ratios on the original range-size scale.
#' @param data Species table with corrected range metrics and traits.
#' @param measures Named response-column vector; area should be listed first.
#' @param stability_threshold Optional lower bound for the metric-specific
#'   80-percent stability ratio. `NULL` uses all eligible ranges.
#' @param regional_background Include the corresponding species-level regional
#'   background column (`regional_background_area`, etc.) as a centred covariate.
#' @param breadth_scale Use raw partner count or `log1p` count. Raw count is the
#'   publication default unless diagnostics clearly support the alternative.
#' @param pairwise_adjust Multiplicity adjustment passed to `emmeans` contrasts.
#' @return Models, analysed data, coefficients, geometric estimates, adjusted
#'   contrasts, model metadata, residual diagnostics and residual-spread tables.
fit_log_range_models <- function(
    data,
    measures = c(area = "range_area", lat = "latitudinal_extent",
                 lon = "longitudinal_extent"),
    stability_threshold = NULL,
    regional_background = FALSE,
    breadth_scale = c("raw", "log1p"),
    pairwise_adjust = "tukey") {
  breadth_scale <- match.arg(breadth_scale)
  models <- model_data <- list()
  coefficients <- means <- contrasts <- diagnostics <- spread <- metadata <- list()

  summarise_model <- function(model, d, label, predictors, breadth_mean = NA_real_,
                              breadth_reference_centered = 0,
                              breadth_reference_original = NA_real_,
                              background_mean = NA_real_) {
    model_key <- paste(label, predictors, sep = "_")
    r2 <- suppressWarnings(MuMIn::r.squaredGLMM(model)[1, ])
    fixed <- as.data.frame(summary(model)$coefficients)
    fixed$term <- rownames(fixed)
    critical <- ifelse(is.finite(fixed$df), stats::qt(0.975, fixed$df), 1.96)
    fixed$lower_log10 <- fixed$Estimate - critical * fixed$`Std. Error`
    fixed$upper_log10 <- fixed$Estimate + critical * fixed$`Std. Error`
    coefficient_table <- data.frame(
      measure = label, predictors = predictors, n = nrow(d), term = fixed$term,
      estimate_log10 = fixed$Estimate, std_error = fixed$`Std. Error`, df = fixed$df,
      lower_log10 = fixed$lower_log10, upper_log10 = fixed$upper_log10,
      range_ratio = 10^fixed$Estimate,
      ratio_lower = 10^fixed$lower_log10, ratio_upper = 10^fixed$upper_log10,
      percent_difference = 100 * (10^fixed$Estimate - 1),
      p_value = fixed$`Pr(>|t|)`, row.names = NULL
    )

    at_values <- list()
    if ("partner_breadth_centered" %in% names(d)) {
      at_values$partner_breadth_centered <- breadth_reference_centered
    }
    if ("regional_background_centered" %in% names(d)) {
      at_values$regional_background_centered <- 0
    }
    emm <- emmeans::emmeans(
      model, ~ interaction_type,
      at = if (length(at_values)) at_values else NULL
    )
    mean_table <- as.data.frame(stats::confint(emm))
    mean_table$geometric_estimate <- 10^mean_table$emmean
    mean_table$geometric_lower <- 10^mean_table$lower.CL
    mean_table$geometric_upper <- 10^mean_table$upper.CL
    mean_table$measure <- label
    mean_table$predictors <- predictors
    mean_table$partner_breadth_reference <- breadth_mean
    mean_table$partner_breadth_emm_reference <- breadth_reference_original
    mean_table$regional_background_reference <- background_mean

    pairwise_object <- emmeans::contrast(
      emm, method = "pairwise", adjust = pairwise_adjust
    )
    pairwise <- as.data.frame(stats::confint(pairwise_object))
    pairwise_tests <- as.data.frame(summary(pairwise_object))
    pairwise$p.value <- pairwise_tests$p.value[
      match(pairwise$contrast, pairwise_tests$contrast)
    ]
    pairwise$range_ratio <- 10^pairwise$estimate
    pairwise$ratio_lower <- 10^pairwise$lower.CL
    pairwise$ratio_upper <- 10^pairwise$upper.CL
    pairwise$percent_difference <- 100 * (pairwise$range_ratio - 1)
    pairwise$measure <- label
    pairwise$predictors <- predictors
    pairwise$adjustment <- pairwise_adjust

    fitted_values <- stats::fitted(model)
    residual_values <- stats::residuals(model)
    leverage <- stats::hatvalues(model)
    standardised <- residual_values /
      (stats::sigma(model) * sqrt(pmax(1 - leverage, .Machine$double.eps)))
    n_fixed <- length(lme4::fixef(model))
    cook <- standardised^2 * leverage /
      (n_fixed * pmax(1 - leverage, .Machine$double.eps))
    diagnostic_table <- data.frame(
      species = rownames(stats::model.frame(model)),
      measure = label, predictors = predictors,
      interaction_type = stats::model.frame(model)$interaction_type,
      fitted = fitted_values, residual = residual_values,
      standardised_residual = standardised, leverage = leverage,
      approximate_cook_distance = cook, row.names = NULL
    )
    spread_table <- stats::aggregate(
      diagnostic_table$residual,
      list(interaction_type = diagnostic_table$interaction_type),
      stats::sd
    )
    names(spread_table)[2] <- "residual_sd"
    spread_table$measure <- label
    spread_table$predictors <- predictors
    finite_sd <- spread_table$residual_sd[is.finite(spread_table$residual_sd) &
                                            spread_table$residual_sd > 0]
    spread_ratio <- if (length(finite_sd)) max(finite_sd) / min(finite_sd) else NA_real_
    variance <- as.data.frame(lme4::VarCorr(model))
    meta <- data.frame(
      measure = label, predictors = predictors, n = nrow(d),
      subfamilies = length(unique(d$subfamily)), genera = length(unique(d$genus)),
      marginal_r2 = unname(r2[1]), conditional_r2 = unname(r2[2]),
      singular = lme4::isSingular(model, tol = 1e-5),
      subfamily_variance = variance$vcov[variance$grp == "subfamily"][1],
      genus_variance = variance$vcov[variance$grp == "genus:subfamily"][1],
      residual_variance = variance$vcov[variance$grp == "Residual"][1],
      residual_sd_ratio = spread_ratio,
      heteroscedasticity_flag = is.finite(spread_ratio) && spread_ratio > 2,
      partner_breadth_mean = breadth_mean,
      partner_breadth_emm_reference = breadth_reference_original,
      regional_background_mean = background_mean,
      stringsAsFactors = FALSE
    )
    list(key = model_key, coefficients = coefficient_table, means = mean_table,
         contrasts = pairwise, diagnostics = diagnostic_table,
         spread = spread_table, metadata = meta)
  }

  for (label in names(measures)) {
    response <- measures[[label]]
    d <- data
    if (!is.null(stability_threshold)) {
      stability <- paste0("asympt_prop_", label)
      d <- d[is.finite(d[[stability]]) &
               d[[stability]] > stability_threshold, , drop = FALSE]
    }
    d <- d[is.finite(d[[response]]) & d[[response]] > 0 &
             !is.na(d$interaction_type) & !is.na(d$genus) &
             !is.na(d$subfamily), , drop = FALSE]
    d$interaction_type <- droplevels(factor(
      d$interaction_type, levels = c("n", "f", "m", "p")
    ))
    d$log10_range <- log10(d[[response]])
    background_mean <- NA_real_
    background_term <- ""
    if (regional_background) {
      background_column <- paste0("regional_background_", label)
      d <- d[is.finite(d[[background_column]]), , drop = FALSE]
      background_mean <- mean(d[[background_column]])
      d$regional_background_centered <- d[[background_column]] - background_mean
      background_term <- " + regional_background_centered"
    }
    rownames(d) <- make.unique(as.character(d$species))
    type_formula <- stats::as.formula(paste0(
      "log10_range ~ interaction_type", background_term,
      " + (1 | subfamily/genus)"
    ))
    type_model <- lmerTest::lmer(type_formula, data = d)
    type_summary <- summarise_model(
      type_model, d, label, "type", background_mean = background_mean
    )
    models[[type_summary$key]] <- type_model
    model_data[[type_summary$key]] <- d

    d_breadth <- droplevels(d[
      d$interaction_type != "n" & is.finite(d$host_breadth), , drop = FALSE
    ])
    background_mean_breadth <- NA_real_
    if (regional_background) {
      background_column <- paste0("regional_background_", label)
      # Centre the geographic background within the data used by this model.
      # This makes the reported interaction-type means refer to the average
      # background of the ant-associated species actually analysed.
      background_mean_breadth <- mean(d_breadth[[background_column]])
      d_breadth$regional_background_centered <-
        d_breadth[[background_column]] - background_mean_breadth
    }
    breadth_values <- if (breadth_scale == "raw") {
      d_breadth$host_breadth
    } else {
      log1p(d_breadth$host_breadth)
    }
    breadth_mean_model_scale <- mean(breadth_values)
    d_breadth$partner_breadth_centered <- breadth_values - breadth_mean_model_scale
    breadth_reference_original <- 1
    breadth_reference_centered <- if (breadth_scale == "raw") {
      breadth_reference_original - breadth_mean_model_scale
    } else {
      log1p(breadth_reference_original) - breadth_mean_model_scale
    }
    breadth_formula <- stats::as.formula(paste0(
      "log10_range ~ interaction_type + partner_breadth_centered",
      background_term, " + (1 | subfamily/genus)"
    ))
    breadth_model <- lmerTest::lmer(breadth_formula, data = d_breadth)
    breadth_summary <- summarise_model(
      breadth_model, d_breadth, label, "breadth",
      breadth_mean = if (breadth_scale == "raw") breadth_mean_model_scale else
        expm1(breadth_mean_model_scale),
      breadth_reference_centered = breadth_reference_centered,
      breadth_reference_original = breadth_reference_original,
      background_mean = background_mean_breadth
    )
    models[[breadth_summary$key]] <- breadth_model
    model_data[[breadth_summary$key]] <- d_breadth

    for (item in list(type_summary, breadth_summary)) {
      coefficients[[item$key]] <- item$coefficients
      means[[item$key]] <- item$means
      contrasts[[item$key]] <- item$contrasts
      diagnostics[[item$key]] <- item$diagnostics
      spread[[item$key]] <- item$spread
      metadata[[item$key]] <- item$metadata
    }
  }
  list(
    models = models, model_data = model_data,
    coefficients = do.call(rbind, coefficients),
    estimated_means = do.call(rbind, means),
    contrasts = do.call(rbind, contrasts),
    diagnostics = do.call(rbind, diagnostics),
    residual_spread = do.call(rbind, spread),
    metadata = do.call(rbind, metadata),
    stability_threshold = stability_threshold,
    breadth_scale = breadth_scale,
    regional_background = regional_background
  )
}
