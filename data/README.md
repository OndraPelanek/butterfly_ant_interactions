# Data

Data are managed with `resrepo`. Git records the selected version metadata; `data/raw` and `data/intermediate` are local links to the downloaded data bundle.

Download and extract the complete data bundle following the [main README](../README.md), then link it with `resrepo::version_relink()`. Supply the folder containing `starting/raw/` and `initial/intermediate/`, not either subfolder, and keep this structure unchanged.

The [data-source inventory](metadata/data_source_list.csv) documents the sources of raw data and the notebooks that generate intermediate data.

## Raw data

Each folder of `data/raw` has a `README.md` that describes its files and the notebooks that read them.

- `daru_2024/`: modelled native ranges of Daru (2025): `rasters/` for all butterfly species (regional background) and `polygons/` for the matched lycaenid species (modelled-range sensitivity)
- `expert_ranges/`: expert range polygons of Hausharter et al. (2023) and the correspondence of their names to the GBIF names used here
- `gbif_backbone/`: GBIF Backbone Taxonomy snapshot for Lycaenidae (2 October 2026) and frozen GBIF name-match responses
- `gbif_occurrences/`: the GBIF occurrence download (doi 10.15468/dl.58kd9b), zipped, with its metadata and checksum
- `illustrations/`: graphical abstract of the report
- `legacy_2024/`: the authors' earlier (2024) manual compilation, used only for the agreement check with the rebuilt dataset
- `occurrence_cleaning/`: curated rules for occurrence cleaning (introduced populations, taxonomic range exclusions, doubtful GBIF keys) and their sources
- `phylogenies/`: the trees of Yumnam & Kodandaramaiah (2025) and Schär et al. (2018)
- `native_region_layers/`: the country checklist of Pinkert et al. (2022), GADM country polygons and RESOLVE ecoregions, with a download log
- `taxonomy/`: genus revisions with their evidence, genus-subfamily tables and the riodinid genera excluded from Lycaenidae
- `trait_evidence/`: the interaction evidence database: one frozen evidence ledger per literature source, the source register, the decision registers (described in `trait_evidence/decisions/README.md`), wingspan extracts, frozen API responses and the register of source corrections

Frozen inputs count as raw data because they cannot be regenerated without the literature itself or live web services: the per-source ledgers were extracted from the literature (manually or with AI assistance directed by the first author), the decision registers record expert judgements, and the GBIF and ChecklistBank responses are dated snapshots.

## Generated data

- `s01_prepare_traits/`: the trait data (files listed below)
- `s02_prepare_ranges/`: occurrence records after each cleaning stage, range metrics, the cleaning parameters, expert validation and the outlier-rule check
- `s03_build_species_tables/`: analysis species tables and the Daru-derived range inputs
- `s04_fit_models/`: taxonomic, spatial and phylogenetic model results, including the main models used by the report
- `s05_check_robustness/`: robustness and sensitivity checks
- `s06_summarise_results/`: report and supplement tables and the report figures

### Files of `s01_prepare_traits/`

| File | Contents | Read by |
|---|---|---|
| `species_traits.csv` | Full species trait table: one row per accepted GBIF species and per 'extra' taxon, with interaction type, partner breadth, associated ants, carnivory, wingspan, duplicate-cluster and evidence-status columns | s02, s03, s05, s06 |
| `evidence_ledger.csv` | One row per claim of one source about one published name, with its accepted GBIF key, harmonised ant names, interaction class, evidence rank and record use (full, weak or excluded) | s03, s05, s06 |
| `synonym_database.csv` | Every published name string with its GBIF Backbone match and any reviewed name decision | s02 |
| `legacy_comparison.csv` | The 2024 compilation compared with the rebuilt values (one row per 2024 species) | s06 |
| `release/species_interaction_dataset.csv` | Public species-level dataset: one row per representative species, with source citations | none (deliverable) |
| `release/column_dictionary.csv` | Description of every column of the species trait table, marking those in the public dataset | none (deliverable) |

Intermediate working tables of s01 (raw ledger, species universe, 2024 names matched to the snapshot, duplicate-species clusters, tree tips matched to species and the trait table before the phylogenetic defaults and wingspan) are written only to a temporary folder.

### Files of `s02_prepare_ranges/`

| File or folder | Contents | Read by |
|---|---|---|
| `range_metrics.csv` | One row per species (duplicate keys share a range pool): range area, latitudinal and longitudinal extent, unique localities and range stability for the main, inclusive and stringent cleaning, with record counts and the native-region rule applied | s03–s06 |
| `records_final.rds` | Cleaned occurrence records with the flags of every cleaning rule | s04–s06 |
| `records_imported.rds`, `records_taxonomy.rds`, `records_meta.rds`, `records_coord.rds`, `records_base.rds` | The records after each cleaning stage (import, species assignment, metadata filters, coordinate filters, native-region filter); each stage reads the previous one | s02 |
| `ranges/` | Range tables of each cleaning variant (`range_main.csv`, `range_inclusive.csv`, `range_strict_plus.csv`) and the spatial-thinning audit; `ranges/checkpoints/` caches the calculation of each species so that an interrupted run resumes (deleting it makes the next run recompute all ranges, about 10 h) | s02 |
| `geometry/`, `native/`, `pinkert/` | Working layers of the native-region filter: country and realm rasters and parts, the Pinkert countries of each species and the native countries and realms of each species | s02 |
| `parameters.csv` | The parameters of the cleaning and range rules | s06, report |
| `dataset_counts.csv` | Number of records after each cleaning stage | s06, report |
| `outlier_groups.csv`, `outlier_expert_check.csv` | Outlying groups of localities found by the outlier rule, and their check against the expert ranges | s02, report |
| `expert_validation_species.csv`, `expert_validation_summary.csv` | Comparison of the occurrence ranges with the expert ranges of Hausharter et al. (2023), per species and summarised | s05, s06 |

