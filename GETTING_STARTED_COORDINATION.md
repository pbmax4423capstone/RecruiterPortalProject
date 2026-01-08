# 🚀 Getting Started with Collaborative Planning

## Welcome!

This guide will get you started with the collaborative planning and coordination system in **under 5 minutes**.

---

## ⚡ Quick Start (3 Steps)

### Step 1: Bookmark These Files

Open and bookmark these three files in your browser:

1. **[QUICK_COORDINATION.md](QUICK_COORDINATION.md)** - Your daily reference
2. **[SHARED_PLANNING.md](SHARED_PLANNING.md)** - Task board for tracking work
3. **[WORK_COORDINATION.md](WORK_COORDINATION.md)** - When you need protocols/templates

### Step 2: Add to Your Daily Workflow

**Before starting any work, run these three commands:**

```bash
# Check what's in progress
cat SHARED_PLANNING.md | grep "🔵 In Progress"

# Check protected files
cat WORK_COORDINATION.md | grep -A 30 "Protected Files"

# Pull latest changes
git pull origin main
```

### Step 3: Your First Task

1. Open **SHARED_PLANNING.md**
2. Find your task in "🟡 Ready to Start" section (or add a new one)
3. Move it to "🔵 In Progress" and add your name
4. Work on it
5. Commit: `git commit -m "YourName: Description - Task #XXX"`
6. Move to "🟢 Completed" when done

**That's it!** You're coordinating effectively now.

---

## 📚 When You Need More

### I'm using a Copilot agent...
→ See **[AGENT_COORDINATION.md](AGENT_COORDINATION.md)** for prompts and patterns

### I need to hand off work to someone...
→ See **[WORK_COORDINATION.md](WORK_COORDINATION.md)** for handoff template

### I want to understand the full system...
→ See **[COLLABORATION_SYSTEM_SUMMARY.md](COLLABORATION_SYSTEM_SUMMARY.md)** for complete overview

### I want visual diagrams...
→ See **[COLLABORATION_VISUAL_GUIDE.md](COLLABORATION_VISUAL_GUIDE.md)** for workflows

---

## 🎯 Common Scenarios

### Scenario: "I want to modify candidateRecordView.js"

```bash
# 1. Check if it's protected
grep "candidateRecordView" WORK_COORDINATION.md
# Result: Yes, it's in the protected files list

# 2. Check if anyone is working on it
grep "candidateRecordView" SHARED_PLANNING.md
# Result: No active work

# 3. Coordinate with Cole (since it's an LWC)
# Message: "Hey Cole, planning to update candidateRecordView for dark mode. OK?"

# 4. After confirmation, add to SHARED_PLANNING.md
# Task: "Add dark mode to candidateRecordView - Patrick - 🔵 In Progress"

# 5. Work on it, commit, mark complete
```

### Scenario: "Cole's agent finished work, I need to deploy it"

```bash
# 1. Check for handoff document
ls docs/handoffs/ | grep "Cole-to-Patrick"

# 2. Read the handoff document
cat docs/handoffs/HANDOFF-042-2026-01-08-Cole-to-Patrick.md

# 3. Follow deployment instructions in handoff doc

# 4. Update SHARED_PLANNING.md
# Change status from "Ready for Deployment" to "🟢 Completed"
```

### Scenario: "I want my agent to research something"

```bash
# 1. Create task in SHARED_PLANNING.md
# Task #050: Research CDC for Interview object - Cole's Agent - 🔵 In Progress

# 2. Prompt your agent (see AGENT_COORDINATION.md for template):
```
Cole's Agent,

Before starting, check:
1. SHARED_PLANNING.md for active work
2. WORK_COORDINATION.md for protected files

Task #050: Research CDC for Interview object

Objective: Investigate Change Data Capture implementation

Deliverable: 
- Create docs/CDC-RESEARCH.md with findings
- Include code examples
- List limitations

Research Questions:
- How to enable CDC on custom object?
- What's the event channel format?
- Performance implications?
```

# 3. Review agent's research output

# 4. Update SHARED_PLANNING.md to "🟢 Completed"
```

---

## 💡 Pro Tips

### Tip 1: Use Aliases
Add to your `.bashrc` or `.zshrc`:

```bash
alias coord-check='cat SHARED_PLANNING.md | grep "🔵"'
alias coord-protected='cat WORK_COORDINATION.md | grep -A 30 "Protected"'
alias coord-pull='git pull origin main && coord-check'
```

### Tip 2: Create Task Templates
Save common task templates in your notes:

```markdown
### Task XXX: [Name]
**Owner:** [Your Name]
**Priority:** [High/Medium/Low]
**Started:** [Date]

#### Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

#### Files to Modify
- File 1
- File 2
```

### Tip 3: Set Reminders
- **Morning:** Check SHARED_PLANNING.md for updates
- **Before work:** Run coordination check commands
- **End of day:** Update task status

---

## 🆘 Help & Support

### "I'm stuck and don't know what to do"

1. Check the **QUICK_COORDINATION.md** FAQ section
2. Search the coordination docs for your scenario
3. Ask the other person (Patrick or Cole)
4. Add a note to SHARED_PLANNING.md with 🔴 Blocked status

### "I made a mistake in the task board"

No problem! Just edit SHARED_PLANNING.md and commit:
```bash
git add SHARED_PLANNING.md
git commit -m "Fix task status for #XXX"
git push origin main
```

### "Someone is working on the same file"

1. Check SHARED_PLANNING.md to see who
2. Message them directly
3. Coordinate approach (parallel or sequential)
4. Document decision in SHARED_PLANNING.md

---

## ✅ Success Checklist

After your first week, you should be able to:

- [ ] Check SHARED_PLANNING.md before starting work
- [ ] Add and update tasks with status emojis
- [ ] Identify protected files
- [ ] Commit with task IDs
- [ ] Create a basic handoff document (if needed)
- [ ] Prompt a Copilot agent with proper context

---

## 📖 Full Documentation Index

| Document | Size | Purpose | Read When |
|----------|------|---------|-----------|
| [QUICK_COORDINATION.md](QUICK_COORDINATION.md) | 3.8 KB | Fast daily reference | Every day |
| [SHARED_PLANNING.md](SHARED_PLANNING.md) | 7.8 KB | Task board | Multiple times daily |
| [WORK_COORDINATION.md](WORK_COORDINATION.md) | 8.6 KB | Protocols & templates | As needed |
| [AGENT_COORDINATION.md](AGENT_COORDINATION.md) | 13 KB | Agent patterns | When using agents |
| [COLLABORATION_SYSTEM_SUMMARY.md](COLLABORATION_SYSTEM_SUMMARY.md) | 12 KB | Complete overview | First time, occasional review |
| [COLLABORATION_VISUAL_GUIDE.md](COLLABORATION_VISUAL_GUIDE.md) | 16 KB | Visual diagrams | When you want visuals |

---

## 🎉 You're Ready!

You now have everything you need to coordinate effectively with Patrick/Cole and your Copilot agents.

**Remember the three daily commands:**
```bash
cat SHARED_PLANNING.md | grep "🔵 In Progress"
cat WORK_COORDINATION.md | grep -A 30 "Protected Files"
git pull origin main
```

**Happy coordinating!** 🚀

---

**Questions?** Check QUICK_COORDINATION.md or ask your teammate!

**Last Updated:** 2026-01-08
