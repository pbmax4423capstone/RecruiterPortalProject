# Quick Coordination Reference

## 🚀 Starting New Work

```bash
# 1. Check for conflicts
cat SHARED_PLANNING.md | grep "🔵 In Progress"
cat WORK_COORDINATION.md | grep -A 30 "Protected Files"

# 2. Pull latest
git pull origin main

# 3. Add your task to SHARED_PLANNING.md
# Mark as 🔵 In Progress with your name

# 4. Start work
```

## 📝 Essential Files

| File | Purpose | When to Use |
|------|---------|-------------|
| [WORK_COORDINATION.md](WORK_COORDINATION.md) | Protocols, patterns, protected files | Before starting any work |
| [SHARED_PLANNING.md](SHARED_PLANNING.md) | Active task board | To check status, add tasks |
| [AGENT_COORDINATION.md](AGENT_COORDINATION.md) | Agent-specific guidance | When using Copilot agents |

## 🤖 Agent Quick Start

### Tell Patrick's Agent:
```
Before starting, please:
1. Check WORK_COORDINATION.md for protected files
2. Check SHARED_PLANNING.md for active work on similar components
3. Review recent commits: git log --oneline -10

Then proceed with [task description].
```

### Tell Cole's Agent:
```
Before starting, please:
1. Check WORK_COORDINATION.md for protected files
2. Check SHARED_PLANNING.md for active work on similar components
3. Review recent commits: git log --oneline -10

Then proceed with [task description].
```

## 🔄 Handoff Template (Quick)

```markdown
## Handoff: [Task Name]
**From:** [You/Your Agent]
**To:** [Other Person/Agent]

### Completed
- [List what's done]

### Next Steps
- [What needs to happen next]

### Files Changed
- [List files]

### Notes
- [Important info, gotchas, decisions]
```

## 🎯 Common Scenarios

### Scenario 1: I want to modify a file

```bash
# Check if it's protected
grep -r "filename" WORK_COORDINATION.md

# Check if someone's working on it
grep -r "filename" SHARED_PLANNING.md

# If clear, proceed. If not, coordinate first.
```

### Scenario 2: Handing off to the other person

```bash
# 1. Commit your work
git add .
git commit -m "Your Name: Description - Task #XXX"
git push origin main

# 2. Create handoff doc in WORK_COORDINATION.md or as separate file

# 3. Update SHARED_PLANNING.md
# Change task owner and status

# 4. Notify via Slack/message
```

### Scenario 3: Both working on related but different files

```bash
# 1. Coordinate on interfaces/contracts first
# 2. Add both to SHARED_PLANNING.md with parallel status
# 3. Work independently
# 4. Test integration before both commit
# 5. Deploy in agreed order
```

## ⚠️ Protected Files (Always Coordinate)

**LWC Components:**
- candidateRecordView
- recruiterDashboard  
- contractBPipelineDashboard
- portalHeaderNew

**Email Templates:**
- All in force-app/main/default/email/Candidate_Outreach/

**Extensions:**
- chrome-extension-linkedin/
- edge-extension-linkedin/

See [WORK_COORDINATION.md](WORK_COORDINATION.md) for complete list.

## 📊 Status Emojis

- 🔵 In Progress
- 🟡 Ready to Start
- 🔴 Blocked
- 🟢 Completed
- ⚠️ Needs Review

## 🔗 Quick Links

- [WORK_COORDINATION.md](WORK_COORDINATION.md) - Full coordination guide
- [SHARED_PLANNING.md](SHARED_PLANNING.md) - Task board
- [AGENT_COORDINATION.md](AGENT_COORDINATION.md) - Agent patterns
- [COLE_ARNOLD_DEVELOPMENT_GUIDE.md](COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Cole's guide
- [README.md](README.md) - Project overview

## 💬 Communication Templates

**Starting work:**
```
🚀 Starting Task #XXX: [Name]
Owner: [Your Name]
Files: [List]
ETA: [Time]
```

**Handoff:**
```
🤝 Handoff Ready: Task #XXX
From: [You]
To: [Other Person]
Status: [What's done]
See [Doc link] for details
```

**Completed:**
```
✅ Completed Task #XXX
Changes: [Summary]
Deployed: [Yes/No, which org]
```

**Blocked:**
```
🔴 Blocked: Task #XXX
Blocker: [Issue]
Need: [What you need to unblock]
```

---

**Last Updated:** 2026-01-08
