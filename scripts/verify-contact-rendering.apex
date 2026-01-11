// Verify Contact snapshot rendering for ALC records in ProdTest
List<ALC__c> alcs = [SELECT Id, Name FROM ALC__c LIMIT 5];
System.debug('Found ALCs: ' + alcs.size());
for (ALC__c a : alcs) {
    ALCRecordViewController.ContactSnapshot s = ALCRecordViewController.getContactSnapshotByALCId(a.Id);
    System.debug('ALC ' + a.Name + ' Contact Snapshot: ' +
        ' firstName=' + (s == null ? null : s.firstName) +
        ' lastName=' + (s == null ? null : s.lastName) +
        ' email=' + (s == null ? null : s.email) +
        ' mobile=' + (s == null ? null : s.mobilePhone) +
        ' home=' + (s == null ? null : s.homePhone) +
        ' mailing=' + (s == null ? null : (s.mailingStreet + ' ' + s.mailingCity + ' ' + s.mailingState + ' ' + s.mailingPostalCode))
    );
}