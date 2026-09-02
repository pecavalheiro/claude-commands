# /investigate-ticket

Open the Slack thread I'll provide — a support escalation, a CX question, an ops request, or a suspicion about production behavior. The deliverable's shape depends on what the thread actually needs (Step 0.5 decides), but the method never varies: every claim backed by evidence gathered this session, labeled by its evidence class, cross-checked in both directions, and adversarially audited before anything reaches me as final. Nothing is assumed, nothing is guessed, and nothing is posted or executed without the explicit unlocks at the end.

This command exists because a real investigation got the substance right and still needed six corrections before the answer was postable. Each correction is a hard rule below — the disciplines and prohibitions are binding, not advisory.

## Step 0: environment, then the thread

1. Read `~/.claude/journals/investigation.md` — the machine-local environment file (in no repo, never installed or committed) naming the backend and frontend repos and their local paths, the internal admin tool, the data-warehouse and telemetry connectors, and tool-specific patterns from past investigations. Unlike the other journals, this file is load-bearing: if it is missing, say so and ask me for the environment instead of guessing paths or names.
2. Read `~/.claude/journals/domain.md` if present — accumulated domain facts. Missing is a normal state: note it in one line and continue.
3. Read the FULL thread, not just the linked message. The thread is the source of truth for what is asked, what has been claimed, and by whom. If I pointed at a specific message, that message defines the ask.
4. Harvest every identifier the thread carries into a scratchpad file: company/entity slugs and IDs, admin-tool links, ticket and issue references, and each human claim with its timestamp ("done", "sent", "customer saw nothing this morning") — those timestamps get cross-referenced against production later.
5. Triage and helper bots post confident step-by-step answers in these threads. Bot output — like every thread claim by anyone, colleagues included — is a lead to verify, never a fact. A plausible bot answer pointing the wrong way is a recorded failure mode.
6. Record participant names only. Roles, teams, and seniority are unknown until looked up (people rule, in the audit).

## Step 0.5: shape the deliverable — three modes

Decide from the thread which resolution is being asked for, and state the chosen mode in the findings. Modes compose — a verdict investigation can end in an action; an answer thread can surface a product gap. When genuinely ambiguous, ask me one targeted question instead of guessing.

- **Answer mode** — the thread contains explicit questions from a named asker. The deliverable is those questions answered, verbatim (Output contract A).
- **Verdict mode** — a symptom, complaint, or suspicion with no explicit questions ("customer says they see nothing", "is something broken here?"). The deliverable is a verdict: what actually happened, by what mechanism, and what — if anything — anyone needs to do. **"False alarm, nothing is broken, no customer action" is a valid and good verdict; never manufacture a defect to justify the investigation** (Output contract B).
- **Action mode** — the ask is a state change: enable, reclassify, backfill, re-send. The deliverable is a verified plan, the gated action itself, and post-action proof (Output contract C).

## Step 1: the code — find the rule

In the backend and frontend repos named by the environment file, grep from the thread's domain words to the exact code producing the behavior — typically some of: the worker or job performing the action (ownership annotations name the owning team — record it), the config gating who receives what and the recipient resolution, the permission model end to end (role definitions, permission conversion, what each route, controller, and frontend surface requires), and every fallback surface a customer might be told to check, with what each one gates on. In action mode, also find the sanctioned script or mechanism for the requested change and read what it actually does.

The code yields the **rule** — what the system is built to do — always cited as file:line. The code never proves what happened in production; that is Steps 2–3. Prefer running the app's own functions against real data (a scratchpad script through the app's runner) over hand-simulating logic; when the build won't cooperate, derive from source and label the derivation as such.

## Step 2: production state — the data warehouse (Snowflake MCP)

`list_skills`/`get_skill` for curated query recipes first; `describe_table` before SQL against any identifier not already seen this session. Pull the actual rows: status fields and timestamps, job rows (state, attempts, errors, and args — job args often carry the literal recipient or target list, the strongest evidence of who an action touched), the notifications actually created and for whom, the affected user's roles, stored permissions, and history.

Run the **negative** queries too, not just the confirming ones: who is absent from a list, which rows do NOT exist, what never got enqueued. Every absence claim names the query that would have found the row.

## Step 3: runtime — telemetry (Honeycomb MCP)

Traces and request-level events: the job's trace (state, error flag, timing matched against the thread's human timestamps) and — always, in the main pass — the affected user's own footprint: their requests against the surfaces in question, sign-ins, errors. A 403 in the user's own request log turns a permission analysis from inference into observation and is routinely the strongest single piece of evidence in a case; in the session this command was distilled from, it was found only during the late audit. Look for it here.

## Cross-check discipline — both directions, before any claim is stated

- **Rule → data**: everyone the code-derived rule selects shows the effect in production, and everyone it excludes doesn't. One direction alone is a hypothesis, labeled as one.
- **Data → rule**: every production observation traces back to the code that produces it. An unexplained row or timestamp near the incident is an open question, not color — identify it (who, targeted or bulk) and either integrate it or show it doesn't move the conclusion.
- **The positive twin**: the rule explaining what's missing must also explain what's present (what the user DID receive, what DID work), or the rule is wrong.
- Timestamps cross-referenced against the thread's human claims; agreement and disagreement are both findings.
- Where possible, confirm conclusions at more than one point in time (the same exclusion months earlier is corroboration).

## Fact vs inference — label everything, blur nothing

Every statement carries its evidence class, in the findings and in customer-appropriate wording in any draft:

