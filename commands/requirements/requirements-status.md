# Check Requirements Status

Show current requirement gathering progress and continue.

## Instructions:

1. Resolve this workspace's active run: derive `<repo>` and the workspace slug (recipe in requirements-start.md's Files section; outside a git repository, stop with "not inside a git repository — the run store is keyed by repo"), then read `~/.claude/runs/<repo>/requirements/.pointers/<workspace-slug>` — valid only if its second line equals this workspace's toplevel and the named run folder exists in the bucket
2. If this workspace has no valid pointer:
   - If the bucket holds run(s) whose metadata `workspace` path no longer exists on disk (orphans of deleted clones/worktrees), list them and offer to adopt one — on acceptance, write this workspace's pointer file and continue with that run
   - Prune pointer files whose recorded workspace path or target run no longer exists
   - Otherwise show "No active requirement gathering", suggest /requirements-start or /requirements-list, and exit

3. If active requirement exists:
   - Read metadata.json for current phase and progress
   - Read gates.md in the run folder — the last appended gate is the authoritative position of the run
   - Show formatted status
   - Before continuing, Read the current phase's file under ~/.claude/requirements-phases/ (a phase's file IS the phase — see requirements-start.md); then load the appropriate question/answer files
   - Continue from last unanswered question

## Status Display Format:
```
📋 Active Requirement: [name]
Started: [time ago]
Phase: [Discovery/Detail]
Progress: [X/Y] questions answered

[Show last 3 answered questions with responses]

Next Question:
[Show next unanswered question with default]
```

## Continuation Flow:
1. Read next unanswered question from file
2. Present to user with default
3. Accept yes/no/idk response
4. Update answer file
5. Update metadata progress
6. Move to next question or phase

## Phase Transitions:
- Discovery complete → Run context gathering → Generate detail questions
- Detail complete → Generate final requirements spec