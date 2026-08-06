# Conventions for this repo

Personal Claude Code slash commands and their runtime support files, installed into `~/.claude` by `./install.sh` (symlinks).

## Adding a command

- One `.md` file under `commands/` = one slash command. The basename is the command name and must be unique across all subfolders — commands install **flat** into `~/.claude/commands/`, so subfolders are organizational only.
- Group a family into a subfolder (like `commands/requirements/`) once it reaches ~3 files; standalone commands stay loose in `commands/`.
- **One command, one name — no alias symlinks.** Claude Code deduplicates entries resolving to the same file and displays only the alphabetically-first name, so an alias like `implement.md` hijacks `/synthesize`'s spot in the picker. (An `aliases:` line in a command's body does nothing either.)
- Run `./install.sh` after adding, moving, or renaming files. Pure content edits need no re-run — symlinks pick them up.

## Support bundles

Runtime files a command reads (not commands themselves) live in a top-level directory, which the installer symlinks to `~/.claude/<dirname>`: `requirements-phases/` (the pipeline's phase rules), `review-lenses/` (`/deep-review`'s lenses). Commands reference them by their `~/.claude/<dirname>` path. `commands/`, `docs/`, and `skills/` are exempt from this rule.

## Skills

Agent skills live in `skills/<name>/SKILL.md` and install as **per-skill** symlinks `~/.claude/skills/<name>`, so skills maintained privately outside this repo coexist untouched. `review-retro` is `/deep-review`'s closing half: it appends to the review-lessons journal that `/deep-review` loads as binding, and proposes edits to `review-lenses/`.

## Journals

Three machine-local journals under `~/.claude/journals/`, in no repo and never installed by this one. Commands read them; retros write them; a missing journal is always a normal state that is noted and continued past, never an error and never a reason to search elsewhere.

| Journal | Path | Scope | Written by |
|---|---|---|---|
| Review lessons | `<app>/review-lessons.md` | per app | `/review-retro` |
| Requirements lessons | `requirements-lessons.md` | all projects | `/requirements-retro` |
| Domain knowledge | `domain.md` | all projects | maintained outside this repo |

`<app>` is the repo's name from its remote — `basename -s .git "$(git remote get-url origin)"`, falling back to its only remote, then to the top-level directory name. Keying on the remote rather than a path is deliberate: every clone of an app shares one journal wherever it sits on disk, and the commands carry no assumption about anyone's folder layout.

## Contracts not to break

- **This repo is public; the journals are not.** Nothing in here may name a company, an internal app, module, or namespace, a vendor or product, a feature flag, a ticket ID, a person, or an internal URL — not in commands, lenses, phase files, or docs. Procedure is public; what a real review or run taught you goes in a journal. Naming a language or framework is fine.
- The spec section headings defined in `requirements-phases/phase-5-output.md` are parsed by `/synthesize` — never rename them (see `docs/requirements-pipeline.md`).
- The phase files are authoritative; the `requirements-*` commands stay thin routers that read them at the moment of use.
- `commands/deep-review.md`, `review-lenses/`, and `skills/review-retro/` are the live source; the copies in the dotfiles repo are a frozen backup — don't edit those.
