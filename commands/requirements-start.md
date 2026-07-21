# Start Requirements Gathering

Begin gathering requirements for: $ARGUMENTS
ultrathink: Deep analysis of the problem space and its implications

The input is typically a Linear ticket (sometimes a document link or a written request). The written sources — the ticket, its linked tickets, the PRD/Notion pages, Slack threads, MRs — are authoritative. Exhaust and verify them before spending my time. Every fact in the output must be traceable to a source quote, a code location, or an explicit decision; everything else is an assumption and must be labeled as one. My time is the scarcest resource in this flow: every question you ask me must have survived the gates below.

## Non-negotiable principles (apply to every phase)

1. **Never proceed blind.** If any source cannot be fetched (MCP auth failure, permissions, dead link), STOP and tell me before continuing — you do NOT get to assess a missing source as "non-load-bearing" and move on; whether it matters is my call (provide access / skip it / abort). Do not improvise around a missing source; partial context produces wrong specs. **STOP means now:** ask the blocking question (fix access / skip this source / abort) the moment the failure is confirmed, and launch no further phase work — subagents included — while it is pending. Deferring it ("I'll surface this before the interactive phase") is a violation. (Different case: a source you fetched and judged out of scope may be excluded autonomously, but record the exclusion + reasoning in the register and list it in the phase announcement.)
2. **Evidence discipline.** Classify every claim before writing it down and meet its evidence bar (Phase 1 defines the bars). A claim you cannot verify is a hypothesis: tag it `[unverified]`, keep the hedge verbatim, and never present it as fact. More reasoning on an unverified premise only makes a wrong conclusion more convincing.
3. **Sources answer first.** Before asking me anything, search the source register and the code. If a sentence in the ticket/PRD/Slack answers it, record it with the quote and move on. Asking me something the sources already answer is forbidden — it signals sloppy reading and erodes trust in everything else produced. The inverse also holds: a question a source explicitly poses is never resolved by a model-picked default — it is settled by an authoritative source, decided by me, or its FR is descoped (see the criticality override, Phase 2).
4. **Decisions are made once.** Once I answer (even indirectly), record it and never re-present that decision — no rewording, no "just to confirm". If later verification changes the premise under my answer, present the changed premise once, with evidence and a recommended default; do not re-ask the question.
5. **Delete, don't reframe.** When I say a topic is out of scope or owned by another ticket/process, remove it from every working document. Repeated pushback on the same item means remove, not refine.
6. **No implementation and no invention.** No code changes, no fixture/cassette edits, nothing fabricated. Any artifact representing external reality (API payloads, fixtures) comes from a verified capture or is flagged `[unverified]`.
7. **Third-party API claims are never trusted from a ticket.** Tickets describe external APIs from memory and are often wrong. Verify every external-API claim (endpoints, fields, hosts, auth, expiry, ordering guarantees) against the official docs, and empirically when a sandbox is available. If an external-API claim is load-bearing and you lack access, ask me for a temporary key, stating exactly what you will test. Account/key configuration (pinned API versions!) changes behavior — verify against OUR account's configuration, not just the latest docs.
8. **Subagents return evidence** (verbatim quotes, file:line, snippets), never verdicts. Read the evidence and conclude yourself; a subagent hedge is a cue to verify, not to trust.

## Full Workflow

### Phase 0: Source Inventory & Extraction (a gate — nothing advances until it passes)

**Connector preflight (before anything else):** the usual source connectors are **Linear, Notion, GitLab, and Figma** (plus Slack when threads are referenced). Verify every connector the source graph will need is connected and authenticated — one trivial call each (e.g., a Linear teams/issue lookup, a Notion search, `glab auth status`, a Figma whoami). If any needed connector is missing or unauthenticated, STOP and ask me to connect it (e.g., `/mcp`) or to explicitly waive that source type for this run. Fetch every source with its **native connector** — WebFetch against an auth-walled SaaS URL (notion.so, linear.app, private GitLab, figma.com) is never a valid accessibility test: a 200 returning an app shell or login page is a FAILED fetch. A source is "inaccessible" only after its proper connector failed or is absent.

