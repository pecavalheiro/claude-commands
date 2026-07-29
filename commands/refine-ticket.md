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

**Order matters:** open questions are resolved with me interactively (Phase 2) BEFORE the refined ticket text is drafted (Phase 3). A ticket that still has unresolved questions has no useful description — so the description is produced only once they are settled, and any `[TBD]` it carries is one I explicitly chose to defer.

## Chat-first contract (the UX law — overrides habit)

- Local files are the command's working memory, never my reading material. **Anything that needs my attention, decision, or action appears in chat, in full** — never "see the file for details".
- Paste-ready artifacts (the refined ticket, ask drafts) are presented inside fenced code blocks so the raw markdown survives copying from the terminal.
- Every action left to me is an explicit chat item at the end: "paste this into the ticket description", "send this to <owner> (link)", "set these labels". Nothing actionable lives only on disk.

## Non-negotiable principles

1. **Every run starts fresh — this is CRITICAL and is NEVER skipped.** NEVER, under any circumstances, scan, list, open, or read any other local run folder, any prior `research-notes.md` / `refined-ticket.md`, or any earlier working document — no prior-run check, no inheritance, no "quick look for context." The ONLY prior material that may enter is a path I explicitly name in $ARGUMENTS. Re-running on the same ticket is just a fresh crawl from the live sources: approved asks were posted to crawlable venues, so their answers are picked up as ordinary sources. Reusing a previous run's notes or conclusions is a critical failure of this command.
2. **Never proceed blind.** Fetch every source with its native connector (tracker, docs, Slack, GitLab, Figma, Loom, and the data warehouse via the Snowflake MCP — all preflighted per Phase 0 step 1; a WebFetch 200 returning an app shell/login page is a FAILED fetch). **A doc page that renders prose but drops its operations/nav sidebar — common on Mintlify/ReadMe/Redocly-style API references, where the endpoint catalog IS that sidebar — is a PARTIAL fetch: never conclude a capability is absent from it; recover the full surface via the site's OpenAPI/Swagger JSON, `llms.txt`/sitemap, a search engine, or a direct fetch of the plausible endpoint URL.** Inaccessible source → STOP immediately and ask me (fix access / skip / abort). A fetched source judged irrelevant may be excluded autonomously with the reason recorded and reported.
3. **Evidence discipline.** Every claim gets an ID, a verbatim quote, a deep locator (message permalink / doc block / ticket section / MR discussion / file:line), author + date, and a provenance tag: `[stated]` / `[decision]` (by whom) / `[open-question]` / `[assumption]` / `[inferred]` / `[code]` (a fact read from code/schema — file:line) / `[verified]` (independently confirmed against its source, vendor docs, or real data). Unverifiable claims are `[unverified]` and never presented as fact; only `[decision]` and `[verified]` entries may read as settled in the ticket (Principle 8, pre-output gate). Never harden a hedge: "likely/should/presumably" stays hedged or gets verified.
4. **Sources answer first.** Never ask me or an owner what a source already answers; quote it instead. Never re-present anything I have decided, in any rewording.
5. **Contradictions are surfaced, never silently resolved.** When live sources conflict on what the feature should do, both sides are quoted (author + date) and the item is flagged: source precedence (current ticket > approved doc decision > older sketch/comment) picks the *recommended* resolution, never the resolution. It ends as my decision or a routed ask.
6. **Genuine unknowns are never resolved by model defaults.** A default is a recommendation attached to a question, nothing more. An unanswered product question makes the ticket NOT READY — saying so is the command working, not failing.
7. **External-system claims from tickets are never trusted — and "it can't be done" is the most dangerous of them.** Tickets misremember third-party APIs and routinely under-claim ("not possible", "needs dev support we lack", "no endpoint for that"). Doc-verify every load-bearing external claim (endpoints, fields, events, limits) now, by DISCOVERY not confirmation: for each capability the ticket relies on OR claims is missing, independently map what the vendor actually offers *for that goal* (search the goal — e.g. "download inquiry PDF" — not the object you already hold), then compare; never set out to confirm the ticket's pessimism. **Absence bar (mirrors Principle 8 for code):** "the vendor does NOT support X" is never a fact until the check has (a) run a goal-oriented web search, (b) enumerated the vendor's FULL operation surface — OpenAPI/Swagger spec, API-reference index, or `llms.txt` — not one object/page, and (c) directly fetched the most plausible endpoint URL(s); "not on the page I read" is never "not in the API", and short of this bar the claim stays `[unverified]`, never presented as fact. Empirical/sandbox verification still belongs to /requirements-start at implementation time. A claim that fails doc-check is corrected in the refined ticket — this is exactly the class of error that fakes "ready".
8. **Code and data answer "what happens today", never "what should happen".** Evidence bars: static facts → defining file:line; behavioral claims → the code that DEFINES the behavior, not a call site; absence claims → the named exhaustive search performed. **A schema/field/table existing in code is NOT proof the data behaves as assumed:** every LOAD-BEARING data assumption (a column is populated for a given population, a table holds what the ticket needs, a slot is actually used today) is confirmed READ-ONLY against the real data via the Snowflake MCP now — a code read alone can never harden a data assumption into a settled fact. A code or schema fact may inform a Technical note or a recommendation, but it may NEVER settle a product/design decision or resolve a source-flagged open question ("Confirm X", "X vs Y") — only a source decision or my explicit approval settles those (Principle 6). Heavy empirical/sandbox/integration verification still belongs to /requirements-start.
9. **Write scope (hard rule).** The ONLY external write this command may perform is creating approved child tickets in the tracker (each individually approved in chat). The refined description is NEVER written to the tracker — it is presented in chat and I paste it. Question drafts are NEVER sent — I send them. Nothing else is posted, edited, reacted to, or created anywhere, ever.
10. **Subagents return evidence** (verbatim quotes, locators, file:line), never verdicts. Read the evidence and conclude in the main thread. **A null result is evidence only when it carries its search trail:** a subagent reporting "X not found" must return the queries run, the indexes/specs enumerated, and the pages fetched (flagging any that came back partial per Principle 2). The main thread may never upgrade "not found on the pages read" to "does not exist" without that trail — an absence claim without a search behind it is `[unverified]`.

