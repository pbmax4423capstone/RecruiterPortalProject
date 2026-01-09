# Notes Component Fix - Multi-Agent Plan

**Date:** 2026-01-09
**Issue:** candidateNotesRelatedList and candidateLegacyNotes components not loading properly in Production
**Priority:** HIGH
**Target Completion:** Same day

---

## 🎯 Problem Statement

After multiple deployment attempts, both Notes components continue to exhibit issues:

1. **candidateNotesRelatedList** - Shows "Error loading notes" message
2. **candidateLegacyNotes** - Displays empty component box (blank space)

**Previous Fixes Attempted:**
- Fixed parameter name mismatch (candidateId → recordId)
- Added null checks and safe wire adapter access
- Added empty state display for Legacy Notes
- Deployed multiple times with various fixes

**Root Cause Hypothesis:**
The issue persists despite fixes, suggesting:
- Possible caching issues in Production
- Apex controller (CandidateNotesController) may not be deployed or has errors
- Component metadata or permissions issues
- Data access or sharing rule problems

---

## 👥 Agent Team Structure

### Agent 1: Research & Diagnostics Agent
**Specialization:** System investigation, log analysis, component auditing
**Responsibilities:**
- Verify CandidateNotesController exists in Production
- Check Apex class test coverage and deployment status
- Review component metadata and permissions
- Analyze browser console errors
- Document exact error messages and stack traces

### Agent 2: Apex Development Agent
**Specialization:** Apex controller development, SOQL, testing
**Responsibilities:**
- Review and fix CandidateNotesController if needed
- Ensure proper error handling and logging
- Update test coverage to 100%
- Verify data access and sharing rules
- Test Apex methods directly via Developer Console

### Agent 3: LWC Development Agent
**Specialization:** Lightning Web Components, JavaScript, wire adapters
**Responsibilities:**
- Review and fix LWC component logic
- Ensure proper wire adapter configuration
- Add comprehensive error logging
- Verify component metadata and API version
- Test components in sandbox first

### Agent 4: Deployment & Validation Agent
**Specialization:** Salesforce CLI, deployment validation, testing
**Responsibilities:**
- Execute deployment sequence in correct order
- Validate deployment success
- Run all tests and verify coverage
- Clear org caches if needed
- Verify components work in Production

---

## 📋 Multi-Phase Execution Plan

### Phase 1: Deep Diagnostics & Research (Agent 1)
**Estimated Time:** 15-20 minutes

**Tasks:**
1. ✅ Verify CandidateNotesController exists in Production org
   - Query: `sf data query --query "SELECT Id, Name, ApiVersion, Status FROM ApexClass WHERE Name = 'CandidateNotesController'" --target-org ProductionCapstone`

2. ✅ Check test class deployment status
   - Query: `sf data query --query "SELECT Id, Name FROM ApexClass WHERE Name = 'CandidateNotesController_Test'" --target-org ProductionCapstone`

3. ✅ Verify component deployment status
   - List components: `sf project retrieve start --source-dir "force-app\main\default\lwc\candidateNotesRelatedList" --target-org ProductionCapstone`

4. ✅ Check for browser console errors
   - Document exact error messages
   - Capture stack traces
   - Note any 404 or Apex errors

5. ✅ Test Apex controller directly in Developer Console
   - Execute: `Id candidateId = [SELECT Id FROM Candidate__c LIMIT 1].Id;`
   - Execute: `List<CandidateNotesController.NoteWrapper> notes = CandidateNotesController.getNotes(candidateId);`
   - Verify it returns without errors

6. ✅ Check component metadata
   - Verify .js-meta.xml files have correct API version
   - Check for any isExposed or target misconfigurations

**Deliverable:** 
- Diagnostic report with exact error messages and system state
- Root cause hypothesis based on findings
- Recommendations for fix approach

**Handoff To:** Agent 2 (Apex) OR Agent 3 (LWC) based on findings

---

### Phase 2A: Apex Controller Fix (Agent 2) - IF APEX ISSUE FOUND
**Estimated Time:** 20-30 minutes

**Tasks:**
1. ✅ Review CandidateNotesController for logic errors
   - Verify SOQL queries are correct
   - Check for null pointer exceptions
   - Ensure proper error handling

2. ✅ Add comprehensive logging
   ```apex
   System.debug('Input recordId: ' + recordId);
   System.debug('ContentDocumentLinks found: ' + links.size());
   System.debug('Notes returned: ' + notes.size());
   ```

