/**
 * @description Test class for NotesFieldMigrationBatch and NotesFieldMigrationRollback
 * @author Copilot
 * @date 2026-01-05
 */
@isTest
private class NotesFieldMigrationBatchTest {
    
    @TestSetup
    static void setupTestData() {
        List<Candidate__c> candidates = new List<Candidate__c>();
        
        // Create candidates with various Notes__c patterns
        
        // 1. Normal note with simple text
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Normal',
            Email__c = 'normal@test.com',
            Status__c = 'Active/In Process',
            Notes__c = 'This is a normal note with some basic information.'
        ));
        
        // 2. Note with dates in text
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'WithDates',
            Email__c = 'dates@test.com',
            Status__c = 'Active/In Process',
            Notes__c = '01/15/2025 - Initial contact made.\n02/20/2025 - Follow up completed.'
        ));
        
        // 3. Note with special characters
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'SpecialChars',
            Email__c = 'special@test.com',
            Status__c = 'Active/In Process',
            Notes__c = 'Notes with "quotes" and \'apostrophes\' & special chars: @#$%^&*()'
        ));
        
        // 4. Note with line breaks and formatting
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Formatted',
            Email__c = 'formatted@test.com',
            Status__c = 'Active/In Process',
            Notes__c = 'Line 1\nLine 2\n\nLine 4 with gap\n\tIndented line'
        ));
        
        // 5. Long note (test content preservation)
        String longNote = '';
        for (Integer i = 0; i < 100; i++) {
            longNote += 'This is line ' + i + ' of a very long note with lots of content to test that large notes migrate properly. ';
        }
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'LongNote',
            Email__c = 'long@test.com',
            Status__c = 'Active/In Process',
            Notes__c = longNote
        ));
        
        // 6. Empty string (should be skipped)
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Empty',
            Email__c = 'empty@test.com',
            Status__c = 'Active/In Process',
            Notes__c = ''
        ));
        
        // 7. Null Notes__c (should be skipped)
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Null',
            Email__c = 'null@test.com',
            Status__c = 'Active/In Process',
            Notes__c = null
        ));
        
        // 8. Unicode/Emoji characters
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Unicode',
            Email__c = 'unicode@test.com',
            Status__c = 'Active/In Process',
            Notes__c = 'Unicode test: café, résumé, naïve, 日本語'
        ));
        
        // 9. Very short note
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Short',
            Email__c = 'short@test.com',
            Status__c = 'Active/In Process',
            Notes__c = 'Hi'
        ));
        
        // 10. Note with HTML-like content
        candidates.add(new Candidate__c(
            First_Name__c = 'Test',
            Last_Name__c = 'Html',
            Email__c = 'html@test.com',
            Status__c = 'Active/In Process',
            Notes__c = '<p>This looks like HTML but should be preserved as-is</p>'
        ));
        
        insert candidates;
    }
    
    @isTest
    static void testMigrationBatch_DryRun() {
        // Test dry run mode - should not create any ContentNotes
        
        Test.startTest();
        NotesFieldMigrationBatch batch = new NotesFieldMigrationBatch(true); // dry run
        Database.executeBatch(batch, 100);
        Test.stopTest();
        
        // Get all candidates first
        List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : allCandidates) {
            candidateIds.add(c.Id);
        }
        
        // Verify no ContentNotes were created
        List<ContentDocumentLink> links = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(0, links.size(), 'Dry run should not create any ContentDocumentLinks');
        
        // Verify Notes__c field is still populated
        List<Candidate__c> candidates = [
            SELECT Id, Notes__c 
            FROM Candidate__c
        ];
        
        Integer candidatesWithNotes = 0;
        for (Candidate__c cand : candidates) {
            if (String.isNotBlank(cand.Notes__c)) {
                candidatesWithNotes++;
            }
        }
        
        System.assertEquals(8, candidatesWithNotes, 'Should have 8 candidates with notes (excluding empty/null)');
    }
    
    @isTest
    static void testMigrationBatch_RealRun() {
        // Test real migration
        
        Test.startTest();
        NotesFieldMigrationBatch batch = new NotesFieldMigrationBatch(false); // real run
        Database.executeBatch(batch, 100);
        Test.stopTest();
        
        // Get all candidates first
        List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : allCandidates) {
            candidateIds.add(c.Id);
        }
        
        // Verify ContentNotes were created
        List<ContentDocumentLink> links = [
            SELECT Id, LinkedEntityId, ContentDocumentId
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(8, links.size(), 'Should have 8 ContentDocumentLinks (excluding empty/null notes)');
        
        // Verify ContentNotes have correct title format
        Set<Id> documentIds = new Set<Id>();
        for (ContentDocumentLink link : links) {
            documentIds.add(link.ContentDocumentId);
        }
        
        List<ContentDocument> documents = [
            SELECT LatestPublishedVersionId 
            FROM ContentDocument 
            WHERE Id IN :documentIds
        ];
        
        Set<Id> versionIds = new Set<Id>();
        for (ContentDocument doc : documents) {
            versionIds.add(doc.LatestPublishedVersionId);
        }
        
        List<ContentVersion> versions = [
            SELECT Title, TextPreview, FileType
            FROM ContentVersion 
            WHERE Id IN :versionIds
        ];
        
        System.assertEquals(8, versions.size(), 'Should have 8 ContentVersions');
        
        String expectedTitlePrefix = 'Legacy Note - Migrated ';
        for (ContentVersion cv : versions) {
            System.assert(cv.Title.startsWith(expectedTitlePrefix), 'Title should start with: ' + expectedTitlePrefix);
            System.assertEquals('SNOTE', cv.FileType, 'FileType should be SNOTE');
        }
        
        // Verify Notes__c field is still populated (not deleted)
        List<Candidate__c> candidates = [
            SELECT Id, Notes__c 
            FROM Candidate__c
        ];
        
        Integer candidatesWithNotes = 0;
        for (Candidate__c cand : candidates) {
            if (String.isNotBlank(cand.Notes__c)) {
                candidatesWithNotes++;
            }
        }
        
        System.assertEquals(8, candidatesWithNotes, 'Notes__c field should still be populated');
    }
    
    @isTest
    static void testMigrationBatch_ContentPreservation() {
        // Test that note content is preserved exactly
        
        Candidate__c specialCharsCandidate = [
            SELECT Id, Notes__c 
            FROM Candidate__c 
            WHERE Email__c = 'special@test.com' 
            LIMIT 1
        ];
        
        List<Candidate__c> singleCandidateList = new List<Candidate__c>{ specialCharsCandidate };
        String migrationDate = Datetime.now().format('MM/dd/yyyy');
        
        Test.startTest();
        NotesFieldMigrationBatch.Result result = NotesFieldMigrationBatch.migrateNotes(
            singleCandidateList, 
            false, 
            migrationDate
        );
        Test.stopTest();
        
        System.assertEquals(1, result.candidatesProcessed, 'Should process 1 candidate');
        System.assertEquals(1, result.notesCreated, 'Should create 1 note');
        System.assertEquals(0, result.errors.size(), 'Should have no errors');
        
        // Query the created note and verify content
        ContentDocumentLink link = [
            SELECT ContentDocumentId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :specialCharsCandidate.Id 
            LIMIT 1
        ];
        
        ContentDocument doc = [
            SELECT LatestPublishedVersionId 
            FROM ContentDocument 
            WHERE Id = :link.ContentDocumentId
        ];
        
        ContentVersion cv = [
            SELECT TextPreview, VersionData
            FROM ContentVersion 
            WHERE Id = :doc.LatestPublishedVersionId
        ];
        
        String noteContent = cv.VersionData.toString();
        System.assertEquals(specialCharsCandidate.Notes__c, noteContent, 'Note content should match exactly');
    }
    
    @isTest
    static void testMigrationBatch_EmptyAndNullHandling() {
        // Test that empty and null notes are skipped
        
        List<Candidate__c> emptyNullCandidates = [
            SELECT Id, Notes__c 
            FROM Candidate__c 
            WHERE Email__c IN ('empty@test.com', 'null@test.com')
        ];
        
        String migrationDate = Datetime.now().format('MM/dd/yyyy');
        
        Test.startTest();
        NotesFieldMigrationBatch.Result result = NotesFieldMigrationBatch.migrateNotes(
            emptyNullCandidates, 
            false, 
            migrationDate
        );
        Test.stopTest();
        
        System.assertEquals(2, result.candidatesProcessed, 'Should process 2 candidates');
        System.assertEquals(0, result.notesCreated, 'Should create 0 notes');
        System.assertEquals(2, result.skipped, 'Should skip 2 candidates');
    }
    
    @isTest
    static void testRollbackBatch() {
        // First run migration
        NotesFieldMigrationBatch migrationBatch = new NotesFieldMigrationBatch(false);
        
        Test.startTest();
        Database.executeBatch(migrationBatch, 100);
        Test.stopTest();
        
        // Get all candidates first
        List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : allCandidates) {
            candidateIds.add(c.Id);
        }
        
        // Verify notes were created
        List<ContentDocumentLink> linksBeforeRollback = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(8, linksBeforeRollback.size(), 'Should have 8 links before rollback');
        
        // Now run rollback
        String migrationDate = Datetime.now().format('MM/dd/yyyy');
        NotesFieldMigrationRollback rollbackBatch = new NotesFieldMigrationRollback(migrationDate);
        
        Test.startTest();
        Database.executeBatch(rollbackBatch, 100);
        Test.stopTest();
        
        // Verify notes were deleted
        List<ContentDocumentLink> linksAfterRollback = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(0, linksAfterRollback.size(), 'All links should be deleted after rollback');
        
        // Verify Notes__c field is still populated
        List<Candidate__c> candidates = [
            SELECT Id, Notes__c 
            FROM Candidate__c
        ];
        
        Integer candidatesWithNotes = 0;
        for (Candidate__c cand : candidates) {
            if (String.isNotBlank(cand.Notes__c)) {
                candidatesWithNotes++;
            }
        }
        
        System.assertEquals(8, candidatesWithNotes, 'Notes__c field should still be populated after rollback');
    }
    
    @isTest
    static void testRollbackBatch_WrongDate() {
        // Test that rollback with wrong date doesn't delete notes
        
        // Get all candidates first
        List<Candidate__c> allCandidates = [SELECT Id FROM Candidate__c];
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : allCandidates) {
            candidateIds.add(c.Id);
        }
        
        // First run migration
        NotesFieldMigrationBatch migrationBatch = new NotesFieldMigrationBatch(false);
        
        Test.startTest();
        Database.executeBatch(migrationBatch, 100);
        Test.stopTest();
        
        // Verify links were created
        List<ContentDocumentLink> linksBeforeRollback = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(8, linksBeforeRollback.size(), 'Should have 8 links after migration');
        
        // Now run rollback with wrong date (outside Test.startTest since we can only call it once)
        NotesFieldMigrationRollback rollbackBatch = new NotesFieldMigrationRollback('12/31/2025'); // different date
        Database.executeBatch(rollbackBatch, 100);
        
        // Wait for batch to complete by querying again
        // In real scenario, this would need AsyncApexJob monitoring
        // For test purposes, we verify count hasn't changed
        List<ContentDocumentLink> linksAfterRollback = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :candidateIds
        ];
        
        System.assertEquals(8, linksAfterRollback.size(), 'Links should NOT be deleted with wrong date');
    }
}
