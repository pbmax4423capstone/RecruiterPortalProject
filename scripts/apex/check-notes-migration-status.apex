// ================================================================
// CHECK STATUS - Notes Field Migration
// ================================================================
// Monitor the progress of the migration batch job
// ================================================================

System.debug('========================================');
System.debug('NOTES FIELD MIGRATION - STATUS CHECK');
System.debug('========================================');
System.debug('');

// Find the most recent NotesFieldMigrationBatch job
List<AsyncApexJob> jobs = [
    SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems,
           CreatedDate, CompletedDate, ExtendedStatus, ApexClass.Name
    FROM AsyncApexJob
    WHERE ApexClass.Name = 'NotesFieldMigrationBatch'
    ORDER BY CreatedDate DESC
    LIMIT 5
];

if (jobs.isEmpty()) {
    System.debug('No NotesFieldMigrationBatch jobs found.');
} else {
    System.debug('Found ' + jobs.size() + ' recent job(s):');
    System.debug('');
    
    for (AsyncApexJob job : jobs) {
        System.debug('--- Job ID: ' + job.Id + ' ---');
        System.debug('Status: ' + job.Status);
        System.debug('Created: ' + job.CreatedDate);
        
        if (job.CompletedDate != null) {
            System.debug('Completed: ' + job.CompletedDate);
        }
        
        System.debug('Progress: ' + job.JobItemsProcessed + ' / ' + job.TotalJobItems + ' batches');
        System.debug('Errors: ' + job.NumberOfErrors);
        
        if (job.ExtendedStatus != null) {
            System.debug('Extended Status: ' + job.ExtendedStatus);
        }
        
        System.debug('');
    }
}

// Count candidates with Notes__c
Integer candidatesWithNotes = [
    SELECT COUNT() 
    FROM Candidate__c 
    WHERE Notes__c != null 
    AND Notes__c != ''
];

System.debug('Candidates with populated Notes__c: ' + candidatesWithNotes);

// Count ContentDocumentLinks for Candidates
Integer contentLinks = [
    SELECT COUNT() 
    FROM ContentDocumentLink 
    WHERE LinkedEntity.Type = 'Candidate__c'
];

System.debug('ContentDocumentLinks for Candidates: ' + contentLinks);
System.debug('');

// Count ContentNotes with migration title pattern
String titlePattern = 'Legacy Note - Migrated%';
Integer migratedNotes = [
    SELECT COUNT() 
    FROM ContentVersion 
    WHERE FileType = 'SNOTE' 
    AND Title LIKE :titlePattern
];

System.debug('Migrated ContentNotes (matching title pattern): ' + migratedNotes);
System.debug('========================================');