3. ✅ Add try-catch blocks with user-friendly errors
   ```apex
   try {
       // existing logic
   } catch (Exception e) {
       System.debug('Error in getNotes: ' + e.getMessage());
       throw new AuraHandledException('Error loading notes: ' + e.getMessage());
   }
   ```

4. ✅ Update test class for better coverage
   - Test with null recordId
   - Test with recordId that has no notes
   - Test with recordId that has multiple notes
   - Test error scenarios

5. ✅ Test in ProdTest sandbox first
   - Deploy to ProdTest
   - Verify works with real data
   - Check performance

**Deliverable:**
- Fixed CandidateNotesController.cls
- Updated test class with 100% coverage
- ProdTest validation results

**Handoff To:** Agent 4 for deployment

---

### Phase 2B: LWC Component Fix (Agent 3) - IF LWC ISSUE FOUND
**Estimated Time:** 20-30 minutes

**Tasks:**
1. ✅ Review candidateNotesRelatedList.js wire adapter
   - Verify parameter names match Apex method
   - Check for typos in import statements
   - Ensure @wire syntax is correct

2. ✅ Add comprehensive error logging
   ```javascript
   wiredNotes(result) {
       console.log('Wire adapter called with recordId:', this.recordId);
       console.log('Wire result:', JSON.stringify(result));
       
       if (result.data) {
           console.log('Notes data:', result.data);
           this.notes = result.data || [];
           this.error = undefined;
       } else if (result.error) {
           console.error('Wire error:', JSON.stringify(result.error));
           this.error = result.error;
           this.notes = [];
       }
   }
   ```

3. ✅ Verify component metadata
   - Check .js-meta.xml has correct API version (62.0 or 65.0)
   - Ensure isExposed is true
   - Verify targets include lightning__RecordPage

4. ✅ Review candidateLegacyNotes component
   - Verify NOTES_FIELD schema import is correct
   - Check for proper error handling
   - Ensure empty state displays properly

5. ✅ Test in ProdTest sandbox first
   - Add components to test record page
   - Verify display with and without notes
   - Check browser console for errors

**Deliverable:**
- Fixed LWC components with enhanced logging
- ProdTest validation results
- Browser console output analysis

**Handoff To:** Agent 4 for deployment

---

### Phase 3: Production Deployment (Agent 4)
**Estimated Time:** 20-30 minutes

**Deployment Sequence:**

1. ✅ **Deploy Apex Controller First** (if modified)
   ```bash
   sf project deploy start \
     --source-dir "force-app\main\default\classes\CandidateNotesController.cls" \
     --source-dir "force-app\main\default\classes\CandidateNotesController_Test.cls" \
     --target-org ProductionCapstone \
     --test-level RunSpecifiedTests \
     --tests CandidateNotesController_Test \
     --wait 30
   ```
   - ✅ Verify: Tests pass (3/3)
   - ✅ Verify: Deployment succeeds

2. ✅ **Deploy LWC Components Second**
   ```bash
   sf project deploy start \
     --source-dir "force-app\main\default\lwc\candidateNotesRelatedList" \
     --source-dir "force-app\main\default\lwc\candidateLegacyNotes" \
     --target-org ProductionCapstone \
     --wait 15
   ```
   - ✅ Verify: Deployment succeeds
   - ✅ Verify: No component errors

3. ✅ **Clear Browser Cache**
   - User must hard refresh: Ctrl+Shift+R
   - Or clear Salesforce cache: Setup → Session Settings → Clear Cache

4. ✅ **Validation Testing**
   - Navigate to Candidate record page in Production
   - Check browser console for errors
   - Verify Notes component loads (empty state or with notes)
   - Verify Legacy Notes component displays properly
   - Test Refresh button on Notes component

**Deliverable:**
- Deployment confirmation with IDs
- Browser console screenshots (no errors)
- Functional component screenshots

**Handoff To:** User for final acceptance testing

---

## 🎯 Success Criteria

### Phase 1 Complete When:
- [ ] Exact error messages documented with stack traces
- [ ] CandidateNotesController deployment status confirmed
- [ ] Component metadata verified
- [ ] Root cause identified
- [ ] Fix approach determined (Apex vs LWC vs both)

### Phase 2 Complete When:
- [ ] Code fixes implemented with enhanced logging
- [ ] Test coverage at 100% (Apex) or passing (LWC)
- [ ] ProdTest validation successful
- [ ] No console errors in ProdTest
- [ ] Components display properly in ProdTest

