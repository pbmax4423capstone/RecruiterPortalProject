# 🚀 Quick Start: Launching Your Training Portal

This is your action checklist to get the training portal live and distribute it to your team.

---

## ✅ Step 1: Enable GitHub Pages (5 minutes)

1. Go to: `https://github.com/pbmax4423capstone/RecruiterPortalProject`
2. Click **Settings** tab (top right)
3. Click **Pages** (left sidebar under "Code and automation")
4. Under "Build and deployment":
   - Source: `Deploy from a branch`
   - Branch: `main`
   - Folder: `/docs`
5. Click **Save**
6. Wait 2 minutes, then refresh the page
7. You'll see: **"Your site is live at `https://pbmax4423capstone.github.io/RecruiterPortalProject/`"**

**Your Training Portal URL:**
```
https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html
```

✅ Test it by clicking the URL above. You should see the training portal home page.

---

## 🎥 Step 2: Record Loom Videos (30-40 minutes)

You have 3 videos to record. Each script is in `docs/loom-scripts/` folder.

### Video 1: Creating a Candidate (3-4 min)
- **Script:** [docs/loom-scripts/01-creating-a-candidate.md](loom-scripts/01-creating-a-candidate.md)
- **What to show:** Dashboard → Click "Create New Candidate" → Fill form with all 6 fields → Submit
- **Key points:** Required vs optional fields, duplicate check, Position/Lead Source dropdowns

### Video 2: Scheduling Interviews (4-5 min)
- **Script:** [docs/loom-scripts/02-scheduling-interviews.md](loom-scripts/02-scheduling-interviews.md)
- **What to show:** Dashboard → Click "Schedule Interview" → Select candidate → Choose interview type → Set date → Submit → Mark complete
- **Key points:** 5 interview types, single date system, completion workflow

### Video 3: Sales Manager Dashboard (5-6 min)
- **Script:** [docs/loom-scripts/03-sales-manager-dashboard.md](loom-scripts/03-sales-manager-dashboard.md)
- **What to show:** All dashboard sections, clickable metrics, Current Month/YTD toggle, call management, Contract B pipeline
- **Key points:** Metric meanings, interactive features, priority actions

### Recording Tips:
- Log into your Salesforce org with real data
- Use "Browser Tab" recording mode for cleaner view
- Speak clearly and at moderate pace
- Follow the voiceover script exactly (it has timestamps)
- Set video privacy to "Anyone with the link"
- Add the chapter timestamps from the script to video description

---

## 🔗 Step 3: Embed Videos (10 minutes)

After recording each video:

1. Open the video in Loom
2. Click **Share** → **Embed** tab
3. Copy the `<iframe>` code
4. Open `docs/training-portal.html` in VS Code
5. Find the video placeholder (search for "Video will be added here")
6. Replace the placeholder with your `<iframe>` code
7. Repeat for all 3 videos
8. Save the file

```bash
# Commit and push changes
git add docs/training-portal.html
git commit -m "Add Loom video embeds to training portal"
git push origin main
```

Wait 2 minutes for GitHub Pages to rebuild, then refresh your portal URL.

---

## 📧 Step 4: Distribute to Team (5 minutes)

### Option A: Email (Copy/Paste This)

```
Subject: 🎓 New Recruiter Portal Training - Complete in 35 Minutes

Hi Team,

We've created a comprehensive online training portal for the updated Recruiter Portal system.

🔗 Access Training Portal:
https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html

📚 What's Included:
✅ 3 video walkthroughs (12 minutes total)
✅ Interactive step-by-step guides
✅ Downloadable quick reference materials
✅ Role-specific learning paths

⏱️ Time Commitment:
• Quick Start (all 3 videos): 35 minutes
• Full training with guides: 1 hour

🎯 Action Required:
Please complete the "Quick Start" track by [INSERT DEADLINE].

Questions? Reply to this email or contact help@capstonetechsupport.com

Thanks!
[Your Name]
```

### Option B: Short URL (Recommended)

1. Go to `https://bitly.com` (or `https://tinyurl.com`)
2. Paste your training portal URL
3. Create short link like: `https://bit.ly/capstone-training`
4. Share the short link (easier to remember)

### Option C: Slack/Teams Message

```
🎓 New Training Available: Recruiter Portal Updates

Complete the training in under an hour:
https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html

Includes videos, guides, and quick references for:
• Creating candidates
• Scheduling interviews  
• Understanding the dashboard

Questions? DM me or contact Help Desk.
```

---

## 📊 Step 5: Track Completion (Optional)

### Method 1: Loom Analytics
- If you have Loom Pro, view analytics to see who watched videos
- Go to each video → Analytics tab

### Method 2: Google Form
- Create a form: "Training Completion Survey"
- Ask: Name, Date Completed, Feedback
- Share form link at end of training

### Method 3: Spreadsheet
- Create Excel/Google Sheet with team names
- Check off as people confirm completion
- Send reminders to incomplete users

---

## 🛠️ Troubleshooting

### "GitHub Pages URL doesn't work"
- Wait 2-3 minutes after enabling Pages
- Check that you selected `/docs` folder (not root)
- Verify you're on `main` branch

### "Videos won't embed"
- Check Loom video privacy is "Anyone with the link" (not "Private")
- Verify `<iframe>` src URL is correct
- Clear browser cache (Ctrl+F5)

### "Links are broken"
- All links use relative paths (they should work automatically)
- Test by clicking every link in the portal

---

## ✅ Launch Checklist

Before announcing to team:

- [ ] GitHub Pages is live and URL loads
- [ ] All 3 videos are recorded
- [ ] Videos are embedded in training portal
- [ ] Test: Click every link to verify they work
- [ ] Test: Watch each video to ensure they play
- [ ] Test: Open portal on mobile device
- [ ] Prepare short URL (optional)
- [ ] Draft announcement email/message
- [ ] Set completion deadline (if needed)
- [ ] Set up tracking method (if needed)

---

## 📞 Need Help?

**Full Documentation:** [docs/GITHUB_PAGES_SETUP.md](GITHUB_PAGES_SETUP.md) (detailed instructions)

**Training Summary:** [docs/TRAINING_IMPLEMENTATION_SUMMARY.md](TRAINING_IMPLEMENTATION_SUMMARY.md) (complete overview)

**Support:** help@capstonetechsupport.com

---

## 🎉 You're Ready!

Your training portal is complete and ready to launch. Just follow the 5 steps above:

1. Enable GitHub Pages (5 min) ✅ 
2. Record videos (30-40 min)
3. Embed videos (10 min)
4. Distribute to team (5 min)
5. Track completion (optional)

**Total Time:** ~1 hour to go from setup to launch

Good luck! 🚀
