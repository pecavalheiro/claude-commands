---
name: review-retro
description: Post-review retrospective on a GitLab MR previously reviewed with /deep-review. Fetches the human review comments, compares them against what my review caught, verifies the reviewers' claims, distills the misses into lessons, and appends them to the review-lessons journal. Triggers on "/review-retro <MR url>", "run a retro on this MR review", "why did my review miss this".
---

# Review Retro

Turn a human review into durable review knowledge. Input: a GitLab MR URL. Optionally the user also pastes what the earlier /deep-review run found; if not, reconstruct it from the comments they posted on the MR (resolve their GitLab username with `glab api user | jq -r .username`) and ask when ambiguous.

## The journal

`~/.claude/journals/<app>/review-lessons.md`, where `<app>` is the reviewed repo's name from its remote: `basename -s .git "$(git remote get-url origin)"` (no `origin` → its only remote; no remotes → the repo's top-level directory name). Lessons are per app and shared by every clone of it, wherever it sits on disk. `mkdir -p` the directory — a first retro on an app legitimately creates it. When the file already exists, always Read it first: the house style is defined by what is there, entries are **Lesson / Why / How to apply / Source**, and existing sections are updated in place, never duplicated.

## Steps

1. Fetch every discussion: `glab api "projects/<project_path_urlencoded>/merge_requests/<iid>/discussions?per_page=100"` — paginate if 100 come back.
2. Partition the notes: system notes (ignore), bot findings, the user's own comments, human reviewer comments. Review-summary comments and requested-changes reasons count as findings too, not just inline threads.
3. Classify each substantive human finding:
   - **caught** — the /deep-review review raised it (or the same issue in different words)
   - **missed-knowledge** — needed a convention, invariant, or org fact that was not written down anywhere the review reads
   - **missed-procedure** — derivable from the diff alone, but no lens procedure asks the question
   - **missed-judgment** — the facts were found but under-weighted (severity or rubric problem)
4. Verify before recording. Read the actual code and rule files each reviewer claim rests on — reviewers can be wrong too. If a claim does not hold up, note that in the report instead; never encode an unverified opinion as a lesson.
5. For every verified miss with a generalizable cause, distill one journal entry (Lesson / Why / How to apply / Source with the MR link and reviewer) and write it — merging into an existing section when one matches.
6. For `missed-procedure` cases, additionally propose a concrete edit to the matching lens file in `~/.claude/review-lenses/` — show the proposed change and ask before applying it. **The lens files live in a public repo; the journal does not.** A lens edit is therefore a generic question about a mechanism, carrying no app, module, or namespace names, no vendor or product names, no feature-flag names, no ticket IDs, no reviewer names, and no internal URLs — the MR link belongs in the journal entry from step 5, never in a lens. If a rule only makes sense with those specifics attached, it is `missed-knowledge`, not `missed-procedure`: put it in the journal and propose no lens edit. State the framework or language plainly when the mechanism is genuinely stack-specific; that is not company information.
7. Report back: a short table of human findings with their classification, plus one line per journal entry added or updated.

Never post anything to GitLab.
