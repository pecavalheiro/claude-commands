# /investigate-ticket

Open the Slack thread I'll provide: a support escalation, a CX question, an ops request, or a suspicion about production behavior. The deliverable's shape depends on what the thread actually needs (Step 0.5 decides), but the method never varies: every claim backed by evidence gathered this session, labeled by its evidence class, cross-checked in both directions, and adversarially audited before anything reaches me as final. Nothing is assumed, nothing is guessed, and nothing is posted or executed without the explicit unlocks at the end. Every discipline and prohibition below is binding, not advisory.

## Step 0: environment, then the thread

1. Read `~/.claude/journals/investigation.md`, the machine-local environment file (in no repo, never installed or committed) naming the backend and frontend repos and their local paths, the internal admin tool, the data-warehouse and telemetry connectors, and tool-specific patterns from past investigations. Unlike the other journals, this file is load-bearing: if it is missing, say so and ask me for the environment instead of guessing paths or names.
2. Read `~/.claude/journals/domain.md` if present (accumulated domain facts) and `~/.claude/journals/investigation-lessons.md` if present (lessons from past cases, written by `/investigate-retro`; every entry is binding on this case, and audit item 8 walks them). Missing is a normal state for either: note it in one line and continue.
3. Read the FULL thread, not just the linked message. The thread is the source of truth for what is asked, what has been claimed, and by whom. If I pointed at a specific message, that message defines the ask.
4. Harvest every identifier the thread carries into a scratchpad file: company/entity slugs and IDs, admin-tool links, ticket and issue references, and each human claim with its timestamp ("done", "sent", "customer saw nothing this morning"). Those timestamps get cross-referenced against production later.
5. Triage and helper bots post confident step-by-step answers in these threads. Bot output (like every thread claim by anyone, colleagues included) is a lead to verify, never a fact; a confident, plausible bot answer can point the wrong way.
6. Record participant names only. Roles, teams, and seniority are unknown until looked up (people rule, in the audit).

## Step 0.5: shape the deliverable (three modes)

Decide from the thread which resolution is being asked for, and state the chosen mode in the findings. Modes compose: a verdict investigation can end in an action; an answer thread can surface a product gap. When genuinely ambiguous, ask me one targeted question instead of guessing.

- **Answer mode**: the thread contains explicit questions from a named asker. The deliverable is those questions answered, verbatim (Output contract A).
- **Verdict mode**: a symptom, complaint, or suspicion with no explicit questions ("customer says they see nothing", "is something broken here?"). The deliverable is a verdict: what actually happened, by what mechanism, and what, if anything, anyone needs to do. **"False alarm, nothing is broken, no customer action" is a valid and good verdict; never manufacture a defect to justify the investigation** (Output contract B).
- **Action mode**: the ask is a state change (enable, reclassify, backfill, re-send). The deliverable is a verified plan, the gated action itself, and post-action proof (Output contract C).

An investigation is long-lived: follow-up questions arrive over days, from new people. Each one re-enters the loop at this step, with the same evidence bar, its own mode, and its own audience and length calibration (see the draft register). It is never answered from memory of the case because "we already know this one."

## Step 1: the code (find the rule)

In the backend and frontend repos named by the environment file, grep from the thread's domain words to the exact code producing the behavior, typically some of: the worker or job performing the action (ownership annotations name the owning team, so record it), the config gating who receives what and the recipient resolution, the permission model end to end (role definitions, permission conversion, what each route, controller, and frontend surface requires), and every fallback surface a customer might be told to check, with what each one gates on. In action mode, also find the sanctioned script or mechanism for the requested change and read what it actually does.

The code yields the **rule** (what the system is built to do), always cited as file:line. The code never proves what happened in production; that is Steps 2 and 3. Prefer running the app's own functions against real data (a scratchpad script through the app's runner) over hand-simulating logic; when the build won't cooperate, derive from source and label the derivation as such.

## Step 2: production state (the data warehouse)

Query through the warehouse connector named by the environment file: its curated query recipes first, and describe a table before writing SQL against any identifier not already seen this session. Pull the actual rows: status fields and timestamps, job rows (state, attempts, errors, and args, since job args often carry the literal recipient or target list, the strongest evidence of who an action touched), the notifications actually created and for whom, the affected user's roles, stored permissions, and history.

Run the **negative** queries too, not just the confirming ones: who is absent from a list, which rows do NOT exist, what never got enqueued. Every absence claim names the query that would have found the row, and that query is proven able to find one: run it where a positive is known to exist, and never read a zero from a column whose values come back redacted, masked or truncated. An automation that demonstrably fires in general has not been shown to fire for this case until this case's own row is found.

## Step 3: runtime (telemetry)

