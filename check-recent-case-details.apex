// Check the most recent Cases with details on Contact assignment
List<Case> recentCases = [
    SELECT Id, CaseNumber, Subject, Description, ContactId, Contact.Name, 
           Contact.Personal_Email__c, Contact.Financialguide_Email__c,
           CreatedDate, CreatedBy.Name, OwnerId, Owner.Name,
           Agents_Staff__c
    FROM Case 
    WHERE CreatedById = :UserInfo.getUserId()
    ORDER BY CreatedDate DESC 
    LIMIT 3
];

for (Case c : recentCases) {
    System.debug('=== CASE ' + c.CaseNumber + ' ===');
    System.debug('Subject: ' + c.Subject);
    System.debug('Description: ' + (c.Description != null ? c.Description.left(200) : 'NULL'));
    System.debug('Contact: ' + c.Contact.Name + ' (ID: ' + c.ContactId + ')');
    System.debug('Contact Personal Email: ' + c.Contact.Personal_Email__c);
    System.debug('Contact FG Email: ' + c.Contact.Financialguide_Email__c);
    System.debug('Agents_Staff__c: ' + c.Agents_Staff__c);
    System.debug('---');
}
