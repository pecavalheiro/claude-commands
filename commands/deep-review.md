Open the link I'll provide. It will be one of two paths, and they differ a lot in complexity:

- **A Linear ticket** is my own work. The changes sit in the current local branch, committed or not. Treat the branch as not merged and all of its code as new, and inspect it by diffing the branch against its base (plus any uncommitted changes). Because the code is mine, you can be more flexible about structure and design preferences. There is no MR and no review discussion, so this is the simpler path: skip the MR gate below.
- **A GitLab MR** is a colleague's work that I'm reviewing. This is the more complex path: there may be existing comments, bot reviews, and back-and-forth between several people. The ticket link is in the MR description. Get the changes readable locally — Step 1 offers a disposable review worktree for exactly this — and treat all of its code as new.

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

1. Save the full diff to a scratchpad file, generated with `git diff --no-color <base> HEAD` (a global `color.ui = always`, which this machine has, colours redirected output too), and make the code readable at the change's revision. Note the repo path — it becomes the briefing's local repo path, used by every lens and by verification:
   - **Linear-ticket path**: the current checkout already IS the change (committed or not) — use it in place; a worktree does not apply.
   - **MR path**: if the current checkout is already at the MR's head, use it in place. Otherwise ask me and WAIT: **"Do you want me to create a disposable review worktree for this MR (recommended) or use the current checkout?"** On worktree: first freshen the default branch, before the MR fetch, since any later fetch overwrites the `FETCH_HEAD` the worktree is created from. `git fetch origin`, then compare the local default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to whichever of master/main exists on origin) against its origin counterpart. Behind → fast-forward it where it is checked out, normally the main folder (`git worktree list` shows which): `git -C <that folder> merge --ff-only origin/<branch>`, or `git fetch origin <branch>:<branch>` when no folder has it checked out. Already current → say so in one line. Diverged, or local state blocks the fast-forward → report the state in one line and ask me (update how / proceed on the stale branch / abort); never merge, rebase, or reset to resolve it yourself. Then fetch the MR head (`git fetch origin "refs/merge-requests/<iid>/head"`; if that ref is unavailable, fetch the source branch) and create a detached sibling worktree — `git worktree add --detach <toplevel>-review-mr-<iid> FETCH_HEAD`. Detached on purpose: it can never collide with a branch checked out elsewhere, and the review writes nothing there. On current checkout: make the branch readable there yourself (e.g. `glab mr checkout`) or work from the saved diff plus fetched refs, and say which you did.
2. Read the repo's own review rules for the touched code. They are binding review context, and findings that lean on them must cite them by file:line:
   - the repo/app root `AGENTS.md` and the domain index (`DOMAINS.md` or similar)
   - the agent rule files (`.cursor/rules/`, `.agents/rules/`): the architecture rules always, plus every rule file whose topic the diff touches (e.g. the hooks rules whenever hook producers, consumers, or hook config change)
   - each touched domain's `AGENTS.md` and `interface.yaml`, when present
   - the test conventions doc (e.g. `test/CLAUDE.md`) when tests change
3. Read the two journals under `~/.claude/journals/`. Both are optional and machine-local, so a missing file is a normal state, never an error — never invent a path or search elsewhere for them:
   - `<app>/review-lessons.md`, where `<app>` is this repo's name from its remote: `basename -s .git "$(git remote get-url origin)"` (no `origin` → its only remote; no remotes → the repo's top-level directory name). Accumulated lessons from past reviews; binding, same as the repo rules. Every clone of an app shares one journal, wherever it sits on disk. If it does not exist, say so in one line ("no review lessons yet for `<app>`") and continue.
   - `domain.md` — domain facts, system topology, and glossary for the work this repo belongs to. One file, shared by every repo. If it does not exist, skip it silently and continue.
   State which journals you loaded and roughly how many entries each held, so a review that ran without its binding lessons is visible rather than silent.
4. Read the ticket.
5. Write a briefing file in the scratchpad containing: the ticket summary and its requirements; the link under review, branch, local repo path, saved-diff path, and changed-file list; (MR path) the thread summary from the gate; the paths of every rules file and journal from steps 2-3; and the lens output contract from the shared rules file, copied verbatim.

**The shared rules file.** `~/.claude/review-rules/verify-and-output.md` holds the lens output contract, the all-lenses barrier, Step 3 (verify, dedup, rank), the Output section, the posting rules, the pre-output gate, the worktree teardown offer and the /review-retro pointer. It is shared with /deep-review-fast on purpose, so the two reviews cannot drift in what counts as a verified finding or in how the review is written, and it IS those steps: read it top to bottom in this session before writing the briefing, and again after any context compaction. Never run them from memory or from a summary.

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

The all-lenses barrier in the shared rules file applies from the moment of launch: the review is written exactly once, after every lens has reported.

## Step 3 and the Output

Both live in `~/.claude/review-rules/verify-and-output.md`, read at Step 1. Apply it as written: verification of each finding starts as its lens reports, ranking and the review wait for the barrier, and the final message passes the pre-output gate, carries the worktree teardown offer when Step 1 created one, and ends with the /review-retro pointer.
