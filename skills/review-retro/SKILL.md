---
name: review-retro
description: Post-review retrospective on a GitLab MR previously reviewed with /deep-review. Compares the other reviews against what my review caught, verifies their claims, and reports which changes to my review setup (journal, lenses, the review commands) would be worth making, ranked by cost, value and how likely the situation is to recur. Triggers on "/review-retro <MR url>", "run a retro on this MR review", "why did my review miss this".
---

# Review Retro

A retro answers one question: should anything about how I review change because of this MR, and which changes would be worth their cost? The deliverable is that analysis. The decision is mine and usually comes later, so the retro is complete once the analysis is delivered; applying a change is a separate request I make afterwards (see the last section).

Expect most retros to conclude that little or nothing should change. The journal and the lenses are read before every review, so each addition costs every future review some attention, and a lesson drawn from a single MR is often an edge case. A retro that finds nothing worth changing has done its job.

Input: a GitLab MR URL. Optionally I paste what the earlier /deep-review run found; if not, reconstruct it from the comments I posted on the MR (resolve my GitLab username with `glab api user | jq -r .username`) and ask when that is ambiguous. The comparison source can also be a second /deep-review run of the same MR at the same head (a different model or session) instead of a human review: classify what one run caught and the other missed with the same taxonomy, skip the discussion-focused steps that do not apply, and name which run caught each lesson.

## Where a change can live

- **The journal**, `~/.claude/journals/<app>/review-lessons.md`, for knowledge specific to one app: conventions, invariants, org facts. `<app>` is the reviewed repo's name from its remote: `basename -s .git "$(git remote get-url origin)"` (no `origin`: its only remote; no remotes: the repo's top-level directory name). Lessons are per app and shared by every clone of it. Entries are **Lesson / Why / How to apply / Source**; the house style is whatever the file already does, so read it first. Merging is by root cause: a lesson that shares an existing entry's cause extends that entry (its Why gains the case, its How to apply generalizes, its Source gains the MR) instead of getting a near-duplicate neighbor. Past ~15 sections, same-cause entries should be consolidated.
- **The lenses**, `~/.claude/review-lenses/`, for generic questions a review should ask about a mechanism. They live in a public repo, so a lens question carries no app, module or namespace names, no vendor or product names, no feature-flag names, no ticket IDs, no reviewer names and no internal URLs; naming the framework or language of a stack-specific mechanism is fine. A rule that only makes sense with those specifics attached is journal knowledge, not a lens question. When a journal lesson graduates into a lens, its journal entry goes away in the same change, so the lesson is not read twice.
- **The review commands themselves** (/deep-review, this skill), when the miss came from how the review runs (what it reads, when it runs, what it records) rather than from what it knows or asks.

## Steps

1. Fetch every discussion: `glab api "projects/<project_path_urlencoded>/merge_requests/<iid>/discussions?per_page=100"`, paginating if 100 come back. Also fetch the versions (`.../merge_requests/<iid>/versions`), so each finding can be placed against the head it was written on.
2. Partition the notes: system notes, bot findings, my own comments, other reviewers' comments. Review-summary comments and requested-changes reasons count as findings too, not just inline threads.
3. Classify each substantive finding from other reviewers:
   - **caught**: my review raised it, or the same issue in different words
   - **missed-knowledge**: needed a convention, invariant or org fact not written down anywhere the review reads
   - **missed-procedure**: derivable from the diff alone, but no lens asks the question
   - **missed-judgment**: the facts were found but under-weighted (a severity or rubric problem). Revealed preference is evidence of under-rating: a finding my review rated below blocking that the author fixed before merging (a new commit touching the flagged lines during review) was blocking in practice.
4. Verify everything the analysis will rest on. For each reviewer's claim, read the code and rule files it depends on; reviewers can be wrong too. For any statement about what happened on the MR (who approved, what was pushed when, what I commented on), use the MR's own record: versions, system notes, timestamps. A claim that does not hold is reported as such; an unverified opinion never becomes a lesson.
5. Work out the candidate changes. For each verified miss with a cause that generalizes beyond this MR, decide where a fix would live (the list above) and what it would say, in a sentence or two. When an existing journal entry, lens question or command step should already have caught the miss, the candidate is tightening that, not adding a sibling. Changing nothing is always one of the candidates.
6. Rank the candidates by cost × value × likelihood, giving the reason behind each rating:
   - **Value**: what it would have prevented here. A shipped or payout-level defect is worth a lot; a nit the author fixed in minutes is worth little.
   - **Likelihood**: how often the situation recurs in this repo's MRs, and whether something else (a lint, a bot, CI, an existing entry that only needed to bite) already catches it reliably.
   - **Cost**: the work to make the change plus what it adds to every future review. A clause in an existing line is cheap; a new section, lens item or command step is not.
   Also say which findings produced no candidate, and why.
7. Deliver the report. That completes the retro.

## The report

Write it to be understood on its own, possibly days later and without this session's context: plain language, every finding and candidate described by what it is rather than by a label invented during the session, and the reasoning behind each rating visible. It covers, in order:

- **What was compared**: the head my review read and the current head, and where my review's findings came from (pasted output, a second run, or a reconstruction from my posted comments).
- **The findings**: each with its source, classification and verdict, and any claim that did not hold, with file:line evidence.
- **The candidate changes, ranked**: what each would change and where, its cost, value and likelihood with the reason for each, and which candidates overlap or replace each other. Exact wording is not needed yet; it is written when I ask for the change.
- **What the retro noticed about the MR itself**, such as a defect still in the code at the current head, as facts with their evidence.

## Applying a change later

When I ask for specific changes, draft each one's exact wording under the rules for where it lives (check the journal for the same mechanism and the MR first, since another retro may have touched it), show it, and write it once I confirm. An ambiguous reply is a question back, not a decision. Afterwards, list one line per change written.

Never post anything to GitLab.
