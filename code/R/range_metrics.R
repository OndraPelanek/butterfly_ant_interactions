# Range measures of occurrence localities: latitudinal extent, circular
# longitudinal extent, minimum-convex-polygon area and their rarefaction
# stability; used by s02_prepare_ranges (whose parallel workers source this file),
# s03_build_species_tables, s05_check_robustness and s06_summarise_results.

#' Describe the occupied longitude arc on a circular axis
#'
#' @param longitude Longitudes in decimal degrees.
#' @return Largest empty gap, occupied span, occupied midpoint, seam through the
#'   empty gap and the opposite central meridian, all in degrees.
circular_longitude_geometry <- function(longitude) {
  stopifnot(length(longitude) >= 1L, all(is.finite(longitude)))
  ordered <- sort(unique(longitude %% 360))
  if (length(ordered) == 1L) {
    seam <- (ordered + 180) %% 360
    return(c(largest_empty_gap = 360, angular_span = 0,
             midpoint = ((ordered + 180) %% 360) - 180,
             seam = ((seam + 180) %% 360) - 180,
             central_meridian = ((seam + 360) %% 360) - 180))
  }
  next_longitude <- c(ordered[-1], ordered[1] + 360)
  gaps <- next_longitude - ordered
  largest_gap <- which.max(gaps)
  seam_unwrapped <- ordered[largest_gap] + gaps[largest_gap] / 2
  start <- next_longitude[largest_gap]
  end <- ordered[largest_gap] + 360
  angular_span <- 360 - gaps[largest_gap]
  midpoint <- start + angular_span / 2
  seam <- ((seam_unwrapped + 180) %% 360) - 180
  central_meridian <- ((seam_unwrapped + 360) %% 360) - 180
  c(
    largest_empty_gap = gaps[largest_gap], angular_span = angular_span,
    midpoint = ((midpoint + 180) %% 360) - 180,
    seam = seam, central_meridian = central_meridian
  )
}

#' Measure the occupied longitude arc without an antimeridian discontinuity
#'
#' Longitudes are placed on a circular axis and the largest unoccupied gap is
#' removed. The occupied angular span is converted to distance along the
#' latitude parallel at a fixed reference latitude.
#' @param longitude Longitudes in decimal degrees.
#' @param reference_latitude Latitude in decimal degrees used to express the
#'   angular longitude span in kilometres.
#' @return Named vector containing extent in km, circular midpoint longitude,
#'   and angular span in degrees.
circular_longitude_extent <- function(longitude, reference_latitude) {
  stopifnot(length(longitude) >= 1L, all(is.finite(longitude)),
            length(reference_latitude) == 1L, is.finite(reference_latitude),
            abs(reference_latitude) <= 90)
  geometry <- circular_longitude_geometry(longitude)
  extent <- 6371.0088 * cos(reference_latitude * pi / 180) *
    geometry["angular_span"] * pi / 180
  c(extent = unname(extent), midpoint = unname(geometry["midpoint"]),
    angular_span = unname(geometry["angular_span"]))
}

#' Construct a species-specific Cylindrical Equal Area CRS
#'
#' The map seam is placed at the midpoint of the largest empty longitude gap;
#' the central meridian is 180 degrees opposite the seam. The standard parallel
#' is fixed, so only the central meridian differs among species.
#' @param longitude Full species longitudes in decimal degrees.
#' @param standard_parallel Fixed standard parallel in degrees.
#' @return An `sf` CRS object with seam and central-meridian attributes.
species_cea_crs <- function(longitude, standard_parallel = 30) {
  stopifnot(length(standard_parallel) == 1L, is.finite(standard_parallel),
            abs(standard_parallel) < 90)
  geometry <- circular_longitude_geometry(longitude)
  crs <- sf::st_crs(sprintf(
    "+proj=cea +lat_ts=%0.10g +lon_0=%0.10g +datum=WGS84 +units=m +no_defs",
    standard_parallel, unname(geometry["central_meridian"])
  ))
  attr(crs, "seam_longitude") <- unname(geometry["seam"])
  attr(crs, "central_meridian") <- unname(geometry["central_meridian"])
  attr(crs, "standard_parallel") <- standard_parallel
  crs
}

#' Project occurrences once into a species-specific CEA coordinate system
#' @param x Occurrence data with WGS84 coordinates.
#' @param projection CRS returned by `species_cea_crs()`.
#' @return Input data with cached `.cea_x` and `.cea_y` metre coordinates.
project_species_cea <- function(x, projection) {
  points <- sf::st_as_sf(
    x, coords = c("decimalLongitude", "decimalLatitude"), crs = 4326,
    remove = FALSE
  )
  xy <- sf::st_coordinates(sf::st_transform(points, projection))
  x$.cea_x <- xy[, 1]
  x$.cea_y <- xy[, 2]
  x
}

