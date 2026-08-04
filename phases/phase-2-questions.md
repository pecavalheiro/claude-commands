# Phases 2 & 4 — Coverage Checkpoint, Decision Disposition & Questions

This file IS the phase — read it fully before running Phase 2, and read it AGAIN before running Phase 4 (the variant section at the end lists what changes). First verify the previous gate in `gates.md` (Gate 1 for Phase 2; Gate 3b for Phase 4); if it is missing or has unfilled lines, go back.

Binding principles for these phases:

- **My time is the scarcest resource.** Every question must survive the gates below.
- **Sources answer first.** Before asking me anything, search the register and the code. If a sentence in the ticket/PRD/Slack answers it, record it with the quote and move on. Asking me something the sources already answer is forbidden. The inverse also holds: a question a source explicitly poses is never resolved by a model-picked default — it is settled by an authoritative source, decided by me, or its FR is descoped.
- **Decisions are made once.** Once I answer (even indirectly), record it and never re-present that decision — no rewording, no "just to confirm". If later verification changes the premise under my answer, present the changed premise once, with evidence and a recommended default; do not re-ask the question.
- **Delete, don't reframe.** When I say a topic is out of scope or owned elsewhere, remove it from every working document. Repeated pushback on the same item means remove, not refine.

## 1. Source-coverage checkpoint (opens the interactive phase)

**Build the table from the register, never from memory.** Every row is derived from a register entry, and a row's status is whatever that entry's `status:`/`fetched_via:` record proves. A checkpoint printed from recall is invalid; if the register says `pending`, the table says `pending`.

