# Cole Arnold Reference: Dashboard Metrics + Extensions

**Date:** December 29, 2025  
**Audience:** Cole Arnold  
**Purpose:** Explain the latest recruiter dashboard + LinkedIn extension updates and the reasoning behind them.

---

## 1. Why We Touched This
- **Data Integrity:** Leadership requested that all dashboard KPIs align with *completed* interviews only. Prior queries mixed in scheduled/ongoing interviews, which inflated counts.
- **Recruiter Flow:** Service and recruiter teams needed a single source of truth (Candidate Record Page) that refreshes automatically when interviews close.
- **Extension Reliability:** Chrome and Edge users were on slightly different code levels. We synced both bundles so testers can reproduce issues consistently.

---

## 2. What Changed (Technical)
### Dashboard & Apex
1. **`InterviewLeaderboardNewController`** now scopes every helper method to the `Status = Completed` + `Completed_Date__c` window.
2. **`candidateRecordView` Flexipage Placement** stays locked so refreshed metrics surface without extra navigation.
3. **Metadata Alignments**
   - Highest Level picklist includes Align/CI/Plan/Present options so dashboards filter the same values the flows now use.
   - Contract Type list view + record type updates keep the recruiter UI in sync with Contract B reporting.

### Lightning Web Components
- `interviewLeaderboard` bundle cleaned up merge markers and logging noise; retains tiles + leaderboard UI.
- `scheduledCallsModal` now tracks call-result checkboxes + final result in a single data structure and keeps UI texts identical across experiences.

### Browser Extensions
- Ensured both `chrome-extension-linkedin` and `edge-extension-linkedin` share identical content/popup/background scripts.
- Verified OAuth configuration continues to reference the shared Connected App with both callback URLs.
- Documented the candidate creation order (Contact -> Candidate__c) and kept guard IIFE wrapper intact.

---

## 3. How to Explain This to Stakeholders
| Audience | Message | Call to Action |
| --- | --- | --- |
| Recruiters | Dashboard now shows **only** finished interviews so numbers match reality. | Continue closing interviews promptly; expect real-time updates. |
| Service Team | Extensions share the same behavior in Chrome/Edge, so support steps are identical. | Use this doc + dashboard overview guide when training new staff. |
| Leadership | Metrics + metadata align across reports, dashboards, and flows. | Reference the GitHub doc link in QBR decks. |

---

## 4. Follow-Up Items for Cole
1. **ProdTest Deployment:** Run `sf project deploy start --source-dir force-app/main/default/lwc/interviewLeaderboard --target-org patrickbakeradmin2@financialguide.com.prodtest` plus related Apex metadata once the branch is green.
2. **Extension Smoke Test:** Install both local extensions, import a sample candidate, and confirm scheduled call modal writes expected fields.
3. **Training Center Hook:** Add the public link to `dashboard-metrics-and-extension-overview.md` inside `training-center.html` so the content shows up with the other guides.

Ping Patrick if business rules change again so we can keep both Copilot instruction sets aligned.
