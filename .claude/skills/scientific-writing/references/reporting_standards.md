# Reporting standards for the thesis models

Two published protocols cover the models in the thesis: ODMAP for species
distribution models (SDMs) and ODD for simulation models (CISGeM). Both work as a
checklist while writing and as a structure for the appendix. Both put a short
overview in the main-text Methods and the full protocol in an appendix or supplement.

## ODMAP: species distribution models

Zurell D, Franklin J, König C, et al. (2020) A standard protocol for reporting species
distribution models. *Ecography* 43: 1261–1277. <https://doi.org/10.1111/ecog.04960>.
CC BY. Read from the open PDF (NSF PAR copy) on 22 November 2026.

- **Five sections** follow the modelling steps: **O**verview, **D**ata, **M**odel,
  **A**ssessment, **P**rediction. Elements are obligatory, needed only for some
  objectives (mapping/interpolation, or forecast/transfer), or optional.
- **Where it goes.**
  - The Overview is prose in the main-text Methods.
  - The full checklist goes in the supplement or appendix, with authors and title so
    it stands alone.
- **Overview (eleven obligatory subsections).**
  - The objective (inference, mapping or transfer) and the main output.
  - The focal taxon and the location.
  - Scales: spatial extent and resolution, temporal extent and resolution, and the type
    of extent boundary.
  - The biodiversity data: observation type and response type.
  - Predictor types.
  - The hypotheses about species–environment relations.
  - The critical assumptions.
  - The algorithms, with the reason for their complexity and whether an ensemble is
    used.
  - The workflow.
  - Software, and the availability of code and data.
- **Data.**
  - Biodiversity data: taxon names, sources, sampling design, sample size, cleaning,
    absences, pseudo-absences or background, and errors and biases.
  - Partitioning into training, validation and truly independent test data.
  - Predictors: sources, resolution and extent, projection, processing, errors and
    dimension reduction.
  - Transfer data: the climate models and scenarios, and how novel environments were
    quantified.
- **Model.**
  - Variable pre-selection and multicollinearity.
  - Settings, including extrapolation beyond the sampled range.
  - Estimates: coefficients and variable importance.
  - Model selection, averaging or ensembles.
  - Non-independence: spatial and temporal autocorrelation of residuals, nested data.
  - Threshold selection.
- **Assessment.** Performance on training, validation and truly independent data
  (separately). Plausibility checks such as response plots and expert judgement.
- **Prediction.**
  - The prediction unit and any post-processing.
  - Uncertainty from algorithms, input data, parameters and scenarios.
  - How novel environments are shown or treated.
