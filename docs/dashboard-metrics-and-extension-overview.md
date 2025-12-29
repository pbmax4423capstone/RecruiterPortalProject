# Dashboard Metrics + Extension Enhancements Overview

**Last Updated:** December 29, 2025  
**Authors:** Patrick Baker & Cole Arnold  
**Scope:** Recruiter dashboard metrics refresh + Chrome/Edge LinkedIn import extensions

---

## 1. Snapshot
- **Objective:** Align the recruiter dashboard with the completed-interview metrics while keeping the LinkedIn extensions fully in sync across Chrome and Edge.
- **Status:** ✅ Development complete · ⏳ Pending ProdTest deployment
- **Primary Consumers:** Recruiters, Service Team, Cole Arnold, Chrome/Edge extension power users

---

## 2. Dashboard Metrics Enhancements
### 2.1 Key Metrics
| Metric | Source | Notes |
| --- | --- | --- |
| Completed Interviews (MTD/YTD) | `InterviewLeaderboardNewController.getCompletedInterviewCounts` | Filters strictly on `Status = Completed` and `Completed_Date__c` within target window. |
| Pipeline Velocity | `InterviewLeaderboardNewController.getPipelineVelocity` | Uses normalized stage durations to highlight bottlenecks. |
| Recruiter Leaderboard | `InterviewLeaderboardNewController.getRecruiterLeaderboard` | Aggregates completed interviews per recruiter with rank + delta. |
| Candidate Conversion | `InterviewLeaderboardNewController.getConversionStats` | Compares Stage N vs Stage N+1 completions. |
| Alerts | `InterviewLeaderboardNewController.getExceptionFlags` | Flags stale candidates or missing follow-ups.

### 2.2 Experience Cloud Placement
- `candidateRecordView` stays embedded on **Candidate Record Page** flexipage.
- Metrics tiles surface in **Recruiter Dashboard** Lightning App via updated `interviewLeaderboard` bundle.
- Auto-refresh + CDC subscriptions remain intact for real-time updates.

### 2.3 Deployment + Validation
1. `sf project deploy start --source-dir force-app/main/default/lwc/interviewLeaderboard --target-org <ORG>`
2. Validate Apex: `SummaryCardMetricsControllerTest`, `InterviewLeaderboardNewControllerTest` (if updated).
3. Open Recruiter Dashboard app page → confirm metrics load without console errors.
4. Switch users (Recruiter/Service) to verify FLS and record visibility.

### 2.4 Training Tips
- Use this guide’s URL in the Training Center (same pattern as other docs).
- Demo scenario: Update an interview to `Completed`, note live refresh in dashboard.
- Remind users the metrics track **completed** milestones only; open interviews will not display.

---

## 3. Chrome & Edge LinkedIn Extensions
### 3.1 Feature Parity Checklist
| Area | Chrome | Edge | Notes |
| --- | --- | --- | --- |
| OAuth Client | ✅ | ✅ | Shared Connected App (`LinkedIn_Import_Extension`) with dual callback URLs. |
| Guarded Content Script | ✅ | ✅ | IIFE + `window.__linkedinToSalesforceLoaded` check prevents duplicate injections. |
| Candidate Creation Flow | ✅ | ✅ | Contact first, Candidate second (Type__c = Candidate). |
| Call Result Tracking | ✅ | ✅ | scheduledCallsModal updates tracked checkboxes + final result state. |
| Error Surfacing | ✅ | ✅ | Toast-style popup messaging mirrored across browsers.

### 3.2 Operational Notes
- Keep `CONFIG.testRecruiterId` consistent in both `popup.js` files when rotating test accounts.
- Background script logs are accessible via each browser’s extension page → Inspect views.
- If LinkedIn changes DOM structure, update selectors in both copies simultaneously.

### 3.3 QA Script (Condensed)
1. Authenticate via extension popup.
2. Import a candidate from LinkedIn (creates Contact + Candidate records).
3. Set call result via scheduled call modal; confirm checkbox sync.
4. Refresh recruiter dashboard to ensure candidate appears in completed metrics once interviews close.

---

## 4. Reference Artifacts
- Apex: `force-app/main/default/classes/InterviewLeaderboardNewController.cls`
- LWC: `force-app/main/default/lwc/interviewLeaderboard/*`
- Modal Enhancements: `force-app/main/default/lwc/scheduledCallsModal/*`
- Extensions: `chrome-extension-linkedin/*`, `edge-extension-linkedin/*`

---

## 5. Sharing the Guide
Once committed to `main`, share the GitHub link:  
`https://github.com/pbmax4423capstone/RecruiterPortalProject/blob/main/docs/dashboard-metrics-and-extension-overview.md`

Add to the Training Center landing page or send directly to stakeholders who need the refresh summary.
