# Phase 0 — Source Inventory & Extraction

A gate: nothing advances until it passes. This file IS the phase — if you are running Phase 0 without having just read this file top to bottom, stop and read it fully.

Binding principles for this phase:

- **Never proceed blind.** If any source cannot be fetched (connector auth failure, permissions, dead link), STOP and ask me — fix access / skip it / abort — the moment the failure is confirmed. Launch no further phase work, subagents included, while the question is pending. You do NOT get to assess a missing source as "non-load-bearing" and move on; whether it matters is my call. (Different case: a source you FETCHED and then judged out of scope may be excluded autonomously — record the exclusion + reasoning in the register and list it in the phase announcement.)
- **No invention.** Nothing fabricated; any artifact representing external reality (API payloads, fixtures) comes from a verified capture or is flagged `[unverified]`.
- **Third-party API claims are never trusted from a ticket.** Tickets describe external APIs from memory and are often wrong. Verify every external-API claim (endpoints, fields, hosts, auth, expiry, ordering guarantees) against the official docs, and empirically when a sandbox is available — and do it NOW, in this phase: a nonexistent endpoint discovered late invalidates hours of downstream work. Account/key configuration (pinned API versions!) changes behavior — verify against OUR account's configuration, not just the latest docs. If a load-bearing external-API claim cannot be checked without access, ask me for a temporary key, stating exactly what you will test. Your training memory of a fast-moving external API is stale by default — "I recall it can't" is a hypothesis to check against CURRENT docs, never a finding.
- **Subagents return evidence** (verbatim quotes, locators, snippets), never verdicts. Read the evidence and conclude yourself.

## 0.1 Lessons journal

If `~/.claude/journals/requirements-lessons.md` exists, read it now — one file, shared by every project. Its lessons are binding for this run, same as the rules in this file; say how many you loaded. If absent, note that in one line and continue: a first run on a machine legitimately has no journal, and it is never invented or searched for elsewhere.

## 0.2 Connector preflight

The usual source connectors: Linear, Notion, GitLab, Figma, Slack. Verify every connector the source graph will need — one trivial call each (a teams/issue lookup, a search, `glab auth status`, a whoami). If a needed connector is missing or unauthenticated, STOP and ask me to connect it (e.g., `/mcp`) or to explicitly waive that source type for this run.

- A source type with no sources in the graph yet may be deferred — but the deferral is provisional and self-cancelling: **the moment a reference to that type enters the graph, its preflight fires then, before the referencing node can receive any status.** A permalink or channel/document reference inside the text of ANY fetched source counts as entering the graph. Record the re-fire as a NEW preflight row in the register; never edit an earlier row to justify a skip — a record adjusted to match behavior instead of behavior corrected to match the record is falsification.
- Fetch every source with its **native connector**. WebFetch against an auth-walled SaaS URL is never a valid accessibility test: a 200 returning an app shell or login page is a FAILED fetch. A source is "inaccessible" only after its proper connector failed or is absent.

## 0.3 Setup — every run starts fresh

Create `requirements/YYYY-MM-DD-HHMM-[slug]/`, write `00-initial-request.md` (the request verbatim + a summary of the primary source), `metadata.json` (structure below — record the primary ticket id in `sources` immediately), create an empty `gates.md`, and update `requirements/.current-requirement`. **Never scan, list, read, or search other folders under `requirements/` or any other prior local working documents — no prior-run check, no resume-by-scan, no answer inheritance.** A prior document enters this run ONLY if I explicitly name its path in the request; it joins the source graph as an ordinary source — its contents are evidence to quote with locators, never decisions: nothing recorded there counts as an answer I gave in THIS run unless I confirm it here.

```json
{
  "id": "feature-slug",
  "started": "ISO-8601-timestamp",
  "lastUpdated": "ISO-8601-timestamp",
  "status": "active | complete | incomplete",
  "phase": "discovery|context|detail|verification|complete",
  "progress": {
    "discovery": { "answered": 0, "total": 0 },
    "detail": { "answered": 0, "total": 0 }
  },
  "contextFiles": ["paths/of/files/analyzed"],
  "relatedFeatures": ["similar features found"],
  "sources": { "linear": [], "notion": [], "slack": [], "gitlab": [] },
  "verification": { "lastRun": null, "sourceClaimsVerified": 0, "codeClaimsVerified": 0, "unverified": 0 },
  "holds": []
}
```

`holds` entries: `{ "comm": "C-3", "owner": "<team> (@who)", "askedAt": "ISO-8601", "heldFRs": ["FR-4"], "resolution": null }` with `resolution` ∈ `null | "answered" | "interim" | "descoped:<ticket>"`. **`status`/`phase` may never be set to "complete" while any hold has `resolution: null`.** The `verification` numbers are only ever written from the computed counts of Phase 3b's arithmetic pass — never typed from memory.

## 0.4 Enumerate the graph — traversal AND search