Through the telemetry connector named by the environment file: traces and request-level events, both the job's trace (state, error flag, timing matched against the thread's human timestamps) and the affected user's own footprint: their requests against the surfaces in question, sign-ins, errors. A 403 in the user's own request log turns a permission analysis from inference into observation and is routinely the strongest single piece of evidence in a case. Search for it now, in the main pass, not during the audit.

## The external-system boundary

Our code and data prove things only up to the edge of our own systems. When the mechanism crosses into an external vendor system (a verification provider's review queue, a mail provider's delivery pipeline, a webhook contract), the boundary is where assertions stop:

- Never assert how the external system behaves (what moves its states, who works its queue, what it will send us) from our side alone. State what is proven up to the boundary, mark the other side explicitly unknown, and ask me: I may have access myself, or can attach a connector mid-session. Saying "unknown, checking" is always better than a plausible guess about what the external system "needs" or will do.
- A comment in our code describing a vendor's behavior is a claim, not evidence. It may shape a hypothesis, never a stated fact.
- When a vendor connector is available (or appears mid-session), use it to settle exactly the boundary claims, and re-audit every earlier sentence that leaned on an assumption about that system. Vendor systems are READ-ONLY: never create, update, or trigger anything in them; the unlocks below do not extend there.
- Connector auth failures (including per-tool authorization errors) are access limits: report exactly which calls failed and how, list the precise calls I could run myself and what each would settle, and never work around a failed connector by assuming the answer.

## Cross-check discipline: both directions, before any claim is stated

- **Rule → data**: everyone the code-derived rule selects shows the effect in production, and everyone it excludes doesn't. One direction alone is a hypothesis, labeled as one. A second affected party found by a shared attribute is not yet selected by the rule: re-run on them the per-subject checks that established the first one before saying they are blocked the same way.
- **Data → rule**: every production observation traces back to the code that produces it. An unexplained row or timestamp near the incident is an open question, not color: identify it (who, targeted or bulk) and either integrate it or show it doesn't move the conclusion.
- **The positive twin**: the rule explaining what's missing must also explain what's present (what the user DID receive, what DID work), or the rule is wrong.
- Timestamps cross-referenced against the thread's human claims; agreement and disagreement are both findings.
- Where possible, confirm conclusions at more than one point in time (the same exclusion months earlier is corroboration).

## Fact vs inference: label everything, blur nothing

Every statement carries its evidence class, in the findings and in customer-appropriate wording in any draft:

- **Observed production fact**: a named warehouse row or telemetry event read this session.
- **Code-derived inference**: cited file:line, phrased as how the system is built ("going on how the flow is built rather than a worked example").

An inference never borrows an observation's confidence. When production offers no worked example of a code-derived rule, say exactly that. A sentence supported by neither class is dropped, not softened.

**The remedy carries the same bar as the diagnosis.** "Do X and it works" is a claim: it needs the file:line or the production rows showing that X changes the condition producing the behavior, and it gets a class label like every other sentence. The obvious inverse of a cause is a hypothesis, not a fix, and it is the one sentence the reader will act on. A remedy also names where it lands: the file, endpoint, screen or document it changes, and what a named person in the thread would have seen or done differently. "Make it visible", "flag it", "add an SLA" are not remedies until that is filled in, and one that turns out to be a request to another person is labeled as a conversation to have, not an item to build.

**A negative is bounded by what was actually searched.** "There is no way to do X" names the repos, trees and callers searched and claims nothing past them. Reading part of a file is not reading it.

Claims about what a user sees or clicks are their own trap: a concrete UI element named in a draft (a checkbox, a button, a tab) must be verified in the frontend code or on an actual rendered surface. Backend definitions never prove a UI noun: "the permission exists" does not make it a real checkbox.

**Access limits are stated plainly, never papered over.** "Dispatched without error" is not "delivered"; no access to a provider's delivery logs means saying so and bounding it with the evidence that does exist. Redacted or unavailable data is named as such. Implying proof beyond actual access is a correctness bug.

## Action mode: the gate around any state change

Investigation first proves the action is right: the current production state, why it is in that state, and that the proposed mechanism is the sanctioned one. That means the actual script or function read, its preconditions checked against real data, and its side effects (emails, jobs, notifications) enumerated. Then:

1. Present the plan to me: each precondition verified (with its evidence class), the exact invocation, the expected side effects, and how the result will be verified.
2. **The run is locked exactly like posting** (see Unlocks): one explicit go-ahead authorizes one execution and is spent.
3. **Post-verification is mandatory**: after running, re-query the warehouse and telemetry to prove the state changed and the side effects actually fired. No "done" reply is drafted from the script's own exit status alone.

## The audit: mandatory, after drafting, before anything reaches me as final

