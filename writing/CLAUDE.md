# writing — notes for Claude

The manuscript on ant-interaction strategy, partner breadth and range size in lycaenid butterflies: main text and Supporting Information in `lycaenidae_manuscript.Rmd`, references in `lycaenidae_references.bib`, Word styles in `docx_template.docx`, caption layout in `caption_style.lua`. Read `README.md` first. These notes add to the root `CLAUDE.md`; the closest file wins. Target journal: Global Ecology and Biogeography (GEB).

For how to build each section and make the argument convincing, use the `scientific-writing` skill (`.claude/skills/scientific-writing/`). It draws its patterns from exemplar papers; the rules in this file win where they differ.

## Journal limits (GEB Research Article; author guidelines read 2026-10-12 and 2026-11-23, re-check before submission)
- About 5,000 words of main text (soft guide; longer only if the cover letter justifies it), about 50 references, 6–8 display items (main figures and tables). References that appear only in the Supporting Information go in a separate list.
- Structured abstract of at most 300 words (Aim, Location, Time period, Major taxa studied, Methods, Results, Main conclusions), counted with the headings. 6–10 keywords in alphabetical order.
- Double-anonymous review: a separate title page (authors, affiliations, Acknowledgements and funding), a blinded main file, a running title under 40 characters, continuous line numbers.
- A Data and Code Availability Statement is mandatory. Data and code go to a stable repository (Zenodo, Dryad or Figshare; GitHub alone is not enough) with an anonymous reviewer link.
- Supporting Information is numbered by appendix (Fig. S1.1). Figure panels use lower-case letters, cited as "Fig. 1a"; figure text is 8 pt at print size. The cover letter has under 250 words.
- Keep the main text within the limit when adding text: offset new words by cutting redundant phrases.

## Voice
- "We" in the paper. Plain descriptive words, British spelling (colour, modelling, standardise).
- The point first. One idea per sentence, one topic per paragraph, stated in the first sentence of the paragraph.
- Purpose before procedure ("To test X, we ..."), steps signposted with First, Second, Third, and "we found that ..." for results. A plain-language gloss after a technical term is welcome ("trophallaxis (mouth-to-mouth feeding by ants)").
- Plain words over jargon and noun stacks: "model" for "specification", "less informative" for "limits the inferential weight".
- At most one sentence-opening adverb per paragraph (However, Interestingly). Skip "Moreover" and "Furthermore" chains, "it is worth noting", "plays a crucial role", "shed light on", "delve", "underscore", "pivotal", "landscape", "leverage", "multifaceted", and stacked hedges ("may potentially suggest").
- Overclaiming words ("demonstrates", "crucial drivers", "significantly impact", "valuable insights", "much-needed") have no place in Ondrej's voice.
- Leave out filler and hype ("crucially", "notably", "importantly", "key insight", "robust", "comprehensive", "seamless"), em-dash chains, lists of three for rhythm, bold labels on every paragraph and closing sentences that repeat the paragraph ("Thus, although ...").
- Phrase things positively: say what something is or does. Avoid "X, not Y", "not X but Y", "not only ... but also", "X rather than Y" and antonym pairs. Name the side that is true, and add the contrast only when a reader would otherwise get it wrong.
- Do not imitate the wording of other papers; use them for structure only.
- Past tense for our methods and results ("parasites had the smallest ranges"); present tense only for published findings and for what a figure shows. Do not mix the two within a paragraph.
- Standard terms, no private labels. Name a model by what it contains ("linear mixed model with genus nested in subfamily"), not "taxonomic model", and say "sensitivity analysis", not "core analysis". Define every term of the dataset (claim, source, coding decision, each interaction type) in the main text; co-authors could not follow undefined ones (`.claude/skills/scientific-writing/references/coauthor_review_lycaenidae_2026-11.md`).

