# Writing principles from guides on scientific writing

General guides that complement the exemplars. Each entry gives the source, what was
read and the principles, paraphrased. Tags match `SKILL.md`.

## GS90: sentences that readers interpret as intended

Gopen GD, Swan JA (1990) The science of scientific writing. *American Scientist*
78: 550–558. Read in full.

Readers take cues from structure. Where information sits tells them how important it
is and how it connects. The principles:

1. **Keep the subject close to its verb.** Words between them read as an interruption,
   and readers discount them.
2. **One unit, one job.** Every unit, from clause to section, makes one point or serves
   one function.
3. **The stress position.** The end of a sentence or clause, at syntactic closure, is
   where readers place emphasis. Put the new information you want emphasised there. A
   semicolon or colon creates a second stress position.
4. **The topic position.** The start of a sentence is where readers look for
   perspective. Put there the old information that links back, and the person or
   thing whose story the sentence tells. The authors call this a principle, not a rule.
5. **Sentence length.** A sentence is too long when it has more candidates for
   emphasis than stress positions. Word count alone does not decide it.
6. **Missing links.** When no old information links a sentence back, readers must
   build the connection themselves. Checking the topic positions of a paragraph
   exposes logical gaps that the writer never stated.

**Revision check.** Read only the topic positions of a paragraph: they should tell one
story. Read only the stress positions: they should carry the new points.

## MK17: structure that serves the reader

Mensh B, Kording K (2017) Ten simple rules for structuring papers. *PLoS Computational
Biology* 13: e1005619. <https://doi.org/10.1371/journal.pcbi.1005619>. CC BY. Read in
full (PMC5619685).

1. **One central contribution, carried by the title.** Papers that push several
   contributions convince less about each.
2. **Write for a reader who does not know the work.** Define terms, avoid
   abbreviations, and keep few loose threads open at once.
3. **Context–content–conclusion at every scale.**
   - In a paper, the Introduction gives the context, the Results the content and the
     Discussion the conclusion.
   - In a paragraph, the first sentence sets the topic, the body gives the content and
     the last sentence the conclusion to remember.
   - Do not tell the work in the order it was done.
4. **No zig-zag; use parallelism.** Cover each subject in one place, and give parallel
   points the same form. Keep the same word for the same thing: a new word makes
   readers suspect a new meaning.
5. **Abstract: context, gap, "Here we", results, answer, broader significance.** The
   common mistake is to give results before the reader knows what question they
   answer.
6. **Introduction: progressively narrower gaps.**
   - A field gap, then a subfield gap, then the specific untested hypothesis.
   - No broad literature review.
   - The last paragraph summarises what the paper does and finds.
7. **Results: a chain of statements that supports the central claim.**
   - The first paragraph summarises the approach.
   - Each later paragraph poses its question, gives data and logic, and ends with the
     answer.
   - Declarative statements work as Results subheadings and figure titles.
   - A figure title states the conclusion; the legend says how it was obtained.
8. **Discussion: how the gap was filled, its limits, and what it opens.**
   - The first paragraph summarises the findings.
   - Each later paragraph takes one strength or weakness and weighs it against the
     literature.
   - The last says how the field moves forward.
   This matches the house rule of discussing each limit where it matters, with no
   separate Limitations section.
9. **Spend time where readers spend it:** the title, abstract, figures and outline.
   Outline with one informal sentence per planned paragraph before writing.
10. **Seek feedback and rewrite whole paragraphs.**
    - If you cannot tell the outline to a colleague in a few minutes, the story needs
      distilling.
    - Vague reviews mean readers missed the big picture; specific comments point to a
      paragraph whose logic is short.

## R14: figures

Rougier NP, Droettboom M, Bourne PE (2014) Ten simple rules for better figures. *PLoS
Computational Biology* 10: e1003833. <https://doi.org/10.1371/journal.pcbi.1003833>.
CC BY. Read in full (PMC4161295).

1. Know the audience; identify the single message of each figure.
2. Adapt the figure to its medium (paper, slide, poster).
3. **Captions are not optional.** They explain how to read the figure, and what the
   graphics cannot show.
