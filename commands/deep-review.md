Open the link I'll provide. It will be one of two paths, and they differ a lot in complexity:

- **A Linear ticket** is my own work. The changes sit in the current local branch, committed or not. Treat the branch as not merged and all of its code as new, and inspect it by diffing the branch against its base (plus any uncommitted changes). Because the code is mine, you can be more flexible about structure and design preferences. There is no MR and no review discussion, so this is the simpler path: skip the MR gate below.
- **A GitLab MR** is a colleague's work that I'm reviewing. This is the more complex path: there may be existing comments, bot reviews, and back-and-forth between several people. The ticket link is in the MR description. Get the changes via the GitLab MCP / glab or by checking out the branch locally, and treat all of its code as new.

## GitLab MR only: mandatory gate before ANY findings

1. Retrieve every existing discussion thread, not just the MR description. The GitLab MCP has no MR-notes tool, so use glab:
   `glab api "projects/<project_id_or_path>/merge_requests/<iid>/discussions?per_page=100"`
   Bot threads count too (BugBot, Cursor, Terraform, and similar). If you cannot retrieve them, STOP and tell me. Never produce findings blind.
2. Summarize what each thread raised and its state: resolved, unresolved, author-replied, or bot.
3. Cross-check every candidate finding against those threads before showing me anything:
   - Drop whatever was already raised and adequately addressed.
   - If a raised issue is still unresolved, or the author's fix looks wrong or incomplete, surface it as a follow-up on the existing thread, not as a new finding.
   - For each surviving finding, state explicitly that it is novel.

## Step 1: assemble the context pack

The review runs as five parallel lenses (Step 2) whose findings you then verify yourself (Step 3). First gather what they all need:

1. Save the full diff to a scratchpad file, and make sure the code is readable at the change's revision — a clean local checkout of the branch is best. Note the repo path.
2. Read the repo's own review rules for the touched code. They are binding review context, and findings that lean on them must cite them by file:line:
   - the repo/app root `AGENTS.md` and the domain index (`DOMAINS.md` or similar)
   - the agent rule files (`.cursor/rules/`, `.agents/rules/`): the architecture rules always, plus every rule file whose topic the diff touches (e.g. the hooks rules whenever hook producers, consumers, or hook config change)
   - each touched domain's `AGENTS.md` and `interface.yaml`, when present
   - the test conventions doc (e.g. `test/CLAUDE.md`) when tests change
3. Read the two journals under `implementation/` at the employ workspace root (default `~/projects/remote/employ_workspace/implementation/`; if missing, walk up from the repo to the directory containing `tiger/`, `dragon/`, etc.):
   - `review-lessons.md` — accumulated lessons from past reviews; binding, same as the repo rules
   - `domain.md` — domain facts for the touched area
4. Read the ticket.
5. Write a briefing file in the scratchpad containing: the ticket summary and its requirements; the link under review, branch, local repo path, saved-diff path, and changed-file list; (MR path) the thread summary from the gate; the paths of every rules file and journal from steps 2-3; and the lens output contract below, copied verbatim.

**Lens output contract** (copy into the briefing verbatim):
> Return only a list of candidate findings. Each finding has: (1) a one-line claim; (2) a class — `mechanism` (runtime behavior, bug, performance, dead code) or `design` (placement, mechanism choice, dependency direction, convention, test quality); (3) the diff file:line it concerns; (4) every file:line you actually read as evidence, each with a phrase saying what it proves; (5) confidence: `confirmed`, `likely`, or `hypothesis` — keep hedges verbatim, never harden them; (6) a suggested severity (Critical / High / Medium / Low / Nitpick). Return claims and evidence, never verdicts — the orchestrator decides what survives. An empty list is a valid, good result; never manufacture findings.

## Step 2: fan out the review lenses

Launch five subagents in parallel — one message, five Agent calls, general-purpose type. Each gets the same prompt shape: "Read the briefing at `<path>`. Read your lens at `<path>`. Investigate the change deeply, reading as much surrounding code as you need, and follow your lens. Return findings exactly per the briefing's output contract." The lenses:

| Lens | File |
|---|---|
| Correctness & behavior | `~/.claude/review-lenses/correctness.md` |
| Architecture & mechanism | `~/.claude/review-lenses/architecture.md` |
| Domain & conventions | `~/.claude/review-lenses/domain.md` |
| Tests | `~/.claude/review-lenses/tests.md` |
| Fresh eyes | `~/.claude/review-lenses/fresh-eyes.md` |

