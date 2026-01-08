# Agent Coordination Guide

## Overview

This guide explains how to effectively use and coordinate GitHub Copilot agents in the RecruiterPortal project for collaborative work between Patrick Baker and Cole Arnold.

---

## 🤖 Understanding Agents

### What Are Agents?

Agents are AI assistants configured with specific knowledge, instructions, and capabilities for particular tasks. In this project:

1. **Patrick's Copilot Agent** - Configured via `.github/copilot-instructions.md`
2. **Cole's Copilot Agent** - Configured via `.github/copilot-instructions-cole.md`
3. **Training Agent** - Configured via `.github/agents/Training Agent.agent.md`

### Agent Capabilities

Each agent has:
- **Context:** Knowledge of the project structure, conventions, recent changes
- **Specialization:** Focused expertise in specific areas
- **Shared Understanding:** Access to common documentation and codebase
- **Independent Context:** Separate conversation history and working memory

---

## 🎯 Coordination Strategies

### Strategy 1: Explicit Context Sharing

When one agent needs to hand off to another, provide explicit context:

**❌ Bad - Vague handoff:**
```
"Cole, please finish the dashboard work"
```

**✅ Good - Explicit handoff:**
```
"Cole's Agent: Please implement the LWC frontend for the new FYC calculator.

Context:
- The Apex backend is complete in CandidateFYCRollupService.cls (committed)
- New method: calculateEnhancedFYC(candidateId) returns Decimal
- Should be called from contractBPipelineDashboard component
- Wire method name: getEnhancedFYCData

Acceptance Criteria:
- Update contractBPipelineDashboard.js to call new method
- Display FYC in Summary Cards section
- Format as currency with 2 decimals
- Add loading spinner during calculation

Files to Modify:
- force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.js
- force-app/main/default/lwc/contractBPipelineDashboard/contractBPipelineDashboard.html

Reference Implementation:
See how existing FYC is displayed in the Total FYC card around line 120 of the HTML.

Test in: ProdTest sandbox first
Deploy to: ProductionCapstone after testing

See WORK_COORDINATION.md for task #045 details."
```

### Strategy 2: Shared Documentation

Create documents that both agents can reference:

1. **Task specs** in SHARED_PLANNING.md
2. **Technical decisions** in docs/ folder
3. **Handoff notes** in WORK_COORDINATION.md
4. **Code comments** in complex implementations

**Example - Creating a handoff document:**
```markdown
## Handoff: Dark Mode Implementation

**From:** Cole's Agent
**To:** Patrick's Agent
**Date:** 2026-01-08

### Work Completed
- Implemented dark mode toggle in portalHeaderNew
- Created LightningMessageService channel: DarkModeChannel__c
- Updated 5 subscriber components (candidateKanban, recentActivity, etc.)
- Tested in choujifan90@gmail.com.prodtest

### Next Steps (For Patrick)
1. Deploy DarkModeChannel__c to ProductionCapstone
2. Deploy updated LWC components
3. Test with real users
4. Add to training documentation

### Files Modified
- force-app/main/default/messageChannels/DarkModeChannel__c.messageChannel-meta.xml
- force-app/main/default/lwc/portalHeaderNew/*
- force-app/main/default/lwc/candidateKanban/*
- [See full list in commit abc123]

### Known Issues
- None at this time

### Testing Checklist
- [x] Toggle works in all components
- [x] State persists on page navigation
- [x] No console errors
- [ ] Production testing (pending deployment)
```

### Strategy 3: Checkpoint System

Use checkpoints for complex multi-phase work:

```markdown
## Project: Q1 Dashboard Enhancements

### Checkpoint 1: Planning (Cole's Agent) ✅
- [x] Research requirements
- [x] Create technical spec
- [x] Identify affected components
- Document: docs/Q1-DASHBOARD-ENHANCEMENTS.md

### Checkpoint 2: Backend (Patrick's Agent) 🔵
- [ ] Update Apex controllers
- [ ] Add new SOQL queries
- [ ] Write unit tests
- Files: RecruiterDashboardController.cls, ContractBDashboardController.cls

### Checkpoint 3: Frontend (Cole's Agent) 🟡
- [ ] Update LWC components
- [ ] Add new UI elements
- [ ] Update styling
- Files: recruiterDashboard, contractBPipelineDashboard

### Checkpoint 4: Integration (Both) 🟡
- [ ] End-to-end testing
- [ ] Fix any issues
- [ ] Update documentation
- [ ] Deploy to production
```