1. **Link traversal, breadth-first until closed:** the primary ticket → every linked/related ticket (record parent/blocks/duplicate relations and each ticket's current status) → PRD/Notion pages (INCLUDING inline comments and what each comment is anchored to) → pages those link to (runbooks, process docs) → referenced Slack threads (full threads, every reply) → referenced MRs/branches → media (Loom/Figma).
2. **Search sweep — mandatory, not optional.** Link traversal only reaches what documents point at, and the decisive conversation is often unlinked. Search each connected system independently for: the ticket id, the feature's distinctive terms, and the name of every person the sources quote, assign a question to, or name as an owner. Slack search is REQUIRED whenever any open question in the sources names or is addressed to a person — a question aimed at a person means the answer, if it exists, lives in a conversation, and conversations do not get linked back into tickets. Record every search in the register: system, exact query, hit count, hits added to the graph. The searches are gate evidence. A system that cannot be searched (no search tool available) is an accessibility STOP per the preflight rules, not a silent skip.

## 0.5 Fetch everything, with evidence

Fetch every graph node COMPLETELY — descriptions AND comments/replies. Fan out one subagent per source for parallel extraction; each returns verbatim quotes with stable locators (ticket id + section, comment author + date, Slack permalink, Notion block, MR iid) plus every URL found inside the source — never summaries alone.

**Fetch-evidence rule.** Every node gets a register row with `status:` and `fetched_via:` (tool + timestamp). The only statuses are:

- `fully-read` — requires a fetch record
- `partial` — requires a fetch record, plus what is missing
- `pending` — enumerated, not yet fetched
- `inaccessible` — its native connector failed or is absent (this already hard-stopped, above)
- `excluded` — FETCHED, then judged out of scope, with the reasoning recorded

**`excluded` without a fetch record cannot exist.** Judging an unfetched node's content from its anchor text, title, channel name, or age is forbidden — an unfetched node is `pending`, full stop, and a pending node blocks the Phase 2 checkpoint from being all-green.

## 0.6 The source-claims register (in `research-notes.md`)

Every requirement, constraint, decision, open question, and technical claim gets a short stable **claim ID** (`LIN-<ticket>-N`, `PRD-N`, `SLK-N`, `CODE-N`, …) plus: the verbatim quote; a DEEP locator (Slack → message permalink, never just the channel; Notion → block link where possible, else page URL + section heading; Linear → ticket URL + quoted section title; GitLab → MR/discussion URL; code → file:line); author + date; a **"via" chain** showing how the source was reached (e.g., "PRD 'Rollout' section, linked from TICKET-123 description"); and a provenance tag:

- `[stated]` — the source says it explicitly (quote it)
- `[inferred]` — you derived it; list the claim IDs it rests on (derived numbers and aggregations always carry this)
- `[absent]` — no source addresses it (questions and autonomous decisions are made of these)

**Interpretation claims are claims.** Any statement that equates, generalizes, or transfers — "X and Y are the same mechanism", "A's reply confirms B's assumption", "this answer about one field also covers that other field" — is an `[inferred]` register entry of its own, listing the claim IDs it rests on. Attribution is part of the claim: a message is credited to the person who wrote it, never to whoever agreed with it, and a bare "yes" confirms exactly the sentence it replies to, nothing more.

**Open questions are first-class register entries:** anything a source poses without a recorded decision — a question mark addressed to anyone, a TBD/TODO, an options list with no decision — in ANY graph source, description or comment. Record WHO said it and what it was anchored to — a comment anchored on section X is not a statement about section Y.

Downstream, **no naked facts**: any number, quote, or behavioral statement used in a question, option description, finding, or FR must carry its claim ID.

## 0.7 Inaccessible media

Login-walled videos, expiring screenshots: flag explicitly in the register with what textual coverage substitutes for them; I decide whether that is acceptable.

## 0.8 Currency snapshot

Record status + timestamp of every mutable fact (ticket states, MR states, branch existence) — these get re-checked in Phase 3b, and again by /synthesize's staleness preflight at implementation start.

## Gate 0 — append to `gates.md` before leaving this phase

```
## Gate 0 — sources (<timestamp>)
- connectors: <each connector → the trivial call run + result; deferred types with their re-fire condition, or "none deferred">
- lessons journal: <path read, or "absent">
- node census: <N> nodes enumerated; register rows with status + fetched_via: <count command + output> — must equal N
- exclusion honesty: zero nodes excluded/fully-read/partial without a fetch record — <the check run + result>
- search sweep: <per system: query → hits → added to graph>, or the STOP ruling that waived it
- claims: <N> register entries — <count command + output>
- third-party API claims: <each: claim → how verified now, or the key request made>
- currency snapshot: <location>
- STOPs raised: <each + my ruling, or "none">
```

Every line carries its evidence; counts are computed (command shown), never recalled. A line you cannot fill is a phase you have not finished.

**Then announce: "Phase 0 complete (gate appended). Starting Phase 1: Codebase Analysis..." and read `~/.claude/requirements-phases/phase-1-code.md`.**
