# Claude Code Commands

Personal collection of Claude Code slash commands and the runtime files they depend on, installed into `~/.claude` via symlinks.

## Prerequisites

**CLI tools:**

- **[`glab`](https://gitlab.com/gitlab-org/cli)**, authenticated (`glab auth login`) — every GitLab-facing command shells out to it: `/deep-review` (whose MR gate refuses to produce findings without the discussion threads), `/mr-feedback-fix`, `/mr-open` (whose preflight stops without it), `/prepare-mr`, `/prepare-mr-deep`, `/review-retro`, `/weekly-recap` (which lists my merge requests through it). `/deep-review` needs it even when the GitLab MCP is connected, because that server has no MR-notes tool.
- **`jq`** — used by `/review-retro` to resolve your GitLab username.

**MCP connectors** are not optional for the two research commands; both gate on them before doing any work:

- `/refine-ticket` preflights **every** connector it can use, before it crawls anything: Linear, Slack, Notion, GitLab, Figma, Loom, web, and **Snowflake** — it confirms load-bearing data assumptions against real data, not just against code. If any one is missing, unauthenticated, or erroring it stops immediately and names it; only you may decide to proceed without it.
- `/requirements-start` preflights on demand — whichever connectors the ticket's source graph actually needs (typically Linear, Notion, GitLab, Figma, Slack). A source type absent from the graph can be deferred, but that deferral cancels itself the moment a link of that type appears. Missing or unauthenticated means it stops and asks you to connect it (`/mcp`) or to waive that source type for the run.
- `/weekly-recap` needs the Slack and Linear connectors plus `glab`, and a machine-local journal (`~/.claude/journals/weekly-recap.md`) naming the team channel and holding a past recap as its style sample. Missing any of them, it stops and asks rather than guessing a channel or a voice.
- Elsewhere they genuinely are optional: `/prepare-mr` reads the ticket through the Linear MCP or `glab`, whichever fits the URL.

That connector list is the stack this pipeline was built against. `/requirements-start`'s gate is generic — it verifies whatever a source in the graph requires — but `/refine-ticket`'s list is explicit, so on a different stack (no Snowflake, another tracker) it will stop on the first run until you waive the missing servers or edit that list.

Nothing else needs setting up. The journals under `~/.claude/journals/` are created on demand by the retro commands; until then a missing journal is the normal first-run state, which each command notes in one line and continues past.

## Install

```bash
./install.sh
```

This symlinks every command under `commands/` (flat — subfolders are organizational only) into `~/.claude/commands/`, and every top-level support bundle (`requirements-phases/`, `review-lenses/`) into `~/.claude/<name>`. Because everything is a symlink, `git pull` updates content in place; re-run the installer only when files are added, moved, or renamed. The installer never clobbers real files or directories already living in `~/.claude`, and prunes its own leftover links after renames.

If any target the installer owns (`~/.claude/requirements-phases`, `~/.claude/review-lenses`, `~/.claude/skills/review-retro`) already exists as a **real directory** rather than a symlink, the installer stops with `ERROR: … move it aside first` and changes nothing. Move or remove it, then re-run. Individual command files that are real files, not symlinks, are skipped with a message instead.

### The run store (requirements pipeline and /refine-ticket)

Run folders never live inside your projects. The pipeline writes to a machine-local store, created on demand:

```
~/.claude/runs/<repo>/requirements/<run>/         # /requirements-start runs
~/.claude/runs/<repo>/ticket-refinements/<run>/   # /refine-ticket runs
```

`<repo>` comes from the repo's remote — `basename -s .git "$(git remote get-url origin)"`, falling back to its only remote, then to the top-level directory name — the same keying the journals use, so every clone and worktree of a repo shares one bucket wherever it sits on disk. Which run is *active* is tracked per workspace (per clone/worktree): each workspace has its own pointer file under `<repo>/requirements/.pointers/`, so parallel runs in several checkouts of one repo never collide, while `/requirements-list` and `/requirements-retro` see the whole repo's history in one place. Like the journals, the store is machine-local, belongs to no repo, is never installed by this one, and routinely holds private content — never commit or publish it. No per-project setup or gitignore entries are needed.

## Commands

### Requirements pipeline

An evidence-first pipeline that takes a ticket from raw idea to implemented code. The full flow, phase files, and contracts are documented in [docs/requirements-pipeline.md](docs/requirements-pipeline.md).

| Command | Role |
|---|---|
| `/refine-ticket <url>` | Upstream of the pipeline: crawls every source linked from a tracker ticket, grounds claims against code and data, resolves each open question with you one at a time, and delivers a paste-ready refined ticket plus a Definition-of-Ready verdict, split proposal, and ask pack. |
| `/requirements-start <ticket>` | Entry point: offers to run in a fresh worktree (recommended) or the current folder, then runs the phased gathering pipeline (source inventory → code analysis → questions → targeted context → adversarial verification → spec). The rules live in `requirements-phases/`. |
| `/requirements-status` | Locate and resume the active run from its gate ledger. |
| `/requirements-current` | Read-only view of the active run. |
| `/requirements-list` | Dashboard of all runs for the current repo — every clone and worktree, annotated by origin. |
| `/requirements-remind` | Compressed rule card to re-ground the model after drift or context compaction. |
| `/requirements-end` | Finalize a run: generate the spec from current information, park it as incomplete, or cancel. |
| `/synthesize` | Implement the most recent completed spec to a ship-ready state, with a staleness preflight and a Definition-of-Done gate; its final report offers `/mr-open` for publishing and teardown of a run-created worktree once the work is safe. |
| `/requirements-retro` | Post-mortem on a finished run whose findings were later challenged; ranks confirmed misses by value, cost and likelihood and proposes lessons for the journal that future runs load as binding, written only on my approval. |

### Review & delivery

| Command | Role |
|---|---|
| `/deep-review <link>` | Deep review of my own Linear ticket branch or a colleague's GitLab MR: five parallel review lenses (`review-lenses/`), strict scope and evidence discipline, severity-ranked findings with paste-ready comments. For an MR, offers a disposable detached review worktree and its teardown after the review. |
| `/review-retro <MR>` | Closes the `/deep-review` loop after humans review: classifies what they found vs what the review caught, verifies their claims, and ranks candidate changes (review-lessons journal, lens files, the review commands) by cost, value and likelihood; it writes a change only when I ask for it. A second `/deep-review` run of the same MR can stand in for the human review as the comparison source. |
| `/mr-feedback-fix <MR>` | Work through unresolved review threads on my own MR: a verdict per thread, fixes grouped one commit per group, paste-ready replies, and a wrap-up that offers publishing (push, post, resolve) only on my explicit go. Offers a worktree when the checkout is dirty or in use. |
| `/commit` | Commit current changes split into logical, chronologically ordered commits. |
| `/prepare-mr [ticket]` | Default MR write-up: fills the repo's own MR template plus a title from the branch diff and the ticket, reconciling what the ticket asked against what actually shipped, and lists what must be solved before merge. One pass, no fan-out. |
| `/prepare-mr-deep` | Same job for complex pipeline work: additionally sweeps the `/synthesize` run folder (`implementation/` notes, spec Assumptions and volatile markers, `communications.md`, holds) for loose ends, each re-verified against the code. Thorough and slow — use `/prepare-mr` unless the run folder matters. |
| `/mr-open [ticket]` | Publish step: commits per `/commit`, splits work over 550 changed lines into a stack of dependency-ordered MRs (each independently green), fills the repo's own GitLab MR template (stops if there is none), and opens them with reviewers on my go. Offered by `/synthesize`'s final report. |

### Investigation

| Command | Role |
|---|---|
| `/investigate-ticket <thread>` | Evidence-first investigation of a support/escalation Slack thread: the thread is the source of truth, the codebase gives the rule, the data warehouse and telemetry prove it against production, with cross-checks in both directions before any claim is stated. Three deliverable modes — answering the asker's questions verbatim, a verdict (where "false alarm" is a valid result), or a gated and post-verified state change — plus a mandatory adversarial audit of its own draft. Reads a machine-local environment journal for repo paths and internal names. |
| `/investigate-retro <thread or session-id>` | Closes the `/investigate-ticket` loop once the thread has moved on: given the ID of the `/investigate-ticket` session, reads that session's transcript from disk for the findings, every draft revision, and my corrections; re-reads the thread to its end, verifies what was later claimed to be wrong like any other claim, classifies each claim of the deliverable (held, missed evidence, wrong evidence, missed knowledge, missed judgment), ranks the misses by value, cost and likelihood of happening again, and reports them with a proposed fix each (the investigation-lessons journal that `/investigate-ticket` loads as binding, the environment or domain journal, or the command file). Nothing is written until I approve the item. Never posts, never touches production. |

### Reporting

| Command | Role |
|---|---|
| `/weekly-recap` | Drafts my end-of-week recap for the team channel from the week's evidence (tracker issues, merge requests, my own chat messages, with every candidate thread read to its end), asks me for next week's availability and priorities instead of inferring them, and hands the result back as a paste-ready block in the conversation with an evidence row per sentence. Topics, not tickets; it never posts and never creates a Slack draft. Reads a machine-local environment journal for the channel, emoji vocabulary, and style sample. |

## Repository layout

```
commands/               # one .md = one slash command, installed flat
  mr/                   #   the MR family (prepare, open, feedback-fix)
  requirements/         #   the requirements pipeline family
  *.md                  #   standalone commands
requirements-phases/    # pipeline rule files  -> ~/.claude/requirements-phases
review-lenses/          # /deep-review lenses  -> ~/.claude/review-lenses
skills/                 # agent skills, per-skill -> ~/.claude/skills/<name>
docs/                   # documentation (not installed)
install.sh
```

Conventions for adding commands are in [CLAUDE.md](CLAUDE.md).

## Notes

- Some commands read or append **journals** under `~/.claude/journals/` — machine-local, in no repo, and not installed by this one: `<app>/review-lessons.md` (per app, written by `/review-retro` on approval), `requirements-lessons.md` (all projects, written by `/requirements-retro` on approval), `investigation-lessons.md` (all projects, written by `/investigate-retro` on approval), `domain.md` (all projects, maintained separately), `investigation.md` (all projects, read by `/investigate-ticket`, maintained separately), and `weekly-recap.md` (all projects, read by `/weekly-recap`, maintained separately). `<app>` comes from the repo's remote, not its path, so every clone of an app shares one journal wherever it lives. A missing journal is a normal first-run state: commands note it and continue — except `investigation.md` and `weekly-recap.md`, which `/investigate-ticket` and `/weekly-recap` need and will ask for. See [CLAUDE.md](CLAUDE.md#journals).
- The **run store** under `~/.claude/runs/` (see "The run store" above) follows the same model: machine-local, keyed by remote, created on demand, never installed or committed.

## Acknowledgments

The requirements pipeline began as a fork of [rizethereum/claude-code-requirements-builder](https://github.com/rizethereum/claude-code-requirements-builder), itself inspired by [@iannuttall](https://github.com/iannuttall)'s [claude-sessions](https://github.com/iannuttall/claude-sessions). It has since been rewritten around per-phase rule files, evidence gates, and adversarial verification.

## License

MIT
