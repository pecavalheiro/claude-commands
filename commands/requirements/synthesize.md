# Synthesize Requirements into Implementation

Analyzes completed requirements, generates a detailed implementation plan with tracked todo steps, then implements it to a ship-ready state.

## Principles (apply throughout)

1. **The spec is final.** `06-requirements-spec.md` is decision-complete: implement every FR/TR as written. Do not re-open, re-litigate, or "defer" spec items. A deviation is allowed only for a BLOCKER whose mechanism you have verified to /deep-review evidence standards (traced to its defining source, not hypothesized — "risks X" without proof is not a blocker). Every deviation is logged in implementation-notes AND appears in the final report's "Needs you now" section — never as an optional menu item.
2. **Never end in a broken state.** Broken tests, lint/format complaints, unregenerated snapshots, or anything not ready to ship is not an acceptable stopping point — fixing what the diff-wide checks surface IS the implementation work, not a follow-up. The only exception: a failure verified to be pre-existing (reproduced on the base branch without your changes) or caused by an external outage — that is reported as a blocker with the evidence.
3. **Work incrementally, always green.** Test-supported development (TDD where sensible): each task lands together with its tests, and the task's targeted tests + formatter/linter for the touched files pass before the next task starts. The working tree is never left failing between tasks. The end-of-run gate CONFIRMS health; it must never be where problems are discovered.
4. **New decisions were the requirements phase's job.** Do not ask the user to decide anything mid-flight unless a verified premise change (preflight or in-task discovery) forces it — then ask ONCE, with evidence, options, and a recommendation, and record the answer in implementation-notes.

## Instructions

When the user runs the `synthesize` command:

