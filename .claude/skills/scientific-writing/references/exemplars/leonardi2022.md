# leonardi2022: following the niche (palaeo-SDM of four ungulates)

- **Citation:** Leonardi M, Boschin F, Boscato P, Manica A (2022) Following the niche:
  the differential impact of the last glacial maximum on four European ungulates.
  *Communications Biology* 5: 1038. <https://doi.org/10.1038/s42003-022-03993-7>.
  CC BY 4.0. Data and code: figshare 10.6084/m9.figshare.20510364.
- **Local PDF:** `data/raw/writing/exemplar_papers/leonardi2022_following_the_niche_ungulates.pdf`.
  Paragraph numbers follow the PMC text (PMC9523052).
- **Genre:** research article (Introduction, Results, Discussion, then Methods).
  Abstract 151 words; Introduction 949; Results 1,558; Discussion 1,189; Methods 1,510.
- **Why it is here:** this is the closest exemplar to the thesis's palaeo-SDM chapters.
  - It uses dated fossil and archaeological occurrences, Beyer2020 climate through
    pastclim, GAMs, the Boyce index, ensembles and binary maps by period.
  - It introduced the time-varying niche GAM that Hallett et al. (2025) and
    Padilla-Iglesias et al. (2026) reuse.

## Structure

- **Abstract (5 sentences).**
  1. Motivation, with the past as a natural experiment.
  2. "Here we test whether ...".
  3. "We show that ..." (the finding).
  4. "We also suggest that ..." (a hedged mechanism).
  5. An implication that holds "irrespective of the mechanism". This keeps the robust
     finding apart from the speculative explanation.
- **Introduction (funnel).**
  - Why niche dynamics matter, and why this period (three reasons: large climate
    swings, radiocarbon coverage, continuous climate series).
  - What SDMs do, with a conceptual figure (Fig. 1).
  - The problem with fitting each time slice separately, with its two consequences,
    each explained (P4–P5).
  - A solution borrowed from movement ecology (P6).
  - "Here, we use this approach on four species", why these species (contrasting
    habitats and sampling), and the aim (P7–P9).
- **Results.** Topic headings in a logical order: data, model choice, variable
  importance, distributions through time, niche change.
- **Discussion.**
  - One-sentence summary.
  - Range patterns.
  - A mismatch with archaeological and genetic evidence, explained by several
    candidates.
  - Mountains, with caution.
  - A sanity check.
  - A confound.
  - Scope.
  - Implication for conservation.

## Moves worth copying

1. **A schematic figure of the methodological problem and its solution** (Fig. 1). It
   shows why per-slice SDMs under-sample the niche and how a single model with time
   interactions avoids this.
2. **Teaching the reader a new kind of figure** (P18–P19, Fig. 5).
   - What the colours mean.
   - Why availability of conditions matters.
   - A warning that the variable with the largest change need not be the most
     important one.
3. **A mismatch handled as a list of candidate explanations** (P29). The candidates
   are sampling gaps, ecotones, human prey choice and coarse climate cells, each with
   its evidence.
4. **A sanity check used as evidence** (P30). An area known to be unsuitable comes out
   unsuitable.
5. **The confound named right after the main claim** (P31). Rugosity and cold are hard
   to separate.
6. **Every data filter with its reason** (P34–P37).
   - The age window: too few data before it, domestication after it.
   - A list of exclusion criteria.
   - One record per cell and time slice, because presence–background models need
     presences and repeated layers inflate sampling bias.
7. **Model settings with their reason and their check** (P44–P46): the extra penalty
   and REML against overfitting; k checked with `gam.check()`; concurvity; DHARMa
   residuals; Moran's I.
8. **A table of counts before and after filtering** (Table 1).

## To avoid

- Model choice by in-sample AIC, and the Boyce index computed on training presences,
  presented as validation. Add a held-out test.
- Choosing the ensemble with the higher Boyce index, then reporting that index. The
  selection inflates it.
- "Robust" claimed from one sanity check; "Interestingly"; "crucial".

## Use in this thesis

- Palaeo-SDM chapters (hartebeest, carnivores): a fossil-validation subsection with a
  list of candidate explanations for each mismatch.
- How-to-read paragraphs for response curves or interaction plots.
- A filtering table (records collected, kept and thinned).
