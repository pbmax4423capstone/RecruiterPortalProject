# Interview Leaderboard Controller - Usage Guide

## Overview
The `InterviewLeaderboardController` Apex class has been deployed to your Production org and provides comprehensive interview and call data for all Sales Managers and Recruiters to power your Interview Leaderboard component.

## Main Method

### `getLeaderboardData()`
**Purpose:** Returns complete leaderboard data for all active Sales Managers and Recruiters  
**Type:** `@AuraEnabled(cacheable=true)` - can be used in LWC with wire service  
**Returns:** `List<LeaderboardEntry>`  
**Limit:** Returns data for up to 10 managers/recruiters

## Data Structure

### LeaderboardEntry Object
Each entry contains:

```javascript
{
    managerId: String,              // Salesforce User ID
    managerName: String,            // Full name (e.g., "Rachyll Tenny")
    profileName: String,            // Profile name (e.g., "Recruiter", "Sales Manager")
    activeCandidates: Integer,      // Count of Active/In Process candidates
    totalCandidates: Integer,       // Total candidates owned
    interviewsThisMonth: Integer,   // Total interviews completed this month
    callsThisMonth: Integer,        // Total calls logged this month
    monthBreakdown: {               // Detailed breakdown of interviews by type
        citInterviews: Integer,     // CIT (1st) interviews
        alignInterviews: Integer,   // Align (2nd) interviews
        planInterviews: Integer,    // Plan (3rd) interviews
        presentInterviews: Integer, // Present (4th) interviews
        optionalInterviews: Integer,// Optional (5th) interviews
        totalInterviews: Integer    // Sum of all interview types
    }
}
```

## Usage in Lightning Web Component

### Import the method:
```javascript
import getLeaderboardData from '@salesforce/apex/InterviewLeaderboardController.getLeaderboardData';
```

### Using Wire Service (Recommended):
```javascript
import { LightningElement, wire } from 'lwc';
import getLeaderboardData from '@salesforce/apex/InterviewLeaderboardController.getLeaderboardData';

export default class InterviewLeaderboard extends LightningElement {
    leaderboardData;
    error;

    @wire(getLeaderboardData)
    wiredLeaderboard({ error, data }) {
        if (data) {
            this.leaderboardData = data;
            this.error = undefined;
            // Process data here
            this.processLeaderboardData(data);
        } else if (error) {
            this.error = error;
            this.leaderboardData = undefined;
        }
    }

    processLeaderboardData(data) {
        // Example: Sort by interviews this month
        const sorted = [...data].sort((a, b) => 
            b.interviewsThisMonth - a.interviewsThisMonth
        );
        
        // Access individual interview types
        sorted.forEach(entry => {
            console.log(`${entry.managerName}:`);
            console.log(`  Total Interviews: ${entry.interviewsThisMonth}`);
            console.log(`  CIT: ${entry.monthBreakdown.citInterviews}`);
            console.log(`  Align: ${entry.monthBreakdown.alignInterviews}`);
            console.log(`  Plan: ${entry.monthBreakdown.planInterviews}`);
            console.log(`  Present: ${entry.monthBreakdown.presentInterviews}`);
            console.log(`  Optional: ${entry.monthBreakdown.optionalInterviews}`);
            console.log(`  Calls: ${entry.callsThisMonth}`);
        });
    }
}
```

### Using Imperative Apex Call:
```javascript
import getLeaderboardData from '@salesforce/apex/InterviewLeaderboardController.getLeaderboardData';

async fetchLeaderboardData() {
    try {
        const result = await getLeaderboardData();
        this.leaderboardData = result;
        // Process the data
    } catch (error) {
        console.error('Error fetching leaderboard data:', error);
    }
}
```

## Example Use Cases

### 1. Display Top 5 Interviewers This Month
```javascript
get topInterviewers() {
    if (!this.leaderboardData) return [];
    return [...this.leaderboardData]
        .sort((a, b) => b.interviewsThisMonth - a.interviewsThisMonth)
        .slice(0, 5);
}
```