## Argument and logic
- Methods say what was done, Results what was found, Discussion what it means. The Discussion connects the findings to the questions in the Introduction and adds interpretation; the Results already tell the findings.
- The paper tests four hypotheses. Keep them and evaluate each one explicitly, with the verdict the evidence allows (for example "weak, model-dependent support" where that is the case).
- Never write a separate Limitations section or a limitations paragraph: it breaks the argument and ends the paper on what could go wrong. Mention each limitation briefly where it matters: as a design choice in Methods, and in a sentence beside the result or interpretation it qualifies, with how much it could change it and why the conclusion holds. Do not collect caveats in one place or repeat them; refer back ("as described above"). The Conclusions end on the finding, with caveats as subordinate clauses.
- Do not undersell. Where the data rule out an alternative explanation, say so before listing what stays open, and lead with the robustness evidence. Turn future-work caveats into what the results make possible (for example, the independent origins of parasitism as natural replicates).
- Say each point once, where it matters.
- Order sections as the argument runs and keep Methods and Results in the same order.
- Results headings state the finding in one short sentence where a section has one clear finding, so that the headings alone tell the story. Descriptive or methods-heavy sections can name their question instead.
- Keep fitting and validation apart. Say which data fitted the model, then test it against data it never saw, and name those data where the test is reported.
- In Methods, give the reason or the test behind each choice next to it (a threshold set by a downsampling test, a cell size chosen to match the coarsest data).
- Long lists of examples (species, genera, regions) go into a table. The text gives the main patterns and points to the table.
- Use "therefore", "thus" and "hence" only when the conclusion follows from the sentence before. Match claims to the evidence: "could have" or "suggests" where the data cannot show the cause, with parallel hedges within a sentence.
- Give every "this", "these" and "it" a clear antecedent. After any edit, re-read the paragraph for logic and flow.
- The main text keeps few, defensible, convincing analyses. A new analysis enters the main text only when it answers a distinct alternative explanation; otherwise it goes to the Supporting Information. Which analyses stay or go is Ondrej's decision: recommend with evidence.
- Co-authors (November 2026) want one simple main model and the checks in the Supporting Information: the main text gives each family of checks as one headline sentence with a pointer to the table, and the analyses named in Methods are the same list as in the robustness figure. Anything raised in the main text (a covariate, a check) is explained there (what, why, how calculated, source, units), or it moves to the Supporting Information.
- The Introduction holds what motivates the four hypotheses. Background that interprets the result or qualifies a hypothesis (reverse causation, the niche-breadth study of European butterflies) goes to the Discussion. The last paragraph runs: question, data with sample sizes, hypotheses with their reasons, one sentence on sensitivity analyses.
- Sample sizes go in Methods, in pipeline order and with the organism named (butterfly species); Results open with a finding. Each model is one sentence: purpose, response, predictors, n.

## Claims
- Write what the data support. Associations get associational wording (no "drives", "causes", "leads to").
- Keep apart statistical support for a difference (p-value, confidence interval) and a difference between point estimates.
- Give an estimate as its median or point value with the 95% interval, and the range it could take (the prior or the tested range) where there is one.
- Show the strength of the evidence. Where the data rule out an alternative explanation, say so before listing what stays open.
- Revising prose keeps every fact, number, reference and caveat unless Ondrej asks for a cut. Word-limit savings come from redundant phrases.
- Every worded claim that depends on a result has a `stopifnot()` check in the Rmd that stops rendering when the results no longer match it. When a check fails after a rerun, revise the sentence to what the results now show and tell Ondrej; never loosen the check to make it pass. New worded claims get a check of their own.
- Definitions of interaction types and the rules for classifying evidence are scientific decisions. Do not change them in the text without Ondrej's agreement.
- Each headline contrast has its ratio, 95% interval and p-value in the Results sentence that claims it; the other contrasts stay in the tables. Write "N times as large as" or "N-fold", because "N times larger" is ambiguous. Where a contrast loses support in the most conservative model, say that the other analyses support it and that the loss may reflect power.
- Open decision: AP and JW write "significantly larger" and "not significant" (15 uses in the accepted text; none in the rendered manuscript), while Methods says "supported" or "clear". Ask Ondrej which word set to use, then use it in Methods, Results and captions alike. The same holds for "interaction type" (text) against "interaction strategy" (title and Abstract).

