# /investigate-ticket

Open the Slack thread I'll provide: a support escalation, a CX question, an ops request, or a suspicion about production behavior. The deliverable's shape depends on what the thread actually needs (Step 0.5 decides), but the method never varies: every claim backed by evidence gathered this session, labeled by its evidence class, cross-checked in both directions, and reviewed by a context that did not do the investigation before anything reaches me as final. Nothing is assumed, nothing is guessed, and nothing is posted or executed without the explicit unlocks at the end. Every discipline below is binding, not advisory.

## Step 0: environment, then the thread

1. Read `~/.claude/journals/investigation.md`, the machine-local environment file (in no repo, never installed or committed) naming the backend and frontend repos and their local paths, the internal admin tool, the data-warehouse and telemetry connectors, and tool-specific patterns from past investigations. Unlike the other journals, this file is load-bearing: if it is missing, say so and ask me for the environment instead of guessing paths or names.
2. Read `~/.claude/journals/domain.md` if present (accumulated domain facts) and `~/.claude/journals/investigation-lessons.md` if present (lessons from past cases, written by `/investigate-retro`; every entry is binding on this case, and the independent review walks them). Missing is a normal state for either: note it in one line and continue.
3. Read the FULL thread, not just the linked message. The thread is the source of truth for what is asked, what has been claimed, and by whom. If I pointed at a specific message, that message defines the ask. On re-entry later in the case, read only what arrived since the last read.
4. Harvest every identifier the thread carries into a scratchpad case file: company/entity slugs and IDs, admin-tool links, ticket and issue references, and each human claim with its author and timestamp. Those timestamps get cross-referenced against production later, and the review reads this file.
5. Triage and helper bots post confident step-by-step answers in these threads. Bot output (like every thread claim by anyone, colleagues and my own earlier messages included) is a lead to verify, never a fact; a confident, plausible bot answer can point the wrong way. One exception runs the other way: a firsthand report of what someone saw inside an external system is the strongest evidence this case has about that system until that system's own API or logs say otherwise, and no record on our side outranks it (see the boundary). When someone in the thread could not act on a message of mine, that message is the first suspect.
6. Record participant names only. Roles, teams, and seniority are unknown until looked up (People and ownership, below).

## Step 0.5: shape the deliverable (three modes)

Decide from the thread which resolution is being asked for, and state the chosen mode in the findings. Modes compose: a verdict investigation can end in an action; an answer thread can surface a product gap. When genuinely ambiguous, ask me one targeted question instead of guessing.

- **Answer mode**: the thread contains explicit questions from a named asker. The deliverable is those questions answered, verbatim (Output contract A).
- **Verdict mode**: a symptom, complaint, or suspicion with no explicit questions ("customer says they see nothing", "is something broken here?"). The deliverable is a verdict: what actually happened, by what mechanism, and what, if anything, anyone needs to do. **"False alarm, nothing is broken, no customer action" is a valid and good verdict; never manufacture a defect to justify the investigation** (Output contract B). One-off or pattern? Count it in the warehouse and read how the earlier cases were closed: the route that cleared them (a channel, a form, a named person) is the remedy for this one.
- **Action mode**: the ask is a state change (enable, reclassify, backfill, re-send). The deliverable is a verified plan, the gated action itself, and post-action proof (Output contract C).

An investigation is long-lived: follow-up questions arrive over days, from new people. Each one re-enters the loop at this step, with the same evidence bar, its own mode, its own audience and length calibration, and its own review. It is never answered from memory of the case because "we already know this one."

## Step 1: the code (find the rule)

In the backend and frontend repos named by the environment file, grep from the thread's domain words to the exact code producing the behavior, typically some of: the worker or job performing the action (ownership annotations name the owning team, so record it), the config gating who receives what and the recipient resolution, the permission model end to end (role definitions, permission conversion, what each route, controller, and frontend surface requires), and every fallback surface the reader (a customer or a colleague) could check for themselves, starting with any admin-tool link the thread carries, with what each one shows and gates on. In action mode, also find the sanctioned script or mechanism for the requested change and read what it actually does.

The code yields the **rule** (what the system is built to do), always cited as file:line. The code never proves what happened in production; that is Steps 2 and 3. Prefer running the app's own functions against real data (a scratchpad script through the app's runner) over hand-simulating logic; when the build won't cooperate, derive from source and label the derivation as such.

