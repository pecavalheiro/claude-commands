# Start Requirements Gathering

Begin gathering requirements for: $ARGUMENTS
ultrathink: Deep analysis of the problem space and its implications

The input is typically a Linear ticket (sometimes a document link or a written request). The written sources — the ticket, its linked tickets, the PRD/Notion pages, Slack threads, MRs — are authoritative. Exhaust and verify them before spending my time; every question you ask me must have survived the gates in the phase files. Every fact in the output must be traceable to a source quote, a code location, or an explicit decision; everything else is an assumption and must be labeled as one.

## The one rule that carries everything

This file is only the map. The rules live in per-phase files, and **a phase's file IS the phase**: you may not begin, resume, or continue a phase without having Read its file top to bottom in this session, after the previous phase's gate was appended. Never run a phase from memory, from a summary, or from recall of a previous run — recall decays and the files change. This is not a reminder to be diligent; it is the mechanism that makes the rules present at the moment they are applied. After ANY interruption, resume, or context compaction: read `gates.md` in the run folder to locate the run, then re-read this file and the current phase's file before the next action.

| Phase | File (read at the moment of use — never all upfront) |
|---|---|
| 0 — Source inventory & extraction | `~/.claude/requirements-phases/phase-0-sources.md` |
| 1 — Codebase analysis | `~/.claude/requirements-phases/phase-1-code.md` |
| 2 — Coverage checkpoint & discovery questions | `~/.claude/requirements-phases/phase-2-questions.md` |
| 3 — Targeted context | `~/.claude/requirements-phases/phase-3-context.md` |
| 3b — Adversarial verification | `~/.claude/requirements-phases/phase-3b-verify.md` |
| 4 — Expert detail questions | `phase-2-questions.md` again — its 'Phase 4 variant' section |
| 5 — Spec & communications | `~/.claude/requirements-phases/phase-5-output.md` |
| People-facing text, any phase | `~/.claude/requirements-phases/drafts-contract.md` |

## Gate discipline

Every phase file ends with a gate block: a fixed checklist appended to `gates.md` in the run folder, every line carrying evidence — a location, a tool result, a count WITH the command that computed it. **No phase begins until the previous gate block exists and every line is filled.** A gate line you cannot fill is a phase you have not finished — go back and finish it. Counts are always computed (grep/wc, command shown), never recalled. `gates.md` doubles as the resume pointer.

## Always-on principles (each phase file carries the ones it enforces in detail)

1. **Never proceed blind.** A source that cannot be fetched is a hard STOP — ask me (fix access / skip / abort) the moment the failure is confirmed; no further phase work, subagents included, while it is pending. Partial context produces wrong specs.
2. **Decisions are made once.** Once I answer (even indirectly), record it and never re-present it. A changed premise is presented once, with evidence, as new information — never as the old question re-asked.
3. **Delete, don't reframe.** Out of scope means removed from every working document; repeated pushback on the same item means remove, not refine.
4. **Evidence, not verdicts, from subagents.** Read the evidence and conclude yourself; a subagent hedge is a cue to verify, not to trust.
5. **No naked facts, no invention.** Every fact carries a claim ID resolving to the register. Anything YOU originate is a `[model proposal — no source]` register entry, dispositioned as its own decision — never bundled inside another question's option.
6. **Requirements only.** No code changes, no fixture edits, nothing fabricated; stay at requirements altitude until /synthesize.

## Execution model

You (the orchestrator) run all phases and all user interaction. The mechanical work inside the autonomous phases (0, 1, 3, 3b) fans out to FRESH subagents exactly as the phase files direct — extraction, code tracing, verification, audits. Verifiers and auditors are ALWAYS fresh-context subagents: they receive the claim or goal and where to look, never the reasoning that produced it. Use whatever tools are available; if a preferred tool is missing, use equivalents — never skip a step because a tool is unavailable.

Interactive phases (2 and 4): ONLY yes/no questions (critical third-party items use the fixed (a)/(b)/(c) format), ONE at a time, all written to file before any is asked, each with an evidence-cited default; 5 per phase maximum — criticals are never dropped for the cap; zero questions is valid only with a fully-cited disposition table.

## Files & the /synthesize interface (do not break)

- Folder: `requirements/YYYY-MM-DD-HHMM-[slug]/`
- Files: `00-initial-request.md`, `01-discovery-questions.md`, `02-discovery-answers.md`, `03-context-findings.md`, `04-detail-questions.md`, `05-detail-answers.md`, `06-requirements-spec.md`, `metadata.json`, `research-notes.md`, `communications.md`, `gates.md`
- /synthesize reads: `metadata.json` (needs `"status": "complete"`, `contextFiles`, `relatedFeatures`, `holds`), `06-requirements-spec.md` (the exact section names, FR/TR numbering), `03-context-findings.md`, and `research-notes.md` (currency snapshot + verification report for its preflight). `communications.md` and `gates.md` are never spec input. The metadata structure is defined in `phase-0-sources.md`; `status`/`phase` may never be "complete" while any hold has `resolution: null`.

## Phase transitions

- After each gate: announce "Phase N complete (gate appended). Starting <next>..." — then read the next phase file.
- /requirements-remind prints the compressed rule card on demand; /requirements-status locates a run. The phase files stay authoritative over both.

**Begin now: read `~/.claude/requirements-phases/phase-0-sources.md`.**
