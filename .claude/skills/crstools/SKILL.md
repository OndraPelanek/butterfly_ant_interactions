---
name: crstools
description: Choose a map projection (CRS) for an area with the crstools R package (the group's own package, EvolEcolGroup, Projection Wizard reimplemented in R) - suggest_crs() for equal-area, conformal, equidistant or compromise projections from an extent, sf object or SpatRaster; geom_tissot() to show distortion on ggplot2 maps; and ground-control-point georeferencing of scanned maps (choose_gcp, find_gcp_coords, georeference_img). Use it whenever code needs a projection for a study area, equal-area grid cells, thinning, background sampling, spatial blocks, buffers, distances or areas, or a map of a region or of the world - for example "which CRS for Europe / Africa / the world", "equal-area cells for this map", "project this raster", "show distortion" - so that the projection comes from suggest_crs() rather than being invented or copied without reason.
---

# crstools: choosing projections

crstools is our group's package (Manica, Pozzi, Padilla-Iglesias, Leonardi, Pelanek et al.;
preprint Pozzi et al. 2026, doi:10.31223/X5K17P). Its key function is **`suggest_crs()`**: a
reimplementation of Projection Wizard 2.1 (Šavrič et al. 2016) that picks a projection
from the extent of the area and the property to preserve. **When a projection is needed,
derive it with `suggest_crs()` and record the resulting string; do not invent one.**

## Version and where to look

- renv library of this repository: crstools **1.0.0.9002**, installed from GitHub (commit
  `7cf87ce`, the same commit as `renv.lock`). It exports `suggest_crs`, `geom_tissot`,
  `choose_gcp`, `find_gcp_coords`, `georeference_img`, `extract_coords` and `plot_gcp`.
- `references/functions.md`: usage and arguments of the installed version, generated from
  this repository's own library on 2026-11-23. Regenerate after an update (repository
  root):
  `Rscript .claude/skills/crstools/scripts/make_function_reference.R crstools .claude/skills/crstools/references/functions.md`
  (add the path of the source clone `C:\Users\ondra\Documents\Cambridge\git\crstools` as
  a third argument when the package is not installed).
- Vignettes in the clone: `vignettes/crstools.Rmd` (CRS formats, `suggest_crs()` for sf and
  terra objects, Tissot indicatrix) and `vignettes/georeference_image.Rmd` (GCP workflow).
  Decision rules: `R/suggest_crs.R`, `R/crs_world.R`, `R/crs_hemisphere.R`,
  `R/crs_small_area.R`, `R/crs_ew_extent.R`, `R/crs_ns_extent.R`, `R/crs_square_format.R`.

## How `suggest_crs()` decides

```r
crs <- crstools::suggest_crs(x, distortion = "equal_area")   # x: lon/lat extent, sf or SpatRaster
crs$proj4    # e.g. "+proj=laea +lon_0=17.5 +lat_0=0 +datum=WGS84 +units=m +no_defs"
crs$wkt; crs$description; crs$notes
```

- `x` can be:
  - an sf object or SpatRaster **in longitude/latitude**;
  - a `terra::ext()`;
  - a numeric `c(lon_min, lon_max, lat_min, lat_max)`. This is **not** sf's `st_bbox()`
    order (xmin, ymin, xmax, ymax).
- The scale `720 / Δlon / (sin lat_max − sin lat_min)` sets the map type:
  - < 1.5: world;
  - < 6: hemisphere;
  - otherwise continent or smaller area. The shape of the extent then chooses square,
    east–west or north–south formats.
- `distortion`:
  - `"equal_area"` (default; SDMs, thinning, background, spatial blocks, areas);
  - `"conformal"`, `"equidistant"`;
  - `"compromise"` (world maps only).
- The central meridian is the midpoint of the longitude range (`round_cm = TRUE` rounds it).
- `return_best = FALSE` returns all candidates as a named list. `datum` and `unit` default
  to WGS84 and metres.

**Checked on 2026-11-23 with the installed version (1.0.0.9002):**