If subagents are unavailable, run the lenses yourself sequentially — one pass per lens, re-reading the lens file immediately before each pass so its questions are fresh. Never all lenses in one pass: that is exactly the attention dilution this structure exists to prevent.

## Step 3: verify, dedup, rank — yours alone, never delegated

Every lens finding is a hypothesis, including the ones marked `confirmed`. Read the cited evidence yourself and decide; a lens that hedged is your cue to verify, not to trust. Merge duplicates across lenses (keep the best-evidenced version), dedup against the MR threads per the gate, then walk everything that survives through the two disciplines below.

### Scope discipline: applies to every finding

- Read the full final content of each changed file, not only the diff hunks, including moduledocs and inline comments. If the code or its own docs already answer a question, do not raise it.
- Every ranked finding must cite a line the change under review actually adds or modifies, or be a direct, demonstrable consequence of one.
- Pre-existing or inherited behavior is never a ranked finding, even when it looks relevant to a requirement (for example, the change reuses inherited behavior that may not fully meet the ticket). If it is worth my awareness, put it under a separate "Reminders" section, phrased neutrally as something for me to consider, so I decide whether it deserves a comment. Never phrase it as a defect or anchor it to a diff line as if the change introduced it. If the decision is already documented (MR description, moduledoc, or a thread), do not re-litigate it.
- Final self-check per finding: (a) does the diff actually change this? (b) does an existing thread or the code's own docs already address it? (c) enumerate every premise that, if false, kills the finding - the central claim AND the background premises (flag defaults and rollout state, whether the affected path even runs, config values, test-env behavior) - and for each one: have I read the code that settles it? For any behavioral, performance, or dead-code claim, "I read the diff" does not settle it. If (a) or (b) fails, drop it or move it to Reminders; if (c) is unsettled, move it to "Unverified, worth a look" or drop it.

### Evidence discipline: applies to every finding

This is the sibling of scope discipline. Scope asks "is this finding about the change?" Evidence asks "have I confirmed it is true?" Most unreliable findings pass the first and fail the second: plausible, fluently written, and wrong. More reasoning does not fix an unverified premise; it only makes the wrong conclusion more convincing. The gate below is what fixes it.

- Classify the central claim of each finding before ranking it, and meet its evidence bar:
  - **Static** (a type, a return shape, a missing field, a name, a literal value): confirm by reading the changed file and its direct collaborators.
  - **Behavioral or runtime** (what happens when this runs: retries, async dispatch, transaction and rollback boundaries, error propagation, ordering, concurrency, performance, N+1): you MUST trace it to the code that defines that behavior, the framework module, the worker or job config, the retry or supervision setting, the transaction wrapper. The diff alone never supports a runtime claim. How a library "usually" behaves is not evidence; this codebase overrides library defaults in places the review-lessons journal records — read the actual config.
  - **Dead code, leftover, or unused**: confirm there are no callers, including dynamic, macro-generated, behaviour, and string-based dispatch, before claiming it.
  - **Design or convention** (wrong placement, unjustified mechanism or indirection, dependency direction, a violated convention or contract, weak tests): the bar is different, not lower. Verify every fact the finding rests on by reading it yourself — the namespaces involved, the actual call sites, the rule/convention/lesson text (cite its file:line), what the ticket actually asked for — then state the judgment explicitly as a judgment. A design finding whose facts are verified and whose rule is cited is rankable at full severity; never demote it to "Unverified, worth a look" merely because its conclusion is a judgment rather than a traceable mechanism. When no written rule or journal lesson backs it, it can still rank on strong reasoning, but its paste-ready comment must be framed as a question — it is taste, not law.
