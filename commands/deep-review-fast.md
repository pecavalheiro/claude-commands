Open the link I'll provide. It will be one of two paths, and they differ a lot in complexity:

- **A Linear ticket** is my own work. The changes sit in the current local branch, committed or not. Treat the branch as not merged and all of its code as new, and inspect it by diffing the branch against its base (plus any uncommitted changes). Because the code is mine, you can be more flexible about structure and design preferences. There is no MR and no review discussion, so this is the simpler path: skip the MR gate below.
- **A GitLab MR** is a colleague's work that I'm reviewing. This is the more complex path: there may be existing comments, bot reviews, and back-and-forth between several people. The ticket link is in the MR description. Get the changes readable locally (Step 1 offers a disposable review worktree for exactly this) and treat all of its code as new.

This is the fast variant of /deep-review: the same five lenses and lens files, the same evidence bar, the same output, with ceilings on how much the lenses and you read and on how many turns you take to read it. A review's cost is turns times context, not reading volume: a lens that re-finds the changed files, the rule files and the journals in a hundred small calls pays for its whole context a hundred times, and an orchestrator that explores on its own while the lenses run is a sixth lens at the largest context of all. This variant builds that shared material once as a context pack, briefs every lens with a scope and a tool-call ceiling, and keeps you to verifying what the lenses cite. /deep-review is for the change where unbounded exploration is worth its cost; /review-retro can compare the two on the same head.

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

The review runs as five parallel lenses (Step 2) whose findings you then verify yourself (Step 3). First build, once, everything they all need:

1. Save the full diff to `pack/diff.patch` in a `pack/` folder in the scratchpad, generated with `git diff --no-color <base> HEAD` (a global `color.ui = always`, which this machine has, colours redirected output too, and the escape codes break every hunk-header parser downstream; the `-U0` diffs that locate hunks for partial files take `--no-color` as well), and make the code readable at the change's revision. Note the repo path: it becomes the briefing's local repo path, used by every lens and by verification:
   - **Linear-ticket path**: the current checkout already IS the change (committed or not). Use it in place; a worktree does not apply.
   - **MR path**: if the current checkout is already at the MR's head, use it in place. Otherwise ask me and WAIT: **"Do you want me to create a disposable review worktree for this MR (recommended) or use the current checkout?"** On worktree: first freshen the default branch, before the MR fetch, since any later fetch overwrites the `FETCH_HEAD` the worktree is created from. `git fetch origin`, then compare the local default branch (`git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to whichever of master/main exists on origin) against its origin counterpart. Behind → fast-forward it where it is checked out, normally the main folder (`git worktree list` shows which): `git -C <that folder> merge --ff-only origin/<branch>`, or `git fetch origin <branch>:<branch>` when no folder has it checked out. Already current → say so in one line. Diverged, or local state blocks the fast-forward → report the state in one line and ask me (update how / proceed on the stale branch / abort); never merge, rebase, or reset to resolve it yourself. Then fetch the MR head (`git fetch origin "refs/merge-requests/<iid>/head"`; if that ref is unavailable, fetch the source branch) and create a detached sibling worktree: `git worktree add --detach <toplevel>-review-mr-<iid> FETCH_HEAD`. Detached on purpose: it can never collide with a branch checked out elsewhere, and the review writes nothing there. On current checkout: make the branch readable there yourself (e.g. `glab mr checkout`) or work from the saved diff plus fetched refs, and say which you did.
2. Identify the repo's own review rules for the touched code. They are binding review context, and findings that lean on them must cite them by file:line:
   - the repo/app root `AGENTS.md` and the domain index (`DOMAINS.md` or similar)
   - the agent rule files (`.cursor/rules/`, `.agents/rules/`): the architecture rules always, plus every rule file whose topic the diff touches (e.g. the hooks rules whenever hook producers, consumers, or hook config change)
   - each touched domain's `AGENTS.md` and `interface.yaml`, when present
   - the test conventions doc (e.g. `test/CLAUDE.md`) when tests change
