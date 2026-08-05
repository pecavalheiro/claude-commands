# Commit

Commit the changes in this branch, split into logically and chronologically ordered commits.

## Instructions

1. Survey the work: `git status` plus the full diff — staged, unstaged, and untracked files — so nothing is missed.
2. Read recent `git log` and match the repo's commit-message style.
3. Group the changes into logical units:
   - Check what depends on what; dependencies are committed first, in order.
   - Logical changes are committed together with their respective tests.
   - A file holding more than one logical change may be split across commits (`git add -p`).
4. Commit each group in order, staging only that group's files.
5. Verify: the working tree is clean after the last commit, and every commit message is short and clear.

## Hard rules

- Never push — committing is the whole job; pushing is mine.
- Never amend or rewrite commits that existed before this run.
