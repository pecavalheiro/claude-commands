# Open the MRs

Commit, split, and open the work in this branch as one merge request — or a stack of
them when it exceeds the size cap: $ARGUMENTS
(optional — a ticket URL/key for the descriptions; when empty, taken from the branch
name, or the diff alone)

This is the publish step that follows /synthesize (or any branch whose implementation is
done). Unlike /prepare-mr, this command DOES push and create MRs: invoking it is my
authorization for those outward actions — but only through its two gates (partition,
publish), never before them.

## Hard rules

1. **The size cap is hard: 550 changed lines per MR** — additions + deletions vs the MR's
   target, everything counted the same (code, tests, comments, lockfiles, generated
   files). Over the cap → a stack of MRs. An indivisible unit larger than the cap on its
   own → STOP and ask; never silently exceed it. One flag exception: a lockfile or
   generated file whose churn alone approaches or busts the cap → surface it and ask what
   to do (count it, isolate it in its own chunk, or leave it out of the count) before
   partitioning.
2. **The repo's GitLab MR template is mandatory.** None found → STOP immediately and say
   so — never invent a shape, never open a template-less MR, never fail silently. More
   than one → list them and ask me to pick; never guess.
3. **Commits follow /commit**: read `~/.claude/commands/commit.md` at the moment of use
   and apply its rules. Scope note: its "never push" rule governs the commit step —
   pushing happens only in this command's publish phase, which is the sanctioned path.
   Its "never amend or rewrite pre-existing commits" rule holds absolutely here too.
4. **Descriptions follow /prepare-mr's hard rules**: read
   `~/.claude/commands/prepare-mr.md` at the moment of use — template structure
   reproduced verbatim, checkboxes ticked only with evidence, nothing invented, no check
   claimed that did not run. Its "never create the MR" rule is superseded by this
   command's publish phase; nothing else in it is.
5. **Every MR is independently green before it is opened**: the chunk's targeted tests +
   format/lint pass at its boundary commit, not just at the tip.
6. Nothing outward before the publish gate: no push, no MR creation, no reviewer
   assignment. On my go, execute exactly the confirmed sequence; a failure mid-sequence
   stops the run and reports precisely what was created and what was not — never papered
   over, never retried into an inconsistent state.

## Step 1 — Preflight

- Current branch, the repo's default branch, `git status` (untracked included), and that
  `glab` can reach this project — if it cannot, STOP and report; nothing here works
  without it.
- The MRs' base is the repo's default branch unless the ticket/run clearly says
  otherwise; ambiguous → ask.
- Sitting on the default branch itself → nothing can be opened from here: propose ONE
  branch name (from the ticket key or the work) and wait.
- Untracked files that look unintentional (editor droppings, OS files) → list them and
  ask before anything is committed; never assume they ship.

## Step 2 — Template check (before any commit or branch exists)

Look in `.gitlab/merge_request_templates/*.md` (case varies). Exactly one → use it and
say so. Several → rule 2: ask me to pick. None → rule 2: STOP.

## Step 3 — Count and partition

- Count the total changed lines that will ship: the branch-vs-base diff plus everything
  uncommitted that belongs to the work. Additions + deletions, per rule 1.
- **≤ 550 → one MR.** State the count and continue.
- **> 550 → a stack.** Partition into logical, dependency-ordered chunks: each ≤ 550,
  sized roughly evenly (never one full chunk plus a sliver), each reviewable on its own,
  tests travelling with the code they exercise. Present the PARTITION GATE — chunks with
  their files and line counts, dependency order, proposed branch names, draft MR
  titles — and WAIT for my confirmation before any commit or branch is made.

## Step 4 — Commit (one linear history, boundaries on commits)

- Apply /commit's rules (rule 3) to everything uncommitted, with one extra constraint:
  no commit straddles a chunk boundary — each chunk's commits are contiguous, so every
  boundary lands exactly on a commit. The stack then falls out of the linear history
  with no cherry-picks and no rewriting.
- Pre-existing commits are placed, never re-cut: one that straddles a planned boundary
  or exceeds the cap by itself → STOP and ask (re-draw the partition around it, or
  accept the oversize on my explicit say-so).

## Step 5 — Stack branches and the green gate

- Single MR → the current branch is the MR branch; run the diff's targeted tests +
  format/lint once.
- Stack → the current branch tip is the LAST MR; create one branch per earlier chunk at
  its boundary commit, named as confirmed at the partition gate. At each boundary, check
  out and run that chunk's targeted tests + format/lint (rule 5).
- A red boundary is fixed before proceeding, inside this run's own commits — rebasing
  commits this run created is fine; a fix that would rewrite a pre-existing commit →
  STOP and ask.

## Step 6 — Titles and descriptions

- One per MR, per rule 4, from the ticket ($ARGUMENTS, else the branch name) and that
  chunk's diff; titles follow the repo's convention read from recently merged MRs.
- A write-up already produced this session by /prepare-mr or /prepare-mr-deep is the
  description source: reuse it rather than regenerating (for a stack, split its content
  by chunk), and carry its pre-merge items into the publish gate's confirm list.
- Each stacked description states its place plainly: part N of M, what the previous part
  provides, what the next one builds on it. The depends-on link is injected at creation
  time, when the previous MR's iid exists.

## Step 7 — Publish gate (one message, then my go)

Present, and WAIT:

- The full outward sequence: push each branch → create each MR in dependency order (the
  first targets the base; each later one targets the previous chunk's branch) → assign
  the reviewer(s).
- The reviewer question, asked ONCE for the whole stack: who should review? One or
  several names; applied to every MR.
- Whatever the descriptions leave for me to confirm: unticked checkboxes, `N/A`
  sections, screenshot placeholders.

On my go, execute exactly that sequence, injecting each previous MR's `!iid` into the
next description's depends-on line as it is created.

## Step 8 — Final report

- A table: part → title → **URL** → target branch → line count. Every MR created appears
  with its URL — that is the deliverable.
- What remains and whose it is: checkboxes to confirm, screenshots to attach, pipeline
  state per MR (read live after the push, never asserted), and the pointer that review
  feedback comes back through /mr-feedback-fix.
