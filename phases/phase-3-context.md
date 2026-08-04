# Phase 3 — Targeted Context Gathering (autonomous)

This file IS the phase — read it fully before running Phase 3. First verify Gate 2 exists in `gates.md` with every line filled; if not, go back.

Deep-dive the code paths the discovery answers select: exact files to modify, precedent implementations, integration points, constraints, side-effect inventories. Fan out subagents for the mechanical work — evidence only (file:line, verbatim snippets), never verdicts.

Document everything in `03-context-findings.md` under the Phase 1 evidence bars — if you cannot state the four bars (static / behavioral / absence / literal) and the door-closing rule from memory, re-read that section of `phase-1-code.md` before writing a single claim. Every code fact carries file:line; every claim you could not verify to its bar is tagged `[unverified]` with the hedge kept verbatim.

New sources discovered during the dive (tickets, MRs, docs, threads) enter the graph under the Phase 0 rules: register row with fetch evidence, claims with IDs, preflight re-fire if they introduce a new source type. They will appear in Phase 4's delta table.

## Gate 3 — append to `gates.md`

```
## Gate 3 — targeted context (<timestamp>)
- paths investigated: <list>
- new claims: <N> with IDs — <count command + output>
- new sources: <list + fetch records, or "none">
- door-closing claims added: <each queued for the 3b refutation pass, or "none">
- [unverified] tags: <count + list>
```

**Then announce: "Phase 3 complete (gate appended). Starting Phase 3b: Adversarial Verification..." and read `~/.claude/requirements-phases/phase-3b-verify.md`.**
