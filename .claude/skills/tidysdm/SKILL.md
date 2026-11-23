---
name: tidysdm
description: Use the tidysdm R package (the group's own SDM package, built on tidymodels) for any species distribution modelling code: thinning occurrences, sampling background or pseudo-absences (also time-aware, for palaeo records), screening predictors (presence vs background distance, collinearity), spatial block cross-validation, model specs for GLM/GAM/random forest/boosted trees/MaxEnt, grid or Bayesian tuning, simple and repeated ensembles, Boyce/TSS/AUC metrics, thresholds and binary maps, raster prediction, MESS and clamping, response curves and niche overlap. In the butterfly_ant_interactions repository tidysdm is used only to thin occurrence records (`thin_by_cell()` and `thin_by_dist()` in `code/R/thinning.R`); consult this skill before changing that code or adding any other occurrence thinning, background sampling or SDM step, so that existing tidysdm functions are used instead of hand-written replacements.
---

# tidysdm in the butterfly_ant_interactions repository

*Copied on 2026-11-23 from the african_diversity repository, where tidysdm drives the palaeo-SDMs. The function reference was regenerated from this repository's own library. Only thinning is used here (see "Use in this repository"); the modelling steps are kept for reference.*

tidysdm is maintained by our group (EvolEcolGroup; Leonardi, Colucci, Manica et al.). Its functions encode decisions that have been tested and reviewed. Hand-written replacements have repeatedly introduced bugs in the African SDMs, for example an inverted binary level coding and a second `predict_raster()` call per slice where one was enough. So the rule is simple: **look for the tidysdm function first, use its arguments, and write new code only for what the package genuinely lacks.**

## Use in this repository

- `code/R/thinning.R` (`thin_species()`) thins one species' localities in three steps:
  1. `tidysdm::thin_by_cell()` on a global Equal Earth grid (`thin_cell_km = 50` in the s02 parameters), only when the geodesic diameter of the localities exceeds five cell widths;
  2. `tidysdm::thin_by_dist()` with `dist_min` = `thin_distance_km` (10 km) and `dist_method = "great_circle"`;
  3. the vertices of the unthinned minimum convex polygon are put back, so that thinning does not change the range area.

  The seed is fixed per species. s02 (`s02_prepare_ranges.Rmd`, the parallel range calculation) uses it for every species, and s06 for the accumulation-curve figure of *Celastrina argiolus*.
- The thinning settings change the range estimates: do not change them without Ondrej's agreement, and rerun the notebooks that depend on them.
- No SDM, background sampling or ensemble is fitted in this repository.

## Version and where to look

- The notebooks use the **renv library** version: tidysdm **1.0.4.9007** (development version, commit `b983919`, the same as `renv.lock`). Run R from the repository root so that renv activates; the system library may hold another version.
- Function reference for this version: `references/functions.md`. It lists every exported function and the S3 methods that matter (`predict.repeat_ensemble`, `predict.simple_ensemble`, `calib_class_thresh` methods, ...) with title, description, usage and arguments. Read the relevant entry before calling a function you have not used in this session.
- Full help pages (details, value, examples): `?function` in R, or the source clone `C:\Users\ondra\Documents\Cambridge\git\tidysdm\man\*.Rd`. Package code: `...\git\tidysdm\R\`. Changes: `NEWS.md` there.
- Worked workflows: `...\git\tidysdm\vignettes\` — `tidysdm.Rmd` (overview, including repeated ensembles), `a1_palaeodata_application.Rmd` (time-aware thinning and sampling with pastclim), `a2_tidymodels_additions.Rmd` (factors, DALEX, per-model recipes, initial splits, stacks), `a3_troubleshooting.Rmd` (NAs, response variable, GAM formulas, failing splits), `a4_robust_presence_only_sdm.Rmd` (draft: the decisions behind repeated presence-only ensembles; balancing, member filtering, passing rates).
- After the package is updated, regenerate the reference: `Rscript .claude/skills/tidysdm/scripts/make_function_reference.R tidysdm .claude/skills/tidysdm/references/functions.md` (from the repository root).

## Workflow: each step and its function

| Step | tidysdm function(s) | Notes |
|---|---|---|
| Check the response | `check_sdm_presence(data, class)` | `class` must be a factor with `"presence"` as the **first** level; metrics and thresholds assume it. |
| Thin presences | `thin_by_cell(data, raster)`, `thin_by_dist(data, dist_min = km2m(150))` | `thin_by_dist()` measures great-circle distance by default; `dist_method = "euclidean"` uses the projection's units. |
| Thin dated records | `thin_by_cell_time()`, `thin_by_dist_time(..., interval_min = y2d(2000), time_col = "time_bp", lubridate_fun = pastclim::ybp2date)` | For palaeo occurrences (vignette a1). |
| Accessible area from presences | `make_mask_from_presence(data, method = "buffer", buffer = ...)` | Our species builds draw the polygon in `<sp>02` instead; use this only for quick buffers. |
| Background / pseudo-absences | `sample_background(data, raster, n, method = "random" \| "bias" \| c("dist_max", m))`, `sample_pseudoabs(data, n, raster, method = c("dist_min", km2m(50)))` | `return_pres = TRUE` returns presences and background with a `class` column. Background describes available environment; it is not absence data. |
| ... for dated records | `sample_background_time()`, `sample_pseudoabs_time(n_per_presence = 3, time_col, lubridate_fun)` | With a `pastclim::region_series()` raster. |
| Predictor values | `terra::extract(climate, points, ID = FALSE)` + `bind_cols()`; for dated points `pastclim::location_slice_from_region_series()` | Drop incomplete rows, then **recount the classes** before balancing or folds. |
| Screen predictors | `plot_pres_vs_bg(data, class)`, `dist_pres_vs_bg(data, class)`, `filter_collinear(raster_or_df, cutoff = 0.7, method = "cor_caret" \| "vif_cor" \| "vif_step")` | `dist_pres_vs_bg` is the "mismatch" used in our variable-selection notes. `filter_high_cor()` is deprecated. |
| Recipe | `recipe(sf_data, formula = class ~ .)` | tidysdm's `recipe()` method for `sf` (`spatial_recipe`) keeps the coordinates out of the predictors. |
| Model specs | `sdm_spec_glm()`, `sdm_spec_gam()` (+ `gam_formula(recipe)` via `update_workflow_model()`), `sdm_spec_rf()`, `sdm_spec_boost_tree(tune = "sdm")`, `sdm_spec_maxent(tune = "sdm")` | `tune = "sdm"` tunes the parameters that matter for SDMs; `"all"`, `"custom"`, `"none"` also exist. |
| Spatial CV | `spatialsample::spatial_block_cv(data, v = 5, cellsize = grid_cellsize(data) * 1.1, offset = grid_offset(data) + runif(2, 0, cell / 2))`, `check_splits_balance(cv, class)`, `autoplot(cv)` | `spatial_initial_split()` for a held-out test set; `blockcv2rsample()` / `blockcv2initial_split()` convert blockCV objects. |
| Tune | `workflow_set(...) %>% option_add(control = control_ensemble_bayes())` then `workflow_map("tune_bayes", resamples = cv, metrics = ...)` | Use `control_ensemble_grid()` / `control_ensemble_resamples()` for grid search or untuned workflows (`fit_resamples`): they save the predictions and workflows that `add_member()` needs. |
| Metrics | `sdm_metric_set()` = `boyce_cont`, `roc_auc`, `tss_max`; also `kap_max`, `tss`, `optim_thresh` | In this project use the **guarded** Boyce (below), not `sdm_metric_set()`. |
| Ensembles | `simple_ensemble() %>% add_member(models, metric = "boyce_cont")`; `repeat_ensemble() %>% add_repeat(list_of_simple_ensembles)`; `get_repeat()`; `collect_metrics()`; `autoplot()` | `add_member()` keeps the best configuration *per workflow* and refits it on the full data of that repeat; it does not apply the later Boyce cutoff. |
| Predict | `predict_raster(ens, raster, fun = "weighted_median", metric_thresh = c("boyce_cont", 0.7))`; data frames: `predict(ens, new_data, ...)` | For a repeat ensemble `by_repeat = TRUE` returns one prediction per repeat; for a simple ensemble `members = TRUE` returns each member. Large rasters: `filename =`, and raise `n` if memory runs out. |
| Binary maps | `calib_class_thresh(ens, class_thresh = "tss_max", metric_thresh = c("boyce_cont", 0.7))` then `predict_raster(ens, raster, type = "class", class_thresh = "tss_max", class_fun = "majority", metric_thresh = ...)`; `collect_class_thresh(ens)` | Calibrate before predicting classes, with the **same** `metric_thresh`. `class_fun = "prop"` gives the proportion of repeats predicting presence. |
| Transfer to other times/places | `extrapol_mess(x, training, .col = class)`, `clamp_predictors(x, training, .col = class)` | Report MESS with every projection to novel climates. |
| Interpretation | `explain_tidysdm(ens)` (DALEX: `model_parts()`, `model_profile()`), response curves with `recipes::step_profile()` (vignette), `niche_overlap()` | |

## Conventions of the African palaeo-SDM builds (approved there; not used in the butterfly analysis)

Paths such as `code/sdm/...` and the notebooks named below exist in the african_diversity repository (`C:\Users\ondra\Documents\Cambridge\git\african_diversity`), not here.

- **Repeated ensembles in a run-table loop**, as in the hartebeest template (`C:\Users\ondra\Documents\Cambridge\git\pelanek_hartebeest_sdm\code\s03_run_repeated_ensembles.Rmd`) and `code/sdm/giraffe/giraffe07_repeated_ens_loop.Rmd`. Each repeat redraws the stochastic steps (thinning, background, block offset) with a recorded seed and fits the same workflows. Save each repeat as its own file, and keep failed repeats' errors.
- **Algorithms and class balance:**
  - `rf_ds`: ranger with class-specific `sample.fraction`, n_presence/n_total for each class, so every tree sees equal counts.
  - `gbm`: `themis::step_downsample(class, under_ratio = 1, skip = TRUE)` in its recipe. `skip = TRUE` downsamples each analysis fold and the final fit, but never assessment or projection data. This is Ondrej's preference over case weights.
  - `maxent`.
  - Bayesian tuning (`tune_bayes`) within each repeat.
  - See hartebeest s03 chunks around "3e. Spatial block cross-validation folds" and the model-spec list.
- **Guarded Boyce**: always define `boyce_cont` as in `code/sdm/hyena_brown/hyena_brown03_run_repeated_ensembles.Rmd`, chunk `define_guarded_boyce`. Pass `yardstick::metric_set(boyce_cont, yardstick::roc_auc, tss_max)` to tuning.
  - The guard keeps the name `boyce_cont`, so tuning, `add_member(metric = "boyce_cont")` and `metric_thresh` all use the guarded value.
  - `sdm_metric_set()` would bring back tidysdm's unguarded version.
  - Why: a downsampled GBM that makes almost no splits gives 2–3 distinct predictions, and the unguarded index then scores a meaningless Boyce = 1 that tuning selects.
- **Bounded GBM search space** (same notebook, parameter block after `extract_parameter_set_dials()`): `tree_depth(c(1, 5))`, `learn_rate(log10(c(0.003, 0.05)))`, `loss_reduction(c(-5, 0))`, `trees(c(300, 2500))`, set with `option_add(param_info = ...)`.
- **Member filter and outputs:**
  - Members need guarded Boyce ≥ 0.7 (`metric_thresh = c("boyce_cont", 0.7)`); a lower species-specific value needs Ondrej's agreement.
  - Repeats are combined with `fun = "weighted_median"`.
  - Binary maps use `class_thresh = "tss_max"` with majority vote.
- **Binary raster codes**: factor levels `c("presence", "background")`, so 1 = presence and 2 = background. Save the levels next to the raster (`*_levels.rds`) rather than relying on GeoTIFF categories.
- **One prediction per repeat for both maps**: `predict(..., by_repeat = TRUE)` plus `collect_class_thresh()` gives the continuous and the binary map from a single prediction. It was checked against two `predict_raster()` calls and gave identical results. Implemented in `code/sdm/lion/lion03_run_repeated_ensembles.Rmd`, chunk `define_single_pass_prediction`; reuse it rather than writing another version.

## Pitfalls (and why they matter)

- **`metric_thresh` only works with metrics computed during tuning.** If the cutoff removes every member of a repeat, that repeat is silently skipped, which changes the effective ensemble. Report passing rates per algorithm, i.e. repeats whose best member passes, divided by repeats fitted (vignette a4).
- **Weighted aggregation weights algorithms within a repeat by the tuning metric; repeats are then combined without weights.** Don't describe `weighted_median` as weighting repeats.
- **Background from all eligible cells is identical in every repeat**, even with `method = "random"`. With that design, variation between repeats comes from thinning, CV blocks, downsampling and tuning only.
- **CRS**: points and raster must share a CRS before `sample_background()` or `thin_by_cell()`. Thin and build CV blocks in the equal-area CRS of the build (`+proj=laea +lon_0=16.3448611 +lat_0=0`).
- **Never downsample or weight assessment data**: balance inside the recipe with `skip = TRUE`, or inside ranger.
- **Controls**: tuning without `control_ensemble_*()` leaves out the saved predictions and workflows, and `add_member()` then fails.
- **NAs**: rows with missing predictors break recipes and some engines (vignette a3); extract, drop NAs and recount classes before making folds.
- **Long projections** (800 time slices): call `predict_raster()` per slice and save each slice as its own file. Don't keep growing an in-memory stack (see `code/sdm/CLAUDE.md` §10 in african_diversity).

## When tidysdm does not cover something

Check `references/functions.md` and the vignettes first. Then:
1. Use tidymodels, terra or sf directly in a few lines rather than a new helper.
2. Add a helper only if it is genuinely reused (the project's rule), and keep it in the notebook that uses it; `code/R/` is for functions used by more than one notebook.
3. If the gap looks general, tell Ondrej that it is a candidate for tidysdm. He can raise it with the package maintainers.