### Files of `s03_build_species_tables/`

| File | Contents | Read by |
|---|---|---|
| `species_table.csv` | The main analysis table: one row per analysis unit, with interaction type (main coding), partner breadth, genus, subfamily, wingspan and strict-cleaning ranges | s04–s06, report |
| `species_table_daru.csv` | The same types with the modelled ranges of Daru (2025) | s04, s06, report |
| `species_table_assumed_subtype.csv` | Alternative coding that keeps assumed mutualist/parasite subtypes | s06 |
| `analysis_units.csv` | The analysis units (one accepted species per range pool) before the evidence and range rules of the species tables | s04, s06 |
| `daru_ranges.csv` | Range metrics of the Daru (2025) polygons of the units | s03 |
| `daru_all_species.csv`, `daru_cells_500km.csv` | Range metrics and occupied 500-km cells of all butterfly species with a Daru (2025) raster: the all-butterfly comparison set of the regional background | s04, s06 |

### Files of `s04_fit_models/`

| Files | Contents | Read by |
|---|---|---|
| `main_models.rds`, `main_coefficients.csv`, `main_contrasts.csv`, `main_estimated_means.csv`, `main_metadata.csv` | The main taxonomic mixed models (type and breadth models for range area, latitudinal and longitudinal extent): fitted models, coefficients, pairwise type contrasts, estimated means and sample sizes | s05, s06, report |
| `lmm_coefficients.csv`, `lmm_contrasts.csv`, `lmm_metadata.csv` | The same mixed models for the alternative tables and range-stability subsets | s05, s06 |
| `background_*.csv` | Mixed models with the regional range-size background as a covariate | s06 |
| `gam_*.csv` | Spatial GAMs with a spherical smooth of the range centre | s06 |
| `pgls_grafted_*.csv` | PGLS on the genus-grafted trees (main phylogenetic analyses), with tree coverage | s06, report |
| `pgls_matched_*.csv` | PGLS on tree-matched species only, and the mixed models of the same species | s05, s06 |
| `phylo_geography_contrasts.csv`, `phylo_geography_moran.csv` | Joint phylogenetic–spatial models and the spatial autocorrelation of their residuals | s05, s06, report |
| `genus_level_pgls.csv`, `leave_genus_out.csv` | Lineage checks: PGLS of genus-by-type means and refits without each genus | s06, report |
| `crosswalk_yumnam_2025.csv`, `crosswalk_schar_2018.csv`, `grafted_trees.rds` | Tree tip of each analysis unit, and the grafted trees | s04–s06, report |
| `species_centres.csv`, `presence_200km.csv`, `presence_500km.csv` | Range centre of each species and its occupied 200-km and 500-km cells | s05, s06 |

### Files of `s05_check_robustness/`

Tables of the robustness and sensitivity checks reported in the Supporting Information: the Box-Cox response (`boxcox_*`), partner-breadth scale and interactions (`breadth_*`), carnivory (`carnivory_*`), occurrence cleaning (`cleaning_*`), rarefied ranges (`rarefied_*`), tree-matched samples (`matched_sample_*`), genus and regional omissions (`genus_pair_omission.csv`, `regional_and_pair_omissions.csv`), origins of parasitism (`parasitism_origin*`), and the model-diagnostics figure (`plot_model_diagnostics.png`, Fig. S3). Read by the report; `rarefied_models.csv` also by s06.

### Files of `s06_summarise_results/`

| Files | Contents | Read by |
|---|---|---|
| `plot_*.png` | The report figures, copied to `results/` (see below) | report |
| `robustness.csv` | Type contrasts and breadth effects of all core analyses and further checks (Fig. 4, Table S12) | report |
| `counts.csv` | Numbers quoted in the text (species, records, classifications) | report |
| `si_*.csv` | Supporting-information tables (evidence basis, attrition, alternative codings, expert validation, agreement with the 2024 compilation and others) | report |
| `accumulation_example.csv`, `interaction_cells_500km.csv`, `pgls_metadata.csv`, `residual_moran.csv`, `wingspan_coefficients.csv` | Data behind further figures and supporting-information tables | report |

Report figures remain here and are copied programmatically to the corresponding `results` folders; the report reads those copies. Rerunning analyses writes into the linked intermediate bundle, so retain a separate download if an unchanged snapshot is needed.

The selected versions are `starting` for raw data and `initial` for intermediate data. See the main [`README.md`](../README.md) for data retrieval and linking.

The GBIF records are licensed CC BY-NC 4.0 and include recorder names; GADM polygons may not be redistributed, and the Schär et al. (2018) tree was supplied by its first author. Check these terms before any public data release.
