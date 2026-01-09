/**
 * @description Controller for Sales Manager Qualification Dashboard
 * Provides Contract B and Contract A agent progress tracking with role-based views
 * @author Patrick's Agent
 * @date 2026-01-09
 */
public with sharing class SalesManagerQualificationController {
    
    /**
     * Get current user's role and access level
     * @return Map with isGlobalView (Boolean) and salesManagerUnit (String)
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getCurrentUserRole() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Get current user's Profile name
            User currentUser = [
                SELECT Id, Profile.Name, ContactId
                FROM User 
                WHERE Id = :UserInfo.getUserId()
                LIMIT 1
            ];
            
            String profileName = currentUser.Profile.Name;
            
            // Check if profile grants global view
            Boolean isGlobalView = 
                profileName.contains('Director') || 
                profileName.contains('System Administrator');
            
            result.put('isGlobalView', isGlobalView);
            
            // If NOT global view, determine user's Sales Manager unit
            if (!isGlobalView) {
                String salesManagerUnit = null;
                
                // If user is linked to a Contact, find their Candidate record
                if (currentUser.ContactId != null) {
                    List<Candidate__c> candidates = [
                        SELECT Sales_Manager__c
                        FROM Candidate__c
                        WHERE Contact__c = :currentUser.ContactId
                        AND Sales_Manager__c != null
                        LIMIT 1
                    ];
                    
                    if (!candidates.isEmpty()) {
                        salesManagerUnit = candidates[0].Sales_Manager__c;
                    }
                }
                
                result.put('salesManagerUnit', salesManagerUnit);
                
                // If no Sales Manager found, return error
                if (salesManagerUnit == null) {
                    result.put('error', 'Unable to determine your Sales Manager unit. Please contact your administrator.');
                }
            } else {
                result.put('salesManagerUnit', null); // Global view sees all
            }
            
            return result;
            
        } catch (Exception e) {
            result.put('error', 'Error determining user role: ' + e.getMessage());
            return result;
        }
    }
    
    /**
     * Get list of Sales Manager units for dropdown
     * @return Sorted list of unique Sales Manager names
     */
    @AuraEnabled(cacheable=true)
    public static List<String> getSalesManagerUnits() {
        List<String> units = new List<String>();
        
        try {
            for (AggregateResult ar : [
                SELECT Sales_Manager__c
                FROM Candidate__c
                WHERE Sales_Manager__c != null
                GROUP BY Sales_Manager__c
                ORDER BY Sales_Manager__c ASC
            ]) {
                units.add((String)ar.get('Sales_Manager__c'));
            }
            
            return units;
            
        } catch (Exception e) {
            System.debug('Error getting Sales Manager units: ' + e.getMessage());
            return new List<String>();
        }
    }
    
    /**
     * Get candidate pipeline data by stage for a Sales Manager
     * @param salesManagerUnit Sales Manager name or "All Units"
     * @return Map with stageData (List) and total (Integer)
     */
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getCandidatePipelineByStage(String salesManagerUnit) {
        Map<String, Object> pipeline = new Map<String, Object>();
        
        try {
            // Build dynamic query with filter
            String query = 'SELECT Highest_Level_Achieved__c stage, COUNT(Id) cnt ' +
                          'FROM Candidate__c ' +
                          'WHERE Status__c = \'Active/In Process\' ';
            
            // Add Sales Manager filter if not "All Units"
            if (salesManagerUnit != 'All Units' && String.isNotBlank(salesManagerUnit)) {
                query += 'AND Sales_Manager__c = :salesManagerUnit ';
            }
            
            query += 'GROUP BY Highest_Level_Achieved__c ' +
                    'ORDER BY Highest_Level_Achieved__c';
            
            List<AggregateResult> stageResults = Database.query(query);
            
            // Format stage data
            List<Map<String, Object>> stageData = new List<Map<String, Object>>();
            Integer totalCount = 0;
            
            for (AggregateResult result : stageResults) {
                String stage = result.get('stage') != null ? (String)result.get('stage') : 'Not Set';
                Integer count = (Integer)result.get('cnt');
                totalCount += count;
                
                stageData.add(new Map<String, Object>{
                    'label' => stage,
                    'value' => count
                });
            }
            
            pipeline.put('stageData', stageData);
            pipeline.put('total', totalCount);
            
        } catch (Exception e) {
            System.debug('Error getting candidate pipeline by stage: ' + e.getMessage());
            pipeline.put('stageData', new List<Map<String, Object>>());
            pipeline.put('total', 0);
            pipeline.put('error', 'Error loading pipeline data: ' + e.getMessage());
        }
        
        return pipeline;
    }
    
    /**
     * Get Contract B agent progress data
     * @param salesManagerUnit Sales Manager name or "All Units"
     * @return List of Contract B agent data with progress metrics
     */
    @AuraEnabled(cacheable=false)
    public static List<ContractBAgentData> getContractBAgentProgress(String salesManagerUnit) {
        List<ContractBAgentData> results = new List<ContractBAgentData>();
        
        try {
            // Build dynamic query with filter
            String query = 'SELECT Id, First_Name__c, Last_Name__c, Contact__c, Sales_Manager__c, Start_Date__c, ' +
                          'Extension_Granted__c, Total_FYC__c ' +
                          'FROM Candidate__c ' +
                          'WHERE Contract_Type__c = \'Contract B\' ' +
                          'AND Contact__c != null ';
            
            // Add Sales Manager filter if not "All Units"
            if (salesManagerUnit != 'All Units' && String.isNotBlank(salesManagerUnit)) {
                query += 'AND Sales_Manager__c = :salesManagerUnit ';
            }
            
            query += 'ORDER BY Last_Name__c, First_Name__c ASC';
            
            List<Candidate__c> candidates = Database.query(query);
            
            // If no candidates, return empty list
            if (candidates.isEmpty()) {
                return results;
            }
            
            // Collect Contact IDs for Opportunity queries
            Set<Id> contactIds = new Set<Id>();
            for (Candidate__c cand : candidates) {
                if (cand.Contact__c != null) {
                    contactIds.add(cand.Contact__c);
                }
            }
            
            // Get Opportunity metrics
            Map<String, Map<Id, Object>> oppMetrics = getOpportunityMetrics(contactIds);
            Map<Id, Integer> submittedMap = (Map<Id, Integer>)oppMetrics.get('submitted');
            Map<Id, Integer> wonMap = (Map<Id, Integer>)oppMetrics.get('won');
            Map<Id, Decimal> fycMap = (Map<Id, Decimal>)oppMetrics.get('fyc');
            
            // Build result data
            for (Candidate__c cand : candidates) {
                ContractBAgentData data = new ContractBAgentData();
                
                // Construct agent name from first and last name
                String firstName = cand.First_Name__c != null ? cand.First_Name__c : '';
                String lastName = cand.Last_Name__c != null ? cand.Last_Name__c : '';
                data.agentName = (firstName + ' ' + lastName).trim();
                
                data.candidateId = cand.Id;
                data.contactId = cand.Contact__c;
                data.startDate = cand.Start_Date__c;
                
                // Get Opportunity counts
                data.opportunitiesSubmitted = submittedMap.containsKey(cand.Contact__c) ? 
                    submittedMap.get(cand.Contact__c) : 0;
                data.opportunitiesWon = wonMap.containsKey(cand.Contact__c) ? 
                    wonMap.get(cand.Contact__c) : 0;
                data.totalFYC = fycMap.containsKey(cand.Contact__c) ? 
                    fycMap.get(cand.Contact__c) : 0;
                
                // Calculate requirements met (5+ submissions AND $2500+ FYC)
                data.requirementsMet = (data.opportunitiesSubmitted >= 5 && data.totalFYC >= 2500);
                
                // Calculate deadline and days remaining
                if (data.startDate != null) {
                    Integer daysToAdd = cand.Extension_Granted__c == true ? 240 : 120;
                    data.deadline = data.startDate.addDays(daysToAdd);
                    data.daysRemaining = data.startDate.daysBetween(Date.today()) < daysToAdd ? 
                        daysToAdd - data.startDate.daysBetween(Date.today()) : 0;
                } else {
                    data.deadline = null;
                    data.daysRemaining = 0;
                }
                
                // Calculate progress percentages
                data.submissionsProgress = calculateProgress(data.opportunitiesSubmitted, 5);
                data.fycProgress = calculateProgress(data.totalFYC, 2500);
                
                // Determine status
                data.status = determineStatus(data.requirementsMet, data.daysRemaining);
                
                results.add(data);
            }
            
            return results;
            
        } catch (Exception e) {
            System.debug('Error getting Contract B agent progress: ' + e.getMessage());
            throw new AuraHandledException('Error loading Contract B data: ' + e.getMessage());
        }
    }
    
    /**
     * Get Contract A agent progress data
     * @param salesManagerUnit Sales Manager name or "All Units"
     * @return List of Contract A agent data with YTD metrics
     */
    @AuraEnabled(cacheable=false)
    public static List<ContractAAgentData> getContractAAgentProgress(String salesManagerUnit) {
        List<ContractAAgentData> results = new List<ContractAAgentData>();
        
        try {
            // First, get Candidates with Sales Manager to filter by
            String candidateQuery = 'SELECT Id, Name, Contact__c, Sales_Manager__c ' +
                                   'FROM Candidate__c ' +
                                   'WHERE Contact__c != null ' +
                                   'AND Sales_Manager__c != null ';
            
            // Add Sales Manager filter if not "All Units"
            if (salesManagerUnit != 'All Units' && String.isNotBlank(salesManagerUnit)) {
                candidateQuery += 'AND Sales_Manager__c = :salesManagerUnit ';
            }
            
            List<Candidate__c> candidates = Database.query(candidateQuery);
            
            if (candidates.isEmpty()) {
                return results;
            }
            
            // Build maps for lookup
            Map<Id, Candidate__c> contactToCandidateMap = new Map<Id, Candidate__c>();
            Set<Id> contactIds = new Set<Id>();
            for (Candidate__c cand : candidates) {
                contactToCandidateMap.put(cand.Contact__c, cand);
                contactIds.add(cand.Contact__c);
            }
            
            // Query Contract_Qualification__c records for these contacts
            List<Contract_Qualification__c> qualifications = [
                SELECT Id, Name, Agent__c, Contract_Date__c, All_YTD_FYC__c, 
                       YTD_WLADL__c, WLADL_Contract_Minimum__c, WLADL_GDC_Qual_Status__c
                FROM Contract_Qualification__c
                WHERE Agent__c IN :contactIds
                ORDER BY Name ASC
            ];
            
            // If no qualifications, return empty list
            if (qualifications.isEmpty()) {
                return results;
            }
            
            // Get Opportunity metrics
            Map<String, Map<Id, Object>> oppMetrics = getOpportunityMetrics(contactIds);
            Map<Id, Integer> submittedMap = (Map<Id, Integer>)oppMetrics.get('submitted');
            Map<Id, Integer> wonMap = (Map<Id, Integer>)oppMetrics.get('won');
            
            // Build result data
            for (Contract_Qualification__c qual : qualifications) {
                // Get the corresponding Candidate for this Agent (Contact)
                Candidate__c candidate = contactToCandidateMap.get(qual.Agent__c);
                if (candidate == null) {
                    continue; // Skip if no matching Candidate
                }
                
                ContractAAgentData data = new ContractAAgentData();
                
                data.agentName = candidate.Name;
                data.contractDate = qual.Contract_Date__c;
                data.ytdFYC = qual.All_YTD_FYC__c != null ? qual.All_YTD_FYC__c : 0;
                data.ytdWLADL = qual.YTD_WLADL__c != null ? qual.YTD_WLADL__c : 0;
                data.wladlGoal = qual.WLADL_Contract_Minimum__c != null ? qual.WLADL_Contract_Minimum__c : 0;
                data.qualStatus = qual.WLADL_GDC_Qual_Status__c;
                
                // Get Opportunity counts (NEW feature)
                Id contactId = qual.Agent__c;
                data.opportunitiesSubmitted = submittedMap.containsKey(contactId) ? 
                    submittedMap.get(contactId) : 0;
                data.opportunitiesWon = wonMap.containsKey(contactId) ? 
                    wonMap.get(contactId) : 0;
                
                // Calculate progress percentage
                data.progress = calculateProgress(data.ytdWLADL, data.wladlGoal);
                
                results.add(data);
            }
            
            return results;
            
        } catch (Exception e) {
            System.debug('Error getting Contract A agent progress: ' + e.getMessage());
            throw new AuraHandledException('Error loading Contract A data: ' + e.getMessage());
        }
    }
    
    // ============================================================================
    // HELPER METHODS
    // ============================================================================
    
    /**
     * Get Opportunity metrics for given Contact IDs
     * @param contactIds Set of Contact IDs (agents)
     * @return Map with 'submitted', 'won', and 'fyc' maps
     */
    private static Map<String, Map<Id, Object>> getOpportunityMetrics(Set<Id> contactIds) {
        if (contactIds == null || contactIds.isEmpty()) {
            return new Map<String, Map<Id, Object>>{
                'submitted' => new Map<Id, Object>(),
                'won' => new Map<Id, Object>(),
                'fyc' => new Map<Id, Object>()
            };
        }
        
        // Query 1: All submissions
        Map<Id, Integer> submittedMap = new Map<Id, Integer>();
        for (AggregateResult ar : [
            SELECT Soliciting_Agent__c, COUNT(Id) oppCount
            FROM Opportunity
            WHERE Soliciting_Agent__c IN :contactIds
            GROUP BY Soliciting_Agent__c
        ]) {
            submittedMap.put((Id)ar.get('Soliciting_Agent__c'), (Integer)ar.get('oppCount'));
        }
        
        // Query 2: Won opportunities + FYC
        Map<Id, Integer> wonMap = new Map<Id, Integer>();
        Map<Id, Decimal> fycMap = new Map<Id, Decimal>();
        for (AggregateResult ar : [
            SELECT Soliciting_Agent__c, 
                   COUNT(Id) wonCount,
                   SUM(Amount) totalFYC
            FROM Opportunity
            WHERE Soliciting_Agent__c IN :contactIds
            AND StageName = 'Closed Won'
            GROUP BY Soliciting_Agent__c
        ]) {
            Id contactId = (Id)ar.get('Soliciting_Agent__c');
            wonMap.put(contactId, (Integer)ar.get('wonCount'));
            fycMap.put(contactId, ar.get('totalFYC') != null ? (Decimal)ar.get('totalFYC') : 0);
        }
        
        return new Map<String, Map<Id, Object>>{
            'submitted' => (Map<Id, Object>)submittedMap,
            'won' => (Map<Id, Object>)wonMap,
            'fyc' => (Map<Id, Object>)fycMap
        };
    }
    
    /**
     * Calculate progress percentage (capped at 100%)
     * @param current Current value
     * @param target Target value
     * @return Progress percentage (0-100)
     */
    private static Decimal calculateProgress(Decimal current, Decimal target) {
        if (target == null || target <= 0) {
            return 0;
        }
        if (current == null) {
            current = 0;
        }
        Decimal progress = (current / target) * 100;
        return Math.min(progress, 100);
    }
    
    /**
     * Determine status based on requirements met and days remaining
     * @param requirementsMet Whether requirements are met
     * @param daysRemaining Days until deadline
     * @return Status string: Complete, Critical, At Risk, On Track
     */
    private static String determineStatus(Boolean requirementsMet, Integer daysRemaining) {
        if (requirementsMet) {
            return 'Complete';
        }
        if (daysRemaining < 14) {
            return 'Critical';
        }
        if (daysRemaining < 30) {
            return 'At Risk';
        }
        return 'On Track';
    }
    
    // ============================================================================
    // WRAPPER CLASSES
    // ============================================================================
    
    /**
     * Wrapper class for Contract B agent data
     */
    public class ContractBAgentData {
        @AuraEnabled public String agentName;
        @AuraEnabled public String candidateId;
        @AuraEnabled public String contactId;
        @AuraEnabled public Date startDate;
        @AuraEnabled public Date deadline;
        @AuraEnabled public Integer daysRemaining;
        @AuraEnabled public Integer opportunitiesSubmitted;
        @AuraEnabled public Integer opportunitiesWon;
        @AuraEnabled public Decimal totalFYC;
        @AuraEnabled public Decimal submissionsProgress; // 0-100
        @AuraEnabled public Decimal fycProgress; // 0-100
        @AuraEnabled public String status; // 'Complete', 'Critical', 'At Risk', 'On Track'
        @AuraEnabled public Boolean requirementsMet;
    }
    
    /**
     * Wrapper class for Contract A agent data
     */
    public class ContractAAgentData {
        @AuraEnabled public String agentName;
        @AuraEnabled public Date contractDate;
        @AuraEnabled public Decimal ytdFYC;
        @AuraEnabled public Decimal ytdWLADL;
        @AuraEnabled public Decimal wladlGoal;
        @AuraEnabled public Decimal progress; // 0-100
        @AuraEnabled public String qualStatus;
        @AuraEnabled public Integer opportunitiesSubmitted;
        @AuraEnabled public Integer opportunitiesWon;
    }
}