3. Identify the two journals under `~/.claude/journals/`. Both are optional and machine-local, so a missing file is a normal state, never an error; never invent a path or search elsewhere for them:
   - `<app>/review-lessons.md`, where `<app>` is this repo's name from its remote: `basename -s .git "$(git remote get-url origin)"` (no `origin` → its only remote; no remotes → the repo's top-level directory name). Accumulated lessons from past reviews; binding, same as the repo rules. Every clone of an app shares one journal, wherever it sits on disk. If it does not exist, say so in one line ("no review lessons yet for `<app>`") and continue.
   - `domain.md`: domain facts, system topology, and glossary for the work this repo belongs to. One file, shared by every repo. If it does not exist, skip it silently and continue.
4. Read the ticket.
5. Build the rest of the pack, by redirection, so that every lens reads the same material in a handful of calls instead of re-finding it:
   - `pack/changed-files.txt`: the full final content of every added or modified file in the diff, each under a `==== <path> (<n> lines) ====` header and numbered with `cat -n`. A file over 600 lines goes in as the regions the diff touches, each hunk with 60 lines of context on either side (`sed -n`), with `(partial: hunks and 60 lines around each, of <n>)` in its header. Deleted files are not included; the diff holds them. If the file passes 300 KB, stop adding content, list every remaining path with its line count under a final `==== not included ====` header, and say so in the index.
   - `pack/rules.md`: the rule files from step 2, concatenated under one header per file, each header carrying the file's path.
   - `pack/journals.md`: the review-lessons journal verbatim, then the domain journal: whole when it is under 300 lines, otherwise the sections whose heading or body names a touched domain, module, or feature (locate them with `grep -n`; copy each section from its heading to the next heading of the same level).
   - `pack/index.md`: one line per pack file with its size and line count; the changed-file list, marking each file as full, partial, or not included; and the links of the ticket and the MR.
   Before Step 2, check the pack: `pack/diff.patch` holds no escape character (`grep -c $'\e' pack/diff.patch` prints 0), and every `(partial: ...)` header in `pack/changed-files.txt` is followed by at least one `---- lines a-b ----` range with content. A pack that fails either check is rebuilt before any lens launches; a lens briefed on a broken pack spends its ceiling re-reading it.
   Then read `pack/rules.md` and `pack/journals.md` yourself, once each: they are binding for you as much as for the lenses. State which journals you loaded and roughly how many entries each held, so a review that ran without its binding lessons is visible rather than silent.
6. Write a briefing file in the scratchpad containing: the ticket summary and its requirements; the link under review, branch, local repo path, the pack folder and index path, and the changed-file list; (MR path) the thread summary from the gate; the paths of every rules file and journal from steps 2-3; and the lens output contract from the shared rules file, copied verbatim.

**The shared rules file.** `~/.claude/review-rules/verify-and-output.md` holds the lens output contract, the all-lenses barrier, Step 3 (verify, dedup, rank), the Output section, the posting rules, the pre-output gate, the worktree teardown offer and the /review-retro pointer. It is shared with /deep-review on purpose, so the two reviews cannot drift in what counts as a verified finding or in how the review is written, and it IS those steps: read it top to bottom in this session before writing the briefing, and again after any context compaction. Never run them from memory or from a summary.

## Step 2: brief and launch the lenses

Launch five subagents in parallel: one message, five Agent calls, general-purpose type. The lenses:

| Lens | File | Ceiling |
|---|---|---|
| Correctness & behavior | `~/.claude/review-lenses/correctness.md` | 35 tool calls |
| Architecture & mechanism | `~/.claude/review-lenses/architecture.md` | 35 tool calls |
| Domain & conventions | `~/.claude/review-lenses/domain.md` | 35 tool calls |
| Tests | `~/.claude/review-lenses/tests.md` | 35 tool calls |
| Fresh eyes | `~/.claude/review-lenses/fresh-eyes.md` | 20 tool calls |

