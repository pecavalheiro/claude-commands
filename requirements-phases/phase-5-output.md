# Phase 5 — Requirements Specification & Communications

This file IS the phase — read it fully before running Phase 5. First verify Gate 4 exists in `gates.md` with every line filled; if not, go back. Also read `~/.claude/requirements-phases/drafts-contract.md` before writing `communications.md` or touching any paste-ready draft.

## Holds

While any `metadata.holds` entry has `resolution: null` (override option (a), pause variant), `06-requirements-spec.md` is NOT written and `phase` is NEVER set to "complete" — the run waits (resume path: I bring the owner's answer back in this session, or explicitly point a future run at this folder; there is no automatic discovery of blocked runs), or I descope the held FR and the spec completes without it.

## `06-requirements-spec.md` — the output contract

- **Exact section headings** (the /synthesize interface): Problem Statement, Solution Overview, Functional Requirements (FR-numbered), Technical Requirements, Implementation Hints, Acceptance Criteria — plus Assumptions and Out of Scope. Numbered headings are fine; the names are not negotiable.
- **Decision-complete and final:** every requirement states ONE final decision. Banned anywhere in the file: revision narration ("correction", "superseded", "revised", "post-audit"), either/or options ("decide at implementation"), people-coordination content ("confirm with X", "pending", "FYI", ownership notes), open questions. **Sole exception:** the fixed provenance tag `interim — final answer owned by <who> (C-n)` on a user-decided interim; it marks pedigree, not an open item — the action lives in communications.md, and it never licenses /synthesize to wait or re-open. Defaults become decisions ONLY when I ratified them (explicitly, or via the question protocol); a model default alone never resolves an override-critical item. History lives only in the phase files (00–05, research-notes).
- **Provenance per requirement:** each FR notes whether it is source-stated (claim ID + locator), user-decided (which answer), a user-decided interim (the tag above), or an autonomous engineering decision (with rationale). Code facts carry the file:line verified in Phase 3b. Claim IDs keep the chain question → decision → FR → source greppable.
- **Per-row provenance:** a citation covers exactly the sentences and rows it names. Any table or field mapping whose content comes from more than one source — or partly from user decisions or model proposals — carries a provenance tag PER ROW; a blanket "source-stated" over a table is valid only if the cited source states every row. A row with no provenance does not ship.
- **No FR may rest on an `[unverified]` claim.** Remaining unknowns become explicit Assumptions, each naming the fact that would settle it.
- **Volatile-claim markers:** any FR/TR resting on the ticket-stated shape of an UNMERGED dependency (open MR, in-review schema or API) is marked `[volatile: <dependency>]` — it can only ever be as accurate as the dependency's ticket, and the merged code may diverge. /synthesize's staleness preflight re-derives every `[volatile]` claim from the merged code before implementing.
- **Out of Scope:** every adjacent requirement discovered in reverse-checks mapped to its owning ticket — or, for a descoped critical, to its owner + communications item (C-n) — proof nothing was silently dropped.
- **Prerequisites** (feature flags, migrations, keys, config) appear as explicit Technical Requirements rows so /synthesize surfaces them before implementation starts.
- **Acceptance criteria** cover each trigger/path end-to-end — including data freshness/timing at trigger time (does the data the job reads exist and is it committed when the trigger fires?), failure paths, idempotency/redelivery, and the flag-off case.

## `communications.md`

Sibling file; header: "NOT part of the spec; NOT input for /synthesize". It holds every people-facing item: exact destination (channel/ticket/thread link), recipient, paste-ready text (written under the drafts contract), the default that stands if unanswered, AND the consequence if the eventual answer differs (nothing / contained rework / structural rework — structural means it was misrouted; reclassify as critical and go back through the question protocol). Only low-stakes items carry model-picked defaults; critical items appear here only as the record of MY (a)/(b)/(c) choice. Echo the full list in chat so I can act on it.

## Final provenance audit — mandatory, before showing me anything

Same design as the pre-ask audit: ONE fresh subagent, given ONLY the register section of `research-notes.md`, `06-requirements-spec.md`, and `communications.md` — never your reasoning. It returns findings in these categories: naked facts; unresolvable IDs; quote-support mismatches (including scope transfers); attribution mismatches; per-row provenance violations (rows a blanket citation does not actually cover); `[unverified]` content stated as fact anywhere — above all inside paste-ready drafts; run-internal labels (Q/FR/C-n numbers, claim IDs, "the spec") inside paste-ready text. Fix every finding; record the report + fixes in `research-notes.md`.

## Verification report (append to `research-notes.md`)

Per source — claims extracted/verified counts (the Phase 3b COMPUTED numbers, pasted, never re-typed from memory); code claims re-derived; currency checks with timestamps; the decision disposition table (every row with its citation); the remaining `[unverified]` items and Assumptions. This is the trust dashboard, and its numbers come from the arithmetic pass or they do not go in.

## Completion

Set metadata `"status": "complete"` and `"phase": "complete"` (never while a hold is unresolved). Announce completion in chat with: the communications list (each item with its consequence label), every interim decision (owner + C-n), every held/descoped FR, the Assumptions, anything that blocked verification, and every source excluded as out-of-scope or inaccessible (with the reasoning / my Phase 0 ruling) — nothing gets dropped silently.

## Gate 5 — append to `gates.md`

```
## Gate 5 — output (<timestamp>)
- holds: <"none open", or the list that blocked completion>
- spec: section headings verified against the contract; banned-word scan: <command + result>
- per-row provenance: <how checked + result>
- final provenance audit: report at <location>; <N> findings, each resolved
- communications: <N> items, each with destination + consequence label; drafts contract applied per draft
- verification report appended: <location>; metadata verification numbers = computed numbers (<show both>)
- completion announced in chat
```

**The run is complete.** If I later report that a finding from this run was wrong, run `/requirements-retro` — it verifies the miss, distills the lesson into the journal, and future Phase 0/3b reads it.