---

## 🔄 Handoff Patterns

### Pattern A: Sequential Pipeline

```
Task: Add new email template with automation

Step 1 → Patrick's Agent
├─ Create email template
├─ Set up merge fields
└─ Document template ID
    ↓ HANDOFF (via WORK_COORDINATION.md)

Step 2 → Patrick's Agent (or Cole's if Flow knowledge)
├─ Update Candidate_Stage_Email_Automation flow
├─ Add new email action
└─ Test flow
    ↓ HANDOFF

Step 3 → Cole's Agent
├─ Update UI to show new stage
└─ Test end-to-end
    ↓ COMPLETE

Coordination Points:
- After Step 1: Share template ID and field names
- After Step 2: Share flow version number
- Before Step 3: Confirm all backend changes deployed
```

### Pattern B: Parallel Development

```
Task: Update multiple independent components

Team A (Patrick's Agent)          Team B (Cole's Agent)
├─ Update Apex Class A            ├─ Update LWC Component X
├─ Update Apex Class B            ├─ Update LWC Component Y
└─ Deploy Classes                 └─ Deploy Components
         ↓                                  ↓
         └──────── MERGE POINT ────────────┘
                        ↓
                 Joint Testing
                        ↓
              Production Deployment

Coordination Points:
- Before start: Agree on interface/contract
- During work: Minimal coordination needed
- At merge: Verify integration
```

### Pattern C: Research → Review → Implement

```
Phase 1: Research
Cole's Agent
├─ Investigate CDC for Interview__c
├─ Test in ProdTest sandbox  
└─ Document findings in docs/CDC-IMPLEMENTATION.md
    ↓ HANDOFF (Request review)

Phase 2: Review & Planning
Patrick (Human)
├─ Review research doc
├─ Provide feedback/decisions
└─ Approve implementation plan
    ↓ HANDOFF (Approved for implementation)

Phase 3: Implementation
Patrick's Agent OR Cole's Agent (based on component)
├─ Enable CDC in Salesforce
├─ Update affected LWCs
└─ Test and deploy
```

---

## 📝 Agent Prompts Library

### Starting a New Task

```
Hi [Agent Name],

Please work on task #[ID] from SHARED_PLANNING.md.

Before starting:
1. Read the task details in SHARED_PLANNING.md
2. Check WORK_COORDINATION.md for any protected files
3. Review recent commits with: git log --oneline -10
4. Pull latest changes: git pull origin main

Context:
[Provide any specific context about recent work, decisions, or dependencies]

Ask me if you need clarification before proceeding.
```

### Requesting a Handoff

```
[Agent Name],

I need to hand off task #[ID] to [Other Agent/Person].

Please:
1. Create a handoff document using the template in WORK_COORDINATION.md
2. List all files you modified
3. Describe what's complete and what remains
4. Note any important decisions or gotchas
5. Update SHARED_PLANNING.md to reflect handoff status

Save the handoff as: docs/handoffs/HANDOFF-[TaskID]-[Date].md
```

### Checking for Conflicts

```
[Agent Name],

Before modifying [file names], please:
1. Check WORK_COORDINATION.md "Protected Files" section
2. Check SHARED_PLANNING.md "In Progress" table
3. Review recent commits for these files: git log --oneline -- [file path]
4. Let me know if there are any potential conflicts

If no conflicts, proceed with the changes.
```

### Coordinating Deployment

```
[Agent Name],

We need to deploy the changes from task #[ID].

Please:
1. Review all modified files with: git status
2. Verify tests pass: npm run test
3. Check for any deployment artifacts (CSV files, etc.) to exclude
4. Update .gitignore if needed
5. Create a deployment checklist

Target org: [ProductionCapstone / ProdTest]
Deployment order: [Specify if there's a specific order]
```

---

## 🛠️ Tools for Agent Coordination

### 1. Version Control Markers

Use comments in code to mark agent work:

```javascript
// AGENT: Cole's Copilot - 2026-01-08
// Added dark mode support - see SHARED_PLANNING.md task #042
connectedCallback() {
    this.subscribeToMessageChannel();
    // ... rest of code
}
```

### 2. Task References in Commits

```bash
git commit -m "Cole Agent: Implement dark mode in candidateKanban - Task #042"
```