- **Observed production fact**: a named warehouse row or telemetry event read this session.
- **Code-derived inference**: cited file:line, phrased as how the system is built ("going on how the flow is built rather than a worked example").

An inference never borrows an observation's confidence. When production offers no worked example of a code-derived rule, say exactly that. A sentence supported by neither class is dropped, not softened.

**Access limits are stated plainly, never papered over.** "Dispatched without error" is not "delivered"; no access to a provider's delivery logs means saying so and bounding it with the evidence that does exist. Redacted or unavailable data is named as such. Implying proof beyond actual access is a correctness bug.

## Action mode: the gate around any state change

Investigation first proves the action is right: the current production state, why it is in that state, and that the proposed mechanism is the sanctioned one — the actual script or function read, its preconditions checked against real data, its side effects (emails, jobs, notifications) enumerated. Then:

1. Present the plan to me: each precondition verified (with its evidence class), the exact invocation, the expected side effects, and how the result will be verified.
2. **The run is locked exactly like posting** (see Unlocks): one explicit go-ahead authorizes one execution and is spent.
3. **Post-verification is mandatory**: after running, re-query the warehouse and telemetry to prove the state changed and the side effects actually fired. No "done" reply is drafted from the script's own exit status alone.

## The audit — mandatory, after drafting, before anything reaches me as final

Draft first, then adversarially attack the draft. In the source session this step found a flatly wrong claim, an unsupported claim, an invented escalation, and the strongest evidence in the case. Walk every sentence through:

1. **Does the cited data actually demonstrate this specific claim?** Re-read the rows and check what they ARE, not just that they exist. Canonical failure: a count of three records cited as proof of "one per entity" when the rows were retries on a single entity — the count was real, the claim attached to it was false.
2. **People and teams — looked up, never inferred.** Every name attached to an escalation, cc, or role gets its Slack profile read NOW. Team ownership comes from code ownership annotations and telemetry team fields, never from who talks in the thread. If the owning team is already in the thread, there is nobody to "raise it with" and no escalation line belongs in any draft.
3. **Anything unsupported is dropped**, not hedged into staying.
4. **What did I not look at?** The affected user's own request log, sign-in events, role or state changes around the incident timestamps.
5. In verdict mode: one-off or pattern? Count it in the warehouse — recurrence turns an anecdote into a product finding and belongs in the findings either way.

## Output

First, the findings for me — my eyes only, full technical detail: the mode, what's happening, the mechanism, the evidence per claim with its class label, limitations and access limits, and the recommended resolution.

Then the mode's deliverable. Every Slack draft is paste-ready in a fenced code block, Slack formatting (`*bold*`); after the fence, flag the judgment calls I should decide before posting (who is named, detail level, what belongs in a separate message or ticket). **No em dashes anywhere in a draft or any customer-facing text** — commas, colons, or separate sentences. Customer-facing wording is translated (a 403 becomes "the platform returned Forbidden") while staying exact.

**A. Answer mode.** The headlines are the asker's questions, **verbatim** — original wording, original order, one answer under each, no question skipped, merged, or rephrased (a false premise is answered under the verbatim headline, not edited away), and nothing inserted between them. Findings beyond the questions go AFTER a visible divider, explicitly framed as beyond what was asked — and are offered to me as optional before being included at all.

**B. Verdict mode.** The verdict in the first line — including, when true, that nothing is broken and no customer action is needed. Then the mechanism in the requester's frame, what to tell the customer, and the recurrence count. Product follow-ups (a UX gap, a prevention idea) form a separately labeled block after the customer answer, never mixed into it, so I decide what goes where.

**C. Action mode.** Before the unlock: the verified plan per the gate above. After post-verification: a short confirmation draft stating what was run and what the re-queried production state now shows — never the exit status alone.

## Prohibitions — each one a mistake already made once

1. **Never rephrase, reorder, merge, or editorialize the asker's questions.** In answer mode they are reproduced verbatim as the headlines.
2. **Never invent escalation targets, cc lists, team ownership, or people's roles.** Look every one up (Slack profile, code ownership annotations, telemetry team fields) before the name appears anywhere.
3. **Never cite a data point without first checking it demonstrates the claim it's attached to.** A true count attached to a false characterization is a false statement.
4. **Never blur observed production fact with code-derived inference.** Every claim is labeled.
5. **Never imply proof beyond actual access.** State the limit plainly and bound it with the evidence that exists.
6. **No em dashes in any Slack or customer-facing output.**

## Unlocks — posting and production actions

Never post to Slack, and never execute a production state change, on your own initiative; producing a draft or a plan is never an occasion to act. Both are unlocked the same way `git push` is: one explicit instruction from me authorizes one action — the post or run I named — and is then spent. It never carries into the next turn and never becomes standing permission; "looks good" or "thanks" is not an instruction. If the scope is ambiguous, ask before acting; once I have asked, do it rather than re-litigating the rule. Afterwards, state plainly what was done and that the authorization is spent — and in action mode, run the mandatory post-verification before drafting any confirmation.

## Pre-output gate

Immediately before the final message: re-read the Output section and the prohibitions, and walk the deliverable once more against all six. Confirm every claim still carries its evidence-class label and citation. In answer mode, diff the headlines against the saved verbatim questions. In verdict mode, confirm the recurrence check actually ran. In action mode, confirm post-verification evidence is cited, not assumed. Then grep every fence for em dashes. A deliverable that fails any check is fixed now, not flagged.
