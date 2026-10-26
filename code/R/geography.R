# Presence cells on the Equal Earth grid, the all-butterfly regional range-size
# background and the spherical GAM; used by s04_fit_models to s06_summarise_results.

#' Build a species-by-cell presence table on an equal-area grid
#'
#' Each species contributes at most once to a cell, irrespective of how many
#' occurrence records were retained there. The grid uses the repository's
#' global Equal Earth projection, so cells have a common area and do not become
#' narrower towards the poles.
#' @param occurrences Named list of occurrence data frames with longitude and
#'   latitude columns.
#' @param cell_km Nominal square-cell width in kilometres.
#' @return Data frame with one row per occupied species-cell combination.
equal_area_species_cells <- function(occurrences, cell_km = 200) {
  stopifnot(is.list(occurrences), !is.null(names(occurrences)),
            length(cell_km) == 1L, is.finite(cell_km), cell_km > 0)
  rows <- lapply(names(occurrences), function(species) {
    x <- occurrences[[species]]
    if (!nrow(x)) return(NULL)
    data.frame(
      species = species,
      decimalLongitude = x$decimalLongitude,
      decimalLatitude = x$decimalLatitude,
      stringsAsFactors = FALSE
    )
  })
  points <- do.call(rbind, rows)
  points <- project_occurrences(points)
  points$cell_x <- floor(points$easting_km / cell_km)
  points$cell_y <- floor(points$northing_km / cell_km)
  points$cell_id <- paste(points$cell_x, points$cell_y, sep = ":")
  points <- points[!duplicated(points[c("species", "cell_id")]), ]
  cell_centres <- unique(points[c("cell_id", "cell_x", "cell_y")])
  centres_sf <- sf::st_as_sf(
    data.frame(
      cell_id = cell_centres$cell_id,
      # `project_occurrences()` stores projected coordinates in kilometres,
      # whereas the Equal Earth CRS is defined in metres. Convert the cell
      # centres back to metres before the inverse projection to WGS84.
      easting_m = (cell_centres$cell_x + 0.5) * cell_km * 1000,
      northing_m = (cell_centres$cell_y + 0.5) * cell_km * 1000
    ),
    coords = c("easting_m", "northing_m"), crs = global_equal_area_crs()
  )
  centre_coordinates <- sf::st_coordinates(sf::st_transform(centres_sf, 4326))
  cell_centres$cell_longitude <- centre_coordinates[, 1]
  cell_centres$cell_latitude <- centre_coordinates[, 2]
  points <- merge(points, cell_centres, by = c("cell_id", "cell_x", "cell_y"),
                  all.x = TRUE, sort = FALSE)
  points[, c("species", "cell_id", "cell_x", "cell_y",
             "easting_km", "northing_km", "decimalLongitude",
             "decimalLatitude", "cell_longitude", "cell_latitude")]
}