#' Calculate planar convex-hull area from projected coordinates
#' @param x,y Projected coordinates in metres.
#' @return Convex-hull area in square kilometres.
planar_mcp_area <- function(x, y) {
  coordinates <- unique(data.frame(x = x, y = y))
  if (nrow(coordinates) < 3L) return(NA_real_)
  hull_id <- grDevices::chull(coordinates$x, coordinates$y)
  hull <- coordinates[c(hull_id, hull_id[1]), ]
  abs(sum(
    hull$x[-nrow(hull)] * hull$y[-1] -
      hull$x[-1] * hull$y[-nrow(hull)]
  )) / 2 / 1e6
}

#' Calculate antimeridian-safe projected MCP range measures
#'
#' Longitude is circular and area is an ordinary planar minimum convex polygon
#' after projection to a species-specific Cylindrical Equal Area CRS. For
#' accumulation or rarefaction, supply the CRS derived once from the full
#' species occurrence set.
#' @param x Occurrences with WGS84 decimalLongitude and decimalLatitude.
#' @param longitude_reference_latitude Optional fixed full-range latitude.
#' @param projection Optional fixed species-specific CRS from `species_cea_crs()`.
#' @param standard_parallel Fixed Cylindrical Equal Area standard parallel.
#' @param include_s2_audit Calculate the slower S2 audit area. Rarefaction and
#'   accumulation subsets set this to FALSE because S2 is not an analysed metric.
#' @return Named range metrics, projected-area audit fields and S2 audit area.
projected_mcp_extent_area <- function(
    x, longitude_reference_latitude = NULL, projection = NULL,
    standard_parallel = 30, include_s2_audit = TRUE) {
  stopifnot(nrow(x) >= 3L, all(is.finite(x$decimalLongitude)),
            all(is.finite(x$decimalLatitude)))
  coordinates <- unique(x[c("decimalLongitude", "decimalLatitude")])
  if (nrow(coordinates) < 3L) {
    return(c(latitudinal_extent = NA_real_, longitudinal_extent = NA_real_,
             range_area = NA_real_, midpoint_latitude = NA_real_,
             midpoint_longitude = NA_real_, s2_range_area = NA_real_,
             cea_central_meridian = NA_real_, cea_seam_longitude = NA_real_))
  }
  min_lat <- min(coordinates$decimalLatitude)
  max_lat <- max(coordinates$decimalLatitude)
  mid_lat <- mean(c(min_lat, max_lat))
  longitude_latitude <- if (is.null(longitude_reference_latitude)) mid_lat else {
    stopifnot(length(longitude_reference_latitude) == 1L,
              is.finite(longitude_reference_latitude),
              abs(longitude_reference_latitude) <= 90)
    longitude_reference_latitude
  }
  if (is.null(projection)) {
    projection <- species_cea_crs(
      coordinates$decimalLongitude, standard_parallel = standard_parallel
    )
  }
  longitude <- circular_longitude_extent(
    coordinates$decimalLongitude, reference_latitude = longitude_latitude
  )
  mid_lon <- unname(longitude["midpoint"])
  latitude_extent <- 6371.0088 * (max_lat - min_lat) * pi / 180
  if (all(c(".cea_x", ".cea_y") %in% names(x))) {
    projected_coordinates <- unique(x[c(".cea_x", ".cea_y")])
  } else {
    projected_x <- project_species_cea(coordinates, projection)
    projected_coordinates <- projected_x[c(".cea_x", ".cea_y")]
  }
  area <- planar_mcp_area(
    projected_coordinates$.cea_x, projected_coordinates$.cea_y
  )
  s2_area <- NA_real_
  if (include_s2_audit) {
    s2_points <- s2::as_s2_geography(sprintf(
      "POINT (%0.15g %0.15g)", coordinates$decimalLongitude,
      coordinates$decimalLatitude
    ))
    s2_area <- as.numeric(
      s2::s2_area(s2::s2_convex_hull_agg(s2_points))
    ) / 1e6
  }
  projection_geometry <- circular_longitude_geometry(
    coordinates$decimalLongitude
  )
  central_meridian <- attr(projection, "central_meridian")
  seam_longitude <- attr(projection, "seam_longitude")
  if (is.null(central_meridian)) {
    central_meridian <- unname(projection_geometry["central_meridian"])
  }
  if (is.null(seam_longitude)) {
    seam_longitude <- unname(projection_geometry["seam"])
  }
  c(
    latitudinal_extent = latitude_extent,
    longitudinal_extent = unname(longitude["extent"]), range_area = area,
    midpoint_latitude = mid_lat, midpoint_longitude = mid_lon,
    s2_range_area = s2_area,
    cea_central_meridian = central_meridian,
    cea_seam_longitude = seam_longitude
  )
}

