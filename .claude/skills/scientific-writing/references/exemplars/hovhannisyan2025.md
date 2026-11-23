# hovhannisyan2025: demographic history of Armenians (population genomics)

- **Citation:** Hovhannisyan A, Delser PM, Hakobyan A, Jones ER, Schraiber JG, Antonosyan M,
  Margaryan A, Xue Z, Jeon S, Bhak J, Hrechdakian P, Sahakyan H, Saag L, Khachatryan Z,
  Yepiskoposyan L, Manica A (2025) Demographic history and genetic variation of the
  Armenian population. *American Journal of Human Genetics* 112(1): 11–
  (online 25 November 2024). <https://doi.org/10.1016/j.ajhg.2024.10.022>.
  CC BY-NC-ND 4.0.
- **Local PDF:** none yet. Cell's bot check blocks scripted downloads; save it from the
  DOI page as `data/raw/writing/exemplar_papers/hovhannisyan2025_armenian_demographic_history.pdf`.
  Paragraph numbers follow the PMC text (PMC11739871).
- **Genre:** population-genomics article (Introduction, Material and methods, Results,
  Discussion). Abstract 226 words; Introduction 1,257; Methods 2,299; Results 4,234;
  Discussion 1,110.
- **Why it is here:** Manica-lab genomics with ancient and modern genomes, formal tests
  of competing hypotheses, demographic inference and a power check by subsampling. It
  matches the genomics side of the thesis (giraffe population genomics, CISGeM fitting).

## Structure

- **Abstract.** The new dataset, the analyses, then one sentence per finding:
  - homogeneous structure;
  - a bottleneck instead of Assyrian input for the Sasun;
  - no support for a Balkan origin;
  - Levantine input after the Early Bronze Age;
  - medical variants.
  It ends with an implication.
- **Introduction.** Regional history, then one open question per paragraph (continuity;
  the origin debate; the Sasun controversy; under-representation in databases). Each
  paragraph ends with what is needed. "Here, we introduce" the dataset and list the
  analyses.
- **Methods.** Every tool with version and parameters; SNP and sample counts after each
  filter; thresholds (kinship 0.0884; |Z| > 3); how sequencing technology and ancient
  DNA damage were handled.
- **Results.** Topic headings, one phrased as a test ("Testing the Balkan theory").
- **Discussion.** The findings in order, each set against earlier studies; then cautions
  (reference bias, mixed technologies) and open questions.

## Moves worth copying

1. **Say what each hypothesis predicts before the test** (P42). Positive D-statistics
   are expected under the Balkan theory; none are observed.
2. **Check power before reading an absence** (P41, P47). Subsampling shows the sample
   size at which a real signal becomes detectable (seven per group). The same rule is
   then applied to every test, and small groups are flagged.
3. **Triangulation across methods with different assumptions** (P33–P35, P58). The
   conclusions rest on agreement between ADMIXTURE, FST, haplotype painting,
   D-statistics, admixture graphs and dating methods. A method that gave unstable
   results (qpAdm) is reported as unstable (P52).
4. **Openness about model choice** (P19). Several admixture graphs fit; the chosen one
   follows known chronology and relationships, and the text says so.
5. **Counts at each filtering step** (P11–P21), so a reader can follow the data from
   raw calls to each analysis.
6. **Each source of bias named with its mitigation, and where mitigation was not
   possible** (P11, P40, P58): transversions for DNA damage; a single sequencing
   technology where feasible.

## To avoid

- Many sentence-opening adverbs ("Strikingly", "Intriguingly", "Remarkably",
  "Interestingly") and figurative verbs ("deciphered", "armed with", "equipped with").
- "We demonstrated" that a bottleneck is the main cause of the Sasun's distinctness
  (P54). The evidence is a smaller effective size in MSMC and in IBD-based estimates,
  and the IBD analysis found little signal of recent change (P36–P37). That shows a
  bottleneck, not that it is the main cause; "our results suggest" fits the evidence.
- A 4,200-word Results section that mixes findings with interpretation, with paragraphs
  of up to about 490 words.

## Use in this thesis

- Genomics and CISGeM chapters:
  - a power check by subsampling before interpreting weak signals (our
    `pi_sampling_optimisation`);
  - the expected direction of each statistic under each scenario, stated before the
    result;
  - filtering counts in Methods.