### 3. Status Files

Create temporary status files for long-running work:

```bash
# .task-status/042-dark-mode.md
Task: #042 Dark Mode Implementation
Agent: Cole's Copilot
Status: 80% Complete
Last Update: 2026-01-08 14:30

Progress:
- [x] portalHeaderNew updated
- [x] candidateKanban updated
- [x] recentActivity updated
- [ ] candidateRecordView (in progress)
- [ ] Testing

Blockers: None
```

### 4. Agent Conversation Logs

For important decisions, save key parts of agent conversations:

```bash
# docs/agent-logs/2026-01-08-dark-mode-decision.md
Date: 2026-01-08
Agent: Cole's Copilot
Topic: Dark Mode Color Palette

Decision: Use consistent color palette across all components
Rationale: Easier maintenance, better UX consistency

Palette:
- Background: #16325c
- Text: #ffffff
- Borders: #3e5771

Approved by: Patrick Baker
See: .github/copilot-instructions-cole.md
```

---

## ⚡ Quick Reference Commands

### For Patrick's Agent
```bash
# See Patrick's instructions
cat .github/copilot-instructions.md | head -50

# Check recent Apex changes
git log --oneline force-app/main/default/classes/ -10

# Deploy Apex to production
sf project deploy start --source-dir "force-app/main/default/classes"
```

### For Cole's Agent
```bash
# See Cole's instructions
cat .github/copilot-instructions-cole.md | head -50

# Check recent LWC changes
git log --oneline force-app/main/default/lwc/ -10

# Deploy LWC to ProdTest
sf project deploy start --source-dir "force-app/main/default/lwc/COMPONENT" --target-org ProdTest
```

### For Both Agents
```bash
# Check active work
cat SHARED_PLANNING.md | grep "🔵"

# See protected files
cat WORK_COORDINATION.md | grep -A 20 "Protected Files"

# View recent handoffs
ls -lt docs/handoffs/ | head -5
```

---

## 🎓 Best Practices

### DO ✅

1. **Provide full context** when prompting agents
2. **Reference task numbers** from SHARED_PLANNING.md
3. **Check coordination files** before starting work
4. **Document handoffs** in structured format
5. **Test before handing off** to next agent
6. **Commit frequently** with clear messages
7. **Update status** in SHARED_PLANNING.md
8. **Ask for clarification** when unclear

### DON'T ❌

1. ❌ Assume agent has context from previous session
2. ❌ Skip checking protected files list
3. ❌ Hand off untested code
4. ❌ Forget to update planning documents
5. ❌ Modify files without checking status
6. ❌ Deploy without reviewing changes
7. ❌ Leave work in broken state
8. ❌ Skip documentation when handing off

---

## 🐛 Troubleshooting

### Issue: Agent modified unexpected files

**Solution:**
1. Check what was modified: `git status`
2. Review changes: `git diff [file]`
3. If incorrect, revert: `git checkout [file]`
4. Provide clearer constraints in next prompt
5. Update .gitignore if needed

### Issue: Conflicting changes between agents

**Solution:**
1. Stop both agents
2. Assess conflict scope
3. Decide priority
4. Communicate with other person
5. Coordinate merge or rollback
6. Update WORK_COORDINATION.md with resolution

### Issue: Agent seems confused about recent changes

**Solution:**
1. Provide recent commit SHAs to review
2. Show relevant file contents
3. Link to documentation
4. Consider starting fresh conversation with full context

### Issue: Handoff information incomplete

**Solution:**
1. Use the handoff template from WORK_COORDINATION.md
2. Ask agent to review and fill in missing details
3. Test the described state matches reality
4. Add additional context if needed

---

## 📚 Related Documentation

- [Work Coordination Guide](WORK_COORDINATION.md) - Main coordination protocols
- [Shared Planning](SHARED_PLANNING.md) - Active task board
- [Cole's Development Guide](COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Cole-specific info
- [Project README](README.md) - Project overview

---

## 🔄 Continuous Improvement

This guide should evolve based on what works and what doesn't.

**Feedback Process:**
1. Try the coordination patterns
2. Note what works well and what's difficult
3. Update this guide with improvements
4. Share learnings with the team

**Version History:**
- v1.0 (2026-01-08): Initial version - basic coordination patterns

---

**Last Updated:** 2026-01-08
**Maintained By:** Patrick Baker & Cole Arnold
