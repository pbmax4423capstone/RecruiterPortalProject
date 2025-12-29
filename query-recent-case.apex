// Query for most recent Case created by current user
List<Case> recentCases = [
    SELECT Id, CaseNumber, Subject, Description, Status, Priority, 
           ContactId, Contact.Name, CreatedDate, CreatedBy.Name, OwnerId, Owner.Name
    FROM Case 
    WHERE CreatedById = :UserInfo.getUserId()
    ORDER BY CreatedDate DESC 
    LIMIT 5
];

System.debug('=== RECENT CASES CREATED BY ' + UserInfo.getName() + ' ===');
for (Case c : recentCases) {
    System.debug('Case Number: ' + c.CaseNumber);
    System.debug('  ID: ' + c.Id);
    System.debug('  Subject: ' + c.Subject);
    System.debug('  Description: ' + c.Description);
    System.debug('  Status: ' + c.Status);
    System.debug('  Priority: ' + c.Priority);
    System.debug('  Contact: ' + c.Contact?.Name + ' (ID: ' + c.ContactId + ')');
    System.debug('  Owner: ' + c.Owner?.Name + ' (ID: ' + c.OwnerId + ')');
    System.debug('  Created: ' + c.CreatedDate);
    System.debug('---');
}

System.debug('TOTAL CASES FOUND: ' + recentCases.size());