## Step 2: production state (the data warehouse)

Query through the warehouse connector named by the environment file: its curated query recipes first, and describe a table before writing SQL against any identifier not already seen this session. Pull the actual rows: status fields and timestamps, job rows (state, attempts, errors, and args, since job args often carry the literal recipient or target list, the strongest evidence of who an action touched), the notifications actually created and for whom, the affected user's roles, stored permissions, and history.

Run the **negative** queries too, not just the confirming ones: who is absent from a list, which rows do NOT exist, what never got enqueued. Every absence claim names the query that would have found the row, and that query is proven able to find one: run it where a positive is known to exist, and never read a zero from a column whose values come back redacted, masked or truncated. An automation that demonstrably fires in general has not been shown to fire for this case until this case's own row is found, and "it has not happened yet" at one point in time is not "it did not fire" until the queue's own rows say so.

## Step 3: runtime (telemetry)

Through the telemetry connector named by the environment file: traces and request-level events, both the job's trace (state, error flag, timing matched against the thread's human timestamps) and the affected user's own footprint: their requests against the surfaces in question, sign-ins, errors. A 403 in the user's own request log turns a permission analysis from inference into observation and is routinely the strongest single piece of evidence in a case. Search for it now, in the main pass.

## The external-system boundary

Our code and data prove things only up to the edge of our own systems. When the mechanism crosses into an external vendor system (a verification provider's review queue, a mail provider's delivery pipeline, a webhook contract), the boundary is where assertions stop:

- Never assert how the external system behaves (what moves its states, who works its queue, what it will send us, what it still holds) from our side alone. State what is proven up to the boundary, mark the other side explicitly unknown, and ask me: I may have access myself, or can attach a connector mid-session. Saying "unknown, checking" is always better than a plausible guess about what the external system "needs" or will do.
- A record on our side saying we created something in the external system proves we asked for it then, not that it is there now. A person who looked inside that system and reports otherwise has boundary-side evidence and we do not: the disagreement is the finding, and the deliverable is interim until that system's own API or logs settle it.
- A comment in our code describing a vendor's behavior is a claim, not evidence. It may shape a hypothesis, never a stated fact.
- When a vendor connector is available (or appears mid-session), use it to settle exactly the boundary claims, and re-check every earlier sentence that leaned on an assumption about that system. Vendor systems are READ-ONLY: never create, update, or trigger anything in them; the unlocks below do not extend there.
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

An inference never borrows an observation's confidence. When production offers no worked example of a code-derived rule, say exactly that. A sentence supported by neither class is dropped, not softened: "should", "automatically" and "will" are not hedges that let an unverified sentence stay, they are a verification gap to close or a sentence to cut.

**The remedy carries the same bar as the diagnosis.** "Do X and it works" is a claim: it needs the file:line or the production rows showing that X changes the condition producing the behavior. The obvious inverse of a cause is a hypothesis, not a fix, and it is the one sentence the reader will act on. A remedy names where it lands, who acts and through what route; one that turns out to be a request to another person is labeled as a conversation to have, not an item to build.

**A negative is bounded by what was actually searched.** "There is no way to do X" names the repos, trees and callers searched and claims nothing past them. Reading part of a file is not reading it.

**UI nouns and identifiers are verified, never inferred.** A checkbox, button, tab or label named in a draft is verified in the frontend code or on a rendered surface; a backend definition proves none of them. An identifier handed to a reader is the one the other system actually holds (verified from what we send it, not from our own screens), called by the label the reader's screen gives it.

**Access limits are stated plainly, in the draft itself.** "Dispatched without error" is not "delivered"; no access to a provider's logs means saying so and bounding it with the evidence that exists. A caveat I am told privately does not qualify a sentence the reader sees. Redacted or unavailable data is named as such.

## People and ownership: looked up, never inferred

Every name attached to an escalation, cc, or role gets its Slack profile read before it appears anywhere. Team ownership comes from ownership annotations and telemetry team fields on the component that actually fails, never from who talks in the thread or who wrote the code: authorship tells you who knows it, not who to ping. A shared runner's annotation (a job framework, a scheduler) names the runner's owner, not the payload's, and a file with no owner is reported as such. If the owning team is already in the thread, no escalation line belongs in any draft. Pronouns are ownership claims too ("us", "them", "our team", "hand this to Y"), and the first to resolve is my own position: confirm which teams I am on before one reaches a draft, and that a team named after a business function is the group meant and not that function's operational group.

