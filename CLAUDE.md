# Conventions for this repo

Personal Claude Code slash commands and their runtime support files, installed into `~/.claude` by `./install.sh` (symlinks).

## Adding a command

- One `.md` file under `commands/` = one slash command. The basename is the command name and must be unique across all subfolders — commands install **flat** into `~/.claude/commands/`, so subfolders are organizational only.
- Group a family into a subfolder (like `commands/requirements/`) once it reaches ~3 files; standalone commands stay loose in `commands/`.
- Aliases are real symlinks, declared in the `ALIASES` list at the top of `install.sh` (`<alias>:<canonical basename>`). An `aliases:` line in a command's body does nothing by itself.
- Run `./install.sh` after adding, moving, or renaming files. Pure content edits need no re-run — symlinks pick them up.

## Support bundles

Runtime files a command reads (not commands themselves) live in a top-level directory, which the installer symlinks to `~/.claude/<dirname>`: `requirements-phases/` (the pipeline's phase rules), `review-lenses/` (`/deep-review`'s lenses). Commands reference them by their `~/.claude/<dirname>` path. `commands/`, `docs/`, and `skills/` are exempt from this rule.

## Skills

Agent skills live in `skills/<name>/SKILL.md` and install as **per-skill** symlinks `~/.claude/skills/<name>`, so skills maintained elsewhere (e.g. `fast-domain-note` in dotfiles) coexist untouched. `review-retro` is `/deep-review`'s closing half: it appends to the review-lessons journal that `/deep-review` loads as binding, and proposes edits to `review-lenses/`.

## Contracts not to break

- The spec section headings defined in `requirements-phases/phase-5-output.md` are parsed by `/synthesize` — never rename them (see `docs/requirements-pipeline.md`).
- The phase files are authoritative; the `requirements-*` commands stay thin routers that read them at the moment of use.
- `commands/deep-review.md`, `review-lenses/`, and `skills/review-retro/` are the live source; the copies in the dotfiles repo are a frozen backup — don't edit those.
