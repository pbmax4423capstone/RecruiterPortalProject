# ALC Terminal Stages Documentation

**Last Updated:** 2026-01-08  
**Component:** candidatesInContracting (Candidates by Record Type)  
**Purpose:** Define which ALC stages represent finished work excluded from the Kanban board

---

## Overview

The candidatesInContracting component displays ALC (Agency Licensing & Contracting) records organized by record type and stage. Terminal stages represent finished work—either completed successfully or canceled—and are excluded from the component display to keep the board focused on active contracting work.

---

## Terminal Stages by Record Type

### Broker Record Type

| Sort Order | Stage API Value | Stage Label | Reason                                    |
| ---------- | --------------- | ----------- | ----------------------------------------- |
| 8          | COMPLETE        | COMPLETE    | Contracting process finished successfully |
| 9          | CANCELED        | CANCELED    | Contracting process was canceled          |

**Active Workflow Stages:** 7 (Sort Order 1-7)  
**Terminal Stages:** 2

---

### Career Record Type

| Sort Order | Stage API Value    | Stage Label        | Reason                                    |
| ---------- | ------------------ | ------------------ | ----------------------------------------- |
| 10         | Candidate Complete | Candidate Complete | Contracting process finished successfully |
| 11         | TERMINATED         | TERMINATED         | Candidate terminated during contracting   |
| 12         | CANCELED           | CANCELED           | Contracting process was canceled          |

**Active Workflow Stages:** 9 (Sort Order 1-9)  
**Terminal Stages:** 3

---

### NRF Record Type

| Sort Order | Stage API Value | Stage Label | Reason                                        |
| ---------- | --------------- | ----------- | --------------------------------------------- |
| 8          | COMPLETE        | COMPLETE    | NRF contracting process finished successfully |

**Active Workflow Stages:** 7 (Sort Order 1-7)  
**Terminal Stages:** 1

**Note:** Stage 07 "Request FieldNet/CoverPath Access" was incorrectly marked as terminal. Fixed on 2026-01-08 to be an active workflow stage.

---

### Registration Record Type

| Sort Order | Stage API Value          | Stage Label              | Reason                                     |
| ---------- | ------------------------ | ------------------------ | ------------------------------------------ |
| 7          | Received Approval Letter | Received Approval Letter | Registration process finished successfully |
| 8          | CANCELED                 | CANCELED                 | Registration process was canceled          |

**Active Workflow Stages:** 6 (Sort Order 1-6)  
**Terminal Stages:** 2

---

## Technical Implementation

### Custom Metadata Configuration

Terminal stages are identified in the `ALC_Stage_Config__mdt` Custom Metadata Type using the `Is_Active__c` field:

```xml
<values>
    <field>Is_Active__c</field>
    <value xsi:type="xsd:boolean">false</value>  <!-- Terminal stage -->
</values>
```

Active workflow stages have `Is_Active__c = true`.

### Apex Controller Filtering

The `CandidatesInContractingController` queries only active stages:

**File:** `force-app/main/default/classes/CandidatesInContractingController.cls`

```apex
// Line 98-104: Retrieve only active stage configurations
List<ALC_Stage_Config__mdt> stageConfigs = [
    SELECT Record_Type_API_Name__c, Stage_API_Value__c, ...
    FROM ALC_Stage_Config__mdt
    WHERE Is_Active__c = true  // Excludes terminal stages
    ORDER BY Record_Type_API_Name__c, Sort_Order__c
];

// Line 148-153: Query ALC records only in active stages
List<ALC__c> alcRecords = [
    SELECT Id, Candidate__c, Stage__c, ...
    FROM ALC__c
    WHERE Stage__c IN :validStages  // Only includes active stages
    AND ...
];
```

This ensures:

1. Terminal stage columns don't appear in the Kanban UI
2. Records in terminal stages are excluded from queries
3. Tab counts only include active records

---

## Total Stage Counts

| Record Type  | Total Stages | Active Workflow | Terminal | Terminal % |
| ------------ | ------------ | --------------- | -------- | ---------- |
| Broker       | 9            | 7               | 2        | 22%        |
| Career       | 12           | 9               | 3        | 25%        |
| NRF          | 8            | 7               | 1        | 13%        |
| Registration | 8            | 6               | 2        | 25%        |
| **TOTAL**    | **37**       | **29**          | **8**    | **22%**    |

---

## User Impact

### What Users See

✅ **Displayed:**

- All active workflow stages (Initial Form Sent through final active stage)
- Records in active stages only
- Tab counts reflecting only active records

❌ **Hidden:**

- COMPLETE, CANCELED, TERMINATED, Candidate Complete, Received Approval Letter stages
- Records that have reached terminal stages
- Counts of terminal records

### Why This Design?

The Kanban board is designed for **managing active contracting work**. Showing terminal stages would:

- Clutter the UI with finished work
- Mix completed records with in-progress work
- Make it harder to focus on candidates requiring action

Users can view completed/canceled records through:

- Standard ALC list views
- Reports filtered by terminal stages
- Candidate record pages showing related ALCs

---

## Maintenance Notes

### When Adding New Stages

If adding a new stage to any record type:

1. **Workflow Stage** - Set `Is_Active__c = true`
   - Appears in component
   - Included in queries and counts

2. **Terminal Stage** - Set `Is_Active__c = false`
   - Hidden from component
   - Excluded from queries and counts
   - Document in this file

### When Modifying Terminal Stages

⚠️ **IMPORTANT:** Changing terminal stage configuration affects:

- Component display and counts
- Historical data visibility
- User workflow expectations

Always:

1. Update this documentation
2. Test in ProdTest sandbox first
3. Communicate changes to ALC team

---

## Related Documentation

- [COLE_ARNOLD_DEVELOPMENT_GUIDE.md](../COLE_ARNOLD_DEVELOPMENT_GUIDE.md) - Component development
- [METADATA-AUDIT-2026-01-08.md](handoffs/METADATA-AUDIT-2026-01-08.md) - Audit findings
- [METADATA-FIXES-2026-01-08.md](handoffs/METADATA-FIXES-2026-01-08.md) - Fix applied

---

## Change Log

**2026-01-08:**

- Initial documentation created
- Fixed NRF Stage 07 "Request FieldNet/CoverPath Access" (was incorrectly marked inactive)
- Verified all 37 stage configurations
- Documented 8 terminal stages across 4 record types

---

**Maintained By:** Development Team  
**Questions?** See `.github/copilot-instructions.md` or `.github/copilot-instructions-cole.md`
