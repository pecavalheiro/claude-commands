# Requirements Retro

Post-mortem on a completed /requirements-start run whose findings were later challenged or proven wrong. Input: the run folder (or enough to find it in the repo's bucket, `~/.claude/runs/<repo>/requirements/` — runs from every clone and worktree of the repo live there, including runs whose creating workspace no longer exists; `<repo>` derivation is in requirements-start.md's Files section), plus what turned out to be wrong — my description, an MR, a thread, or a conversation excerpt.

A retro's job is to make future runs better, not to make the journal longer. Every entry and every rule is paid for on every future run (Phase 0 and 3b load the journal in full), and most misses are not missing rules — they are existing rules that did not bite. Default to tightening what exists over adding something new.

**This command writes nothing on its own.** No journal entry, no phase-file edit, not even a first journal file. The retro reports findings; I decide which ones get written. Each finding names its proposed fix (target file and the gist). The exact wording is shown when I pick the item, and written only after my explicit go-ahead for that item.

## Steps

1. Read the run's record: `gates.md`, the register and verification report in `research-notes.md`, `06-requirements-spec.md`, `communications.md`, the question files, and any `implementation/` notes. Then read the CURRENT phase files (`~/.claude/requirements-phases/`) and the FULL lessons journal — you cannot classify a miss as a gap without knowing what the rulebook already says, and a "new rule" that restates an existing one is the retro failing its own purpose.
2. **Verify the counter-claims like any claim.** "It was wrong" is itself a set of claims — confirm each against sources and code before treating it as ground truth. Some challenges are themselves mistaken; when one is, say so plainly, with evidence. A challenge can also be right in its facts and wrong in its premise — separate the two.
3. For each CONFIRMED miss, identify the mechanism, not just the fact:
   - which phase owned it, and which gate line should have caught it;
   - whether the rule existed and did not bite (enforcement miss — quote the rule and what the gate line actually held; the usual hole is a gate line that accepts an adjective ("re-checked", "exhaustive", "none material") where sibling lines demand artifacts — commands, outputs, SHAs) or genuinely did not exist (spec gap);
   - what the run's own records show: a gate line filled without real evidence, an audit that never ran, a search never made, a count that did not reconcile, a snapshot taken from stale state.
4. **Rank by value, cost and likelihood of happening again.** For every confirmed miss rate: value (what the miss cost: a false requirement shipped vs. review nits fixed in minutes), cost (of the fix, including what it adds to every future run, and whether a later stage such as review or /synthesize's preflight already catches it), and likelihood (how often its trigger recurs). Order the findings by that, and say plainly what you would drop and why.
5. Distill each surviving miss into a proposed lesson: trigger ("when …"), action ("do / check …"), and the run + retro date + MR as an evidence tail. The action is the binding part — keep it tight; the tail is one or two lines, not a story. Route each lesson to the right journal: pipeline-mechanism lessons → `~/.claude/journals/requirements-lessons.md`; implementation or doc-hygiene lessons that a code review catches → the per-app review journal (`~/.claude/journals/<app>/review-lessons.md`), written in THAT file's house style.
6. Merge discipline, for items I approve: Read the journal first and merge at ENTRY level — an entry sharing the lesson's root cause is extended with a new evidence tail, never given a sibling bullet. A new entry needs a new mechanism. Concurrent retros on sibling MRs race: grep the journal for the mechanism, the SHAs, and the MR numbers before writing. If the journal would exceed ~20 entries, propose consolidating same-root-cause entries as a finding of its own.
7. Phase-file edits: when a miss reveals a genuine gap OR an enforcement hole in a phase file (`~/.claude/requirements-phases/`), propose the edit (file and gist) as a finding. The proposal must modify an existing line, bullet, or gate-template entry wherever one can carry it; a net-new rule requires showing why no existing line can. When an approved phase-file edit would replace a journal entry, propose deleting that entry in the same item: the phase file is the binding copy, and a duplicate taxes every future run twice.
8. Never rewrite the finished run's artifacts to look better in hindsight; the record stays as it ran, plus dated addenda.

## Report shape

Short: one screen, no essays. I read it to decide, not to study.

1. Counter-claims that did not hold, or held only in part: one line each with the evidence pointer.
2. The findings, ranked: a table with the finding (one line), enforcement miss or spec gap, value, cost, likelihood, and the proposed fix (target file and line, the gist in a few words). Dropped findings go in one line at the end, with the reason.
3. One question: which items to write.

The full mechanism analysis, the evidence, and the exact wording stay out unless I ask for them.