## Action mode: the gate around any state change

Investigation first proves the action is right: the current production state, why it is in that state, and that the proposed mechanism is the sanctioned one. That means the actual script or function read, its preconditions checked against real data, and its side effects (emails, jobs, notifications) enumerated. Then:

1. Present the plan to me: each precondition verified (with its evidence class), the exact target record the action and its proof refer to (which run, which row), the exact invocation, the expected side effects, and how each will be verified. The plan goes through the independent review before I see it.
2. **The run is locked exactly like posting** (see Unlocks): one explicit go-ahead authorizes one execution and is spent.
3. **Post-verification is mandatory**: after running, re-read the target record and re-query the warehouse and telemetry to prove the state changed and each named side effect actually fired. No "done" reply is drafted from the script's own exit status alone, and no side effect is described as having happened until its own row or re-read shows it.

## Findings: what reaches me, and in what order

The findings are for me, my eyes only, written to the case folder before the review and shown after it:

1. **Unknowns the deliverable rests on.** Each with the check that would settle it, whether I can run that check now (a connector, the console, asking a named person), and the draft sentence it constrains. Any entry here makes the deliverable interim: the draft states what is established and what is being checked, phrased as checking. An empty list is itself a claim, and the review tests it.
2. At most five lines: the verdict, what the draft asks and of whom, and each decision waiting on me with a recommendation. When the ticket is mine, a defect found in it is offered to me first; code ownership decides who approves the change, not who makes it.
3. The detail (mode, mechanism, evidence per claim with its class label, limitations and access limits), cut to what supports a claim or a decision. The halving rule of the draft register applies here too.
4. The review's verdict, and each problem it raised with my answer: the evidence that settles it, quoted with its class, or the change made to the text.

## The independent review: mandatory, before anything reaches me as final

The context that did the investigation cannot audit its own draft: it checks the citations it chose and defends the hypothesis it formed. So before any draft, plan or confirmation is shown to me as final, write the findings and the proposed text to the case folder and spawn a reviewer subagent that took no part in the investigation. It gets the thread link(s) to read read-only, the case file, the findings file, the proposed text, and the lessons journal path. It uses nothing else, and these instructions verbatim:

> You are the last check before a colleague posts a reply, or runs a change, in a Slack thread. You have the thread(s) as they stand, the investigator's notes, and the proposed text. You did not do the investigation and must not redo it: read only the thread(s) and the files named.
>
> Assume the text contains at least one sentence that a message already in the thread contradicts or has already answered, and at least one that depends on something nobody has verified. Find them. For each sentence: quote the thread messages (author, time) that support it and the ones that contradict or pre-empt it; if it says what a system outside our own contains, shows or will do, say whether anyone has shown evidence from that system's side; if it rests on an unknown, name it and whether a check exists that would settle it before posting; if it describes a record's state after a change, name the output that shows that state after the change, or say none does.
>
> Also flag: a point someone already made restated as the author's own; a promise of future work; an escalation target, cc, team or role claim; a UI element, label or identifier the reader must find on their screen; engineering work handed to a non-technical reader; a correction of something never posted; any lessons-journal entry whose trigger matches and whose action was not taken.
>
> Say how the author of the thread's most recent message would react. Output: the problems ranked by how badly they would land, each with its quotes; then one line: POST / POST AS INTERIM (what is known, what is being checked) / DO NOT POST. Do not rewrite the text.

Then answer every problem it raised: with the evidence that settles it, quoted and labeled, or by changing the text. A problem I cannot settle becomes an entry in the unknowns list, and the deliverable becomes interim. The review runs again on any revision that changes a claim, and in action mode it runs twice: on the plan before the run, and on the confirmation after post-verification. Three mechanical checks stay with me, before the review: no em dashes in any fence; in answer mode, the headlines diff clean against the saved verbatim questions; on a revision, the diff against the previous draft shows only what the correction named, and a rewording of every sentence is re-checked sentence by sentence, because compressing a sentence can change what it claims.

