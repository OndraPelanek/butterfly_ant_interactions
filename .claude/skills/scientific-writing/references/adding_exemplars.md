# Adding an exemplar paper

The skill should rest on many papers, so that no single paper sets the rules. Each
exemplar gets a note in `exemplars/`. A pattern enters `SKILL.md` only when the
exemplars support it.

## Choosing papers

- Prefer recent papers (last ~5 years) close to the thesis: palaeo-SDMs, palaeoclimate,
  spatial demographic–genetic models (CISGeM), population genomics of African mammals,
  data or methods papers that the thesis builds on.
- Mix genres: research articles in short and long formats, data descriptors,
  methods/software papers, reviews. Each teaches different moves.
- Take strong writing from outside the group too, not only Manica-lab papers. The
  group's own conventions show up anyway, through the papers the thesis cites.
- Avoid adding a second paper that adds nothing new: the note's "Moves worth copying"
  must contain at least two moves the existing exemplars lack.

## Getting the text

1. Find the DOI and, for open-access papers, the PMCID (Europe PMC search or the
   article page).
2. Save the PDF for Ondrej in `data/raw/writing/exemplar_papers/<firstauthor><year>_<short_title>.pdf`.
   Check that the file starts with `%PDF`; delete HTML stubs. Publishers with bot
   checks (Cell, Elsevier, Wiley, MDPI, Taylor & Francis) need a manual download: give
   Ondrej the DOI link and the file name. Add a line to that folder's `README.md`.
3. Get readable text with `scripts/fetch_open_access_text.R` (PMC open-access papers),
   written to a scratch folder outside the repository:
   `Rscript .claude/skills/scientific-writing/scripts/fetch_open_access_text.R <scratch> <key>=<PMCID>`.
   For preprints or papers without PMC text, use `pdftotext -layout` on the PDF.

## Reading

Read the whole paper, including Methods, captions and data/code statements. While
reading, note for each section:

- its job in the argument and its length (words, paragraphs);
- how each paragraph opens and closes;
- how claims are hedged and what evidence carries them;
- every device that makes the argument convincing: validation, null model, robustness,
  sensitivity, power, alternative explanations, scope statements;
- faults: overclaims, mismatches between text, figures and code, missing units or
  priors, long paragraphs.

If code or data are public, check one or two methods statements against them. The
padilla-iglesias2026 check found two mismatches this way.

## Writing the note (`exemplars/<key>.md`)

Paraphrase. Quote at most a few words, and point to paragraphs (P numbers from the
PMC text) or line numbers instead of copying sentences. Use this template:

```markdown
# <key>: <short description>

- **Citation:** authors (year) title. *Journal* volume: pages. <DOI link>. Licence.
- **Local PDF:** path, or why there is none and the file name to use.
- **Genre:** format, section order, word counts per section.
- **Why it is here:** one or two sentences linking it to the thesis.

## Structure
Section by section: the job each section does, in the order it does it.

## Moves worth copying
Numbered; each with what it does, why it works, and where (P numbers).

## To avoid
Faults found, each with where and a better alternative.

## Use in this thesis
Which chapter or document could use which move.
```

## Adding guides, journal pages and standards

- **Where they go.** Journal author pages go to `journal_guidelines.md`. Reporting
  standards go to `reporting_standards.md`. Books and articles on writing go to
  `writing_principles.md`.
- **What to record.** The URL, the date read, and what was actually read (the whole
  text, or only an abstract or replies). Say clearly what could not be read.
- **How to read them.**
  - Publisher pages blocked for scripts (Nature, PNAS, Wiley) open in the in-app
    browser.
  - Open-access PDFs can be read with `pdftotext`.
  - Do not get past sign-ins or bot checks; list those sources for Ondrej.
- **Tags.** Give each source a short tag in the `SKILL.md` source table, and add it to
  every pattern it supports.

## Updating SKILL.md

1. Add the paper to the exemplar index table.
2. For each move in the note, look for the matching pattern in `SKILL.md`:
   - if the pattern exists, add the paper's key to its tag list;
   - if it is new and a second exemplar (or a house rule in `writing/CLAUDE.md`)
     supports it, add it with both keys;
   - if only this paper supports it, leave it in the note until another paper does.
3. If a paper contradicts a pattern (for example, topic headings against finding
   headings), record both choices and when each fits. Do not delete the older advice.
4. Keep `SKILL.md` under ~500 lines. Move detail into the notes when it grows.
5. Log the addition (date, paper, what changed) in the skill's change log at the end
   of `SKILL.md`.
