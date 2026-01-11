// Verify Contact snapshot for a specific ALC record in ProdTest
Id alcId = 'a12dm000000l24eAAA';
System.debug('Verifying Contact snapshot for ALC: ' + alcId);
ALCRecordViewController.ContactSnapshot snap = ALCRecordViewController.getContactSnapshotByALCId(alcId);
if (snap == null) {
    System.debug('Snapshot is NULL');
} else {
    System.debug('Snapshot Id: ' + snap.id);
    System.debug('Name: ' + snap.firstName + ' ' + snap.lastName);
    System.debug('Email: ' + snap.email);
    System.debug('Mobile: ' + snap.mobilePhone);
    System.debug('Home: ' + snap.homePhone);
    System.debug('Personal Email: ' + snap.personalEmail);
}

// Skipping direct ALC query due to org-level enforced FLS; rely on snapshot above