4. Do not trust plotting defaults.
5. **Choose colour by data type:** sequential for low-to-high values, diverging for
   deviations from a midpoint, qualitative for categories. Avoid similar colours that
   colour-blind readers cannot separate.
6. **Do not mislead.** Scales, axes and areas must represent the data faithfully.
7. Remove chartjunk (extra colours, labels, backgrounds, grid lines). Message comes
   before beauty.

## MU22: the language of statistical evidence

Muff S, Nilsen EB, O'Hara RB, Nater CR (2022) Rewriting results sections in the
language of evidence. *Trends in Ecology & Evolution* 37: 203–210.
<https://doi.org/10.1016/j.tree.2021.10.009>. The full text could not be opened; read
from the abstract, repository records and the published replies.

- **The proposal.** Drop "statistically significant" and describe P-values as graded
  evidence. As quoted by their critics, P > 0.1 is "little or no evidence" and
  P = 0.001 "strong evidence".
- **The replies.**
  - Amrhein & Greenland (2022, *TREE*) prefer the language of *compatibility* between
    the data and a hypothesis.
  - Others note that the evidence a P-value carries depends on statistical power.
- **What to do in the thesis** (the house rule in `writing/CLAUDE.md` agrees):
  - Report the effect size with its interval.
  - Describe strength in graded words.
  - Never read P > 0.05 as "no effect".
  - Keep apart the statistical support for a difference and the difference between
    point estimates.

## WS12: a paper tells a story

Schimel J (2012) *Writing Science: How to Write Papers That Get Cited and Proposals
That Get Funded*. Oxford University Press. Read in full (chapters 1–21) from Ondrej's
copy, `data/raw/schimel_2012_writing_science.pdf`, on 23 November 2026.

The book's first rule is that the writer does the work so that the reader does not
have to. It works from the whole story down to single words, and it is about
revising: first drafts only need to exist.

**The story.**

- Data are the supporting cast. The question and the larger problem carry the story.
  Take the text as far as it goes from data to information, knowledge and
  understanding.
- Build the story from the data upwards, then tell it from the top down. Explore the
  odd results in private, then cut back to the simple core.
- Before drafting, write the four key points: the larger problem, the specific
  question, the two or three key results, and the conclusion. The conclusion answers
  the question and says what it means for the larger problem.
- A sticky story is simple (its core, not simplistic), unexpected (a knowledge gap
  framed by what is known), concrete, credible (an unbroken chain from past work to
  methods, data, statistics and conclusions), emotional (curiosity) and told as a story
  (the SUCCES list, from Heath & Heath). Hype and bold type cost credibility.
- Build on ideas the reader already holds. Expert terms in the middle of the ladder
  of abstraction lose outsiders; tie them to a broad idea or a concrete example.

**Structure by reader patience.**

| Structure | Order | Fits |
|---|---|---|
| OCAR | Opening, Challenge (the question), Action, Resolution | specialist papers, thesis chapters |
| LDR | Lead (main finding), Development, Resolution | Nature-type papers, abstracts, proposals |
| ABDCE | Action first, then Background, Development, Climax, Ending | proposals |
| LD | Lead, then details in falling importance | news, results paragraphs |

- Readers take whatever stands at the opening, the end of the Introduction and the end
  of the Discussion as the opening, the question and the resolution. Those three
  places alone should give the key points.
- The resolution comes back to the opening and is as wide as it. A wider opening
  promises what the paper does not deliver; a narrower one loses the right readers.
- The same arc repeats in sections, paragraphs and sentences. Finish each topic before
  starting the next.

**Section by section.**

- *Opening.* Name the problem and the main characters, and point towards the question.
  Delete textbook material that every reader knows: the story starts after it. For a
  broad audience, open on an issue those readers care about and narrow to the topic
  within the first paragraph.
- *Funnel.* Each step of the Introduction says what we still need to know. Cite the
  known only to mark where knowledge ends. Do not write "little is known about X":
  say what exactly is unknown. Sell the problem before the method. Put citations at
  the end of the sentence; make a researcher the subject only in a debate.
