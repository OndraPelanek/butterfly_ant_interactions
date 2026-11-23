---
name: scientific-writing
description: Structure and argument patterns for scientific writing in this repository, distilled from exemplar papers (so far Manica-lab papers on palaeoclimate, palaeo-SDMs, CISGeM and population genomics), from journal author guidelines (Nature, Nature Communications, PNAS, Global Ecology and Biogeography, Journal of Biogeography, Molecular Ecology), from reporting standards (ODMAP for SDMs, ODD for simulation models) and from writing guides (Gopen & Swan, Mensh & Kording, Schimel's Writing Science), and checked against the house rules in writing/CLAUDE.md. Use it whenever you draft, restructure, revise or review scientific prose - the manuscript in writing/ (target Global Ecology and Biogeography), its supplement and cover letter, other papers and reports, abstracts, titles, introductions, methods, results, discussions, figure captions, data and code statements, or the longer prose sections of notebooks that argue a result - and when Ondrej asks how a paper is written or how to make a text more convincing, even if he only says "the manuscript", "the report", "this paragraph" or "the abstract". It covers what each section does, devices that make an argument convincing (independent validation, null models, robustness, sensitivity, power checks), hedging, captions, faults to check for, and how to add more exemplar papers.
---

# Scientific writing for the manuscript and other papers

This skill says how to build each part of a scientific text and which devices make
an argument convincing. It does not set the voice. **`writing/CLAUDE.md` holds the
house rules** (voice, argument, claims, consistency, citations, figures, revising,
checking) and wins wherever the two differ. The root `CLAUDE.md` adds the rules for
notebook prose.

*Copied on 2026-11-23 from the african_diversity repository, where it was written for
the African palaeo-SDM thesis. The patterns, journal notes and guides apply to any paper.
The "Use in this thesis" sections and "Local PDF" paths of the exemplar notes belong to
that thesis (the PDFs are in its `data/raw/writing/exemplar_papers/`). Here the document
is the Lycaenidae manuscript (macroecology, target GEB), which has no SDM or CISGeM model,
so ODMAP and ODD do not apply. No macroecology exemplar is in the set yet: add one,
preferably a GEB paper (`references/adding_exemplars.md`).*

Every pattern below names the exemplars that show it, so its support is visible.
Read the exemplar note in `references/exemplars/` for paragraph-level detail.

| Tag | Exemplar | Note |
|---|---|---|
| B21 | Beyer et al. 2021, *Nat Commun*, climatic windows out of Africa | `beyer2021.md` |
| K21 | Krapp et al. 2021, *Sci Data*, 800-kyr climate reconstruction | `krapp2021.md` |
| L22 | Leonardi et al. 2022, *Commun Biol*, niche change in four ungulates | `leonardi2022.md` |
| H25 | Hallett et al. 2025, *Nature*, human niche expansion | `hallett2025.md` |
| HV25 | Hovhannisyan et al. 2025, *AJHG*, Armenian population genomics | `hovhannisyan2025.md` |
| PI26 | Padilla-Iglesias et al. 2026, bioRxiv, Pan-African CISGeM model | `padilla-iglesias2026.md` |
| WR | House rule in `writing/CLAUDE.md` | — |

Guides and standards (read on 22–23 November 2026; details in the reference files):

| Tag | Source | Reference file |
|---|---|---|
| NAT | Nature formatting guide, annotated summary paragraph, "How to write your paper" | `journal_guidelines.md` |
| NC | Nature Communications article guidelines | `journal_guidelines.md` |
| PNAS | PNAS submission guidelines | `journal_guidelines.md` |
| GEB, JBI, MEC | Global Ecology and Biogeography, Journal of Biogeography, Molecular Ecology author guidelines | `journal_guidelines.md` |
| ODMAP | Zurell et al. 2020, reporting protocol for SDMs | `reporting_standards.md` |
| ODD | Grimm et al. 2020, protocol for describing simulation models | `reporting_standards.md` |
| GS90 | Gopen & Swan 1990, the science of scientific writing | `writing_principles.md` |
| MK17 | Mensh & Kording 2017, ten simple rules for structuring papers | `writing_principles.md` |
| R14 | Rougier et al. 2014, ten simple rules for better figures | `writing_principles.md` |
| MU22 | Muff et al. 2022 and replies, the language of statistical evidence | `writing_principles.md` |
| WS12 | Schimel 2012, *Writing Science* (book): story structure, limits, sentences, revising | `writing_principles.md` |
| CR26 | Co-author review of our own Lycaenidae manuscript (Nov 2026): 96 comments and about 560 tracked insertions and deletions by three co-authors | `coauthor_review_lycaenidae_2026-11.md` |

The exemplars are few and come from one group. Treat single-exemplar patterns as
suggestions and add papers (`references/adding_exemplars.md`). CR26 differs in kind: it is
feedback from readers in Ondrej's own field on his draft, so it shows what such readers
miss, not what a published paper does. Where CR26 and an exemplar differ, say so to Ondrej.

## How to work

1. Read `writing/CLAUDE.md` and the document's folder (its Rmd, `.bib`, template and
   frozen figures). For notebook prose, read the root `CLAUDE.md` "Writing text" section.
