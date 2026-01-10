# Recruiter Portal Training - GitHub Pages Setup

This document explains how to enable GitHub Pages for the training portal and how to record and embed Loom videos.

---

## 📖 Table of Contents

1. [Enabling GitHub Pages](#enabling-github-pages)
2. [Recording Loom Videos](#recording-loom-videos)
3. [Embedding Loom Videos](#embedding-loom-videos)
4. [Updating Training Materials](#updating-training-materials)
5. [Sharing the Training Portal](#sharing-the-training-portal)

---

## 🌐 Enabling GitHub Pages

### Step 1: Access Repository Settings

1. Go to your GitHub repository: `https://github.com/pbmax4423capstone/RecruiterPortalProject`
2. Click the **Settings** tab (far right in the top navigation)
3. Scroll down the left sidebar and click **Pages** under "Code and automation"

### Step 2: Configure Source

1. Under "Build and deployment" section
2. **Source:** Select `Deploy from a branch`
3. **Branch:** Select `main` from the dropdown
4. **Folder:** Select `/docs` from the folder dropdown
5. Click **Save**

### Step 3: Wait for Deployment

- GitHub will automatically build and deploy your site
- This typically takes 1-2 minutes
- You'll see a green checkmark and URL when ready

### Step 4: Access Your Training Portal

Once deployed, your training portal will be available at:

```
https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html
```

**Important:** The path includes `training-portal.html` because that's your home page. Bookmark this URL for easy access.

### Optional: Set Custom URL as Home Page

If you want the training portal to load when visiting the base URL, rename the file:

```bash
cd docs
mv training-portal.html index.html
```

Then the portal will be accessible at:

```
https://pbmax4423capstone.github.io/RecruiterPortalProject/
```

---

## 🎥 Recording Loom Videos

You have three Loom video scripts ready to record in the `docs/loom-scripts/` folder:

1. `01-creating-a-candidate.md` (3-4 minutes)
2. `02-scheduling-interviews.md` (4-5 minutes)
3. `03-sales-manager-dashboard.md` (5-6 minutes)

### Prerequisites

- Loom account (free or paid)
- Access to your Salesforce Recruiter Portal org
- Test data in the org (candidates, interviews, dashboard metrics)

### Recording Steps

1. **Open Loom:**
   - Go to `https://www.loom.com/`
   - Sign in to your account
   - Click "New Video" button

2. **Configure Recording:**
   - Select **"Screen + Camera"** or **"Screen Only"** (your choice)
   - Choose **"Full Desktop"** or **"Browser Tab"** (recommend Browser Tab for cleaner view)
   - Click **"Start Recording"**

3. **Follow the Script:**
   - Open the script file for the video you're recording (e.g., `01-creating-a-candidate.md`)
   - Follow the voiceover text and action steps exactly
   - Pause and redo sections if needed (you can trim later)
   - Speak clearly and at a moderate pace

4. **Complete Recording:**
   - Click the Loom extension icon or press the stop hotkey
   - Loom will automatically process and upload your video
   - You'll be taken to the video page

5. **Edit & Trim (Optional):**
   - Click **"Edit Video"** button
   - Trim beginning/end if needed
   - Add chapters using the timestamps in the script
   - Add a custom thumbnail (optional)

6. **Set Video Title & Description:**
   - Use the exact title from the script (e.g., "How to Create a Candidate in the Recruiter Portal")
   - Copy the chapter timestamps from the script into the description
   - Set visibility to **"Anyone with the link"** (for public sharing)

7. **Copy Share Link:**
   - Click the **"Share"** button
   - Copy the **"Share link"** (e.g., `https://www.loom.com/share/abc123...`)
   - Save this link—you'll need it for embedding

---

## 🔗 Embedding Loom Videos

After recording your videos, you need to embed them in the training portal.

### Step 1: Get Embed Code from Loom

1. Open your Loom video
2. Click the **"Share"** button
3. Click the **"Embed"** tab
4. Copy the `<iframe>` code (it will look like this):

```html
<iframe
  src="https://www.loom.com/embed/abc123xyz"
  frameborder="0"
  webkitallowfullscreen
  mozallowfullscreen
  allowfullscreen
  style="width: 100%; height: 400px;"
>
</iframe>
```

### Step 2: Update training-portal.html

1. Open `docs/training-portal.html` in your code editor
2. Find the placeholder for the corresponding video:

**For Video 1 (Creating a Candidate):**

```html
<!-- REPLACE THIS PLACEHOLDER -->
<div class="video-placeholder">
  📹 Video will be added here<br />
  <small
    >Record using Loom script: loom-scripts/01-creating-a-candidate.md</small
  >
</div>

<!-- WITH YOUR LOOM EMBED CODE -->
<iframe
  src="https://www.loom.com/embed/YOUR_VIDEO_ID"
  frameborder="0"
  webkitallowfullscreen
  mozallowfullscreen
  allowfullscreen
  style="width: 100%; height: 400px; border-radius: 8px;"
>
</iframe>
```

3. Repeat for Videos 2 and 3
4. Save the file

### Step 3: Commit & Push Changes

```bash
git add docs/training-portal.html
git commit -m "Add Loom video embeds to training portal"
git push origin main
```

GitHub Pages will automatically rebuild (takes 1-2 minutes). Refresh your training portal URL to see the videos.

---

## 📝 Updating Training Materials

### Adding New Documentation

1. Create new `.md` or `.html` files in the `docs/` folder
2. Link to them from `training-portal.html`
3. Commit and push:
   ```bash
   git add docs/
   git commit -m "Add new training documentation"
   git push origin main
   ```

### Updating Existing Files

1. Edit the files in the `docs/` folder
2. Commit and push changes
3. GitHub Pages will automatically rebuild

### Testing Locally

You can test the HTML files locally before pushing:

```bash
cd docs
# Open training-portal.html in your browser
start training-portal.html  # Windows
open training-portal.html   # Mac
```

---

## 🔗 Sharing the Training Portal

### Option 1: Direct Link (Default)

Share this URL with your team:

```
https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html
```

### Option 2: Short URL (Recommended)

Use a URL shortener like:

- **Bitly:** `https://bitly.com/` → Create short link like `https://bit.ly/capstone-training`
- **TinyURL:** `https://tinyurl.com/` → Create short link like `https://tinyurl.com/capstone-training`

### Option 3: QR Code

Generate a QR code pointing to your training portal:

1. Go to `https://www.qr-code-generator.com/`
2. Paste your training portal URL
3. Download QR code image
4. Print on handouts or display at training sessions

### Option 4: Email Template

Use this email template to announce the training:

```
Subject: 🎓 New Recruiter Portal Training Available Online

Hi Team,

We've created a comprehensive online training portal for the Recruiter Portal system.

Access the training here: https://pbmax4423capstone.github.io/RecruiterPortalProject/training-portal.html

The portal includes:
✅ Video walkthroughs (35 minutes total)
✅ Interactive step-by-step guides
✅ Downloadable reference materials
✅ Role-specific learning paths

Complete the "Quick Start" track (all 3 videos) to get up to speed in under an hour.

Questions? Contact [Your Name] or the Help Desk.

Thanks!
```

---

## 📊 Tracking Training Completion

To track who has completed training, you can:

1. **Manual Tracking:** Create a spreadsheet with team member names and completion checkboxes
2. **Loom Analytics:** Loom Pro accounts show video view counts and viewer emails
3. **Google Form:** Create a completion survey linked at the end of each module
4. **Salesforce Custom Object:** Create a "Training Completion" object to track in Salesforce

---

## 🛠️ Troubleshooting

### Videos Not Loading

- **Check embed code:** Ensure `<iframe>` src URL is correct
- **Check Loom privacy:** Video must be set to "Anyone with the link"
- **Clear browser cache:** Hard refresh with Ctrl+F5 (Windows) or Cmd+Shift+R (Mac)

### GitHub Pages Not Updating

- **Wait 2-3 minutes:** Deployment takes time
- **Check Actions tab:** Go to `https://github.com/pbmax4423capstone/RecruiterPortalProject/actions` to see build status
- **Verify branch:** Ensure you pushed to `main` branch
- **Check file paths:** All links must use relative paths (no `C:\` or `file://`)

### Broken Links

- **Use relative paths:** `training-portal.html` not `../training-portal.html` when in same folder
- **Case sensitive:** GitHub Pages URLs are case-sensitive (use lowercase)
- **Test locally first:** Open HTML files in browser before pushing

---

## 📅 Maintenance Schedule

### Weekly

- Review Loom video analytics to see completion rates
- Check for broken links or outdated content

### Monthly

- Update training materials based on system changes
- Re-record videos if major UI changes occur
- Solicit feedback from new users

### Quarterly

- Review all documentation for accuracy
- Update screenshots and examples
- Add new modules for new features

---

## 📞 Support

If you encounter issues with:

- **GitHub Pages setup:** Contact GitHub Support or post in GitHub Community
- **Loom recording:** Visit Loom Help Center: `https://support.loom.com/`
- **Training content:** Contact Recruiting Operations team

---

## ✅ Final Checklist

Before launching the training portal publicly:

- [ ] GitHub Pages is enabled and URL is accessible
- [ ] All 3 Loom videos are recorded and embedded
- [ ] All links work (click through every link to test)
- [ ] Videos play correctly (test in Chrome, Edge, and mobile)
- [ ] Download links for PDFs work
- [ ] Training portal is visually appealing (no broken layouts)
- [ ] Contact/support information is accurate
- [ ] Team has been notified with training portal URL
- [ ] Completion tracking method is in place

---

**Last Updated:** January 7, 2026  
**Maintained By:** Recruiting Operations  
**Questions?** Contact help@capstonetechsupport.com