- *Question.* State the question, not only objectives; a hypothesis recasts it as a
  prediction that the data could falsify. A good question reads as "To learn X, we
  did Y". List the aims in order of importance, with the main one first.
- *Methods.* Open each method with its purpose. Name standard methods and give only
  what differs. Deal with a method's limit where the method is described: why it was
  needed, the wider context, how it was mitigated. Then leave it.
- *Results.* Keep data, inference (what any practitioner would conclude) and
  interpretation (your own reading) distinct, even within a sentence, and give the
  data before the conclusion. Choose the data that the story needs; collapse the rest
  into one panel or a supplement. Lead a paragraph with the pattern, then the detail.
- *Statistics.* The story is the effect, the test only qualifies it: "increased
  3.4-fold (P < 0.05)" rather than "significantly increased". A 2.3-fold difference with
  P = 0.07 is a 2.3-fold difference with weak evidence.
- *Limits ("but, yes").* Give the limit first and end on what the work shows: "Despite
  the small number of sites, X ...". In the Discussion, limits go early in the body,
  never in its first or last paragraph. A design with unusual limits can open the
  Discussion with a short section on what the design can and cannot show.
- *Resolution.* Restate the key result, answer the question, then say what it adds to
  the larger problem, ideally in the opening's words. Weak endings: "may provide new
  insights" without naming them, a new idea raised only at the end, and ending on
  what was not done ("more research is needed"). A concrete new question that grew
  from the work is a strong ending.

**Paragraphs and sentences.**

- Most paragraphs state their point first. About a quarter, at openings, transitions
  and conclusions, build to it in the last sentence. A paragraph that drifts from one
  character to the next has several arcs: split it.
- A sentence is the shortest story. Put a short, familiar subject first, its verb right
  after it, and the new point at the end. Qualifications go in the middle, the weakest
  position.
- A long sentence reads easily when its main clause comes first and the elaboration
  follows.
- Flow comes from linking the end of one sentence to the start of the next. When
  several sentences in a row start with the same topic, the text reads as a list.
  Open a new paragraph with the idea the last one ended on.
- Put the action in verbs: "rates differed", not "there was a difference". Replace
  fuzzy verbs (examined, affected, influenced) with verbs that say what happened.
  Use the passive only to keep the right topic or when the actor does not matter.
- A term at the start of a sentence is assumed known, one at the end is being
  defined. When unsure, define it. Spell out abbreviations at first use and make
  readable labels for sites and treatments.
- Prefer short common words (use, show, start). Break noun trains of three or more
  nouns with a preposition.

**Revising.**

- Edit in passes: structure, clarity, flow, then language (SCFL), and go back to
  structure if needed.
- Cut big pieces first (material the story does not need), then words: empty
  amplifiers (very, highly, dramatically; give the number instead), redundant pairs,
  "We found that", "There is evidence that". A second draft is usually 10–20% shorter.
  Keep the words that build flow.
- Read the text aloud from a clean copy.
- In this repository the house rule wins: when revising Ondrej's text, keep every fact,
  number, reference and caveat unless he asks for a cut. The house rule also keeps
  "demonstrates" out of his voice, although the book uses it to mark inferences.

**Novelty and audience.**

- An old question in a new species, region or method fills in information. Say what
  the earlier work left open (does the pattern hold here, by which mechanism, with
  which other factor) and answer that.
- Choose a journal by its scope and readers. "The first data from region X" is a
  common reason for rejection.
- For the public, use more story and fewer terms. The message box sets a short text:
  issue and audience, then problem, so what, solution, benefits. Front-load it, define
  or avoid every technical term, and answer the reader's question in the reader's
  terms without overclaiming. The box also helps to open a proposal.

## Further reading (not processed)

General recommendations, not read for this skill. Process them with
`adding_exemplars.md` before treating them as evidence.

- Williams JM, Bizup J, *Style: Lessons in Clarity and Grace*. Characters as subjects,
  actions as verbs.
- Sword H (2012) *Stylish Academic Writing*. Harvard University Press.
- Pinker S (2014) *The Sense of Style*. Viking.
- Tufte ER, *The Visual Display of Quantitative Information*. Graphics Press.