#' Estimate a regional range background from co-occurring butterflies
#'
#' The comparison species come from an external set (e.g. modelled ranges of
#' all butterflies). In every cell occupied by a focal species, the log10
#' ranges of the external species are averaged after leaving out the
#' focal species' genus; cells with fewer than `min_other` comparison species
#' are omitted and the remaining cells are weighted equally.
#' @param presence Focal species-cell table (`species`, `cell_id`).
#' @param genus_of Named vector: focal species -> genus.
#' @param species_ranges External species table: `daru_name`, `genus` and the
#'   range-measure columns named in `measures`.
#' @param species_cells External species-cell table (`daru_name`, `cell_id`) on
#'   the same grid as `presence`.
#' @param measures Named range-measure columns.
#' @param min_other Minimum number of comparison species in a cell.
#' @param drop_genera Optional genera removed from the external set entirely.
#' @return One row per focal species with `regional_background_<label>` and
#'   `background_mean_comparators_<label>` for every measure.
butterfly_range_background <- function(
    presence, genus_of, species_ranges, species_cells,
    measures = c(area = "range_area", lat = "latitudinal_extent",
                 lon = "longitudinal_extent"),
    min_other = 5L, drop_genera = NULL) {
  dsp <- data.table::as.data.table(species_ranges)
  if (!is.null(drop_genera)) dsp <- dsp[!genus %in% drop_genera]
  dce <- data.table::as.data.table(species_cells)[, c("daru_name", "cell_id")]
  out <- data.table::data.table(species = unique(presence$species))
  for (label in names(measures)) {
    v <- dsp[[measures[[label]]]]
    dsp[, lv := data.table::fifelse(is.finite(v) & v > 0, log10(v), NA_real_)]
    x <- merge(dce, dsp[!is.na(lv), .(daru_name, genus, lv)], by = "daru_name")
    cs <- x[, .(S = sum(lv), N = .N), by = cell_id]
    cg <- x[, .(Sg = sum(lv), Ng = .N), by = .(cell_id, genus)]
    p <- data.table::data.table(species = presence$species, cell_id = presence$cell_id)
    p[, genus := unname(genus_of[species])]
    p <- merge(p, cs, by = "cell_id", all.x = TRUE)
    p <- merge(p, cg, by = c("cell_id", "genus"), all.x = TRUE)
    p[is.na(S), `:=`(S = 0, N = 0L)][is.na(Sg), `:=`(Sg = 0, Ng = 0L)]
    p[, n_other := N - Ng]
    p[, bgc := data.table::fifelse(n_other >= min_other, (S - Sg) / n_other, NA_real_)]
    s <- p[, .(bg = if (any(is.finite(bgc))) mean(bgc, na.rm = TRUE) else NA_real_,
               comp = if (any(is.finite(bgc))) mean(n_other[is.finite(bgc)]) else NA_real_),
           by = species]
    out[, (paste0("regional_background_", label)) := s$bg[match(species, s$species)]]
    out[, (paste0("background_mean_comparators_", label)) := s$comp[match(species, s$species)]]
  }
  as.data.frame(out)
}

