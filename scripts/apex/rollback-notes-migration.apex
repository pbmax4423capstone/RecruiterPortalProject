// ================================================================
// ROLLBACK - Notes Field Migration
// ================================================================
// Delete migrated ContentNotes if issues are found
// Notes__c field data will NOT be affected (preserved)
// ================================================================

System.debug('========================================');
System.debug('NOTES FIELD MIGRATION - ROLLBACK');
System.debug('========================================');
System.debug('');

// Get today's date in MM/dd/yyyy format
String migrationDate = Datetime.now().format('MM/dd/yyyy');

System.debug('Target Migration Date: ' + migrationDate);
System.debug('Title Pattern: Legacy Note - Migrated ' + migrationDate);
System.debug('');

// Count ContentNotes to be deleted
String titlePattern = 'Legacy Note - Migrated ' + migrationDate;
List<ContentVersion> notesToDelete = [
    SELECT Id, Title
    FROM ContentVersion 
    WHERE FileType = 'SNOTE' 
    AND Title = :titlePattern
];

System.debug('ContentNotes to be deleted: ' + notesToDelete.size());
System.debug('');

if (notesToDelete.isEmpty()) {
    System.debug('No notes found matching the migration date pattern.');
    System.debug('');
    System.debug('Possible reasons:');
    System.debug('1. Migration has not been run yet');
    System.debug('2. Migration was run on a different date');
    System.debug('3. Notes have already been rolled back');
    System.debug('');
    System.debug('To rollback notes from a different date, modify this script');
    System.debug('and change the migrationDate variable to the target date.');
} else {
    System.debug('IMPORTANT: This will DELETE ' + notesToDelete.size() + ' ContentNotes.');
    System.debug('The Notes__c field on Candidate records will NOT be affected.');
    System.debug('Original data will remain preserved in Notes__c field.');
    System.debug('');
    
    // Execute rollback batch
    System.debug('Starting rollback batch job...');
    System.debug('Batch size: 100 records per execution');
    System.debug('');
    
    NotesFieldMigrationRollback rollbackBatch = new NotesFieldMigrationRollback(migrationDate);
    Id batchJobId = Database.executeBatch(rollbackBatch, 100);
    
    System.debug('Rollback Batch Job ID: ' + batchJobId);
    System.debug('');
    System.debug('Monitor progress with:');
    System.debug('Run: check-notes-migration-status.apex');
}

System.debug('========================================');
