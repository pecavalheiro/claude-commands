# End Requirements Gathering

Finalize the current requirement gathering session.

## Instructions:

1. Read requirements/.current-requirement
2. If no active requirement:
   - Show "No active requirement to end"
   - Exit

3. Show current status and ask user intent:
   ```
   ⚠️ Ending requirement: [name]
   Current phase: [phase] ([X/Y] complete)
   
   What would you like to do?
   1. Generate spec with current information
   2. Mark as incomplete for later
   3. Cancel and delete
   ```

4. Based on choice:

### Option 1: Generate Spec
- Create 06-requirements-spec.md following EXACTLY the Phase 5 output contract in requirements-start.md (same section headings /synthesize parses; decision-complete; no intermediate states or people-coordination content)
- Defaults for unanswered NON-critical questions become final decisions, recorded under Assumptions. **Never default a critical item:** decisions flagged by the criticality override and FRs held under override option (a) are never resolved from "current information" — present each one now: the user gives a final or interim decision (recorded with its provenance tag), or the FR is descoped to a follow-up listed in Out of Scope
- People-facing follow-ups go to communications.md (header-marked NOT /synthesize input) and are echoed in chat
- Update metadata status to "complete" — permitted only when no `metadata.holds` entry has `"resolution": null`

### Option 2: Mark Incomplete
- Update metadata status to "incomplete"
- Add "lastUpdated" timestamp
- Create summary of progress
- Note what's still needed — including any outstanding holds (C-n, owner, held FRs)

### Option 3: Cancel
- Confirm deletion
- Remove requirement folder
- Clear .current-requirement

## Final Spec Format:

Use the Phase 5 output contract from requirements-start.md verbatim — sections: Problem Statement, Solution Overview, Functional Requirements (FR*), Technical Requirements, Implementation Hints, Acceptance Criteria, Assumptions, Out of Scope. Do not use an alternative template: /synthesize parses these exact section names.

5. Clear .current-requirement
6. Update requirements/index.md