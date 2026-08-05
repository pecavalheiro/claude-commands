# Claude Code Commands

Personal collection of Claude Code slash commands and the runtime files they depend on, installed into `~/.claude` via symlinks.

## Install

```bash
./install.sh
```

This symlinks every command under `commands/` (flat — subfolders are organizational only) into `~/.claude/commands/`, and every top-level support bundle (`requirements-phases/`, `review-lenses/`) into `~/.claude/<name>`. Because everything is a symlink, `git pull` updates content in place; re-run the installer only when files are added, moved, or renamed. The installer never clobbers real files or directories already living in `~/.claude`, and prunes its own leftover links after renames.

## Commands

### Requirements pipeline

An evidence-first pipeline that takes a ticket from raw idea to implemented code. The full flow, phase files, and contracts are documented in [docs/requirements-pipeline.md](docs/requirements-pipeline.md).

| Command | Role |
|---|---|
| `/refine-ticket <url>` | Upstream of the pipeline: crawls every source linked from a tracker ticket, grounds claims against code and data, resolves each open question with you one at a time, and delivers a paste-ready refined ticket plus a Definition-of-Ready verdict, split proposal, and ask pack. |
| `/requirements-start <ticket>` | Entry point: runs the phased gathering pipeline (source inventory → code analysis → questions → targeted context → adversarial verification → spec). The rules live in `requirements-phases/`. |
| `/requirements-status` | Locate and resume the active run from its gate ledger. |
| `/requirements-current` | Read-only view of the active run. |
| `/requirements-list` | Dashboard of all runs in the current project. |
| `/requirements-remind` | Compressed rule card to re-ground the model after drift or context compaction. |
| `/requirements-end` | Finalize a run: generate the spec from current information, park it as incomplete, or cancel. |
| `/synthesize` | Implement the most recent completed spec to a ship-ready state, with a staleness preflight and a Definition-of-Done gate. |
| `/requirements-retro` | Post-mortem on a finished run whose findings were later challenged; distills confirmed misses into the lessons journal that future runs load as binding. |

### Review & delivery

| Command | Role |
|---|---|
| `/deep-review <link>` | Deep review of my own Linear ticket branch or a colleague's GitLab MR: five parallel review lenses (`review-lenses/`), strict scope and evidence discipline, severity-ranked findings with paste-ready comments. |
| `/review-retro <MR>` | Closes the `/deep-review` loop after humans review: classifies what they found vs what the review caught, verifies their claims, appends lessons to the review-lessons journal (binding on the next run), and proposes lens-file edits. |
| `/mr-feedback-fix <MR>` | Work through unresolved review threads on my own MR: a verdict per thread, fixes grouped one commit per group, paste-ready replies. |
| `/commit` | Commit current changes split into logical, chronologically ordered commits. |
| `/prepare-mr [ticket]` | Default MR write-up: fills the repo's own MR template plus a title from the branch diff and the ticket, reconciling what the ticket asked against what actually shipped, and lists what must be solved before merge. One pass, no fan-out. |
| `/prepare-mr-deep` | Same job for complex pipeline work: additionally sweeps the `/synthesize` run folder (`implementation/` notes, spec Assumptions and volatile markers, `communications.md`, holds) for loose ends, each re-verified against the code. Thorough and slow — use `/prepare-mr` unless the run folder matters. |

## Repository layout

```
commands/               # one .md = one slash command, installed flat
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

- The requirements pipeline writes run folders to `requirements/` in the **target project's** working directory — gitignore it there. `/refine-ticket` similarly uses `ticket-refinements/`.
- Some commands read or append journals under an `implementation/` directory outside this repo (`requirements-lessons.md` for the pipeline retro, `review-lessons.md` and `domain.md` for `/deep-review`), resolved by walking up from the target repo.

## Acknowledgments

The requirements pipeline began as a fork of [rizethereum/claude-code-requirements-builder](https://github.com/rizethereum/claude-code-requirements-builder), itself inspired by [@iannuttall](https://github.com/iannuttall)'s [claude-sessions](https://github.com/iannuttall/claude-sessions). It has since been rewritten around per-phase rule files, evidence gates, and adversarial verification.

## License

MIT