- **Assumptions to state** (the paper's Table 2):
  - species–environment equilibrium;
  - no observation bias, or bias accounted for;
  - independent observations;
  - all important predictors included;
  - predictors without error;
  - **niche stability** across space and time;
  - no other extrapolation problems, such as changed correlations between predictors.

**In the thesis.** The palaeo-SDM chapters project niches through time, so niche
stability is the central assumption. Say where it is assumed and where it is tested.
Time-varying niche models relax it (leonardi2022, hallett2025). Map the tidysdm
pipeline onto ODMAP:

| ODMAP element | tidysdm pipeline step |
|---|---|
| Biodiversity data, cleaning, bias | records table, thinning, background |
| Data partitioning | spatial blocks |
| Model selection and ensembles | repeated ensembles |
| Performance statistics | Boyce, TSS |
| Novel environments | MESS, clamping |

Say which performance values come from held-out blocks and which from training data.

## ODD: simulation models (for CISGeM)

Grimm V, Railsback SF, Vincenot CE, et al. (2020) The ODD protocol for describing
agent-based and other simulation models: a second update to improve clarity,
replication, and structural realism. *Journal of Artificial Societies and Social
Simulation* 23(2): 7. <https://doi.org/10.18564/jasss.4259>. Read from the article
page and its Supplement S1 (guidance and checklists) on 22 November 2026.

**Seven elements, in this order, keeping the numbers:**

1. **Purpose and patterns.**
   - State a specific purpose, precise enough to judge whether the model is fit for it.
   - Describe the patterns used to evaluate the model, why they were chosen, and which
     ones the model fails to reproduce.
   - Define terms, and keep this element independent of the Introduction (do not
     describe the model yet).
2. **Entities, state variables and scales.**
   - The kinds of entity, what they represent, and why these were included (and others
     not).
   - Each state variable with its meaning, units, type, range, and whether it is
     dynamic or static (usually a table).
   - Time step and extent, spatial unit, resolution and extent, and the reasons for
     these scales.
3. **Process overview and scheduling.**
   - A complete, concise schedule of what happens in each time step: which entity runs
     which process, what is updated, and in which order.
   - The reason for the processes included and for their order.
4. **Design concepts.** Basic principles, emergence, adaptation, objectives, learning,
   prediction, sensing, interaction, stochasticity, collectives, observation. Omit
   those that do not apply.
5. **Initialization.**
   - What is created at the start, how many, and with which values and locations.
   - Any site-specific data used, how initialization differs between scenarios, and
     the reasons.
6. **Input data.** Time-varying inputs (what they represent, units, source,
   preparation). Name any other model that produced them, and how it was used.
7. **Submodels.** One subsection each: equations, algorithms, parameters and how their
   values were chosen, and the tests run on each submodel alone.

**How to write it.**

- Keep the description apart from the justification. Use an optional *Rationale*
  subsection in each element.
- Write the full ODD first, as the appendix. Then write a summary ODD for the main
  text:
  - prose without the element titles;
  - ODD keywords in italics;
  - state-variable lists as tables;
  - only the essential design concepts and submodels.
- Link ODD elements to the code (names, comments or a table). Give software versions.
- Credit any reused ODD text and its authors.

**Suggested mapping for CISGeM** (check every item against the `cisgem-engine` skill
before writing):

| Element | CISGeM content |
|---|---|
| 1. Purpose and patterns | which landscape history reproduces the observed pairwise π matrix. Patterns: between-group π, within- against between-lineage contrast, spread across loci |
| 2. Entities | demes (cells of the 40k hexagonal grid) with population size and capacity; edges with friction; sampled lineages in the genetic stage. Scales: generation length (10 years for giraffe), time steps, grid resolution and extent |
| 3. Process schedule | per generation: capacity from suitability, logistic growth, undirected and directed movement with friction; then the backward coalescent through the stored demography |
| 4. Design concepts | stochasticity (sampled parameters, random states), emergence (genetic structure from range dynamics), observation (summary statistics) |
| 5. Initialization | start time, seed deme and radius, initial sizes; the ancestral population K0 |
| 6. Input data | the environment NetCDF (suitability series, masks, edge weights) and its source SDM |
| 7. Submodels | capacity (factor × suitability^exponent), growth, movement and friction, K0 fit, genetics |

## Other required statements

- **Data and code availability.** All target journals want data and code in a stable
  archive with a DOI (see `journal_guidelines.md`). Write the statement from the
  repository's actual files: genomic data accession numbers, the SDM inputs, and the
  CISGeM configs and summaries.
- **Benefit-sharing (Nagoya Protocol).** Molecular Ecology asks for it; samples from
  African range states may need one.
- **Reporting summary.** Required by Nature journals for life-science articles.

## Not read yet

- Feng X et al. (2019) A checklist for maximizing reproducibility of ecological niche
  models. *Nature Ecology & Evolution* 3: 1382–1395.
  <https://doi.org/10.1038/s41559-019-0972-5>. Paywalled; read through Cambridge access
  and merge with the ODMAP section.
- No reporting standard for approximate Bayesian computation or simulation-based
  inference was read. Until one is, report:
  - priors with their ranges;
  - attempted and usable runs;
  - parameter recovery on held-out simulations (R², coverage);
  - whether the observed statistics lie inside the simulated range.
