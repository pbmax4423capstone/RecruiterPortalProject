/**
 * Controller for Summary Card Metrics Lightning Web Component
 * 
 * Phase 1: Stub implementation with method signatures
 * Phase 2: Implement real data queries following RecruiterDashboardController patterns
 * 
 * @author Recruiter Portal Development Team
 * @date 2025-12-23
 */
public without sharing class SummaryCardMetricsController {
    
    /**
     * Retrieves current user's full name for Sales Manager filtering
     * 
     * @return String Current user's full name
     */
    private static String getCurrentUserName() {
        return [SELECT Name FROM User WHERE Id = :UserInfo.getUserId()].Name;
    }
    
    /**
     * Retrieves summary metrics for the current user's recruiting dashboard
     * 
     * Queries Candidate__c and Interview__c for user-specific metrics
     * All counts are filtered by OwnerId = current user
     * 
     * @return Map<String, Object> containing metric values
     *   {
     *     totalCandidates: Integer,
     *     upcomingInterviews: Integer,
     *     activePipeline: Integer,
     *     onContractB: Integer,
     *     hiredThisMonth: Integer,
     *     interviewRate: Decimal
     *   }
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getMetrics() {
        Map<String, Object> metrics = new Map<String, Object>();
        Id currentUserId = UserInfo.getUserId();
        String currentUserName = getCurrentUserName();
        
        try {
            // Total Candidates - All candidates assigned to current user as Sales Manager
            Integer totalCandidates = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Sales_Manager__c = :currentUserName
            ];
            metrics.put('totalCandidates', totalCandidates);
            
            // Upcoming Interviews - Scheduled interviews with future dates for current user's candidates
            Integer upcomingInterviews = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE Interview_Status__c = 'Scheduled' 
                AND Date_Time_Scheduled__c >= TODAY
                AND Candidate__r.OwnerId = :currentUserId
            ];
            metrics.put('upcomingInterviews', upcomingInterviews);
            
            // Active Pipeline - Candidates with status Active/In Process assigned to current user as Sales Manager
            Integer activePipeline = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Sales_Manager__c = :currentUserName 
                AND Status__c = 'Active/In Process'
            ];
            metrics.put('activePipeline', activePipeline);
            
            // On Contract B - Candidates at Contracting Complete stage with Contract Type B
            Integer onContractB = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Candidate__r.Sales_Manager__c = :currentUserName 
                AND Contract_Type__c = 'B'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractB', onContractB);
            
            // On Contract A - Candidates at Contracting Complete stage with Contract Type A
            Integer onContractA = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Candidate__r.Sales_Manager__c = :currentUserName 
                AND Contract_Type__c = 'A'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractA', onContractA);
            
            // Hired This Month - Candidates hired during current calendar month
            // Using ALC Stage change to 'Contracted' or 'COMPLETE' this month
            Integer hiredThisMonth = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Candidate__r.OwnerId = :currentUserId 
                AND Stage__c IN ('Contracted', 'COMPLETE')
                AND LastModifiedDate = THIS_MONTH
            ];
            metrics.put('hiredThisMonth', hiredThisMonth);
            
            // Completed Interviews This Month - All completed interviews in current month
            Integer completedInterviewsThisMonth = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE Candidate__r.OwnerId = :currentUserId 
                AND Interview_Status__c = 'Completed'
                AND Date_Completed__c = THIS_MONTH
            ];
            metrics.put('completedInterviewsThisMonth', completedInterviewsThisMonth);
            
        } catch (Exception e) {
            System.debug('Error in getMetrics: ' + e.getMessage());
            // Return zeros on error
            metrics.put('totalCandidates', 0);
            metrics.put('upcomingInterviews', 0);
            metrics.put('activePipeline', 0);
            metrics.put('onContractB', 0);
            metrics.put('onContractA', 0);
            metrics.put('hiredThisMonth', 0);
            metrics.put('completedInterviewsThisMonth', 0);
        }
        
        return metrics;
    }
    
    /**
     * Retrieves detailed list of all candidates owned by current user
     * Used for drill-down modal display
     * 
     * @return List<Map<String, Object>> list of candidate records with relevant fields
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCandidatesList() {
        List<Map<String, Object>> candidateList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<Candidate__c> candidates = [
                SELECT Id, Name, First_Name__c, Last_Name__c, Status__c,
                       Highest_Level_Achieved__c, Email__c, Phone__c,
                       Office_Location__c, Sales_Manager__c, CreatedDate
                FROM Candidate__c
                WHERE Sales_Manager__c = :currentUserName
                ORDER BY CreatedDate DESC
            ];
            
            for (Candidate__c candidate : candidates) {
                Map<String, Object> candidateMap = new Map<String, Object>();
                candidateMap.put('id', candidate.Id);
                candidateMap.put('name', candidate.Name);
                candidateMap.put('status', candidate.Status__c);
                candidateMap.put('highestLevel', candidate.Highest_Level_Achieved__c);
                candidateMap.put('email', candidate.Email__c);
                candidateMap.put('phone', candidate.Phone__c);
                candidateMap.put('officeLocation', candidate.Office_Location__c);
                candidateMap.put('salesManagerName', candidate.Sales_Manager__c);
                candidateMap.put('recordUrl', '/' + candidate.Id);
                candidateList.add(candidateMap);
            }
        } catch (Exception e) {
            System.debug('Error in getCandidatesList: ' + e.getMessage());
        }
        
        return candidateList;
    }
    
    /**
     * Retrieves detailed list of upcoming interviews for current user's candidates
     * 
     * @return List<Map<String, Object>> list of scheduled interviews
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getUpcomingInterviewsList() {
        List<Map<String, Object>> interviewList = new List<Map<String, Object>>();
        Id currentUserId = UserInfo.getUserId();
        
        try {
            List<Interview__c> interviews = [
                SELECT Id, Name, Candidate__r.Name, Candidate__c,
                       Interview_Type__c, Date_Time_Scheduled__c,
                       Conducted_By__r.Name, Interview_Status__c
                FROM Interview__c
                WHERE Interview_Status__c = 'Scheduled'
                AND Date_Time_Scheduled__c >= TODAY
                AND Candidate__r.OwnerId = :currentUserId
                ORDER BY Date_Time_Scheduled__c ASC
            ];
            
            for (Interview__c interview : interviews) {
                Map<String, Object> interviewMap = new Map<String, Object>();
                interviewMap.put('id', interview.Id);
                interviewMap.put('candidateName', interview.Candidate__r.Name);
                interviewMap.put('candidateId', interview.Candidate__c);
                interviewMap.put('interviewType', interview.Interview_Type__c);
                interviewMap.put('scheduledDate', interview.Date_Time_Scheduled__c);
                interviewMap.put('interviewer', interview.Conducted_By__r != null ? interview.Conducted_By__r.Name : '');
                interviewMap.put('status', interview.Interview_Status__c);
                interviewMap.put('recordUrl', '/' + interview.Id);
                interviewMap.put('candidateUrl', '/' + interview.Candidate__c);
                interviewList.add(interviewMap);
            }
        } catch (Exception e) {
            System.debug('Error in getUpcomingInterviewsList: ' + e.getMessage());
        }
        
        return interviewList;
    }
    
    /**
     * Retrieves detailed list of active pipeline candidates
     * 
     * @return List<Map<String, Object>> list of active candidates
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getActivePipelineList() {
        List<Map<String, Object>> candidateList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<Candidate__c> candidates = [
                SELECT Id, Name, Status__c, Highest_Level_Achieved__c,
                       Email__c, Phone__c, Next_Meeting_Date__c, Sales_Manager__c, LastModifiedDate
                FROM Candidate__c
                WHERE Sales_Manager__c = :currentUserName
                AND Status__c = 'Active/In Process'
                ORDER BY Next_Meeting_Date__c ASC NULLS LAST
            ];
            
            for (Candidate__c candidate : candidates) {
                Map<String, Object> candidateMap = new Map<String, Object>();
                candidateMap.put('id', candidate.Id);
                candidateMap.put('name', candidate.Name);
                candidateMap.put('status', candidate.Status__c);
                candidateMap.put('highestLevel', candidate.Highest_Level_Achieved__c);
                candidateMap.put('nextMeeting', candidate.Next_Meeting_Date__c);
                candidateMap.put('email', candidate.Email__c);
                candidateMap.put('phone', candidate.Phone__c);
                candidateMap.put('salesManagerName', candidate.Sales_Manager__c);
                candidateMap.put('phone', candidate.Phone__c);
                candidateMap.put('recordUrl', '/' + candidate.Id);
                candidateList.add(candidateMap);
            }
        } catch (Exception e) {
            System.debug('Error in getActivePipelineList: ' + e.getMessage());
        }
        
        return candidateList;
    }
    
    /**
     * Retrieves detailed list of Contract B agents
     * 
     * @return List<Map<String, Object>> list of Contract B ALC records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getOnContractBList() {
        List<Map<String, Object>> alcList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Candidate__r.Name, Candidate__c,
                       Contract_Type__c, Stage__c, Contract_Effective__c,
                       Contract_B_Expiration_Date__c, CreatedDate
                FROM ALC__c
                WHERE Candidate__r.Sales_Manager__c = :currentUserName
                AND Contract_Type__c = 'B'
                AND Stage__c = 'Contracting Complete'
                ORDER BY CreatedDate DESC
            ];
            
            for (ALC__c alc : alcRecords) {
                Map<String, Object> alcMap = new Map<String, Object>();
                alcMap.put('id', alc.Id);
                alcMap.put('candidateName', alc.Candidate__r.Name);
                alcMap.put('candidateId', alc.Candidate__c);
                alcMap.put('contractType', alc.Contract_Type__c);
                alcMap.put('stage', alc.Stage__c);
                alcMap.put('effectiveDate', alc.Contract_Effective__c);
                alcMap.put('expirationDate', alc.Contract_B_Expiration_Date__c);
                alcMap.put('recordUrl', '/' + alc.Id);
                alcMap.put('candidateUrl', '/' + alc.Candidate__c);
                alcList.add(alcMap);
            }
        } catch (Exception e) {
            System.debug('Error in getOnContractBList: ' + e.getMessage());
        }
        
        return alcList;
    }
    
    /**
     * Retrieves detailed list of Contract A agents
     * 
     * @return List<Map<String, Object>> list of Contract A ALC records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getOnContractAList() {
        List<Map<String, Object>> alcList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Candidate__r.Name, Candidate__c,
                       Contract_Type__c, Stage__c, Contract_Effective__c,
                       CreatedDate
                FROM ALC__c
                WHERE Candidate__r.Sales_Manager__c = :currentUserName
                AND Contract_Type__c = 'A'
                AND Stage__c = 'Contracting Complete'
                ORDER BY CreatedDate DESC
            ];
            
            for (ALC__c alc : alcRecords) {
                Map<String, Object> alcMap = new Map<String, Object>();
                alcMap.put('id', alc.Id);
                alcMap.put('candidateName', alc.Candidate__r.Name);
                alcMap.put('candidateId', alc.Candidate__c);
                alcMap.put('contractType', alc.Contract_Type__c);
                alcMap.put('stage', alc.Stage__c);
                alcMap.put('effectiveDate', alc.Contract_Effective__c);
                alcMap.put('recordUrl', '/' + alc.Id);
                alcMap.put('candidateUrl', '/' + alc.Candidate__c);
                alcList.add(alcMap);
            }
        } catch (Exception e) {
            System.debug('Error in getOnContractAList: ' + e.getMessage());
        }
        
        return alcList;
    }
    
    /**
     * Retrieves detailed list of candidates hired this month
     * 
     * @return List<Map<String, Object>> list of recently hired candidates
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getHiredThisMonthList() {
        List<Map<String, Object>> hiredList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<ALC__c> alcRecords = [
                SELECT Id, Name, Candidate__r.Name, Candidate__c,
                       Contract_Type__c, Stage__c, LastModifiedDate,
                       Contract_Effective__c
                FROM ALC__c
                WHERE Candidate__r.Sales_Manager__c = :currentUserName
                AND Stage__c IN ('Contracted', 'COMPLETE')
                AND LastModifiedDate = THIS_MONTH
                ORDER BY LastModifiedDate DESC
            ];
            
            for (ALC__c alc : alcRecords) {
                Map<String, Object> hiredMap = new Map<String, Object>();
                hiredMap.put('id', alc.Id);
                hiredMap.put('candidateName', alc.Candidate__r.Name);
                hiredMap.put('candidateId', alc.Candidate__c);
                hiredMap.put('contractType', alc.Contract_Type__c);
                hiredMap.put('stage', alc.Stage__c);
                hiredMap.put('hireDate', alc.LastModifiedDate);
                hiredMap.put('effectiveDate', alc.Contract_Effective__c);
                hiredMap.put('recordUrl', '/' + alc.Id);
                hiredMap.put('candidateUrl', '/' + alc.Candidate__c);
                hiredList.add(hiredMap);
            }
        } catch (Exception e) {
            System.debug('Error in getHiredThisMonthList: ' + e.getMessage());
        }
        
        return hiredList;
    }
    
    /**
     * Retrieves detailed list of completed interviews this month
     * 
     * @return List<Map<String, Object>> list of completed interviews
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCompletedInterviewsList() {
        List<Map<String, Object>> interviewList = new List<Map<String, Object>>();
        String currentUserName = getCurrentUserName();
        
        try {
            List<Interview__c> interviews = [
                SELECT Id, Name, Candidate__r.Name, Candidate__c,
                       Interview_Type__c, Date_Completed__c, Outcome__c,
                       Conducted_By__r.Name, Interview_Status__c
                FROM Interview__c
                WHERE Candidate__r.Sales_Manager__c = :currentUserName
                AND Interview_Status__c = 'Completed'
                AND Date_Completed__c = THIS_MONTH
                ORDER BY Date_Completed__c DESC
            ];
            
            for (Interview__c interview : interviews) {
                Map<String, Object> interviewMap = new Map<String, Object>();
                interviewMap.put('id', interview.Id);
                interviewMap.put('candidateName', interview.Candidate__r.Name);
                interviewMap.put('candidateId', interview.Candidate__c);
                interviewMap.put('interviewType', interview.Interview_Type__c);
                interviewMap.put('completedDate', interview.Date_Completed__c);
                interviewMap.put('outcome', interview.Outcome__c);
                interviewMap.put('interviewer', interview.Conducted_By__r != null ? interview.Conducted_By__r.Name : '');
                interviewMap.put('recordUrl', '/' + interview.Id);
                interviewMap.put('candidateUrl', '/' + interview.Candidate__c);
                interviewList.add(interviewMap);
            }
        } catch (Exception e) {
            System.debug('Error in getCompletedInterviewsList: ' + e.getMessage());
        }
        
        return interviewList;
    }
}