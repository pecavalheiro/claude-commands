---
name: review-retro
description: Post-review retrospective on a GitLab MR previously reviewed with /final-check. Fetches the human review comments, compares them against what my review caught, verifies the reviewers' claims, distills the misses into lessons, and appends them to the review-lessons journal. Triggers on "/review-retro <MR url>", "run a retro on this MR review", "why did my review miss this".
---

# Review Retro

Turn a human review into durable review knowledge. Input: a GitLab MR URL. Optionally the user also pastes what the earlier /final-check run found; if not, reconstruct it from the comments they posted on the MR (resolve their GitLab username with `glab api user | jq -r .username`) and ask when ambiguous.

## The journal

`implementation/review-lessons.md` at the employ workspace root (default `~/projects/remote/employ_workspace/implementation/review-lessons.md`; if missing, walk up from the current repo to the directory containing `tiger/`, `dragon/`, etc.). Always Read it first — the house style is defined by what is there, entries are **Lesson / Why / How to apply / Source**, and existing sections are updated in place, never duplicated.

## Steps

1. Fetch every discussion: `glab api "projects/<project_path_urlencoded>/merge_requests/<iid>/discussions?per_page=100"` — paginate if 100 come back.
2. Partition the notes: system notes (ignore), bot findings, the user's own comments, human reviewer comments. Review-summary comments and requested-changes reasons count as findings too, not just inline threads.
3. Classify each substantive human finding:
   - **caught** — the /final-check review raised it (or the same issue in different words)
   - **missed-knowledge** — needed a convention, invariant, or org fact that was not written down anywhere the review reads
   - **missed-procedure** — derivable from the diff alone, but no lens procedure asks the question
   - **missed-judgment** — the facts were found but under-weighted (severity or rubric problem)
4. Verify before recording. Read the actual code and rule files each reviewer claim rests on — reviewers can be wrong too. If a claim does not hold up, note that in the report instead; never encode an unverified opinion as a lesson.
5. For every verified miss with a generalizable cause, distill one journal entry (Lesson / Why / How to apply / Source with the MR link and reviewer) and write it — merging into an existing section when one matches.
6. For `missed-procedure` cases, additionally propose a concrete edit to the matching lens file in `~/.claude/review-lenses/` — show the proposed change and ask before applying it.
7. Report back: a short table of human findings with their classification, plus one line per journal entry added or updated.

Never post anything to GitLab.
