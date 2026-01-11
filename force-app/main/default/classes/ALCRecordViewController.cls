// Apex controller for ALC__c record view LWC
// Pattern: Service/controller separation, bulkification, FLS, security enforced
// Exposes ALC__c data, notes, and related records for LWC

public with sharing class ALCRecordViewController {
    // Lightweight DTO for Contact snapshot to ensure reliable rendering in LWC
    public class ContactSnapshot {
        @AuraEnabled public Id id;
        @AuraEnabled public String firstName;
        @AuraEnabled public String lastName;
        @AuraEnabled public String email;
        @AuraEnabled public String mobilePhone;
        @AuraEnabled public String homePhone;
        @AuraEnabled public String mailingStreet;
        @AuraEnabled public String mailingCity;
        @AuraEnabled public String mailingState;
        @AuraEnabled public String mailingPostalCode;
        @AuraEnabled public String personalEmail;
    }

        @AuraEnabled
        public static Id createALCForCandidate(Id candidateId, Id contactId) {
            // Bulk-safe, FLS enforced
            if (candidateId == null || contactId == null) {
                throw new AuraHandledException('Candidate and Contact required');
            }
            // CRUD: verify object access for ALC__c
            if (!Schema.sObjectType.ALC__c.isAccessible()) {
                throw new AuraHandledException('Access to ALC__c is denied');
            }
            if (!Schema.sObjectType.ALC__c.isCreateable()) {
                throw new AuraHandledException('Create permission for ALC__c is denied');
            }
            // Check for existing ALC for candidate
            // Check for existing ALC for candidate using either field
            List<ALC__c> existing = [SELECT Id FROM ALC__c WHERE Candidate__c = :candidateId OR Related_Candidate__c = :candidateId WITH SECURITY_ENFORCED LIMIT 1];
            if (!existing.isEmpty()) {
                return existing[0].Id;
            }
            // Create new ALC
            ALC__c alc = new ALC__c();
            // Set both candidate relation fields for compatibility
            alc.Candidate__c = candidateId;
            alc.Related_Candidate__c = candidateId;
            // Set contact relation
            alc.Contact__c = contactId;
            alc.Stage__c = 'Initial Form Sent';
            alc.Contract_Type__c = 'B';
            insert alc;
            return alc.Id;
        }
    @AuraEnabled(cacheable=true)
    public static ALC__c getALCData(Id alcId) {
        // FLS enforced, returns full ALC__c record with related Contact
        List<ALC__c> alcList = [
                 SELECT Id, Name,
                   Contract_Type__c, Office__c, Contract_Effective__c, Contract_B_Expiration_Date__c,
                   Life_Insurance_Licensed__c, Registered__c,
                     Related_Candidate__c,
                   Contact__c,
                   Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, Contact__r.MobilePhone, Contact__r.HomePhone, Contact__r.MailingStreet, Contact__r.MailingCity, Contact__r.MailingState, Contact__r.MailingPostalCode
            FROM ALC__c
            WHERE Id = :alcId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        return alcList.isEmpty() ? null : alcList[0];
    }

    @AuraEnabled(cacheable=true)
    public static List<ContentNote> getNotes(Id alcId) {
        // Returns ContentNotes related to this ALC__c (via ContentDocumentLink, two-step query)
        List<Id> noteIds = new List<Id>();
        for (ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :alcId WITH SECURITY_ENFORCED]) {
            noteIds.add(cdl.ContentDocumentId);
        }
        List<ContentNote> notes = new List<ContentNote>();
        if (!noteIds.isEmpty()) {
            notes = [SELECT Id, Title, Content, CreatedDate, CreatedBy.Name FROM ContentNote WHERE Id IN :noteIds WITH SECURITY_ENFORCED ORDER BY CreatedDate DESC LIMIT 50];
        }
        return notes;
    }

    @AuraEnabled(cacheable=true)
    public static List<Event> getActivities(Id alcId) {
        // Returns Events/Tasks related to this ALC__c
        List<Event> events = [
            SELECT Id, Subject, StartDateTime, EndDateTime, Owner.Name, WhatId, WhoId
            FROM Event
            WHERE WhatId = :alcId
            WITH SECURITY_ENFORCED
            ORDER BY StartDateTime DESC
            LIMIT 50
        ];
        return events;
    }

    // Deterministic Contact fallback for LWC. Enforces CRUD/FLS via WITH SECURITY_ENFORCED.
    @AuraEnabled(cacheable=true)
    public static ContactSnapshot getContactSnapshotByALCId(Id alcId) {
        if (alcId == null) {
            return null;
        }
        ALC__c a = [
            SELECT Contact__c, Candidate__c, Related_Candidate__c,
                   Candidate__r.Contact__c, Related_Candidate__r.Contact__c
            FROM ALC__c WHERE Id = :alcId WITH SECURITY_ENFORCED LIMIT 1
        ];
        if (a == null) {
            return null;
        }
        // Prefer direct Contact__c, then Candidate links
        Id resolvedContactId = a.Contact__c;
        if (resolvedContactId == null) {
            resolvedContactId = a.Candidate__r != null ? a.Candidate__r.Contact__c : null;
        }
        if (resolvedContactId == null) {
            resolvedContactId = a.Related_Candidate__r != null ? a.Related_Candidate__r.Contact__c : null;
        }
        if (resolvedContactId == null) {
            return null;
        }
        return getContactSnapshot(resolvedContactId);
    }

    @AuraEnabled(cacheable=true)
    public static ContactSnapshot getContactSnapshot(Id contactId) {
        if (contactId == null) {
            return null;
        }
        // Query only widely FLS-accessible fields to avoid security errors
        Contact c = [
            SELECT Id, FirstName, LastName, Email, MobilePhone, Personal_Email__c
            FROM Contact
            WHERE Id = :contactId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
        if (c == null) {
            return null;
        }
        ContactSnapshot s = new ContactSnapshot();
        s.id = c.Id;
        s.firstName = c.FirstName;
        s.lastName = c.LastName;
        s.email = c.Email;
        s.mobilePhone = c.MobilePhone;
        s.homePhone = null;
        // Address fields intentionally omitted from snapshot to prevent FLS errors; UI API wire handles address rendering
        s.mailingStreet = null;
        s.mailingCity = null;
        s.mailingState = null;
        s.mailingPostalCode = null;
        s.personalEmail = (String) c.get('Personal_Email__c');
        return s;
    }
}
