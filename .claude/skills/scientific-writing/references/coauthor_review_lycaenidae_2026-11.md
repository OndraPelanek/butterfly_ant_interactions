# Co-author review of the Lycaenidae manuscript (November 2026)

Tag **CR26** in `SKILL.md`. This note records what three co-authors changed and asked in Word, and what it teaches for writing the next paper. Initials: **AP** Alex Pigot (supervisor), **JW** Joe Williamson, **RW** Robert Wilson (shown as "rjwilson" in Word and "RJ" in the script output). Unlike the exemplars, this is feedback on Ondrej's own text, so it shows what readers from his own field and group find unclear.

## What was read and how

The files below are in `C:\Users\ondra\Documents\UCL\3rd year\Pigot lab\git\butterfly_ant_interactions\writing\`.

- `lycaenidae_manuscript.docx` (rendered from the Rmd on 2026-10-28) was compared with `lycaenidae_manuscript_ALP_JW_RW.docx` (tracked changes and comments, 2026-11-12 to 18) and with `lycaenidae_manuscript_ALP_JW_RW_OP.docx` (Ondrej's copy with the changes accepted, 2026-11-20).
- Reproduce with `scripts/read_docx_review.R` (read-only). Checks made on 2026-11-23:
  - the text of the tracked file with all changes rejected equals the rendered manuscript, apart from trailing spaces and paragraph-style names, so the tracked changes are the complete difference;
  - figures, tables, footnotes and the Discussion, Conclusions and Supporting Information text did not change;
  - the accepted text of the tracked file equals Ondrej's `_OP` file apart from two tracked deletions by JW that were not accepted ("proportions" to "proportion"; "the a model" to "the model"), one stray character ("extent.0") and white space.
- Changes: AP 296 insertions and 155 deletions, JW 42 and 36, RW 17 and 14, all in the Abstract, Introduction, Methods and Results (29 paragraphs). Comments: 96 (87 threads and 9 replies; AP 44, RW 28, JW 24). By my count about 40 threads ask for a definition, an explanation or a reason, about 10 ask to move material to the Supporting Information (SI) and about 6 to the Discussion.
- Main-text body (Introduction to Conclusions) grew from 4,932 to 5,654 words (GEB guide: about 5,000). One Results paragraph (about 180 words) now appears twice, because AP moved it up and left the old copy to be deleted (comment on the Robustness section).

## What the co-authors changed

| Section | Change | Who |
|---|---|---|
| Introduction | Opening sentence reworded; the Eltonian aside and "reflects" list cut; axes of interaction strategy defined as dependence and benefit or exploitation (RW); lycaenid paragraph rebuilt with examples and a closing sentence on why the family suits the question; last paragraph reordered to question, data with numbers, hypotheses, sensitivity analyses | JW, RW, AP |
| Methods 3.1–3.2 | Rewritten as a plain sequence with counts at each step (12,138 claims, 187 sources, 6,921 species units, 1,356 classified, 916 with ranges, per type, 456 with breadth); measures and cleaning steps explained; placeholders left for missing detail | AP, JW |
| Methods 3.3–3.4 | Purpose put first ("To understand how ..."), response, predictors and n named; seven sensitivity analyses listed in one sentence; a few labels removed | AP, JW |
| Results | Data-coverage paragraph deleted (moved to Methods); 4.2 reordered to lead with the finding and then the numbers; first robustness paragraph shortened to its headline and the old mutualist paragraph deleted; AP asked to move the rest of 4.4 to the SI | AP, JW |
| Formatting | Sample size *n* in italics, km² with superscript | AP |

## Patterns for next time

### Whole paper
- **Main message and system.** AP marked "this diversity of interaction types among closely related species" as "really the key ... strongly highlighted". Put the reason a system suits the question in a prominent sentence of the Introduction and say it again in the Abstract and Discussion. RW asked whether the phylogeny figure of interaction types (Fig. S7) belongs in the main text, which would show this point.
- **One simple main analysis.** Both JW ("streamline and run fewer models") and AP ("this detail will overwhelm the reader and detracts from the main message that there is a consistent effect regardless of the details of the analysis") want one main model in the main text and the checks in the SI. Give the robustness result as one headline sentence per family ("supported in every analysis; the only exception was X") and a pointer to the SI table.
- **Everything raised in the main text is explained there.** A covariate or analysis named in Methods needs its what, why, how it was calculated and its source (AP on "average modelled range size of co-occurring butterflies"); otherwise move it to the SI. The Methods list and the rows of the sensitivity figure must match (AP on Fig. 4), and a figure that shows only two of four contrasts needs the reason.
- **Main-text displays serve the question.** AP suggested moving the maps (Fig. 1) and the geographic paragraph to the SI, and JW agreed: describing the spatial pattern needs its own question and "becomes a different paper". AP proposed a data figure instead (species per type, histograms of breadth and range size, one richness map).
- **Same term everywhere.** AP queried "strategies" in the Abstract where the text says "types". Use the label of the Methods in the title, Abstract, text, captions and tables.
- **Do not use private labels.** "Taxonomic model" (JW: "might just be confusing"), "core analyses", "claim", "coding decision", "source location", "subtype", "species unit" and "obligate associates" were not clear to readers. Name a model by what it contains ("linear mixed model with genus nested in subfamily"), and use the standard term (sensitivity analysis).
- **Word budget.** The review added about 720 words while asking for moves to the SI. Count the main text after each round (Introduction to Conclusions) and say where the SI takes the excess.

### Introduction
- Keep it to what motivates the hypotheses. Background that interprets (the niche-breadth study of European butterflies) or qualifies (breadth and range size can run in either direction) moves to the Discussion (AP proposed it for the niche-breadth paragraph, and RW and JW agreed; JW proposed it for the reverse-causation sentence).
- Last paragraph: the question, what was done with the sample sizes, the hypotheses (each with its reason, and an example where it helps; RW suggested adding that adoption by the wrong ant species kills *Phengaris* larvae), then one sentence on sensitivity analyses. A sentence that repeats the one before ("We tested them ...") is tautological (AP).
- When a cited result is quantitative, say how it was measured ("ecological specialisation ... quantified how?", AP) or leave the detail out.
- Spell out the ends of a spectrum and what lies between (RW: a benefit-to-exploit axis puts commensalism in the middle).
- Plain words: "integrated into comparative explanations" (JW: studied less, or shown not to matter?) and "individual range boundary" (RW: "species range boundaries").

### Methods
- **Define the vocabulary of the dataset in the main text.** A "claim", a "coding decision", a "source location" and the four types need one plain definition each (AP, RW and JW asked about them about eight times). Give the four types once, with the criterion that separates them, in a short key or schematic (RW), and add no fifth label. JW and RW read "obligate mutualists obtain most of their larval food independently of ants" as the opposite of the intended meaning or as vague ("most, or all?"), so state the criterion without hedge words.
- **Give the sample sizes in Methods, in the order of the pipeline**, naming the organism in each count ("butterfly species", RW), and say what the counts are used for (456 species with breadth). Results then start with a finding.
- **Each model in one sentence:** purpose first, response, predictors, n, random effects. Say why a subset is analysed, because readers ask ("why not include the zeros?", "why two models?", JW). If JW misread breadth as the response ("use a mixed Poisson GLM"), the sentence did not say that range size is the response.
- **Name every range measure once and signpost it** (JW): area, latitudinal extent, longitudinal extent. Say how each was calculated (AP: which formula, great-circle distance?) and why the minimum convex polygon was chosen over alternatives such as occupied cells.
- **Cleaning steps: rule, reason and safeguard.** For each step give the rule and what stops it removing real data. RW worried that the outlier rule removes real disjunct populations of rare species; the safeguard (never fewer than five localities, groups of at most 10% of localities) sits in the SI and a clause of it belongs in the main text. Name CoordinateCleaner tests briefly (AP: "needs more explanation").
- **Avoid statements about the philosophy of inference** ("inference rests instead on the consistency and precision of estimates ..."; AP and JW could not follow). State the test, the threshold and the adjustment in one sentence. Explain in one plain sentence why ratios are reported ("the response was log10 transformed, so differences between types are ratios of range sizes").
- **Cite at first mention, give units, avoid vague phrases:** the two trees (AP: "provide citations"), wingspan in mm, "the largest sample its method allowed" (AP: vague).
- **AI use must be replicable** (JW: "this needs a lot of unpacking ... What did you get ChatGPT and Claude to do?"). Say which tasks (discovery, extraction, cross-checking, classification), which tools, versions and dates, what a person checked, how disagreements were settled (RW) and where the records are kept.
- Say what happens to missing evidence (species without interaction evidence were left unclassified, not called non-associated).

### Results
- **State the numbers beside the claim.** JW left "(p values test stats etc)" and "(more in text stats here)". Each headline contrast has its ratio, interval and p-value in the sentence that claims it; the other contrasts stay in the table. This replaces the earlier rule of few numbers in running text.
- **Past tense for what was found** ("parasites had the smallest ranges"). The accepted text mixes "have" and "had" in the same paragraph. Use the present only for published findings and for what a figure shows.
- **Write "N times as large as" or "N-fold".** "11.2 times larger than" is ambiguous (it can mean 12.2 times).
- **When a contrast loses support in the most conservative model,** say that it is supported in the other analyses and that the loss may reflect power rather than a smaller effect (JW).
- Peripheral contrasts (facultative against non-associated) go to the SI (AP). Keep one paragraph per family of checks; cut the numbers that only one reader of the SI needs (AP: Moran's I, tree-by-tree ratios).
- Explain how a regression is "adjusted for space" in plain words or leave it to the SI ("I don't follow what this means", AP).

### Figures, tables and captions
- Captions follow the style of the text; no interpretation or method detail in them (AP, JW: "delete or discussion").
- Describe lines and bands in plain words ("lines show the model's prediction for each type; the slope is the same for all types"), not "fixed-effect predictions ... common slope and type-specific intercepts" (JW: "I don't follow").
- Spell out group names in tables (n/f/m/p as full names, AP) and use plain row labels ("per additional ant genus", JW).
- Small icons for the types in the corners of panels help readers (JW).
- Check the map at the 180° seam: land wraps around, equal-area cells do not (JW asked whether this is an error). Say in the caption how cells at the seam are treated.

### Discussion
- Say whether breadth means mutualistic partners only, and cite related evidence from other systems (AP: seed-dispersal birds that interact with more plants have larger ranges).
- Name the abundance route: widespread species may be more abundant, so interactions are more often recorded (AP).
- Move the reverse-causation sentence from the Introduction here (JW).

## Where the review departs from the house rules (Ondrej decides)

1. **"Significant".** AP and JW write "significantly larger" and "not significant". `writing/CLAUDE.md` and the Methods say "supported" or "clear". The rendered manuscript had no "significant" in the main text; the accepted text has 15. Methods and Results now mix both word sets. Pick one for the whole document.
2. **Numbers in running text.** The older rule (few numbers) conflicts with JW's request for the statistics beside each claim (see Results above).
3. **Terms.** "Interaction type" (AP) or "interaction strategy" (title and Abstract).
4. **Content of the main text.** AP and JW would move Fig. 1, Section 4.4 and most robustness detail to the SI. This changes which analyses the paper shows, so it is a decision about the paper, not about wording.

## Checks that the accepted version shows are needed

- Search for placeholders before every hand-over: `xx`, `…`, empty brackets `()` and `(e.g. )`, `version X`, `(units)`, "(p values test stats etc)". The accepted text of 2026-11-20 holds about twenty marks (five `xx`, a few `…`, two `(e.g. )`, one empty `()`, `version X`, `(units)` and the two notes by JW).
- Search for duplicated paragraphs after a move, for subject–verb agreement in edited sentences ("The larger range sizes ... was"), for leftover words from deleted text ("we repeated our analysis also estimated"), and for stray characters and tracked changes still pending.
- A comment can be deleted while its request is still open (the request "give the interaction types again" lost its comment and the placeholder `()` remains).
- After a move, check that Methods, Results and the figure still describe the same analyses.

## Applying co-author edits to an Rmd manuscript

1. Run `scripts/read_docx_review.R` on the returned file and on the version that was sent; compare the accepted texts word by word.
2. Apply the accepted wording to the Rmd, not to the Word file. Replace typed numbers by the inline R calls the Rmd already uses, add new ones for new counts, and keep each `stopifnot()` claim check consistent with the new wording.
3. Treat each comment as a suggestion: form a view first, apply those that matter and say which were skipped and why (`writing/CLAUDE.md`, Revising).
4. Render, then compare the new Word file with the accepted one.
