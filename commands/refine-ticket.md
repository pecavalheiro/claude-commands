# Refine Ticket

Refine into an implementation-ready ticket: $ARGUMENTS
ultrathink: Deep analysis of a ticket's clarity, completeness, and readiness

aliases: rt

The input is a tracker ticket (URL or ID), optionally followed by extra context I explicitly name (links, local paths). The mission: produce a **clear, concise, self-contained version of that ticket** plus an honest **readiness verdict** — a ticket someone could pick up and implement (via /requirements-start) without doing any external research. This command is NOT a spec and NOT implementation planning: it settles **product behavior and expectations**, at ticket altitude. The driver: tickets get marked "ready for development" while still containing wrong facts, contradictions, and unanswered questions — this command exists to catch that before an implementer does.

## Deliverables (every one presented IN CHAT — see the chat-first contract)

1. **Refined ticket text** following the template below — paste-ready.
2. **Readiness verdict** against the Definition of Ready: READY, or NOT READY with the exact blockers.
3. **Split proposal** (if the ticket holds more than one deliverable) — and, after my approval, the child tickets created in the tracker.
4. **Ask pack**: every open question routed to its owner, with a paste-ready draft — flagged contradictions included.

## Chat-first contract (the UX law — overrides habit)

- Local files are the command's working memory, never my reading material. **Anything that needs my attention, decision, or action appears in chat, in full** — never "see the file for details".
- Paste-ready artifacts (the refined ticket, ask drafts) are presented inside fenced code blocks so the raw markdown survives copying from the terminal.
- Every action left to me is an explicit chat item at the end: "paste this into the ticket description", "send this to <owner> (link)", "set these labels". Nothing actionable lives only on disk.

## Non-negotiable principles

1. **Every run starts fresh.** Never scan, list, or read other local run folders or prior working documents — no prior-run check, no inheritance. Prior material enters only if I explicitly name its path in $ARGUMENTS. Re-running on the same ticket is just a fresh crawl: approved asks were posted to crawlable venues, so their answers are picked up as ordinary sources.
2. **Never proceed blind.** Fetch every source with its native connector (tracker, docs, Slack, GitLab, Figma — preflight them; a WebFetch 200 returning an app shell/login page is a FAILED fetch). Inaccessible source → STOP immediately and ask me (fix access / skip / abort). A fetched source judged irrelevant may be excluded autonomously with the reason recorded and reported.
3. **Evidence discipline.** Every claim gets an ID, a verbatim quote, a deep locator (message permalink / doc block / ticket section / MR discussion / file:line), author + date, and a provenance tag: `[stated]` / `[decision]` (by whom) / `[open-question]` / `[assumption]` / `[inferred]`. Unverifiable claims are `[unverified]` and never presented as fact. Never harden a hedge: "likely/should/presumably" stays hedged or gets verified.
4. **Sources answer first.** Never ask me or an owner what a source already answers; quote it instead. Never re-present anything I have decided, in any rewording.
5. **Contradictions are surfaced, never silently resolved.** When live sources conflict on what the feature should do, both sides are quoted (author + date) and the item is flagged: source precedence (current ticket > approved doc decision > older sketch/comment) picks the *recommended* resolution, never the resolution. It ends as my decision or a routed ask.
6. **Genuine unknowns are never resolved by model defaults.** A default is a recommendation attached to a question, nothing more. An unanswered product question makes the ticket NOT READY — saying so is the command working, not failing.
7. **External-system claims from tickets are never trusted.** Tickets misremember third-party APIs and other systems' behavior. Doc-verify every load-bearing external claim (endpoints, fields, events, limits) now; note that empirical/sandbox verification belongs to /requirements-start at implementation time. A claim that fails doc-check is corrected in the refined ticket — this is exactly the class of error that fakes "ready".
8. **Code answers "what happens today", never "what should happen".** Evidence bars: static facts → defining file:line; behavioral claims → the code that DEFINES the behavior, not a call site; absence claims → the named exhaustive search performed.
9. **Write scope (hard rule).** The ONLY external write this command may perform is creating approved child tickets in the tracker (each individually approved in chat). The refined description is NEVER written to the tracker — it is presented in chat and I paste it. Question drafts are NEVER sent — I send them. Nothing else is posted, edited, reacted to, or created anywhere, ever.
10. **Subagents return evidence** (verbatim quotes, locators, file:line), never verdicts. Read the evidence and conclude in the main thread.

## Workflow

### Phase 0 — Setup & source crawl (autonomous)

