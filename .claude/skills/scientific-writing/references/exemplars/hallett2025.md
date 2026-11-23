# hallett2025: human niche expansion before the out-of-Africa dispersal

- **Citation:** Hallett EY, Leonardi M, Cerasoni JN, Will M, Beyer R, Krapp M, Kandel AW,
  Manica A, Scerri EML (2025) Major expansion in the human niche preceded out of Africa
  dispersal. *Nature* 644: 115–121. <https://doi.org/10.1038/s41586-025-09154-0>.
  CC BY 4.0. Code on figshare, one link per numbered script.
- **Local PDF:** `data/raw/writing/exemplar_papers/hallett2025_human_niche_expansion.pdf`.
  Paragraph numbers follow the PMC text (PMC12328235).
- **Genre:** *Nature* article. A main text with result headings, then Discussion,
  Methods and Extended Data. Abstract 184 words; main text about 3,300 (introduction
  635, results 1,770, discussion 876); Methods 3,513.
- **Why it is here:** it applies the time-varying niche GAM of Leonardi et al. (2022)
  at *Nature* level. Its abstract builds tension, then a question, then the answer. It
  compares every result with a null model, tests robustness to the climate model, and
  justifies the corrections it leaves out.

## Structure

- **Abstract.**
  1. Two lines of evidence in tension.
  2. The only way they can be reconciled.
  3. "A key question therefore concerns ...".
  4. "Here we show that ...".
  5. What was assembled and done.
  6. "We found that ..." (with the date and the driver).
  7. "Thus, ..." (the implication).
- **Introduction.**
  - The question.
  - The proposed explanations, each with the evidence against it.
  - The gap: none was tested quantitatively at continental scale, which risks post hoc
    explanations.
  - A theory that makes a prediction (ideal free distribution).
  - "Here we specifically test whether ...", with the key term (niche) defined in the
    next sentence.
- **Results.** One heading for the test ("Testing for the presence of niche change"),
  then finding headings ("Geographic range expanded 70 ka").
- **Discussion.**
  - The answer with its dates.
  - Robustness.
  - Meaning for archaeology.
  - What the results do not imply.
  - Climate context.
  - A closing paragraph.
- **Methods.** Numbered scripts; the headings carry the script numbers, and the code
  availability statement links each script.

## Moves worth copying

1. **Tension–question–answer abstract.** Two facts that cannot both be true unless
   something else holds; that turns into the question; the paper answers it.
2. **A gap defined by untested hypotheses and a missing prediction** (P2), with a
   theory that supplies the prediction.
3. **The key term defined where the aim is stated** (P3).
4. **A null model beside every key result** (P7, P9). The fixed-niche model shows what
   climate change alone would have produced. The difference from the changing-niche
   model is what the paper attributes to niche change.
5. **Robustness to an independent input** (P4, P44). A second palaeoclimate simulation
   gets one sentence in the main text, with the full results in Extended Data.
6. **A time trend in sampling handled explicitly** (P6, P21). The reasons for the trend
   are given (preservation, the reach of dating methods), and sampling effort is
   evened out by subsampling.
7. **Corrections left out on purpose, with reasons and their largest possible effect**
   (P16, Extended Data Fig. 5). Marine curves, hemisphere boundary and eggshell offset
   would move a site at most to the adjacent 2-kyr window, below the model's resolution.
8. **Model formulas printed as code, then explained term by term in words**, with a
   page reference for the theory (P23–P35).
9. **Failed checks reported specifically** (P37).
   - The failing repeats are listed by number.
   - The judgement gives a reason (large n gives high power to detect trivial
     deviations).
   - A refit without outliers confirms it.
10. **Counts at every selection step** (P39, Extended Data Fig. 7): 91 of 100 repeats
    support the changing niche; 64 of them pass the Boyce threshold.
11. **Explicit "does not imply" sentences** (P11–P12): niche expansion does not
    necessarily mean a larger population, and a continental pattern does not mean one
    unified process.

## To avoid

- Overclaims: "formally demonstrate", "unquestionably", "unparalleled", "Essentially".
- Building the ensemble only from repeats that support the changing niche, then
  interpreting it, without showing what the excluded repeats predict.
- AIC and Boyce both in-sample (as in leonardi2022).

## Use in this thesis

- Chapter abstracts and introductions: tension, question, answer.
- Any SDM result that could reflect either changing climate availability or a changing
  niche: show the fixed-niche counterfactual beside it.
- Corrections we leave out (calibration curves, transversion scaling): show their
  largest effect against the resolution of the analysis.
