/**
 * November 2025 Interview Event Report
 * Counts events by interview type to compare with Recruiting Portal Dashboard
 */

// Query all interview events created in November 2025
List<Event> novemberEvents = [
    SELECT Id, Subject, ActivityDate
    FROM Event
    WHERE Subject LIKE 'Interview%'
    AND ActivityDate >= 2025-11-01
    AND ActivityDate <= 2025-11-30
];

// Initialize counters for each interview type
Integer attractionCount = 0;
Integer careerPresentationCount = 0;
Integer si1Count = 0;
Integer si2Count = 0;
Integer si3Count = 0;
Integer totalCount = novemberEvents.size();

// Count by interview type based on Subject field
for (Event e : novemberEvents) {
    if (e.Subject.contains('Attraction')) {
        attractionCount++;
    } else if (e.Subject.contains('Career Presentation')) {
        careerPresentationCount++;
    } else if (e.Subject.contains('SI 1')) {
        si1Count++;
    } else if (e.Subject.contains('SI 2')) {
        si2Count++;
    } else if (e.Subject.contains('SI 3')) {
        si3Count++;
    }
}

// Print report
System.debug('========================================');
System.debug('NOVEMBER 2025 INTERVIEW EVENT REPORT');
System.debug('========================================');
System.debug('');
System.debug('Interview Type Breakdown:');
System.debug('-------------------------');
System.debug('Attraction (AI):          ' + attractionCount);
System.debug('Career Presentation (CP): ' + careerPresentationCount);
System.debug('SI 1 (ALIGN):             ' + si1Count);
System.debug('SI 2 (PLAN):              ' + si2Count);
System.debug('SI 3 (PRESENT):           ' + si3Count);
System.debug('-------------------------');
System.debug('TOTAL EVENTS:             ' + totalCount);
System.debug('');
System.debug('========================================');
System.debug('');
System.debug('Compare these counts to the Recruiting Portal Dashboard');
System.debug('to verify data consistency after migration.');
System.debug('');
