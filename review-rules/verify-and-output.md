# Review rules: lens output contract, verification, and output

Shared by `/deep-review` and `/deep-review-fast`, on purpose: the two commands differ only in how the context is assembled (their Step 1) and how the lenses are briefed and launched (their Step 2). What counts as a verified finding, how the review is written, and what may be posted live here and nowhere else. This file IS the lens output contract, the all-lenses barrier, Step 3, the Output and the `--r2m` layout: read it top to bottom in this session before writing the briefing, and again after any context compaction. Never run these steps from memory or from a summary.

## Lens output contract (copy into the briefing verbatim)

> Return only a list of candidate findings. Each finding has: (1) a one-line claim; (2) a class: `mechanism` (runtime behavior, bug, performance, dead code) or `design` (placement, mechanism choice, dependency direction, convention, test quality); (3) the diff file:line it concerns; (4) every file:line you actually read as evidence, each with a phrase saying what it proves; (5) confidence: `confirmed`, `likely`, or `hypothesis` (keep hedges verbatim, never harden them); (6) a suggested severity (Critical / High / Medium / Low / Nitpick). Return claims and evidence, never verdicts: the orchestrator decides what survives. An empty list is a valid, good result; never manufacture findings.

## The all-lenses barrier: the review is written once, after ALL lenses report

The harness may run the lenses as background tasks: each launch returns immediately, and a lens's findings arrive later as a task notification (sometimes mid-turn, sometimes only when your turn ends) which fires ONCE, when the lens stops, and never again. So beliefs about lens state are worthless in both directions: silence never proves a lens is still running (its findings may already sit in the conversation), and a lens that already stopped will never notify again, so a turn ended to "wait" for it sleeps forever. Before reasoning about a lens's state, check: search the conversation for its delivered findings, then the harness agent list for whether it is actually still running.

- The review (ratings, ranked findings, the entire Output section) is produced **exactly once**, and only after every lens has reported. No partial or provisional review, no "covering" a missing lens yourself, no publish-then-correct. A review that contradicts itself minutes later is far worse than a review that arrives late: the retraction, not the delay, is the failure mode this barrier exists to prevent.
- While lenses are pending, use the time on Step 3 verification of findings already received. When you run out of that work, **end the turn with a one-line status** ("4 of 5 lenses in; waiting on correctness") and nothing else, but only after the agent list proves at least one awaited lens is actually still running; if none is, the findings are already delivered or the lens failed; find out which instead of waiting. Publishing early buys zero wall-clock time: a genuinely running straggler's result lands the second your turn ends either way.
- Never conclude a lens is dead or "too slow" from elapsed time; lens runtimes legitimately differ by two to three times, and a lens that looks stalled has usually just not been deliverable mid-turn. If you genuinely suspect a failure, check the task's status through the harness (its task tools or output file, not TaskList, which tracks to-do items, not agents). If a lens has truly failed, STOP and tell me: relaunching it or proceeding on four lenses is my call, never a silent default.

## Step 3: verify, dedup, rank (yours alone, never delegated)

Verification of individual findings starts as each lens reports, but ranking and the Output section wait for the all-lenses barrier: not one word of the review is written while any lens is outstanding.

Every lens finding is a hypothesis, including the ones marked `confirmed`. Read the cited evidence yourself and decide; a lens that hedged is your cue to verify, not to trust. Merge duplicates across lenses (keep the best-evidenced version), dedup against the MR threads per the MR gate, then walk everything that survives through the two disciplines below.

### Scope discipline: applies to every finding

- Read the full final content of each changed file, not only the diff hunks, including moduledocs and inline comments. If the code or its own docs already answer a question, do not raise it.
- Every ranked finding must cite a line the change under review actually adds or modifies, or be a direct, demonstrable consequence of one.
- Pre-existing or inherited behavior is never a ranked finding, even when it looks relevant to a requirement (for example, the change reuses inherited behavior that may not fully meet the ticket). If it is worth my awareness, put it under a separate "Reminders" section, phrased neutrally as something for me to consider, so I decide whether it deserves a comment. Never phrase it as a defect or anchor it to a diff line as if the change introduced it. If the decision is already documented (MR description, moduledoc, or a thread), do not re-litigate it.
- Final self-check per finding: (a) does the diff actually change this? (b) does an existing thread or the code's own docs already address it? (c) enumerate every premise that, if false, kills the finding - the central claim AND the background premises (flag defaults and rollout state, whether the affected path even runs, config values, test-env behavior) - and for each one: have I read the code that settles it? For any behavioral, performance, or dead-code claim, "I read the diff" does not settle it. If (a) or (b) fails, drop it or move it to Reminders; if (c) is unsettled, move it to "Unverified, worth a look" or drop it.

