# Spatial thinning of a species' localities; used by s02_prepare_ranges and
# s06_summarise_results.

#' Thin a species using an equal-area grid and geodesic separation
#'
#' Cell thinning is applied only when the geodesic diameter exceeds five cell
#' widths. Diameter is evaluated in blocks to avoid a full distance matrix.
#' The original coordinates and columns are retained. No 1,000-record cap is
#' imposed. The distance step uses tidysdm's great-circle method on WGS84.
#' Vertices of the unthinned projected MCP are restored after thinning. This
#' prevents a computational subsample of interior records from changing the
#' range quantity that thinning is meant only to make tractable.
#' @param x Occurrences with decimalLongitude and decimalLatitude (degrees).
#' @param grid Global grid from global_thinning_grid().
#' @param cell_km Grid resolution in kilometres; must match grid.
#' @param distance_km Minimum separation in kilometres.
#' @param span_multiplier Cell-thinning threshold in multiples of cell width.
#' @param seed Reproducible random seed for tie breaking.
#' @return A data frame with original columns and a thinning_audit attribute.
thin_species <- function(x, grid, cell_km = 50, distance_km = 10,
                         span_multiplier = 5, seed = 20240926L) {
  stopifnot(all(is.finite(as.matrix(x[c("decimalLongitude", "decimalLatitude")]))),
    all(abs(x$decimalLongitude) <= 180), all(abs(x$decimalLatitude) <= 90),
    distance_km > 0, span_multiplier > 0,
    all(abs(terra::res(grid) - cell_km * 1000) < 1e-6))
  set.seed(seed)
  # Restore sf's global distance setting on exit.
  old_s2 <- sf::sf_use_s2()
  on.exit(suppressMessages(sf::sf_use_s2(old_s2)), add = TRUE)
  suppressMessages(sf::sf_use_s2(TRUE))
  n_input <- nrow(x)
  x$.input_row <- seq_len(n_input)
  # Protect the geometrically sufficient boundary set before thinning. The CEA
  # projection is derived from the full cleaned species, exactly as it is for
  # the final range calculation.
  unique_rows <- !duplicated(x[c("decimalLongitude", "decimalLatitude")])
  boundary_source <- x[unique_rows, , drop = FALSE]
  boundary_projected <- project_species_cea(
    boundary_source, species_cea_crs(boundary_source$decimalLongitude)
  )
  protected_rows <- if (nrow(boundary_source) >= 3L) {
    boundary_source$.input_row[grDevices::chull(
      boundary_projected$.cea_x, boundary_projected$.cea_y
    )]
  } else boundary_source$.input_row
  pts <- sf::st_as_sf(x, coords = c("decimalLongitude", "decimalLatitude"),
                      crs = 4326, remove = FALSE)
  use_cell <- FALSE
  if (n_input > 1L) {
    for (start in seq.int(1L, n_input, by = 128L)) {
      block <- start:min(start + 127L, n_input)
      if (any(as.numeric(sf::st_distance(pts[block, ], pts)) >
                span_multiplier * cell_km * 1000)) {
        use_cell <- TRUE
        break
      }
    }
  }
  if (use_cell) pts <- tidysdm::thin_by_cell(pts, grid, drop_na = FALSE)
  n_cell <- nrow(pts)
  if (n_cell > 1L) {
    pts <- tidysdm::thin_by_dist(pts, dist_min = distance_km * 1000,
                                dist_method = "great_circle")
  }
  retained_rows <- sort(unique(c(pts$.input_row, protected_rows)))
  out <- x[retained_rows, setdiff(names(x), ".input_row"), drop = FALSE]
  attr(out, "thinning_audit") <- data.frame(input = n_input,
    cell_applied = use_cell, after_cell = n_cell,
    after_distance_before_boundary_restore = nrow(pts),
    protected_boundary_records = length(protected_rows),
    after_distance = nrow(out),
    cell_km = cell_km, distance_km = distance_km, seed = seed)
  out
}