**The brief contract.** Every lens brief names its inputs, its scope, its ceiling, and its return:

- **Inputs, in as few calls as possible:** the pack index, then every pack file it lists (one `cat` per file, or several files in one call), then the lens file. Nothing the pack holds is read again from the repo; a lens that needs more of a partial file reads the range it needs.
- **Scope:** the changed files, their direct collaborators (what they call and what calls them, one level out), the tests that cover them, and whatever the lens's own procedures name. A read beyond that needs a candidate finding that depends on it. A brief never says "read as much as you need" and never lets the lens widen its own scope.
- **Ceiling:** the number in the table. Reads are batched: several files in one `cat`, a `grep -n` and the `sed -n` ranges it points at in the same call, never one call per file. At the ceiling the lens stops, returns what it has, and names what it would have read next.
- **Return:** exactly the briefing's output contract, followed by two lines: `calls used: <n> of <ceiling>` and `not explored: <the paths or questions it would have pursued next, each with the candidate finding it could bear on, or none>`.

Each lens gets the same prompt shape: "Read the pack index at `<path>` and every file it lists, in as few calls as you can, then your lens at `<path>`. Scope: the changed files, their direct collaborators one level out, the tests that cover them, and what your lens's procedures name; nothing the pack holds is read again from the repo. Ceiling: <n> tool calls; batch your reads; at the ceiling stop and return what you have. Return findings exactly per the briefing's output contract, then the lines `calls used: <n> of <ceiling>` and `not explored: ...`."

If subagents are unavailable, run the lenses yourself sequentially, one pass per lens under the same ceiling, re-reading the lens file immediately before each pass so its questions are fresh. Never all lenses in one pass: that is exactly the attention dilution this structure exists to prevent.

**After the launches, in the same turn:** read `pack/changed-files.txt` once (it is the full final content that Step 3's scope discipline requires of you), then end the turn with the one-line status. The all-lenses barrier in the shared rules file applies as written, with one tightening: between the launches and the first report there is nothing to verify, so you read nothing else and launch nothing else; and while reports are pending, the only reads you make are the ranged reads that verify evidence a delivered report cites. You are not a sixth lens.

## Step 3 and the Output

Both live in `~/.claude/review-rules/verify-and-output.md`, read at Step 1, and apply as written: every lens finding is a hypothesis, every ranked finding carries its `[verified:]` and `Post at:` lines, and the severity scale, the comment economy, the pre-output gate and the posting rules are unchanged. What this variant bounds is how you verify:

- **Ranged reads only.** Locate with `grep -n`, read with `sed -n 'a,bp'`, several ranges per call. Never `cat` a whole file the pack holds, since its content is already in your context, and never re-read a pack file. A finding whose cited lines do not say what the lens claims is dropped or demoted to "Unverified, worth a look", not re-investigated from scratch.
- **Follow-up agents instead of your own exploration.** When a `not explored:` line names something that bears on the behavior the change exists to produce, or when settling one finding would take more than three ranged reads, launch one fresh follow-up agent with a narrow brief: the one question, the files or modules to look at, a ceiling of 15 tool calls, evidence only (file:line and the snippet), never a verdict. At most three follow-ups per review; a gap that would need a fourth goes under "Unverified, worth a look" with the one fact that would settle it. A follow-up's return is verified like a lens's, and the barrier covers it: the review waits for it.
- **The budget line.** The last line of the review's final message, before the worktree teardown offer when there is one: `budget: lens calls correctness <n>/35, architecture <n>/35, domain <n>/35, tests <n>/35, fresh eyes <n>/20; ceilings hit: <lenses, or none>; not explored: <one clause per lens that reported something, or none>; follow-ups: <n> of 3; your read calls after launch: <n>`. The lens numbers come from their returns, yours from your own count. The line exists so the spend is visible without opening anything, and so a trial against /deep-review on the same head can be judged on what each one left unread.
