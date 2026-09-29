# Fix MR Review Feedback

Address the open review threads on a merge request I authored: $ARGUMENTS
(an MR URL or iid; when empty, resolve the MR for the current branch via glab)

This is a remediation command, not a requirements process — the reviewer's threads ARE
the requirements. Fetch them, verify each, plan the responses, then execute one fix at a
time with one commit each so the git history stays clean. Nothing outside the threads is
in scope.

## Hard rules

1. Never post anything to GitLab (no replies, no resolving) and never push — unprompted.
   Replies are drafted locally; I decide what to post. Outward actions happen only
   through the publish offer in Step 5, on my explicit go, and execute exactly as
   defined there.
2. Commits happen only at per-group checkpoints, after my explicit confirmation of that
   group's diff — one commit per fix group, never mixing groups. If the working tree is
   dirty at start, STOP and ask (worktree mode in Step 0 is one of the options to
   offer).
3. Scope discipline: fix exactly what a thread asks plus its direct, demonstrable
   consequences. No opportunistic refactors, no drive-by cleanups. Anything worth doing
   beyond a thread → propose as a follow-up; do not do it here. A deferral is a verdict
   too and carries rule 4's evidence bar: verify the follow-up's necessity against the
   MR's target branch (never just the local tree), tracing into other locally available
   repos when the severity depends on their behavior. Never widen a thread's scope and
   then defer the widened version — when the thread's subject sits in files this MR
   creates or touches, a verified concern defaults to a fix here.
4. Evidence discipline (as in /deep-review): verify every thread's premise against the
   code before any verdict — behavioral claims traced to their defining source, never
   assumed from the diff. A reviewer can be wrong; prove it before pushing back — and
   prove them right before agreeing. Before pushing back on a premise, check for prior
   art: `ls ~/.claude/runs/<repo>/requirements/` for the ticket in the branch name, and
   read that run's spec on the behavior in question — it often settles the point with
   better sources than a fresh investigation will find. Any push-back resting on "X
   cannot happen" states the frame its evidence was gathered under: which enforcement,
   which config, which seeding path. An invariant is only as absolute as the constraint
   behind it, and a constraint the repo ships a way to disable is not absolute. When the
   push-back defends a design or a module boundary, run the search that would disprove
   you before drafting: look for code outside that boundary which already does what you
   claim only the boundary can do. Precedent that supports your position is not
   evidence; the counter-precedent is.
