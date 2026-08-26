# List All Requirements

Display all requirements with their status and summaries.

## Instructions:

1. Derive `<repo>` (recipe in requirements-start.md's Files section; outside a git repository, stop with "not inside a git repository — the run store is keyed by repo") and read this workspace's pointer under `~/.claude/runs/<repo>/requirements/.pointers/` for the active marker
2. List all run folders in the repo's bucket — `~/.claude/runs/<repo>/requirements/` and `~/.claude/runs/<repo>/ticket-refinements/` (plus `investigations/` if present, an archive family) — across ALL workspaces: every clone and worktree of this repo shares the bucket
3. For each run folder:
   - Read metadata.json
   - Extract key information, including its origin workspace (`workspace`) and family
   - Format for display: annotate each run with its origin workspace (shorten `~`-relative), and mark the run named by THIS workspace's pointer as active

4. Sort by:
   - Active first (if any)
   - Then by status: complete, incomplete
   - Then by date (newest first)

## Display Format:
```
📚 Requirements Documentation

🔴 ACTIVE (this workspace): profile-picture-upload
   Phase: Discovery (3/5) | Started: 30m ago | From: ~/projects/app-main
   Next: Q4 about file restrictions

✅ COMPLETE:
2025-01-26-0900-ABC-123-dark-mode-toggle
   Status: Ready for implementation | 15 questions answered
   From: ~/projects/app-wt-darkmode | requirements
   Summary: Full theme system with user preferences
   Linked MR: !234 (merged)

2025-01-25-1400-export-reports  
   Status: Implemented | 22 questions answered
   From: ~/projects/app-main | requirements
   Summary: PDF/CSV export with filtering
   
⚠️ INCOMPLETE:
2025-01-24-1100-notification-system
   Status: Paused at Detail phase (2/8) | Last: 2 days ago
   Summary: Email/push notifications for events
   
📈 Statistics:
- Total: 4 requirements
- Complete: 2 (13 avg questions)
- Active: 1
- Incomplete: 1
```

## Additional Features:

1. Show linked artifacts:
   - Development sessions
   - Merge requests
   - Implementation status

2. Highlight stale requirements:
   - Mark if incomplete > 7 days
   - Suggest resuming or ending

3. Quick actions:
   - "View active: /requirements-current"
   - "Resume incomplete: /requirements-status"
   - "Start new: /requirements-start [description]"