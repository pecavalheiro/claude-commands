# Prepare the MR description (deep, pipeline-aware)

Write the merge-request title and description for the work in this branch, filling the
repo's own MR template, and list everything that still has to be solved before it can
merge: $ARGUMENTS
(optional — a run folder path, a ticket URL, or a template name to force; when empty,
everything is discovered)

Use this only for complex work that came through the requirements pipeline and whose loose
ends are recorded in a run folder. It is deliberately thorough and therefore slow: for
everything else use `/prepare-mr`, which works from the diff and the ticket alone.

This is the delivery step after `/synthesize`. The implementation is done; the job now is
to describe it honestly and to surface what the run left open. The pipeline already
recorded every loose end — in `implementation/`, in the spec's Assumptions and volatile
markers, in `communications.md`, in `metadata.json` holds — so pending items are
**collected from those artifacts and re-verified against the code**, never invented here
and never guessed from the diff alone.

## Hard rules

1. Never post, never push, never create or update an MR, never run `glab mr create` or
   `glab mr update`. Everything is local and paste-ready; publishing is mine.
2. Never edit the repo's template file, and never restructure it. Its headings, their
   order and numbering, its `<details>` blocks and its GitLab quick actions (`/assign me`
   and friends) are reproduced verbatim. You fill sections; you do not redesign them.
3. Only tick a checkbox you have evidence for. A box asserting something you did not
   verify stays unticked and becomes a pre-merge item for me to confirm — silently
   ticking it makes me sign a claim I never made.
4. Nothing in the description is invented. Every link, ticket ID, flag name, dependency
   MR, and command comes from an artifact, the repo, or the session. No placeholder URLs,
   no plausible-looking ticket keys, no "should be tested by" filler. If a template
   section has no truthful content, say `None` / `N/A` and why in a clause.
5. Never claim a check ran that did not run, or a result you did not see. The verification
   sections carry the commands actually executed and their actual outcomes.
6. Evidence discipline for pending items (as in `/deep-review`): an artifact is a claim,
   not proof. A `BLOCKED:` line, an unmet acceptance criterion, or an unmerged dependency
   may have been resolved later in the run — confirm each against the current code before
   listing it, and drop it if it is settled. Finding nothing pending is a valid, good
   result; never manufacture a blocker to fill the list.
7. No run-internal labels anywhere in the description or title: no FR/TR numbers, no
   `C-n`, no claim IDs, no phase names, no "the spec", no journal names. The MR page and
   the repo are all a reader has. Restate the fact in plain words instead.
8. This command creates no files. Output lands in chat, in fenced blocks I copy from.

## Step 1 — Locate the work and its run

- The change: `git status`, the current branch, its base branch, and the full diff of
  branch-vs-base **plus** anything uncommitted or untracked. Uncommitted work is not in
  the MR — note it now; it becomes a pre-merge item in Step 4.
- The run: if `/synthesize` ran in this session, that run folder is authoritative and its
  final report ("Needs you now", "Yours by design", "Deviations from spec",
  "Done & verified") is the primary source for Step 4 — it is already in context.
  Otherwise resolve the folder from `$ARGUMENTS`, then `requirements/.current-requirement`,
  then the most recent `requirements/YYYY-MM-DD-HHMM-*` that has an `implementation/`
  directory. If several fit, take the most recent and say which.
- Confirm the run actually matches this branch (touched files, ticket key, timing). A
  mismatched run is worse than none: if it does not match, say so and treat it as absent.
- No run folder → say so plainly in one line, then work from the session and the diff
  alone, and state in the output that the pending-item list is only as complete as this
  session's context.

## Step 2 — Find and read the template

- Look for `.gitlab/merge_request_templates/*.md` (case varies: `default.md`, `Default.md`),
  then `.github/PULL_REQUEST_TEMPLATE.md` or `.github/pull_request_template.md` or
  `docs/`. Read the whole file; also read whatever it links to in-repo for authoring
  rules (an MR guide, `AGENTS.md`) when it names one — those rules bind this output.
- Several templates → pick the one whose purpose fits the change, name it, and say why
  in one line. Genuinely ambiguous → ask me, do not guess.
- No template anywhere → STOP and tell me; ask whether to use a plain
  Summary / Changes / How to verify / Risks shape instead.
- Template comments (`<!-- ... -->`) are author instructions: drop the instruction block
  from a section once that section is filled, keep every structural or executable
  element. Keep the quick-action lines exactly as written and in place.

## Step 3 — Fill the template from the artifacts

Read `06-requirements-spec.md`, `03-context-findings.md`, `research-notes.md`,
`metadata.json`, and everything under `implementation/` (the `current` symlinks, or the
newest timestamped file when a symlink is missing). Then map, rewriting for a reviewer who
has never seen the run — spec prose is written for implementation, not for review:

