/**
 * Controller for the Unified Recruiting Dashboard component
 * Provides configuration and shared methods for all dashboard tabs
 */
public with sharing class UnifiedDashboardController {
    
    /**
     * Determines if current user can view all candidates (Director/Admin)
     * @return true if user profile or role contains 'Director' or 'System Administrator'
     */
    @AuraEnabled(cacheable=true)
    public static Boolean canViewAllCandidates() {
        try {
            Id profileId = UserInfo.getProfileId();
            Id userId = UserInfo.getUserId();
            
            Profile userProfile = [
                SELECT Name 
                FROM Profile 
                WHERE Id = :profileId 
                LIMIT 1
            ];
            
            String profileName = userProfile.Name;
            
            // Check profile for Director/Admin/GA
            if (profileName.contains('Director') || 
                profileName.contains('System Administrator') ||
                profileName.contains('Admin') ||
                profileName.equalsIgnoreCase('GA')) {
                return true;
            }
            
            // Check UserRole for Directors/GA
            User currentUser = [
                SELECT UserRole.Name 
                FROM User 
                WHERE Id = :userId 
                LIMIT 1
            ];
            
            if (currentUser.UserRole != null && currentUser.UserRole.Name != null) {
                String roleName = currentUser.UserRole.Name;
                if (roleName.contains('Director') || roleName.equalsIgnoreCase('GA')) {
                    return true;
                }
            }
            
            return false;
        } catch (Exception e) {
            System.debug('Error in canViewAllCandidates: ' + e.getMessage());
            return false;
        }
    }
    
    /**
     * Returns the current user's name for display and filtering
     * @return Current user's full name
     */
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }
    
    /**
     * Returns list of distinct Sales Manager values for dropdown
     * @return List of Sales Manager names with "All Sales Managers" first
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getSalesManagerOptions() {
        List<String> options = new List<String>();
        options.add('All Sales Managers');
        
        // Inactive sales managers to exclude
        Set<String> inactiveManagers = new Set<String>{
            'Diljeet Masuda',
            'Scott Primm'
        };
        
        // Query distinct Sales Managers from Candidates
        Set<String> uniqueManagers = new Set<String>();
        
        for (AggregateResult ar : [
            SELECT Sales_Manager__c
            FROM Candidate__c
            WHERE Sales_Manager__c != null
            AND Status__c NOT IN ('Closed Lost', 'Not Interesting', 'Hired', 'Terminated')
            GROUP BY Sales_Manager__c
            ORDER BY Sales_Manager__c
        ]) {
            String salesManager = (String)ar.get('Sales_Manager__c');
            if (String.isNotBlank(salesManager) && !inactiveManagers.contains(salesManager)) {
                uniqueManagers.add(salesManager);
            }
        }
        
        // Also get Sales Managers from ALC records (Career contracting)
        for (AggregateResult ar : [
            SELECT Sales_Manager__c
            FROM ALC__c
            WHERE Sales_Manager__c != null
            AND RecordType.DeveloperName = 'Career'
            AND Agency__c = 'A157'
            GROUP BY Sales_Manager__c
        ]) {
            String salesManager = (String)ar.get('Sales_Manager__c');
            if (String.isNotBlank(salesManager) && !inactiveManagers.contains(salesManager)) {
                uniqueManagers.add(salesManager);
            }
        }
        
        // Convert set to sorted list
        List<String> managerList = new List<String>(uniqueManagers);
        managerList.sort();
        options.addAll(managerList);
        
        return options;
    }
    
    /**
     * Get dashboard configuration for current user
     * @return Map with dashboard settings and permissions
     */
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardConfig() {
        Map<String, Object> config = new Map<String, Object>();
        
        String userName = getCurrentUserName();
        Boolean isDirector = canViewAllCandidates();
        
        // Check if user is Rachyll Tenny (Director of Recruiting)
        Boolean isRachyllTenny = userName == 'Rachyll Tenny';
        
        config.put('userName', userName);
        config.put('isDirector', isDirector);
        config.put('isRachyllTenny', isRachyllTenny);
        config.put('showRecruitingMetrics', isRachyllTenny || isDirector);
        
        return config;
    }
    
    /**
     * Get Sales Manager Activity data with interview and candidate metrics
     * @param salesManagerFilter Filter by specific sales manager or 'All Sales Managers'
     * @param dateRangeFilter Date range: THIS_MONTH, THIS_QUARTER, THIS_YEAR
     * @return List of Sales Manager activity records with metrics
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSalesManagerActivity(String salesManagerFilter, String dateRangeFilter) {
        List<Map<String, Object>> activityList = new List<Map<String, Object>>();
        
        try {
            // Calculate date range
            Date startDate = getStartDateForRange(dateRangeFilter);
            
            // Get all active Sales Manager users
            List<User> salesManagers = [
                SELECT Id, Name, LastLoginDate
                FROM User
                WHERE IsActive = true
                AND (Profile.Name LIKE '%Sales Manager%' 
                     OR Profile.Name LIKE '%Director%'
                     OR Profile.Name = 'System Administrator')
                ORDER BY Name
            ];
            
            // If filtering by specific manager, filter the list
            if (salesManagerFilter != null && salesManagerFilter != 'All Sales Managers') {
                List<User> filteredManagers = new List<User>();
                for (User sm : salesManagers) {
                    if (sm.Name == salesManagerFilter) {
                        filteredManagers.add(sm);
                    }
                }
                salesManagers = filteredManagers;
            }
            
            // For each Sales Manager, calculate metrics
            for (User sm : salesManagers) {
                Map<String, Object> activity = new Map<String, Object>();
                activity.put('salesManagerName', sm.Name);
                activity.put('lastLoginDate', sm.LastLoginDate);
                
                // Count candidates added (by Sales_Manager__c field)
                Integer candidatesAdded = [
                    SELECT COUNT()
                    FROM Candidate__c
                    WHERE Sales_Manager__c = :sm.Name
                    AND CreatedDate >= :startDate
                ];
                activity.put('candidatesAdded', candidatesAdded);
                
                // Get candidate IDs for this sales manager created in date range
                Set<Id> candidateIds = new Set<Id>();
                for (Candidate__c c : [
                    SELECT Id
                    FROM Candidate__c
                    WHERE Sales_Manager__c = :sm.Name
                    AND CreatedDate >= :startDate
                ]) {
                    candidateIds.add(c.Id);
                }
                
                // Count interviews scheduled (for candidates of this sales manager)
                Integer interviewsScheduled = 0;
                if (!candidateIds.isEmpty()) {
                    interviewsScheduled = [
                        SELECT COUNT()
                        FROM Interview__c
                        WHERE Candidate__c IN :candidateIds
                        AND CreatedDate >= :startDate
                    ];
                }
                activity.put('interviewsScheduled', interviewsScheduled);
                
                // Count interviews completed
                Integer interviewsCompleted = 0;
                if (!candidateIds.isEmpty()) {
                    interviewsCompleted = [
                        SELECT COUNT()
                        FROM Interview__c
                        WHERE Candidate__c IN :candidateIds
                        AND Interview_Status__c = 'Completed'
                        AND LastModifiedDate >= :startDate
                    ];
                }
                activity.put('interviewsCompleted', interviewsCompleted);
                
                // Count candidates in contracting (ALC with contracting stages)
                Integer candidatesContracting = 0;
                if (!candidateIds.isEmpty()) {
                    candidatesContracting = [
                        SELECT COUNT()
                        FROM ALC__c
                        WHERE Candidate__c IN :candidateIds
                        AND Stage__c IN ('Initial Form Sent', 'MM_ONX_Sent', 'In Background', 
                                         'Post Background - Pending Rachyll',
                                         'Sent To Compliance', 'Pending SM', 'Contract Codes (A/B) & DocuSign', 
                                         'Submit to HO', 'AA Received')
                        AND CreatedDate >= :startDate
                    ];
                }
                activity.put('candidatesContracting', candidatesContracting);
                
                // Count candidates onboarding (ALC with onboarding stages)
                Integer candidatesOnboarding = 0;
                if (!candidateIds.isEmpty()) {
                    candidatesOnboarding = [
                        SELECT COUNT()
                        FROM ALC__c
                        WHERE Candidate__c IN :candidateIds
                        AND Stage__c IN ('Received Approval Letter', 'Onboarded')
                        AND LastModifiedDate >= :startDate
                    ];
                }
                activity.put('candidatesOnboarding', candidatesOnboarding);
                
                activityList.add(activity);
            }
            
        } catch (Exception e) {
            System.debug('Error in getSalesManagerActivity: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving Sales Manager activity: ' + e.getMessage());
        }
        
        return activityList;
    }
    
    /**
     * Helper method to calculate start date based on date range filter
     */
    private static Date getStartDateForRange(String dateRangeFilter) {
        Date today = Date.today();
        
        if (dateRangeFilter == 'THIS_QUARTER') {
            return today.addDays(-90);
        } else if (dateRangeFilter == 'THIS_YEAR') {
            return today.addDays(-365);
        } else {
            // Default to THIS_MONTH
            return today.addDays(-30);
        }
    }
}
