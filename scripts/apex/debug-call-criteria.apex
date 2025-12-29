// Check what criteria gets us to 214 calls for Rachyll

Date novemberStart = Date.newInstance(2025, 11, 1);
Date novemberEnd = Date.newInstance(2025, 11, 30);

System.debug('=== DIFFERENT COUNTING METHODS ===\n');

// Method 1: Current (Closed + Call in Subject/TaskSubtype + ActivityDate)
Integer method1 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Method 1 (Current): ' + method1);

// Method 2: No IsClosed filter
Integer method2 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Method 2 (No IsClosed): ' + method2);

// Method 3: Only TaskSubtype = 'Call'
Integer method3 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND TaskSubtype = 'Call' AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Method 3 (TaskSubtype=Call only): ' + method3);

// Method 4: All Tasks (not just calls)
Integer method4 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Method 4 (All Tasks): ' + method4);

// Method 5: CompletedDateTime instead of ActivityDate
Integer method5 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND CompletedDateTime >= :novemberStart AND CompletedDateTime <= :novemberEnd];
System.debug('Method 5 (CompletedDateTime): ' + method5);

// Method 6: CreatedDate
Integer method6 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND CreatedDate >= :novemberStart AND CreatedDate <= :novemberEnd];
System.debug('Method 6 (CreatedDate): ' + method6);

// Method 7: All closed tasks with ActivityDate
Integer method7 = [SELECT COUNT() FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND IsClosed = true AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Method 7 (All Closed Tasks w/ ActivityDate): ' + method7);

// Method 8: Check if there's a custom field or different criteria
System.debug('\n=== SAMPLE TASK DETAILS ===');
List<Task> samples = [SELECT Subject, TaskSubtype, IsClosed, ActivityDate, CreatedDate, CompletedDateTime FROM Task WHERE Owner.Name = 'Rachyll Tenny' AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd LIMIT 5];
for (Task t : samples) {
    System.debug('Subject: ' + t.Subject + ' | TaskSubtype: ' + t.TaskSubtype + ' | IsClosed: ' + t.IsClosed + ' | ActivityDate: ' + t.ActivityDate);
}

System.debug('\n=== BRAD FOR COMPARISON ===');
Integer brad1 = [SELECT COUNT() FROM Task WHERE Owner.Name LIKE '%Sofonia%' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND IsClosed = true AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Brad Method 1 (Current): ' + brad1);

Integer brad2 = [SELECT COUNT() FROM Task WHERE Owner.Name LIKE '%Sofonia%' AND (Subject LIKE '%Call%' OR TaskSubtype = 'Call') AND ActivityDate >= :novemberStart AND ActivityDate <= :novemberEnd];
System.debug('Brad Method 2 (No IsClosed): ' + brad2);
