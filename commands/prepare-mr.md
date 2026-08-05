# Prepare the MR description

Write the MR title and description for this branch's changes, filling the repo's own MR
template, and list what still has to be solved before it can merge.

The ticket is $ARGUMENTS — treat it as the intent, not the record: what the description
reports is what the diff actually does, and why. When no ticket is given, take the key from
the branch name, or work from the diff alone and say so.

For work that came through the requirements pipeline and needs its run artifacts swept,
use `/prepare-mr-deep` instead.

## Hard rules

- Never post, push, or create/update the MR (`glab mr create|update` included). The output
  is paste-ready; publishing is mine.
- Reproduce the template's headings, order, `<details>` blocks, and GitLab quick-action
  lines (`/assign me`) verbatim. Drop only the author-instruction comments from the
  sections you fill. Fill sections; never redesign them.
- Tick a checkbox only with evidence for it. Anything else stays unticked and gets listed
  for me to confirm — never make me sign a claim I did not make.
- Invent nothing: no links, ticket keys, flag names, screenshots, or commands absent from
  the diff, the repo, or the ticket. A section with no truthful content says `None` or
  `N/A`.
- Never claim a check ran that did not run, or a result you did not see.
- Keep it cheap: one pass over the diff, the template, and the ticket. No subagents, no
  repo-wide exploration, no re-reading what is already in context.
- Plain direct English, valid GitLab Markdown, identifiers in backticks. No first-person
  narration, no em dashes.

## Instructions

1. **Gather, once.** Current branch, its base, the branch's `git log`, the full
   branch-vs-base diff, and `git status`. Uncommitted or untracked work is not in the MR:
   note it.
2. **Read the ticket** from the argument (Linear MCP or `glab`, whichever fits the URL).
   If it cannot be fetched, say so in one line and continue from the commits and the diff.
3. **Reconcile ticket against diff.** The ticket says what was wanted; the diff says what
   shipped. Read enough of the changed files to state the *why* behind the approach, not
   only the *what*, and name every divergence: asked for but absent, present but not asked
   for, solved differently. A divergence you cannot explain from the code is a question
   for me, never narration in the description.
4. **Find the template**: `.gitlab/merge_request_templates/*.md`, then
   `.github/PULL_REQUEST_TEMPLATE.md` or `pull_request_template.md`. Several candidates →
   pick the fitting one and name it. None → ask whether to use a plain
   Summary / Changes / How to verify / Risks shape.
5. **Fill it** for a reviewer who has not read the ticket: what changed and why, the ticket
   link, how to verify (commands or steps a reviewer can actually run), risks, dependent
   MRs, feature flags, migrations. UI touched → leave the screenshot placeholder rather
   than fabricating one.
6. **Collect what must be solved before merge**: ticket requirements the diff does not
   meet, `TODO`/`FIXME` this change adds, skipped or pending tests, debug or commented-out
   code, uncommitted work, an unpushed branch, and checkboxes needing my confirmation.
   Verify each against the code before listing it; nothing open is a fine result, so never
   manufacture an item.
7. **Title**: match the convention in the base branch's recently merged MRs (ticket-key
   prefix or not, imperative or descriptive). One recommendation plus at most two
   alternates; in a squash-merge repo this becomes the commit message. Take the ticket key
   from the ticket or the branch name; never invent one.

## Output

One message, in this order:

1. **Before this can merge** — the Step 6 items, each with the evidence it is still open
   and the smallest thing that closes it. Blockers also go into the description, under the
   template's own fitting heading when it has one, otherwise as one labeled section
   appended after the template's content.
2. **Title** — the recommendation in its own fenced block, alternates plainly below.
3. **Description** — the filled template in a single fenced block, nothing else inside the
   fence, so the raw markdown survives copy/paste from the terminal.
4. **Check before pasting** — what you inferred, left unticked, or marked `N/A`, plus any
   ticket divergence you could not explain.

Then stop. Pushing, creating the MR, and pasting are mine.
