# krapp2021: 800-kyr climate reconstruction (data paper)

- **Citation:** Krapp M, Beyer RM, Edmundson SL, Valdes PJ, Manica A (2021) A
  statistics-based reconstruction of high-resolution global terrestrial climate for
  the last 800,000 years. *Scientific Data* 8: 228.
  <https://doi.org/10.1038/s41597-021-01009-3>. CC BY 4.0.
- **Local PDF:** `data/raw/writing/exemplar_papers/krapp2021_climate_800kyr_reconstruction.pdf`.
  Paragraph numbers follow the PMC text (PMC8397735).
- **Genre:** data descriptor, with Background & Summary, Methods, Data Records,
  Technical Validation and Usage Notes. Abstract 169 words; Background 647; Methods
  1,926; Data Records 254; Technical Validation 1,952.
- **Why it is here:** this is the Krapp2021 series behind all our SDMs (pastclim). It is
  the model for any chapter section or appendix that describes a dataset we built, such
  as CISGeM environment files, rescaled suitability series or edge-weight files.

## Structure

- **Abstract (8 sentences, one idea each).**
  1. The gap (computational cost).
  2. "Here, we present" the dataset: what, how often, how far back.
  3. How it was made: regressions on 72 simulations against the forcings.
  4. Downscaling and bias correction.
  5. Validation in one sentence.
  6. What it contains.
  7. Derived products.
  8. Who can use it.
- **Background.** It lists the existing datasets with the period each covers, says what
  the new one adds, and says when the older dataset should be preferred (P2–P3).
- **Methods.**
  - A flowchart comes first (Fig. 1), then one heading per step.
  - The train/test split is designed to cover the space of predictors, with a figure of
    that space (Fig. 2).
  - The text adds that the split served only for validation and the final fit used all
    data (P10–P12).
- **Technical Validation.** Four independent checks:
  - against the original model on held-out simulations (R², RMSE);
  - preservation of spatial covariance;
  - correlations with marine and terrestrial proxies (tables);
  - bias against present-day observations.
- **"Informed user notice"** (P40–P41). Where the data can be trusted, and what users
  should check (with the diagnostics files) before relying on precipitation or cloud
  cover in their region.

## Moves worth copying

1. **Positioning by complementarity** (P3). The paper says which dataset to use for
   which period instead of claiming superiority.
2. **A design choice explained by its purpose** (P10). The test set lies inside the
   predictor space, so the validation measures interpolation, which is how the model
   is used.
3. **Transformations justified by the constraint they enforce** (P16): log for
   precipitation (never negative), logit for cloud cover (between 0 and 1).
4. **Differences in performance explained by mechanism** (P27–P28). Temperature
   follows local forcing; precipitation depends on circulation, so the regression fits
   it less well. Readers learn where to trust the data.
5. **Limits written as guidance for users** (P40–P41). The limits are what to check
   before use, and where to look.
6. **Tables of variables with units, and of file names.** A reader can find any output
   without the code.

## To avoid

- Typos and grammar slips that survived review ("a some", "competing of interest").
- A validation table with negative correlations for δ18O records and no word on the
  expected sign. Say which sign a good match should have.
- Sentence openers such as "Unfortunately".

## Use in this thesis

- Sections describing generated inputs (giraffe08 environment steps, edge-weight
  files): flowchart first, one heading per step, a table of outputs with units.
- A short "how to use and where not to trust" paragraph for SDM projections, for
  example extrapolated climates (MESS) and coarse cells.
