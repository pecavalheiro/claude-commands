# Fix MR Review Feedback

Address the open review threads on a merge request I authored: $ARGUMENTS
(an MR URL or iid; when empty, resolve the MR for the current branch via glab)

This is a remediation command, not a requirements process — the reviewer's threads ARE
the requirements. Fetch them, verify each, plan the responses, then execute one fix at a
time with one commit each so the git history stays clean. Nothing outside the threads is
in scope.

## Hard rules

1. Never post anything to GitLab (no replies, no resolving) and never push. Replies are
   drafted locally; I decide what to post.
2. Commits happen only at per-group checkpoints, after my explicit confirmation of that
   group's diff — one commit per fix group, never mixing groups. If the working tree is
   dirty at start, STOP and ask.
3. Scope discipline: fix exactly what a thread asks plus its direct, demonstrable
   consequences. No opportunistic refactors, no drive-by cleanups. Anything worth doing
   beyond a thread → propose as a follow-up; do not do it here.
4. Evidence discipline (as in /final-check): verify every thread's premise against the
   code before any verdict — behavioral claims traced to their defining source, never
   assumed from the diff. A reviewer can be wrong; prove it before pushing back — and
   prove them right before agreeing.
5. Provenance separation: the reviewer's words and your analysis are NEVER blended.
   Every quote carries its clickable note anchor
   (…/merge_requests/<iid>#note_<note_id> — not an internal discussion hash). Anything
   you derived beyond the comment is labeled "beyond the thread — my analysis"
   everywhere it appears, including in the plan.
6. Follow the reviewer's direction when one is given and the premise verifies, unless
   evidence contradicts it — then push back with the evidence instead of silently
   implementing a third path.

## Step 1 — Fetch & scope gate

- Resolve project + MR iid (from $ARGUMENTS or the current branch). Fetch ALL
  discussions: `glab api "projects/<id>/merge_requests/<iid>/discussions?per_page=100"`,
  paginating until exhausted. If this fails, STOP — never work from a partial list.
- Enumerate UNRESOLVED threads as T1..Tn: author, file:line, trimmed verbatim quote,
  note anchor link. Separately list what is excluded (resolved threads, my own
  self-notes). Unresolved bot threads are included by default.
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
  genuinely mine; max 2–3 options, one-line trade-off each

Threads sharing one fix form a single fix group; each group lists every thread it
addresses (N:M is normal).

## Step 3 — Plan gate

Present: ordered fix groups (threads + links; the fix in ≤3 sentences; files touched;
test plan; draft commit message matching this repo's style from `git log`), then
answers, push-backs, and your-call items. I approve or adjust the plan before any code
changes.

## Step 4 — Execute, one group at a time, with checkpoints

For each approved group, in order:
1. Implement the fix → format + targeted tests for the touched files.
2. CHECKPOINT: present a compact diff summary + test results + the commit message, and
   WAIT for my confirmation. I may adjust the fix here (re-run tests after adjustments)
   or skip the group.
3. On my go: ONE commit whose message references the thread(s). Tree clean before the
   next group starts.

STOP and tell me if: a fix unexpectedly bleeds into another group's files; tests fail
for a cause outside the group's scope; or verification during implementation
contradicts the plan's premise for that group.

## Step 5 — Wrap-up (single message)

- Table: thread → verdict → commit SHA (or answer / push-back / deferred / skipped).
- A paste-ready reply per thread: fixes get "done in <short-sha>: <one-liner>"; answers
  and push-backs get their evidence-backed reply; deferrals name the follow-up
  ticket/MR I should create. Replies must be valid GitLab Markdown with every code
  identifier in backticks, and each reply is presented inside a fenced code block so
  the raw markdown (backticks included) survives copy/paste from the terminal.
- No push, no posting — I take it from here. This command creates no files or folders;
  the MR threads and git history are the state, so re-running later simply picks up
  whatever is still unresolved.
