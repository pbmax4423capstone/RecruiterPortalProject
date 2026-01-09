/**
 * Trigger handler for ALC__c object
 * Automatically creates Contact and Candidate relationships on insert
 * 
 * @group ALC Automation
 * @date 2026-01-08
 */
public class ALCRelationshipTriggerHandler {
    
    /**
     * Handle before insert trigger logic
     * @param newALCs List of new ALC records
     */
    public static void handleBeforeInsert(List<ALC__c> newALCs) {
        // Get record type map for Career type detection
        Map<Id, String> recordTypeIdToName = new Map<Id, String>();
        for (RecordType rt : [SELECT Id, DeveloperName FROM RecordType WHERE SObjectType = 'ALC__c']) {
            recordTypeIdToName.put(rt.Id, rt.DeveloperName);
        }
        
        // Collect data for bulk Contact/Candidate queries
        Set<String> emails = new Set<String>();
        Set<String> phones = new Set<String>();
        Set<String> lastNames = new Set<String>();
        
        for (ALC__c alc : newALCs) {
            if (alc.Contact__c == null) {
                if (String.isNotBlank(alc.Personal_Email_Address__c)) {
                    emails.add(alc.Personal_Email_Address__c.toLowerCase());
                }
                if (String.isNotBlank(alc.Mobile__c)) {
                    phones.add(standardizePhone(alc.Mobile__c));
                }
                if (String.isNotBlank(alc.Last_Name__c)) {
                    lastNames.add(alc.Last_Name__c);
                }
            }
        }
        
        // Bulk query existing Contacts to avoid duplicates
        Map<String, Contact> emailToContact = new Map<String, Contact>();
        Map<String, Contact> phoneToContact = new Map<String, Contact>();
        
        if (!emails.isEmpty() || !phones.isEmpty()) {
            List<Contact> existingContacts = [
                SELECT Id, Email, Personal_Email__c, MobilePhone
                FROM Contact
                WHERE Email IN :emails 
                OR Personal_Email__c IN :emails
                OR MobilePhone IN :phones
            ];
            
            for (Contact c : existingContacts) {
                if (String.isNotBlank(c.Email)) {
                    emailToContact.put(c.Email.toLowerCase(), c);
                }
                if (String.isNotBlank(c.Personal_Email__c)) {
                    emailToContact.put(c.Personal_Email__c.toLowerCase(), c);
                }
                if (String.isNotBlank(c.MobilePhone)) {
                    String stdPhone = standardizePhone(c.MobilePhone);
                    if (stdPhone != null) {
                        phoneToContact.put(stdPhone, c);
                    }
                }
            }
        }
        
        // Query existing Candidates for Contacts that were found
        Map<Id, Id> contactToCandidateId = new Map<Id, Id>();
        Set<Id> contactIds = new Set<Id>();
        for (Contact c : emailToContact.values()) {
            contactIds.add(c.Id);
        }
        for (Contact c : phoneToContact.values()) {
            contactIds.add(c.Id);
        }
        
        if (!contactIds.isEmpty()) {
            for (Candidate__c cand : [SELECT Id, Contact__c FROM Candidate__c WHERE Contact__c IN :contactIds]) {
                contactToCandidateId.put(cand.Contact__c, cand.Id);
            }
        }
        
        // Process each ALC
        List<Contact> contactsToInsert = new List<Contact>();
        List<Candidate__c> candidatesToInsert = new List<Candidate__c>();
        List<ALC__c> alcsWithExistingContactNeedingCandidate = new List<ALC__c>();
        Map<Integer, ALC__c> indexToALC = new Map<Integer, ALC__c>();
        Map<Integer, Boolean> indexNeedsCandidate = new Map<Integer, Boolean>();
        
        Integer index = 0;
        for (ALC__c alc : newALCs) {
            // Skip if already has Contact
            if (alc.Contact__c != null) {
                continue;
            }
            
            // Try to find existing Contact
            Contact existingContact = null;
            if (String.isNotBlank(alc.Personal_Email_Address__c)) {
                existingContact = emailToContact.get(alc.Personal_Email_Address__c.toLowerCase());
            }
            if (existingContact == null && String.isNotBlank(alc.Mobile__c)) {
                String stdPhone = standardizePhone(alc.Mobile__c);
                if (stdPhone != null) {
                    existingContact = phoneToContact.get(stdPhone);
                }
            }
            
            if (existingContact != null) {
                // Link to existing Contact
                alc.Contact__c = existingContact.Id;
                
                // Check if Contact has Candidate, if not and this is Career type, create one
                String recordTypeName = recordTypeIdToName.get(alc.RecordTypeId);
                if (recordTypeName == 'Career' && alc.Candidate__c == null) {
                    Id existingCandidateId = contactToCandidateId.get(existingContact.Id);
                    if (existingCandidateId != null) {
                        // Link to existing Candidate
                        alc.Candidate__c = existingCandidateId;
                    } else {
                        // Need to create Candidate for existing Contact
                        alcsWithExistingContactNeedingCandidate.add(alc);
                    }
                }
            } else {
                // Create new Contact
                Contact newContact = new Contact();
                newContact.FirstName = alc.First_Name__c;
                newContact.LastName = alc.Last_Name__c != null ? alc.Last_Name__c : 'Unknown';
                newContact.Personal_Email__c = alc.Personal_Email_Address__c;
                newContact.MobilePhone = alc.Mobile__c;
                
                contactsToInsert.add(newContact);
                indexToALC.put(index, alc);
                
                // Check if needs Candidate (Career type only)
                String recordTypeName = recordTypeIdToName.get(alc.RecordTypeId);
                if (recordTypeName == 'Career' && alc.Candidate__c == null) {
                    indexNeedsCandidate.put(index, true);
                }
                
                index++;
            }
        }
        
        // Insert Contacts
        if (!contactsToInsert.isEmpty()) {
            try {
                insert contactsToInsert;
                
                // Link ALCs to new Contacts and create Candidates for Career types
                for (Integer i = 0; i < contactsToInsert.size(); i++) {
                    ALC__c alc = indexToALC.get(i);
                    Contact newContact = contactsToInsert[i];
                    alc.Contact__c = newContact.Id;
                    
                    // Create Candidate for Career type
                    if (indexNeedsCandidate.containsKey(i)) {
                        Candidate__c newCandidate = new Candidate__c();
                        newCandidate.First_Name__c = alc.First_Name__c;
                        newCandidate.Last_Name__c = alc.Last_Name__c;
                        newCandidate.personal_email__c = alc.Personal_Email_Address__c;
                        newCandidate.Phone__c = alc.Mobile__c;
                        newCandidate.Contact__c = newContact.Id;
                        newCandidate.Status__c = 'Contract Sent';
                        
                        candidatesToInsert.add(newCandidate);
                    }
                }
                
                // Insert Candidates
                if (!candidatesToInsert.isEmpty()) {
                    insert candidatesToInsert;
                    
                    // Link ALCs to new Candidates
                    Integer candidateIndex = 0;
                    for (Integer i = 0; i < contactsToInsert.size(); i++) {
                        if (indexNeedsCandidate.containsKey(i)) {
                            ALC__c alc = indexToALC.get(i);
                            alc.Candidate__c = candidatesToInsert[candidateIndex].Id;
                            candidateIndex++;
                        }
                    }
                }
                
                // Create Candidates for existing Contacts that need them
                if (!alcsWithExistingContactNeedingCandidate.isEmpty()) {
                    List<Candidate__c> candidatesForExistingContacts = new List<Candidate__c>();
                    for (ALC__c alc : alcsWithExistingContactNeedingCandidate) {
                        Candidate__c newCandidate = new Candidate__c();
                        newCandidate.First_Name__c = alc.First_Name__c;
                        newCandidate.Last_Name__c = alc.Last_Name__c;
                        newCandidate.personal_email__c = alc.Personal_Email_Address__c;
                        newCandidate.Phone__c = alc.Mobile__c;
                        newCandidate.Contact__c = alc.Contact__c;
                        newCandidate.Status__c = 'Contract Sent';
                        candidatesForExistingContacts.add(newCandidate);
                    }
                    
                    if (!candidatesForExistingContacts.isEmpty()) {
                        insert candidatesForExistingContacts;
                        
                        // Link ALCs to their new Candidates
                        for (Integer i = 0; i < alcsWithExistingContactNeedingCandidate.size(); i++) {
                            alcsWithExistingContactNeedingCandidate[i].Candidate__c = candidatesForExistingContacts[i].Id;
                        }
                    }
                }
                
                // Create audit log asynchronously
                Integer totalCandidates = candidatesToInsert.size() + (alcsWithExistingContactNeedingCandidate != null ? alcsWithExistingContactNeedingCandidate.size() : 0);
                createAuditLogAsync(contactsToInsert.size(), totalCandidates, 'Auto-created via trigger');
                
            } catch (DmlException e) {
                // Log error asynchronously
                createErrorLogAsync('Trigger Insert Error', e.getMessage(), e.getStackTraceString());
            }
        }
    }
    
