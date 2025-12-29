// Debug November 2025 Call Counts

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

// Get Sales Managers and Active Recruiters
List<User> managers = [
    SELECT Id, Name, UserRole.Name, Profile.Name
    FROM User
    WHERE (
        UserRole.Name LIKE '%Sales Manager%'
        OR Profile.Name LIKE '%Sales Manager%'
    )
    OR (
        IsActive = true
        AND (
            UserRole.Name LIKE '%Recruiter%'
            OR Profile.Name LIKE '%Recruiter%'
        )
    )
    ORDER BY Name
];

System.debug('=== MANAGERS/RECRUITERS ===');
for (User u : managers) {
    System.debug(u.Name + ' (' + u.Id + ')');
}

System.debug('\n=== CALL COUNTS BY OWNER ===');

for (AggregateResult ar : [
    SELECT OwnerId owner, Owner.Name ownerName, COUNT(Id) cnt
    FROM Task
    WHERE OwnerId IN (SELECT Id FROM User WHERE (
        UserRole.Name LIKE '%Sales Manager%'
        OR Profile.Name LIKE '%Sales Manager%'
    )
    OR (
        IsActive = true
        AND (
            UserRole.Name LIKE '%Recruiter%'
            OR Profile.Name LIKE '%Recruiter%'
        )
    ))
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
    GROUP BY OwnerId, Owner.Name
    ORDER BY Owner.Name
]) {
    String ownerName = (String)ar.get('ownerName');
    Integer count = (Integer)ar.get('cnt');
    System.debug(ownerName + ': ' + count + ' calls');
}

System.debug('\n=== SAMPLE RACHYLL CALLS ===');
List<Task> rachyllCalls = [
    SELECT Id, Subject, ActivityDate, Owner.Name
    FROM Task
    WHERE Owner.Name = 'Rachyll Tenny'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
    ORDER BY ActivityDate DESC
    LIMIT 10
];

for (Task t : rachyllCalls) {
    System.debug(t.ActivityDate + ' - ' + t.Subject + ' (' + t.Id + ')');
}
System.debug('Total Rachyll calls shown: ' + rachyllCalls.size());

System.debug('\n=== SAMPLE BRAD CALLS ===');
List<Task> bradCalls = [
    SELECT Id, Subject, ActivityDate, Owner.Name
    FROM Task
    WHERE Owner.Name LIKE '%Sofonia%'
    AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call')
    AND IsClosed = true
    AND ActivityDate >= :novemberStart
    AND ActivityDate <= :novemberEnd
    ORDER BY ActivityDate DESC
    LIMIT 10
];

for (Task t : bradCalls) {
    System.debug(t.ActivityDate + ' - ' + t.Subject + ' (' + t.Id + ')');
}
System.debug('Total Brad calls shown: ' + bradCalls.size());
