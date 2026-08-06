# Requirements Retro

Post-mortem on a completed /requirements-start run whose findings were later challenged or proven wrong. Input: the run folder (or enough to find it under `requirements/`), plus what turned out to be wrong — my description, an MR, a thread, or a conversation excerpt.

## Steps

1. Read the run's record: `gates.md`, the register and verification report in `research-notes.md`, `06-requirements-spec.md`, `communications.md`, and the question files.
2. **Verify the counter-claims like any claim.** "It was wrong" is itself a set of claims — confirm each against sources and code before treating it as ground truth. Some challenges are themselves mistaken; when one is, say so plainly, with evidence.
3. For each CONFIRMED miss, identify the mechanism, not just the fact:
   - which phase owned it, and which gate line should have caught it;
   - whether the rule existed and was skipped (enforcement miss — quote the gate line and what its evidence actually was) or did not exist (spec gap);
   - what the run's own records show: a gate line filled without real evidence, an audit that never ran, a search never made, a count that did not reconcile.
4. Distill each miss into a lesson of at most 3 lines: the trigger ("when ..."), the action ("do / check ..."), and the run + date it came from. Lessons are read by FUTURE runs (Phase 0 and Phase 3b load the journal as binding), so phrase them as instructions, not stories.
5. Append the lessons to `~/.claude/journals/requirements-lessons.md` — one file, shared by every project, since these lessons are about the pipeline's own gates rather than any one codebase. Create it if it does not exist; when it does, Read it first and merge into the matching section instead of duplicating.
6. When a miss reveals a genuine spec gap in a phase file (`~/.claude/requirements-phases/`), propose the exact edit (file + wording) in chat — do NOT edit the phase files yourself.
7. Never rewrite the finished run's artifacts to look better in hindsight; the record stays as it ran, plus dated addenda.