### 2. Display Top Callers This Month
```javascript
get topCallers() {
    if (!this.leaderboardData) return [];
    return [...this.leaderboardData]
        .sort((a, b) => b.callsThisMonth - a.callsThisMonth)
        .slice(0, 5);
}
```

### 3. Calculate Team Totals
```javascript
get teamTotals() {
    if (!this.leaderboardData) return {};
    
    return this.leaderboardData.reduce((totals, entry) => {
        totals.interviews += entry.interviewsThisMonth;
        totals.calls += entry.callsThisMonth;
        totals.activeCandidates += entry.activeCandidates;
        return totals;
    }, { interviews: 0, calls: 0, activeCandidates: 0 });
}
```

### 4. Get Breakdown by Interview Type
```javascript
get interviewTypeBreakdown() {
    if (!this.leaderboardData) return {};
    
    return this.leaderboardData.reduce((breakdown, entry) => {
        breakdown.cit += entry.monthBreakdown.citInterviews;
        breakdown.align += entry.monthBreakdown.alignInterviews;
        breakdown.plan += entry.monthBreakdown.planInterviews;
        breakdown.present += entry.monthBreakdown.presentInterviews;
        breakdown.optional += entry.monthBreakdown.optionalInterviews;
        return breakdown;
    }, { cit: 0, align: 0, plan: 0, present: 0, optional: 0 });
}
```

## HTML Template Example

```html
<template>
    <lightning-card title="Interview Leaderboard" icon-name="standard:marketing_actions">
        <template if:true={leaderboardData}>
            <table class="slds-table slds-table_cell-buffer slds-table_bordered">
                <thead>
                    <tr>
                        <th>Name</th>
                        <th>Active Candidates</th>
                        <th>Interviews</th>
                        <th>Calls</th>
                        <th>CIT</th>
                        <th>Align</th>
                        <th>Plan</th>
                    </tr>
                </thead>
                <tbody>
                    <template for:each={leaderboardData} for:item="entry">
                        <tr key={entry.managerId}>
                            <td>{entry.managerName}</td>
                            <td>{entry.activeCandidates}</td>
                            <td>{entry.interviewsThisMonth}</td>
                            <td>{entry.callsThisMonth}</td>
                            <td>{entry.monthBreakdown.citInterviews}</td>
                            <td>{entry.monthBreakdown.alignInterviews}</td>
                            <td>{entry.monthBreakdown.planInterviews}</td>
                        </tr>
                    </template>
                </tbody>
            </table>
        </template>
        <template if:true={error}>
            <p>Error loading leaderboard: {error.body.message}</p>
        </template>
    </lightning-card>
</template>
```

## Interview Type Field Mapping

The data comes from the following Candidate__c fields:
- **CIT (1st):** `AI_Completed_Date_Time__c` OR `Attraction_Interview_Date_Completed__c`
- **Align (2nd):** `SI_1_Date_Completed__c`
- **Plan (3rd):** `SI_2_Date_Completed__c`
- **Present (4th):** `SI_3_Completed__c`
- **Optional (5th):** `Career_Presentation_Date_Completed__c`

## Call Data Source

Calls are counted from the Task object where:
- `Subject LIKE '%Call%'` OR `TaskSubtype = 'Call'`
- `IsClosed = true`
- `ActivityDate = THIS_MONTH`

## Performance Notes

- The method is cacheable for better performance
- Returns data for up to 10 managers/recruiters (top 10 alphabetically)
- Currently optimized to return THIS_MONTH data only
- Uses 8 SOQL queries per manager (80 queries for 10 managers)

## Class Name Reference

**Apex Class:** `InterviewLeaderboardController`  
**Main Method:** `getLeaderboardData()`  
**Return Type:** `List<InterviewLeaderboardController.LeaderboardEntry>`

Your colleague should import and use it like this:
```javascript
import getLeaderboardData from '@salesforce/apex/InterviewLeaderboardController.getLeaderboardData';
```