Draft first, then adversarially attack the draft: assume it contains a wrong claim, an unsupported claim, or missed evidence, and go looking for them. Walk every sentence through:

1. **Does the cited evidence actually demonstrate this specific claim?** Re-read the rows, re-read the cited lines, and check what they ARE, not just that they exist. In data: a count of three records cited as proof of "one per entity" when the rows were retries on a single entity, a true count attached to a false characterization. In code: a real file:line cited for a branch that does not make the decision the claim hangs on it, while the deciding condition sits a few lines away, unread.
2. **People and teams: looked up, never inferred.** Every name attached to an escalation, cc, or role gets its Slack profile read NOW. Team ownership comes from code ownership annotations and telemetry team fields on the component that actually fails, never from who talks in the thread, and never from who wrote the code: authorship tells you who knows it, not who to ping. An annotation on a shared runner (a job framework, a scheduler) names the runner's owner, not the owner of every payload it runs; when the failing file has no owner, say so instead of borrowing the runner's. If the owning team is already in the thread, there is nobody to "raise it with" and no escalation line belongs in any draft. The check covers pronouns, not just names: "us", "them", "our team", "the X team" and "hand this to Y" are ownership claims too, and the first one to resolve is my own position. Before any of them reaches a draft, confirm which teams I am on and whether the sentence puts me outside one of them, and confirm that a team whose name matches a business function is the group actually meant and not that function's operational group.
3. **Anything unsupported is dropped**, not hedged into staying.
4. **What did I not look at?** The affected user's own request log, sign-in events, role or state changes around the incident timestamps.
5. In verdict mode: one-off or pattern? Count it in the warehouse: recurrence turns an anecdote into a product finding and belongs in the findings either way. Then read how the earlier cases were closed: the route that cleared them (a channel, a form, a named person) is the remedy for this one. A remedy that names no route is not finished.
6. **Boundary check.** Any sentence asserting how an external system behaves must cite evidence from that system's side (its connector, its logs). Otherwise, rewrite it as explicitly unknown or being checked.
7. **Audience check on every outward line.** Who reads this draft, and what is my role in the thread? Engineering work never leaves the findings; UI nouns are verified; the length fits the question that was asked.
8. **Lessons check.** Walk every entry of the lessons journal against this case. A trigger that matches and an action that was not taken is a defect to fix now, not a note.

## Output

First, the findings for me, my eyes only. They open with at most five lines: the verdict, what the draft asks and of whom, and each decision waiting on me with a recommendation. When the ticket is mine, a defect found in it is offered to me first; code ownership decides who approves the change, not who makes it. The detail follows (mode, mechanism, evidence per claim with its class label, limitations and access limits), cut to what supports a claim or a decision. The halving rule of the draft register applies here too.

Then the mode's deliverable. Every Slack draft is paste-ready in a fenced code block, Slack formatting (`*bold*`); after the fence, flag the judgment calls I should decide before posting (who is named, detail level, what belongs in a separate message or ticket). **No em dashes anywhere in a draft or any customer-facing text**: commas, colons, or separate sentences. Customer-facing wording is translated (a 403 becomes "the platform returned Forbidden") while staying exact.

**The draft register** is how every Slack draft reads, regardless of mode:

- **Scaled to the asker.** A one-line question gets a few sentences back; the detail lives in the findings, never the draft. When a draft feels complete, halve it: verbosity is the default failure and the first version is always too long. Respect people's time.
- **Conversational, in my voice.** As I would type it: no header-and-bullet scaffolding on a short reply, no fake-positivity openers, nothing that reads as "AI structured this and I pasted it." Plain, simple words: I am not a native English speaker and neither are many readers. The voice matches my actual position in the thread (for example, new to a domain: "what I found and what I assume the right change is").
- **True to the posted state.** The thread contains only what I actually posted. Never phrase a draft as correcting or updating an earlier message of mine that was never sent: a draft has no history until I post it. It is also new to the thread: a point someone already made is credited to them in a clause or dropped, never restated as mine, and a thread claim the draft states as fact needs its own row first.
- **Interim is valid.** When a boundary or a pending check blocks the full answer, the right draft states what is established and what is still being checked, phrased as checking, never guessed at.
- **Audience and role.** Establish my role in the thread (usually the investigating engineer) and who will read the draft. An engineering follow-up (check a webhook subscription, run a script, re-point a job) is my own work item: it goes in the findings addressed to me, never into a draft as an ask of product or non-technical people.

**A. Answer mode.** The headlines are the asker's questions, **verbatim**: original wording, original order, one answer under each, no question skipped, merged, or rephrased (a false premise is answered under the verbatim headline, not edited away), and nothing inserted between them. Findings beyond the questions go AFTER a visible divider, explicitly framed as beyond what was asked, and are offered to me as optional before being included at all.