| Input | equal_area | other properties |
|---|---|---|
| World `c(-180, 180, -90, 90)` | `+proj=eqearth +lon_0=0` (Equal Earth) | `compromise`: `+proj=natearth +lon_0=0`; `conformal` is refused; `equidistant` needs `world_equidist` |
| Africa `c(-20, 55, -36, 38)` | `+proj=laea +lon_0=17.5 +lat_0=0` (equatorial Lambert azimuthal) | |
| Europe `c(-11, 40, 34, 72)` | `+proj=laea +lon_0=14.5 +lat_0=53` | |
| Australia `c(112, 154, -44, -10)` | `+proj=laea +lon_0=133 +lat_0=-27` | |

## Project conventions (butterfly_ant_interactions)

- One global equal-area projection serves the whole paper: `global_equal_area_crs()` in
  `code/R/projections.R` calls `suggest_crs(c(-180, 180, -90, 90), distortion = "equal_area",
  return_best = TRUE, quiet = TRUE)`, which gives Equal Earth. Use it for every cell count,
  cell average, thinning grid and map. Longitude–latitude cells shrink towards the poles, so
  never count or average species in them; give the cell size (km) in the caption.
- Ranges use a different, species-specific cylindrical equal-area projection whose seam
  lies in the largest empty longitude gap (`species_cea_crs()` in `code/R/range_metrics.R`),
  so that ranges crossing the antimeridian stay continuous. Do not replace it by the global
  projection.
- Grid sizes (all Equal Earth, `global_thinning_grid()` or `equal_area_species_cells()`): 25 and
  50 km for the cleaning checks and thinning in s02, 200 and 500 km for presence cells and
  the regional range-size background in s04, and 500 km for the report maps (s06), so that
  all report figures share one grid. Record any change of cell size in the notebook's
  Variables chunk.
- For a new region, call `suggest_crs()` on its lon/lat polygon and write the string and its
  source into the notebook's Variables chunk.
- Check distortion when a projection is new or the area is unusual:
  `ggplot(sf_obj) + geom_sf() + geom_tissot() + coord_sf(crs = crs$proj4)` (for rasters
  `geom_tissot(data = rast)`); circles that stay equal in area confirm an equal-area
  choice.

## Georeferencing scanned maps (interactive; Ondrej's task)

The butterfly analysis does not georeference maps; this section is for a later need.
- Workflow:
  1. `choose_gcp(image)` (click points on the image);
  2. `find_gcp_coords(gcp, sf_reference_map)` (click the same points on a reference map);
  3. `georeference_img(image, gcp_coords)` → GeoTIFF `<name>_warp.tif` via GDAL;
  4. `plot_gcp()` and `extract_coords(georef_image)` to digitise symbols.
- These open separate windows and **do not run inside R Markdown**. Claude never
  georeferences or digitises maps (AI is not good at it): prepare disabled chunks
  (`eval = FALSE`) and evaluated reload chunks, and list the map for Ondrej.

## Pitfalls

1. **Projected input fails**: an sf object already in metres gives `Latitude values must be
   between -90 and 90`. Pass lon/lat data (transform to EPSG:4326 first).
2. **Extent order**: `c(lon_min, lon_max, lat_min, lat_max)`. A bbox vector in sf order
   gives a wrong extent silently if the numbers still fall in range.
3. **Not every property exists at every scale**: `conformal` is refused for world and
   hemisphere maps, and `compromise` for hemisphere and smaller maps. Use `equal_area`.
4. **Extents crossing the antimeridian** (lon_min > lon_max) are refused.
5. **`quiet = TRUE` does not silence everything** (the stereographic scale-factor note still
   prints).
6. **proj4 vs WKT**: store and pass `$proj4` (as the builds do). The WKT names are
   Projection Wizard customs (`ProjWiz_Custom_...`), not EPSG codes.
7. **Equal area is not equal distance**: use `distortion = "equidistant"` (or great-circle
   distances) when distances matter, e.g. for thinning radii in km. tidysdm's
   `thin_by_dist()` uses great-circle distance by default.
8. **Cells at the 180° seam**: the cells are squares in the projected plane
   (`equal_area_cell_polygons()` in `s06_summarise_results.Rmd`), so cells on the two sides
   of the seam are separate cells, while land polygons appear on both sides of the map. A
   co-author asked whether this was an error (Fig. 1 of the manuscript, 2026-11-13). Say in
   the caption or Methods how the seam is treated.
