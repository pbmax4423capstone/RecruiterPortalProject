// Interview Counts Report
// Generates a comprehensive report of interview counts by type and time period

System.debug('=================================================================');
System.debug('           INTERVIEW COUNTS BY TYPE AND TIME PERIOD              ');
System.debug('=================================================================\n');

// CIT (1st) - Attraction Interview
// NOTE: Two different fields are used - checking both
Integer citWeek = [SELECT COUNT() FROM Candidate__c 
                   WHERE AI_Completed_Date_Time__c = THIS_WEEK 
                   OR Attraction_Interview_Date_Completed__c = THIS_WEEK];
Integer citMonth = [SELECT COUNT() FROM Candidate__c 
                    WHERE AI_Completed_Date_Time__c = THIS_MONTH 
                    OR Attraction_Interview_Date_Completed__c = THIS_MONTH];
Integer citYear = [SELECT COUNT() FROM Candidate__c 
                   WHERE AI_Completed_Date_Time__c = THIS_YEAR 
                   OR Attraction_Interview_Date_Completed__c = THIS_YEAR];

System.debug('CIT (1st) - Attraction Interview:');
System.debug('  This Week:  ' + citWeek);
System.debug('  This Month: ' + citMonth);
System.debug('  This Year:  ' + citYear);
System.debug('');

// Align (2nd) - Second Interview
Integer alignWeek = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_WEEK];
Integer alignMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_MONTH];
Integer alignYear = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c = THIS_YEAR];

System.debug('Align (2nd) - Second Interview:');
System.debug('  This Week:  ' + alignWeek);
System.debug('  This Month: ' + alignMonth);
System.debug('  This Year:  ' + alignYear);
System.debug('');

// Plan (3rd) - Third Interview
Integer planWeek = [SELECT COUNT() FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_WEEK];
Integer planMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_MONTH];
Integer planYear = [SELECT COUNT() FROM Candidate__c WHERE SI_2_Date_Completed__c = THIS_YEAR];

System.debug('Plan (3rd) - Third Interview:');
System.debug('  This Week:  ' + planWeek);
System.debug('  This Month: ' + planMonth);
System.debug('  This Year:  ' + planYear);
System.debug('');

// Present (4th) - Fourth Interview
Integer presentWeek = [SELECT COUNT() FROM Candidate__c WHERE SI_3_Completed__c = THIS_WEEK];
Integer presentMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_3_Completed__c = THIS_MONTH];
Integer presentYear = [SELECT COUNT() FROM Candidate__c WHERE SI_3_Completed__c = THIS_YEAR];

System.debug('Present (4th) - Fourth Interview:');
System.debug('  This Week:  ' + presentWeek);
System.debug('  This Month: ' + presentMonth);
System.debug('  This Year:  ' + presentYear);
System.debug('');

// Optional (5th) - Career Presentation
Integer optionalWeek = [SELECT COUNT() FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_WEEK];
Integer optionalMonth = [SELECT COUNT() FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_MONTH];
Integer optionalYear = [SELECT COUNT() FROM Candidate__c WHERE Career_Presentation_Date_Completed__c = THIS_YEAR];

System.debug('Optional (5th) - Career Presentation:');
System.debug('  This Week:  ' + optionalWeek);
System.debug('  This Month: ' + optionalMonth);
System.debug('  This Year:  ' + optionalYear);
System.debug('');

// Calculate totals
Integer totalWeek = citWeek + alignWeek + planWeek + presentWeek + optionalWeek;
Integer totalMonth = citMonth + alignMonth + planMonth + presentMonth + optionalMonth;
Integer totalYear = citYear + alignYear + planYear + presentYear + optionalYear;

System.debug('=================================================================');
System.debug('TOTALS:');
System.debug('  This Week:  ' + totalWeek);
System.debug('  This Month: ' + totalMonth);
System.debug('  This Year:  ' + totalYear);
System.debug('=================================================================');

// Create formatted table output
System.debug('\n');
System.debug('FORMATTED SUMMARY TABLE:');
System.debug('┌─────────────────────────┬───────────┬────────────┬───────────┐');
System.debug('│ Interview Type          │ This Week │ This Month │ This Year │');
System.debug('├─────────────────────────┼───────────┼────────────┼───────────┤');
System.debug('│ CIT (1st)               │ ' + String.valueOf(citWeek).leftPad(9) + ' │ ' + String.valueOf(citMonth).leftPad(10) + ' │ ' + String.valueOf(citYear).leftPad(9) + ' │');
System.debug('│ Align (2nd)             │ ' + String.valueOf(alignWeek).leftPad(9) + ' │ ' + String.valueOf(alignMonth).leftPad(10) + ' │ ' + String.valueOf(alignYear).leftPad(9) + ' │');
System.debug('│ Plan (3rd)              │ ' + String.valueOf(planWeek).leftPad(9) + ' │ ' + String.valueOf(planMonth).leftPad(10) + ' │ ' + String.valueOf(planYear).leftPad(9) + ' │');
System.debug('│ Present (4th)           │ ' + String.valueOf(presentWeek).leftPad(9) + ' │ ' + String.valueOf(presentMonth).leftPad(10) + ' │ ' + String.valueOf(presentYear).leftPad(9) + ' │');
System.debug('│ Optional (5th)          │ ' + String.valueOf(optionalWeek).leftPad(9) + ' │ ' + String.valueOf(optionalMonth).leftPad(10) + ' │ ' + String.valueOf(optionalYear).leftPad(9) + ' │');
System.debug('├─────────────────────────┼───────────┼────────────┼───────────┤');
System.debug('│ TOTAL                   │ ' + String.valueOf(totalWeek).leftPad(9) + ' │ ' + String.valueOf(totalMonth).leftPad(10) + ' │ ' + String.valueOf(totalYear).leftPad(9) + ' │');
System.debug('└─────────────────────────┴───────────┴────────────┴───────────┘');

System.debug('\nReport generated: ' + DateTime.now().format('yyyy-MM-dd HH:mm:ss'));