2. Name the document type and its reader. Then pick the matching exemplar:

   | Document | Look at |
   |---|---|
   | The manuscript of this repository (species-level macroecology paper) | B21 and H25 for the argument devices, L22 for a species-data frame, HV25 for predictions before tests |
   | Research paper in another field of the group | L22 (palaeo-SDM), PI26 (CISGeM), HV25 (genomics), B21 (short) |
   | High-impact short paper | H25, B21 |
   | Data, methods or appendix describing generated data (here: the released species dataset and its column dictionary) | K21 |
   | Report or supplement section | L22 for one study; the house rules for the report frame |
   | Proposal, lay summary or outreach text | WS12 (lead with the question; the message box) |

3. **Know the target and the reporting standard.**
   - For a paper, read the target journal's entry in `references/journal_guidelines.md`
     (limits, abstract format, title rules, data statements). Re-check the journal's
     page before submission. For this manuscript the entry is Global Ecology and
     Biogeography (GEB).
   - For a thesis chapter (not in this repository), check the Cambridge word limit.
   - For SDM or CISGeM methods (not in this repository), use ODMAP or ODD from
     `references/reporting_standards.md` as the checklist and the appendix structure.
4. Write the spine before drafting a section or chapter, in 5–8 sentences:
   - the question and why it matters;
   - the approach;
   - the main findings with their numbers;
   - what they mean for the question and for the larger problem [WS12];
   - the main limit, and why the conclusion holds.

   Show it to Ondrej for larger texts. Every paragraph must serve the spine. Then
   outline with one informal sentence per planned paragraph [MK17]. Choose the order
   by the reader's patience: context first and the answer at the end (OCAR) for
   specialist papers and thesis chapters, the main finding first (LDR) for short
   high-impact papers, abstracts and proposals [WS12, NAT].
5. Draft with the section patterns below. Use the devices that the evidence allows.
6. Check every method statement and number against the code or its saved output
   (PI26 shows what goes wrong otherwise).
7. Revise in passes: structure, clarity, flow, then language. Read the text aloud
   [WS12]. Run the final checklist, then render as `writing/CLAUDE.md` describes.
8. When co-authors return a Word file with tracked changes and comments, read it with
   `scripts/read_docx_review.R` (read-only), compare it with the version that was sent,
   and follow "Applying co-author edits to an Rmd manuscript" in
   `references/coauthor_review_lycaenidae_2026-11.md` [CR26]. Apply wording to the Rmd,
   never to the Word file.

## Section patterns

### Title

- **Research papers:** state the main finding, or the question with its object
  [H25, PI26, L22, NAT].
- **One contribution:** a title carries one central contribution; let it steer what the
  text keeps [MK17].
- **Data papers:** name the product with its span and resolution [K21].
- **Journal rules:**
  - main keywords in the title, at the front [GEB, JBI, MEC];
  - name the organism [PNAS];
  - no abbreviations, acronyms, numbers or puns [NAT, PNAS, GEB, JBI];
  - character limits in `journal_guidelines.md`.

