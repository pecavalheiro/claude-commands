# /weekly-recap

Draft my end-of-week recap for the team channel: what I worked on this week and what comes next, in my voice and at my level of detail, from evidence gathered this session. The deliverable is a paste-ready block in this conversation. Nothing is posted, nothing is drafted inside Slack, nothing is saved anywhere. "Draft" means here. Every discipline and prohibition below is binding, not advisory.

## Step 0: environment, week, calibration

1. Read `~/.claude/journals/weekly-recap.md`, the machine-local environment file (in no repo, never installed or committed). It names the team channel, my identifiers in each tool, the emoji vocabulary and what each marker means, the phrase that marks my past recaps, and at least one past recap as the style sample. This file is load-bearing: if it is missing, say so and ask me for the channel and a past recap instead of guessing a channel or inventing markers.
2. Fix the week: Monday through today, my local date. Run `date`, derive the Monday, and state both dates in the findings. There is no argument; the command always covers the current week.
3. Read my last two recaps in the team channel (search the marker phrase, from me, in that channel). They calibrate voice and length. The most recent one's "Next week" section is the plan this week is measured against.

## Step 1: gather, all three sources, before a single line is drafted

- **Tracker.** Issues assigned to me updated since Monday, every team. Record each issue's state transitions inside the week (started, in review, done) and its project.
- **Merge requests.** Through `glab`: resolve my username (`glab api user`), then list my MRs updated since Monday (`glab api "merge_requests?author_username=<me>&updated_after=<monday>T00:00:00Z&scope=all&per_page=100"`), and separately every MR of mine still open regardless of age. Merged, opened, draft, and still-open are different states; record which.
- **Chat.** Every message I sent since Sunday (search `from:<my id> after:<sunday>`, sorted by time, paginated to the last page). The channels tell me where my week went. For every thread that could become a bullet, read the FULL thread with the thread tool on its parent message; search snippets truncate and hide the conclusion. Record the thread's state at week end in one of four words: done, open, handed-over (only when the thread shows the handover happening), unknown.
- Harvest into a scratchpad file: topic, source (channel and time, issue, MR), week-end state, and the people involved with their user ids, taken from the thread itself.

## Step 2: cluster into topics

Group by topic, never by ticket. Every topic gets one of these roles:

- **Rotation or requests**: support rotation, ad hoc investigations for other teams.
- **Delivery**: project work of mine that moved (merged, unblocked, finished).
- **Finding**: a gap or bug I surfaced that others should know about, with the thread where it is being discussed and the person who opened that thread.
- **Supporting**: an investigation that belongs to someone else where I am helping; the owner is whoever the thread shows leading it.
- **Side item**: tooling, shares, presentations, anything that is not team delivery. Side items never enter the draft on their own; they go to the candidates list (Output, part 5).
- **Open**: anything I left running: open MRs, threads where my last message leaves a question or says I am working on it. This list feeds the "wrap up" line.

## Step 3: ask me, then wait

Before drafting anything about next week, ask me in one message and wait for the answer:

1. **Availability next week**: PTO, partial days, rotation, anything that changes the shape. Never read this from a calendar, a status, or an assumption.
2. **Priorities**: present the candidates found (the Open list, project commitments visible in chat, the finding I am working on) with their week-end state, and ask me to rank them highest, medium, low. If my availability answer leaves most of next week unavailable, ask for the week after as well. Do not pre-rank; the ranking is mine.
3. **Side items**: list the candidates found and ask whether any goes in.

Claims that come from my answers are labeled "my input" in the evidence table. They are not verified and are never presented as verified.

## Step 4: the register

The style sample in the journal is a ceiling for length and detail, not a floor. When the draft feels complete, halve it.