## Workflow

### Phase 0 — Setup & source crawl (autonomous)

1. **Connector preflight (BEFORE any investigation — same discipline as /requirements-start):** make one trivial read call to EVERY MCP connector this command can use — tracker (Linear), Slack, docs (Notion), GitLab, Figma, Loom, web (WebSearch/WebFetch), AND the Snowflake MCP (data grounding). If ANY of them is missing, unauthenticated, erroring, or returns an app-shell/permission failure, STOP IMMEDIATELY and tell me exactly which server failed and how — do not begin the crawl, do not launch any subagent, do not silently waive or work around it. Only I decide whether to connect it (e.g. `/mcp`) or proceed without it.
2. Create `ticket-refinements/YYYY-MM-DD-HHMM-<TICKET-ID>/` with `metadata.json` (structure below) and `research-notes.md`. These files are working memory only (chat-first contract).
3. **Crawl the source graph breadth-first until closed:** the ticket (description AND comments) → linked/related tickets (relations + current status) → PRD/docs including inline comments and what each is anchored to → pages they link → referenced threads (full, every reply) → referenced MRs/branches → media (video transcripts, design files). One extraction subagent per source; each fetches COMPLETELY via the native connector, writes its FULL extract to `sources/<SRC-ID>.md` (mandatory — this file is what the Phase 2 verifiers re-check against; a run that ends with an empty `sources/` folder has skipped its own protocol), and returns only a register row + discovered links.
4. Build the **claims register** in `research-notes.md` per Principle 3 — open questions posed in ANY source (question marks, TBDs, option lists without a decision, AND imperative "confirm/verify/decide X" or "X vs Y" phrasings) are first-class entries with who posed them and what they were anchored to. An imperative to "confirm" is the source telling you it is unsure: it stays OPEN until a source decision or I settle it — never closed by a code or data read (Principle 8).
5. **Currency snapshot:** status + timestamp for every mutable fact (ticket/MR states, dependency availability).
6. Queue every external-system claim — including every claim that a capability is missing, hard, or "needs dev support" — for the Principle 7 doc-check (discovery framing + absence bar) and run it now.

