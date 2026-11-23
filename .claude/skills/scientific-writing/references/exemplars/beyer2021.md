# beyer2021: climatic windows out of Africa

- **Citation:** Beyer RM, Krapp M, Eriksson A, Manica A (2021) Climatic windows for human
  migration out of Africa in the past 300,000 years. *Nature Communications* 12: 4889.
  <https://doi.org/10.1038/s41467-021-24779-1>. CC BY 4.0.
- **Local PDF:** `data/raw/writing/exemplar_papers/beyer2021_climatic_windows_out_of_africa.pdf`.
  Paragraph numbers below (P1, P2, ...) follow the PMC text (PMC8384873).
- **Genre:** short research article with Introduction, combined Results and discussion,
  and Methods. Abstract 146 words; Introduction 567; Results and discussion 2,700;
  Methods 2,824. The Methods are as long as the Results.
- **Why it is here:** Manica-lab palaeoclimate study with one clear question and one
  metric. It shows how to turn a doubtful assumption into a sensitivity analysis. Its
  climate data are the Krapp emulator used in our SDMs.

## Structure

- **Abstract (4 sentences).** What is settled, what is debated and why it is debated;
  "Here, we use" the method and what it estimates; "We then combine" it with a second
  input, which lets them answer when and where; the answer is compatible with
  independent evidence, with the implication. No numbers.
- **Introduction (3 paragraphs).**
  - P1 reviews the evidence for early exits and marks each contested claim as
    challenged or defended, with references on both sides.
  - P2 names the limits of earlier approaches. It gives one concrete example of an
    implausible fitted value from a previous model. Then "Here, we take a different
    approach", with First, In a second step, and We then.
  - P3 states the findings in two sentences, so the Introduction ends with the answer.
- **Results and discussion.** Seven topic headings follow the logic of the argument:
  - the tolerance required, then the tolerance hunter-gatherers have;
  - the windows these imply, and their sensitivity to the threshold;
  - the sea crossing, short-term variability, and why early waves failed.
  Each heading names the question; the paragraph gives the finding.
- **Methods.**
  - Each equation has its symbols defined in the sentence around it.
  - The search algorithm (bisection) is given with its precision (within 1 mm per year).
  - The checks of the climate input against long proxy records, pollen and dated
    palaeolakes sit in Methods with their own figures (Figs. 4–6).
- **Back matter.** Author contributions, plus data and code on OSF with a DOI.

## Moves worth copying

1. **A threshold supported by three independent sources** (P5). The 90 mm per year
   limit comes from where present-day hunter-gatherers live, from the minimum rainfall
   that sustains grazers, and from the desert–shrubland boundary.
2. **Assumptions stated where they are used, with the reason they do not change the
   result** (P4). The Nile delta is treated as always crossable; lakes and small rivers
   are left out because they lie in areas wetter than the threshold anyway. One open
   assumption (the Red Sea crossing) is flagged, with a pointer to the later section
   that discusses it (P9).
3. **A limitation turned into an analysis** (P8). The authors do not defend the threshold
   any further. They show the windows for every threshold (Fig. 2b,c) and describe how
   the conclusions change above 110, 130 and 200 mm per year.
4. **A scope sentence** (P11). The results show when migration was climatically
   feasible. Whether it happened needs a dispersal model, and the paragraph says what
   that model would need.
5. **Pre-empting an objection** (P7). The paragraph explains why the result need not
   match single local proxy records: it measures the driest point of the best path, and
   that point moves over time.
6. **Expectations set before a validation** (P28). Realistic simulations should match
   the major trends of the proxies; a perfect correlation is not expected, and the
   paragraph says why.
7. **Captions with a reading guide.** They say what lines, shades and percentiles show,
   give n, and add the direction ("higher values mean a more favourable climate").
8. **Units on every number** (mm per year; strait width 4 to over 20 km).

## To avoid

- One Results paragraph of about 600 words mixes data, assumptions and the figure
  (P4). Split such paragraphs at each new idea.
- Loaded words in places ("heated debate", "crucial").
- A run of a dozen date intervals in one paragraph (P6). A table or labels on the
  figure carry these better.

## Use in this thesis

- Habitability or suitability thresholds (for example, the deme habitability threshold
  in CISGeM or an HSI cut-off): show results across the plausible range of thresholds.
- Separate "climatically suitable" from "occupied" in one scope sentence wherever
  palaeo-SDM maps are interpreted.