## Output

After the findings, the mode's deliverable. Every Slack draft is paste-ready in a fenced code block, Slack formatting (`*bold*`); after the fence, flag the judgment calls I should decide before posting (who is named, detail level, what belongs in a separate message or ticket). **No em dashes anywhere in a draft or any customer-facing text**: commas, colons, or separate sentences. Customer-facing wording is translated (a 403 becomes "the platform returned Forbidden") while staying exact.

**The draft register** is how every Slack draft reads, regardless of mode:

- **Scaled to the asker.** A one-line question gets a few sentences back; the detail lives in the findings, never the draft. When a draft feels complete, halve it: verbosity is the default failure and the first version is always too long. Respect people's time.
- **Conversational, in my voice.** As I would type it: no header-and-bullet scaffolding on a short reply, no fake-positivity openers, nothing that reads as "AI structured this and I pasted it." Plain, simple words: I am not a native English speaker and neither are many readers. The voice matches my actual position in the thread (for example, new to a domain: "what I found and what I assume the right change is").
- **True to the posted state.** The thread contains only what I actually posted. Never phrase a draft as correcting or updating an earlier message of mine that was never sent: a draft has no history until I post it. The reverse holds too: when something I did post is wrong or caused the confusion, the draft says so plainly and gives the correct version. It is also new to the thread: a point someone already made is credited to them in a clause or dropped, never restated as mine, and a thread claim the draft states as fact needs its own row first.
- **Interim is valid.** When a boundary or a pending check blocks the full answer, the right draft states what is established and what is still being checked, phrased as checking, never guessed at. A check that can run now runs before the draft is offered as final.
- **Audience and role.** Establish my role in the thread (usually the investigating engineer) and who will read the draft. An engineering follow-up (check a webhook subscription, run a script, re-point a job) is my own work item: it goes in the findings addressed to me, never into a draft as an ask of product or non-technical people.

**A. Answer mode.** The headlines are the asker's questions, **verbatim**: original wording, original order, one answer under each, no question skipped, merged, or rephrased (a false premise is answered under the verbatim headline, not edited away), and nothing inserted between them. Findings beyond the questions go AFTER a visible divider, explicitly framed as beyond what was asked, and are offered to me as optional before being included at all.

**B. Verdict mode.** The verdict in the first line, including (when true) that nothing is broken and no customer action is needed. Then the mechanism in the requester's frame, what to tell the customer, and the recurrence count. Product follow-ups (a UX gap, a prevention idea) form a separately labeled block after the customer answer, never mixed into it, so I decide what goes where.

When the investigation finds a real defect, the bug, its mechanism, and the fact that it needs fixing always belong in the draft: no correction about process ever removes them. The process around the bug (ticket or no ticket, who fixes it) is my call: ask once, with a recommendation, and never unilaterally propose process steps in a draft. Once I decide, the draft speaks as me in first person ("I'll create a ticket and work on the fix"). If I ask for a ticket draft, use the template defined in `/refine-ticket` and show it here first.

**C. Action mode.** Before the unlock: the verified plan per the gate above. After post-verification: a short confirmation draft stating what was run and what the re-read production state now shows, never the exit status alone.

## Revisions: change what was corrected, nothing else

When I correct a draft, the next version changes exactly what the correction names and keeps everything else intact: content, structure, and wording. A correction is never a license to restructure, shorten elsewhere, or drop other material: "no ticket", for example, is not a reason to also drop the bug explanation. Say in one line what changed. When I ask for a shorter draft, length comes out of explanation and scaffolding, never out of findings: a fact established earlier in the investigation that changes what the reader should do stays in, or I am told in one line that it was cut and why.

## Unlocks: posting and production actions

Never post to Slack, and never execute a production state change, on your own initiative; producing a draft or a plan is never an occasion to act. Both are unlocked the same way `git push` is: one explicit instruction from me authorizes one action (the post or run I named) and is then spent. It never carries into the next turn and never becomes standing permission; "looks good" or "thanks" is not an instruction. If the scope is ambiguous, ask before acting; once I have asked, do it rather than re-litigating the rule. Afterwards, state plainly what was done and that the authorization is spent. In action mode, run the mandatory post-verification before drafting any confirmation.