1. **Resolve the Requirements Run**
   - Derive `<repo>` and this workspace (recipe in requirements-start.md's Files section: remote basename → only remote → toplevel dir name; an empty key is an error, and outside a git repository stop with "not inside a git repository — the run store is keyed by repo"). The bucket is `~/.claude/runs/<repo>/requirements/`; run folders use the timestamp format (YYYY-MM-DD-HHMM-*)
   - Take the FIRST of these that yields a qualifying run: (1) an explicit argument — a run name/path, or a worktree reference (name or full path) matched against each run's metadata `worktree.path`, then `workspace` (most recent qualifying run on a tie); (2) this workspace's pointer file (`.pointers/<workspace-slug>`, valid only if its second line equals this workspace's toplevel); (3) the most recent qualifying run whose metadata `workspace` contains this workspace's path; (4) the most recent qualifying run in the whole bucket — ONLY while announcing, before any work, which run was chosen and which workspace created it
   - Qualifying: `metadata.json` with `"status": "complete"` (legacy folders may instead have `"status": "active"` with `"phase": "complete"` — accept those too), UNLESS `metadata.holds` contains an entry with `"resolution": null`: a run paused on a critical answer is never picked up. Skip `"status": "superseded"`; if multiple qualify at one step for the same ticket, use the most recent and say so explicitly
   - Extract the requirement name from the directory (part after timestamp)

2. **Load the Full Requirement Corpus**
   - Read `06-requirements-spec.md` — parse: Problem Statement, Solution Overview, Functional Requirements (FR*), Technical Requirements (TR*), Implementation Hints, Acceptance Criteria, Assumptions, Out of Scope. Ultrathink all of it.
   - Read `03-context-findings.md` for technical context.
   - Read `research-notes.md` — specifically the source-claims register, the **currency snapshot**, and the **verification report**: this is where the volatile facts live.
   - Read `metadata.json` for related features and context files.
   - Read `communications.md` if present — it is NOT spec input (never derive requirements or tasks from it); it is read so the final report can reconcile the user's standing action items (obsolete vs still standing) and so the preflight can identify pending interim items (C-n).

3. **Staleness Preflight (before ANY planning or code)**
   Time has passed since the spec was finalized; re-verify what can drift:
   - Every fact in the currency snapshot: dependency ticket/MR states, branch existence, flags.
   - Every claim marked `[volatile: <dependency>]` in the spec: re-derive it from the MERGED code, never from the ticket text it was based on.
   - Every FR tagged `interim — final answer owned by <who> (C-n)`: ask the user in the (single) preflight checkpoint whether the owner has since answered. A differing answer is a premise change (handled by the same checkpoint); no answer → implement the interim exactly as written — the tag never licenses waiting or re-opening.
   - Spot-check the spec's load-bearing file:line anchors against the current base branch.
   Outcomes:
   - All premises hold → state "preflight clean" and continue autonomously.
   - A load-bearing premise changed → present ALL premise changes in ONE checkpoint (evidence, consequence, options, recommendation) and wait for the user; record the decision in implementation-notes, then continue.
   Never discover mid-implementation what this step could have caught.

4. **Generate Implementation Plan** (in planning mode)
   ```markdown
   # Implementation Plan: [Requirement Name]
   Generated: [timestamp] · Based on: [requirements timestamp] · Preflight: [clean | premises changed + decision]

   ## Overview
   ## Prerequisites (from the spec's TR prerequisites — verified executable now)
   ## Implementation Phases
   ### Phase N: [name] — Objective, Requirements Addressed (FR/TR), Steps with file:line
   ## Testing Strategy (TDD: each task carries its tests; targeted checks per task; DoD gate at the end)
   ## Validation Against Acceptance Criteria (each AC → implementation step)
   ```

5. **Generate Todo List**
   Structured tasks mapping to FR/TR numbers, each with file + priority; testing is part of each task, not a phase at the end; the final task is always the Definition-of-Done gate (step 7).

6. **Save Plan and Todo List**
   - `[requirements-dir]/implementation/` with timestamps: `implementation-plan_[ts].md`, `implementation-todo_[ts].md`, `current` symlinks; `implementation-notes_[ts].md` for discoveries, decisions, and deviations.

7. **Implement — incrementally, always green**
   - Load the todo list into the task tracker. Per task: mark in_progress → implement WITH its tests → run the task's targeted tests + format/lint for the touched files → fix anything red (part of the task) → mark completed → update the saved todo file.
   - In-task discovery that contradicts the spec → stop that task, verify the mechanism to Principle-1 standards, apply Principle 4 (one checkpoint), record in implementation-notes.

8. **Definition of Done (mandatory gate — "complete" may not be claimed before it passes)**
   - Discover the repo's diff-wide verification commands from its docs (CLAUDE.md / AGENTS.md): the formatter, diff-scoped tests, and the full lint/codegen suite, run from the directory the docs prescribe.
   - Run them all. Fix EVERYTHING they surface — failing tests, lint, snapshots/catalogs, CODEOWNERS, generated files — and re-run until green. This is implementation work, not follow-up.
   - Exception per Principle 2 only: failures verified pre-existing on the base branch or externally caused → blockers with evidence.
   - Walk the Acceptance Criteria: each one checked off, or listed as a deviation-blocker.
   - NEVER offer any part of this gate as an optional next step to the user.

9. **Final Report (mandatory typed structure — the closing message contains exactly these sections)**
   - **Needs you now** — verified blockers, forced decisions, and any deviation from the spec, each with a severity label (critical-for-merge / recommended / optional) and its evidence. If empty, say "Nothing — no action needed from you to consider this done."
   - **Yours by design** — commit/push/MR authorization (never commit unasked), and `communications.md` reconciled item by item: obsolete (say why) or still standing (destination is already in the file). Include anything implementation added to communications — and verify it was actually written there. **Worktree teardown**: when the run's `metadata.worktree.createdAtStart` is true and its path is the current workspace, remind the user this worktree was created for the run and offer to tear it down. On acceptance, verify FIRST: working tree clean AND the branch pushed (or the user explicitly says discard) — anything dirty or unpushed means report it and leave the worktree alone. To remove: leave the worktree first (ExitWorktree when available, otherwise run from the main checkout), then `git worktree remove <path>` — never `--force`, and never delete the branch. The run's artifacts live in the store, so teardown loses nothing of the pipeline; the workspace's now-stale pointer is pruned by the next command that reads pointers.
   - **Deviations from spec** — what/why/evidence, mirroring implementation-notes. If none: "implemented exactly as specified."
   - **Done & verified** — what was built (FR/TR coverage), exactly which checks ran with their results, and the AC checklist.
   No trailing open-ended menus ("want me to a/b/c?"). Concrete recommendations belong inside the sections, with their severity.

10. **Progress Tracking**
   - Save progress to the todo file as tasks complete (with timestamps); `BLOCKED:` prefix + explanation when stuck; discoveries/decisions/deviations go to implementation-notes as they happen, not at the end.

## Error Handling

- If no completed requirements found: "No completed requirements found in this repo's bucket (~/.claude/runs/<repo>/requirements/)"
- If requirements incomplete: "Found requirement [name] but status is [status], not 'complete'"
- If missing required files: list which files are missing from the requirement

## Notes

- Respects coding standards from the project's CLAUDE.md / AGENTS.md.
- Each todo task maps to specific FR/TR items; testing and validation happen inside each task, never deferred to the end — the DoD gate is confirmation, not discovery.
- The command's contract with /requirements-start: spec sections and file names are fixed; runs live in `~/.claude/runs/<repo>/requirements/` and resolve workspace-first (step 1's order); `research-notes.md` carries the currency snapshot + volatile claims the preflight consumes; `communications.md` is reconciled in the final report but never drives implementation.
