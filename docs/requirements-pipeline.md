# The requirements pipeline

End-to-end flow:

```
/refine-ticket (optional, upstream)
      → /requirements-start … /requirements-end   (gathering)
      → /synthesize                               (implementation)
      → /requirements-retro                       (feedback loop, when a run's findings are challenged)
```

## Design principles

- **Written sources are authoritative.** The ticket, its linked tickets, PRD/Notion pages, Slack threads, and MRs are exhausted and verified before the user's time is spent. Every fact in the output traces to a source quote, a code location, or an explicit decision; everything else is a labeled assumption.
- **A phase's file IS the phase.** `requirements-start.md` is only a router. Each phase is executed by reading its file under `~/.claude/requirements-phases/` at the moment of use — never from memory or a summary. This keeps the rules present when they are applied, and survives resumes and context compaction.
- **Gate discipline.** Every phase ends by appending an evidence-carrying gate block to `gates.md` in the run folder (locations, tool results, counts with the command that computed them). No phase begins until the previous gate exists and is filled. `gates.md` doubles as the resume pointer.
- **Provenance everywhere.** Every fact carries a claim ID resolving to the register in `research-notes.md`, tagged `[stated]` / `[inferred]` / `[absent]`. Anything the model originates is a `[model proposal — no source]` entry dispositioned as its own decision. Door-closing claims ("we can't deliver X") are guilty until proven and go through the Phase 3b refutation pass.
- **Interaction contract.** Interactive phases ask ONLY yes/no questions (critical third-party items use a fixed (a)/(b)/(c) format), one at a time, all written to file before any is asked, each with an evidence-cited default, five per phase maximum — criticals are never dropped for the cap. Zero questions is valid only with a fully-cited disposition table.

## Phases

| Phase | File | Job |
|---|---|---|
| 0 — Source inventory | `phase-0-sources.md` | Breadth-first crawl of the ticket's source graph plus a search sweep of every connected system; connector preflight; creates the run folder, `metadata.json`, `gates.md`, and the source-claims register. |
| 1 — Codebase analysis | `phase-1-code.md` | Maps hook points, precedent features, and house patterns via evidence-returning subagents; defines the four evidence bars (static / behavioral / absence / literal). |
| 2 — Discovery questions | `phase-2-questions.md` | Coverage checkpoint, decision disposition table (source-settled / other-owned / criticality override / low-stakes / engineering), pre-ask provenance audit, then the questions. |
| 3 — Targeted context | `phase-3-context.md` | Deep-dives the code paths the discovery answers selected, under Phase 1's evidence bars. |
| 3b — Adversarial verification | `phase-3b-verify.md` | The trust gate: seven passes — refutation of door-closing claims, source re-check, code re-derivation, cross-source conflicts, per-source reverse-check, currency, arithmetic reconciliation. |
| 4 — Expert detail questions | `phase-2-questions.md` (its "Phase 4 variant" section) | Delta coverage table; questions must arise from verified findings. |
| 5 — Spec & communications | `phase-5-output.md` | The `06-requirements-spec.md` output contract (the `/synthesize` interface) plus `communications.md` for people-facing items. |
| any | `drafts-contract.md` | Cross-cutting rules for every paste-ready human-facing draft. |

## Run folder contract

`requirements/YYYY-MM-DD-HHMM-[slug]/` in the **target project's** working directory (gitignore it there), containing: `00-initial-request.md`, `01-discovery-questions.md`, `02-discovery-answers.md`, `03-context-findings.md`, `04-detail-questions.md`, `05-detail-answers.md`, `06-requirements-spec.md`, `metadata.json`, `research-notes.md`, `communications.md`, `gates.md`. `requirements/.current-requirement` points at the active run. Every run starts fresh — prior run folders are never read.

## The /synthesize interface (do not break)

- Reads: `metadata.json` (needs `"status": "complete"`, `contextFiles`, `relatedFeatures`, `holds` — never complete while any hold has `resolution: null`), `06-requirements-spec.md`, `03-context-findings.md`, and `research-notes.md` (currency snapshot + verification report, for its staleness preflight).
- The spec's section names are parsed and are not negotiable: **Problem Statement, Solution Overview, Functional Requirements (FR-numbered), Technical Requirements, Implementation Hints, Acceptance Criteria, Assumptions, Out of Scope.**
- `communications.md` and `gates.md` are never spec input.
- Outputs implementation plan/todo/notes under `[run]/implementation/` and implements to ship-ready state, ending with a four-section report (Needs you now / Yours by design / Deviations from spec / Done & verified).

## The feedback loop

`/requirements-retro` runs when a finished run's findings are challenged: it verifies the counter-claims like any other claim, identifies the mechanism of each confirmed miss (enforcement miss vs spec gap, which gate line should have caught it), and appends ≤3-line lessons to `implementation/requirements-lessons.md` — found by walking up from the repo — which Phase 0 and Phase 3b load as **binding** on future runs. It proposes phase-file edits in chat but never applies them, and never rewrites a finished run's artifacts.
