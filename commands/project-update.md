# /project-update

Draft this week's status update for a tracker project I lead: a short overview of where the project stands, in my voice and at the length of my previous updates, from evidence gathered this session. The deliverable is a paste-ready block in this conversation. Nothing is posted to the tracker or anywhere else. Every rule below is binding, not advisory.

Input: $ARGUMENTS

The first token is the project: a URL, an identifier, a slug, or a quoted name. Everything after it is my notes for the week: where my time went, state the tracker may not show yet (an MR waiting for approval, questions I posted, with links), and anything about next week. When the project is missing, ask for it and stop.

## Step 0: project, window, calibration

1. Resolve the project through the tracker connector: name, description, lead, target date, milestones with their progress, status.
2. Read every previous status update of the project (paginate to the end). They are the sample for voice and length. Model the draft on the short ones; a past update that went ticket by ticket is not a model. The most recent update's "next week" line is the plan this week is measured against.
3. Fix the window: from the most recent update's creation time to now (run `date`). With no previous update, the last 7 days. State the window in one line of the output.

## Step 1: gather, before a word is drafted

- **Tracker.** Every issue of the project updated in the window: state transitions inside the window, and issues created or canceled in it (scope changes). Read the comments written in the window on every issue that changed state, was created or was canceled; skim the rest. A comment written when an issue closed usually holds its outcome; read it in full.
- **Merge requests.** For each issue that moved, its attached MRs and their state now: merged (when), open, approved, draft, closed. Also every MR my notes mention: when it is not attached to an issue, look for it among my MRs updated in the window whose title or branch names one of the project's issues. Use `glab` or the code-host connector.
- **Chat.** My messages in the window that mention the project, its issues or its subject (search the project's name, the key terms of its subject, and the ids of the issues that moved), and every thread linked in my notes. Read each candidate thread to its end with the thread tool; search snippets hide the conclusion. Record each thread's state: answered, open (waiting on which team), or unknown.
- **My notes.** Every statement in them is "my input". What only I can know (where my time went, intent, next week) is taken as given. What a source can confirm (an MR state, an issue status, a posted question) is checked. When the source says something else, the draft follows the source and the notes say so in one line (for example: I wrote that an MR waits for approval and it merged an hour ago).
- Keep the harvest in a scratchpad file, never in the reply.

## Step 2: the overview

Write about the project, not about its tickets.

- **Shape:** two or three short paragraphs of plain prose, no bullets. (a) One or two sentences on the week's context: where my time went, from my notes. (b) Where the project stands: what moved, said as outcomes at the level of milestones or phases ("the readiness work is almost done"); a change of scope or direction in one clause; what waits on others and on which team, with at most one link to the place where it waits. (c) One sentence on next week's focus.
- **Length:** about the word count of my shorter previous updates (count them), and never over 120 words. When it feels complete, cut it again.
- **No ticket list.** Do not walk through the issues. No ticket ids by default: a ticket is named only when it is the single headline of the week, as one linked clause. No MR numbers, file or config names, field names, enum values, counts, query results, or other technical detail.
- **Next week:** from my notes. When my notes say nothing about it, write the most likely focus from the evidence (the next open milestone, the issue that was just unblocked) and flag it as a guess below the draft.
- **People:** no @mentions unless my notes ask for one. Whoever the project waits on is named by team, never by person: take the team from the thread, or from the tracker when the thread only names people.
- **Words:** my voice, first person, plain. No em dashes or en dashes: use commas, colons, full stops, or two sentences. No upbeat filler openers, no headings inside the update.

## Step 3: health

Recommend a health value (on track, at risk, off track) in one sentence with its reason: the open work left against the project's target date, and the capacity the evidence shows. Milestone dates count only when the project is still planned around them; when a milestone date passed with nobody replanning, or when my notes or a recent update say the dates are stale, weigh against the target date alone. Never set it; it is my call.

## Output

1. One line: the window covered.
2. The draft, in a fenced markdown block, paste-ready, links as markdown.
3. At most three notes of one or two sentences each, and only ones that change what I post: a fact where my notes and a source disagree; work that moved but has no evidence beyond a status change, left out (ask whether to add it); the next-week guess; the health recommendation. No evidence tables and no summary of what was read, unless I ask.

## Revisions

A correction changes exactly what it names and nothing else. "Shorter", "too detailed" or "it's an overview" means rewrite to the shape in Step 2, not trim a few words. When a correction disputes a fact, re-read the source before rewriting; never re-guess. Say in one line what changed.

## Prohibitions

1. **Never create, edit, or post a status update in the tracker, and never post or draft anything in chat.** The deliverable is text in this conversation.
2. **Never write to any tool**: no comments, no status or health changes, no reactions.
3. **No per-ticket bullets or walk-through**, even when a previous update had them.
4. **No sentence without a source** read this session or a statement in my notes.
5. **Never round open to done**: "merged", "done", "answered", "agreed" appear only when the source shows that event.
6. **Never repeat a fact from my notes that a source contradicts** without saying so in the notes.
7. **No em dashes or en dashes** anywhere in the reply.
8. **Never set or assume the health value**; recommend it.

## Pre-output gate

Immediately before the final message: count the words in the fence (120 or fewer) and the paragraphs (three or fewer); grep the fence for bullets (`^\s*[-*] `), em and en dashes, ticket-id shapes (`[A-Z]{2,}-[0-9]+`) beyond the one allowed headline, and MR references (`![0-9]+`); confirm every "done", "merged", "answered" traces to its event in a source. A draft that fails any check is fixed now, not flagged.