### Phase 1 — Grounding & analysis (autonomous)

7. **Code & data grounding:** verify what the ticket asserts about the current system (does that endpoint/field/flow exist? what happens today on the paths the ticket touches?) under the Principle 8 bars — and for every LOAD-BEARING data assumption, confirm it READ-ONLY against the real data via the Snowflake MCP (is the column populated for this population? does the table hold what the ticket needs? is the slot actually used today?), never from the schema alone. No design work — this is fact-checking, not planning.
8. **Classify every statement of intended product behavior** into exactly one bucket:
   - **Settled** — an authoritative source states it as a decision; quote + claim ID.
   - **Contested** — live sources conflict; both sides quoted; recommendation via precedence (Principle 5).
   - **Vague** — stated but not testable as written ("handle errors properly", "notify the team") — needs sharpening into observable behavior.
   - **Missing** — required by the Definition of Ready but no source addresses it (edge cases, failure paths, eligibility boundaries, rollout posture).
9. **Split assessment:** does the ticket hold more than one deliverable (different layers, teams, phases, or independently shippable outcomes)? Draft the axes with a recommendation and each option's consequence (sequencing, review size, ownership). Include "no split" whenever defensible.
10. **Owner map:** for every Contested/Missing/open item, identify who owns the answer (cited — named as owner/author/decider in a source) and the venue where the ask should land (prefer the venue where the item's evidence lives; must be crawlable — never a DM).

### Phase 2 — Interactive resolution (in chat — the only interactive phase)

The description is NOT drafted until this phase closes: a ticket with open questions has no useful description, so we settle them together first. This is NOT a crawl/coverage confirmation gate — there is none — it is only about decisions and not-yet-clear items.

11. **Open with the readiness snapshot, then the split call.** Present the Definition of Ready checklist (pass/fail + one-line reason each) so the gaps are visible, then the split assessment (options, recommendation, consequences, "no split" when defensible). The split is my call and comes first — it determines what gets drafted. (If you know of a source I missed, name it and I fold it in before proceeding — a note, not a gate.)
12. **Resolve every not-100%-clear item — ONE AT A TIME, each as a real question to me, and WAIT for my answer before the next** (use the Decision question format). For each Contested / Vague / Missing / source-flagged-open item, present an Evidence block (claim IDs → verbatim quote → clickable locator), a recommended answer with a couple of options where they exist, and — for anything I may not own — the cited owner who could clarify. I dispose each, and you record it:
    - **I decide it** (or pick an option) → it becomes a settled statement in the ticket.
    - **I don't know / route to an owner** → it goes to the ask pack; then ask me, for THIS item, whether to (a) record it as a `[TBD]` in the description meanwhile, or (b) HOLD — do not draft the description until the answer lands (a re-run picks it up, Principle 1).
    - **Mark it `[TBD]`** → recorded as a `[TBD]` question in the description (keeps the ticket NOT READY).
    Never settle one of these by a model default, a code read, or a data read (Principles 6, 8) — a recommendation is only ever a suggestion attached to the question. Questions only I can settle (scope, intent, priority, appetite) come to me; anything an identified owner should answer is routed, never put to me as if I owned it. Contradictions are shown with both sides quoted and the precedence recommendation (Principle 5), resolved by my decision or a routed ask — never silently.
13. **Close with a disposition recap** — one short list: each item and its outcome (decided / routed + `[TBD]` / routed + HOLD / `[TBD]`). If ANY item is on HOLD, the description is DEFERRED: Phase 3 delivers the verdict + ask pack and notes the description comes on a re-run once the held answers land. Otherwise, proceed to draft.

### Phase 3 — Draft, verify & deliver (autonomous, then present)

Entered only after Phase 2 closes. If any item is on HOLD, do NOT draft a ticket body — go straight to delivery (verdict + ask pack + the re-run note). Otherwise:

14. **Draft the refined ticket text** (and each child, if split) per the template and its writing rules, using ONLY my Phase 2 decisions plus source-`[decision]`/`[verified]` facts. The only `[TBD]`s permitted are the ones I explicitly chose in Phase 2 — none are invented here.
15. **Verification gate:** fresh, context-isolated subagents — given the claim and where to look, never the reasoning that produced it — re-verify everything destined for the final text: every quoted claim against its source (verbatim, anchor, attribution), every code/system fact re-derived, every load-bearing data assumption re-confirmed read-only against the real data (Snowflake, Principle 8), every external-system claim against docs, currency re-checked. **Every absence / "not possible" / "no such endpoint" claim additionally gets an ADVERSARIAL verifier whose explicit goal is to DISPROVE it — find the endpoint or capability that makes it false — via Principle 7's absence bar (goal-oriented search + full operation surface + direct endpoint fetch); it is NOT handed "where to look" (that re-biases toward the page that lacks it), and the claim survives only if a genuine disprove attempt fails AND returns its search trail (Principle 10).** Failures are corrected everywhere; an unverifiable item is demoted to a [TBD] question or dropped — **nothing `[unverified]` appears in the refined ticket as fact.** Delivery does not begin until every check has RESOLVED.
16. **Pre-output gate:** walk the final text sentence by sentence — every settled statement must trace to a `[decision]` or `[verified]` register entry (Principle 3). A `[code]`, `[inferred]`, or `[assumption]` entry — or ANY entry still marked pending — may NEVER appear as settled fact: it is a hedged Technical note or a [TBD], never an acceptance criterion. A model recommendation never appears as settled (rollout posture — flags, backfill, sequencing — included). A sentence that fails becomes a [TBD] or has no place in the ticket.
17. **Deliver in chat, in this order:** the **readiness verdict** (READY only if zero `[TBD]`s remain; otherwise NOT READY, naming each remaining `[TBD]` and what would flip it) → **the refined ticket text** (and each child, if split) in fenced code blocks → the **ask pack** (routed items, per the Routed ask format) → the **action list**: (a) paste-ready description(s); (b) every ask + its destination link; (c) recommended tracker metadata (status, labels, estimate, project, relations — recommend only, never set) → **coverage (FYI):** sources read / excluded + why, nothing dropped silently. If the description is DEFERRED (HOLD items), say so plainly and deliver the verdict + ask pack in place of a ticket body.
18. **Then I react.** Iterate on my edits to the ticket text. If I approve a split, create the child tickets in the tracker (linked to the parent as sub-issues or related, per my choice) and echo their URLs — child creation is the ONLY write, approved per item (Principle 9). The parent/main description is mine to paste — remind me explicitly.

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
- **Only decided things read as decided.** Every settled statement traces to a source `[decision]`/`[verified]` entry or my explicit approval this run; a model recommendation, a `[code]`/`[inferred]` fact, or a bare code/schema read never reads as a decision — rollout posture (flags, backfill, sequencing) included. Undecided → [TBD] or omitted.
- **Sources hold documentation only.** No tracker tickets (recommend native ticket relations instead), no MR links, no public API docs — those are googleable or belong elsewhere.
- No section restates another's content. There is deliberately no "in scope" section — Context plus Acceptance criteria already carry it.
- Prefer bullets over prose and short sentences over qualifiers. Bold-label prefixes on every line are noise.

## Definition of Ready (the verdict checklist)

1. Every acceptance criterion is final, testable, and uncontested — no [TBD] items remain.
2. The criteria cover the happy path and the failure/edge cases that matter — without enumerating no-op behavior.
3. Dependencies named in the notes verified to exist / be available, current status checked.
4. Every factual claim verified — external-system claims doc-checked, load-bearing data assumptions confirmed against real data (Snowflake), code facts re-derived; no `[unverified]` facts, and nothing read as settled that traces only to `[code]`/`[inferred]`/`[assumption]` or a still-pending check.
5. Self-contained: implementable without opening any source link.
6. Right-sized: one deliverable; otherwise split.

## Formats

Decision question (Phase 2 — asked ONE at a time; WAIT for my answer before the next):

```
### D-1 — <the decision, phrased as a question>
**Evidence:** [C-n] "<verbatim quote>" (link) · [C-m] "<verbatim quote>" (link)
**Recommendation:** <option> — <one-line why + citation>
**Options:** (a) <…>  (b) <…>
**Not sure?** <cited owner> could clarify — <venue link>.
**Or:** shall I record this as `[TBD]: <question>` in the description?
```

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
  "phase": "crawl | analysis | resolve | verify | deliver | complete",
  "verdict": null,
  "tbdItems": 0,
  "asks": { "drafted": 0, "approved": 0 },
  "children": [],
  "sources": { "tracker": [], "docs": [], "slack": [], "gitlab": [] }
}
```

## Phase transitions

- **Re-ground at every boundary AND before each high-risk step.** Re-read the **Rule card** (below) at every phase boundary, whenever resuming after an interruption or context compaction, and immediately before each high-risk autonomous action — connector preflight, any doc-check, any Snowflake data-check, drafting the ticket text, the verification gate, and the pre-output gate. At phase boundaries also re-read the fuller text for that phase from this file (`~/.claude/commands/refine-ticket.md`): before Phase 0 the Non-negotiable principles + this section; before Phase 1 Principles 6/7/8; before Phase 2 Principle 6 + the interactive-resolution rules + the Decision question / Routed ask / Contradiction formats; before Phase 3 Principles 3/10 + the verification & pre-output gates + the template, writing rules, and Definition of Ready. The Rule card is short and cheap — re-read it often; a long autonomous crawl pushes these rules too far back to trust recall, and after compaction they are gone. Never run a phase — or a doc/data check — from memory of these rules.
- After each phase, announce: "Phase complete. Starting [next phase]..."
- Phases 0–1 are fully autonomous (Phase 0 hard stops excepted — connector preflight / inaccessible source), and there is NO crawl/coverage confirmation gate. **Phase 2 is the interactive phase** — every open question is settled with me one at a time BEFORE any description is drafted. Phase 3 drafts (only once nothing is on HOLD), runs the trust gate, and delivers; child-ticket creation (Phase 3 step 18) is the only interactive write, approved per item.

## Rule card (re-grounding — the invariants that drift)

Re-read this card per the Phase transitions rule above: at every phase boundary, on resume, after any context compaction, and before each high-risk autonomous step. It is the gist; the Non-negotiable principles and phase steps are the authoritative letter — the card never overrides them.

1. **Fresh run** — NEVER read any prior local run folder, `research-notes.md`, or `refined-ticket.md`; only a path I name in $ARGUMENTS enters (P1).
2. **Preflight ALL connectors** — incl. Snowflake — before crawling; any missing/unauthenticated/erroring server → STOP and tell me which and how (Phase 0 step 1).
3. **External "can't / doesn't exist" is a hypothesis, not a finding** — verify by discovery, not confirmation; no absence is fact without the bar: goal-oriented web search + full API surface (OpenAPI/index/`llms.txt`) + direct endpoint fetch (P7).
4. **Data assumption → confirm READ-ONLY in Snowflake** — a schema/field/table existing in code is NOT proof the data behaves that way (P8).
5. **Code/schema NEVER settles a decision or a source-flagged "Confirm X" / "X vs Y" open question** — only a source decision or my approval does (P6, P8).
6. **Only `[decision]`/`[verified]` may read as settled** — `[code]`/`[inferred]`/`[assumption]`/pending → hedged note or `[TBD]`; nothing `[unverified]` as fact (P3, step 16).
7. **Sources answer first** — never ask what a source already answered; never re-present what I decided (P4).
8. **Contradictions surfaced, never silently resolved** — both sides quoted; precedence = recommendation only (P5).
9. **Subagents return evidence, never verdicts** — a null result must carry its search trail (P10).
10. **Write scope** — the ONLY write is approved child tickets; the description is never written to the tracker, asks are never sent (P9).
11. **No crawl gate; ONE interactive phase** — Phases 0–1 autonomous; Phase 2 settles every open question with me one at a time; the description is drafted (Phase 3) only AFTER, never alongside open questions. A `[TBD]` appears only where I chose it; a HOLD defers the description to a re-run (P1).
12. **Don't harden a hedge, don't ship a pending check** — "likely/should/presumably" stays hedged or gets verified; delivery waits until every check resolves (P3, step 15).