1. **Connector preflight:** one trivial call per connector the graph will need. Missing/unauthenticated → STOP and ask me to connect or waive that source type.
2. Create `ticket-refinements/YYYY-MM-DD-HHMM-<TICKET-ID>/` with `metadata.json` (structure below) and `research-notes.md`. These files are working memory only (chat-first contract).
3. **Crawl the source graph breadth-first until closed:** the ticket (description AND comments) → linked/related tickets (relations + current status) → PRD/docs including inline comments and what each is anchored to → pages they link → referenced threads (full, every reply) → referenced MRs/branches → media (video transcripts, design files). One extraction subagent per source; each fetches COMPLETELY via the native connector, writes its extract under `sources/`, and returns only a register row + discovered links.
4. Build the **claims register** in `research-notes.md` per Principle 3 — open questions posed in ANY source (question marks, TBDs, option lists without a decision) are first-class entries with who posed them and what they were anchored to.
5. **Currency snapshot:** status + timestamp for every mutable fact (ticket/MR states, dependency availability).
6. Queue every external-system claim for the Principle 7 doc-check and run it now.

### Phase 1 — Grounding & analysis (autonomous)

7. **Code grounding:** verify what the ticket asserts about the current system (does that endpoint/field/flow exist? what happens today on the paths the ticket touches?) under the Principle 8 bars. No design work — this is fact-checking, not planning.
8. **Classify every statement of intended product behavior** into exactly one bucket:
   - **Settled** — an authoritative source states it as a decision; quote + claim ID.
   - **Contested** — live sources conflict; both sides quoted; recommendation via precedence (Principle 5).
   - **Vague** — stated but not testable as written ("handle errors properly", "notify the team") — needs sharpening into observable behavior.
   - **Missing** — required by the Definition of Ready but no source addresses it (edge cases, failure paths, eligibility boundaries, rollout posture).
