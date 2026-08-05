# Requirements Gathering Reminder

Re-grounding card for requirements gathering. Two uses: a quick correction when deviating from the rules, and a proactive refresh — run it on resuming a run and after the conversation has been summarized/compacted, before any drift appears. This card is only the gist; the authoritative rules live in the per-phase files under `~/.claude/requirements-phases/` — a phase's file IS the phase, and it must be Read before that phase begins, resumes, or continues (see requirements-start.md). After printing this card, read `gates.md` in the run folder to locate the run, then re-read the current phase's file.

## Instructions:

1. Check requirements/.current-requirement
2. If no active requirement:
   - Show "No active requirement gathering session"
   - Exit

3. Display reminder based on current context:

```
🔔 Requirements Gathering Reminder

You are gathering requirements for: [active-requirement]
Current phase: [Initial Setup/Context Discovery/Targeted Context/Expert Requirements]  
Progress: [X/Y questions]

📋 PHASE-SPECIFIC RULES:

Phase 0 - Source Inventory (Autonomous, with hard stops):
- ✅ Connector preflight before fetching: Linear/Notion/GitLab/Figma/Slack connected and authenticated; a deferred type's preflight FIRES the moment a reference to it enters the graph (a permalink inside fetched content counts)
- ✅ Every source fetched via its native connector — an app-shell/login 200 from WebFetch is a FAILED fetch
- ✅ Search sweep beyond link traversal: search each system for the ticket id, feature terms, and every person the sources quote — Slack search is REQUIRED when an open question names a person
- ✅ Every node carries status + fetched_via evidence; "excluded" requires a fetch record — an unfetched node is "pending", never judged from its title/anchor text
- ❌ Never continue past an inaccessible source — blocking question (fix/skip/abort) immediately, no deferral, no self-assessed "non-load-bearing"

Phase 2 - Context Discovery:
- ✅ Open with the source-coverage checkpoint DERIVED FROM THE REGISTER (never from memory): every node (fully read / partial+missing / excluded+why — "excluded" only for FETCHED sources) + Phase 0 flags with prior rulings inline; ends with the search-sweep summary AND the unlinked-sources ask ("any relevant thread/doc not linked anywhere?") — the ask always waits for an answer; a named missing source returns the run to Phase 0
- ✅ Pre-ask provenance audit by a fresh subagent (register + question file only): naked facts, unresolvable IDs, quote-support mismatches incl. scope transfers, attribution mismatches, unregistered inventions — all fixed before the first ask
- ❌ Never bundle a model invention inside an option — anything you originate is a `[model proposal — no source]` register entry with its OWN disposition row (externally-visible ones are critical)
- ✅ Disposition every DECISION (not just questions) in the decision disposition table — source-settled (authoritative quote) / other-owned & independent (citation) / critical / low-stakes comms / engineering
- ✅ Criticality override BEATS Gates B and C: source-posed open questions, genuinely conflicting sources, externally-visible + hard-to-reverse-or-new-behavior defaults, NEW policy positions → ALWAYS interactive, with owner + where + paste-ready draft + consequence + (a)/(b)/(c) options; whether it blocks is the USER's call
- ✅ Every question passes Gate A (sources don't answer it — conflicting sources are never "an answer"), Gate B (product altitude), Gate C (NON-critical third-party items only → communications.md; rationale = low stakes, never "not blocking"; no owner-availability assumptions)
- ✅ Every factual assertion in a question/option carries a claim ID; print the Evidence block (quotes + links) in chat before each ask
- ✅ Questions for product managers (no code knowledge required)
- ✅ Write ALL questions before asking any
- ✅ Record answers ONLY after all questions asked

Phase 3/3b - Targeted Context + Adversarial Verification (Autonomous):
- ✅ Use available search/read tools and subagents to explore code
- ✅ Meet the evidence bars: static → file:line; behavioral → defining mechanism; absence → named search; literals → resolved from authoritative source
- ✅ 3b runs SEVEN named passes, each by fresh context-isolated subagents, each leaving a report: refutation (goal-framed, never the framed claim), source re-check (quote/anchor/AUTHOR), code re-derivation, cross-source conflict hunt (register only — catches two-source problems and scope transfers), reverse-check, currency, arithmetic
- ✅ Counts are computed (grep, command pasted), never recalled — extracted = verified + sampled + unverified must reconcile; metadata copies computed numbers
- ✅ Document findings in context file; tag what can't be verified `[unverified]` — a pass with no report did not happen
- ❌ No user interaction during these phases (changed premises are presented once, after)

Phase 4 - Expert Requirements:
- ✅ Open with a coverage DELTA table if Phase 3/3b added sources (full table on a resumed session)
- ✅ Same disposition flow, criticality override, and gates as Phase 2 (zero is valid only with a fully-cited disposition table)
- ✅ Questions as if speaking to PM who knows no code, arising from VERIFIED findings only
- ✅ Every factual assertion in a question/option carries a claim ID; print the Evidence block (quotes + links) in chat before each ask
- ✅ Clarify expected system behavior
- ✅ Reference specific files when relevant
- ✅ Record answers ONLY after all questions asked

🚫 GENERAL RULES:
0. ❌ Don't run any phase without having Read its phase file this session; don't pass a gate line you can't fill with evidence
1. ❌ Don't start coding or implementing
2. ❌ Don't ask open-ended questions (override items use the fixed (a)/(b)/(c) option format — that is not open-ended)
3. ❌ Don't record answers until ALL questions in phase are asked
4. ❌ Don't exceed 5 questions per phase (a critical override item is never dropped for the cap — if criticals exceed 5, say the feature is underspecified and ask how to proceed)
5. ❌ Don't ask anything the sources (ticket/PRD/Slack/code) already answer — record the quote instead
6. ❌ Don't re-present an answered decision, even reworded ("to confirm" counts)
7. ❌ Don't state unverified claims as facts — tag them `[unverified]`
8. ❌ Don't put intermediate states, revision narration, or people-coordination content in 06 — final decisions only; people-facing items go to communications.md + chat (sole exception: the provenance tag `interim — final answer owned by <who> (C-n)`)
9. ❌ Don't route critical decisions to communications.md — source-posed open questions, conflicting sources, hard-to-reverse or policy-encoding defaults go to the user, who decides whether they block; "to avoid blocking you" is never a reason

📍 CURRENT STATE:
- Last question: [Show last question]
- User response: [pending/answered]
- Next action: [Continue with question X of 5]

Please continue with the current question or read the next one from the file.
```

## Common Correction Scenarios:

### Open-ended question asked:
"Let me rephrase as a yes/no question..."

### Multiple questions asked:
"Let me ask one question at a time..."

### Implementation started:
"I apologize. Let me continue with requirements gathering..."

### No default provided:
"Let me add a default for that question..."

## Auto-trigger Patterns:
- Detect code blocks → remind no implementation
- Multiple "?" in response → remind one question
- Response > 100 words → remind to be concise
- Open-ended words ("what", "how") → remind yes/no only
- (Exempt from the above: coverage checkpoint tables, Evidence blocks, and override (a)/(b)/(c) option lists)