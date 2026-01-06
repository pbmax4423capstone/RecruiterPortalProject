// ================================================================
// REAL MIGRATION - Notes Field Migration
// ================================================================
// This script runs the ACTUAL migration.
// ContentNotes will be created and linked to Candidates.
// Notes__c field will be preserved (not deleted).
// ================================================================

System.debug('========================================');
System.debug('NOTES FIELD MIGRATION - REAL RUN');
System.debug('========================================');
System.debug('');

// Count candidates with Notes__c populated (before migration)
Integer candidatesWithNotes = [
    SELECT COUNT() 
    FROM Candidate__c 
    WHERE Notes__c != null 
    AND Notes__c != ''
];

System.debug('Candidates with populated Notes__c field: ' + candidatesWithNotes);
System.debug('');

// Count existing ContentDocumentLinks for Candidates (before migration)
Integer existingLinks = [
    SELECT COUNT() 
    FROM ContentDocumentLink 
    WHERE LinkedEntity.Type = 'Candidate__c'
];

System.debug('Existing ContentDocumentLinks for Candidates: ' + existingLinks);
System.debug('');

// Confirm execution
System.debug('IMPORTANT: This will create ' + candidatesWithNotes + ' ContentNotes.');
System.debug('Migration Date: ' + Datetime.now().format('MM/dd/yyyy'));
System.debug('Title Format: Legacy Note - Migrated MM/dd/yyyy');
System.debug('');

// Execute batch in real mode
System.debug('Starting batch job in REAL RUN mode...');
System.debug('Batch size: 100 records per execution');
System.debug('');

NotesFieldMigrationBatch batch = new NotesFieldMigrationBatch(false); // false = real run
Id batchJobId = Database.executeBatch(batch, 100);

System.debug('Batch Job ID: ' + batchJobId);
System.debug('');
System.debug('Monitor progress with:');
System.debug('Run: check-notes-migration-status.apex');
System.debug('');
System.debug('If issues found, rollback with:');
System.debug('Run: rollback-notes-migration.apex');
System.debug('========================================');
