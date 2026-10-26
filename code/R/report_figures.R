# Inventory of the report figures. Each figure is drawn into its notebook's folder in
# data/intermediate; the notebook then copies it to results/<notebook>/, from where the
# manuscript includes it.
report_figure_notebooks <- c(
  plot_interaction_maps = "s06_summarise_results",                # Fig. 1
  plot_range_by_interaction_type = "s06_summarise_results",       # Fig. 2
  plot_range_by_partner_breadth = "s06_summarise_results",        # Fig. 3
  plot_robustness_core_analyses = "s06_summarise_results",        # Fig. 4
  plot_expert_validation = "s06_summarise_results",               # Fig. S1
  plot_accumulation_example = "s06_summarise_results",            # Fig. S2
  plot_model_diagnostics = "s05_check_robustness",                # Fig. S3
  plot_richness_range_maps = "s06_summarise_results",             # Fig. S4
  plot_gam_spatial_effect = "s06_summarise_results",              # Fig. S5
  plot_regional_background = "s06_summarise_results",             # Fig. S6
  plot_phylogeny_traits = "s06_summarise_results",                # Fig. S7
  plot_robustness_mutualist_contrasts = "s06_summarise_results"   # Fig. S8
)

#' Path of a report figure in results/
#'
#' @param name Figure name from `report_figure_notebooks`, without extension.
#' @return Path of the PNG in `results/<notebook>/`.
report_figure_path <- function(name) {
  notebook <- report_figure_notebooks[[name]]
  file.path(resrepo::path_resrepo(file.path("results", notebook)), paste0(name, ".png"))
}

#' Copy the report figures of one notebook from data/intermediate to results/
#'
#' @param notebook Notebook name, for example `"s06_summarise_results"`.
#' @return Paths of the copied figures, invisibly; stops if a figure is missing.
copy_report_figures <- function(notebook) {
  figures <- names(report_figure_notebooks)[report_figure_notebooks == notebook]
  from <- file.path(resrepo::path_resrepo(file.path("data/intermediate", notebook)), paste0(figures, ".png"))
  missing <- from[!file.exists(from)]
  if (length(missing)) stop("Report figures missing: ", paste(basename(missing), collapse = ", "))
  to <- vapply(figures, report_figure_path, "")
  dir.create(dirname(to[1]), recursive = TRUE, showWarnings = FALSE)
  stopifnot(all(file.copy(from, to, overwrite = TRUE, copy.date = TRUE)))
  message("Copied ", length(to), " report figures to results/", notebook)
  invisible(to)
}