**B. Verdict mode.** The verdict in the first line, including (when true) that nothing is broken and no customer action is needed. Then the mechanism in the requester's frame, what to tell the customer, and the recurrence count. Product follow-ups (a UX gap, a prevention idea) form a separately labeled block after the customer answer, never mixed into it, so I decide what goes where.

When the investigation finds a real defect, the bug, its mechanism, and the fact that it needs fixing always belong in the draft: no correction about process ever removes them. The process around the bug (ticket or no ticket, who fixes it) is my call: ask once, with a recommendation, and never unilaterally propose process steps in a draft. Once I decide, the draft speaks as me in first person ("I'll create a ticket and work on the fix"). If I ask for a ticket draft, use the template defined in `/refine-ticket` and show it here first.

**C. Action mode.** Before the unlock: the verified plan per the gate above. After post-verification: a short confirmation draft stating what was run and what the re-queried production state now shows, never the exit status alone.

## Revisions: change what was corrected, nothing else

When I correct a draft, the next version changes exactly what the correction names and keeps everything else intact: content, structure, and wording. A correction is never a license to restructure, shorten elsewhere, or drop other material: "no ticket", for example, is not a reason to also drop the bug explanation. Say in one line what changed. When I ask for a shorter draft, length comes out of explanation and scaffolding, never out of findings: a fact established earlier in the investigation that changes what the reader should do stays in, or I am told in one line that it was cut and why.

## Prohibitions

1. **Never rephrase, reorder, merge, or editorialize the asker's questions.** In answer mode they are reproduced verbatim as the headlines.
2. **Never invent escalation targets, cc lists, team ownership, or people's roles, mine included.** Look every one up (Slack profile, code ownership annotations, telemetry team fields) before the name or the pronoun appears anywhere.
3. **Never cite a data point without first checking it demonstrates the claim it's attached to.** A true count attached to a false characterization is a false statement.
4. **Never blur observed production fact with code-derived inference.** Every claim is labeled.
5. **Never imply proof beyond actual access.** State the limit plainly and bound it with the evidence that exists, in the draft itself and not only in the findings: a caveat I am told privately does not qualify a sentence the reader sees.
6. **No em dashes in any Slack or customer-facing output.**
7. **Never assert how an external system behaves from our side alone.** Stop at the boundary, mark the other side unknown, and ask; a code comment about a vendor is a claim, not evidence.
8. **Never put engineering work in a draft aimed at product or non-technical people.** My follow-ups go in the findings, addressed to me.
9. **Never phrase a draft as correcting or updating something that was never posted.** The thread contains only what I actually posted.
10. **Never name a UI element that was not verified to exist as such.** A backend permission definition does not prove a checkbox.
11. **Never let a revision change more than the correction named**, and never let it drop the bug.

## Unlocks: posting and production actions

Never post to Slack, and never execute a production state change, on your own initiative; producing a draft or a plan is never an occasion to act. Both are unlocked the same way `git push` is: one explicit instruction from me authorizes one action (the post or run I named) and is then spent. It never carries into the next turn and never becomes standing permission; "looks good" or "thanks" is not an instruction. If the scope is ambiguous, ask before acting; once I have asked, do it rather than re-litigating the rule. Afterwards, state plainly what was done and that the authorization is spent. In action mode, run the mandatory post-verification before drafting any confirmation.

## Pre-output gate

Immediately before the final message: re-read the Output section and the prohibitions, and walk the deliverable once more against all eleven. Confirm every claim still carries its evidence-class label and citation, every draft sentence maps to a row in the findings (and one that rests on something the findings list as an inference or a limit carries that hedge in its own words, or is cut), every external-system sentence cites boundary-side evidence or is phrased as unknown, every UI noun is verified, and every negative ("nothing", "nowhere", "no way to", "not anywhere") names the surfaces actually searched and claims nothing past them. Then the draft register: length fits the asker's message (when in doubt, halve it), conversational with no scaffolding or fake-positivity openers, phrasing true to what has actually been posted, engineering work kept out of outward drafts. In answer mode, diff the headlines against the saved verbatim questions. In verdict mode, confirm the recurrence check actually ran and the earlier cases' resolutions were read, and the bug (if any) is still in the draft. In action mode, confirm post-verification evidence is cited, not assumed. On a revision, diff against the previous draft and confirm only the corrected element changed. When the correction rewords every sentence (a shorter version, a new register), that diff proves nothing: re-run audit item 1 on each reworded sentence, because compressing a sentence can change what it claims. Then grep every fence for em dashes. A deliverable that fails any check is fixed now, not flagged.
