public with sharing class EncryptedDeviceController {
    public class DeviceDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String name;
        @AuraEnabled public Datetime createdDate;
        @AuraEnabled public Datetime lastModifiedDate;
    }

    @AuraEnabled(cacheable=true)
    public static List<DeviceDTO> getForCase(Id caseId, Integer limitSize) {
        if (caseId == null) return new List<DeviceDTO>();
        Integer lim = (limitSize == null || limitSize <= 0) ? 50 : Math.min(limitSize, 200);
        Case c = [SELECT ContactId FROM Case WHERE Id = :caseId LIMIT 1];
        if (c.ContactId == null) return new List<DeviceDTO>();
        List<DeviceDTO> out = new List<DeviceDTO>();
        for (Encrypted_Device__c d : [
            SELECT Id, Name, CreatedDate, LastModifiedDate
            FROM Encrypted_Device__c
            WHERE (Contact__c = :c.ContactId OR Contact_Lookup__c = :c.ContactId)
            ORDER BY LastModifiedDate DESC
            LIMIT :lim
        ]) {
            DeviceDTO dto = new DeviceDTO();
            dto.id = d.Id;
            dto.name = d.Name;
            dto.createdDate = d.CreatedDate;
            dto.lastModifiedDate = d.LastModifiedDate;
            out.add(dto);
        }
        return out;
    }
}
