# Phase 1 — Codebase Analysis (autonomous)

This file IS the phase — read it fully before running Phase 1. First verify Gate 0 exists in `gates.md` with every line filled; if not, go back to `phase-0-sources.md`.

Map the domain: the code the sources point at, the hook/trigger points, precedent features, house patterns. Fan out subagents for parallel exploration — they return evidence (file:line, verbatim snippets), never verdicts — and batch-read what they locate.

## Evidence bars — every claim written into any working document meets the bar for its class

- **Static** (names, enum values, schema fields, literals, config): read the defining file; cite file:line.
- **Behavioral** (side effects, notification chains, transactions/rollback, retries, permission checks, ordering, cron schedules): trace to the code that DEFINES the behavior — framework module, worker config, changeset internals, cron registration. A call site alone never supports a behavioral claim. "How the library usually behaves" is not evidence; codebases override defaults.
- **Absence** ("no other callers", "no X exists", "the only setter"): name the exhaustive search performed (patterns, scope, exclusions) or do not make the claim. An absence in OUR code bounds only what we have built — it never licenses a claim about what an external system can do, and never closes a door on a source-requested capability. Before letting an absence close a door, search the adjacent space (sibling ids/tables/config keys, precedent patterns) for the thing that would flip it.
- **Literal values** (country names, hosts, config strings): NEVER hardcode from memory or reasoning — resolve from the authoritative seed/table/config and cite it.

## Door-closing claims are guilty until proven

A door-closing claim concludes a capability the sources asked for *can't be delivered* (impossible / unsupported / not feasible / "not viable as-is"), or cites net-new work as the reason to DROP it — the highest-risk claim in the run; it kills features. Judge the CONCLUSION, not the presence of a negative word: building something new to ADD a requested capability is never door-closing (however much work), and a scope cut a SOURCE settled is a decision, not a door-closing claim — the test is *who* closed the door, a source vs. you inferring it from our code. It may NEVER rest on an absence in our own code (no caller, empty/omitted field, missing wrapper, a type mismatch = "we haven't built it", never "it can't be done"); a claim about an EXTERNAL system's capability may not be inferred from our code's limits at all. For a mainstream external product, assume its documented/common capability is AVAILABLE — refute feasibility, don't prove it. **A confirmed premise never upgrades an unproven inference**: verifying that "X has no caller / an empty field / the wrong type in our client" is TRUE does not make "therefore X is impossible" true. Every door-closing claim is queued here for the Phase 3b refutation pass — none is written as fact or shown to me before that pass runs.

## Integration inventory

Inventory both directions of every integration: what the change writes AND every surface that reads/exposes what it writes (value objects/serializers/views, notifications, crons, webhooks, permission checks, API schemas). Exposure surfaces you don't look for are the ones that flip decisions later.

All claims from this phase enter the register as `CODE-*` entries under the Phase 0 rules (IDs, locators, provenance tags). A claim you could not verify to its bar is tagged `[unverified]`, hedge kept verbatim.

## Gate 1 — append to `gates.md`

```
## Gate 1 — codebase (<timestamp>)
- exploration: <subagents run + their scopes>
- code claims: <N> CODE-* entries, each classed static/behavioral/absence/literal with file:line — <count command + output>
- absence claims: <each names its exhaustive search, or "none">
- door-closing claims: <each listed + queued for the Phase 3b refutation pass, or "none">
- integration inventory: <location — both directions covered>
- contextFiles updated in metadata.json: <yes>
```

**Then announce: "Phase 1 complete (gate appended). Starting Phase 2: Coverage Checkpoint & Discovery Questions..." and read `~/.claude/requirements-phases/phase-2-questions.md`.**
