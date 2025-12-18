/**
 * Controller for the Candidate Kanban Board component
 * Provides data for displaying candidates organized by Highest Level Achieved
 */
public with sharing class CandidateKanbanController {
    
    /**
     * Get all candidates grouped by Highest Level Achieved stage
     * @return Map of stage name to list of candidate wrapper objects
     */
    @AuraEnabled(cacheable=true)
    public static KanbanData getKanbanData() {
        KanbanData result = new KanbanData();
        
        // Define stages in order (pipeline only - excludes Contracted)
        result.stages = new List<StageInfo>();
        result.stages.add(new StageInfo('0-Prequal', 'Prequal'));
        result.stages.add(new StageInfo('Ci_1st', 'Ci (1st)'));
        result.stages.add(new StageInfo('Align (2nd)', 'Align (2nd)'));
        result.stages.add(new StageInfo('Plan_3rd', 'Plan (3rd)'));
        result.stages.add(new StageInfo('Present-4th', 'Present (4th)'));
        result.stages.add(new StageInfo('Optional_5th', 'Optional (5th)'));
        result.stages.add(new StageInfo('6-Offer Acc', 'Offer Accepted'));
        
        // Query active candidates in pipeline - excludes Contracted
        List<Candidate__c> candidates = [
            SELECT Id, Name, First_Name__c, Last_Name__c, Nickname__c,
                   Email__c, personal_email__c, Phone__c, Work_Phone__c,
                   City__c, State_Province__c, Work_City__c,
                   Highest_Level_Achieved__c, Status__c,
                   Recruiter__c, Recruiter__r.Name,
                   Contact__c, Contact__r.Name,
                   OwnerId, Owner.Name,
                   ALC__c, ALC__r.Name, ALC__r.Stage__c,
                   CreatedDate, LastModifiedDate
            FROM Candidate__c
            WHERE Status__c NOT IN ('Closed Lost', 'Not Interested', 'Hired', 'Terminated')
            AND Highest_Level_Achieved__c != '7-Contracted'
            ORDER BY LastModifiedDate DESC
            LIMIT 200
        ];
        
        // Collect candidate IDs
        Set<Id> candidateIds = new Set<Id>();
        for (Candidate__c c : candidates) {
            candidateIds.add(c.Id);
        }
        
        // Query latest interview for each candidate (most recent by Date_Time_Scheduled__c or CreatedDate)
        Map<Id, Interview__c> latestInterviewByCandidate = new Map<Id, Interview__c>();
        List<Interview__c> interviews = [
            SELECT Id, Candidate__c, Interview_Type__c, Interview_Status__c, 
                   Date_Time_Scheduled__c, CreatedDate
            FROM Interview__c
            WHERE Candidate__c IN :candidateIds
            ORDER BY Date_Time_Scheduled__c DESC NULLS LAST, CreatedDate DESC
        ];
        
        // Keep only the most recent interview per candidate
        for (Interview__c interview : interviews) {
            if (!latestInterviewByCandidate.containsKey(interview.Candidate__c)) {
                latestInterviewByCandidate.put(interview.Candidate__c, interview);
            }
        }
        
        // Query ALC records linked to these candidates (ALC has Candidate__c lookup)
        Map<Id, ALC__c> alcByCandidate = new Map<Id, ALC__c>();
        List<ALC__c> alcRecords = [
            SELECT Id, Name, Stage__c, Candidate__c
            FROM ALC__c
            WHERE Candidate__c IN :candidateIds
            AND Stage__c != null
            ORDER BY CreatedDate DESC
        ];
        
        // Keep the most recent ALC per candidate
        for (ALC__c alc : alcRecords) {
            if (!alcByCandidate.containsKey(alc.Candidate__c)) {
                alcByCandidate.put(alc.Candidate__c, alc);
            }
        }
        
        // Group candidates by stage
        result.candidatesByStage = new Map<String, List<CandidateCard>>();
        
        // Initialize empty lists for each stage
        for (StageInfo stage : result.stages) {
            result.candidatesByStage.put(stage.value, new List<CandidateCard>());
        }
        
        // Populate candidates into stages
        for (Candidate__c c : candidates) {
            String stage = c.Highest_Level_Achieved__c;
            if (stage == null) {
                stage = '0-Prequal';
            }
            
            if (result.candidatesByStage.containsKey(stage)) {
                Interview__c latestInterview = latestInterviewByCandidate.get(c.Id);
                ALC__c alc = alcByCandidate.get(c.Id);
                result.candidatesByStage.get(stage).add(new CandidateCard(c, latestInterview, alc));
            }
        }
        
        // Calculate counts for each stage
        for (StageInfo stage : result.stages) {
            stage.count = result.candidatesByStage.get(stage.value).size();
        }
        
        return result;
    }
    
    /**
     * Update a candidate's Highest Level Achieved stage (for drag-drop)
     * @param candidateId The Id of the candidate to update
     * @param newStage The new stage value
     * @return Success message or error
     */
    @AuraEnabled
    public static String updateCandidateStage(Id candidateId, String newStage) {
        try {
            Candidate__c candidate = new Candidate__c(
                Id = candidateId,
                Highest_Level_Achieved__c = newStage
            );
            update candidate;
            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error updating candidate: ' + e.getMessage());
        }
    }
    
    /**
     * Wrapper class for kanban data
     */
    public class KanbanData {
        @AuraEnabled public List<StageInfo> stages { get; set; }
        @AuraEnabled public Map<String, List<CandidateCard>> candidatesByStage { get; set; }
    }
    
    /**
     * Wrapper class for stage information
     */
    public class StageInfo {
        @AuraEnabled public String value { get; set; }
        @AuraEnabled public String label { get; set; }
        @AuraEnabled public Integer count { get; set; }
        
        public StageInfo(String value, String label) {
            this.value = value;
            this.label = label;
            this.count = 0;
        }
    }
    
    /**
     * Wrapper class for candidate card data
     */
    public class CandidateCard {
        @AuraEnabled public Id id { get; set; }
        @AuraEnabled public String name { get; set; }
        @AuraEnabled public String firstName { get; set; }
        @AuraEnabled public String lastName { get; set; }
        @AuraEnabled public String initials { get; set; }
        @AuraEnabled public String email { get; set; }
        @AuraEnabled public String phone { get; set; }
        @AuraEnabled public String location { get; set; }
        @AuraEnabled public String stage { get; set; }
        @AuraEnabled public String status { get; set; }
        @AuraEnabled public String recruiterName { get; set; }
        @AuraEnabled public String ownerName { get; set; }
        @AuraEnabled public String timeAgo { get; set; }
        @AuraEnabled public Datetime lastModified { get; set; }
        @AuraEnabled public Boolean inContracting { get; set; }
        @AuraEnabled public String contractingStage { get; set; }
        @AuraEnabled public String interviewStage { get; set; }
        @AuraEnabled public String interviewStatus { get; set; }
        
        public CandidateCard(Candidate__c c, Interview__c latestInterview, ALC__c alc) {
            this.id = c.Id;
            this.name = c.Name;
            this.firstName = c.First_Name__c;
            this.lastName = c.Last_Name__c;
            this.initials = getInitials(c.First_Name__c, c.Last_Name__c);
            this.email = c.Email__c != null ? c.Email__c : c.personal_email__c;
            this.phone = c.Phone__c != null ? c.Phone__c : c.Work_Phone__c;
            this.location = formatLocation(c.City__c, c.State_Province__c);
            this.stage = c.Highest_Level_Achieved__c;
            this.status = c.Status__c;
            this.recruiterName = c.Recruiter__r?.Name;
            this.ownerName = c.Owner.Name;
            this.lastModified = c.LastModifiedDate;
            this.timeAgo = calculateTimeAgo(c.LastModifiedDate);
            
            // Interview stage from latest interview
            if (latestInterview != null) {
                this.interviewStage = latestInterview.Interview_Type__c;
                this.interviewStatus = latestInterview.Interview_Status__c;
            }
            
            // ALC contracting status - query from ALC__c that has Candidate__c lookup
            this.inContracting = alc != null;
            if (alc != null && alc.Stage__c != null) {
                this.contractingStage = alc.Stage__c;
            }
        }
        
        private String getInitials(String firstName, String lastName) {
            String initials = '';
            if (firstName != null && firstName.length() > 0) {
                initials += firstName.substring(0, 1).toUpperCase();
            }
            if (lastName != null && lastName.length() > 0) {
                initials += lastName.substring(0, 1).toUpperCase();
            }
            return initials.length() > 0 ? initials : '?';
        }
        
        private String formatLocation(String city, String state) {
            List<String> parts = new List<String>();
            if (city != null && city.length() > 0) {
                parts.add(city);
            }
            if (state != null && state.length() > 0) {
                parts.add(state);
            }
            return parts.isEmpty() ? 'No Location' : String.join(parts, ', ');
        }
        
        private String calculateTimeAgo(Datetime dt) {
            if (dt == null) return '';
            
            Long milliseconds = Datetime.now().getTime() - dt.getTime();
            Long seconds = milliseconds / 1000;
            Long minutes = seconds / 60;
            Long hours = minutes / 60;
            Long days = hours / 24;
            
            if (days > 0) {
                return days == 1 ? '1 day ago' : days + ' days ago';
            } else if (hours > 0) {
                return hours == 1 ? '1 hour ago' : hours + ' hours ago';
            } else if (minutes > 0) {
                return minutes == 1 ? '1 minute ago' : minutes + ' minutes ago';
            } else {
                return 'just now';
            }
        }
    }
}