public with sharing class CaseEmailController {
    public class EmailDTO {
        @AuraEnabled public Id id;
        @AuraEnabled public String subject;
        @AuraEnabled public String fromAddress;
        @AuraEnabled public String toAddress;
        @AuraEnabled public Datetime messageDate;
        @AuraEnabled public String htmlBody;
        @AuraEnabled public String textBody;
    }

    @AuraEnabled(cacheable=true)
    public static List<EmailDTO> getEmails(Id caseId, Integer limitSize) {
        if (caseId == null) return new List<EmailDTO>();
        Integer lim = (limitSize == null || limitSize <= 0) ? 50 : Math.min(limitSize, 200);
        List<EmailDTO> out = new List<EmailDTO>();
        for (EmailMessage em : [
            SELECT Id, Subject, FromAddress, ToAddress, MessageDate, HtmlBody, TextBody
            FROM EmailMessage
            WHERE ParentId = :caseId
            ORDER BY MessageDate DESC
            LIMIT :lim
        ]) {
            EmailDTO dto = new EmailDTO();
            dto.id = em.Id;
            dto.subject = em.Subject;
            dto.fromAddress = em.FromAddress;
            dto.toAddress = em.ToAddress;
            dto.messageDate = em.MessageDate;
            dto.htmlBody = em.HtmlBody;
            dto.textBody = em.TextBody;
            out.add(dto);
        }
        return out;
    }

    @AuraEnabled
    public static void sendEmail(Id caseId, String toCsv, String ccCsv, String bccCsv, String subject, String htmlBody, Id orgWideEmailId) {
        if (caseId == null) {
            throw new AuraHandledException('Missing Case Id');
        }
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        if (String.isNotBlank(toCsv)) {
            msg.setToAddresses(splitCsv(toCsv));
        }
        if (String.isNotBlank(ccCsv)) {
            msg.setCcAddresses(splitCsv(ccCsv));
        }
        if (String.isNotBlank(bccCsv)) {
            msg.setBccAddresses(splitCsv(bccCsv));
        }
        msg.setSubject(subject);
        if (String.isNotBlank(htmlBody)) {
            msg.setHtmlBody(htmlBody);
        } else {
            msg.setPlainTextBody('');
        }
        msg.setWhatId(caseId);
        msg.setSaveAsActivity(true);
        if (orgWideEmailId != null) {
            msg.setOrgWideEmailAddressId(orgWideEmailId);
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { msg });
    }

    private static List<String> splitCsv(String csv) {
        List<String> out = new List<String>();
        for (String s : csv.split('[,;]')) {
            String t = s != null ? s.trim() : null;
            if (String.isNotBlank(t)) out.add(t);
        }
        return out;
    }
}
