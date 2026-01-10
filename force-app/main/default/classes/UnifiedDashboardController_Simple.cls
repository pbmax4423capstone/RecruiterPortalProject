/**
 * Simplified controller for the Unified Recruiting Dashboard
 * Uses existing data in org for Sales Manager options
 */
public with sharing class UnifiedDashboardController {
    
    /**
     * Determines if current user can view all candidates (Director/Admin)
     */
    @AuraEnabled(cacheable=true)
    public static Boolean canViewAllCandidates() {
        try {
            Id profileId = UserInfo.getProfileId();
            Id userId = UserInfo.getUserId();
            
            Profile userProfile = [SELECT Name FROM Profile WHERE Id = :profileId LIMIT 1];
            String profileName = userProfile.Name;
            
            if (profileName.contains('Director') || profileName.contains('System Administrator') ||
                profileName.contains('Admin') || profileName.equalsIgnoreCase('GA')) {
                return true;
            }
            
            User currentUser = [SELECT UserRole.Name FROM User WHERE Id = :userId LIMIT 1];
            if (currentUser.UserRole != null && currentUser.UserRole.Name != null) {
                String roleName = currentUser.UserRole.Name;
                if (roleName.contains('Director') || roleName.equalsIgnoreCase('GA')) {
                    return true;
                }
            }
            
            return false;
        } catch (Exception e) {
            return false;
        }
    }
    
    @AuraEnabled(cacheable=true)
    public static String getCurrentUserName() {
        return UserInfo.getName();
    }
    
    @AuraEnabled(cacheable=true)
    public static List<String> getSalesManagerOptions() {
        List<String> options = new List<String>();
        options.add('All Sales Managers');
        
        Set<String> uniqueManagers = new Set<String>();
        
        // Query distinct Sales Managers from Candidates
        for (AggregateResult ar : [
            SELECT Sales_Manager__c
            FROM Candidate__c
            WHERE Sales_Manager__c != null
            AND Status__c NOT IN ('Closed Lost', 'Not Interesting', 'Hired', 'Terminated')
            GROUP BY Sales_Manager__c
        ]) {
            String salesManager = (String)ar.get('Sales_Manager__c');
            if (String.isNotBlank(salesManager)) {
                uniqueManagers.add(salesManager);
            }
        }
        
        // Also get Sales Managers from ALC records
        for (AggregateResult ar : [
            SELECT Sales_Manager__c
            FROM ALC__c
            WHERE Sales_Manager__c != null
            AND RecordType.DeveloperName = 'Career'
            GROUP BY Sales_Manager__c
        ]) {
            String salesManager = (String)ar.get('Sales_Manager__c');
            if (String.isNotBlank(salesManager)) {
                uniqueManagers.add(salesManager);
            }
        }
        
        List<String> managerList = new List<String>(uniqueManagers);
        managerList.sort();
        options.addAll(managerList);
        
        return options;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getDashboardConfig() {
        Map<String, Object> config = new Map<String, Object>();
        
        String userName = getCurrentUserName();
        Boolean isDirector = canViewAllCandidates();
        Boolean isRachyllTenny = userName == 'Rachyll Tenny';
        
        config.put('userName', userName);
        config.put('isDirector', isDirector);
        config.put('isRachyllTenny', isRachyllTenny);
        config.put('showRecruitingMetrics', isRachyllTenny || isDirector);
        
        return config;
    }
}