- Open with the greeting line from the sample. Sections in this order: the week's bullets; a blank line; "Next week:"; then "Week after:" only when my availability answer leaves most of next week unavailable.
- **Two to three top-level bullets** for the week, one or two sentences each. A finding goes as a nested sub-bullet under the topic it came from, never as its own top-level line.
- **Topics, not tickets.** No ticket ids, MR numbers, counts of tickets or MRs beyond "a bunch", status codes, field names, identifiers, or query results. Project-level outcomes in one clause ("merged a bunch of <project> MRs, no more pending blockers"), never what each MR does. A project link with the project's title is fine; an issue link is not.
- **Rotation line**: one neutral sentence saying it happened and what kind of work it was. No cases, no customer names, no volume adjectives that read as complaint, no drama.
- **Finding**: one sentence for the gap, one for what I am doing about it, then "Details in @Person's thread" pointing at the thread where it is discussed. The person is whoever opened that thread, as read from the thread.
- **Supporting**: "supporting @Person investigating <topic>", the person being who leads the thread, and no technical detail.
- **Next week lines**: each opens with a priority marker from the journal vocabulary. An availability note opens with the info marker and comes first. "Wrap up MRs/investigations I have open" is the usual first priority when the Open list is not empty and I rank it so.
- **People**: `@Full Name`, only people the evidence shows involved. Links: the word that carries the link stays in the text; the URLs are listed under the fence for me to attach in the composer.
- **Emoji**: only from the journal vocabulary, used where the sample uses them. Never invent one.
- **Words**: plain and simple, my voice, as I would type it. No em dashes or en dashes anywhere: commas, colons, full stops, or two sentences. No fake-positivity openers, no header scaffolding.

## Step 5: evidence gate, every line traces to a source

- Each sentence in the draft maps to one row: the message (channel and time), the issue and its state, the MR and its state, or "my input" from Step 3. A sentence with no row is deleted, not softened.
- **State is what the full thread shows at week end.** An open question is open ("I'd say team X, who should I ping?" is open). An instruction to me ("you'll need to coordinate with X") is a task of mine, not a handover done. "Passed to", "handed to", "resolved", "agreed" appear only when the thread shows that event. Rounding open to done is the failure this gate exists to catch.
- **Two threads sharing a team name or a word are not one topic.** Confirm the parent of each thread before connecting anything.
- **People**: named only when the evidence shows them in that role in that thread. Never invent who owns what or who was told.
- **The plan check**: compare this week's topics against the last recap's "Next week". Anything planned and not covered goes to Output part 5 for me to decide, never silently into the draft.

## Output

1. **Findings, brief**: the week's dates, what was read (issues, MRs, messages, threads), topics with their role and week-end state.
2. **The draft**, in a fenced block, paste-ready: mentions as `@Full Name`, link words as plain text.
3. **Attach in the composer**: each link word with its URL, each mention with the handle as found in the evidence.
4. **Evidence table**: one row per sentence: sentence, source, state or "my input".
5. **Left out, for me to decide**: side items found, items planned last week and not covered, threads whose week-end state is unknown.
6. One line confirming nothing was posted, drafted in Slack, or saved.

## Revisions

A correction changes exactly what it names and nothing else: "shorten the second bullet" shortens the second bullet; "drop the ids" drops the ids. When a correction disputes a fact, re-read the source before rewriting; never re-guess. Say in one line what changed.

## Prohibitions

1. **Never create a Slack draft, send, schedule, or post anything**, in any channel or DM, on any wording of "draft". The deliverable is text in this conversation.
2. **Never write to the tracker, GitLab, Notion, or any other tool.** The run is read-only.
3. **No ticket ids, MR numbers, counts, status codes, field names, identifiers, or query results in the draft.** Issue links are out; project links with a title are in.
4. **No em dashes or en dashes** anywhere in the draft or the attach list.
5. **Never assign availability or priorities.** Both come from my answers this run.
6. **Never state a resolution the thread does not show.** Open stays open; unknown stays unknown or is left out.
7. **Never connect threads on keyword overlap.**
8. **Never name a person the evidence does not place in that role**, and never invent ownership or handovers.
9. **Never include a sentence without an evidence row.**
10. **Never exceed the sample's length or detail**; it is the ceiling.
11. **Never invent emoji**; the journal vocabulary is the whole set.
12. **Never let a revision change more than the correction named.**

## Pre-output gate

Immediately before the final message: walk the draft against all twelve prohibitions. Grep the fence for em and en dashes, for ticket-id shapes (`[A-Z]{2,}-[0-9]+`), and for MR references (`![0-9]+`). Confirm every sentence has an evidence row and every "done", "merged", "handed", "agreed" traces to that event in its source. Confirm the availability line and every priority marker came from my answers this run, not from inference. Confirm the greeting, markers, and emoji came from the journal. Count the top-level bullets: two or three. A draft that fails any check is fixed now, not flagged.