### Abstract (about 150–230 words in the exemplars)

- **Moves, one sentence each:**
  1. context, or a tension in the evidence;
  2. the gap or question;
  3. "Here we ..." (what was done);
  4. the approach;
  5. the findings, with the key number or date;
  6. the implication.

  [B21, K21, L22, H25, HV25, PI26, MK17]
- **The common mistake:** results before the reader knows the question they answer
  [MK17].
- **Nature summary paragraph:** seven parts, each written for a named reader (any
  scientist, then related fields). Avoid numbers and acronyms in it
  (`journal_guidelines.md`) [NAT].
- **Significance statement:** for PNAS, ≤ 120 words for an educated scientist outside
  the field [PNAS].
- **Structured abstracts:** for biogeography journals, write factual statements under
  fixed headings. The Aim is the question or hypothesis, and Main conclusions the
  take-home message [GEB, JBI].
- **Tension opening for short high-impact papers:** two facts that cannot both hold,
  what would reconcile them, and the question that follows [H25].
- **Finding apart from mechanism:** "We show ..." for the finding, "We also suggest ..."
  for the mechanism, and an implication that holds whichever mechanism is right [L22].
- **Data papers:**
  1. the gap;
  2. what the dataset is, its span and resolution;
  3. how it was made;
  4. its validation in one sentence;
  5. its contents;
  6. its uses.

  [K21]

### Introduction

- **The funnel (3–6 paragraphs):**
  - Why the topic matters: the larger problem and the main characters. Cut textbook
    background that every reader knows [WS12].
  - What is known. Cite contested claims with both sides [B21, H25].
  - A specific gap: which hypotheses are untested, or why earlier methods fall short,
    with one concrete example [B21, L22, H25]. Say exactly what is unknown, never
    "little is known about X" [WS12].
  - The theory and the prediction it makes, where one exists [H25].
  - "Here we test whether ...", with the key term defined in the next sentence
    [H25, L22, WR]. State a question or prediction, not only objectives, with the main
    aim first [WS12].
  - The approach in steps (First, Second, We then) [B21, WR].
- **Narrowing gaps:** the gap narrows paragraph by paragraph, from field gap to
  subfield gap to the untested hypothesis. Each paragraph moves from context to the
  knowns to the unknown it ends on. No broad literature review: cite the known only
  to mark where knowledge ends, with citations at the end of the sentence. Sell the
  problem before the method [MK17, WS12].
- **For outsiders:** explain the research question early without assuming
  specialist background [NAT].
- **Why this system:** say in two or three reasons why the species, period or region
  suits the question [L22, HV25].
- **Ending:** the Introduction may end with the answer in brief [B21, H25, MK17].
- **Keep what motivates the hypotheses.** Background that interprets the result or
  qualifies a hypothesis (for example that an association can run in either direction)
  belongs in the Discussion [CR26].
- **Say why the system suits the question where it cannot be missed**, for example that
  closely related species differ in the trait; repeat it in the Abstract and Discussion
  [CR26, L22, HV25].
- **Last paragraph:** the question, what was done with the sample sizes, the hypotheses
  each with its reason, then one sentence on the sensitivity analyses. Do not restate
  the previous sentence ("We tested them ...") [CR26].
- **Plain words, and a measure for each cited result:** say how a cited finding was
  measured or leave the detail out; spell out both ends of a spectrum and what lies
  between [CR26].
- **No novelty or priority claims** ("first", "novel") [PNAS]. For GEB and J
  Biogeogr, state the general or conceptual advance instead [GEB, JBI]. An old
  question in a new species, region or method only adds information: say what the
  earlier work left open and answer that [WS12].

### Methods

- **Order:** follow the pipeline, in the same order as the Results [WR, K21, PI26].
  Open a long pipeline with an overview figure or paragraph [K21, PI26].
- **Choices:** open each step with its purpose ("To estimate X, we ..."), and give
  each choice with its reason or the test that set it [WR, B21, L22, H25, PI26, WS12].
- **Limits of a method:** state them where the method is described, with why it was
  needed and how the limit was reduced. Do not raise them again [WR, WS12].
