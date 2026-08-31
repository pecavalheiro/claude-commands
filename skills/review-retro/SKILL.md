---
name: review-retro
description: Post-review retrospective on a GitLab MR previously reviewed with /deep-review. Fetches the human review comments, compares them against what my review caught, verifies the reviewers' claims, distills the misses into lessons, and appends them to the review-lessons journal. Triggers on "/review-retro <MR url>", "run a retro on this MR review", "why did my review miss this".
---

# Review Retro

Turn a human review into durable review knowledge. Input: a GitLab MR URL. Optionally the user also pastes what the earlier /deep-review run found; if not, reconstruct it from the comments they posted on the MR (resolve their GitLab username with `glab api user | jq -r .username`) and ask when ambiguous. The comparison source can also be a second /deep-review run of the same MR at the same head (a different model or session) instead of a human review: classify what one run caught and the other missed with the same taxonomy, skip the discussion-focused steps that don't apply, and name which run caught each lesson in its Source line.

## The journal

`~/.claude/journals/<app>/review-lessons.md`, where `<app>` is the reviewed repo's name from its remote: `basename -s .git "$(git remote get-url origin)"` (no `origin` → its only remote; no remotes → the repo's top-level directory name). Lessons are per app and shared by every clone of it, wherever it sits on disk. `mkdir -p` the directory — a first retro on an app legitimately creates it. When the file already exists, always Read it first: the house style is defined by what is there, entries are **Lesson / Why / How to apply / Source**, and existing sections are updated in place, never duplicated. Merging is at ENTRY level, by root cause: an entry that shares a new lesson's root cause is extended — its Why gains the new case, its How to apply generalizes, its Source gains the MR — never given a near-duplicate neighbor. The journal is loaded before every review, so each entry taxes all of them: prefer generalizing an existing entry over adding one, and if the file has grown past ~15 sections, consolidate same-root-cause entries while you are in there.

## Steps

1. Fetch every discussion: `glab api "projects/<project_path_urlencoded>/merge_requests/<iid>/discussions?per_page=100"` — paginate if 100 come back.
2. Partition the notes: system notes (ignore), bot findings, the user's own comments, human reviewer comments. Review-summary comments and requested-changes reasons count as findings too, not just inline threads.
3. Classify each substantive human finding:
   - **caught** — the /deep-review review raised it (or the same issue in different words)
   - **missed-knowledge** — needed a convention, invariant, or org fact that was not written down anywhere the review reads
   - **missed-procedure** — derivable from the diff alone, but no lens procedure asks the question
   - **missed-judgment** — the facts were found but under-weighted (severity or rubric problem). Evidence of under-rating includes revealed preference: a finding the review rated below blocking (High) that the author nonetheless fixed before merging — a new commit touching the flagged lines during review — was blocking in practice; classify it missed-judgment even though it was caught.
4. Verify before recording. Read the actual code and rule files each reviewer claim rests on — reviewers can be wrong too. If a claim does not hold up, note that in the report instead; never encode an unverified opinion as a lesson.
5. **Rank before writing.** For each verified miss estimate: how often its trigger recurs in this repo's MRs, what the miss cost (a shipped defect vs. a nit the author fixed in minutes), and whether another safeguard (a lint, a bot, CI, an existing lens or journal entry that merely needed to bite) already reliably catches it. Report the ranking with a verdict per finding; only misses with a generalizable cause AND real expected value become journal entries — say explicitly which findings you are dropping or demoting, and why. When an existing entry or lens should have caught the miss, the fix is tightening that entry or lens, not a new sibling.
6. For each surviving miss, distill one journal entry (Lesson / Why / How to apply / Source with the MR link and reviewer) and write it under the entry-level merge rule above.
7. For `missed-procedure` cases, additionally propose a concrete edit to the matching lens file in `~/.claude/review-lenses/` — show the proposed change and ask before applying it. **The lens files live in a public repo; the journal does not.** A lens edit is therefore a generic question about a mechanism, carrying no app, module, or namespace names, no vendor or product names, no feature-flag names, no ticket IDs, no reviewer names, and no internal URLs — the MR link belongs in the journal entry from step 6, never in a lens. If a rule only makes sense with those specifics attached, it is `missed-knowledge`, not `missed-procedure`: put it in the journal and propose no lens edit. State the framework or language plainly when the mechanism is genuinely stack-specific; that is not company information.
8. Report back: a short table of human findings with their classification and ranking verdict (including what was verified-and-rejected and what was dropped as low-value), plus one line per journal entry added, extended, or consolidated.

Never post anything to GitLab.