### Phase 3 Complete When:
- [ ] All deployments to Production succeed
- [ ] All tests pass in Production
- [ ] Browser console shows no errors
- [ ] candidateNotesRelatedList displays notes or "No notes yet" message
- [ ] candidateLegacyNotes displays legacy notes or "No legacy notes" message
- [ ] User confirms components are working

---

## 🔄 Handoff Checkpoints

### Checkpoint 1: Research → Development
**Agent 1 delivers to Agent 2/3:**
- Diagnostic report document
- Error logs and stack traces
- Root cause analysis
- Recommendation: Apex fix OR LWC fix OR both

**Agent 2/3 confirms receipt:**
- Understands the identified issue
- Has access to all error details
- Agrees with fix approach

### Checkpoint 2: Development → Deployment
**Agent 2/3 delivers to Agent 4:**
- Fixed component files (in git staging)
- ProdTest validation screenshots
- Test results (all passing)
- Deployment instructions (if special order required)

**Agent 4 confirms receipt:**
- Can see modified files in git status
- Understands deployment sequence
- Has ProdTest validation evidence

### Checkpoint 3: Deployment → User
**Agent 4 delivers to User:**
- Deployment IDs and success confirmations
- Browser cache clearing instructions
- Expected behavior description
- Screenshots of working components

**User confirms:**
- Received deployment notifications
- Understands cache clearing steps
- Ready to test in Production

---

## 🚨 Contingency Plans

### If Phase 1 finds Apex is not deployed:
- Deploy CandidateNotesController immediately
- Deploy test class with it
- Skip Phase 2, go directly to Phase 3

### If Phase 2 fixes don't work in ProdTest:
- Agent 2/3 loops back to Phase 1 diagnostics
- Get additional error logs from ProdTest
- Re-analyze and implement alternate fix

### If Phase 3 deployment fails:
- Check test failures and fix immediately
- If unrelated test failures, deploy with --test-level RunSpecifiedTests
- Document any production-specific issues

### If components still don't work after deployment:
- Agent 1 re-runs diagnostics in Production
- Check for permission set issues
- Verify user has access to Candidate__c object
- Check Lightning page configurations

---

## 📊 Estimated Timeline

| Phase | Agent | Duration | Dependencies |
|-------|-------|----------|--------------|
| Phase 1: Research | Agent 1 | 15-20 min | None |
| Phase 2A: Apex Fix | Agent 2 | 20-30 min | Phase 1 complete |
| Phase 2B: LWC Fix | Agent 3 | 20-30 min | Phase 1 complete |
| Phase 3: Deployment | Agent 4 | 20-30 min | Phase 2 complete |
| **Total** | | **55-80 min** | Sequential execution |

---

## 📝 Communication Protocol

### Status Updates:
- Each agent posts update when phase starts
- Each agent posts update when phase completes
- Any blockers reported immediately

### Handoff Format:
```
## Handoff: [Phase Name]
**From:** Agent [N]
**To:** Agent [N+1]
**Date:** 2026-01-09
**Status:** [Complete/Blocked/Needs Review]

### Work Completed:
- Item 1
- Item 2

### Deliverables:
- File/Document 1
- File/Document 2

### Findings:
- Key finding 1
- Key finding 2

### Next Steps for Receiving Agent:
- Step 1
- Step 2

### Files Modified:
- path/to/file1
- path/to/file2

### Known Issues/Blockers:
- Issue 1 (if any)
```

---

## ✅ Approval Checklist

Before proceeding, confirm:

- [ ] **Plan Structure:** Multi-agent approach with clear handoffs is acceptable
- [ ] **Agent Specializations:** Each agent has clear, focused responsibilities
- [ ] **Phase Sequence:** Research → Fix → Deploy approach makes sense
- [ ] **Timeline:** 55-80 minutes is acceptable timeframe
- [ ] **Success Criteria:** Clear definition of "done" for each phase
- [ ] **Contingencies:** Backup plans cover likely failure scenarios
- [ ] **Communication:** Handoff format provides sufficient documentation

---

## 🚀 Ready to Execute?

Once you approve this plan:

1. I'll activate Agent 1 (Research & Diagnostics)
2. Agent 1 will begin Phase 1 investigation
3. Based on findings, Agent 2 or 3 will be activated
4. Each agent will document handoffs
5. Agent 4 will handle final deployment
6. You'll receive final deliverable for acceptance testing

**Approval needed to proceed:** YES / NO / MODIFY PLAN

---

**Plan Version:** 1.0  
**Last Updated:** 2026-01-09  
**Plan Owner:** Patrick Baker  
**Execution Status:** AWAITING APPROVAL