- Cite the evidence, not just the target. A ranked finding names two things: the diff line it concerns, and the `file:line` you read that proves the mechanism (or, for design findings, the facts and the rule). If a behavioral finding has only one citation (the diff), you have not verified it.
- Never harden a hedge. If your own reasoning or a lens says "likely," "implied," "should," "presumably," or "by default," that is an unverified premise. Resolve it by reading the source, or carry the uncertainty into the output verbatim. Do not convert it into a confident assertion.
- Statements in MR threads, the MR description, or my own prior review comments are claims, not evidence - verify them like anything else before a finding rests on them.
- Tag every ranked finding `[verified]` and name the evidence. A finding you cannot tag verified is a hypothesis. Hypotheses are never ranked: they go under "Unverified, worth a look," stating exactly what you could not confirm and the one fact that would confirm it.
- Do not delegate the conclusion. A subagent (lens or otherwise) returns evidence (snippets, `file:line`), not verdicts. Read its evidence and decide yourself; if it hedged, that is your cue to verify, not to trust.

## Output

Ultrathink, then give me:
- two ratings, each 0 to 10, neither allowed to depend on any unverified finding:
  - **Implementation** — is the code, as written, correct, well built, and well tested.
  - **Approach** — is it the right design: right domain, right mechanism, right size. Score the approach the way a senior domain reviewer would; an MR can be a 9 on implementation and a 4 on approach, and I need to see both numbers.
- a list of suggestions ordered from most to least severe, only if applicable. **Tag every item with an explicit severity label as the first token of its heading** (`Critical` / `High` / `Medium` / `Low` / `Nitpick`). Never let ordering alone carry severity: a reader must see the label without inferring it from position. **Immediately under each heading, add a `[verified: <file:line(s) you actually read this session that prove the mechanism>]` line** naming the evidence for every load-bearing premise, not just the central claim. A ranked finding without a `[verified:]` line is invalid output - either produce the line or move the item to "Unverified, worth a look". **On the line directly below the `[verified:]` line, add a `Post at: <file path>:<line or range> (new-side | old-side)` line** giving the single location in the MR diff where I attach this comment. This is distinct from `[verified:]`: the verified line proves the mechanism and may cite several files; `Post at:` names the one spot to paste the comment. It must be a line the MR diff actually contains - give the new-side line for an added or changed line, the old-side line for a removed line. If the code the comment is about is not part of the diff, write `Post at: general MR comment (not in diff)` instead. A ranked finding without a `Post at:` line is invalid output. Rank by evidence and impact together: the higher the severity, the higher the evidence bar. A Critical or High finding whose mechanism you have not traced to source does not belong in this list. Severity reflects real-world impact and reachability, not theoretical correctness: a verified but near-unreachable edge case, or a diagnostic/cosmetic-only issue with no behavior change, is Low or Nitpick even if a bot rated it higher; state your reasoning when you downgrade a bot's rating. When the most severe item is only Low or Nitpick, say so in one line before the list so its top position is not misread as serious. Finding nothing rankable is a valid and good result, say so plainly and never manufacture a headline concern to fill the list.
  - Severity scale (label each item with one):
    - **Critical** - merge blocker: data loss or corruption, security hole, crash, or a requirement the change claims to meet but does not.
    - **High** - likely to bite in normal use: wrong result on a realistic input, missing error handling on a reachable path, a real N+1 on a hot path. Also a verified design choice a maintainer would block the merge on — wrong domain placement, unjustified infrastructure or indirection, a dependency-direction violation — with the violated rule, lesson, or convention cited.
    - **Medium** - real defect on a plausible but non-central path, or a design problem that will cause maintenance pain soon.
    - **Low** - real but narrow: needs an atypical or near-unreachable input, or has diagnostic/cosmetic-only impact with no behavior or scoring change.
    - **Nitpick** - style, naming, wording, doc drift; correct as-is, just cleaner if changed.
- a separate "Unverified, worth a look" section for findings you could not confirm, each naming what is unconfirmed and the one fact that would settle it, only if applicable
- a separate "Reminders" section for anything pre-existing worth my awareness, only if applicable

Don't assume things: if anything is ambiguous, tell me, since that is also feedback on the implementation. For a GitLab MR, every ranked finding uses exactly this layout, in this order, with these literal labels:

1. the severity-tagged heading
2. the `[verified: ...]` line
3. the `Post at: ...` line
4. a paragraph starting with the literal label `Why:` — the blunt explanation of the finding for my eyes only, so I can judge it, and the home of the full evidence chain: every citation, the complete trace, the precedent comparisons. This part is never posted, so anything the author does not strictly need lands here, not in the comment
5. a line reading exactly `Comment to post:` followed by a fenced code block containing ONLY the paste-ready comment