#' Fit species-level spatial range models on the sphere
#'
#' Each species contributes one equal-cell-weighted geographic centre. The
#' `bs = "sos"` term is an isotropic spline on the sphere, with latitude as its
#' first argument and longitude as its second. Random-effect smooths retain the
#' taxonomic controls used elsewhere in the analysis. Models use REML and
#' log10 range responses.
#' @param species Species table containing range, interaction and taxonomy data.
#' @param response Name of the positive range-response column.
#' @param include_breadth Include recorded ant-partner breadth as a linear term.
#' @param k Basis dimension for the spherical spatial smooth.
#' @return A list containing the fitted GAM, analysis data, coefficients,
#'   estimated marginal means, Tukey contrasts, omnibus tests and diagnostics.
fit_species_spatial_gam <- function(
    species, response, include_breadth = FALSE, k = 160L) {
  needed <- c(response, "interaction_type", "subfamily", "genus",
              "geo_latitude", "geo_longitude")
  if (include_breadth) needed <- c(needed, "host_breadth")
  stopifnot(all(needed %in% names(species)))
  keep <- is.finite(species[[response]]) & species[[response]] > 0 &
    !is.na(species$interaction_type) & !is.na(species$subfamily) &
    !is.na(species$genus) & is.finite(species$geo_latitude) &
    is.finite(species$geo_longitude)
  if (include_breadth) {
    keep <- keep & species$interaction_type %in% c("f", "m", "p") &
      is.finite(species$host_breadth)
  }
  d <- droplevels(species[keep, , drop = FALSE])
  d$log10_range <- log10(d[[response]])
  d$interaction_type <- factor(d$interaction_type, levels = c("n", "f", "m", "p"))
  d$subfamily <- factor(d$subfamily)
  d$genus <- factor(d$genus)
  d$partner_breadth_centered <- if (include_breadth) {
    d$host_breadth - mean(d$host_breadth)
  } else 0
  fixed <- if (include_breadth) {
    "interaction_type + partner_breadth_centered"
  } else "interaction_type"
  formula <- stats::as.formula(paste(
    "log10_range ~", fixed,
    "+ s(geo_latitude, geo_longitude, bs = 'sos', k =", as.integer(k), ")",
    "+ s(subfamily, bs = 're') + s(genus, bs = 're')"
  ))
  model <- mgcv::gam(formula, data = d, method = "REML")
  coefficient_matrix <- summary(model)$p.table
  coefficients <- data.frame(
    term = rownames(coefficient_matrix), estimate_log10 = coefficient_matrix[, 1],
    std_error = coefficient_matrix[, 2], statistic = coefficient_matrix[, 3],
    p_value = coefficient_matrix[, 4], row.names = NULL
  )
  coefficients$range_ratio <- 10^coefficients$estimate_log10
  coefficients$ratio_lower <- 10^(coefficients$estimate_log10 -
                                    1.96 * coefficients$std_error)
  coefficients$ratio_upper <- 10^(coefficients$estimate_log10 +
                                    1.96 * coefficients$std_error)
  at <- if (include_breadth) {
    list(partner_breadth_centered = 1 - mean(d$host_breadth))
  } else NULL
  emm <- emmeans::emmeans(model, ~interaction_type, at = at)
  means <- as.data.frame(emm)
  means$geometric_estimate <- 10^means$emmean
  means$geometric_lower <- 10^means$lower.CL
  means$geometric_upper <- 10^means$upper.CL
  contrasts <- as.data.frame(summary(emmeans::contrast(
    emm, method = "pairwise", adjust = "tukey", infer = c(TRUE, TRUE)
  )))
  contrasts$range_ratio <- 10^contrasts$estimate
  contrasts$ratio_lower <- 10^contrasts$lower.CL
  contrasts$ratio_upper <- 10^contrasts$upper.CL
  model_summary <- summary(model)
  parametric_tests <- as.data.frame(model_summary$pTerms.table)
  parametric_tests$term <- rownames(parametric_tests)
  names(parametric_tests)[names(parametric_tests) == "p-value"] <- "p_value"
  smooth_tests <- as.data.frame(model_summary$s.table)
  smooth_tests$term <- rownames(smooth_tests)
  names(smooth_tests)[names(smooth_tests) == "p-value"] <- "p_value"
  omnibus <- rbind(
    data.frame(
      term = parametric_tests$term, df = parametric_tests$df,
      reference_df = NA_real_, statistic = parametric_tests$F,
      p_value = parametric_tests$p_value, component = "parametric"
    ),
    data.frame(
      term = smooth_tests$term, df = smooth_tests$edf,
      reference_df = smooth_tests$Ref.df, statistic = smooth_tests$F,
      p_value = smooth_tests$p_value, component = "smooth"
    )
  )
  # k.check uses a random residual permutation for its p-value. Fixing the
  # seed makes the saved diagnostic reproducible without affecting the model.
  set.seed(20240927L)
  k_diagnostic <- as.data.frame(mgcv::k.check(model))
  list(
    model = model, data = d, coefficients = coefficients,
    estimated_means = means, contrasts = contrasts, omnibus = omnibus,
    k_check = k_diagnostic,
    metadata = data.frame(
      n = nrow(d), response = response,
      predictors = if (include_breadth) "breadth" else "type",
      breadth_reference = if (include_breadth) 1 else NA_real_,
      deviance_explained = model_summary$dev.expl,
      adjusted_r2 = model_summary$r.sq, stringsAsFactors = FALSE
    )
  )
}

#' Great-circle distances between all pairs of points
#'
#' @param lat,lon Latitudes and longitudes in degrees.
#' @return Symmetric matrix of distances in km (Earth radius 6371 km).
gc_km <- function(lat, lon) {
  la <- lat * pi / 180; lo <- lon * pi / 180
  x <- cbind(cos(la) * cos(lo), cos(la) * sin(lo), sin(la))
  6371 * acos(pmax(pmin(x %*% t(x), 1), -1))
}
