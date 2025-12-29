public with sharing class InterviewLeaderboardNewController {
    
    public class LeaderboardEntry implements Comparable {
        @AuraEnabled public String userId { get; set; }
        @AuraEnabled public String userName { get; set; }
        @AuraEnabled public Integer interviewsThisWeek { get; set; }
        @AuraEnabled public Integer interviewsThisMonth { get; set; }
        @AuraEnabled public Integer ciFirstCount { get; set; }
        @AuraEnabled public Integer alignSecondCount { get; set; }
        @AuraEnabled public Integer planThirdCount { get; set; }
        @AuraEnabled public Integer presentFourthCount { get; set; }
        @AuraEnabled public Integer optionalFifthCount { get; set; }
        @AuraEnabled public Integer totalInterviews { get; set; }
        @AuraEnabled public Integer unassignedCount { get; set; }
        
        public Integer compareTo(Object compareTo) {
            LeaderboardEntry compareEntry = (LeaderboardEntry)compareTo;
            // Sort descending by totalInterviews
            return compareEntry.totalInterviews - this.totalInterviews;
        }
    }
    
    @AuraEnabled
    public static List<LeaderboardEntry> getCurrentMonthLeaderboard() {
        Map<String, LeaderboardEntry> leaderboardMap = new Map<String, LeaderboardEntry>();
        
        try {
            // Query all interviews for the current month
            // Cannot use GROUP BY with multipicklist, so we'll process individually
            List<Interview__c> monthInterviews = [
                SELECT 
                    Id,
                    Interviewer_s__c,
                    Interview_Type__c,
                    Date_Time_Scheduled__c
                FROM Interview__c
                WHERE Date_Time_Scheduled__c = THIS_MONTH
                AND Interview_Type__c != null
            ];
            
            // Process each interview
            for (Interview__c interview : monthInterviews) {
                String interviewType = interview.Interview_Type__c;
                String interviewers = interview.Interviewer_s__c;
                
                // Handle unassigned (null or empty Interviewer_s__c)
                if (String.isBlank(interviewers)) {
                    // Find or create Unassigned entry
                    if (!leaderboardMap.containsKey('Unassigned')) {
                        LeaderboardEntry unassignedEntry = new LeaderboardEntry();
                        unassignedEntry.userId = null;
                        unassignedEntry.userName = 'Unassigned';
                        unassignedEntry.ciFirstCount = 0;
                        unassignedEntry.alignSecondCount = 0;
                        unassignedEntry.planThirdCount = 0;
                        unassignedEntry.presentFourthCount = 0;
                        unassignedEntry.optionalFifthCount = 0;
                        unassignedEntry.totalInterviews = 0;
                        unassignedEntry.interviewsThisWeek = 0;
                        unassignedEntry.interviewsThisMonth = 0;
                        unassignedEntry.unassignedCount = 0;
                        leaderboardMap.put('Unassigned', unassignedEntry);
                    }
                    
                    leaderboardMap.get('Unassigned').unassignedCount += 1;
                    continue;
                }
                
                // Split multipicklist values (semicolon-separated)
                List<String> interviewerList = interviewers.split(';');
                
                // Count for each interviewer
                for (String interviewer : interviewerList) {
                    interviewer = interviewer.trim();
                    
                    if (String.isBlank(interviewer)) {
                        continue;
                    }
                    
                    // Get or create entry for this interviewer
                    if (!leaderboardMap.containsKey(interviewer)) {
                        LeaderboardEntry entry = new LeaderboardEntry();
                        entry.userId = null; // Not SF users
                        entry.userName = interviewer;
                        entry.ciFirstCount = 0;
                        entry.alignSecondCount = 0;
                        entry.planThirdCount = 0;
                        entry.presentFourthCount = 0;
                        entry.optionalFifthCount = 0;
                        entry.totalInterviews = 0;
                        entry.interviewsThisWeek = 0;
                        entry.interviewsThisMonth = 0;
                        entry.unassignedCount = 0;
                        leaderboardMap.put(interviewer, entry);
                    }
                    
                    LeaderboardEntry entry = leaderboardMap.get(interviewer);
                    
                    // Map interview types to counts based on the leaderboard categories
                    // CI-First: New picklist value 'Ci-First' or legacy 'Attraction'
                    if (interviewType == 'Ci-First' || interviewType == 'Attraction') {
                        entry.ciFirstCount += 1;
                    }
                    // Align-2nd: New picklist value 'Align-2nd' or legacy 'SI1' or 'SI2'
                    else if (interviewType == 'Align-2nd' || interviewType == 'SI1' || interviewType == 'SI2') {
                        entry.alignSecondCount += 1;
                    }
                    // Plan-3rd: New picklist value 'Plan-3rd' or legacy 'SI3'
                    else if (interviewType == 'Plan-3rd' || interviewType == 'SI3') {
                        entry.planThirdCount += 1;
                    }
                    // Present-4th: New picklist value 'Present-4th' or legacy 'Career'
                    else if (interviewType == 'Present-4th' || interviewType == 'Career') {
                        entry.presentFourthCount += 1;
                    }
                    // Optional-5th: New picklist value 'Optional-5th' or any other type
                    else {
                        entry.optionalFifthCount += 1;
                    }
                    
                    entry.totalInterviews += 1;
                }
            }
            
            // Get this week counts for each interviewer
            List<Interview__c> weekInterviews = [
                SELECT 
                    Id,
                    Interviewer_s__c
                FROM Interview__c
                WHERE Date_Time_Scheduled__c = THIS_WEEK
                AND Interviewer_s__c != null
            ];
            
            for (Interview__c interview : weekInterviews) {
                String interviewers = interview.Interviewer_s__c;
                List<String> interviewerList = interviewers.split(';');
                
                for (String interviewer : interviewerList) {
                    interviewer = interviewer.trim();
                    
                    if (String.isBlank(interviewer)) {
                        continue;
                    }
                    
                    if (leaderboardMap.containsKey(interviewer)) {
                        leaderboardMap.get(interviewer).interviewsThisWeek += 1;
                    }
                }
            }
            
            // Set interviewsThisMonth to totalInterviews since we're already filtering by THIS_MONTH
            for (LeaderboardEntry entry : leaderboardMap.values()) {
                entry.interviewsThisMonth = entry.totalInterviews;
            }
            
            // Convert to list and sort by total interviews descending
            List<LeaderboardEntry> leaderboard = new List<LeaderboardEntry>();
            leaderboard.addAll(leaderboardMap.values());
            
            // Sort descending by totalInterviews
            leaderboard.sort();
            
            return leaderboard;
            
        } catch (Exception e) {
            System.debug('Error in getCurrentMonthLeaderboard: ' + e.getMessage());
            System.debug('Error type: ' + e.getTypeName());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug('Stack trace: ' + e.getStackTraceString());
            throw new AuraHandledException('Error retrieving leaderboard: ' + e.getMessage() + ' at line ' + e.getLineNumber());
        }
    }
    
    public class InterviewDetail {
        @AuraEnabled public String id { get; set; }
        @AuraEnabled public String candidateName { get; set; }
        @AuraEnabled public String interviewType { get; set; }
        @AuraEnabled public String interviewers { get; set; }
        @AuraEnabled public DateTime scheduledDate { get; set; }
        @AuraEnabled public String formattedDate { get; set; }
    }
    
    @AuraEnabled
    public static List<InterviewDetail> getThisWeekInterviews() {
        List<InterviewDetail> weeklyInterviews = new List<InterviewDetail>();
        
        try {
            // Query interviews for this week
            List<Interview__c> interviews = [
                SELECT 
                    Id,
                    Candidate__r.Name,
                    Interview_Type__c,
                    Interviewer_s__c,
                    Date_Time_Scheduled__c
                FROM Interview__c
                WHERE Date_Time_Scheduled__c = THIS_WEEK
                AND Interview_Type__c != null
                ORDER BY Date_Time_Scheduled__c DESC, Candidate__r.Name ASC
            ];
            
            for (Interview__c interview : interviews) {
                InterviewDetail detail = new InterviewDetail();
                detail.id = interview.Id;
                detail.candidateName = interview.Candidate__r.Name;
                detail.interviewType = interview.Interview_Type__c;
                detail.interviewers = String.isBlank(interview.Interviewer_s__c) ? 'Unassigned' : interview.Interviewer_s__c;
                detail.scheduledDate = interview.Date_Time_Scheduled__c;
                detail.formattedDate = interview.Date_Time_Scheduled__c.format('MMM d, yyyy');
                weeklyInterviews.add(detail);
            }
            
            return weeklyInterviews;
            
        } catch (Exception e) {
            System.debug('Error in getThisWeekInterviews: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving weekly interviews: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<InterviewDetail> getThisMonthInterviews() {
        List<InterviewDetail> monthlyInterviews = new List<InterviewDetail>();
        
        try {
            // Query interviews for this month
            List<Interview__c> interviews = [
                SELECT 
                    Id,
                    Candidate__r.Name,
                    Interview_Type__c,
                    Interviewer_s__c,
                    Date_Time_Scheduled__c
                FROM Interview__c
                WHERE Date_Time_Scheduled__c = THIS_MONTH
                AND Interview_Type__c != null
                ORDER BY Date_Time_Scheduled__c DESC, Candidate__r.Name ASC
            ];
            
            for (Interview__c interview : interviews) {
                InterviewDetail detail = new InterviewDetail();
                detail.id = interview.Id;
                detail.candidateName = interview.Candidate__r.Name;
                detail.interviewType = interview.Interview_Type__c;
                detail.interviewers = String.isBlank(interview.Interviewer_s__c) ? 'Unassigned' : interview.Interviewer_s__c;
                detail.scheduledDate = interview.Date_Time_Scheduled__c;
                detail.formattedDate = interview.Date_Time_Scheduled__c.format('MMM d, yyyy');
                monthlyInterviews.add(detail);
            }
            
            return monthlyInterviews;
            
        } catch (Exception e) {
            System.debug('Error in getThisMonthInterviews: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving monthly interviews: ' + e.getMessage());
        }
    }
    
    @AuraEnabled
    public static List<InterviewDetail> getInterviewsByType(String interviewType) {
        List<InterviewDetail> typeInterviews = new List<InterviewDetail>();
        
        try {
            // Query interviews for this month filtered by type
            List<Interview__c> interviews = [
                SELECT 
                    Id,
                    Candidate__r.Name,
                    Interview_Type__c,
                    Interviewer_s__c,
                    Date_Time_Scheduled__c
                FROM Interview__c
                WHERE Date_Time_Scheduled__c = THIS_MONTH
                AND Interview_Type__c = :interviewType
                ORDER BY Date_Time_Scheduled__c DESC, Candidate__r.Name ASC
            ];
            
            for (Interview__c interview : interviews) {
                InterviewDetail detail = new InterviewDetail();
                detail.id = interview.Id;
                detail.candidateName = interview.Candidate__r.Name;
                detail.interviewType = interview.Interview_Type__c;
                detail.interviewers = String.isBlank(interview.Interviewer_s__c) ? 'Unassigned' : interview.Interviewer_s__c;
                detail.scheduledDate = interview.Date_Time_Scheduled__c;
                detail.formattedDate = interview.Date_Time_Scheduled__c.format('MMM d, yyyy');
                typeInterviews.add(detail);
            }
            
            return typeInterviews;
            
        } catch (Exception e) {
            System.debug('Error in getInterviewsByType: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving interviews by type: ' + e.getMessage());
        }
    }
    
}
