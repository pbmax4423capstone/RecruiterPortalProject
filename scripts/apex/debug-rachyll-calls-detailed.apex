// Check all Rachyll calls in November - including open ones and different date fields

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

System.debug('=== RACHYLL CALLS - CLOSED WITH ACTIVITYDATE ===');
Integer closedActivityDate = [
    SELECT COUNT()
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
];
System.debug('Count: ' + closedActivityDate);

System.debug('\n=== RACHYLL CALLS - ALL (CLOSED + OPEN) WITH ACTIVITYDATE ===');
Integer allActivityDate = [
    SELECT COUNT()
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
];
System.debug('Count: ' + allActivityDate);

System.debug('\n=== RACHYLL CALLS - CLOSED WITH CREATEDDATE ===');
Integer closedCreatedDate = [
    SELECT COUNT()
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND CreatedDate >= :novemberStart
    AND CreatedDate <= :novemberEnd
];
System.debug('Count: ' + closedCreatedDate);

System.debug('\n=== RACHYLL CALLS - CLOSED WITH COMPLETEDDATETIME ===');
Integer closedCompletedDate = [
    SELECT COUNT()
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND CompletedDateTime >= :novemberStart
    AND CompletedDateTime <= :novemberEnd
];
System.debug('Count: ' + closedCompletedDate);

System.debug('\n=== RACHYLL CALLS - ALL WITH COMPLETEDDATETIME (NO ISCLOSED CHECK) ===');
Integer allCompletedDate = [
    SELECT COUNT()
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND CompletedDateTime >= :novemberStart
    AND CompletedDateTime <= :novemberEnd
];
System.debug('Count: ' + allCompletedDate);

System.debug('\n=== CHECKING TASKSUBTYPE VALUES ===');
for (AggregateResult ar : [
    SELECT TaskSubtype, COUNT(Id) cnt
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
    GROUP BY TaskSubtype
]) {
    System.debug((String)ar.get('TaskSubtype') + ': ' + ar.get('cnt'));
}