1. Setup — **every run starts fresh:** create `requirements/YYYY-MM-DD-HHMM-[slug]/` (slug from $ARGUMENTS), write `00-initial-request.md` (the request verbatim + a summary of the primary source), `metadata.json` (structure below — record the primary ticket id in `sources` immediately), and update `requirements/.current-requirement`. **Never scan, list, read, or search other folders under `requirements/` or any other prior local working documents — no prior-run check, no resume-by-scan, no answer inheritance.** A prior document enters this run ONLY if I explicitly name its path in $ARGUMENTS (e.g., "also read requirements/<folder>" or "/this/path"); an explicitly-named document joins the source graph as an ordinary source — its contents are evidence to quote with locators, never decisions: nothing recorded there counts as an answer I gave in THIS run unless I confirm it here.
2. Enumerate the complete source graph, breadth-first until closed: the primary ticket → every linked/related ticket (record parent/blocks/duplicate relations and each ticket's current status) → PRD/Notion pages (INCLUDING inline comments and what each comment is anchored to) → pages those link to (runbooks, process docs) → referenced Slack threads (full threads, every reply) → referenced MRs/branches → media (Loom/Figma).
3. Fetch every source COMPLETELY — descriptions AND comments/replies. Fan out one subagent per source for parallel extraction; each returns verbatim quotes with stable locators (ticket id + section, comment author + date, Slack permalink, Notion block, MR iid) — never summaries alone.
4. Build the **source-claims register** in `research-notes.md`: every requirement, constraint, decision, open question, and technical claim gets a short stable **claim ID** (`LIN-<ticket>-N`, `PRD-N`, `SLK-N`, `CODE-N`, …) plus: the verbatim quote; a DEEP locator (Slack → message permalink, never just the channel; Notion → block link where possible, else page URL + section heading; Linear → ticket URL + quoted section title; GitLab → MR/discussion URL; code → file:line); author + date; a **"via" chain** showing how the source was reached (e.g., "PRD §Rollout, linked from TICKET-123 description"); and a provenance tag:
   - `[stated]` — the source says it explicitly (quote it)
   - `[inferred]` — you derived it; list the claim IDs it rests on (derived numbers and aggregations always carry this)
   - `[absent]` — no source addresses it (questions and autonomous decisions are made of these)
   **Open questions are first-class register entries:** anything a source poses without a recorded decision — a question mark addressed to anyone, a TBD/TODO, an options list with no decision — in ANY graph source, description or comment. Record WHO said each thing and what it was anchored to — a comment anchored on section X is not a statement about section Y. Downstream, **no naked facts**: any number, quote, or behavioral statement used in a question, option description, finding, or FR must carry its claim ID.
5. Inaccessible media (login-walled videos, expiring screenshots): flag explicitly in the register with what textual coverage substitutes for them; I decide whether that is acceptable.
6. Queue every third-party-API claim for Principle 7 verification and run it NOW — a nonexistent endpoint discovered late invalidates hours of downstream work.
7. Currency snapshot: record status + timestamp of every mutable fact (ticket states, MR states, branch existence) — these get re-checked in Phase 3b, and again by /synthesize's staleness preflight at implementation start.

### Phase 1: Codebase Analysis (autonomous)

8. Map the domain: the code the sources point at, the hook/trigger points, precedent features, house patterns. Fan out subagents for parallel exploration; batch-read what they locate.
9. **Evidence bars** — every claim written into any working document meets the bar for its class:
   - **Static** (names, enum values, schema fields, literals, config): read the defining file; cite file:line.
   - **Behavioral** (side effects, notification chains, transactions/rollback, retries, permission checks, ordering, cron schedules): trace to the code that DEFINES the behavior — framework module, worker config, changeset internals, cron registration. A call site alone never supports a behavioral claim. "How the library usually behaves" is not evidence; this codebase overrides defaults.
   - **Absence** ("no other callers", "no X exists", "the only setter"): name the exhaustive search performed (patterns, scope, exclusions) or do not make the claim.
   - **Literal values** (country names, hosts, config strings): NEVER hardcode from memory or reasoning — resolve from the authoritative seed/table/config and cite it.
10. Inventory both directions of every integration: what the change writes AND every surface that reads/exposes what it writes (value objects/serializers/views, notifications, crons, webhooks, permission checks, API schemas). Exposure surfaces you don't look for are the ones that flip decisions later.

### Phase 2: Coverage Checkpoint, Decision Disposition & Discovery Questions

11. **Source-coverage checkpoint (opens the interactive phase).** Present a one-screen table: every source-graph node — source, type, fetch status (**fully read** / **partially read + what's missing** / **excluded + why**), claims extracted, links found in it — plus every Phase 0 flag shown WITH my prior ruling inline ("excluded — your Phase 0 call"; rulings are context, never re-asked). Statuses are honest: "excluded" applies only to sources FETCHED and then judged out of scope (Principle 1 unchanged); an unfetched node is only ever "pending" or "inaccessible" (and inaccessible already hard-stopped in Phase 0 — the table records my ruling, it does not substitute for the STOP). "Unread" means pending OR partial. The table ends with: "graph closed — last link sweep added 0 nodes." **WAIT for my confirmation unless the table is all-green** (every node fully read, nothing pending/partial, every exclusion carries a ruling, no unconfirmed flags); when all-green, print it and continue autonomously. If I name a missing source: announce "Coverage amended — re-entering Phase 0 for <source>", run Phase 0 steps 2–7 (and any Phase 1 delta) for that node only — its claims join the register and get Phase 3b verification like any other — then re-present a delta table and wait once more. Questions asked while a known source is pending or partial (without my explicit ruling on that specific gap) are invalid. Answers I already gave stand even if a coverage gap surfaces later — the changed-premise protocol (Phase 3b) applies; never re-ask. On any RESUMED session (continuing this same run after an interruption or compaction), present the FULL table before the session's first interactive ask, whatever the phase. Append the confirmed table to `research-notes.md` with a timestamp. The checkpoint is not a question: it has no Evidence block, does not count against the question budget, and is not written to the question files.
12. **Decision disposition — the criticality override.** Work at the level of DECISIONS, not questions: a critical decision that is never drafted as a question must still be dispositioned. Collect every decision this spec must bake in — every `[absent]`-provenance item and every open-question register entry — into a **decision disposition table** (kept in `research-notes.md`, summarized in the phase announcement). Each row: decision → disposition + citation. Dispositions, evaluated in this order:
    - **Source-settled (Gate A):** a source answers it with an explicit decision statement from someone with authority over that decision — record quote + claim ID; asking me is forbidden. A proposal, a lean, or a non-owner's reply does NOT settle it; code answers "what happens today", never "what should happen"; two conflicting sources are never "an answer" — source precedence (current ticket description / approved PRD decision > implementation sketch or comment > superseded design docs) picks the *recommended default*, never the resolution.
    - **Other-owned & independent:** the decision belongs to another ticket/team AND this spec does not depend on it — the ownership mapping requires a citation (a source stating it); route to `communications.md` as an FYI/chase item regardless of signals. Absent that citation, treat as critical.
    - **CRITICAL (the override — beats Gates B and C):** the decision is open, this spec depends on it, and ANY of these fire:
      - **(i)** a source explicitly poses it as an open question that this spec must resolve, and no later authoritative source settles it;
      - **(ii)** live sources genuinely conflict about what THIS feature should do (after precedence; factual discrepancies that bear on no decision are Phase 3b corrections, not questions);
      - **(iii)** it sets the feature's externally observable behavior AND either is expensive to reverse (schema, data already written under the decision, contracts other tickets build on) or its default would produce new user- or externally-visible effects that today's process does not produce (workflow-state writes, notifications, events to external systems, a change in who gets processed). Internal mechanics — trigger wiring, lazy record creation, retry policy, feature flags — never fire (iii) alone; a cheap-to-reverse default that degrades to today's status quo never fires (iii), UNLESS the status quo is itself the contested subject;
      - **(iv)** its default would take a NEW compliance/legal/product-policy position — one not already settled by me earlier in this run, by an approved PRD/governance source, or by existing production behavior. Parameterizing an already-settled position using an existing authoritative definition in the codebase, where the error direction is fail-safe, is NOT a new position (route to comms, stating the derivation); defaulting an edge population to today's status quo is not a policy position.
      The override is checked on the DECISION, not its parts: any sub-question or sub-decision derived from a critical decision inherits its criticality — no salami-slicing into "engineering" fragments.
      **Critical decisions ALWAYS come to me interactively.** Gate B may not absorb them as "engineering"; Gate C may not route them to `communications.md`; whether something blocks me is MY call, never yours — "to avoid blocking you" is never a reason. When the final answer is owned by a third party, the question names WHO owns it and WHERE to ask, includes a paste-ready draft, states the consequence if the eventual answer differs from the recommendation (naming the affected FRs — "minor rework" is not a consequence), and offers exactly three options: **(a)** I send the draft to the owner now (I also choose: hold the affected FR — recorded in `metadata.holds` — or descope it to a follow-up); **(b)** I set the interim decision myself; **(c)** I accept your recommended interim. Under (b)/(c) the spec records the decision as FINAL with the provenance tag `interim — final answer owned by <who> (C-n)`, and the C-n item carries the ask plus the consequence-if-different. An interim is a decision-made-once for this run: Phase 3b may present a genuinely changed premise once, but never silently flips an interim; the owner's real answer arriving mid-run is new information, presented once.
    - **Low-stakes third-party (Gate C):** the final answer belongs to a third party AND the item is low-stakes — reversible (config/copy/list-level rework), fail-safe (its default degrades to today's status quo), and not source-posed — route to `communications.md` with a recommended default AND the consequence if the eventual answer differs (nothing / contained rework / structural rework; an item whose consequence is structural rework is misrouted — reclassify as critical). The third party owns the FINAL answer; picking the interim is delegated to you only at this low-stakes tier. Never assume the third party is unavailable; routing here is justified by LOW STAKES, never by "not blocking".
    - **Engineering (Gate B):** engineering-level choices (which function, which code path, which pattern) that fire no override signal — decide autonomously from house patterns, log decision + rationale; they appear in the disposition table like everything else.
    **Zero surviving questions is a valid, good outcome — but only when the disposition table exists with every row cited.** Never manufacture questions to fill a quota.
13. Write all surviving questions to `01-discovery-questions.md` BEFORE asking any. Each question carries an **Evidence block**: every claim the question or its options rely on, listed as claim ID → 1–2 sentence verbatim quote (readable on its own) → clickable locator. **No naked facts** in the question or its options — every number/quote/behavioral statement carries its claim ID. Ask ONE at a time; yes/no format with an evidence-cited default ("**Default if unknown:** Yes — [PRD-3] because …") for normal questions; critical third-party-owned items use the fixed (a)/(b)/(c) format instead. When asking interactively: print the question's Evidence block in chat immediately BEFORE the ask, and append the claim IDs inside option descriptions. Critical questions count toward the 0–5 budget but are NEVER dropped for it — if criticals alone exceed 5, say plainly that the sources leave the feature underspecified, list them all, and ask whether to proceed through all of them or descope. Record answers in `02-discovery-answers.md` only after all are asked; update metadata.

### Phase 3: Targeted Context Gathering (autonomous)

14. Deep-dive the code paths the answers select: exact files to modify, precedent implementations, integration points, constraints, side-effect inventories. Document in `03-context-findings.md` under the Phase 1 evidence bars — every code fact with file:line, every uncertain claim tagged `[unverified]`.

### Phase 3b: Adversarial Verification (autonomous — the trust gate)

15. Before writing detail questions, fan out FRESH, context-isolated subagents that receive the claim and where to look — never the reasoning that produced it:
    - **Source re-verification:** every register claim (referenced by claim ID) re-checked against its source; the verbatim quote must match; anchor and attribution confirmed.
    - **Code re-derivation:** every file:line and behavioral claim in `03-context-findings.md` re-derived from the code by an agent that did not write it.
    - **Reverse-check (one per source):** what does this source require or constrain that the draft does NOT reflect? Triage every hit: in-scope (add it), owned elsewhere (map to the owning ticket), or a genuine question.
    - **Currency check:** re-verify every mutable fact from the Phase 0 snapshot (ticket/MR states) and timestamp the result.
16. Outcomes: failed claims corrected everywhere they appear; unverifiable claims quarantined as `[unverified]` with "the one fact that would settle it" — each becomes a question, a sandbox-verification request, or an explicit labeled assumption. Nothing `[unverified]` flows forward as fact.
17. **Decision-impact check:** for each answer I already gave, determine whether verification changed the premise it rested on. If yes, present the changed premise once — evidence, consequence, recommended new default — as new information, never as the old question re-asked. A held FR (override option (a)) is treated like an `[unverified]` claim: context gathering continues (the evidence sharpens the ask to the owner), no other FR may rest on it, and if verification changes the recommendation, update the paste-ready draft in its C-n item — open a new user round-trip only if the set of viable options flips.

### Phase 4: Expert Detail Questions (0–5, same machinery)

18. Open with a coverage DELTA table (new/changed nodes only) if Phase 3/3b added sources — full table instead on a resumed session. Then the same decision-disposition flow and criticality override as Phase 2, the same three gates, and the same evidence rules (Evidence block per question, no naked facts, Evidence block printed in chat before each ask, claim IDs in option descriptions, (a)/(b)/(c) format for critical third-party items). Questions must arise from VERIFIED findings, be phrased for a product manager (observable behavior, not code), asked one at a time. Write all to `04-detail-questions.md` before asking; record in `05-detail-answers.md` after all are asked.

### Phase 5: Requirements Specification

19. Write `06-requirements-spec.md` under the **output contract**:
    - **Exact section headings** (the /synthesize interface): Problem Statement, Solution Overview, Functional Requirements (FR-numbered), Technical Requirements, Implementation Hints, Acceptance Criteria — plus Assumptions and Out of Scope. Numbered headings are fine; the names are not negotiable.
    - **Decision-complete and final:** every requirement states ONE final decision. Banned anywhere in the file: revision narration ("correction", "superseded", "revised", "post-audit"), either/or options ("decide at implementation"), people-coordination content ("confirm with X", "pending", "FYI", ownership notes), open questions. **Sole exception:** the fixed provenance tag `interim — final answer owned by <who> (C-n)` on a user-decided interim; it marks pedigree, not an open item — the action lives in communications.md, and it never licenses /synthesize to wait or re-open. Defaults become decisions ONLY when I ratified them (explicitly, or via the question protocol); a model default alone never resolves an override-critical item. History lives only in the phase files (00–05, research-notes).
    - **Provenance per requirement:** each FR notes whether it is source-stated (claim ID + locator), user-decided (which answer), a user-decided interim (the tag above), or an autonomous engineering decision (with rationale). Code facts carry the file:line verified in Phase 3b. Claim IDs keep the chain question → decision → FR → source greppable.
    - **No FR may rest on an `[unverified]` claim.** Remaining unknowns become explicit Assumptions, each naming the fact that would settle it.
    - **Volatile-claim markers:** any FR/TR resting on the ticket-stated shape of an UNMERGED dependency (open MR, in-review schema or API) is marked `[volatile: <dependency>]` — it can only ever be as accurate as the dependency's ticket, and the merged code may diverge. /synthesize's staleness preflight re-derives every `[volatile]` claim from the merged code before implementing.
    - **Out of Scope:** every adjacent requirement discovered in reverse-checks mapped to its owning ticket — or, for a descoped critical, to its owner + communications item (C-n) — proof nothing was silently dropped.
    - **Prerequisites** (feature flags, migrations, keys, config) appear as explicit Technical Requirements rows so /synthesize surfaces them before implementation starts.
    - **Acceptance criteria** cover each trigger/path end-to-end — including data freshness/timing at trigger time (does the data the job reads exist and is it committed when the trigger fires?), failure paths, idempotency/redelivery, and the flag-off case.
    - **Holds:** while any `metadata.holds` entry has `resolution: null` (override option (a), pause variant), `06-requirements-spec.md` is NOT written and `phase` is NEVER set to "complete" — the run waits (resume path: I bring the owner's answer back in this session, or explicitly point a future run at this folder — e.g., "also read requirements/<folder>"; there is no automatic discovery of blocked runs), or I descope the held FR and the spec completes without it.
20. Write `communications.md` (sibling file; header: "NOT part of the spec; NOT input for /synthesize") holding every people-facing item: exact destination (channel/ticket/thread link), recipient, paste-ready text, the default that stands if unanswered, AND the consequence if the eventual answer differs (nothing / contained rework / structural rework — structural means it was misrouted; reclassify as critical). Only low-stakes items carry model-picked defaults; critical items appear here only as the record of MY (a)/(b)/(c) choice. Echo the full list in chat so I can act on it.
21. Append a **verification report** to `research-notes.md`: per source — claims extracted/verified counts; code claims re-derived; currency checks with timestamps; the decision disposition table (every row with its citation); the remaining `[unverified]` items and Assumptions. This is the trust dashboard.
22. Set metadata `"status": "complete"` and `"phase": "complete"` (never while a hold is unresolved). Announce completion in chat with: the communications list (each item with its consequence label), every interim decision (owner + C-n), every held/descoped FR, the Assumptions, anything that blocked verification, and every source excluded as out-of-scope or inaccessible (with the reasoning / my Phase 0 decision) — nothing gets dropped silently.

## Question Format (both question phases)

```
## Q2: When an invoice was already disputed by the customer, should the automation skip it instead of retrying the charge?
**Why the sources don't answer this:** ticket §Proposed flow and PRD §Retry policy define the happy path only; searched Slack threads for "disputed" — only the dispute-notification email is discussed (SLK-6).
**Default if unknown:** Yes — skip (a dispute freezes the invoice for manual review [CODE-4][SLK-6]; retrying the charge would interfere with an open case)
**Evidence:**
- **CODE-4** — a dispute stamps `disputed_by`/`disputed_at` and notifies the billing team — `billing/handlers/invoice_dispute.ex:26-37`
- **SLK-6** — "the billing team is alerted whenever a customer disputes a charge … reviewed case by case" — <author>, #<team-channel>, <date> (permalink) — via PRD §Dispute handling
```

Critical third-party-owned format:

```
## Q3 (CRITICAL — third-party-owned): Who gets notified when an order fails the eligibility check, and how?
**Why this comes to you despite ownership:** source-posed open question [LIN-812-8] + conflicting sources [LIN-640-1 says notify the customer] — never resolved by a model default.
**Owner:** <PM name> — TICKET-812 comment or #<project-channel> (link)
**Paste-ready draft:** "…"
**Consequence if the eventual answer differs from the recommendation:** FR-3 (notification target) and FR-5 (status write) change; no data/schema rework.
**Options:** (a) you send the draft to the PM now — FR-3 held (run pauses at Phase 5) or descoped, your pick; (b) you set the interim; (c) accept recommended interim: notify the ops team via the review-dashboard status [CODE-17], no customer email — [LIN-812-8][SLK-3]
**Evidence:** …
```

## Important Rules

- ONLY yes/no questions, ONE at a time, all written to file before any is asked — **exception:** criticality-override items with a third-party owner use the fixed (a)/(b)/(c) format above, still one at a time, still written to file first, still carrying an Evidence block and a recommended option
- Every default cites its evidence; every question justifies why sources don't answer it
- Zero questions is valid ONLY with a fully-cited decision disposition table — never pad to a quota (5 is a maximum, not a target; criticals are never dropped for the cap)
- The coverage checkpoint is not a question: no Evidence block, no budget impact, not in the question files
- Stay at requirements level (no implementation)
- Use actual file paths and component names in the detail phase
- Use whatever tools are available; if a preferred tool is missing, use equivalents — never skip a step because a tool is unavailable

## Files & the /synthesize Interface (do not break)

- Folder: `requirements/YYYY-MM-DD-HHMM-[slug]/`
- Files: `00-initial-request.md`, `01-discovery-questions.md`, `02-discovery-answers.md`, `03-context-findings.md`, `04-detail-questions.md`, `05-detail-answers.md`, `06-requirements-spec.md`, `metadata.json`, `research-notes.md`, `communications.md`
- /synthesize reads: `metadata.json` (needs `"status": "complete"`, `contextFiles`, `relatedFeatures`, `holds`), `06-requirements-spec.md` (the section names above, FR/TR numbering), `03-context-findings.md`, and `research-notes.md` (currency snapshot + verification report for its preflight). Everything else is free-form. `communications.md` is never spec input.

## Metadata Structure

```json
{
  "id": "feature-slug",
  "started": "ISO-8601-timestamp",
  "lastUpdated": "ISO-8601-timestamp",
  "status": "active | complete | incomplete",
  "phase": "discovery|context|detail|verification|complete",
  "progress": {
    "discovery": { "answered": 0, "total": 0 },
    "detail": { "answered": 0, "total": 0 }
  },
  "contextFiles": ["paths/of/files/analyzed"],
  "relatedFeatures": ["similar features found"],
  "sources": { "linear": [], "notion": [], "slack": [], "gitlab": [] },
  "verification": { "lastRun": null, "sourceClaimsVerified": 0, "codeClaimsVerified": 0, "unverified": 0 },
  "holds": []
}
```

`holds` entries: `{ "comm": "C-3", "owner": "compliance (@who)", "askedAt": "ISO-8601", "heldFRs": ["FR-4"], "resolution": null }` with `resolution` ∈ `null | "answered" | "interim" | "descoped:<ticket>"`. **`status`/`phase` may never be set to "complete" while any hold has `resolution: null`.** Set `"status": "complete"` at the end of Phase 5 — /synthesize keys on it.

## Phase Transitions

- **Re-ground at every boundary:** before starting each phase — and whenever resuming a run or continuing after the conversation has been summarized/compacted — re-read this file (`~/.claude/commands/requirements-start.md`): the Non-negotiable principles plus the full section of the phase about to start; before Phases 2 and 4 also the Question Format and Important Rules sections, before Phase 5 the output contract. Never run a phase from memory of these rules — a long investigation pushes this text too far back in context to trust recall, and after compaction it is gone entirely. /requirements-remind prints the compressed rule card on demand; this file stays authoritative.
- After each phase, announce: "Phase complete. Starting [next phase]..."
- Save all work before moving on; progress is checkable anytime with /requirements-status
- Phases 0, 1, 3, 3b are autonomous — no user interaction beyond Phase 0's hard stops; Phases 2 and 4 are the interactive ones (each opens with the coverage checkpoint / delta table, then questions); Phase 5 is autonomous unless a hold (override option (a)) pauses the run there
- No question may share a message with the coverage table; my confirmation (when the table is not all-green) precedes Q1