    /**
     * Standardize phone number to 10-digit format
     */
    private static String standardizePhone(String phone) {
        if (String.isBlank(phone)) {
            return null;
        }
        
        String digitsOnly = phone.replaceAll('[^0-9]', '');
        
        if (digitsOnly.length() == 11 && digitsOnly.startsWith('1')) {
            digitsOnly = digitsOnly.substring(1);
        }
        
        return digitsOnly.length() == 10 ? digitsOnly : null;
    }
    
    /**
     * Create success audit log asynchronously
     */
    @future
    private static void createAuditLogAsync(Integer contactsCreated, Integer candidatesCreated, String operation) {
        try {
            ALC_Automation_Log__c log = new ALC_Automation_Log__c();
            log.Operation_Type__c = operation;
            log.Success__c = true;
            log.Error_Message__c = String.format('Created {0} Contacts and {1} Candidates', 
                new List<Object>{contactsCreated, candidatesCreated});
            insert log;
        } catch (Exception e) {
            System.debug('Failed to create audit log: ' + e.getMessage());
        }
    }
    
    /**
     * Create error audit log asynchronously
     */
    @future
    private static void createErrorLogAsync(String errorType, String errorMessage, String stackTrace) {
        try {
            ALC_Automation_Log__c log = new ALC_Automation_Log__c();
            log.Operation_Type__c = 'Auto-create via trigger';
            log.Success__c = false;
            log.Error_Type__c = errorType;
            log.Error_Message__c = errorMessage;
            log.Stack_Trace__c = stackTrace;
            insert log;
        } catch (Exception e) {
            System.debug('Failed to create error log: ' + e.getMessage());
        }
    }
}
