// ================================================================
// DRY RUN - Notes Field Migration
// ================================================================
// This script runs the migration in DRY RUN mode.
// No changes will be made to your org.
// Use this to validate how many notes will be migrated.
// ================================================================

System.debug('========================================');
System.debug('NOTES FIELD MIGRATION - DRY RUN');
System.debug('========================================');
System.debug('');

// Count candidates with Notes__c populated
Integer candidatesWithNotes = [
    SELECT COUNT() 
    FROM Candidate__c 
    WHERE Notes__c != null 
    AND Notes__c != ''
];

System.debug('Candidates with populated Notes__c field: ' + candidatesWithNotes);
System.debug('');

// Execute batch in dry run mode
System.debug('Starting batch job in DRY RUN mode...');
System.debug('Batch size: 100 records per execution');
System.debug('');

NotesFieldMigrationBatch batch = new NotesFieldMigrationBatch(true); // true = dry run
Id batchJobId = Database.executeBatch(batch, 100);

System.debug('Batch Job ID: ' + batchJobId);
System.debug('');
System.debug('This is a DRY RUN - no changes will be made.');
System.debug('');
System.debug('Monitor progress with:');
System.debug('Run: check-notes-migration-status.apex');
System.debug('');
System.debug('After validation, run real migration with:');
System.debug('Run: run-notes-migration.apex');
System.debug('========================================');