### Evidence discipline: applies to every finding

This is the sibling of scope discipline. Scope asks "is this finding about the change?" Evidence asks "have I confirmed it is true?" Most unreliable findings pass the first and fail the second: plausible, fluently written, and wrong. More reasoning does not fix an unverified premise; it only makes the wrong conclusion more convincing. The gate below is what fixes it.

- Classify the central claim of each finding before ranking it, and meet its evidence bar:
  - **Static** (a type, a return shape, a missing field, a name, a literal value): confirm by reading the changed file and its direct collaborators.
  - **Behavioral or runtime** (what happens when this runs: retries, async dispatch, transaction and rollback boundaries, error propagation, ordering, concurrency, performance, N+1): you MUST trace it to the code that defines that behavior, the framework module, the worker or job config, the retry or supervision setting, the transaction wrapper. The diff alone never supports a runtime claim. How a library "usually" behaves is not evidence; this codebase overrides library defaults in places the review-lessons journal records; read the actual config. Also search the affected module's test files for the behavior being claimed: an existing test asserting it (or its opposite) is decisive evidence and belongs in the `[verified:]` line.
  - **Dead code, leftover, or unused**: confirm there are no callers, including dynamic, macro-generated, behaviour, and string-based dispatch, before claiming it.
  - **Design or convention** (wrong placement, unjustified mechanism or indirection, dependency direction, a violated convention or contract, weak tests): the bar is different, not lower. Verify every fact the finding rests on by reading it yourself: the namespaces involved, the actual call sites, the rule/convention/lesson text (cite its file:line), what the ticket actually asked for. Then state the judgment explicitly as a judgment. A design finding whose facts are verified and whose rule is cited is rankable at full severity; never demote it to "Unverified, worth a look" merely because its conclusion is a judgment rather than a traceable mechanism. When no written rule or journal lesson backs it, it can still rank on strong reasoning, but its paste-ready comment must be framed as a question: it is taste, not law.