- **Filters:** give each data filter with its reason, and the counts before and after
  (a table when there are several) [L22, HV25, H25]. Name what stops the filter from
  removing real data (for example a rule that keeps a minimum number of localities);
  readers ask [CR26].
- **Vocabulary and sample sizes:** define every term of the dataset in the main text
  (claim, source, coding decision, each type) and give the four types once with the
  criterion that separates them, in a short key or table; use no extra label. Give the
  sample sizes in pipeline order in Methods, name the organism in each count, and start
  Results with a finding [CR26].
- **Each model in one sentence:** purpose first, then response, predictors, n and random
  effects. Say why a subset is analysed. Name a model by what it contains, not by a
  private label. Name each response measure once and refer to it by that name [CR26].
- **Everything raised in the main text is explained there** (what, why, how calculated,
  source, units, citation at first mention); otherwise move it to the supplement
  [CR26].
- **No philosophy of inference in Methods.** State the test, the threshold and the
  adjustment in one sentence, and why effects are reported as ratios [CR26].
- **AI use must be replicable:** tasks, tools and versions, what a person checked, how
  disagreements were settled and where the records are [CR26].
- **Model settings and checks:**
  - Give the settings with the check that confirmed them (smooth complexity,
    residuals, autocorrelation, convergence) [L22, H25].
  - Report failed checks specifically (which repeats, by how much), with the judgement
    and a sensitivity test [H25].
- **Things left out** (a correction, a factor, a layer): say why, and show that the
  largest possible effect is below the resolution of the analysis [H25, B21].
- **Equations:** define every symbol with its unit next to the equation [WR, B21, K21].
  Print model formulas as code, then explain each term in words [H25].
- **Reproducibility:**
  - Software versions and parameters [HV25, L22].
  - Data and code statements with DOIs [B21, K21, L22, H25, HV25].
  - Methods headings that name the scripts, matching the code statement [H25].
- **Fidelity to the code:** describe each method exactly as the code computes it
  [WR; PI26 shows the cost].
- **Detail and length.**
  - Give enough detail for a competent practitioner to repeat the work, or give the
    code [JBI, NAT].
  - Cite methods that are already published and state only what changed [NAT, WS12].
  - Keep the main text able to stand without the supplement [PNAS].
- **Model descriptions.**
  - **SDMs:** an ODMAP Overview as prose in Methods, and the full ODMAP checklist in an
    appendix. State the assumptions, especially niche stability for palaeo-projections
    [ODMAP].
  - **CISGeM:** a summary ODD in Methods and the full ODD in an appendix. Keep
    description apart from justification (a Rationale subsection per element), and name
    the patterns used to evaluate the model [ODD].
- **Data and code statements.**
  - Use a stable archive with a DOI: Zenodo, Dryad, Figshare. GitHub alone is not
    enough [GEB, MEC, PNAS, NAT].
  - Include data accession numbers. Add a benefit-sharing statement for genetic
    samples where the journal asks [MEC].

### Results

- **Headings:**
  - A finding sentence where a section has one clear finding [H25, PI26, WR].
  - A topic or question for descriptive or methods-heavy sections [B21, L22, K21, HV25].
- **Paragraphs:** open with the finding, then the evidence, with the figure reference
  and numbers [WR, B21, H25, WS12]. An alternative is question, then data, then answer
  in the last sentence. It is easy to fact-check, but use it only where the question is
  not obvious [MK17].
- **Data, inference, interpretation:** keep apart what was measured, what any
  practitioner would conclude from it, and your own reading. Give the data before the
  conclusion. Show the data the story needs and collapse the rest into one panel or
  the supplement [WS12, WR].
- **First Results paragraph:** summarise the approach, because most readers skip
  Methods [MK17, PI26].
- **Comparison:** compare each key result with a null or counterfactual [H25]. When
  testing competing hypotheses, say what each predicts before the result [HV25].
- **Estimates:** give the median and interval, and the range the estimate could take
  (prior or tested range) [WR; PI26 omits it].
- **Counts:** report them at each selection step (usable runs, repeats passing a
  check) [H25, HV25]. For a dataset built from literature and records, the selection
  cascade belongs in Methods and Results give n beside each result [CR26].
