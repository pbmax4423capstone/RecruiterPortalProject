# Work Coordination Guide

## Overview

This document enables collaborative planning and coordination between Patrick Baker, Cole Arnold, and their respective Copilot agents in the RecruiterPortal project.

## 🎯 Current Status

**Last Updated:** 2026-01-08

### Active Work Items

| Status | Owner | Task | Agent Used | Start Date | Notes |
|--------|-------|------|------------|------------|-------|
| 🟢 Available | - | - | - | - | Ready for assignment |

### Completed Work Items

| Owner | Task | Completed Date | Notes |
|-------|------|----------------|-------|
| - | - | - | - |

---

## 🤝 Coordination Protocol

### Before Starting Work

1. **Check this file** - Review "Active Work Items" to avoid conflicts
2. **Update status** - Add your task to the table with 🔵 In Progress status
3. **Notify team** - Post in Slack/communication channel
4. **Pull latest** - Run `git pull origin main` to get latest changes

### During Work

1. **Update progress** - Change status emoji and add notes regularly
2. **Flag blockers** - Use 🔴 Blocked status if stuck, explain in Notes
3. **Commit often** - Make small commits with clear messages
4. **Coordinate handoffs** - Update this file when handing off to another agent/person

### After Completing Work

1. **Mark complete** - Move item to "Completed Work Items" table
2. **Document changes** - Update relevant docs (COLE_ARNOLD_DEVELOPMENT_GUIDE.md, etc.)
3. **Notify team** - Post completion in communication channel
4. **Clean status** - Change status to 🟢 Available for next task

---

## 🤖 Agent Collaboration Patterns

### Pattern 1: Sequential Handoff
One agent completes work, documents findings, hands off to next agent.

**Example:**
```
Task: Implement new dashboard feature
1. Patrick's Agent: Creates Apex controller → Documents in handoff notes
2. Cole's Agent: Creates LWC component → Uses controller from step 1
3. Patrick: Reviews and deploys to production
```

**Handoff Template:**
```markdown
## Handoff: [Task Name]
**From:** [Agent/Person]
**To:** [Agent/Person]
**Date:** YYYY-MM-DD

### Work Completed
- Item 1
- Item 2

### Next Steps
- Step 1
- Step 2

### Important Notes
- Any warnings or gotchas
- Files modified
- Dependencies

### Testing Done
- Test 1 ✅
- Test 2 ✅
```

### Pattern 2: Parallel Work
Multiple agents work simultaneously on independent components.

**Example:**
```
Task: Update multiple email templates
- Patrick's Agent: Updates templates 1-3
- Cole's Agent: Updates templates 4-7
- Coordination: Regular syncs to ensure consistent approach
```

### Pattern 3: Research → Implementation
One agent researches/plans, another implements.

**Example:**
```
Task: Add new field to Candidate object
1. Cole's Agent: Research data model, create plan
2. Patrick's Agent: Implement field, update LWCs, deploy
3. Both: Review and verify
```

---

## 📋 Task Planning Template

Use this template when creating tasks that can be distributed:

```markdown
## Task: [Name]
**Created:** YYYY-MM-DD
**Priority:** High/Medium/Low
**Estimated Effort:** [Hours/Days]
**Dependencies:** [List any blockers]

### Objective
[Clear description of what needs to be accomplished]

### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2
- [ ] Criterion 3

### Subtasks
- [ ] Subtask 1 - **Owner:** [Name] - **Agent:** [Which agent]
- [ ] Subtask 2 - **Owner:** [Name] - **Agent:** [Which agent]
- [ ] Subtask 3 - **Owner:** [Name] - **Agent:** [Which agent]

### Technical Notes
[Any technical details, links to docs, related files]

### Testing Plan
[How will this be tested]

### Deployment Notes
[Deployment order, org targets, etc.]
```

---

## 🔍 Finding Information

### For Patrick's Work
- **Copilot Instructions:** `.github/copilot-instructions.md`
- **Recent Changes:** See "Recently Modified Components" section in both guides
- **Focus Areas:** Dashboard metrics, FYC rollups, email automation

### For Cole's Work
- **Copilot Instructions:** `.github/copilot-instructions-cole.md`
- **Development Guide:** `COLE_ARNOLD_DEVELOPMENT_GUIDE.md`
- **Focus Areas:** Dark mode, interview leaderboard, UI components

### Shared Resources
- **Development Guide:** `COLE_ARNOLD_DEVELOPMENT_GUIDE.md`
- **Technical Docs:** `docs/` directory
- **Build Commands:** See README.md or copilot instructions

