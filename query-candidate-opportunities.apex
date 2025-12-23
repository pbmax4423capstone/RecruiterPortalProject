// Query Opportunities where Soliciting Agent matches Contract B candidates
// Running against Production org

List<String> candidateNames = new List<String>{
    'Samuel Fenstermacher',
    'Malarie Martin',
    'Alexzander Gonzales',
    'Aaron Diaz',
    'Jordyn Manrique',
    'Gee Na Park',
    'Brandon Arnett',
    'Marc Clark',
    'Stone Sinek',
    'Anthony Balzano'
};

// Query Opportunities by Soliciting Agent name
System.debug('=== OPPORTUNITIES BY SOLICITING AGENT ===');
List<Opportunity> opps = [
    SELECT Id, Name, StageName, Amount, CloseDate, Soliciting_Agent__c, Soliciting_Agent__r.Name,
           AccountId, Account.Name, IsClosed, IsWon
    FROM Opportunity
    WHERE Soliciting_Agent__r.Name IN :candidateNames
    LIMIT 200
];

System.debug('Total opportunities with soliciting agent matching candidates: ' + opps.size());
for (Opportunity o : opps) {
    System.debug(o.Soliciting_Agent__r.Name + ' | Opp: ' + o.Name + ' | Stage: ' + o.StageName + 
                 ' | Amount: ' + o.Amount + ' | Close: ' + o.CloseDate + ' | Closed: ' + o.IsClosed + ' | Won: ' + o.IsWon);
}
