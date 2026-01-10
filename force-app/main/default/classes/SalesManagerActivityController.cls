/**
 * Controller for Sales Manager Activity dashboard component
 * Provides metrics on sales manager login activity and performance
 */
public without sharing class SalesManagerActivityController {
    
    /**
     * Get comprehensive activity data for all sales managers
     * @param dateRange Date range filter (THIS_MONTH, THIS_QUARTER, THIS_YEAR)
     * @param salesManagerFilter Specific sales manager or 'All Sales Managers'
     * @return List of sales manager activity records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSalesManagerActivity(String dateRange, String salesManagerFilter) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        try {
            // Get date range boundaries
            Map<String, Date> dateRangeBoundaries = getDateRangeBoundaries(dateRange);
            Date startDate = dateRangeBoundaries.get('startDate');
            Date endDate = dateRangeBoundaries.get('endDate');
            
            // Query active Sales Managers with last login info
            List<User> salesManagers = [
                SELECT Id, Name, LastLoginDate, Profile.Name, Email
                FROM User
                WHERE IsActive = true
                AND (
                    Profile.Name LIKE '%Sales Manager%'
                    OR UserRole.Name LIKE '%Sales Manager%'
                    OR UserRole.Name = 'SM'
                )
                ORDER BY Name ASC
            ];
            
            // Filter by specific sales manager if needed
            if (salesManagerFilter != null && salesManagerFilter != 'All Sales Managers') {
                List<User> filteredManagers = new List<User>();
                for (User u : salesManagers) {
                    if (u.Name == salesManagerFilter) {
                        filteredManagers.add(u);
                    }
                }
                salesManagers = filteredManagers;
            }
            
            // Build activity data for each sales manager
            for (User sm : salesManagers) {
                Map<String, Object> record = new Map<String, Object>();
                record.put('id', sm.Id);
                record.put('name', sm.Name);
                record.put('email', sm.Email);
                record.put('lastLoginDate', sm.LastLoginDate);
                record.put('daysSinceLogin', calculateDaysSinceLogin(sm.LastLoginDate));
                record.put('loginStatus', getLoginStatus(sm.LastLoginDate));
                
                // Get performance metrics
                record.put('candidatesAdded', getCandidatesAddedCount(sm.Name, startDate, endDate));
                record.put('interviewsScheduled', getInterviewsScheduledCount(sm.Name, startDate, endDate));
                record.put('interviewsCompleted', getInterviewsCompletedCount(sm.Name, startDate, endDate));
                record.put('candidatesInContracting', getCandidatesInContractingCount(sm.Name));
                record.put('candidatesOnboarding', getCandidatesOnboardingCount(sm.Name));
                
                results.add(record);
            }
            
            return results;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving sales manager activity: ' + e.getMessage());
        }
    }
    
    /**
     * Get summary metrics across all sales managers
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getSalesManagerSummary(String dateRange, String salesManagerFilter) {
        Map<String, Object> summary = new Map<String, Object>();
        
        try {
            List<Map<String, Object>> activityData = getSalesManagerActivity(dateRange, salesManagerFilter);
            
            Integer totalManagers = activityData.size();
            Integer inactiveManagers = 0;
            Integer totalCandidates = 0;
            Integer totalInterviewsScheduled = 0;
            Integer totalInterviewsCompleted = 0;
            Integer totalInContracting = 0;
            Integer totalOnboarding = 0;
            
            for (Map<String, Object> record : activityData) {
                if (record.get('loginStatus') == 'Inactive') {
                    inactiveManagers++;
                }
                totalCandidates += (Integer)record.get('candidatesAdded');
                totalInterviewsScheduled += (Integer)record.get('interviewsScheduled');
                totalInterviewsCompleted += (Integer)record.get('interviewsCompleted');
                totalInContracting += (Integer)record.get('candidatesInContracting');
                totalOnboarding += (Integer)record.get('candidatesOnboarding');
            }
            
            summary.put('totalManagers', totalManagers);
            summary.put('inactiveManagers', inactiveManagers);
            summary.put('activeManagers', totalManagers - inactiveManagers);
            summary.put('totalCandidates', totalCandidates);
            summary.put('totalInterviewsScheduled', totalInterviewsScheduled);
            summary.put('totalInterviewsCompleted', totalInterviewsCompleted);
            summary.put('totalInContracting', totalInContracting);
            summary.put('totalOnboarding', totalOnboarding);
            
            return summary;
        } catch (Exception e) {
            throw new AuraHandledException('Error retrieving summary: ' + e.getMessage());
        }
    }
    
    // Helper methods
    
    private static Map<String, Date> getDateRangeBoundaries(String dateRange) {
        Map<String, Date> boundaries = new Map<String, Date>();
        Date today = Date.today();
        Date startDate;
        Date endDate = today;
        
        if (dateRange == 'THIS_QUARTER') {
            Integer currentMonth = today.month();
            Integer quarterStartMonth = ((currentMonth - 1) / 3) * 3 + 1;
            startDate = Date.newInstance(today.year(), quarterStartMonth, 1);
        } else if (dateRange == 'THIS_YEAR') {
            startDate = Date.newInstance(today.year(), 1, 1);
        } else {
            // Default to THIS_MONTH
            startDate = today.toStartOfMonth();
        }
        
        boundaries.put('startDate', startDate);
        boundaries.put('endDate', endDate);
        return boundaries;
    }
    
    private static Integer calculateDaysSinceLogin(DateTime lastLogin) {
        if (lastLogin == null) {
            return 999; // Never logged in
        }
        return Date.today().daysBetween(lastLogin.date());
    }
    
    private static String getLoginStatus(DateTime lastLogin) {
        Integer daysSince = calculateDaysSinceLogin(lastLogin);
        if (daysSince > 7) {
            return 'Inactive';
        }
        return 'Active';
    }
    
    private static Integer getCandidatesAddedCount(String salesManager, Date startDate, Date endDate) {
        return [
            SELECT COUNT()
            FROM Candidate__c
            WHERE Sales_Manager__c = :salesManager
            AND CreatedDate >= :startDate
            AND CreatedDate <= :endDate
        ];
    }
    
    private static Integer getInterviewsScheduledCount(String salesManager, Date startDate, Date endDate) {
        DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 0));
        
        return [
            SELECT COUNT()
            FROM Interview__c
            WHERE Candidate__r.Sales_Manager__c = :salesManager
            AND Date_Time_Scheduled__c >= :startDateTime
            AND Date_Time_Scheduled__c <= :endDateTime
        ];
    }
    
    private static Integer getInterviewsCompletedCount(String salesManager, Date startDate, Date endDate) {
        DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
        DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 0));
        
        return [
            SELECT COUNT()
            FROM Interview__c
            WHERE Candidate__r.Sales_Manager__c = :salesManager
            AND Interview_Status__c = 'Completed'
            AND Date_Time_Scheduled__c >= :startDateTime
            AND Date_Time_Scheduled__c <= :endDateTime
        ];
    }
    
    private static Integer getCandidatesInContractingCount(String salesManager) {
        return [
            SELECT COUNT()
            FROM Candidate__c
            WHERE Sales_Manager__c = :salesManager
            AND Status__c = 'Active/In Process'
            AND Id IN (
                SELECT Candidate__c 
                FROM ALC__c 
                WHERE RecordType.DeveloperName = 'Career'
                AND Agency__c = 'A157'
                AND Stage__c != null
                AND Stage__c NOT IN ('Terminated', 'Candidate Complete')
            )
        ];
    }
    
    /**
     * Normalize name by trimming and removing extra spaces
     * This ensures consistent name matching even with whitespace variations
     */
    private static String normalizeName(String name) {
        if (String.isBlank(name)) {
            return '';
        }
        // Trim and replace multiple spaces with single space
        return name.trim().replaceAll('\\s+', ' ');
    }
    
    private static Integer getCandidatesOnboardingCount(String salesManager) {
        // Get candidates with completed ALCs
        Set<String> candidateNames = new Set<String>();
        for (Candidate__c candidate : [
            SELECT Name
            FROM Candidate__c
            WHERE Sales_Manager__c = :salesManager
            AND Id IN (
                SELECT Candidate__c
                FROM ALC__c
                WHERE RecordType.DeveloperName = 'Career'
                AND Agency__c = 'A157'
                AND Stage__c = 'Candidate Complete'
            )
        ]) {
            candidateNames.add(normalizeName(candidate.Name));
        }
        
        // Return count of matching Agents_Staff records with Onboarding status
        if (candidateNames.isEmpty()) {
            return 0;
        }
        
        // Query with LIKE pattern to handle whitespace variations
        Integer count = 0;
        for (Agents_Staff__c agent : [
            SELECT Name
            FROM Agents_Staff__c
            WHERE Status__c = 'Onboarding'
        ]) {
            if (candidateNames.contains(normalizeName(agent.Name))) {
                count++;
            }
        }
        return count;
    }
    
    /**
     * Get detailed interview records for a sales manager
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getInterviewDetails(String salesManager, String dateRange, String interviewType) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        try {
            Map<String, Date> dateRangeBoundaries = getDateRangeBoundaries(dateRange);
            Date startDate = dateRangeBoundaries.get('startDate');
            Date endDate = dateRangeBoundaries.get('endDate');
            DateTime startDateTime = DateTime.newInstance(startDate, Time.newInstance(0, 0, 0, 0));
            DateTime endDateTime = DateTime.newInstance(endDate, Time.newInstance(23, 59, 59, 0));
            
            String statusFilter = interviewType == 'completed' ? 'AND Interview_Status__c = \'Completed\'' : '';
            String salesManagerFilter = (salesManager != 'All Sales Managers') ? 'AND Candidate__r.Sales_Manager__c = :salesManager' : '';
            
            String query = 'SELECT Id, Name, Candidate__r.Name, Candidate__r.Id, Candidate__r.Sales_Manager__c, ' +
                          'Date_Time_Scheduled__c, Interview_Status__c, Interview_Type__c, Outcome__c ' +
                          'FROM Interview__c ' +
                          'WHERE Date_Time_Scheduled__c >= :startDateTime ' +
                          'AND Date_Time_Scheduled__c <= :endDateTime ' +
                          salesManagerFilter + ' ' +
                          statusFilter + ' ' +
                          'ORDER BY Date_Time_Scheduled__c DESC';
            
            List<Interview__c> interviews = Database.query(query);
            
            for (Interview__c interview : interviews) {
                Map<String, Object> record = new Map<String, Object>();
                record.put('id', interview.Id);
                record.put('name', interview.Name);
                record.put('candidateName', interview.Candidate__r.Name);
                record.put('candidateId', interview.Candidate__r.Id);
                record.put('salesManager', interview.Candidate__r.Sales_Manager__c);
                record.put('scheduledDate', interview.Date_Time_Scheduled__c);
                record.put('status', interview.Interview_Status__c);
                record.put('type', interview.Interview_Type__c);
                record.put('outcome', interview.Outcome__c);
                results.add(record);
            }
            
            return results;
        } catch (Exception e) {
            System.debug('Error in getInterviewDetails: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving interview details: ' + e.getMessage());
        }
    }
    
    /**
     * Get candidates in contracting
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCandidatesInContracting(String salesManager) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        try {
            String salesManagerFilter = (salesManager != 'All Sales Managers') ? 'AND Sales_Manager__c = :salesManager' : '';
            
            String query = 'SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c, ' +
                          'Highest_Level_Achieved__c, Status__c, Sales_Manager__c, ' +
                          '(SELECT Id, Name, Stage__c FROM ALC__r ' +
                          'WHERE RecordType.DeveloperName = \'Career\' ' +
                          'AND Agency__c = \'A157\' ' +
                          'AND Stage__c != null ' +
                          'AND Stage__c NOT IN (\'Terminated\', \'Candidate Complete\') ' +
                          'LIMIT 1) ' +
                          'FROM Candidate__c ' +
                          'WHERE Status__c = \'Active/In Process\' ' +
                          salesManagerFilter + ' ' +
                          'AND Id IN (' +
                          'SELECT Candidate__c FROM ALC__c ' +
                          'WHERE RecordType.DeveloperName = \'Career\' ' +
                          'AND Agency__c = \'A157\' ' +
                          'AND Stage__c != null ' +
                          'AND Stage__c NOT IN (\'Terminated\', \'Candidate Complete\')) ' +
                          'ORDER BY Name';
            
            List<Candidate__c> candidates = Database.query(query);
            
            for (Candidate__c candidate : candidates) {
                Map<String, Object> record = new Map<String, Object>();
                record.put('id', candidate.Id);
                record.put('name', candidate.Name);
                record.put('firstName', candidate.First_Name__c);
                record.put('lastName', candidate.Last_Name__c);
                record.put('email', candidate.Email__c);
                record.put('phone', candidate.Phone__c);
                record.put('status', candidate.Status__c);
                record.put('stage', candidate.Highest_Level_Achieved__c);
                record.put('salesManager', candidate.Sales_Manager__c);
                
                if (!candidate.ALC__r.isEmpty()) {
                    record.put('alcStage', candidate.ALC__r[0].Stage__c);
                    record.put('alcId', candidate.ALC__r[0].Id);
                }
                
                results.add(record);
            }
            
            return results;
        } catch (Exception e) {
            System.debug('Error in getCandidatesInContracting: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving contracting candidates: ' + e.getMessage());
        }
    }
    
    /**
     * Get candidates in onboarding
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCandidatesOnboarding(String salesManager, String dateRange) {
        List<Map<String, Object>> results = new List<Map<String, Object>>();
        
        try {
            String salesManagerFilter = (salesManager != 'All Sales Managers') ? 'AND Sales_Manager__c = :salesManager' : '';
            
            // Step 1: Get candidates with completed ALCs
            String candidateQuery = 'SELECT Id, Name, First_Name__c, Last_Name__c, Email__c, Phone__c, ' +
                          'Status__c, Sales_Manager__c, ' +
                          '(SELECT Id, Name, Stage__c FROM ALC__r ' +
                          'WHERE RecordType.DeveloperName = \'Career\' ' +
                          'AND Agency__c = \'A157\' ' +
                          'AND Stage__c = \'Candidate Complete\' ' +
                          'LIMIT 1) ' +
                          'FROM Candidate__c ' +
                          'WHERE Id IN (' +
                          'SELECT Candidate__c FROM ALC__c ' +
                          'WHERE RecordType.DeveloperName = \'Career\' ' +
                          'AND Agency__c = \'A157\' ' +
                          'AND Stage__c = \'Candidate Complete\') ' +
                          salesManagerFilter + ' ' +
                          'ORDER BY Name';
            
            List<Candidate__c> candidates = Database.query(candidateQuery);
            
            // Step 2: Get Agents_Staff records with Onboarding status
            Set<String> candidateNames = new Set<String>();
            Map<String, String> normalizedToOriginalName = new Map<String, String>();
            for (Candidate__c candidate : candidates) {
                String normalized = normalizeName(candidate.Name);
                candidateNames.add(normalized);
                normalizedToOriginalName.put(normalized, candidate.Name);
            }
            
            Map<String, Agents_Staff__c> agentsStaffByName = new Map<String, Agents_Staff__c>();
            if (!candidateNames.isEmpty()) {
                for (Agents_Staff__c agentStaff : [
                    SELECT Id, Name, Status__c
                    FROM Agents_Staff__c
                    WHERE Status__c = 'Onboarding'
                ]) {
                    String normalizedAgentName = normalizeName(agentStaff.Name);
                    if (candidateNames.contains(normalizedAgentName)) {
                        // Map normalized name to agent staff record
                        agentsStaffByName.put(normalizedAgentName, agentStaff);
                    }
                }
            }
            
            // Step 3: Build results by matching names
            for (Candidate__c candidate : candidates) {
                String normalizedCandidateName = normalizeName(candidate.Name);
                // Only include if there's a matching Agents_Staff record
                if (agentsStaffByName.containsKey(normalizedCandidateName)) {
                    Map<String, Object> record = new Map<String, Object>();
                    record.put('id', candidate.Id);
                    record.put('name', candidate.Name);
                    record.put('firstName', candidate.First_Name__c);
                    record.put('lastName', candidate.Last_Name__c);
                    record.put('email', candidate.Email__c);
                    record.put('phone', candidate.Phone__c);
                    record.put('status', candidate.Status__c);
                    record.put('salesManager', candidate.Sales_Manager__c);
                    
                    if (!candidate.ALC__r.isEmpty()) {
                        record.put('alcStatus', candidate.ALC__r[0].Stage__c);
                        record.put('alcId', candidate.ALC__r[0].Id);
                    }
                    
                    Agents_Staff__c agentStaff = agentsStaffByName.get(normalizedCandidateName);
                    record.put('agentStaffStatus', agentStaff.Status__c);
                    record.put('agentStaffId', agentStaff.Id);
                    
                    results.add(record);
                }
            }
            
            return results;
        } catch (Exception e) {
            System.debug('Error in getCandidatesOnboarding: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving onboarding candidates: ' + e.getMessage());
        }
    }
}