---

## 🚨 Conflict Resolution

### When You Encounter Conflicts

1. **Stop and assess** - Don't force push or overwrite
2. **Check this file** - See who else is working on related files
3. **Communicate** - Reach out to the other person
4. **Coordinate merge** - Decide who should integrate changes
5. **Document** - Add notes to this file about the resolution

### Protected Files (Require Coordination)

Files that are actively maintained and should be modified with coordination:

#### LWC Components
- `candidateRecordView` - Has auto-refresh with CDC subscription
- `recruiterDashboard` - Main dashboard interface
- `contractBPipelineDashboard` - Contract B tracking
- `portalHeaderNew` - Dark mode publisher

#### Email Templates
All templates in `force-app/main/default/email/Candidate_Outreach/`:
- Use `{!Contact.FirstName}` merge field syntax
- Connected to `Candidate_Stage_Email_Automation` flow

#### Browser Extensions
- `chrome-extension-linkedin/` (content.js, popup.js, background.js)
- `edge-extension-linkedin/` (content.js, popup.js, background.js)
- Must maintain IIFE guard pattern

#### Connected Apps
- `LinkedIn_Import_Extension` - OAuth for browser extensions

---

## 📊 Agent Capabilities Reference

### Patrick's Copilot Agent
**Strengths:**
- Salesforce DX deployment
- Apex development
- FYC and rollup calculations
- Email template configuration
- Flow automation

**Instructions Location:** `.github/copilot-instructions.md`

### Cole's Copilot Agent
**Strengths:**
- Lightning Web Components
- Dark mode implementation
- UI/UX components
- Dashboard development
- Browser extension development

**Instructions Location:** `.github/copilot-instructions-cole.md`

### Training Agent
**Strengths:**
- Documentation creation
- Training material development
- User guides

**Instructions Location:** `.github/agents/Training Agent.agent.md`

---

## 💡 Best Practices

### For Effective Collaboration

1. **Small commits** - Easier to review and merge
2. **Clear messages** - Prefix with your name: "Cole: Added dark mode to dashboard"
3. **Frequent pulls** - Stay in sync with `git pull origin main`
4. **Document decisions** - Add context to commit messages and this file
5. **Test before commit** - Verify changes work in target org
6. **Update tracking** - Keep "Active Work Items" current

### For Agent Coordination

1. **Be explicit** - Tell agents to check this file before starting
2. **Provide context** - Give agents links to related work and docs
3. **Set boundaries** - Clearly define what each agent should/shouldn't touch
4. **Review outputs** - Always verify agent work before committing
5. **Iterate** - Don't expect perfection on first try

### Communication Templates

**Starting New Work:**
```
🚀 Starting: [Task Name]
Owner: [Your Name]
Agent: [Agent Name if applicable]
Files: [List of files you'll be modifying]
ETA: [Expected completion]
See WORK_COORDINATION.md for details
```

**Handoff Request:**
```
🤝 Handoff Ready: [Task Name]
From: [Your Name]
To: [Other Person]
Status: [What's completed]
Next: [What needs to be done]
Files: [Modified files list]
See WORK_COORDINATION.md for full handoff notes
```

**Completion Notice:**
```
✅ Completed: [Task Name]
Owner: [Your Name]
Changes: [Summary of changes]
Deployed: [Yes/No and which org]
Docs Updated: [Yes/No]
See WORK_COORDINATION.md for details
```

---

## 🔗 Related Documentation

- [Cole Arnold Development Guide](COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Development best practices
- [README](README.md) - Project overview and setup
- [Copilot Instructions (Patrick)](.github/copilot-instructions.md) - Patrick's agent instructions
- [Copilot Instructions (Cole)](.github/copilot-instructions-cole.md) - Cole's agent instructions
- [Technical Design](docs/LOXO-ATS-Design.md) - System architecture

---

## 📝 Notes & Decisions Log

### 2026-01-08
- Created WORK_COORDINATION.md for collaborative planning
- Established agent handoff protocols
- Defined coordination patterns for parallel and sequential work

---

## ❓ Questions or Issues?

If you're unclear about:
- **Responsibilities:** Check the "Agent Capabilities Reference" section
- **Active work:** Check "Active Work Items" table at the top
- **Protected files:** See "Protected Files" section
- **Process:** Review "Coordination Protocol" section

**Still stuck?** Add a note to the "Active Work Items" table with 🔴 Blocked status and details in Notes column.
