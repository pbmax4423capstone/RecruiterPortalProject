// Delete candidates in small batches to avoid cascade delete limits
Integer batchSize = 100;
Integer totalDeleted = 0;

List<Candidate__c> toDelete = [SELECT Id FROM Candidate__c LIMIT :batchSize];
if (!toDelete.isEmpty()) {
    delete toDelete;
    totalDeleted += toDelete.size();
    System.debug('Deleted batch of ' + toDelete.size() + ' candidates. Total: ' + totalDeleted);
}

// Count remaining
Integer remaining = [SELECT COUNT() FROM Candidate__c];
System.debug('Remaining candidates: ' + remaining);
