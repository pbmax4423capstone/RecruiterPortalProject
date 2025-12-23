// Create Opportunities from the report and link to Contract B candidates via Soliciting Agent
// Data from report1766203424632.csv

// Get contacts that are linked to our Contract B candidates
Map<String, Id> contactNameToId = new Map<String, Id>();
for (Contact c : [SELECT Id, Name FROM Contact WHERE Name IN (
    'Brandon Arnett', 'Marc Clark', 'Gee Na Park', 'Stone Sinek', 
    'Samuel Fenstermacher', 'Malarie Martin', 'Aaron Diaz', 'Jordyn Manrique',
    'Alexzander Gonzales', 'Anthony Balzano', 'Alicia Johnson', 'Michelle Mayer',
    'Rodrigo Gonzalez', 'Salina Bouasangouane'
)]) {
    contactNameToId.put(c.Name.toLowerCase(), c.Id);
    // Also add variations
    if (c.Name == 'Gee Na Park') {
        contactNameToId.put('gee na park', c.Id);
    }
}

System.debug('Contacts mapped: ' + contactNameToId.size());
for (String name : contactNameToId.keySet()) {
    System.debug('  ' + name + ' -> ' + contactNameToId.get(name));
}

// Get default account
Account acc = [SELECT Id FROM Account WHERE Name LIKE '%Capstone%' LIMIT 1];

// Opportunities from report for our Contract B candidates
// Brandon Arnett opportunities (from earlier query - won)
// Marc Clark opportunities (from earlier query - multiple won + open)
// Gee na Park opportunity (1 won)

List<Opportunity> oppsToCreate = new List<Opportunity>();

// Brandon Arnett - 2 won opportunities
if (contactNameToId.containsKey('brandon arnett')) {
    Id solicitingAgentId = contactNameToId.get('brandon arnett');
    
    oppsToCreate.add(new Opportunity(
        Name = 'John Rouzzo 38810286',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 12, 2),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Samantha Rouzzo 38810287',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 12, 2),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
}

// Gee Na Park - 1 won opportunity
if (contactNameToId.containsKey('gee na park')) {
    Id solicitingAgentId = contactNameToId.get('gee na park');
    
    oppsToCreate.add(new Opportunity(
        Name = 'HONG, SUK HYUN 32896630',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 15),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
}

// Marc Clark - multiple opportunities
if (contactNameToId.containsKey('marc clark')) {
    Id solicitingAgentId = contactNameToId.get('marc clark');
    
    // Won sales
    oppsToCreate.add(new Opportunity(
        Name = 'Sara Lunsford 32901063',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 21),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Sara Lunsford 38812405',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 21),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Sara Lunsford 38812404',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 21),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Dejon Lunsford 38812402',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 7),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Dejon Lunsford 38812401',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 10, 7),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Alex Keith 38812393',
        StageName = 'Complete – Won Sale',
        CloseDate = Date.newInstance(2025, 11, 25),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    // Lost sale
    oppsToCreate.add(new Opportunity(
        Name = 'Darwin Miguel 38812595',
        StageName = 'Complete- Lost Sale',
        CloseDate = Date.newInstance(2025, 11, 29),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    // Open/Submitted
    oppsToCreate.add(new Opportunity(
        Name = 'Kelly Waterhouse 38813901',
        StageName = 'Submitted',
        CloseDate = Date.newInstance(2025, 12, 22),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Thomas Christopherson 38822549',
        StageName = 'Submitted',
        CloseDate = Date.newInstance(2026, 1, 12),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
    
    oppsToCreate.add(new Opportunity(
        Name = 'Thomas Christopherson 38822548',
        StageName = 'Submitted',
        CloseDate = Date.newInstance(2026, 1, 12),
        AccountId = acc.Id,
        Soliciting_Agent__c = solicitingAgentId
    ));
}

System.debug('Opportunities to create: ' + oppsToCreate.size());

if (!oppsToCreate.isEmpty()) {
    insert oppsToCreate;
    System.debug('Created ' + oppsToCreate.size() + ' opportunities');
}

// Verification
System.debug('');
System.debug('=== OPPORTUNITIES CREATED ===');
for (Opportunity o : [SELECT Name, StageName, CloseDate, Soliciting_Agent__r.Name, IsWon, IsClosed 
                      FROM Opportunity 
                      WHERE Soliciting_Agent__c IN :contactNameToId.values()]) {
    System.debug(o.Soliciting_Agent__r.Name + ' | ' + o.Name + ' | ' + o.StageName + ' | Won: ' + o.IsWon);
}
