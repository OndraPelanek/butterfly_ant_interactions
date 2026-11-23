# padilla-iglesias2026: Pan-African metapopulation model (CISGeM)

- **Citation:** Padilla-Iglesias C, Xue Z, Leonardi M, et al., Migliano AB, Manica A
  (2026) Pan-African model explains *Homo sapiens* genetic and morphological evolution.
  *bioRxiv* 2025.05.22.655514, version 2 (30 April 2026).
  <https://doi.org/10.1101/2025.05.22.655514>. CC BY-ND 4.0.
- **Local PDF:** `data/raw/cisgem/papers/padilla-iglesias2026.pdf` (line numbers below are
  the preprint's own). Code: the group repository `African_HunterGatherers`, local
  clone. The supplement is not public.
- **Genre:** preprint in *Nature* style: Summary; main text with finding headings;
  Materials and Methods.
- **Why it is here:** the CISGeM study closest to the thesis. It chains an SDM, CISGeM
  simulations and genomes, then validates against independent data. It was checked
  against its code on 22 November 2026, which showed where the text and the code
  disagree.

## Structure

- **Summary.** Debate, limitation, "Here we provide", what was integrated, then three
  results (genetic fit, morphological prediction, archaeological congruence).
- **Main text.**
  - A short introduction: what is known, what is less known, the evidence for
    structure, the open questions (lines 51–75).
  - A "Here we provide" paragraph that walks through the whole pipeline (lines 86–103).
  - Sections with finding headings: genetic fit; morphological validation; key regions;
    connectivity and events in time order.
  - Conclusions.
- **Methods.** One heading per pipeline step: genetic data; masking; pairwise π;
  archaeological sites; niche model; CISGeM demography and genetics; the CNN;
  parameter estimation; model comparison; replays; validation tests.

## Moves worth copying

1. **The title and the section headings state findings.**
2. **Fit, then validate on data the model never saw**, naming each dataset as
   independent: census densities, camp locations, crania, and the placement of the
   Yoruba (lines 147–177, 230–239).
3. **The obvious alternative tested beside the result** (lines 169–174). Isolation by
   distance is checked with partial Mantel tests that use geographic and cost
   distances.
4. **One explicit caution where interpretation begins** (lines 247–257). Congruence
   does not imply causation, and the archaeological record is uneven. Exceptions are
   framed as directions for future work.
5. **The reason or test behind each methods choice** (lines 430–443, 495–503): the
   coverage threshold from downsampling tests; 50-kb spacing so that loci are unlinked;
   2,000 windows from a stability test.
6. **A long list of events kept in a table** (Table S7); the text discusses the main
   patterns.
7. **Robustness of the niche model to a second climate model** (lines 632–635). The
   niche model is compared with one built on another climate simulation, with the
   similarity given as a number (Sørensen index 0.85).

## To avoid (found by checking against the code)

- Methods text that does not match the code.
  - The text says "sum of Euclidean distances"; the code computes one Euclidean distance
    on statistics scaled by their median absolute deviation (`abc::abc`, rejection).
  - Line 140 says the best 1,000 runs "of all the scenarios"; line 831 and the code take
    the best 1,000 from each scenario.
- A posterior reported vaguely ("tended to cluster") without its prior range. The
  Pan-African start time, 208–270 ka (95% interval), sits inside a 200–300 ka prior.
- Inconsistent or missing details:
  - Florisbad longitude given as 20.07 in one place and 26.06 in another;
  - no unit for the altitude measure;
  - one caption says "in blue" for both of two contrasting categories.
- In-sample evaluation presented as validation (Boyce on training presences), and
  "good power" defined as R² > 0.15.
- Key settings only in a supplement that is not public.
- Hype: "complete reconstruction", "first comprehensive", "Crucially", "exciting avenue".

## Use in this thesis

- The blueprint for the CISGeM chapter: pipeline paragraph, fit, independent
  validation, then interpretation in time order.
- Report each posterior with its prior range, and the selection rule exactly as coded.
