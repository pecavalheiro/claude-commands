# Conventions for this repo

Personal Claude Code slash commands and their runtime support files, installed into `~/.claude` by `./install.sh` (symlinks).

## Adding a command

- One `.md` file under `commands/` = one slash command. The basename is the command name and must be unique across all subfolders — commands install **flat** into `~/.claude/commands/`, so subfolders are organizational only.
- Group a family into a subfolder (like `commands/requirements/`) once it reaches ~3 files; standalone commands stay loose in `commands/`.
- **One command, one name — no alias symlinks.** Claude Code deduplicates entries resolving to the same file and displays only the alphabetically-first name, so an alias like `implement.md` hijacks `/synthesize`'s spot in the picker. (An `aliases:` line in a command's body does nothing either.)
- Run `./install.sh` after adding, moving, or renaming files. Pure content edits need no re-run — symlinks pick them up.

## Support bundles

Runtime files a command reads (not commands themselves) live in a top-level directory, which the installer symlinks to `~/.claude/<dirname>`: `requirements-phases/` (the pipeline's phase rules), `requirements-phases-fast/` (the single rules file `rules.md` that `/requirements-start-fast` reads once per run; it shares `drafts-contract.md` and the spec headings of `phase-5-output.md` with the full bundle), `review-lenses/` (the five lenses both review commands fan out to), `review-rules/` (the single file `/deep-review` and `/deep-review-fast` both read for the lens output contract, the all-lenses barrier, verification and the Output section). Commands reference them by their `~/.claude/<dirname>` path. `commands/`, `docs/`, and `skills/` are exempt from this rule.

## Skills

Agent skills live in `skills/<name>/SKILL.md` and install as **per-skill** symlinks `~/.claude/skills/<name>`, so skills maintained privately outside this repo coexist untouched. `review-retro` is `/deep-review`'s closing half: it ranks candidate changes to the review-lessons journal that `/deep-review` loads as binding and to `review-lenses/`, and writes one only when I ask.

## Journals

Six machine-local journals under `~/.claude/journals/`, in no repo and never installed by this one. Commands read them; retros propose entries and write them only on my approval; a missing journal is always a normal state that is noted and continued past, never an error and never a reason to search elsewhere — except `investigation.md` and `weekly-recap.md`, which are load-bearing for `/investigate-ticket` and `/weekly-recap` (they hold this machine's repo paths and internal names, and the team channel and recap style sample), so when one is missing its command asks for the environment instead of continuing.

| Journal | Path | Scope | Written by |
|---|---|---|---|
| Review lessons | `<app>/review-lessons.md` | per app | `/review-retro`, on approval |
| Requirements lessons | `requirements-lessons.md` | all projects | `/requirements-retro`, on approval |
| Investigation lessons | `investigation-lessons.md` | all projects | `/investigate-retro`, on approval |
| Domain knowledge | `domain.md` | all projects | maintained outside this repo; `/investigate-retro` proposes additions |
| Investigation environment | `investigation.md` | all projects | maintained outside this repo; `/investigate-retro` proposes additions |
| Weekly recap environment | `weekly-recap.md` | all projects | maintained outside this repo |

`<app>` is the repo's name from its remote — `basename -s .git "$(git remote get-url origin)"`, falling back to its only remote, then to the top-level directory name. Keying on the remote rather than a path is deliberate: every clone of an app shares one journal wherever it sits on disk, and the commands carry no assumption about anyone's folder layout.

## The run store

Pipeline run folders live in a machine-local store, never in any repo: `~/.claude/runs/<repo>/requirements/<run>/` (`/requirements-start`) and `~/.claude/runs/<repo>/ticket-refinements/<run>/` (`/refine-ticket`), with `<repo>` derived by the same recipe as the journals' `<app>`. Created on demand (`mkdir -p`), never by `install.sh`. The active run is per **workspace** (per clone/worktree, identified by `git rev-parse --show-toplevel`): each workspace has its own pointer file under `<repo>/requirements/.pointers/` — two lines, run name then raw workspace path, content authoritative — so parallel runs in several checkouts never collide. Each run's `metadata.json` records its creating `workspace`. Like the journals, the store routinely holds private content: it is never installed, committed, or published, and no repo needs gitignore entries for it.

## Contracts not to break

- **This repo is public; the journals are not.** Nothing in here may name a company, an internal app, module, or namespace, a vendor or product, a feature flag, a ticket ID, a person, or an internal URL — not in commands, lenses, phase files, or docs. Procedure is public; what a real review or run taught you goes in a journal. Naming a language or framework is fine.
- The spec section headings defined in `requirements-phases/phase-5-output.md` are parsed by `/synthesize` — never rename them (see `docs/requirements-pipeline.md`). The fast variant's `rules.md` lists the same headings and names `phase-5-output.md` as their definition, so the `/synthesize` interface cannot drift between the two variants. Never fork the headings into a second definition.
- The phase files are authoritative; the `requirements-*` commands stay thin routers that read them at the moment of use.
- `commands/deep-review.md`, `commands/deep-review-fast.md`, `review-lenses/`, `review-rules/`, and `skills/review-retro/` are the live source; the copies in the dotfiles repo are a frozen backup — don't edit those.
- `review-rules/verify-and-output.md` is read by both `/deep-review` and `/deep-review-fast` at their Step 1 and is the only place the lens output contract, the all-lenses barrier, Step 3 and the Output live. The two commands differ only in Step 1 (how the context is assembled) and Step 2 (how the lenses are briefed and launched). Never fork it and never copy a section of it back into a command: a rule about what counts as a verified finding changes in one place or not at all.
