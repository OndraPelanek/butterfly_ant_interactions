# The global Equal Earth projection, its grids and the projection of occurrence
# records; used by s02_prepare_ranges to s06_summarise_results.

#' Select a global equal-area projection
#'
#' Uses crstools to choose the projection for the full WGS84 globe. Distances
#' remain geodesic; this CRS is for cell areas, maps and projected GAM covariates.
#' @return An sf CRS object (metres).
global_equal_area_crs <- function() {
  choice <- crstools::suggest_crs(c(-180, 180, -90, 90),
    distortion = "equal_area", return_best = TRUE, quiet = TRUE)
  sf::st_crs(choice$proj4)
}

#' Construct an empty global equal-area thinning grid
#' @param cell_km Cell width and height in projected kilometres.
#' @return A terra SpatRaster geometry without allocated cell values.
global_thinning_grid <- function(cell_km = 50) {
  stopifnot(length(cell_km) == 1L, is.finite(cell_km), cell_km > 0)
  crs <- global_equal_area_crs()
  boundary <- rbind(
    cbind(seq(-180, 180, by = 1), -90), cbind(seq(-180, 180, by = 1), 90),
    cbind(-180, seq(-90, 90, by = 1)), cbind(180, seq(-90, 90, by = 1)))
  pts <- sf::st_as_sf(data.frame(lon = boundary[, 1], lat = boundary[, 2]),
                       coords = c("lon", "lat"), crs = 4326)
  bbox <- sf::st_bbox(sf::st_transform(pts, crs))
  size <- cell_km * 1000
  terra::rast(xmin = floor(bbox[1] / size) * size,
    xmax = ceiling(bbox[3] / size) * size + size,
    ymin = floor(bbox[2] / size) * size,
    ymax = ceiling(bbox[4] / size) * size + size,
    resolution = size, crs = crs$wkt)
}

#' Add projected coordinates for a spatial GAM
#' @param x Data frame with decimalLongitude and decimalLatitude in WGS84.
#' @return Original data with easting_km and northing_km columns.
project_occurrences <- function(x) {
  pts <- sf::st_as_sf(x, coords = c("decimalLongitude", "decimalLatitude"),
                      crs = 4326, remove = FALSE)
  xy <- sf::st_coordinates(sf::st_transform(pts, global_equal_area_crs())) / 1000
  x$easting_km <- xy[, 1]
  x$northing_km <- xy[, 2]
  x
}