Nothing outside the fence ever gets posted; the fence contains nothing but the comment. Each comment must be self-contained for a reader who sees only the MR page and the repo: it may be the only comment I post, so never reference other findings from this review ("as noted above", "see the High finding") and never use session-internal labels — thread numbers like `T19`, finding IDs, lens names, the briefing, or the journals. To refer to an existing MR discussion, name it the way its participants would ("the earlier thread about `manual: true`"). Citing in-repo files by path and line is fine; naming or quoting the private journals as a source is not — restate the fact in plain words or point at the in-repo rule that backs it. Paste-ready comments must be valid GitLab Markdown: wrap every code identifier (module, function, variable, config key, file path, literal value) in backticks. The fenced code block matters because the terminal renders markdown (copied text loses the formatting characters) — I copy the raw text from inside the fence, backticks and all. Phrase comments as kind, collaborative questions or observations, never as demands or finger-pointing, and keep the technical substance precise. Never write comments in the first person: no `I`, `me`, `my`, and no simulated human reactions ("this surprised me", "happy either way") — there is no person behind these findings and faked personhood reads as pedantic. Keep the conversational tone with impersonal constructions instead: "`X` has no other callers under `apps/`", "it looks like...", "worth double-checking whether...", "should this be...?". State conclusions, not the searches or traces that produced them. Addressing the author with a question ("was the plan to land the UI first?") is fine; speaking as a someone is not. Use plain neutral English with no em dashes, and do not add filler or self-deprecating disclaimers.

**Comment economy.** The comment is the pointer, not the proof — the full derivation already lives in `Why:`. The fence carries only what the author needs to start verifying, in this shape: (1) the claim, stated in the first sentence with no preamble ("Small correction...", "Worth confirming..." openers included); (2) the minimal mechanism, one to three sentences with at most two or three citations — the ones the author would click first; (3) the ask or suggestion, one sentence. Target about 70 words; Low and Nitpick items about 50. Wanting a fourth citation is the signal that material belongs in `Why:` — the author can always ask for more, and `Why:` holds the trace ready when they do. One concern per comment: a finding with independent sub-issues becomes separate findings, or the secondary ones move to `Why:` or Reminders. "Self-contained" means every reference resolves from the MR page and the repo alone, not that the comment carries the whole derivation. A hedge, when needed, is a clause ("appears to", "unless the caller always sends a category"), never a sentence of its own. A model comment at the target size (all names fictional):

> Worth confirming which transport the importer service will use here, because the two behave differently. `/api/v1/catalog/*` sits under `:api_protected`, which declares no `expose_to_service_namespace`, so `RequireAuthenticated` returns `:not_found` for any bearer token (`lib/app_web/plugs/require_authenticated.ex:55-62`). Only the `:internal_rpc` pipeline declares a namespace (`lib/app_web/router.ex:153`), so a service token appears to work over the RPC route only. If RPC is the intended path, the controller tests here cover a caller that will not exist in production. Was the plan for the importer to call over RPC rather than REST?

Claim first, two citations, one question, about 70 words. Everything else that supported the finding (the full pipeline trace, the other five citations) stays in `Why:`.

**IMPORTANT:** never post anything to GitLab. Keep everything local so I decide what to post.

**Pre-output gate:** immediately before writing the final message, re-read the Output section above and walk every candidate finding through the self-check again. Any finding whose `[verified:]` line you cannot fill from files you actually opened this session gets verified NOW (late verification is cheaper than a wrong finding) or demoted to "Unverified, worth a look". For design findings the same gate means: every fact read this session, the rule or lesson cited, and the judgment labeled as judgment. Then re-read every paste-ready comment as the MR author will see it — alone, on the diff, with no access to this session: any reference that does not resolve from the MR page or the repo (internal thread numbers, finding IDs, lenses, journals) gets rewritten to its public form NOW. Then apply the comment-economy check to each fence: claim first, at most three citations, one concern, about 70 words — cut anything the author does not need to start verifying and move it to `Why:`. A comment the author can verify in fewer words gets more engagement, not less. Never ship a ranked finding on the promise that you would probably confirm it.

**Afterwards:** when a human reviewer later finds something on this MR that this review missed, run `/review-retro <MR url>` — it distills the miss into the review-lessons journal so the next run catches it.