- **Description / Summary** ← Problem Statement + Solution Overview, plus the approach and
  any trade-off worth a reviewer's attention (from `implementation-notes`). Enough that
  the diff does not have to be read to understand intent.
- **Changed behavior** ← the requirements as implemented, checked against the diff.
- **Related resources** ← the ticket URL and the source links in `metadata.json` /
  the claims register. Real links only.
- **Type of change** ← inferred from the diff; state the inference so I can correct it.
- **Testing / How to verify** ← the acceptance criteria turned into steps a reviewer can
  run, plus the exact commands the Definition-of-Done gate ran and their results.
- **Rollout / risks / dependencies** ← the prerequisites in Technical Requirements (flags,
  migrations, keys, config), deploy order, and every `[volatile: <dependency>]` dependency
  whose MR is still open — that is what the "requires a specific branch / feature flag"
  questions are asking.
- **Scope** ← Out of Scope, each item with the ticket that owns it.
- **UI / screenshots** ← only if the diff touches UI. Never fabricate a screenshot or a
  Loom link: leave the placeholder and make it a pre-merge item.
- **Checklists** ← per rule 3.

Register: plain, direct English, valid GitLab Markdown, every identifier (module,
function, variable, config key, file path, literal value) in backticks. No em dashes, no
bold-for-emphasis, no first-person narration of work ("I decided", "as we discussed").

## Step 4 — Collect and verify what must be solved before merge

Sweep every source, then verify each candidate against the current code per rule 6:

- The session's `/synthesize` report: "Needs you now" items, forced decisions, and every
  deviation from spec, with its severity.
- `implementation/implementation-todo_current`: any task not completed, any `BLOCKED:` line.
- `implementation/implementation-notes_current`: deviations, discoveries, decisions made
  mid-flight.
- `06-requirements-spec.md`: acceptance criteria with no evidence of being met;
  Assumptions (each names the fact that would settle it); `[volatile: <dependency>]`
  markers whose dependency is still unmerged; any `interim — final answer owned by <who>`
  tag whose owner has not answered; prerequisites in Technical Requirements not yet
  executed (flag not created, migration not run, key not set).
- `communications.md`: items still standing — what I owe someone, and to which
  destination.
- `metadata.json`: `holds`, and any FR held or descoped.
- The diff: `TODO`/`FIXME` this change introduces, skipped or pending tests, commented-out
  or debug code, uncommitted work from Step 1, and an unpushed branch.

Give each surviving item one class:

- **Blocks merge** — code or config work that must land first.
- **Mine before merge** — not code: an answer to chase, a message to send, a flag to
  create, a screenshot to attach.
- **Reviewer needs to know** — not a blocker; belongs in the description (dependency MR,
  flag-off state, follow-up ticket).
- **Follow-up** — after merge, named with its owning ticket, or flagged as a ticket I
  still need to create.

Blocks-merge and mine-before-merge items also go **into the description**, so they are
visible on the MR page: under the template's own most fitting heading when one exists (an
exceptions, testing, or risks section), otherwise as one clearly-labeled section appended
after the template's content. Phrase them factually and without the internal labels
(rule 7). Reviewer-needs-to-know items are folded into their natural template section, not
listed as caveats.

## Step 5 — Title

- Derive the repo's convention from recently merged MR titles (`glab mr list --state merged`,
  or the first-parent merge commits and branch names on the base branch): ticket-key
  prefix or not, scope prefix or not, imperative or descriptive.
- One recommended title plus at most two alternates. Short, specific, meaningful on its
  own — in a squash-merge repo this becomes the commit message.
- The ticket key comes from the run's metadata, the ticket URL, or the branch name. Never
  invent one.

## Output

One message, in this order:

1. **Before this can merge** — the classified items from Step 4, blocks-merge first, each
   with the evidence that it is still open (`file:line`, artifact line, or command
   output) and the smallest thing that closes it. If nothing is open, say
   "Nothing open — this is mergeable as it stands" and say what you checked to conclude it.
2. **Title** — the recommendation in its own fenced block, alternates listed plainly below.
3. **Description** — the filled template in a single fenced block, nothing but the
   description inside the fence. Terminal markdown rendering eats the formatting
   characters, so the fence is what makes it copy/pasteable.
4. **Confirm before you paste** — the short list of things you inferred or could not
   verify: the type-of-change guess, every checkbox left unticked and why, any section
   filled with `None`/`N/A`, and anything the run folder could not settle.

Then stop. Pushing, creating the MR, and pasting are mine.
