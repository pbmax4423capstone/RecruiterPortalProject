# Sales Manager Activity History & Notes Fix

## Issue
Sales Managers were unable to view Activity History and Notes components on Candidate record pages, receiving the following errors:
- **Activity History:** "Error loading activities"
- **Notes:** "Error loading notes - You do not have access to the Apex class named 'CandidateNoteController'."

## Root Cause
The `Sales_Manager_Contracting_Dashboard_Access` permission set was missing Apex class permissions for:
1. `CandidateActivityController` - Powers the Activity History component
2. `CandidateNotesController` - Powers the Notes component

Additionally, object-level permissions were missing for:
- `Task` (read/create/edit access needed for activities)
- `Event` (read/create/edit access needed for calendar events)
- `ContentNote` (read access needed for notes)

## Solution Implemented

### Updated Permission Set
**File:** `force-app\main\default\permissionsets\Sales_Manager_Contracting_Dashboard_Access.permissionset-meta.xml`

**Added Apex Class Permissions:**
```xml
<classAccesses>
    <apexClass>CandidateActivityController</apexClass>
    <enabled>true</enabled>
</classAccesses>
<classAccesses>
    <apexClass>CandidateNotesController</apexClass>
    <enabled>true</enabled>
</classAccesses>
```

**Added Object Permissions:**
```xml
<!-- Task Object - for Activity History -->
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>true</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>false</modifyAllRecords>
    <object>Task</object>
    <viewAllRecords>false</viewAllRecords>
</objectPermissions>

<!-- Event Object - for Activity History -->
<objectPermissions>
    <allowCreate>true</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>true</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>false</modifyAllRecords>
    <object>Event</object>
    <viewAllRecords>false</viewAllRecords>
</objectPermissions>

<!-- ContentNote Object - for Notes -->
<objectPermissions>
    <allowCreate>false</allowCreate>
    <allowDelete>false</allowDelete>
    <allowEdit>false</allowEdit>
    <allowRead>true</allowRead>
    <modifyAllRecords>false</modifyAllRecords>
    <object>ContentNote</object>
    <viewAllRecords>false</viewAllRecords>
</objectPermissions>
```

**Updated Description:**
```
Grants Sales Managers access to view their Career candidates, activity history, notes, and contracting pipeline. 
Includes access to Candidate records, ALC records, Tasks, Events, and ContentNotes for full candidate management capabilities.
```

## Deployment Details
- **Target Org:** ProductionCapstone (patrickbakeradmin2@financialguide.com)
- **Deploy ID:** 0AfVo000000tJtFKAU
- **Status:** Succeeded
- **Date:** 2026-01-09

## Users with Permission Set Assigned
The following 10 users already have the `Sales_Manager_Contracting_Dashboard_Access` permission set:
1. Andrew Moore (Brokerage Director)
2. Bradley Sofonia (Sales Manager- Brad S)
3. Elizabeth Kagele (Sales Manager)
4. Hailey Mullen (New Business Director)
5. Matt Schraeder (Brokerage Director)
6. Michael Acosta (Brokerage Director)
7. Michael Trujillo (Director of Sales)
8. Pat Baker (System Administrator)
9. Tim Denton (Sales Manager)
10. Van Hess (GA)

## Testing
**To verify the fix:**
1. Log in as a Sales Manager (e.g., Tim Denton or Elizabeth Kagele)
2. Navigate to a Candidate record page
3. Verify Activity History component loads without errors
4. Verify Notes component loads without errors
5. Test creating a new Task
6. Test creating a new Note

## Components Affected
- **LWC:** `candidateActivityHistory` (uses `CandidateActivityController`)
- **LWC:** `candidateNotesRelatedList` (uses `CandidateNotesController`)
- **Apex:** `CandidateActivityController.cls`
- **Apex:** `CandidateNotesController.cls`

## Additional Notes
- Both Apex controllers use appropriate sharing rules:
  - `CandidateActivityController` uses `with sharing`
  - `CandidateNotesController` uses `without sharing` (to access ContentVersion records)
- No changes were made to the Apex classes themselves
- Only the permission set was updated to grant access
- The fix is backward compatible and does not affect other user profiles

## Related Documentation
- [Sales Manager Contracting Dashboard Guide](docs/SM-Contracting-Dashboard-Guide.md)
- [COLE_ARNOLD_DEVELOPMENT_GUIDE.md](COLE_ARNOLD_DEVELOPMENT_GUIDE.md)
- [WORK_COORDINATION.md](WORK_COORDINATION.md)