Present a one-screen table: every source-graph node — source, type, fetch status (**fully read** / **partially read + what's missing** / **excluded + why**), claims extracted, links found in it — plus every Phase 0 flag shown WITH my prior ruling inline ("excluded — your Phase 0 call"; rulings are context, never re-asked). Statuses are honest: "excluded" applies only to sources FETCHED and then judged out of scope; an unfetched node is only ever "pending" or "inaccessible" (and inaccessible already hard-stopped in Phase 0 — the table records my ruling, it does not substitute for the STOP). "Unread" means pending OR partial.

The table ends with three lines:

1. "Graph closed — last link sweep added 0 nodes."
2. The search-sweep summary: each system searched, the exact queries, hits added.
3. **The unlinked-sources ask — always asked, even when the table is all-green:** "Is there any Slack thread, document, or conversation relevant to this work that is not linked from any written source and did not surface in the searches above?" Traversal and search can only reach what is written down or indexed; this question is the only path to what isn't. WAIT for my answer. It is part of the checkpoint — no Evidence block, no budget impact, not written to the question files.

If I name a missing source: announce "Coverage amended — re-entering Phase 0 for <source>", run the Phase 0 steps for that node only (its claims join the register and get Phase 3b verification like any other), then re-present a delta table and wait once more. Questions asked while a known source is pending or partial (without my explicit ruling on that specific gap) are invalid. Answers I already gave stand even if a coverage gap surfaces later — the changed-premise protocol applies; never re-ask. On any RESUMED session (continuing after an interruption or compaction), present the FULL table before the session's first interactive ask, whatever the phase. Append the confirmed table to `research-notes.md` with a timestamp. No question may share a message with the coverage table.

## 2. Decision disposition — the criticality override

Work at the level of DECISIONS, not questions: a critical decision that is never drafted as a question must still be dispositioned. Collect every decision this spec must bake in — every `[absent]`-provenance item and every open-question register entry — into a **decision disposition table** (kept in `research-notes.md`, summarized in the phase announcement). Each row: decision → disposition + citation. Dispositions, evaluated in this order:

- **Source-settled (Gate A):** a source answers it with an explicit decision statement from someone with authority over that decision — record quote + claim ID; asking me is forbidden. A proposal, a lean, or a non-owner's reply does NOT settle it; code answers "what happens today", never "what should happen"; two conflicting sources are never "an answer" — source precedence (current ticket description / approved PRD decision > implementation sketch or comment > superseded design docs) picks the *recommended default*, never the resolution. **A decision may not be both source-settled and one side of a live conflict: if a later row of the table (or a Phase 3b finding) declares a conflict over the same quote, the Gate A row is reopened and re-dispositioned — the table must never hold both.**
- **Other-owned & independent:** the decision belongs to another ticket/team AND this spec does not depend on it — the ownership mapping requires a citation (a source stating it); route to `communications.md` as an FYI/chase item regardless of signals. Absent that citation, treat as critical.
- **CRITICAL (the override — beats Gates B and C):** the decision is open, this spec depends on it, and ANY of these fire:
  - **(i)** a source explicitly poses it as an open question that this spec must resolve, and no later authoritative source settles it;
  - **(ii)** live sources genuinely conflict about what THIS feature should do (after precedence; factual discrepancies that bear on no decision are Phase 3b corrections, not questions);
  - **(iii)** it sets the feature's externally observable behavior AND either is expensive to reverse (schema, data already written under the decision, contracts other tickets build on) or its default would produce new user- or externally-visible effects that today's process does not produce (workflow-state writes, notifications, events to external systems, a change in who gets processed). Internal mechanics — trigger wiring, lazy record creation, retry policy, feature flags — never fire (iii) alone; a cheap-to-reverse default that degrades to today's status quo never fires (iii), UNLESS the status quo is itself the contested subject. **Dropping or downgrading a capability a source explicitly requested because we could not verify it always fires (iii)** — it comes to me with the honest reason (*unconfirmed*, not *impossible*) and the strongest feasibility case; a pre-decided fallback never absorbs it autonomously, and "consequence" here is measured in product/stakeholder terms, not code-reversibility;
  - **(iv)** its default would take a NEW compliance/legal/product-policy position — one not already settled by me earlier in this run, by an approved PRD/governance source, or by existing production behavior. Parameterizing an already-settled position using an existing authoritative definition in the codebase, where the error direction is fail-safe, is NOT a new position (route to comms, stating the derivation); defaulting an edge population to today's status quo is not a policy position.
  The override is checked on the DECISION, not its parts: any sub-question or sub-decision derived from a critical decision inherits its criticality — no salami-slicing into "engineering" fragments.
  **Critical decisions ALWAYS come to me interactively.** Gate B may not absorb them as "engineering"; Gate C may not route them to `communications.md`; whether something blocks me is MY call, never yours — "to avoid blocking you" is never a reason. When the final answer is owned by a third party, the question names WHO owns it and WHERE to ask, includes a paste-ready draft (written under `~/.claude/requirements-phases/drafts-contract.md` — read it before drafting), states the consequence if the eventual answer differs from the recommendation (naming the affected FRs — "minor rework" is not a consequence), and offers exactly three options: **(a)** I send the draft to the owner now (I also choose: hold the affected FR — recorded in `metadata.holds` — or descope it to a follow-up); **(b)** I set the interim decision myself; **(c)** I accept your recommended interim. Under (b)/(c) the spec records the decision as FINAL with the provenance tag `interim — final answer owned by <who> (C-n)`, and the C-n item carries the ask plus the consequence-if-different. An interim is a decision-made-once for this run: Phase 3b may present a genuinely changed premise once, but never silently flips an interim; the owner's real answer arriving mid-run is new information, presented once.
- **Low-stakes third-party (Gate C):** the final answer belongs to a third party AND the item is low-stakes — reversible (config/copy/list-level rework), fail-safe (its default degrades to today's status quo), and not source-posed — route to `communications.md` with a recommended default AND the consequence if the eventual answer differs (nothing / contained rework / structural rework; an item whose consequence is structural rework is misrouted — reclassify as critical). Never assume the third party is unavailable; routing here is justified by LOW STAKES, never by "not blocking".
- **Engineering (Gate B):** engineering-level choices (which function, which code path, which pattern) that fire no override signal — decide autonomously from house patterns, log decision + rationale; they appear in the disposition table like everything else.

**Zero surviving questions is a valid, good outcome — but only when the disposition table exists with every row cited.** Never manufacture questions to fill a quota.

## 3. Inventions — the bundling ban

Every artifact name, field, tag, value, or mechanism that appears in a question, an option, or a draft must resolve to a claim ID. When YOU originate something no source asked for (a tag, a field, a fallback, a naming scheme, a status), it is a **model proposal**: register it as `[model proposal — no source]` with its rationale, give it its own disposition row, and assess its criticality as if a source had posed it — a new externally-visible artifact (anything written to a user-facing surface or an external system) fires override (iii) and comes to me as its OWN decision. **Bundling a proposal inside another question's option is forbidden** — ratifying an option must never silently ratify an invention riding in it.

## 4. Writing and asking questions

Write all surviving questions to the question file (`01-discovery-questions.md` for Phase 2, `04-detail-questions.md` for Phase 4) BEFORE asking any. Each question carries an **Evidence block**: every claim the question or its options rely on, listed as claim ID → 1–2 sentence verbatim quote (readable on its own) → clickable locator. **No naked facts** in the question or its options — every number/quote/behavioral statement carries its claim ID.

Ask ONE at a time; yes/no format with an evidence-cited default ("**Default if unknown:** Yes — [PRD-3] because …") for normal questions; critical third-party-owned items use the fixed (a)/(b)/(c) format instead. When asking interactively: print the question's Evidence block in chat immediately BEFORE the ask, and append the claim IDs inside option descriptions. Critical questions count toward the 0–5 budget but are NEVER dropped for it — if criticals alone exceed 5, say plainly that the sources leave the feature underspecified, list them all, and ask whether to proceed through all of them or descope.

Question format (fictional examples):

```
## Q2: When an invoice was already disputed by the customer, should the automation skip it instead of retrying the charge?
**Why the sources don't answer this:** the ticket's 'Proposed flow' and the PRD's 'Retry policy' sections define the happy path only; searched Slack threads for "disputed" — only the dispute-notification email is discussed (SLK-6).
**Default if unknown:** Yes — skip (a dispute freezes the invoice for manual review [CODE-4][SLK-6]; retrying the charge would interfere with an open case)
**Evidence:**
- **CODE-4** — a dispute stamps `disputed_by`/`disputed_at` and notifies the billing team — `billing/handlers/invoice_dispute.ex:26-37`
- **SLK-6** — "the billing team is alerted whenever a customer disputes a charge … reviewed case by case" — <author>, #<team-channel>, <date> (permalink) — via the PRD's 'Dispute handling' section
```

Critical third-party-owned format:

```
## Q3 (CRITICAL — third-party-owned): Who gets notified when an order fails the eligibility check, and how?
**Why this comes to you despite ownership:** source-posed open question [LIN-812-8] + conflicting sources [LIN-640-1 says notify the customer] — never resolved by a model default.
**Owner:** <PM name> — TICKET-812 comment or #<project-channel> (link)
**Paste-ready draft:** "…" — written under the drafts contract
**Consequence if the eventual answer differs from the recommendation:** FR-3 (notification target) and FR-5 (status write) change; no data/schema rework.
**Options:** (a) you send the draft to the PM now — FR-3 held (run pauses at Phase 5) or descoped, your pick; (b) you set the interim; (c) accept recommended interim: notify the ops team via the review-dashboard status [CODE-17], no customer email — [LIN-812-8][SLK-3]
**Evidence:** …
```

## 5. Pre-ask provenance audit — mandatory, before the first question is asked

Spawn ONE fresh subagent. It receives exactly two inputs: the register section of `research-notes.md`, and the drafted question file. Never your reasoning, never the conversation. It returns findings in five categories:

1. **Naked facts** — any number, identifier, or behavioral statement in a question/option/draft with no claim ID.
2. **Unresolvable IDs** — cited IDs with no register entry.
3. **Quote-support mismatches** — sentences whose cited quote does not actually say what the sentence says, including scope transfers (the quote is about one field/case/population; the sentence generalizes to another).
4. **Attribution mismatches** — names in questions/drafts vs. the register's author fields.
5. **Unregistered inventions** — content in options that exists in no register entry (the bundling ban, section 3 above).

Fix every finding before the first ask (register + disposition what it caught, or delete it); record the audit report and the fixes in `research-notes.md`. This audit is cheap, and it catches exactly the class of failure that otherwise reaches me looking confident.

## 6. Recording

Record answers in `02-discovery-answers.md` (Phase 2) / `05-detail-answers.md` (Phase 4) only after all questions are asked; update metadata progress.

## Phase 4 variant (Expert Detail Questions)

Everything above applies, with these deltas:

- Open with a coverage DELTA table (new/changed nodes only) if Phase 3/3b added sources — full table instead on a resumed session. The unlinked-sources ask is repeated only if new sources entered the graph since Phase 2.
- Questions must arise from VERIFIED findings (Gate 3b), be phrased for a product manager (observable behavior, not code — actual file paths allowed where they help me locate things).
- Files: `04-detail-questions.md` / `05-detail-answers.md`.

## Gate 2 / Gate 4 — append to `gates.md`

```
## Gate 2 — discovery questions (<timestamp>)     [or: Gate 4 — detail questions]
- checkpoint: presented <timestamp>; confirmed by user or all-green; unlinked-sources ask answered: "<the answer>"  [Phase 4: delta table or "no new sources"]
- disposition table: <N> rows, every row cited — <location>
- inventions: <each model proposal registered + dispositioned, or "none">
- provenance audit: report at <location>; <N> findings, each resolved
- questions: <n> asked of <budget>; criticals: <list or "none">; zero-questions justification if applicable
- answers recorded: <file>; metadata updated
```

**Then: Phase 2 → announce and read `~/.claude/requirements-phases/phase-3-context.md`. Phase 4 → announce and read `~/.claude/requirements-phases/phase-5-output.md`.**