9. **Split assessment:** does the ticket hold more than one deliverable (different layers, teams, phases, or independently shippable outcomes)? Draft the axes with a recommendation and each option's consequence (sequencing, review size, ownership). Include "no split" whenever defensible.
10. **Owner map:** for every Contested/Missing/open item, identify who owns the answer (cited — named as owner/author/decider in a source) and the venue where the ask should land (prefer the venue where the item's evidence lives; must be crawlable — never a DM).

### Phase 2 — Interactive session (in chat, this fixed order)

11. **Coverage table:** every source-graph node — type, fetch status (fully read / partial + what's missing / excluded + why), claims extracted, links found — ending with "graph closed — last sweep added 0 nodes". WAIT for my confirmation unless all-green. A source I name gets fetched and merged before anything else proceeds. No question may share a message with this table.
12. **Readiness snapshot:** the Definition of Ready checklist with the current pass/fail per criterion and a one-line reason each. This frames every question that follows.
13. **Split decision:** present the assessment (options, recommendation, consequences). My call. If split: agree which behaviors/requirements land in which child before any text is drafted.
14. **My decisions** — questions only I can settle (scope, intent, priority, appetite), one at a time, each with an Evidence block (claim IDs → short verbatim quote → clickable locator) printed in chat before the ask, yes/no with a cited recommended default where possible. Anything an identified owner should answer instead is NOT asked to me — it routes to the ask pack.
15. **Ask pack review:** routed questions grouped per owner per venue. Each item: owner (+ why, cited), venue link, paste-ready draft written FOR that venue, default-if-unanswered, and consequence-if-the-answer-differs. I approve / edit / drop / re-route each. An approved-but-unanswered ask surfaces in the refined ticket only as a [TBD] acceptance-criteria item — the question phrased for the reader; owner and venue detail stays in the ask pack.

### Phase 3 — Verification gate (autonomous — the trust gate)

16. Fresh, context-isolated subagents — given the claim and where to look, never the reasoning that produced it — re-verify everything destined for the final text: every quoted claim against its source (verbatim, anchor, attribution), every code/system fact re-derived, every external-system claim against docs, currency re-checked. Failures are corrected everywhere; an unverifiable item is demoted to a [TBD] question or dropped — **nothing `[unverified]` appears in the refined ticket as fact.**
17. **Pre-output gate:** walk the final text sentence by sentence — every behavioral statement, number, and named dependency must be backed by a register entry or an explicit decision I made this run; a recommendation I never approved may not appear as settled (rollout posture — flags, backfill, sequencing — included). A sentence that fails becomes a [TBD] or has no place in the ticket.

### Phase 4 — Deliver (in chat)

18. **Readiness verdict:** READY, or NOT READY with the exact blocking items (each naming what would flip it). A ticket with [TBD] acceptance criteria is never called ready — this verdict is the product.
19. **The refined ticket text** (and each child, if split) in a fenced code block, following the template and its writing rules. Wait for my approval; iterate on my edits.
20. **On approval, if split:** create the child tickets in the tracker (linked to the parent as sub-issues or related, per my choice), echo their URLs. The parent/main description is mine to paste — remind me explicitly.
21. **Final chat echo — my action list:** (a) paste-ready description(s); (b) every approved ask with its destination link; (c) recommended tracker metadata (status, labels, estimate, project, and ticket relations — related tickets live in the tracker's relations, never in Sources) — recommend only, never set. Nothing dropped silently: excluded sources and skipped items listed with reasons.

## The Ticket Template (the output contract)

```markdown
# <Short, outcome-focused title>

## Context
Why this work exists: current behavior, who is affected, the driver. One short paragraph.

## Acceptance criteria
What we want, phrased as if it already exists ("The assigned specialist receives an
email when the check fails"), with eligibility woven into the phrasing ("a full-time
employee's …"). A plain bullet or numbered list. An undecided point is its own item,
written as the question to decide, with the current candidates if any:
[TBD]: Which channels should the notification use — email, in-app, or both?

## Technical / other notes
A few short hints worth having before implementation — "similar functionality exists
in SomeClass, worth checking" is the ceiling. Omit the section if nothing earns a line.

## Out of context
What we explicitly don't do here, one bullet each — name the owning ticket when known.
Omit the section when empty.

## Sources
Documentation only — internal docs and discussion threads, one labeled link per line:
[Document name](url) · [Slack thread](url).
```

**Writing rules (the anti-noise contract — every ticket, every child):**
- The ticket is written to be READ: it should fit on roughly one screen. If it can't, cut harder or split the ticket. Omit any section with nothing to say.
- **Zero provenance in the body.** No citations, claim IDs, dates, "decided by", "verified against", thread/reply pointers, or file:line evidence markers. Verification lives in the working files; the published ticket carries none of the apparatus. Naming a module, endpoint, or ticket as information is fine — pointing at evidence is not.
- **State only what changes.** Never enumerate unchanged or no-op behavior ("X remains unchanged", "Y still fires", "Z sends nothing") — silence already says that.
- **[TBD] items are questions, not annotations.** Format: `[TBD]: <the question to decide>` — plain text, never wrapped in backticks, never a settled-sounding statement with a flag appended, never carrying owners/venues/default-rationale (those live in the ask pack).
- **Notes are hints, never directions.** No trigger points, no code paths to modify, no "mirrors TICKET-N's approach", no investigation trivia, and never a "confirm/verify/check with …" task — anything needing confirmation is settled during refinement or becomes a [TBD].
- **Only decided things read as decided.** Every settled statement traces to a source decision or my explicit approval this run; a model recommendation never appears as fact — rollout posture (flags, backfill, sequencing) included. Undecided → [TBD] or omitted.
- **Sources hold documentation only.** No tracker tickets (recommend native ticket relations instead), no MR links, no public API docs — those are googleable or belong elsewhere.
- No section restates another's content. There is deliberately no "in scope" section — Context plus Acceptance criteria already carry it.
- Prefer bullets over prose and short sentences over qualifiers. Bold-label prefixes on every line are noise.

## Definition of Ready (the verdict checklist)

1. Every acceptance criterion is final, testable, and uncontested — no [TBD] items remain.
2. The criteria cover the happy path and the failure/edge cases that matter — without enumerating no-op behavior.
3. Dependencies named in the notes verified to exist / be available, current status checked.
4. Every factual claim verified — external-system claims doc-checked; no `[unverified]` facts.
5. Self-contained: implementable without opening any source link.
6. Right-sized: one deliverable; otherwise split.

## Formats

Routed ask (chat presentation opens with its destination):

```
### A-2 → <owner> (PM — decision owner per TICKET-812 §Description) — blocks R3
**Venue:** TICKET-812 comment (link)
**Ask (paste-ready):** "<self-contained text written for the venue>"
**Default if unanswered:** <recommendation + citation>
**Consequence if the answer differs:** <which R-n changes; "minor rework" is not a consequence>
```

Contradiction flag:

```
### C-1 — Who gets notified on failure: PRD says the customer [SRC-2.7, <author>, <date>]
vs later thread decision says ops-only [SRC-5.4, <owner>, <date>].
Precedence recommends SRC-5.4 (later + decision owner) — recommendation only → A-3.
```

## Files, metadata & handoff

- Folder: `ticket-refinements/YYYY-MM-DD-HHMM-<TICKET-ID>/` — files: `research-notes.md`, `sources/*.md`, `refined-ticket.md`, `children/*.md`, `asks.md`, `metadata.json`. Working memory only; /synthesize never reads this folder.
- Handoff: once the ticket is READY (pasted + status updated by me), /requirements-start runs on it as the primary source for implementation.

```json
{
  "ticket": "TICKET-812",
  "started": "ISO-8601",
  "lastUpdated": "ISO-8601",
  "phase": "crawl | analysis | interactive | verify | deliver | complete",
  "verdict": null,
  "tbdItems": 0,
  "asks": { "drafted": 0, "approved": 0 },
  "children": [],
  "sources": { "tracker": [], "docs": [], "slack": [], "gitlab": [] }
}
```

## Phase transitions

- **Re-ground at every boundary:** before each phase — and whenever resuming after an interruption or context compaction — re-read this file (`~/.claude/commands/refine-ticket.md`): the Non-negotiable principles, the chat-first contract, plus the section of the phase about to start. Never run a phase from memory of these rules.
- After each phase, announce: "Phase complete. Starting [next phase]..."
- Phases 0, 1, 3 are autonomous (Phase 0 hard stops excepted); Phase 2 is the single interactive pass in its fixed order; Phase 4 ends with the explicit my-action list.