## Consistency
- Keep terms, ordering (north–south) and formatting identical throughout: package names in italics (*tidysdm*), number style (1,735; km$^2$), "approximately" in the same position. Define an acronym at first use, or drop it if it appears only a few times.
- Numbers in the text come from inline R and the helpers in `code/R/manuscript.R` (`report_number()`, `format_table_p()` ...). Never type a number that a result file holds. Keep the formats the Rmd already uses for ratios, intervals and p-values. Sample size is italic *n*, and km² has a superscript (AP's formatting edits).
- After a change of method (an analysis dropped, a rule changed), search the whole document for stale mentions: text, tables, captions, the abstract and the caveats beside each result.
- Describe each method exactly as the code computes it (the distance, the selection rule, the thresholds), and check every count and setting in the text against the notebook or its output.

## Citations, figures and tables
- Cite as `[@Key]` from `lycaenidae_references.bib` and add the entry together with the citation. After edits, check for missing, duplicate and unused keys.
- Add a reference only after checking its claim against the abstract or full text, and put its DOI in the `.bib`. Never add a reference from memory.
- Captions say what is plotted (observed data or model output), what lines, shades and intervals show, the number of species or cells, and how to read it ("darker = more"). Use plain words ("the model's prediction for each type, with the same slope for all types"), carry no interpretation, and follow the style of the text. Tables spell out group names (not n/f/m/p) and use plain row labels ("per additional ant genus"). In equal-area maps, say how cells at the 180° seam are treated, because land wraps round the map and cells do not.
- Figures come only from `results/` through the inventory in `code/R/report_figures.R` (`report_figure()`); the graphical abstract is in `data/raw/illustrations/`. Do not point the manuscript at the analysis output folders. A changed figure is drawn by its notebook (s05 or s06) and copied by that notebook's last chunk.
- Colour follows one rule in the document. Amounts (counts, proportions, means, sizes) use one sequential palette with dark = more (magma); signed effects use a diverging palette centred on zero; categories (interaction types) keep the same colours in every figure. Leave out red–green pairs.
- Maps count and average in equal-area cells (Equal Earth, 500 km in every report map, stated in the caption).
- Word output: images are sized in inches (6.5 in text width), because Pandoc takes percentage widths from the template's last section. Wide tables sit in landscape sections made with the OpenXML section blocks in the Rmd: keep each pair of blocks (end of the portrait section, end of the landscape section) in place when moving text, and set `report_table_width` to 9 in inside them. Keep each figure on the page of its caption.
- Leave Ondrej's TODO markers and comments unchanged unless asked.
- The `lycaenidae_manuscript_*.docx` files with initials in the name are Word copies with co-author edits. Never overwrite or edit them; read them as feedback.

## Revising
- Change only what Ondrej asks, as little as possible. Keep his wording and logic, and change wording only where really needed. Put larger ideas in chat for him to decide.
- Before a larger revision, copy the Rmd and bib into `archive/manuscript_revision_<date>/` with a short README.md that logs what changed and why. Removed analyses and text go there too, never into the bin.
- Comments from co-authors and supervisors and suggestions from ChatGPT or reviewers: form your own view of the text first, check each point against it, apply those that matter and say which ones you skipped and why.
- For a final-check pass, look at logic and flow, repeated content, undefined acronyms, stale mentions, consistency of terms and numbers, the word count against the GEB limit, and broken references.
- Co-authors review the rendered Word file with tracked changes and comments. Read it with `.claude/skills/scientific-writing/scripts/read_docx_review.R` (read-only; work from a copy if Word has the file open) and compare it with the version that was sent. Apply accepted wording to the Rmd, never to the Word file: turn typed numbers into inline R, keep each `stopifnot()` check consistent with the new wording, and render again. State at the start which Word file the Rmd is synchronised with.
- The Word file returned on 2026-11-20 (`lycaenidae_manuscript_ALP_JW_RW_OP.docx`, changes accepted, 95 comments) is ahead of the Rmd, which still holds the text of 2026-10-28. Its tracked changes, comments and what they teach are in `.claude/skills/scientific-writing/references/coauthor_review_lycaenidae_2026-11.md`. Do not edit the Rmd from it without Ondrej's instruction.

## Checking
- After an edit, render the manuscript (`Rscript code/render_report.R`, or into a temporary `output_dir` so that the existing Word output stays untouched; it may be open in Word, and rendering stops on a permission error). Rendering reads existing results and does not rerun the analysis. Word needs Pandoc (`RSTUDIO_PANDOC`, see the root `CLAUDE.md`).
- In the render, check that every figure is embedded, no `??` marks an unresolved reference, every citation reaches the reference list, and no `stopifnot()` check fails.
- Search the text for placeholders (`xx`, `…`, empty brackets, "version X", "(units)"), duplicated paragraphs, subject–verb disagreement in edited sentences and stray characters before every hand-over.
- Look at the Word pages as images (Word exports the .docx to PDF, then render pages to PNG): figures inside the margins and on the page of their captions, table columns not squeezed, no near-empty pages.
- Say in the summary what was rendered and checked. Changes stay uncommitted; Ondrej commits.
