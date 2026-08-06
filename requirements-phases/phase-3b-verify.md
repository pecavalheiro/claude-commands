# Phase 3b — Adversarial Verification (autonomous — the trust gate)

This file IS the phase — read it fully before running Phase 3b. First verify Gate 3 exists in `gates.md` with every line filled; if not, go back.

Why this phase exists: everything upstream was produced by one line of reasoning; this is where independent eyes attack it. **Verification that does not happen but gets counted is worse than none — it converts unverified claims into trusted ones.** Every pass below is therefore a named deliverable: it produces a report appended to `research-notes.md`, and the gate cites each report by location. A pass with no report did not happen, whatever you remember.

Re-read the lessons journal (`~/.claude/journals/requirements-lessons.md`, if present) before designing the passes — it records how previous runs' verification missed things.

**Verify by consequence, not uniformly.** Load-bearing claims — anything an FR, a question default, a disposition row, or a communications draft rests on — get exhaustive treatment; benign confirmatory claims get sampled (at least 1 in 5). Isolate every verifier from the FRAME, not just the reasoning: a verifier handed a framed claim can only return CONFIRMED.

## The seven passes

### 1. Refutation pass — door-closing and gating claims

For every claim queued at Gates 1/3 that closes or downgrades a source-requested capability, or that an FR/question rests on: spawn a FRESH agent whose job is to make the claim FAIL, handed the GOAL, never the framed claim ("find any way to post a mention-note on the case tracker using existing code or the live API" — never "confirm our client can't post mentions"). It seeks the adjacent primitive (another id/table/config key, a sibling pattern) or reads the CURRENT external docs. Verdicts: REFUTED / PARTIALLY REFUTED / NOT REFUTED, with the exact searches shown. A claim survives only if refutation fails; an unrefuted-but-unconfirmed capability is `[unverified]`, never `[infeasible]`.

### 2. Source re-check pass

Fresh subagents re-fetch registered sources and check claims against reality: is the quote verbatim? is the locator right? is it anchored to what the register says? **is the author the register's author?** Exhaustive for load-bearing claims, sampled for the rest. Every re-checked claim gets a `verified-by: source-recheck <date>` mark appended to its register row — these marks are what the arithmetic pass counts. This pass is NOT satisfied by you re-reading your own notes: the re-checker is a fresh-context agent that did not write the claims.

### 3. Code re-derivation pass

Each file:line/behavioral claim in `03-context-findings.md` re-derived by an agent that did not write it, from the CURRENT branch heads — `[volatile]` claims (resting on unmerged dependencies) explicitly re-derived from those dependencies' current heads. Marks: `verified-by: code-rederive <date>`.

### 4. Cross-source conflict pass

One fresh subagent receives ONLY the claims register (IDs, quotes, authors, dates, provenance tags — no drafts, no reasoning, no conclusions) and hunts:

- pairs of claims that contradict each other;
- claims that interact — one source's mechanism plus another source's rule/config producing a consequence no single source states;
- interpretation claims (`[inferred]` equations and generalizations) whose underlying quotes do not actually support them — especially scope transfers, where a quote about one field/case/population was generalized to another.

Per-source checks structurally cannot see two-source problems; this pass exists for exactly those.

### 5. Reverse-check pass (one per source)

What does this source require or constrain that the draft does NOT reflect? Triage every hit: in-scope (add it), owned elsewhere (map to the owning ticket), or a genuine question.

### 6. Currency re-check

Every mutable Phase 0 fact re-checked and timestamped: ticket states, MR states, branch existence.

### 7. Arithmetic pass — the register must add up

All counts are computed, never recalled: claims extracted (grep on claim-ID lines), verified (grep on `verified-by:` marks), sampled-out (grep on the sampling marks), unverified (grep on `[unverified]`). Paste the exact commands and their outputs into the verification report. **extracted = verified + sampled-out + unverified must reconcile, shown numerically.** `metadata.json`'s verification numbers are copied from these computed counts, never free-written. If the numbers do not reconcile, the register is wrong somewhere — find it before proceeding.

## Outcomes

- **Failed claims are corrected everywhere they appear** — grep for every occurrence of the claim's content across all working files; claims propagate, and a correction applied only at the register leaves the wrong version live downstream.
- **Unverifiable claims are quarantined** as `[unverified]` with "the one fact that would settle it" — each becomes a question, a sandbox-verification request, or an explicit labeled assumption. Nothing `[unverified]` flows forward as fact.
- **Decision-impact check:** for each answer I already gave, did verification change the premise it rested on? If yes, present the changed premise ONCE — evidence, consequence, recommended new default — as new information, never as the old question re-asked. A held FR (override option (a)) is treated like an `[unverified]` claim: context gathering continues (the evidence sharpens the ask to the owner), no other FR may rest on it, and if verification changes the recommendation, update the paste-ready draft in its C-n item — open a new user round-trip only if the set of viable options flips.
- **Disposition consistency:** if any pass declares a conflict over a quote that a Gate A disposition row calls "settled", reopen that row (the table must never hold both).

## Gate 3b — append to `gates.md`

```
## Gate 3b — adversarial verification (<timestamp>)
- refutation: report at <location>; <N> claims attacked → <verdict summary>
- source re-check: report at <location>; <N> load-bearing exhaustive + <M> sampled; attribution mismatches: <list or "none">
- code re-derivation: report at <location>; <N> re-derived, <X> changed on re-derivation
- cross-source: report at <location>; findings: <list or "none">
- reverse-check: <per source, one line each>
- currency: re-checked <timestamp>; changes: <list or "none">
- arithmetic: <the pasted count commands + outputs + the reconciliation line>
- corrections applied: <list, each with the files it touched>
- [unverified] remaining: <list>
- changed premises presented to me: <list or "none">
```

**Then announce: "Phase 3b complete (gate appended). Starting Phase 4: Expert Detail Questions..." and read `~/.claude/requirements-phases/phase-2-questions.md` again — its 'Phase 4 variant' section applies.**