5. Provenance separation: the reviewer's words and your analysis are NEVER blended.
   Every quote carries its clickable note anchor
   (…/merge_requests/<iid>#note_<note_id> — not an internal discussion hash). Anything
   you derived beyond the comment is labeled "beyond the thread — my analysis"
   everywhere it appears, including in the plan.
6. Follow the reviewer's direction when one is given and the premise verifies, unless
   evidence contradicts it — then push back with the evidence instead of silently
   implementing a third path.
7. Communication register: every question put to me carries exactly ONE recommendation
   plus the evidence for it — a menu without a default is never a question. Gate
   messages lead with the verdict/recommendation; supporting evidence follows,
   compressed. Once I ask for brevity, it holds for the rest of the run.

## Step 0 — Git preflight (always, before anything else)

- Check the current branch and the working tree (`git status`, untracked files included).
- **Worktree mode** — take it when I ask for it; offer it when the checkout is dirty or
  visibly in use by another session: `git fetch origin`, create a worktree at the MR
  source branch's remote tip, and do ALL work there — the main checkout is never touched
  again. Expect a fresh worktree to need bootstrapping (deps installed or cloned from
  the main checkout before hooks and tests work). Provision test resources per run with
  unique names/ports (e.g. a throwaway database container) — never reuse another
  session's shared containers; parallel sessions tear them down under you. Keep a
  running list of everything provisioned: the wrap-up offers its teardown.
- **Any local changes** (staged, unstaged, or untracked), when not in worktree mode:
  STOP. Report the branch and the exact files and ask what to do (worktree / stash /
  commit / abort) — never stash, discard, or proceed on your own.
- **Clean tree**: if $ARGUMENTS is empty, resolve the MR for the current branch NOW,
  before switching away. Then sync: `git switch master` (or the repo's default branch if
  it isn't master) and `git pull`. Then check out the MR's source branch and bring it to
  the remote tip — the fixes in Step 4 are committed there, never on master. Only then
  start Step 1.

## Step 1 — Fetch & scope gate

- Resolve project + MR iid (from $ARGUMENTS or the current branch), and record the MR's
  `target_branch` (`glab api "projects/<id>/merge_requests/<iid>"`). A target that is not
  the repo's default branch means this is a STACKED MR — Step 5 depends on knowing this.
  Fetch ALL discussions:
  `glab api "projects/<id>/merge_requests/<iid>/discussions?per_page=100"`, paginating
  until exhausted. If this fails, STOP — never work from a partial list.
- Enumerate UNRESOLVED threads as T1..Tn: author, file:line, trimmed verbatim quote,
  note anchor link. Separately list what is excluded (resolved threads, my own
  self-notes). Unresolved bot threads are included by default.
- When a thread's very disposition is ambiguous at this gate (say, a bot note that
  defers itself), do a light pre-assessment first so the scope question arrives with a
  recommendation (rule 7) instead of an open menu.
- Present this table and WAIT for my scope confirmation (drop/add items). Nothing else
  starts before I confirm.

## Step 2 — Assess each in-scope thread (autonomous)

Start skeptical: a comment is a claim, not an instruction. Not every thread has — or
needs — a "solution": some are informative, some are questions, some are wrong.
Agreement must be earned exactly like disagreement: by reading the full final content of
each touched file (not just the hunk) and verifying the premise. One verdict each:

- **fix** — premise verified, change warranted; propose ONE fix honoring the reviewer's
  direction (or the obvious minimal fix when none was given)
- **fix, differently** — valid concern, better fix available; one line on why
- **answer** — the thread is a question or informative note, not a change request:
  draft the answering reply (evidence-backed). If the fact that a reviewer had to ask
  reveals genuinely unclear code, you MAY additionally propose a small clarifying
  change (comment, rename) as an optional fix — flagged as optional
- **push-back** — premise wrong, outdated, or already addressed; draft a kind,
  evidence-backed reply; no code change
- **your call** — only when materially different designs exist and the trade-off is
  genuinely mine; max 2–3 options, one-line trade-off each, your recommendation marked
  (rule 7)

One thread = one fix group (and one commit) by default. Merge threads into a shared
group only when their changes are literally inseparable in one commit; each group lists
every thread it addresses.

## Step 3 — Plan gate

Present: ordered fix groups (threads + links; the fix in ≤3 sentences; files touched;
test plan; draft commit message matching this repo's style from `git log`), then
answers, push-backs, and your-call items — each led by its one-line recommendation,
evidence compressed beneath it (rule 7). I approve or adjust the plan before any code
changes.

## Step 4 — Execute, one group at a time, with checkpoints

For each approved group, in order:
1. Implement the fix → format + targeted tests for the touched files. Tests that cannot
   run are a blocker to RESOLVE, not report: discover the environment first (running
   containers, compose files, the pattern other worktrees or sessions use) and provision
   a uniquely-named throwaway substitute if needed. Never conclude anything from a
   permission-denied compound command — re-run its parts individually first.
2. CHECKPOINT: present a compact diff summary + test results + the commit message, and
   WAIT for my confirmation. Any test-environment substitution is disclosed here, in the
   same message as the results it produced — never as a later aside. One footer line:
   paste-ready replies come at the wrap-up; nothing has been pushed. I may adjust the
   fix here (re-run tests after adjustments) or skip the group.
3. On my go: ONE commit whose message references the thread(s). Tree clean before the
   next group starts.

STOP and tell me if: a fix unexpectedly bleeds into another group's files; tests fail
for a cause outside the group's scope; or verification during implementation
contradicts the plan's premise for that group.

## Step 5 — Wrap-up (single message, recommendation first)

- REFRESH FIRST: re-fetch the MR live (`glab api "projects/<id>/merge_requests/<iid>"`)
  — current `target_branch`, `merge_status`, `has_conflicts`, head pipeline status.
  Step 1's snapshot was for scoping; never propose a cross-branch action from data that
  old. Call out any retarget explicitly: GitLab retargets a stacked MR to the default
  branch when its parent merges, and from that moment merging the default branch
  becomes the CORRECT move, not a violation of the stacked-MR warning below.
- Table: thread → verdict → commit SHA (or answer / push-back / deferred / skipped).
  Key each row by the opening words of the reviewer's comment, quoted verbatim, so I
  can find the thread in the GitLab UI — the anchor link alone is not a findable key.
- A paste-ready reply per thread: fixes get "done in <short-sha>: <one-liner>"; answers
  and push-backs get their evidence-backed reply; deferrals name the follow-up
  ticket/MR I should create plus one sentence on why it cannot land in this MR. Replies
  must be valid GitLab Markdown with every code identifier in backticks, and each reply
  is presented inside a fenced code block so the raw markdown (backticks included)
  survives copy/paste from the terminal. Label evidence honestly: a behavior you
  demonstrated in a lab or throwaway setup is stated as such, never as observed live
  behavior.
- End with a numbered "what remains, and whose it is" checklist: push, post each reply,
  resolve threads, deferred items, teardown of everything the run provisioned — each
  item marked mine or yours, with push state read from `git status -sb` (not asserted
  from memory) and the pipeline state from the refresh. In its default mode this
  command creates no files or folders — the MR threads and git history are the state,
  so re-running later simply picks up whatever is still unresolved; in worktree mode,
  every provision sits on this checklist.
- Propose bringing the MR branch up to date, using the REFRESHED `target_branch` —
  never reflexively reach for master:
  - **Target is the default branch** (`master`): propose `git merge origin/master`.
  - **Target is another branch** (stacked MR): propose `git merge origin/<target_branch>`,
    and state plainly that master must NOT be merged. Merging master into a stacked branch
    does not advance its merge-base with the parent target, so every commit master gained
    since the stack forked lands in the MR diff — on a real stacked MR this turned a
    6-file diff into several thousand files. It is also near-irreversible once pushed:
    force-push is off the table, and `git revert -m 1 <merge>` is not a safe substitute,
    because the branch would then carry content that re-deletes master's commits when it
    eventually merges.
  Name the branch you are proposing explicitly, so the choice is visible rather than
  assumed, and wait for my answer. On my go: `git fetch origin` then the merge above.
  If the merge conflicts, stop, list the conflicting files, and ask — never resolve
  conflicts on your own. After a clean merge, sanity-gate before anything else:
  `git diff --stat origin/<target_branch>...HEAD` must stay in the ballpark of the MR's
  own size — a file count an order of magnitude beyond the MR's own means the wrong
  branch was merged; stop and say so. Then re-run the targeted tests from Step 4 and
  report the result.
- PUBLISH OFFER — the only sanctioned path for outward actions (rule 1). Offer, never
  auto-execute, the sequence: push → post each drafted reply on its thread → resolve
  the threads whose reply closes them (fixes and answers; push-backs stay open for the
  reviewer) → tear down the run's provisions. On my go, execute the enumerated list
  exactly as confirmed: when my instruction is ambiguous about which actions it covers,
  ask before acting — never silently drop an action or infer a subset. The MR is mine:
  when I authorize resolving, resolve — do not substitute a reviewer-etiquette
  convention for my instruction. A correction to an already-posted reply edits the note
  in place, never posts a stacked follow-up note. After any push, report the MR's fresh
  pipeline status and that the push reset approvals.