- Cite the evidence, not just the target. A ranked finding names two things: the diff line it concerns, and the `file:line` you read that proves the mechanism (or, for design findings, the facts and the rule). If a behavioral finding has only one citation (the diff), you have not verified it.
- Never harden a hedge. If your own reasoning or a lens says "likely," "implied," "should," "presumably," or "by default," that is an unverified premise. Resolve it by reading the source, or carry the uncertainty into the output verbatim. Do not convert it into a confident assertion.
- Prose proves only itself. A comment, moduledoc, README or config annotation is evidence that the document says X, never that X is true now. That is exactly the right evidence for a convention finding, where the documented rule is the claim. For a claim about current behavior or deployment state, cite the configured value, the code path, or a test that pins it; when the repo cannot settle it, the fence carries the uncertainty as a clause or drops the claim.
- Statements in MR threads, the MR description, or my own prior review comments are claims, not evidence - verify them like anything else before a finding rests on them.
- **Production state** (a count, a volume, whether a row or a configuration exists today): when a finding's severity turns on it, one follow-up agent may run aggregate queries against the data warehouse. Counts and shapes only, never names, ids, rows or personal data; at most one data follow-up per review; the query and its result go in the finding's `Why:` (under `--r2m`, its Details), never in a posted line. A claim about production state that no such query settled stays a hypothesis.
- Tag every ranked finding `[verified]` and name the evidence. A finding you cannot tag verified is a hypothesis. Hypotheses are never ranked: they go under "Unverified, worth a look," stating exactly what you could not confirm and the one fact that would confirm it. Before a hypothesis is listed, try to settle it: when that one fact lives in the repo or the workspace (a grep, a config value, a test, a sibling repo's suite), spend one targeted read or one follow-up agent on it while budget remains, then rank it or drop it. Only a fact outside the repo may be listed without that attempt.
- Do not delegate the conclusion. A subagent (lens or otherwise) returns evidence (snippets, `file:line`), not verdicts. Read its evidence and decide yourself; if it hedged, that is your cue to verify, not to trust.

## Output

Under `--r2m`, the section "The `--r2m` layout" below replaces the ratings, the verdict line, the finding layout, the summary comment and the posting mechanics described here; everything else in this section still applies.

Ultrathink, then give me:
- two ratings, each 0 to 10, neither allowed to depend on any unverified finding:
  - **Implementation**: is the code, as written, correct, well built, and well tested.
  - **Approach**: is it the right design (right domain, right mechanism, right size). Score the approach the way a senior domain reviewer would; an MR can be a 9 on implementation and a 4 on approach, and I need to see both numbers.
- a **Merge verdict** line, mandatory: `request changes: N blocking finding(s)` when any ranked finding is Critical or High, otherwise `approve: comments are non-blocking only` (or `approve: nothing to post` when there are no findings). Follow it with a paste-ready top-level summary comment in a fenced code block, same voice and formatting rules as the finding comments, at most fifteen words: the verdict and, when something blocks, what blocks, nothing else ("left a few non-blocking comments", "one blocking comment on the retry path, the rest is small"). It never lists or restates the findings; they are on the diff. The summary must agree with the per-finding tags: it never says "non blocking" while any finding is tagged `[blocking]`, and a request-changes summary names what blocks.
- a list of suggestions ordered from most to least severe, only if applicable. **Tag every item with an explicit severity label as the first token of its heading** (`Critical` / `High` / `Medium` / `Low` / `Nitpick`). Never let ordering alone carry severity: a reader must see the label without inferring it from position. **Immediately under each heading, add a `[verified: <file:line(s) you actually read this session that prove the mechanism>]` line** naming the evidence for every load-bearing premise, not just the central claim. A ranked finding without a `[verified:]` line is invalid output - either produce the line or move the item to "Unverified, worth a look". **On the line directly below the `[verified:]` line, add a `Post at: <file path>:<line or range> (new-side | old-side)` line** giving the single location in the MR diff where I attach this comment. This is distinct from `[verified:]`: the verified line proves the mechanism and may cite several files; `Post at:` names the one spot to paste the comment. It must be a line the MR diff actually contains - give the new-side line for an added or changed line, the old-side line for a removed line. If the code the comment is about is not part of the diff, write `Post at: general MR comment (not in diff)` instead. A ranked finding without a `Post at:` line is invalid output. Rank by evidence and impact together: the higher the severity, the higher the evidence bar. A Critical or High finding whose mechanism you have not traced to source does not belong in this list. Severity reflects real-world impact and reachability, not theoretical correctness: a verified but near-unreachable edge case, or a diagnostic/cosmetic-only issue with no behavior change, is Low or Nitpick even if a bot rated it higher; state your reasoning when you downgrade a bot's rating. When the most severe item is only Low or Nitpick, say so in one line before the list so its top position is not misread as serious. Finding nothing rankable is a valid and good result, say so plainly and never manufacture a headline concern to fill the list.
  - Severity scale (label each item with one):
    - **Critical** - merge blocker: data loss or corruption, security hole, crash, or a requirement the change claims to meet but does not.
    - **High** - likely to bite in normal use: wrong result on a realistic input, missing error handling on a reachable path, a real N+1 on a hot path. Also a verified design choice a maintainer would block the merge on (wrong domain placement, unjustified infrastructure or indirection, a dependency-direction violation) with the violated rule, lesson, or convention cited.
    - **Medium** - real defect on a plausible but non-central path, or a design problem that will cause maintenance pain soon.
    - **Low** - real but narrow: needs an atypical or near-unreachable input, or has diagnostic/cosmetic-only impact with no behavior or scoring change.
    - **Nitpick** - style, naming, wording, doc drift; correct as-is, just cleaner if changed.
  - Anti-downgrade rules, applied after choosing a tentative severity and overriding the general reachability guidance above: (a) a written rule the diff violates ranks as written; uneven adoption of that rule elsewhere in the codebase never downgrades it; (b) a defect in the exact behavior the MR exists to change is High at minimum; reachability arguments cannot demote it, because the MR's own premise establishes that the path matters.
- a separate "Unverified, worth a look" section for findings you could not confirm, each naming what is unconfirmed and the one fact that would settle it, only if applicable
- a separate "Reminders" section for anything pre-existing worth my awareness, only if applicable

Don't assume things: if anything is ambiguous, tell me, since that is also feedback on the implementation. For a GitLab MR, every ranked finding uses exactly this layout, in this order, with these literal labels:

1. the severity-tagged heading
2. the `[verified: ...]` line
3. the `Post at: ...` line
4. a paragraph starting with the literal label `Why:`, the blunt explanation of the finding for my eyes only, so I can judge it, and the home of the full evidence chain: every citation, the complete trace, the precedent comparisons. This part is never posted, so anything the author does not strictly need lands here, not in the comment. It is also the reply, ready to paste, for when the author answers the comment with "where?" or "why?", which is what lets the comment itself stay short
5. a line reading exactly `Comment to post [blocking]:` or `Comment to post [non-blocking]:` followed by a fenced code block containing ONLY the paste-ready comment. The tag is derived from the severity label, never judged independently: Critical and High → `[blocking]`; Medium, Low, and Nitpick → `[non-blocking]`. It repeats the merge verdict at the moment of pasting, in reviewer vocabulary; it never goes inside the fence

Nothing outside the fence ever gets posted; the fence contains nothing but the comment. Each comment must be self-contained for a reader who sees only the MR page and the repo: it may be the only comment I post, so never reference other findings from this review ("as noted above", "see the High finding") and never use session-internal labels: thread numbers like `T19`, finding IDs, lens names, the briefing, or the journals. To refer to an existing MR discussion, name it the way its participants would ("the earlier thread about `manual: true`"). Citing in-repo files by path and line is fine; naming or quoting the private journals as a source is not; restate the fact in plain words or point at the in-repo rule that backs it. Paste-ready comments must be valid GitLab Markdown: wrap every code identifier (module, function, variable, config key, file path, literal value) in backticks. The fenced code block matters because the terminal renders markdown (copied text loses the formatting characters); I copy the raw text from inside the fence, backticks and all. Write comments the way a teammate writes on a colleague's diff: one or two sentences, direct, the ask phrased as a question, contractions welcome, a lowercase opener fine. Kind and collaborative, never a demand or finger-pointing. Keep the technical substance precise, but assume the author knows their own code: name the identifier in backticks rather than its path, and explain a mechanism only when it lives outside the file the comment is anchored to. Never write comments in the first person: no `I`, `me`, `my`, and no simulated human reactions ("this surprised me", "happy either way"), since there is no person behind these findings and faked personhood reads as pedantic. The same goes for borrowed personal texture: no typos, no interjections ("huh", "hm"), no imitating how one particular colleague types. Keep the conversational tone with impersonal constructions instead: "`X` has no other callers under `apps/`", "it looks like...", "worth double-checking whether...", "should this be...?". State conclusions, not the searches or traces that produced them. Addressing the author with a question ("was the plan to land the UI first?") is fine; speaking as a someone is not. Use plain neutral English with no em dashes, and do not add filler or self-deprecating disclaimers.

**Comment economy.** The comment is the pointer, not the proof. The full derivation already lives in `Why:`, and the author can ask for it. The fence carries only what the author needs to start verifying: (1) the claim, in the first sentence, with no preamble ("Small correction...", "Worth confirming..." openers included); (2) the consequence, or the one mechanism sentence the author cannot see from the anchored line; (3) the ask, as a question. Size follows severity:

- **Medium, Low and Nitpick:** one or two sentences, 20 to 40 words, no file:line citations. The comment sits on the line it is about, so that line is the citation; name an identifier in backticks instead of a path.
- **High and Critical:** up to about 55 words, one mechanism sentence, and at most one citation, only to a file other than the one the comment is anchored to. A blocking claim needs enough for the author to weigh it on the spot, without a round trip.

Wanting a second citation is the signal that material belongs in `Why:`. One concern per comment: a finding with independent sub-issues becomes separate findings, or the secondary ones move to `Why:` or Reminders. "Self-contained" means every reference resolves from the MR page and the repo alone, not that the comment carries the derivation. A hedge, when needed, is a clause ("appears to", "unless the caller always sends a category"), never a sentence of its own.

Before and after, at the sizes above (all names fictional):

> **Too heavy, about 80 words and three citations:** Because `active?/1` reads only `ends_at` (`lib/billing/finders/subscription_active.ex:34-35`), a pending `:premium` subscription with `starts_at: nil` counts as premium, and that bucket is then dropped at `lib/billing/handlers/limits.ex:53`. During the pending window the effect runs opposite to the safety argument in the moduledoc: the account leaves the limited set while its in-effect plan is still the standard one. `FilterAccountsByPlan`'s moduledoc (`:23-30`) names the same divergence as its reason to exclude pending rows. Can a stale un-started subscription outlive activation onto a standard plan?
>
> **Right size, Medium, 40 words:** a pending `:premium` subscription with no `starts_at` already counts as premium here, so an account still on the standard plan comes back empty and can't be limited at all. is that intended for the window before the contract is signed?
>
> **Right size, Low, 24 words:** worth a case where the subscription already ended? that's the branch that makes an account limitable again and every fixture here is `ends_at: nil`.
>
> **Right size, High, about 50 words:** `sync_status/2` now returns `:ok` for every error tuple, not just `:not_found`. `fetch_account/1` also returns `{:error, :suspended}` (`lib/accounts/finders/fetch_account.ex:41`), and that one used to raise into the error tracker, so a suspended account now goes silent on this path. Should the match narrow to `:not_found`, or should the other branch report?

The Medium keeps the claim, the consequence and the question; the mechanism and the sibling module's precedent stay in `Why:`, ready for the reply. The High keeps one mechanism sentence and one citation because the author has to weigh a blocking claim on the spot.

**IMPORTANT:** never post anything to GitLab on your own initiative. The review itself always lands local, as paste-ready blocks, so I decide what to post. Producing the review is never an occasion to post, and you never offer to.

Posting is unlocked only by me asking for it, and the unlock works exactly like `git push`: one explicit instruction authorizes one posting action, covering the findings I named in it, and then the authorization is spent. It never carries into the next turn and never becomes standing permission; a follow-up like "looks good" or "thanks" is not a fresh instruction. If the scope of what I asked for is ambiguous (which findings, how many threads), ask before posting rather than guessing, since posting to a colleague's MR is outward-facing and cannot be taken back. Once I have asked, do it rather than re-litigating the rule. Afterwards, state plainly what went up and that the authorization is spent.

**Pre-output gate:** first, the barrier: confirm every lens has delivered its findings into this conversation. If any has not, this message must not contain any part of the review; end the turn with a one-line status instead, per the all-lenses barrier above. Then, immediately before writing the final message, re-read the Output section above and walk every candidate finding through the self-check again. Any finding whose `[verified:]` line you cannot fill from files you actually opened this session gets verified NOW (late verification is cheaper than a wrong finding) or demoted to "Unverified, worth a look". For design findings the same gate means: every fact read this session, the rule or lesson cited, and the judgment labeled as judgment. Then re-read every paste-ready comment as the MR author will see it, alone, on the diff, with no access to this session: any reference that does not resolve from the MR page or the repo (internal thread numbers, finding IDs, lenses, journals) gets rewritten to its public form NOW. Then read each fence against its own `Why:` paragraph and the "Unverified, worth a look" section: when the fence asserts something those call unsettled, the fence is wrong, not them, so add the hedge as a clause or cut the claim. Then apply the comment-economy check to each fence: claim first, one concern, the ask as a question, and the budget for its severity (20 to 40 words and no citations for Medium and below; about 55 words and at most one citation for High and Critical). Cut anything the author does not need to start verifying and move it to `Why:`. Read the fence once more as a teammate's comment on the diff: if it reads like a report, shorten it. A comment the author can verify in fewer words gets more engagement, not less. Then run the mechanical fence checks on every comment: no em dashes anywhere inside a fence; any concrete code a comment proposes must be legal at the location it names (for example, an Elixir guard cannot call a remote function; suggest the form that works instead); and every file path cited in a fence or `[verified:]` line must resolve in the repo, since a path cited from memory is a path you have not checked. Last, check agreement: the merge verdict, the summary comment, and every `Comment to post [blocking|non-blocking]` tag must all be consistent with the severity labels; fix any mismatch now. Never ship a ranked finding on the promise that you would probably confirm it. Under `--r2m`, the comment-economy, voice and tag checks in this gate are replaced by the checks in "The gate under `--r2m`" below; the rest of this gate applies as written.

## The `--r2m` layout

`--r2m`, given after the link on either command, writes the review to be posted as-is, in the note layout of the automated reviewer my team runs on its MRs, so a note from this review and a note from that reviewer are indistinguishable on the MR page. Nothing before the Output changes: the MR gate, the lenses and their output contract (the lenses are never told about the flag and keep suggesting the five-step severity), Step 3's scope and evidence discipline, and the barrier all apply as written. What changes is the vocabulary of the findings, the shape of every text that can be posted, the final message, and how posting works. Where this section and the Output section disagree, this section wins under the flag; where it is silent, the Output section applies: "Unverified, worth a look", the posting unlock, the barrier part of the pre-output gate, the teardown offer and the retro pointer. On the Linear-ticket path the flag only changes the layout; there is nothing to post.

### Levels instead of severities

Every ranked finding carries one of four levels. Assign the level by these definitions first, then check that the mapping below agrees; when they disagree, the definitions win, because the level is a judgment about the merge, not a relabeling:

- **Blocking**: the MR cannot merge as it is. It solves the wrong problem, or the right one the wrong way, the code is wrong, or there is a real product, security, data or production risk. A repo rule blocks only when it protects one of those; a code-style rule never does.
- **Should fix**: something serious to fix in this MR before it is approved. The author may decline, with a reason, a case that needs two or more independent unlikely events, never a security, permissions or data-loss case.
- **Optional**: a minor point the author can take or decline; it never holds the approval. A title or description that no longer matches the code is Optional, since the code is what merges. Style, naming and wording are Optional at most, and a point a linter catches is not posted at all.
- **Pre-existing**: a real problem this MR did not introduce. It goes in the overall comment, never in a thread, so it never blocks and never reads as the author's fault. The Output section's Reminders land here under the flag.

Mapping from the severity you would otherwise have given: Critical and High become Blocking; Medium becomes Should fix; Low and Nitpick become Optional. The anti-downgrade rules apply unchanged: a written rule the diff violates ranks at the level its protection earns, and a defect in the exact behavior the MR exists to change is Blocking.

A design preference that no written rule or verified behavior backs is not a note under this layout, whatever its merit: list it for me in one line each under **Not posted, your call**, after the review, so I raise it in my own words if I want to.

### Areas

Every note also carries one area, and the overall comment has one line per area, always all five:

- **Product fit**: does it solve the right problem for the people who use it, the way their work really goes.
- **Design**: is it the simplest fit for the domain and the existing code, and what does it make hard later. The structure and placement of tests go here.
- **Correctness**: code that is wrong: a wrong result, a crash, lost or duplicated data, a case it misses. Untested or wrongly tested changed behavior goes here.
- **Security and data**: permissions, personal and customer data, secrets, what is stored and logged.
- **Risk**: what can break in production, at real volumes, and how it is switched off or undone. Performance at scale lives here.

### The note

Each Blocking, Should fix or Optional finding whose `Post at:` is a diff line is rendered as the note exactly as it will appear on the MR, in a fenced code block. A finding whose `Post at:` is `general MR comment (not in diff)` is never rendered as a note fence: it appears once, in its one-line form inside the overall comment under "Not on a changed line", which is exactly how it will be posted. Before settling on `general MR comment`, look for the changed line the finding follows from (the sentence the MR added, the clause it removed, the test it changed) and anchor there when one exists: a thread on the diff reaches the author, a line in the overall comment rarely does.

```
**<Level> · <Area>: <title>**

- **What goes wrong:** <one or two short sentences>
- **Why it matters:** <one or two short sentences, saying for whom>
- **What to change:** <one or two short sentences>

<details><summary>Details</summary>

<the evidence: quoted words, numbers, paths, precedent>

</details>

> on behalf of <my name as GitLab shows it>
```

Its text follows these rules, which replace the Output section's comment economy, voice and size rules:

- The title is the problem in a few plain words, on one line, at most 90 characters.
- Each of the three lines makes sense on its own to someone new to the code: one or two short sentences in plain words, the meaning before any identifier or shorthand, no metaphors, and no review-internal terms (lens, briefing, journal, finding IDs, thread numbers). Quote the words the note is about rather than pointing at a line by number; a bare line reference such as ":86" is refused at posting.
- "What to change" states what to do; it is not phrased as a question. The voice is plain and impersonal: never first person, never "my rule" or "I asked for" (refused at posting), no simulated reactions, no em dashes.
- Evidence, quotes, numbers and precedent go under Details, folded, never in the three lines. Details replaces the Output section's `Why:` paragraph: the derivation is written once, for the author, and nothing is kept for my eyes alone. Omit the whole Details block when there is no evidence worth the author's time.
- A note rests on a written rule in the repo, cited by path with the words quoted, or on code behavior verified per Step 3. The same mistake in several places is one note that names the class and lists every place.
- One concern per note. Identifiers (modules, functions, files, options, atoms) are written plain, without backticks, in the title, the three lines and the overall comment's lines, the way the team reviewer writes them; Details may use backticks. The fence contains nothing but the note, and nothing outside a fence is ever posted.
- My GitLab display name comes from `glab api user` (its `name`, falling back to `username`); never guess it.

### The overall comment

Rendered once, in its own fence, after the notes, exactly as it will be posted as the review's summary. Bracketed parts appear only when they apply:

```
[**Waiting for <name>'s own approval: high risk (<reason>).**  <- high risk, nothing Blocking or Should fix]
[**High risk (<reason>): <name> approves it once nothing serious is left.**  <- high risk, something serious]

- **Product fit:** <one plain line>
- **Design:** <one plain line>
- **Correctness:** <one plain line>
- **Security and data:** <one plain line>
- **Risk:** <one plain line>
- **Access change:** <No access change | Not checked: <what the diff touches>>

<the verdict and the main reason, one to three short sentences>

[Already raised in another thread (agreed, and counted below):
- **<Blocking | Should fix> · <Area>:** <the point, and who raised it where>]

[Not on a changed line:
- **<Level> · <Area>:** `<path>:<line>`: <title>: <what goes wrong> <what to change>]

[Pre-existing, not introduced by this MR (these never block):
- `<path>:<line>`: <title>: <what goes wrong> <what to change>]

**Open now:** Blocking: <n> · Should fix: <n> · Optional: <n>      (or: **Open now:** nothing.)

> on behalf of <name>
```

- One plain line per area, always all five: what the review found there (naming the note it led to as "(note below)"), or in a few words that it looked and found nothing. The area lines and the verdict follow the note's writing rules: plain words, the meaning before any ID, no ticket IDs, MR references or acronyms as shorthand (say what the ticket asks for, not its number), no review-internal terms, and no account of how something was checked (a query, a replica, a search, a lens): the result goes in the line, the method stays out or goes under a note's Details.
- **Access change** is a result this command does not fully produce: the full access review is not part of it. Write `No access change` only when you verified that the diff changes nothing that decides who can see, receive or do something (permissions, policies, roles, visibility, recipients, data scoping); otherwise write `Not checked: <what it touches>`. Never `Passed` or `Failed`.
- The verdict is one sentence in the team reviewer's idiom: `Approved: <the main reason>` when nothing Blocking or Should fix is posted and the MR is not high risk (I approve it on GitLab right after posting; the final message reminds me); `Not approved yet: <what stands, the Blocking and Should fix points in plain words>` when something Blocking or Should fix is posted; and on a high-risk MR a sentence on what stands without either word ("Two Should fix notes stand: ...", "Nothing serious found: ...").
- **Already raised**: a Blocking or Should fix that someone else raised in a thread and Step 3 confirmed is listed here and counted, never posted again as a note; the MR gate's follow-up on the existing thread stays available on my instruction.
- **Not on a changed line**: a note whose `Post at:` is `general MR comment (not in diff)` is listed here instead of becoming a thread.
- **Open now** counts the Blocking, Should fix and Optional notes being posted plus my earlier notes with those labels still open on the MR, from the gate's thread retrieval: a Blocking or Should fix one counts until I resolved it myself, an Optional one until anyone did.
- The review state is Request changes when any Blocking note is posted or already raised, otherwise Reviewed.
- **Risk** is high when the diff touches auth, permissions or secrets, a migration, anything that moves money or decides whether it moves or changes financial records, personal data, CI or infrastructure, or a public or partner API; medium for application or backend logic, a new external call or a large diff; low for copy, docs, styling or tests only. A high-risk MR is approved by me, never by tooling, and its overall comment opens with the high-risk line.

### The final message

1. `Verdict: Request changes (<n> Blocking)`, or `Verdict: Reviewed, approval withheld (<n> Should fix)`, or `Verdict: Reviewed, nothing holds the approval`, followed by `Risk: <low | medium | high (<reason>)>`. No ratings.
2. The notes, most serious first (Blocking, then Should fix, then Optional), each as exactly three parts: the `Post at:` line, the `[verified:]` line, both as the Output section defines them, then the note's fence. No severity heading or level line outside the fence, no `Why:` paragraph, no `Comment to post` label, and no sections beyond the ones listed here. A note missing either line is invalid output.
3. The overall comment's fence.
4. "Unverified, worth a look" as in the Output section, then **Not posted, your call** when there is anything in it.
5. Then as the Output section says: the fast variant's budget line, the teardown offer when there is a worktree, and the retro pointer.

### Posting under `--r2m`

Posting is unlocked only by my asking, one instruction for one action, exactly as the Output section says. What changes is the mechanics, because a hand-pasted note and a posted review are not the same thing on the MR page: the automated reviewer publishes the notes and the overall comment together as one review, signed, labelled, with a hidden machine-readable line on the overall comment that carries the reviewed head and the counts of Blocking and Should fix notes, which the approval tooling reads.

- The posting script is machine-local: read `~/.claude/journals/review-posting.md` at posting time. It names the script's absolute path and the form of its arguments (the MR reference, the reviewed head sha, the review file). The script's own header documents the file it takes: read the header (`sed -n '/^# Usage:/,/^set /p' <script>`), build the file in the scratchpad from the notes I authorized and nothing else, run the script, and show its output verbatim. The script signs, labels, publishes as one review, sets Request changes when a Blocking note is in it, and writes the hidden line: never write any of those yourself when the script is available, and never work around one of its refusals (the head moved, pending notes of mine on the MR, a wording it rejects) with direct API calls. A refusal is shown to me and ends the action.
- **The posted set is what I named.** The file holds exactly the notes I authorized, and the overall comment is recomposed for that set at posting time: its verdict, its area lines, its review state and the counts in its hidden line describe what goes up, never a note I dropped. When dropping a note changes the verdict (the only Blocking one, say), say so in one line before posting and recompose; never post a verdict the posted notes no longer support.
- Post in one action when you can. A second posting action on the same head adds a second overall comment whose counts include the first one's notes still open; say so when I ask for a second batch.
- When the journal is missing, or names a script that is not there, say so in one line and post the authorized notes directly with `glab api`: each note as a diff discussion at its `Post at:` position on the MR's latest diff version (new side or old side as given), the overall comment as a plain MR note, each with its signature line and nothing else. That path adds no label, no hidden line and no review state, so the approval tooling will not recognise the review; say that in the report of what went up.

### The gate under `--r2m`

In the pre-output gate, the comment-economy, voice and tag checks are replaced by these, applied to every fence: the heading carries a level, an area and a title of at most 90 characters; the three lines are present, each one or two short sentences, with no bare line reference, no first person, no "my rule" or "I asked for", identifiers plain and no ticket ID, MR reference or acronym used as shorthand; the evidence sits under Details; the signature line closes the note. For the overall comment: the same writing checks on every line; all five area lines present; a finding not on a diff line appears only there, never as a note fence; the access line is one of its two allowed forms; the Open now counts match the notes and my open threads; the verdict's opening word agrees with the levels and the risk. Everything else in the gate applies as written: the barrier, the verification of every `[verified:]` line, the public-form check, no em dashes inside a fence, and every cited path resolving in the repo.

**Review worktree teardown:** when Step 1 created a review worktree, end the review's final message with one line offering to remove it now that the review is delivered; keeping it is the right call if I expect follow-up questions that need the code readable. On my acceptance: `git worktree remove <path>`, run from outside it. It is clean by construction (the review writes nothing there); if git reports it dirty anyway, STOP and show what changed instead of forcing. The saved diff and briefing live in the scratchpad and survive teardown. This offer is local housekeeping; it never interacts with the posting rules above.

**Afterwards:** when a human reviewer later finds something on this MR that this review missed, run `/review-retro <MR url>`: it distills the miss into the review-lessons journal so the next run catches it.