#' Average range measures across random occurrence subsets
#'
#' @param x Occurrence data frame.
#' @param n_records Number of records drawn without replacement.
#' @param n_rep Number of replicate draws.
#' @param metric_function Function used to compute the three range measures.
#' @return Named vector of mean latitude extent, longitude extent and area.
rarefy_extent <- function(x, n_records, n_rep = 1000L,
                          metric_function = projected_mcp_extent_area) {
  draws <- replicate(n_rep, metric_function(
    x[sample.int(nrow(x), n_records), , drop = FALSE]
  )[1:3])
  rowMeans(draws)
}

#' Estimate range size and 80-percent rarefaction completeness
#'
#' @param occ Named list of occurrence data frames.
#' @param n_rep Replicates for the 80-percent subsamples.
#' @param seed Base random seed; each species receives a stable offset.
#' @param metric_function Function used to compute the three range measures.
#' @param checkpoint_dir Optional per-species RDS checkpoint directory.
#' @param fixed_longitude_reference Keep the full species' latitudinal midpoint
#'   fixed for the full estimate and every rarefaction draw.
#' @param fixed_projection Project each species once to its full-range
#'   Cylindrical Equal Area CRS and use it for the full estimate and every draw.
#' @return Species table; species with fewer than five records receive missing metrics.
range_metrics <- function(occ, n_rep = 1000L, seed = 20240401L,
                          metric_function = projected_mcp_extent_area,
                          checkpoint_dir = NULL,
                          fixed_longitude_reference = TRUE,
                          fixed_projection = identical(
                            metric_function, projected_mcp_extent_area
                          )) {
  if (!is.null(checkpoint_dir)) dir.create(checkpoint_dir, recursive = TRUE, showWarnings = FALSE)
  rows <- lapply(seq_along(occ), function(i) {
    species <- names(occ)[i]
    checkpoint <- if (is.null(checkpoint_dir)) NA_character_ else
      file.path(checkpoint_dir, paste0(species, ".rds"))
    if (!is.na(checkpoint) && file.exists(checkpoint)) return(readRDS(checkpoint))
    set.seed(seed + i)
    x <- occ[[species]]
    result <- if (nrow(x) < 5L) {
      data.frame(species = species, latitudinal_extent = NA,
        longitudinal_extent = NA, range_area = NA, midpoint_latitude = NA,
        midpoint_longitude = NA, s2_range_area = NA,
        cea_central_meridian = NA, cea_seam_longitude = NA,
        occurrence_count = nrow(x), asympt_prop_lat = NA,
        asympt_prop_lon = NA, asympt_prop_area = NA)
    } else {
      species_metric <- metric_function
      reference_latitude <- if (fixed_longitude_reference) {
        mean(range(x$decimalLatitude))
      } else NULL
      projection <- if (fixed_projection) {
        species_cea_crs(x$decimalLongitude)
      } else NULL
      if (fixed_projection) {
        x <- project_species_cea(x, projection)
        full <- metric_function(
          x, longitude_reference_latitude = reference_latitude,
          projection = projection, include_s2_audit = TRUE
        )
        species_metric <- function(y) metric_function(
          y, longitude_reference_latitude = reference_latitude,
          projection = projection, include_s2_audit = FALSE
        )
      } else if (fixed_longitude_reference) {
        species_metric <- function(y) metric_function(
          y, longitude_reference_latitude = reference_latitude
        )
      }
      if (!fixed_projection) full <- species_metric(x)
      rare <- rarefy_extent(x, floor(0.8 * nrow(x)), n_rep, species_metric)
      data.frame(species = species, t(full), occurrence_count = nrow(x),
        asympt_prop_lat = rare[1] / full[1],
        asympt_prop_lon = rare[2] / full[2],
        asympt_prop_area = rare[3] / full[3], check.names = FALSE)
    }
    if (!is.na(checkpoint)) saveRDS(result, checkpoint, version = 3)
    message("Calculated ranges: ", species)
    result
  })
  do.call(rbind, rows)
}
