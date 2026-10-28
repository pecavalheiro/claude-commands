# Start Requirements Gathering (fast)

Begin gathering requirements for: $ARGUMENTS

The fast variant of /requirements-start: one context, zero subagents by default (three at most, for three named cases), the ticket's own neighbourhood read completely and everything one step further listed for me to pull in, one verification pass on the spec, a spec sized to the change. Same run store, same file names, same spec headings, so /synthesize and every sibling command read a fast run unchanged. For tickets whose scope the ticket itself states; /requirements-start is the heavy option for scattered sources or stakes that justify its cost.

The written sources are authoritative. Every fact in the output traces to a source quote, a code location, or an explicit decision; everything else is a labeled assumption.

## Step 0: workspace choice (once, before anything else)

1. Not inside a git repository → stop: "not inside a git repository: the run store is keyed by repo".
2. Freshen the default branch: `git fetch origin`, then compare the local default branch (master/main: `git symbolic-ref --short refs/remotes/origin/HEAD`, falling back to whichever of the two exists on origin) against its origin counterpart. Behind → fast-forward it where it is checked out, normally the main folder (`git worktree list` shows which): `git -C <that folder> merge --ff-only origin/<branch>`, or `git fetch origin <branch>:<branch>` when no folder has it checked out. Already current → say so in one line and move on. Diverged, or local state blocks the fast-forward → report the state in one line and ask me (update how / proceed on the stale branch / abort); never merge, rebase, or reset to resolve it yourself.
3. Already inside a LINKED worktree (`git rev-parse --git-dir` differs from `--git-common-dir`) → say so in one line and proceed in place; never offer to nest a worktree inside one.
4. Otherwise ask me and WAIT: **"Do you want me to create a worktree for this (recommended) or proceed in the current folder?"**
   - **Current folder** → continue, unchanged.
   - **Worktree** → `git worktree add -b <branch> <path> origin/<default-branch>` (origin is already fresh from step 2) with defaults I may override in my answer: path = a sibling of the current toplevel named `<toplevel>-<ticket-id-lower>` (no ticket → the run slug); branch = `<ticket-id-lower>-<slug>`. Then MOVE INTO it: use Claude Code's worktree tool (EnterWorktree) when available, otherwise treat the worktree path as the repo root for EVERY subsequent operation this session performs, subagents included. The worktree is the run's workspace from here on, recorded in `metadata.json`'s `worktree` field so /synthesize can offer teardown when the work is done.

## The one rule

The rules live in one file, `~/.claude/requirements-phases-fast/rules.md`, and **that file IS the run**: Read it top to bottom before the first fetch, and again after any interruption, resume, or context compaction (resolve the run via this workspace's pointer file, read its `gates.md` to locate the phase, then re-read the rules before the next action). Never run from memory of this or any earlier run. Two shared files are read at the moment they apply, as the rules say: `~/.claude/requirements-phases/drafts-contract.md` before any paste-ready draft, and the section headings of `~/.claude/requirements-phases/phase-5-output.md` for the spec. Nothing else in the full command's bundle applies to a fast run.

## Files & the /synthesize interface (do not break)

- Folder: `~/.claude/runs/<repo>/requirements/YYYY-MM-DD-HHMM-<TICKET-ID>-[slug]/`; `<repo>` and the workspace slug are derived as section 0 of the rules says. Files: `00-initial-request.md`, `01-discovery-questions.md`, `02-discovery-answers.md`, `03-context-findings.md`, `04-detail-questions.md`, `05-detail-answers.md`, `06-requirements-spec.md`, `metadata.json`, `research-notes.md`, `communications.md`, `gates.md`.
- `metadata.json` carries `"mode": "fast"`; /requirements-status, /requirements-remind and /requirements-retro read it to find this run's rules file.
- Pointer: `~/.claude/runs/<repo>/requirements/.pointers/<workspace-slug>`, two lines (run-folder name, raw workspace path), content authoritative; written at setup, cleared by /requirements-end; stale pointers are treated as absent.
- /synthesize resolves its run explicit argument → this workspace's pointer → newest qualifying run whose metadata `workspace` contains this workspace → newest qualifying run repo-wide, with an announcement. It reads `metadata.json` (`"status": "complete"`, `contextFiles`, `relatedFeatures`, `holds`, `workspace`, `worktree`), `06-requirements-spec.md` (the exact section names, FR/TR numbering), `03-context-findings.md`, and `research-notes.md` (currency snapshot + verification line). `communications.md` and `gates.md` are never spec input. `status`/`phase` are never "complete" while any hold has `resolution: null`.

**Begin now: run Step 0, then read `~/.claude/requirements-phases-fast/rules.md`.**