- **Numbers beside the claim:** each headline contrast has its estimate, interval and
  p-value in the sentence that claims it; the other contrasts stay in the table
  [CR26].
- **Tense and ratios:** past tense for what we found; present only for published
  findings and for what a figure shows. Write "N times as large as" or "N-fold"; "N times
  larger" is ambiguous [CR26].
- **Where a contrast loses support** in the most conservative model, say that the other
  analyses support it and that the loss may reflect power, not a smaller effect [CR26].
- **Robustness in the main text** is one headline sentence per family of checks ("supported
  in every analysis; the exception was X") with a pointer to the supplement table. The
  analyses in Methods and in the robustness figure must be the same list [CR26].
- **Absence of a signal:** show first that the data could have detected it [HV25].
- **New kinds of figure:** explain how to read them, including the usual misreading
  [L22].

### Discussion

- **Opening:** answer the Introduction's question first, with the numbers or dates
  [H25, L22, HV25, WR].
- **Independent evidence:** set the result against it. Where they disagree, list the
  candidate explanations with the evidence for each [L22, B21].
- **Scope:** say what the results do not show, next to the claim it limits; no separate
  Limitations section [B21, H25, PI26, WR]. Give the limit first and end on the
  finding ("Despite the few sites, X ..."). Keep limits out of the Discussion's first
  and last paragraphs [WS12].
- **Middle paragraphs:** each takes one strength or weakness and weighs it against the
  literature, then says how far it changes the conclusion [MK17, WR].
- **Confounds and checks:** name confounds right after the claim they affect; use
  sanity checks as supporting evidence [L22]. For an association between a species'
  recorded interactions and its range, name the abundance route (widespread species are
  more abundant, so more interactions are recorded) and cite evidence from other
  systems [CR26].
- **Ending:** restate the key result, answer the question, and say what it adds to the
  larger problem of the opening, as wide as the opening and ideally in its words.
  Close on the finding or a concrete new question [WR, B21, HV25, WS12].
- **Weak endings:** "new insights" left unnamed, a new idea raised only at the end,
  and "more research is needed" [WS12].

### Figures, tables and captions

- **Captions:**
  - say what is plotted (observed data or model output);
  - say what lines, shades and intervals show, and give n;
  - add a reading direction ("higher values mean ...").

  [B21, K21, WR, R14]
- **Legend rules:**
  - open with a one-sentence title for the whole figure, then describe each panel and
    symbol;
  - define every error bar and statistic (SD or SEM), and give n;
  - keep methods out of the legend when there is a Methods section [NAT, PNAS].
  - For biogeography journals, the legend must stand alone and name the region and the
    taxon [GEB].
- **Plain captions and labels:** captions follow the style of the text and carry no
  interpretation. Describe lines and bands in plain words ("the model's prediction for each
  type, with the same slope for all types"), spell out group names in tables, use plain row
  labels ("per additional ant genus") and add small icons for the groups in multi-panel
  figures [CR26].
- **Maps in equal-area cells:** say how cells at the 180° seam are treated, because land
  wraps round the map and cells do not [CR26].
- **Main-text displays serve the question.** A descriptive map belongs in the supplement
  unless the question is spatial; a figure that shows the data (counts per group,
  distributions of the response and predictor) fits the main text better [CR26].
- **Figure titles:** a title that states the figure's conclusion helps readers who go
  from the abstract straight to the figures [MK17].
- **Each figure earns its place:** one message, no chartjunk, scales that do not
  mislead. Choose colour by data type: sequential, diverging or categorical
  [NAT, R14, WR].
- **Schematics:** a conceptual figure for a new method, showing the problem and the
  solution [L22]; a flowchart for a data pipeline [K21]. A simple schematic of the main
  finding is welcome at Nature [NAT].
- **Long lists** (sites, dates, events) belong in a table, which the text summarises
  [WR, PI26, B21].

### Describing generated data (chapter section, appendix, data paper) [K21]

- **Background:** position the data against the alternatives, and say when to prefer
  them.
- **Methods:** a flowchart, then one heading per step, with each transformation and
  its reason.
- **Data records:** a table of variables with units, and the file names.
- **Validation:** independent checks against held-out data, observations and the
  source model, with a physical reason for any difference in performance.
- **User notice:** where the data can be trusted and what to check before use.

## Sentences and paragraphs

- **One job per unit:** each paragraph makes one point. Cover each subject in one
  place; do not come back to it later (zig-zag) [GS90, MK17, WR].
- **Paragraph shape:** the first sentence gives the topic or the finding, the body the
  evidence, and the last sentence what to remember [MK17, WR]. Openings, transitions
  and conclusions can build to their point in the last sentence. A paragraph that
  drifts from one subject to the next holds several arcs: split it [WS12].
- **Topic position (sentence start):** put the old information that links back, and
  the thing whose story the sentence tells, at the start. Read only the sentence
  openings of a paragraph: they should tell one story. Where no sentence links back,
  a logical step is missing; write it out [GS90, WS12].
- **Stress position (sentence end):** put the new point to be emphasised at the end.
  A sentence is too long when it holds more points worth emphasis than places to
  stress them. Split it, or use a semicolon [GS90]. Qualifications go in the middle;
  a long sentence reads easily when its main clause comes first [WS12].
- **Flow:** link the end of one sentence, or paragraph, to the start of the next. A
  run of sentences with the same topic reads as a list [WS12].
- **Subject next to verb:** keep long qualifiers out from between them [GS90, WS12].
- **Parallel form for parallel points**, and the same word for the same thing
  throughout [MK17, WR].
- **For the outside reader:** use the active voice ("we fitted"), define each term
  where it is first needed, and keep abbreviations few [NAT, PNAS, MK17, WR]. A term at
  the start of a sentence reads as known, one at the end as being defined [WS12].
- **Action in verbs:** "rates differed" beats "there was a difference". Replace fuzzy
  verbs (examined, affected) with verbs that say what happened. Use the passive only
  to keep the right topic or when the actor does not matter [WS12].
- **Condensing your own drafts:** cut material the story does not need first, then
  words: empty amplifiers (give the number), "We found that", "There is evidence
  that". Keep the words that build flow [WS12]. Ondrej's text keeps every fact and
  caveat unless he asks for a cut [WR].

## Devices that make an argument convincing

| Device | What it does | Exemplars |
|---|---|---|
| Independent validation | Fit on one dataset, test on data never used, and name them | PI26, K21, B21 |
| Null or counterfactual model | Shows what would happen without the proposed process | H25 |
| Robustness to another input | Repeats the analysis with an alternative (second climate model, other grouping) | H25, PI26 |
| Sensitivity across an assumption | Shows results over the plausible range of an uncertain value | B21 |
| Triangulation | Methods with different assumptions agree | HV25, B21 |
| Predictions before tests | States what each hypothesis expects, then the result | HV25, H25 |
| Power before absence | Shows a real signal would have been detected | HV25 |
| Alternative explanation tested | Rules out the obvious rival (isolation by distance) | PI26 |
| Sanity check | A known case comes out right | L22 |
| Omission with its bound | A correction left out cannot change the result | H25 |
| Assumption with its reason | States where an assumption is used and why it does not matter | B21 |
| Objection pre-empted | Explains why a naive comparison would mislead | B21 |

## Claims and hedging

- **Strength of verbs.** Use the strength the evidence allows, and keep parallel claims
  at the same strength [WR]:
  - "show", "find" for direct, tested evidence;
  - "indicate", "support";
  - "suggest", "is consistent with";
  - "could", "may", "we speculate".
- **Finding apart from mechanism.** Write a finding and its proposed mechanism in
  separate sentences at different strengths [L22, H25].
- **Statistical wording.**
  - Report the effect size with its interval, and describe the strength of evidence in
    graded words. Lead with the effect, "increased 3.4-fold (P < 0.05)", and let the
    test qualify it [WS12].
  - Do not use "significant" as a verdict, and never read P > 0.05 as "no effect".
    Co-authors in ecology write "significantly larger" [CR26]; whichever word set
    Ondrej chooses, use it in Methods, Results and captions alike.
  - Whether P-values are "evidence" or "compatibility" is debated; either wording beats
    a binary verdict [MU22, WR].
- **Words to avoid.** These were used as overclaims in the exemplars: "formally
  demonstrate", "unquestionably", "unparalleled", "complete reconstruction",
  "first comprehensive", "deciphered", "crucial". Use "robust" only when a robustness
  test is reported. The house list of filler words is in `writing/CLAUDE.md`.

## Faults found in the exemplars (check for them)

- Methods text that differs from the code, for example the distance or the selection
  rule [PI26].
- The same quantity with two values in different places (coordinates, counts) [PI26].
- Captions with a copy-paste error, or no unit for a measure [PI26].
- Correlations whose expected sign is not explained [K21].
- An estimate shown without the prior or range that bounded it [PI26].
- In-sample fit (AIC, Boyce on training presences) presented as validation [L22, H25, PI26].
- Choosing runs or ensembles by a metric, then reporting that metric as performance
  [L22, H25].
- Paragraphs over ~250 words; several sentence-opening adverbs in a row [B21, HV25].
- Key settings only in a supplement that is not public [PI26].

## Final checklist

1. The spine (question, approach, findings, meaning, limit) is recognisable in the
   abstract, the last paragraph of the Introduction and the first paragraph of the
   Discussion. The last paragraph returns to the opening's larger problem and is as
   wide as the opening [WS12].
2. Each Results section opens with its finding. Each key result has a comparison
   (null, alternative, independent data or robustness).
3. Every methods choice has its reason or test. Every filter has its counts. Methods
   match the code.
4. Every estimate has its uncertainty and the range it could take. Every number has
   a unit.
5. Claims match the evidence. Each limit sits beside the claim it limits.
6. Captions say what is plotted, n, intervals and how to read the figure.
7. Data and code statements name the repositories and commits or DOIs.
8. The opening of each sentence links back to what came before, and its end carries
   the new point. No paragraph has two jobs [GS90, WS12].
9. For a paper, the title, abstract, word count, display items and required statements
   fit the target journal (`references/journal_guidelines.md`). For a model chapter, the
   ODMAP or ODD appendix is complete.
10. A colleague outside the field can tell from the title and abstract what was found
    and why it matters [NAT].
11. The house checks in `writing/CLAUDE.md` pass: voice, consistency, references, render.
12. No placeholder (`xx`, `…`, empty brackets, "version X"), duplicated paragraph or pending
    tracked change remains. Every dataset term in the main text is defined there, and
    Methods and the robustness figure list the same analyses [CR26].

## Growing the skill

The guides and journal pages (`journal_guidelines.md`, `reporting_standards.md`,
`writing_principles.md`) date from 22–23 November 2026. Re-read a journal's page before
submitting, and record changes there; sources still to read are listed at the end of the
two other files. Add exemplars with `references/adding_exemplars.md` (choosing papers,
`scripts/fetch_open_access_text.R` for open-access text, the note template, how a pattern
enters this file). `data/raw` here is the versioned data store, so ask Ondrej where to keep
exemplar PDFs. The notes paraphrase; they do not copy text. Add each new round of
co-author feedback to `references/coauthor_review_*.md` and tag it CR<year>.

## Change log

- 2026-11-22: created from `writing/CLAUDE.md` and six exemplars (B21, K21, L22, H25,
  HV25, PI26); PI26 checked against its code repository.
- 2026-11-23: added six journals' author guidelines, ODMAP and ODD, and the guides GS90,
  MK17, R14, MU22 and WS12 (read in full). New: target-journal step, sentence and
  paragraph section, statistical wording, story order (OCAR, LDR), checklist items.
  Ecography, the Cambridge word limit and Feng et al. 2019 could not be read.
- 2026-11-23 (butterfly_ant_interactions): copied from african_diversity; title,
  description, document table and journal steps adapted to the Lycaenidae manuscript.
- 2026-11-23 (butterfly_ant_interactions): added CR26, the co-author review of the
  Lycaenidae manuscript, with `scripts/read_docx_review.R`, rules in the section patterns
  and checklist item 12.
