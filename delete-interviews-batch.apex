// Delete interviews in batches
Integer batchSize = 2000;
Integer totalDeleted = 0;

List<Interview__c> toDelete = [SELECT Id FROM Interview__c LIMIT :batchSize];
while (!toDelete.isEmpty()) {
    delete toDelete;
    totalDeleted += toDelete.size();
    System.debug('Deleted batch of ' + toDelete.size() + ' interviews. Total: ' + totalDeleted);
    toDelete = [SELECT Id FROM Interview__c LIMIT :batchSize];
}

System.debug('Total interviews deleted: ' + totalDeleted);

// Count remaining
Integer remaining = [SELECT COUNT() FROM Interview__c];
System.debug('Remaining interviews: ' + remaining);
