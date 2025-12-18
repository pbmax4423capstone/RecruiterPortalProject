public without sharing class RecruiterDashboardController {

    @AuraEnabled
    public static Map<String, Object> getDashboardData() {
        Map<String, Object> dashboardData = new Map<String, Object>();
        
        // Get current user's call statistics (priority section at top)
        Map<String, Integer> userCallStats = getCurrentUserCallStats();
        dashboardData.put('userCallStats', userCallStats);
        
        // Get candidate statistics
        Map<String, Integer> candidateStats = getCandidateStats();
        dashboardData.put('candidateStats', candidateStats);
        
        // Get scheduled interview statistics from Candidate object
        Map<String, Integer> scheduledInterviewStats = getScheduledInterviewStats();
        dashboardData.put('scheduledInterviewStats', scheduledInterviewStats);
        
        // Recent activity now loaded separately via wire adapter in LWC
        // to reduce SOQL query count and improve performance
        dashboardData.put('recentActivity', new List<Map<String, Object>>());
        
        // Get recruiting metrics by type
        List<Map<String, Object>> interviewsByType = getInterviewsByType();
        dashboardData.put('interviewsByType', interviewsByType);
        
        // Get detailed interview statistics matching the dashboard reports
        Map<String, Object> detailedInterviewStats = getDetailedInterviewStats();
        dashboardData.put('detailedInterviewStats', detailedInterviewStats);
        
        // Get recruiting performance metrics
        Map<String, Integer> performanceMetrics = getPerformanceMetrics();
        dashboardData.put('performanceMetrics', performanceMetrics);
        
        // Get sales manager metrics
        List<Map<String, Object>> salesManagerMetrics = getSalesManagerMetrics();
        dashboardData.put('salesManagerMetrics', salesManagerMetrics);
        
        return dashboardData;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Integer> getCandidateStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        
        try {
            // Active/In Process Candidates
            stats.put('active', [SELECT COUNT() FROM Candidate__c WHERE Status__c = 'Active/In Process']);
            
            // Leads
            stats.put('leads', [SELECT COUNT() FROM Candidate__c WHERE Status__c = 'Lead']);
            
            // Total Candidates
            stats.put('total', [SELECT COUNT() FROM Candidate__c]);
            
            // New Candidates This Week
            stats.put('newThisWeek', [SELECT COUNT() FROM Candidate__c WHERE CreatedDate = THIS_WEEK]);
            
            // Candidates with upcoming meetings
            stats.put('upcomingMeetings', [SELECT COUNT() FROM Candidate__c WHERE Next_Meeting_Date__c >= TODAY]);
            
        } catch (Exception e) {
            System.debug('Error in getCandidateStats: ' + e.getMessage());
            // Return default values if there's an error
            stats.put('active', 0);
            stats.put('leads', 0);
            stats.put('total', 0);
            stats.put('newThisWeek', 0);
            stats.put('upcomingMeetings', 0);
        }
        
        return stats;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getActiveCandidateAnalytics() {
        Map<String, Object> analytics = new Map<String, Object>();
        
        try {
            // Get Active/In Process candidates with Sales Manager
            List<AggregateResult> managerResults = [
                SELECT Sales_Manager__c manager, COUNT(Id) cnt
                FROM Candidate__c 
                WHERE Status__c = 'Active/In Process' 
                AND Sales_Manager__c != null
                GROUP BY Sales_Manager__c
                ORDER BY Sales_Manager__c
            ];
            
            // Format manager data with reassignments
            List<Map<String, Object>> managerData = new List<Map<String, Object>>();
            Map<String, Integer> managerCounts = new Map<String, Integer>();
            
            for (AggregateResult result : managerResults) {
                String managerName = result.get('manager') != null ? (String)result.get('manager') : 'Unassigned';
                Integer count = (Integer)result.get('cnt');
                
                // Skip inactive managers and reassign their candidates
                if (managerName == 'Scott Primm') {
                    // Reassign Scott Primm's candidates to Bradley Sofonia
                    managerName = 'Bradley Sofonia';
                } else if (managerName == 'Diljeet Masuda') {
                    // Reassign Diljeet Masuda's candidates to Elizabeth Kagele
                    managerName = 'Elizabeth Kagele';
                }
                
                // Normalize manager names (Brad Sofonia = Bradley Sofonia)
                if (managerName == 'Brad Sofonia') {
                    managerName = 'Bradley Sofonia';
                }
                
                // Accumulate counts for managers
                if (managerCounts.containsKey(managerName)) {
                    managerCounts.put(managerName, managerCounts.get(managerName) + count);
                } else {
                    managerCounts.put(managerName, count);
                }
            }
            
            // Convert to list format for pie chart
            for (String manager : managerCounts.keySet()) {
                Map<String, Object> dataPoint = new Map<String, Object>();
                dataPoint.put('label', manager);
                dataPoint.put('Name', manager);
                dataPoint.put('value', managerCounts.get(manager));
                dataPoint.put('Count', managerCounts.get(manager));
                managerData.add(dataPoint);
            }
            
            // For pie chart, we'll use manager data as the main data
            analytics.put('byManager', managerData);
            analytics.put('byLevel', new List<Map<String, Object>>()); // Empty for now
            
        } catch (Exception e) {
            System.debug('Error in getActiveCandidateAnalytics: ' + e.getMessage());
            analytics.put('byLevel', new List<Map<String, Object>>());
            analytics.put('byManager', new List<Map<String, Object>>());
        }
        
        return analytics;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getInterviewStatsByType() {
        Map<String, Object> interviewStats = new Map<String, Object>();
        
        try {
            // Count interviews by checking completed date fields on Candidate__c
            Integer attractionCount = [SELECT COUNT() FROM Candidate__c WHERE Attraction_Interview_Date_Completed__c != null];
            Integer si1Count = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c != null];
            Integer si2Count = [SELECT COUNT() FROM Candidate__c WHERE SI_2_Date_Completed__c != null];
            Integer si3Count = [SELECT COUNT() FROM Candidate__c WHERE SI_3_Completed__c != null];
            Integer careerCount = [SELECT COUNT() FROM Candidate__c WHERE Career_Presentation_Date_Completed__c != null];
            
            // Calculate total
            Integer totalInterviews = attractionCount + si1Count + si2Count + si3Count + careerCount;
            
            // Get this week's completed interviews
            Date weekStart = Date.today().toStartOfWeek();
            Date weekEnd = weekStart.addDays(6);
            
            Integer thisWeekCount = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE (Attraction_Interview_Date_Completed__c >= :weekStart AND Attraction_Interview_Date_Completed__c <= :weekEnd)
                OR (SI_1_Date_Completed__c >= :weekStart AND SI_1_Date_Completed__c <= :weekEnd)
                OR (SI_2_Date_Completed__c >= :weekStart AND SI_2_Date_Completed__c <= :weekEnd)
                OR (SI_3_Completed__c >= :weekStart AND SI_3_Completed__c <= :weekEnd)
                OR (Career_Presentation_Date_Completed__c >= :weekStart AND Career_Presentation_Date_Completed__c <= :weekEnd)
            ];
            
            // Get this month's completed interviews
            Date monthStart = Date.today().toStartOfMonth();
            Date monthEnd = monthStart.addMonths(1).addDays(-1);
            
            Integer attractionThisMonth = [SELECT COUNT() FROM Candidate__c WHERE Attraction_Interview_Date_Completed__c >= :monthStart AND Attraction_Interview_Date_Completed__c <= :monthEnd];
            Integer si1ThisMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_1_Date_Completed__c >= :monthStart AND SI_1_Date_Completed__c <= :monthEnd];
            Integer si2ThisMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_2_Date_Completed__c >= :monthStart AND SI_2_Date_Completed__c <= :monthEnd];
            Integer si3ThisMonth = [SELECT COUNT() FROM Candidate__c WHERE SI_3_Completed__c >= :monthStart AND SI_3_Completed__c <= :monthEnd];
            Integer careerThisMonth = [SELECT COUNT() FROM Candidate__c WHERE Career_Presentation_Date_Completed__c >= :monthStart AND Career_Presentation_Date_Completed__c <= :monthEnd];
            
            Integer thisMonthTotal = attractionThisMonth + si1ThisMonth + si2ThisMonth + si3ThisMonth + careerThisMonth;
            
            // Get scheduled interviews (future scheduled dates)
            Integer scheduledCount = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Attraction_Interview_Date_Scheduled__c >= TODAY
                OR SI_1_Date_Scheduled__c >= TODAY
                OR SI_2_Date_Scheduled__c >= TODAY
                OR SI_3_Scheduled__c >= TODAY
                OR Career_Presentation_Date_Scheduled__c >= TODAY
            ];
            
            interviewStats.put('attraction', attractionThisMonth);
            interviewStats.put('si1', si1ThisMonth);
            interviewStats.put('si2', si2ThisMonth);
            interviewStats.put('si3', si3ThisMonth);
            interviewStats.put('career', careerThisMonth);
            interviewStats.put('total', thisMonthTotal);
            interviewStats.put('thisWeek', thisWeekCount);
            interviewStats.put('scheduled', scheduledCount);
            interviewStats.put('allTimeTotal', totalInterviews);
            
        } catch (Exception e) {
            System.debug('Error in getInterviewStatsByType: ' + e.getMessage());
            // Return default values on error
            interviewStats.put('attraction', 0);
            interviewStats.put('si1', 0);
            interviewStats.put('si2', 0);
            interviewStats.put('si3', 0);
            interviewStats.put('career', 0);
            interviewStats.put('total', 0);
            interviewStats.put('thisWeek', 0);
            interviewStats.put('scheduled', 0);
        }
        
        return interviewStats;
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getInterviewStatsByInterviewer() {
        List<Map<String, Object>> interviewerStats = new List<Map<String, Object>>();
        
        try {
            // Get interview counts by interviewer from Candidate "Conducted By" fields
            // Since Conducted By fields are text/picklist (CP_Conducted_by__c is multi-select), 
            // we need to query and count manually
            List<Candidate__c> attractionCandidates = [
                SELECT Attraction_Interview_Conducted_By__c
                FROM Candidate__c 
                WHERE Attraction_Interview_Date_Completed__c != null 
                AND Attraction_Interview_Conducted_By__c != null
            ];
            
            List<Candidate__c> careerCandidates = [
                SELECT CP_Conducted_by__c
                FROM Candidate__c 
                WHERE Career_Presentation_Date_Completed__c != null 
                AND CP_Conducted_by__c != null
            ];
            
            // Build interviewer map by counting manually
            Map<String, Map<String, Object>> interviewerMap = new Map<String, Map<String, Object>>();
            
            // Process Attraction interviews
            for (Candidate__c cand : attractionCandidates) {
                String interviewerName = cand.Attraction_Interview_Conducted_By__c;
                
                if (!interviewerMap.containsKey(interviewerName)) {
                    interviewerMap.put(interviewerName, new Map<String, Object>{
                        'interviewerName' => interviewerName,
                        'attraction' => 0,
                        'si1' => 0,
                        'si2' => 0,
                        'si3' => 0,
                        'career' => 0,
                        'total' => 0
                    });
                }
                
                Map<String, Object> interviewer = interviewerMap.get(interviewerName);
                interviewer.put('attraction', (Integer)interviewer.get('attraction') + 1);
                interviewer.put('total', (Integer)interviewer.get('total') + 1);
            }
            
            // Process Career Presentation interviews (multi-select picklist)
            for (Candidate__c cand : careerCandidates) {
                // CP_Conducted_by__c is multi-select, so split by semicolon
                if (cand.CP_Conducted_by__c != null) {
                    List<String> interviewers = cand.CP_Conducted_by__c.split(';');
                    for (String interviewerName : interviewers) {
                        interviewerName = interviewerName.trim();
                        
                        if (!interviewerMap.containsKey(interviewerName)) {
                            interviewerMap.put(interviewerName, new Map<String, Object>{
                                'interviewerName' => interviewerName,
                                'attraction' => 0,
                                'si1' => 0,
                                'si2' => 0,
                                'si3' => 0,
                                'career' => 0,
                                'total' => 0
                            });
                        }
                        
                        Map<String, Object> interviewer = interviewerMap.get(interviewerName);
                        interviewer.put('career', (Integer)interviewer.get('career') + 1);
                        interviewer.put('total', (Integer)interviewer.get('total') + 1);
                    }
                }
            }
            
            // Convert to list
            interviewerStats.addAll(interviewerMap.values());
            
        } catch (Exception e) {
            System.debug('Error in getInterviewStatsByInterviewer: ' + e.getMessage());
        }
        
        return interviewerStats;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getInterviewTypeWithInterviewerStats() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Get current month date range
            Date monthStart = Date.today().toStartOfMonth();
            Date monthEnd = monthStart.addMonths(1).addDays(-1);
            DateTime monthStartDT = DateTime.newInstance(monthStart.year(), monthStart.month(), monthStart.day(), 0, 0, 0);
            DateTime monthEndDT = DateTime.newInstance(monthEnd.year(), monthEnd.month(), monthEnd.day(), 23, 59, 59);
            
            // Initialize structure for each interview type
            List<Map<String, Object>> attractionByInterviewer = new List<Map<String, Object>>();
            List<Map<String, Object>> si1ByInterviewer = new List<Map<String, Object>>();
            List<Map<String, Object>> si2ByInterviewer = new List<Map<String, Object>>();
            List<Map<String, Object>> si3ByInterviewer = new List<Map<String, Object>>();
            List<Map<String, Object>> careerByInterviewer = new List<Map<String, Object>>();
            
            // Query Interview__c records grouped by Interview_Type__c and Conducted_By
            // Get Attraction interviews (Interview_Type__c = 'Attraction')
            List<AggregateResult> attractionResults = [
                SELECT Conducted_By__r.Name interviewer, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c = 'Attraction'
                AND Interview_Status__c = 'Completed'
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                AND Conducted_By__c != null
                GROUP BY Conducted_By__r.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult ar : attractionResults) {
                attractionByInterviewer.add(new Map<String, Object>{
                    'interviewer' => (String)ar.get('interviewer'),
                    'count' => (Integer)ar.get('cnt')
                });
            }
            
            // Get SI1 interviews (Interview_Type__c = 'SI1')
            List<AggregateResult> si1Results = [
                SELECT Conducted_By__r.Name interviewer, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c = 'SI1'
                AND Interview_Status__c = 'Completed'
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                AND Conducted_By__c != null
                GROUP BY Conducted_By__r.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult ar : si1Results) {
                si1ByInterviewer.add(new Map<String, Object>{
                    'interviewer' => (String)ar.get('interviewer'),
                    'count' => (Integer)ar.get('cnt')
                });
            }
            
            // Get SI2 interviews (Interview_Type__c = 'SI2')
            List<AggregateResult> si2Results = [
                SELECT Conducted_By__r.Name interviewer, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c = 'SI2'
                AND Interview_Status__c = 'Completed'
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                AND Conducted_By__c != null
                GROUP BY Conducted_By__r.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult ar : si2Results) {
                si2ByInterviewer.add(new Map<String, Object>{
                    'interviewer' => (String)ar.get('interviewer'),
                    'count' => (Integer)ar.get('cnt')
                });
            }
            
            // Get SI3 interviews (Interview_Type__c = 'SI3')
            List<AggregateResult> si3Results = [
                SELECT Conducted_By__r.Name interviewer, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c = 'SI3'
                AND Interview_Status__c = 'Completed'
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                AND Conducted_By__c != null
                GROUP BY Conducted_By__r.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult ar : si3Results) {
                si3ByInterviewer.add(new Map<String, Object>{
                    'interviewer' => (String)ar.get('interviewer'),
                    'count' => (Integer)ar.get('cnt')
                });
            }
            
            // Get Career interviews (Interview_Type__c = 'Career')
            List<AggregateResult> careerResults = [
                SELECT Conducted_By__r.Name interviewer, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c = 'Career'
                AND Interview_Status__c = 'Completed'
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                AND Conducted_By__c != null
                GROUP BY Conducted_By__r.Name
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult ar : careerResults) {
                careerByInterviewer.add(new Map<String, Object>{
                    'interviewer' => (String)ar.get('interviewer'),
                    'count' => (Integer)ar.get('cnt')
                });
            }
            
            result.put('attractionByInterviewer', attractionByInterviewer);
            result.put('si1ByInterviewer', si1ByInterviewer);
            result.put('si2ByInterviewer', si2ByInterviewer);
            result.put('si3ByInterviewer', si3ByInterviewer);
            result.put('careerByInterviewer', careerByInterviewer);
            
            System.debug('Interview type with interviewer stats (THIS MONTH): ' + result);
            
        } catch (Exception e) {
            System.debug('Error in getInterviewTypeWithInterviewerStats: ' + e.getMessage());
            // Return empty data structure on error
            result.put('attractionByInterviewer', new List<Map<String, Object>>());
            result.put('si1ByInterviewer', new List<Map<String, Object>>());
            result.put('si2ByInterviewer', new List<Map<String, Object>>());
            result.put('si3ByInterviewer', new List<Map<String, Object>>());
            result.put('careerByInterviewer', new List<Map<String, Object>>());
        }
        
        return result;
    }

    @AuraEnabled
    public static List<Map<String, Object>> getInterviewDetailsByInterviewer(String interviewer, String interviewType) {
        List<Map<String, Object>> interviewDetails = new List<Map<String, Object>>();
        
        try {
            // Get current month date range
            Date monthStart = Date.today().toStartOfMonth();
            Date monthEnd = monthStart.addMonths(1).addDays(-1);
            DateTime monthStartDT = DateTime.newInstance(monthStart.year(), monthStart.month(), monthStart.day(), 0, 0, 0);
            DateTime monthEndDT = DateTime.newInstance(monthEnd.year(), monthEnd.month(), monthEnd.day(), 23, 59, 59);
            
            // Map interview type names to Interview__c picklist values
            String interviewTypeValue = '';
            if (interviewType == 'Ci-First' || interviewType == 'Attraction') {
                interviewTypeValue = 'Attraction';
            } else if (interviewType == 'Align-2nd' || interviewType == 'Structured Interview 1') {
                interviewTypeValue = 'SI1';
            } else if (interviewType == 'Plan-3rd' || interviewType == 'Structured Interview 2') {
                interviewTypeValue = 'SI2';
            } else if (interviewType == 'Present-4th' || interviewType == 'Structured Interview 3') {
                interviewTypeValue = 'SI3';
            } else if (interviewType == 'Optional-5th' || interviewType == 'Career') {
                interviewTypeValue = 'Career';
            }
            
            // Query Interview__c records
            List<Interview__c> interviews = [
                SELECT Id, Name, Candidate__r.Name, Conducted_By__r.Name, 
                       Interview_Type__c, Interview_Status__c, CreatedDate, Notes__c
                FROM Interview__c
                WHERE Interview_Type__c = :interviewTypeValue
                AND Interview_Status__c = 'Completed'
                AND Conducted_By__r.Name = :interviewer
                AND CreatedDate >= :monthStartDT
                AND CreatedDate <= :monthEndDT
                ORDER BY CreatedDate DESC
            ];
            
            for (Interview__c interview : interviews) {
                interviewDetails.add(new Map<String, Object>{
                    'id' => interview.Id,
                    'candidateName' => interview.Candidate__r?.Name != null ? interview.Candidate__r.Name : 'N/A',
                    'interviewDate' => interview.CreatedDate,
                    'status' => interview.Interview_Status__c,
                    'notes' => interview.Notes__c != null ? interview.Notes__c : ''
                });
            }
            
            System.debug('Retrieved ' + interviewDetails.size() + ' interview details for ' + interviewer + ' - ' + interviewType);
            
        } catch (Exception e) {
            System.debug('Error in getInterviewDetailsByInterviewer: ' + e.getMessage());
        }
        
        return interviewDetails;
    }

    @AuraEnabled
    public static String reassignInterviewsToSalesManagers() {
        try {
            // First, find Elizabeth Kagele specifically as she's the preferred Sales Manager
            User elizabethKagele = null;
            try {
                elizabethKagele = [
                    SELECT Id, Name, Profile.Name, UserRole.Name, IsActive
                    FROM User 
                    WHERE Name = 'Elizabeth Kagele' AND IsActive = true
                    LIMIT 1
                ];
                System.debug('Found Elizabeth Kagele: ' + elizabethKagele.Name + ' - Active: ' + elizabethKagele.IsActive);
            } catch (Exception e) {
                System.debug('Elizabeth Kagele not found: ' + e.getMessage());
            }
            
            // Get users who are Sales Managers or Recruiters based on profile or role
            List<User> authorizedInterviewers = [
                SELECT Id, Name, Profile.Name, UserRole.Name, IsActive
                FROM User 
                WHERE IsActive = true
                AND (
                    Profile.Name LIKE '%Sales Manager%' OR 
                    Profile.Name LIKE '%Recruiter%' OR
                    Profile.Name LIKE '%Sales%Manager%' OR
                    UserRole.Name LIKE '%Sales Manager%' OR
                    UserRole.Name LIKE '%Recruiter%' OR
                    UserRole.Name LIKE '%Sales%' OR
                    Name = 'Elizabeth Kagele'
                )
                LIMIT 20
            ];
            
            System.debug('Found authorized interviewers: ' + authorizedInterviewers.size());
            for (User u : authorizedInterviewers) {
                System.debug('Authorized interviewer: ' + u.Name + ' - Profile: ' + u.Profile.Name + ' - Role: ' + u.UserRole?.Name + ' - Active: ' + u.IsActive);
            }
            
            if (authorizedInterviewers.isEmpty() && elizabethKagele == null) {
                // Fallback: get any active users with management-related names or profiles
                authorizedInterviewers = [
                    SELECT Id, Name, Profile.Name, IsActive
                    FROM User 
                    WHERE IsActive = true
                    AND (Name LIKE '%Manager%' OR Name LIKE '%Sales%' OR Name LIKE '%Recruit%' OR Name = 'Elizabeth Kagele')
                    LIMIT 10
                ];
                System.debug('Fallback: Found ' + authorizedInterviewers.size() + ' users with management-related names');
            }
            
            if (authorizedInterviewers.isEmpty() && elizabethKagele == null) {
                return 'No authorized interviewers (Sales Managers/Recruiters) found, including Elizabeth Kagele';
            }
            
            // Get all interviews including those conducted by inactive users or specific users (Diljeet, Scott)
            List<Interview__c> allInterviews = [
                SELECT Id, Conducted_By__c, Interview_Type__c, Conducted_By__r.Name, Conducted_By__r.Profile.Name, Conducted_By__r.IsActive
                FROM Interview__c 
                WHERE Conducted_By__c != null
                LIMIT 200
            ];
            
            if (allInterviews.isEmpty()) {
                return 'No interviews found';
            }
            
            // Check which interviews need reassignment
            Set<Id> authorizedUserIds = new Set<Id>();
            for (User u : authorizedInterviewers) {
                authorizedUserIds.add(u.Id);
            }
            
            List<Interview__c> interviewsToReassign = new List<Interview__c>();
            for (Interview__c interview : allInterviews) {
                String conductorName = interview.Conducted_By__r.Name;
                Boolean isInactive = !interview.Conducted_By__r.IsActive;
                Boolean isDiljeetOrScott = (conductorName == 'Diljeet Masuda' || conductorName == 'Scott Primm');
                Boolean isUnauthorized = !authorizedUserIds.contains(interview.Conducted_By__c);
                
                if (isInactive || isDiljeetOrScott || isUnauthorized) {
                    interviewsToReassign.add(interview);
                    String reason = '';
                    if (isInactive) reason += 'Inactive user ';
                    if (isDiljeetOrScott) reason += 'Diljeet/Scott (no longer active) ';
                    if (isUnauthorized) reason += 'Unauthorized user ';
                    
                    System.debug('Interview needs reassignment - Current conductor: ' + conductorName + 
                               ' (Profile: ' + interview.Conducted_By__r.Profile.Name + 
                               ', Active: ' + interview.Conducted_By__r.IsActive + ') - Reason: ' + reason);
                }
            }
            
            if (interviewsToReassign.isEmpty()) {
                return 'All ' + allInterviews.size() + ' interviews are already conducted by active authorized Sales Managers/Recruiters';
            }
            
            // Reassign interviews - prefer Elizabeth Kagele for all reassignments
            List<Interview__c> updatedInterviews = new List<Interview__c>();
            
            for (Interview__c interview : interviewsToReassign) {
                String oldConductorName = interview.Conducted_By__r.Name;
                Id newConductorId;
                String newConductorName;
                
                // Prefer Elizabeth Kagele for all reassignments
                if (elizabethKagele != null) {
                    newConductorId = elizabethKagele.Id;
                    newConductorName = elizabethKagele.Name;
                } else if (!authorizedInterviewers.isEmpty()) {
                    // Fallback to first authorized interviewer
                    newConductorId = authorizedInterviewers[0].Id;
                    newConductorName = authorizedInterviewers[0].Name;
                } else {
                    continue; // Skip if no one to assign to
                }
                
                interview.Conducted_By__c = newConductorId;
                updatedInterviews.add(interview);
                
                System.debug('Reassigning interview from ' + oldConductorName + ' to ' + newConductorName);
            }
            
            if (updatedInterviews.size() > 0) {
                update updatedInterviews;
                String preferredAssignee = elizabethKagele != null ? elizabethKagele.Name : 'authorized interviewers';
                String result = 'Successfully reassigned ' + updatedInterviews.size() + ' interviews to ' + preferredAssignee + ' (active Sales Manager/Recruiter)';
                System.debug(result);
                return result;
            }
            
            return 'No interviews needed reassignment';
            
        } catch (Exception e) {
            System.debug('Error in reassignInterviewsToSalesManagers: ' + e.getMessage());
            return 'Error: ' + e.getMessage();
        }
    }

    @AuraEnabled(cacheable=false)
    public static Map<String, Integer> getScheduledInterviewStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        
        try {
            // Count scheduled interviews by type based on Candidate fields
            stats.put('attractionScheduled', [SELECT COUNT() FROM Candidate__c 
                WHERE Attraction_Interview_Date_Scheduled__c >= TODAY]);
                
            stats.put('si1Scheduled', [SELECT COUNT() FROM Candidate__c 
                WHERE SI_1_Date_Scheduled__c >= TODAY]);
                
            stats.put('si2Scheduled', [SELECT COUNT() FROM Candidate__c 
                WHERE SI_2_Date_Scheduled__c >= TODAY]);
                
            stats.put('si3Scheduled', [SELECT COUNT() FROM Candidate__c 
                WHERE SI_3_Scheduled__c >= TODAY]);
                
            stats.put('careerScheduled', [SELECT COUNT() FROM Candidate__c 
                WHERE Career_Presentation_Date_Scheduled__c >= TODAY]);
            
            // Interview object statistics for completed interviews
            stats.put('completed', [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Completed']);
            stats.put('noShow', [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'No Show']);
            stats.put('canceled', [SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = 'Canceled']);
            stats.put('thisWeek', [SELECT COUNT() FROM Interview__c WHERE CreatedDate = THIS_WEEK]);
            
        } catch (Exception e) {
            System.debug('Error in getScheduledInterviewStats: ' + e.getMessage());
            stats.put('attractionScheduled', 0);
            stats.put('si1Scheduled', 0);
            stats.put('si2Scheduled', 0);
            stats.put('si3Scheduled', 0);
            stats.put('careerScheduled', 0);
            stats.put('completed', 0);
            stats.put('noShow', 0);
            stats.put('canceled', 0);
            stats.put('thisWeek', 0);
        }
        
        return stats;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getRecentActivity() {
        return getUserRecentActivity();
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getUserRecentActivity() {
        List<Map<String, Object>> activities = new List<Map<String, Object>>();
        
        // ALWAYS get the current active user's ID - this ensures data is always correct for whoever is logged in
        String currentUserId = UserInfo.getUserId();
        
        try {
            // Get current user info to determine view permissions
            Map<String, String> currentUserInfo = getCurrentUserInfo();
            String userType = currentUserInfo.get('userType');
            String userName = currentUserInfo.get('name');
            
            System.debug('getUserRecentActivity - Current User ID: ' + currentUserId + ', userType: ' + userType + ', userName: ' + userName);
            
            // Query recently COMPLETED interviews only - filter by user who conducted them
            String interviewQuery = 'SELECT Id, Name, Interview_Type__c, Interview_Status__c, CreatedDate, ' +
                                  'Candidate__r.Name, Candidate__r.Sales_Manager__c, Conducted_By__r.Name, Conducted_By__c ' +
                                  'FROM Interview__c ' +
                                  'WHERE Interview_Status__c = \'Completed\' ';
            
            if (userType == 'Sales Manager') {
                // Filter by interviews for candidates assigned to this Sales Manager OR conducted by them
                interviewQuery += 'AND (Candidate__r.Sales_Manager__c = :userName OR Conducted_By__c = :currentUserId) ';
            } else {
                // For other users, show only interviews they conducted
                interviewQuery += 'AND Conducted_By__c = :currentUserId ';
            }
            
            interviewQuery += 'ORDER BY CreatedDate DESC LIMIT 15';
            
            List<Interview__c> recentInterviews = Database.query(interviewQuery);
            System.debug('Found ' + recentInterviews.size() + ' interviews for user');
            
            for (Interview__c interview : recentInterviews) {
                Map<String, Object> activity = new Map<String, Object>();
                activity.put('id', interview.Id + '_interview');
                activity.put('type', '📅');
                activity.put('description', interview.Interview_Type__c + ' Interview');
                activity.put('candidateName', interview.Candidate__r?.Name != null ? interview.Candidate__r.Name : 'N/A');
                activity.put('salesManager', interview.Candidate__r?.Sales_Manager__c != null ? interview.Candidate__r.Sales_Manager__c : 'N/A');
                activity.put('conductedBy', interview.Conducted_By__r?.Name != null ? interview.Conducted_By__r.Name : 'N/A');
                activity.put('status', interview.Interview_Status__c != null ? interview.Interview_Status__c : 'Scheduled');
                activity.put('statusVariant', getStatusVariant(interview.Interview_Status__c));
                activity.put('timeAgo', getTimeAgo(interview.CreatedDate));
                activity.put('activityDate', interview.CreatedDate);
                activities.add(activity);
            }
            
            // Query recent candidates added - filter by owner or sales manager
            String candidateQuery = 'SELECT Id, Name, Contact__r.Name, Status__c, Sales_Manager__c, CreatedDate, CreatedById, CreatedBy.Name, OwnerId, Owner.Name ' +
                                   'FROM Candidate__c ' +
                                   'WHERE ';
            
            if (userType == 'Sales Manager') {
                // Filter by candidates assigned to this Sales Manager OR owned by them
                candidateQuery += '(Sales_Manager__c = :userName OR OwnerId = :currentUserId) ';
            } else {
                // For other users, show only candidates they own or created
                candidateQuery += '(OwnerId = :currentUserId OR CreatedById = :currentUserId) ';
            }
            
            candidateQuery += 'ORDER BY CreatedDate DESC LIMIT 15';
            
            List<Candidate__c> recentCandidates = Database.query(candidateQuery);
            System.debug('Found ' + recentCandidates.size() + ' candidates for user');
            
            for (Candidate__c candidate : recentCandidates) {
                Map<String, Object> activity = new Map<String, Object>();
                activity.put('id', candidate.Id + '_candidate');
                activity.put('type', '✅');
                activity.put('description', 'Candidate Added');
                String candidateName = candidate.Contact__r?.Name != null ? candidate.Contact__r.Name : candidate.Name;
                activity.put('candidateName', candidateName != null ? candidateName : 'N/A');
                activity.put('salesManager', candidate.Sales_Manager__c != null ? candidate.Sales_Manager__c : 'N/A');
                activity.put('createdBy', candidate.CreatedBy?.Name != null ? candidate.CreatedBy.Name : 'N/A');
                activity.put('status', candidate.Status__c != null ? candidate.Status__c : 'New');
                activity.put('statusVariant', getStatusVariant(candidate.Status__c));
                activity.put('timeAgo', getTimeAgo(candidate.CreatedDate));
                activity.put('activityDate', candidate.CreatedDate);
                activities.add(activity);
            }
            
            // Query recent calls/tasks - matching report filters exactly:
            // Status = Completed, Subtype = Task/Email/Call/LinkedIn, Modified >= YESTERDAY
            // Use My tasks (OwnerId = current user)
            String taskQuery = 'SELECT Id, Subject, Status, CreatedDate, ActivityDate, Who.Name, WhoId, ' +
                              'What.Name, WhatId, OwnerId, Owner.Name, Description, TaskSubtype, LastModifiedDate ' +
                              'FROM Task ' +
                              'WHERE OwnerId = :currentUserId ' +
                              'AND Status = \'Completed\' ' +
                              'AND TaskSubtype IN (\'Task\', \'Email\', \'Call\', \'LinkedIn\') ' +
                              'AND LastModifiedDate >= YESTERDAY ' +
                              'ORDER BY LastModifiedDate DESC LIMIT 50';
            
            List<Task> recentTasks = Database.query(taskQuery);
            System.debug('Found ' + recentTasks.size() + ' tasks for user');
            
            for (Task taskRecord : recentTasks) {
                Map<String, Object> activity = new Map<String, Object>();
                activity.put('id', taskRecord.Id + '_task');
                
                // Determine icon based on task subject
                String taskType = '✓';
                String taskSubject = taskRecord.Subject != null ? taskRecord.Subject.toLowerCase() : '';
                if (taskSubject.contains('call') || taskSubject.contains('phone')) {
                    taskType = '📞';
                } else if (taskSubject.contains('email') || taskSubject.contains('mail')) {
                    taskType = '📧';
                } else if (taskSubject.contains('meeting') || taskSubject.contains('interview')) {
                    taskType = '🤝';
                } else if (taskSubject.contains('review') || taskSubject.contains('access')) {
                    taskType = '📋';
                }
                
                activity.put('type', taskType);
                activity.put('description', taskRecord.Subject != null ? taskRecord.Subject : 'Task Completed');
                
                // Try to get the contact/lead name from Who field, or related record from What field
                String contactName = 'N/A';
                if (taskRecord.Who?.Name != null) {
                    contactName = taskRecord.Who.Name;
                } else if (taskRecord.What?.Name != null) {
                    contactName = taskRecord.What.Name;
                }
                
                activity.put('candidateName', contactName);
                activity.put('taskOwner', taskRecord.Owner?.Name != null ? taskRecord.Owner.Name : 'N/A');
                activity.put('status', taskRecord.Status != null ? taskRecord.Status : 'Not Started');
                activity.put('statusVariant', getStatusVariant(taskRecord.Status));
                activity.put('timeAgo', getTimeAgo(taskRecord.CreatedDate));
                activity.put('activityDate', taskRecord.CreatedDate);
                activity.put('dueDate', taskRecord.ActivityDate); // Add due date for tasks
                activities.add(activity);
            }
            
            // Sort all activities by date (most recent first)
            activities.sort(new ActivityDateComparator());
            
            System.debug('Total activities before limiting: ' + activities.size());
            
            // Limit to top 10 most recent
            if (activities.size() > 10) {
                List<Map<String, Object>> topActivities = new List<Map<String, Object>>();
                for (Integer i = 0; i < 10; i++) {
                    topActivities.add(activities[i]);
                }
                System.debug('Returning top 10 activities');
                return topActivities;
            }
            
            System.debug('Returning all ' + activities.size() + ' activities');
            return activities;
            
        } catch (Exception e) {
            System.debug('Error in getUserRecentActivity: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return activities;
    }
    
    // Helper method to get status variant for badge
    private static String getStatusVariant(String status) {
        if (status == null) return 'warning';
        
        String lowerStatus = status.toLowerCase();
        if (lowerStatus.contains('complete') || lowerStatus.contains('success') || lowerStatus.contains('done')) {
            return 'success';
        } else if (lowerStatus.contains('cancel') || lowerStatus.contains('fail') || lowerStatus.contains('no show')) {
            return 'error';
        } else if (lowerStatus.contains('progress') || lowerStatus.contains('schedule')) {
            return 'warning';
        }
        return 'inverse';
    }
    
    // Helper method to calculate relative time
    private static String getTimeAgo(DateTime activityDate) {
        if (activityDate == null) return 'Unknown';
        
        Long secondsAgo = (DateTime.now().getTime() - activityDate.getTime()) / 1000;
        
        if (secondsAgo < 60) {
            return 'Just now';
        } else if (secondsAgo < 3600) {
            Long minutes = secondsAgo / 60;
            return minutes + (minutes == 1 ? ' minute ago' : ' minutes ago');
        } else if (secondsAgo < 86400) {
            Long hours = secondsAgo / 3600;
            return hours + (hours == 1 ? ' hour ago' : ' hours ago');
        } else if (secondsAgo < 604800) {
            Long days = secondsAgo / 86400;
            return days + (days == 1 ? ' day ago' : ' days ago');
        } else {
            return activityDate.format('MMM d, yyyy');
        }
    }
    
    // Comparator class for sorting activities by date
    private class ActivityDateComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            DateTime dateA = (DateTime)a.get('activityDate');
            DateTime dateB = (DateTime)b.get('activityDate');
            
            if (dateA == null && dateB == null) return 0;
            if (dateA == null) return 1;
            if (dateB == null) return -1;
            
            // Sort descending (most recent first)
            return dateB > dateA ? 1 : (dateB < dateA ? -1 : 0);
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getDetailedInterviewStats() {
        Map<String, Object> interviewStats = new Map<String, Object>();
        
        try {
            // Attraction Interviews
            interviewStats.put('attractionThisWeek', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'Attraction' AND CreatedDate = THIS_WEEK]);
            interviewStats.put('attractionThisMonth', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'Attraction' AND CreatedDate = THIS_MONTH]);
            
            // SI1 Interviews  
            interviewStats.put('si1ThisWeek', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'SI1' AND CreatedDate = THIS_WEEK]);
            interviewStats.put('si1ThisMonth', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'SI1' AND CreatedDate = THIS_MONTH]);
                
            // SI2 Interviews
            interviewStats.put('si2ThisWeek', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'SI2' AND CreatedDate = THIS_WEEK]);
            interviewStats.put('si2ThisMonth', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'SI2' AND CreatedDate = THIS_MONTH]);
                
            // Career Interviews
            interviewStats.put('careerThisWeek', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'Career' AND CreatedDate = THIS_WEEK]);
            interviewStats.put('careerThisMonth', [SELECT COUNT() FROM Interview__c 
                WHERE Interview_Type__c = 'Career' AND CreatedDate = THIS_MONTH]);
                
            // Calls (using Activities or Events related to Candidates)
            interviewStats.put('callsThisWeek', getCallsCount('THIS_WEEK'));
            interviewStats.put('callsThisMonth', getCallsCount('THIS_MONTH'));
            
        } catch (Exception e) {
            System.debug('Error in getDetailedInterviewStats: ' + e.getMessage());
            // Set default values
            interviewStats.put('attractionThisWeek', 0);
            interviewStats.put('attractionThisMonth', 0);
            interviewStats.put('si1ThisWeek', 0);
            interviewStats.put('si1ThisMonth', 0);
            interviewStats.put('si2ThisWeek', 0);
            interviewStats.put('si2ThisMonth', 0);
            interviewStats.put('careerThisWeek', 0);
            interviewStats.put('careerThisMonth', 0);
            interviewStats.put('callsThisWeek', 0);
            interviewStats.put('callsThisMonth', 0);
        }
        
        return interviewStats;
    }
    
    private static Integer getCallsCount(String timeFrame) {
        try {
            String query = 'SELECT COUNT() FROM Task WHERE Subject LIKE \'%Call%\' OR Subject LIKE \'%call%\'';
            if (timeFrame == 'THIS_WEEK') {
                query += ' AND CreatedDate = THIS_WEEK';
            } else if (timeFrame == 'THIS_MONTH') {
                query += ' AND CreatedDate = THIS_MONTH';
            }
            return Database.countQuery(query);
        } catch (Exception e) {
            System.debug('Error getting calls count: ' + e.getMessage());
            return 0;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getInterviewsByType() {
        List<Map<String, Object>> interviewData = new List<Map<String, Object>>();
        
        try {
            List<AggregateResult> results = [
                SELECT Interview_Type__c, COUNT(Id) total
                FROM Interview__c 
                WHERE Interview_Type__c != null
                GROUP BY Interview_Type__c
                ORDER BY COUNT(Id) DESC
            ];
            
            for (AggregateResult result : results) {
                Map<String, Object> data = new Map<String, Object>();
                data.put('type', (String)result.get('Interview_Type__c'));
                data.put('count', (Integer)result.get('total'));
                interviewData.add(data);
            }
        } catch (Exception e) {
            System.debug('Error in getInterviewsByType: ' + e.getMessage());
        }
        
        return interviewData;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Integer> getPerformanceMetrics() {
        Map<String, Integer> metrics = new Map<String, Integer>();
        
        try {
            metrics.put('proceedOutcome', [SELECT COUNT() FROM Interview__c WHERE Outcome__c = 'Proceed']);
            metrics.put('holdOutcome', [SELECT COUNT() FROM Interview__c WHERE Outcome__c = 'Hold']);
            metrics.put('declineOutcome', [SELECT COUNT() FROM Interview__c WHERE Outcome__c = 'Decline']);
            
            // Calculate success rate (proceed + hold vs total with outcomes)
            Integer totalWithOutcome = [SELECT COUNT() FROM Interview__c WHERE Outcome__c != null];
            Integer successfulOutcomes = metrics.get('proceedOutcome') + metrics.get('holdOutcome');
            
            if (totalWithOutcome > 0) {
                metrics.put('successRate', (successfulOutcomes * 100) / totalWithOutcome);
            } else {
                metrics.put('successRate', 0);
            }
            
            metrics.put('totalWithOutcome', totalWithOutcome);
        } catch (Exception e) {
            System.debug('Error in getPerformanceMetrics: ' + e.getMessage());
            metrics.put('proceedOutcome', 0);
            metrics.put('holdOutcome', 0);
            metrics.put('declineOutcome', 0);
            metrics.put('successRate', 0);
            metrics.put('totalWithOutcome', 0);
        }
        
        return metrics;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getScheduledCandidateDetails(String interviewType) {
        List<Map<String, Object>> candidateDetails = new List<Map<String, Object>>();
        
        try {
            String query = 'SELECT Id, Name, ';
            String whereClause = ' WHERE ';
            
            switch on interviewType {
                when 'attraction' {
                    query += 'Attraction_Interview_Date_Scheduled__c';
                    whereClause += 'Attraction_Interview_Date_Scheduled__c >= TODAY';
                }
                when 'si1' {
                    query += 'SI_1_Date_Scheduled__c';
                    whereClause += 'SI_1_Date_Scheduled__c >= TODAY';
                }
                when 'si2' {
                    query += 'SI_2_Date_Scheduled__c';
                    whereClause += 'SI_2_Date_Scheduled__c >= TODAY';
                }
                when 'si3' {
                    query += 'SI_3_Scheduled__c';
                    whereClause += 'SI_3_Scheduled__c >= TODAY';
                }
                when 'career' {
                    query += 'Career_Presentation_Date_Scheduled__c';
                    whereClause += 'Career_Presentation_Date_Scheduled__c >= TODAY';
                }
                when else {
                    return candidateDetails; // Return empty list for invalid type
                }
            }
            
            query += ' scheduledDate FROM Candidate__c' + whereClause + ' ORDER BY scheduledDate ASC LIMIT 50';
            
            List<Candidate__c> candidates = Database.query(query);
            
            for (Candidate__c candidate : candidates) {
                Map<String, Object> detail = new Map<String, Object>();
                detail.put('id', candidate.Id);
                detail.put('name', candidate.Name);
                detail.put('interviewType', interviewType.toUpperCase());
                
                // Get the scheduled date based on interview type
                Date scheduledDate = null;
                switch on interviewType {
                    when 'attraction' {
                        scheduledDate = candidate.Attraction_Interview_Date_Scheduled__c;
                    }
                    when 'si1' {
                        scheduledDate = candidate.SI_1_Date_Scheduled__c;
                    }
                    when 'si2' {
                        scheduledDate = candidate.SI_2_Date_Scheduled__c;
                    }
                    when 'si3' {
                        scheduledDate = candidate.SI_3_Scheduled__c;
                    }
                    when 'career' {
                        scheduledDate = candidate.Career_Presentation_Date_Scheduled__c;
                    }
                }
                
                detail.put('scheduledDate', scheduledDate);
                candidateDetails.add(detail);
            }
            
        } catch (Exception e) {
            System.debug('Error in getScheduledCandidateDetails: ' + e.getMessage());
        }
        
        return candidateDetails;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Integer> getCurrentUserCallStats() {
        Map<String, Integer> stats = new Map<String, Integer>();
        try {
            Date today = Date.today();
            // Query open call-type tasks for the running user
            List<Task> userCallTasks = [
                SELECT Id, ActivityDate, Status, IsClosed, TaskSubtype
                FROM Task
                WHERE OwnerId = :UserInfo.getUserId()
                  AND Type = 'Call'
                  AND IsClosed = false
                  AND (TaskSubtype = 'Call' OR TaskSubtype = NULL)
                ORDER BY ActivityDate ASC
                LIMIT 1000
            ];
            Integer scheduledCalls = 0;
            Integer pastDueCalls = 0;
            for (Task t : userCallTasks) {
                if (t.ActivityDate != null) {
                    if (t.ActivityDate >= today) {
                        scheduledCalls++;
                    } else {
                        pastDueCalls++;
                    }
                }
            }
            stats.put('scheduledCalls', scheduledCalls);
            stats.put('pastDueCalls', pastDueCalls);
            stats.put('totalAssigned', userCallTasks.size());
        } catch (Exception e) {
            System.debug('Error in getCurrentUserCallStats: ' + e.getMessage());
            stats.put('scheduledCalls', 0);
            stats.put('pastDueCalls', 0);
            stats.put('totalAssigned', 0);
        }
        return stats;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getRachyllCallDetails(String callType) {
        // Backward compatibility shim that returns current user's details
        return getCurrentUserCallDetails(callType);
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCurrentUserCallDetails(String callType) {
        List<Map<String, Object>> callDetails = new List<Map<String, Object>>();
        try {
            System.debug('=== getCurrentUserCallDetails Debug v2.2 - ' + System.now() + ' ===');
            System.debug('Call Type: ' + callType);
            System.debug('Current User ID: ' + UserInfo.getUserId());
            System.debug('Current User Name: ' + UserInfo.getName());
            
            Date today = Date.today();
            String whereClause = '';
            
            // Build query matching the report filters:
            // Show: Open Activities (Tasks)
            // Date: ONLY TODAY (not future dates) for scheduled, less than TODAY for past due
            // Assigned: equals current user
            switch on callType {
                when 'scheduled' { 
                    whereClause = 'AND ActivityDate = TODAY'; 
                }
                when 'pastdue' { 
                    whereClause = 'AND ActivityDate < TODAY'; 
                }
            }
            
            // Query open call tasks assigned to current user
            // CRITICAL: ONLY filter by TaskSubtype = 'Call' to exclude emails and other task types
            // DO NOT use Subject LIKE '%Call%' or Type = 'Call' as this includes non-call tasks
            String query = 'SELECT Id, Subject, ActivityDate, Status, Description, WhatId, WhoId, ' +
                           'What.Name, Who.Name ' +
                           'FROM Task ' +
                           'WHERE OwnerId = \'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\' ' +
                           'AND TaskSubtype = \'Call\' ' +
                           'AND IsClosed = false ' +
                           whereClause + ' ' +
                           'ORDER BY ActivityDate ASC LIMIT 1000';
            
            System.debug('Query: ' + query);
            
            List<Task> tasks = Database.query(query);
            
            System.debug('Number of tasks found: ' + tasks.size());
            
            for (Task task : tasks) {
                // Filter out Email tasks by checking Description field
                if (task.Description != null && task.Description.startsWith('Email:')) {
                    continue;
                }
                
                Map<String, Object> detail = new Map<String, Object>();
                detail.put('id', task.Id);
                detail.put('subject', task.Subject);
                detail.put('dueDate', task.ActivityDate);
                detail.put('status', task.Status);
                detail.put('description', task.Description);
                detail.put('relatedTo', task.What?.Name);
                detail.put('relatedToId', task.WhatId);
                detail.put('relatedPerson', task.Who?.Name);
                detail.put('relatedPersonId', task.WhoId);
                if (callType == 'pastdue' && task.ActivityDate != null) {
                    Integer daysOverdue = today.daysBetween(task.ActivityDate) * -1;
                    detail.put('daysOverdue', daysOverdue);
                }
                callDetails.add(detail);
            }
            
            System.debug('Call details created: ' + callDetails.size());
            System.debug('=== End getCurrentUserCallDetails Debug ===');
            
        } catch (Exception e) {
            System.debug('Error in getCurrentUserCallDetails: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        return callDetails;
    }
    
    @AuraEnabled
    public static String completeCallTask(String taskId) {
        try {
            Task taskToComplete = [SELECT Id, Status FROM Task WHERE Id = :taskId LIMIT 1];
            taskToComplete.Status = 'Completed';
            update taskToComplete;
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error completing task: ' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }
    
    @AuraEnabled
    public static String completeCallWithNotesAndSchedule(String taskId, String notes, Date nextCallDate, Date newDueDate) {
        try {
            // Complete the current task
            Task taskToComplete = [
                SELECT Id, Status, Description, WhatId, WhoId, OwnerId, Subject, ActivityDate
                FROM Task 
                WHERE Id = :taskId 
                LIMIT 1
            ];
            
            // Update the task with completion notes
            taskToComplete.Status = 'Completed';
            if (String.isNotBlank(notes)) {
                String existingDescription = taskToComplete.Description != null ? taskToComplete.Description : '';
                taskToComplete.Description = existingDescription + '\n\nCall Completion Notes: ' + notes;
            }
            
            // Update the due date if provided
            if (newDueDate != null) {
                taskToComplete.ActivityDate = newDueDate;
            }
            
            update taskToComplete;
            
            // Create follow-up task if scheduled
            if (nextCallDate != null) {
                Task followUpTask = new Task();
                followUpTask.Subject = 'Follow-up Call - ' + taskToComplete.Subject?.replace('Follow-up Call - ', '')?.replace('Overdue Call - ', '');
                followUpTask.Type = 'Call';
                followUpTask.Status = 'Not Started';
                followUpTask.Priority = 'Normal';
                followUpTask.ActivityDate = nextCallDate;
                followUpTask.WhatId = taskToComplete.WhatId;
                followUpTask.WhoId = taskToComplete.WhoId;
                followUpTask.OwnerId = taskToComplete.OwnerId;
                followUpTask.Description = 'Follow-up call scheduled from previous call completion.';
                
                insert followUpTask;
            }
            
            return 'SUCCESS';
        } catch (Exception e) {
            System.debug('Error completing task with notes: ' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getSalesManagerMetrics() {
        List<Map<String, Object>> managerMetrics = new List<Map<String, Object>>();
        
        try {
            // Get managers from User object with Sales Manager profile or role
            List<User> salesManagers = [
                SELECT Id, Name, Profile.Name 
                FROM User 
                WHERE IsActive = true 
                AND (Profile.Name LIKE '%Sales%Manager%' OR Profile.Name LIKE '%Recruiting%Manager%' OR Name LIKE '%Manager%')
                LIMIT 10
            ];
            
            for (User manager : salesManagers) {
                Map<String, Object> managerData = new Map<String, Object>();
                managerData.put('managerId', manager.Id);
                managerData.put('managerName', manager.Name);
                
                // Get candidates assigned to this manager (simplified approach)
                Integer activeCandidates = [
                    SELECT COUNT() 
                    FROM Candidate__c 
                    WHERE OwnerId = :manager.Id 
                    AND Status__c = 'Active/In Process'
                ];
                
                Integer totalCandidates = [
                    SELECT COUNT() 
                    FROM Candidate__c 
                    WHERE OwnerId = :manager.Id
                ];
                
                Integer interviewsThisMonth = [
                    SELECT COUNT() 
                    FROM Interview__c 
                    WHERE CreatedDate = THIS_MONTH 
                    AND Candidate__r.OwnerId = :manager.Id
                ];
                
                managerData.put('activeCandidates', activeCandidates);
                managerData.put('totalCandidates', totalCandidates);
                managerData.put('interviewsThisMonth', interviewsThisMonth);
                
                // Calculate success rate (simplified)
                Decimal successRate = totalCandidates > 0 ? (activeCandidates * 100.0 / totalCandidates) : 0;
                managerData.put('successRate', successRate.setScale(1));
                
                managerMetrics.add(managerData);
            }
            
        } catch (Exception e) {
            System.debug('Error in getSalesManagerMetrics: ' + e.getMessage());
        }
        
        return managerMetrics;
    }
    
    @AuraEnabled
    public static String generateTestCallsForRachyll() {
        try {
            List<Task> testTasks = new List<Task>();
            
            // Get Rachyll Tenny's User ID specifically
            List<User> rachyllUsers = [
                SELECT Id, Name 
                FROM User 
                WHERE Name = 'Rachyll Tenny' 
                AND IsActive = true 
                LIMIT 1
            ];
            
            Id rachyllId;
            if (rachyllUsers.isEmpty()) {
                // If Rachyll Tenny doesn't exist, create tasks for current user but with note
                rachyllId = UserInfo.getUserId();
                System.debug('Rachyll Tenny user not found, assigning to current user: ' + UserInfo.getName());
            } else {
                rachyllId = rachyllUsers[0].Id;
                System.debug('Found Rachyll Tenny user: ' + rachyllUsers[0].Name);
            }
            
            // Get some candidate records to associate with tasks
            List<Candidate__c> candidates = [SELECT Id, Name FROM Candidate__c LIMIT 10];
            
            if (candidates.isEmpty()) {
                return 'ERROR: No candidates found to associate with test calls';
            }
            
            // Create scheduled calls (future dates)
            for (Integer i = 0; i < 5; i++) {
                Task scheduledCall = new Task();
                scheduledCall.Subject = 'Follow-up Call - ' + candidates[Math.mod(i, candidates.size())].Name;
                scheduledCall.Type = 'Call';
                scheduledCall.Status = 'Not Started';
                scheduledCall.Priority = 'Normal';
                scheduledCall.OwnerId = rachyllId;
                scheduledCall.WhatId = candidates[Math.mod(i, candidates.size())].Id;
                scheduledCall.ActivityDate = Date.today().addDays(i + 1);
                scheduledCall.Description = 'Scheduled follow-up call to discuss next steps in the recruiting process.';
                testTasks.add(scheduledCall);
            }
            
            // Create past due calls (past dates)
            for (Integer i = 0; i < 7; i++) {
                Task pastDueCall = new Task();
                pastDueCall.Subject = 'Overdue Call - ' + candidates[Math.mod(i + 5, candidates.size())].Name;
                pastDueCall.Type = 'Call';
                pastDueCall.Status = 'Not Started';
                pastDueCall.Priority = 'High';
                pastDueCall.OwnerId = rachyllId;
                pastDueCall.WhatId = candidates[Math.mod(i + 5, candidates.size())].Id;
                pastDueCall.ActivityDate = Date.today().addDays(-(i + 1));
                pastDueCall.Description = 'Past due follow-up call. Needs immediate attention.';
                testTasks.add(pastDueCall);
            }
            
            insert testTasks;
            
            String userMessage = rachyllUsers.isEmpty() ? 
                'SUCCESS: Created ' + testTasks.size() + ' test calls (assigned to current user - Rachyll Tenny not found)' :
                'SUCCESS: Created ' + testTasks.size() + ' test calls for Rachyll Tenny';
            
            return userMessage;
            
        } catch (Exception e) {
            System.debug('Error generating test calls: ' + e.getMessage());
            return 'ERROR: ' + e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getPastDueCalls() {
        List<Map<String, Object>> pastDueCalls = new List<Map<String, Object>>();
        
        try {
            // Get past due tasks (ActivityDate < TODAY and Status != 'Completed')
            // CRITICAL: Only show tasks with TaskSubtype = 'Call' to exclude emails
            List<Task> pastDueTasks = [
                SELECT Id, Subject, Description, ActivityDate, Status, OwnerId, Owner.Name, 
                       WhatId, What.Name, CreatedDate
                FROM Task 
                WHERE ActivityDate < TODAY 
                AND Status != 'Completed'
                AND Status != 'Deferred'
                AND TaskSubtype = 'Call'
                ORDER BY ActivityDate ASC, CreatedDate DESC
                LIMIT 50
            ];
            
            for (Task task : pastDueTasks) {
                Map<String, Object> callData = new Map<String, Object>();
                callData.put('id', task.Id);
                callData.put('candidateName', task.What?.Name != null ? task.What.Name : 'Unknown');
                callData.put('subject', task.Subject);
                callData.put('originalDate', task.ActivityDate?.format());
                callData.put('originalTime', ''); // Tasks don't store time typically
                callData.put('purpose', task.Subject != null ? task.Subject : 'Follow-up call');
                callData.put('description', task.Description);
                callData.put('ownerName', task.Owner?.Name);
                
                // Calculate days overdue
                if (task.ActivityDate != null) {
                    Integer daysOverdue = task.ActivityDate.daysBetween(Date.today());
                    callData.put('daysOverdue', daysOverdue);
                    
                    // Set priority based on days overdue
                    if (daysOverdue >= 7) {
                        callData.put('priority', 'High');
                    } else if (daysOverdue >= 3) {
                        callData.put('priority', 'Medium');
                    } else {
                        callData.put('priority', 'Low');
                    }
                }
                
                pastDueCalls.add(callData);
            }
            
            return pastDueCalls;
            
        } catch (Exception e) {
            System.debug('Error getting past due calls: ' + e.getMessage());
            // Return empty list on error
            return new List<Map<String, Object>>();
        }
    }

    @AuraEnabled
    public static String rescheduleCalls(List<String> taskIds, String newDate, String newTime, String notes) {
        return RecruiterRescheduleHelper.rescheduleCalls(taskIds, newDate, newTime, notes);
    }

    
    @AuraEnabled
    public static String createCandidate(String candidateName, String email, String phone, String contactId, String position, String source, String notes) {
        try {
            // Validate required inputs
            if (String.isBlank(candidateName) || String.isBlank(email)) {
                return 'ERROR: Candidate name and email are required';
            }
            
            Contact candidateContact;
            Boolean contactCreated = false;
            
            if (String.isNotBlank(contactId)) {
                // Use existing contact (duplicate scenario)
                try {
                    candidateContact = [SELECT Id, Name, Email, Phone FROM Contact WHERE Id = :contactId LIMIT 1];
                } catch (Exception e) {
                    return 'ERROR: Specified contact not found';
                }
            } else {
                // Check if contact already exists with this email (shouldn't happen with proper duplicate detection)
                List<Contact> existingContacts = [
                    SELECT Id, Name, Email, Phone 
                    FROM Contact 
                    WHERE Email = :email 
                    LIMIT 1
                ];
                
                if (!existingContacts.isEmpty()) {
                    candidateContact = existingContacts[0];
                } else {
                    // Create new contact
                    candidateContact = new Contact();
                    
                    // Parse name into First Name and Last Name
                    List<String> nameParts = candidateName.trim().split('\\s+');
                    if (nameParts.size() >= 2) {
                        candidateContact.FirstName = nameParts[0];
                        // Join remaining parts as last name
                        String lastName = '';
                        for (Integer i = 1; i < nameParts.size(); i++) {
                            if (i > 1) lastName += ' ';
                            lastName += nameParts[i];
                        }
                        candidateContact.LastName = lastName;
                    } else {
                        candidateContact.FirstName = candidateName;
                        candidateContact.LastName = 'Candidate';
                    }
                    
                    candidateContact.Email = email;
                    candidateContact.Phone = phone;
                    candidateContact.Title = position; // Store position in contact title
                    
                    insert candidateContact;
                    contactCreated = true;
                }
            }
            
            // Check if candidate already exists for this contact
            List<Candidate__c> existingCandidates = [
                SELECT Id, Name, Status__c
                FROM Candidate__c 
                WHERE Contact__c = :candidateContact.Id 
                LIMIT 1
            ];
            
            if (!existingCandidates.isEmpty()) {
                return 'ERROR: Candidate record already exists for ' + candidateContact.Name + 
                       '. Each contact can only have one candidate record.';
            }
            
            // Create new candidate record
            Candidate__c newCandidate = new Candidate__c();
            newCandidate.Contact__c = candidateContact.Id;
            newCandidate.Email__c = candidateContact.Email;
            newCandidate.Phone__c = candidateContact.Phone;
            newCandidate.Position__c = position;
            newCandidate.Status__c = 'Lead'; // Default status for new candidates
            
            if (String.isNotBlank(notes)) {
                newCandidate.Candidate_Summary__c = notes;
            }
            
            insert newCandidate;
            
            String message = contactCreated ? 
                'Created new contact and candidate record for ' + candidateContact.Name :
                'Created candidate record for existing contact ' + candidateContact.Name;
            
            return 'SUCCESS: ' + message + ' (' + candidateContact.Email + ')';
            
        } catch (Exception e) {
            System.debug('Error creating candidate: ' + e.getMessage());
            return 'ERROR: Failed to create candidate - ' + e.getMessage();
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, String> getCurrentUserInfo() {
        Map<String, String> result = new Map<String, String>();
        try {
            User currentUser = [SELECT Id, Name, FirstName, Email, Profile.Name, UserRole.Name FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            
            System.debug('=== getCurrentUserInfo Debug ===');
            System.debug('User ID: ' + currentUser.Id);
            System.debug('User Name: ' + currentUser.Name);
            System.debug('User FirstName: ' + currentUser.FirstName);
            System.debug('User Email: ' + currentUser.Email);
            System.debug('User Profile: ' + currentUser.Profile?.Name);
            System.debug('User Role: ' + currentUser.UserRole?.Name);
            
            result.put('id', currentUser.Id);
            result.put('name', currentUser.Name);
            result.put('firstName', currentUser.FirstName != null ? currentUser.FirstName : '');
            result.put('email', currentUser.Email);
            result.put('profileName', currentUser.Profile != null ? currentUser.Profile.Name : '');
            result.put('roleName', currentUser.UserRole != null ? currentUser.UserRole.Name : '');
            
            // Determine if user is Director or Sales Manager
            String profileName = currentUser.Profile != null ? currentUser.Profile.Name : '';
            String roleName = currentUser.UserRole != null ? currentUser.UserRole.Name : '';
            String userName = currentUser.Name;
            
            // Global/Director view users - specific recruiting team members who see all data
            Set<String> globalViewUsers = new Set<String>{
                'Rachyll Tenny',
                'Neilie Torres', 
                'Van Hess',
                'Patrick Baker'
            };
            
            System.debug('Checking global view access for: ' + userName);
            
            // Check if user has global view access
            if (globalViewUsers.contains(userName)) {
                result.put('userType', 'Director');
                System.debug('User has global view access - userType set to Director');
            }
            // Check if Director of Recruiting (UserRole = "Recruiting Director")
            else if (roleName.containsIgnoreCase('Recruiting Director') || 
                (profileName.containsIgnoreCase('Director') && profileName.containsIgnoreCase('Recruit'))) {
                result.put('userType', 'Director');
                System.debug('User is Recruiting Director - userType set to Director');
            } 
            // Check if Sales Manager (UserRole = "SM" or Profile = "Sales Manager")
            else if (roleName == 'SM' || profileName.containsIgnoreCase('Sales Manager')) {
                result.put('userType', 'Sales Manager');
                System.debug('User is Sales Manager - userType set to Sales Manager');
            } 
            // System Administrator sees Director view
            else if (profileName.containsIgnoreCase('System Administrator')) {
                result.put('userType', 'Director');
                System.debug('User is System Administrator - userType set to Director');
            }
            else {
                result.put('userType', 'Other');
                System.debug('User has standard access - userType set to Other');
            }
            
            System.debug('Final result: ' + result);
            System.debug('=== End getCurrentUserInfo Debug ===');
            
        } catch (Exception e) {
            System.debug('Error getting current user info: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
            result.put('id', UserInfo.getUserId());
            result.put('name', UserInfo.getName());
            result.put('firstName', UserInfo.getFirstName() != null ? UserInfo.getFirstName() : '');
            result.put('email', '');
            result.put('profileName', '');
            result.put('roleName', '');
            result.put('userType', 'Other');
        }
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> searchUsers(String searchTerm) {
        List<Map<String, String>> userResults = new List<Map<String, String>>();
        
        try {
            List<User> users;
            
            if (String.isBlank(searchTerm)) {
                // Return all active users with Salesforce User License if no search term
                users = [
                    SELECT Id, Name, Email, Username, Profile.UserLicense.Name
                    FROM User
                    WHERE IsActive = true
                    AND Profile.UserLicense.Name = 'Salesforce'
                    ORDER BY Name
                    LIMIT 50
                ];
            } else {
                // Search users by name or email, only Salesforce licensed users
                String wildcardSearch = '%' + String.escapeSingleQuotes(searchTerm) + '%';
                users = [
                    SELECT Id, Name, Email, Username, Profile.UserLicense.Name
                    FROM User
                    WHERE IsActive = true
                    AND Profile.UserLicense.Name = 'Salesforce'
                    AND (Name LIKE :wildcardSearch OR Email LIKE :wildcardSearch)
                    ORDER BY Name
                    LIMIT 50
                ];
            }
            
            for (User u : users) {
                Map<String, String> userMap = new Map<String, String>();
                userMap.put('id', u.Id);
                userMap.put('name', u.Name);
                userMap.put('email', u.Email != null ? u.Email : '');
                userMap.put('username', u.Username);
                userResults.add(userMap);
            }
            
        } catch (Exception e) {
            System.debug('Error searching users: ' + e.getMessage());
        }
        
        return userResults;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getUserPipelineAnalytics(String userName) {
        Map<String, Object> analytics = new Map<String, Object>();
        
        try {
            // Get candidates for this specific Sales Manager by highest level achieved
            List<AggregateResult> levelResults = [
                SELECT Highest_Level_Achieved__c level, COUNT(Id) cnt
                FROM Candidate__c 
                WHERE Status__c = 'Active/In Process' 
                AND Sales_Manager__c = :userName
                GROUP BY Highest_Level_Achieved__c
                ORDER BY Highest_Level_Achieved__c
            ];
            
            // Format level data
            List<Map<String, Object>> levelData = new List<Map<String, Object>>();
            Integer totalCount = 0;
            
            for (AggregateResult result : levelResults) {
                String level = result.get('level') != null ? (String)result.get('level') : 'Not Set';
                Integer count = (Integer)result.get('cnt');
                totalCount += count;
                
                levelData.add(new Map<String, Object>{
                    'label' => level,
                    'value' => count
                });
            }
            
            analytics.put('levelData', levelData);
            analytics.put('total', totalCount);
            
        } catch (Exception e) {
            System.debug('Error in getUserPipelineAnalytics: ' + e.getMessage());
            analytics.put('levelData', new List<Map<String, Object>>());
            analytics.put('total', 0);
        }
        
        return analytics;
    }

    @AuraEnabled
    public static String createScheduledCall(Map<String, Object> taskData) {
        try {
            Task newTask = new Task();
            
            // Map the task data
            if (taskData.containsKey('Subject')) {
                newTask.Subject = (String) taskData.get('Subject');
            }
            if (taskData.containsKey('WhoId')) {
                newTask.WhoId = (Id) taskData.get('WhoId');
            }
            if (taskData.containsKey('WhatId') && taskData.get('WhatId') != null) {
                newTask.WhatId = (Id) taskData.get('WhatId');
            }
            if (taskData.containsKey('ActivityDate')) {
                newTask.ActivityDate = Date.valueOf((String) taskData.get('ActivityDate'));
            }
            if (taskData.containsKey('Status')) {
                newTask.Status = (String) taskData.get('Status');
            }
            if (taskData.containsKey('Priority')) {
                newTask.Priority = (String) taskData.get('Priority');
            }
            if (taskData.containsKey('Type')) {
                newTask.Type = (String) taskData.get('Type');
            }
            if (taskData.containsKey('TaskSubtype')) {
                newTask.TaskSubtype = (String) taskData.get('TaskSubtype');
            }
            if (taskData.containsKey('Description') && taskData.get('Description') != null) {
                newTask.Description = (String) taskData.get('Description');
            }
            
            // Set owner to current user and ensure correct task type defaults
            newTask.OwnerId = UserInfo.getUserId();
            
            // Ensure task type and subtype are set correctly
            if (String.isBlank(newTask.Type)) {
                newTask.Type = 'Call';
            }
            if (String.isBlank(newTask.TaskSubtype)) {
                newTask.TaskSubtype = 'Call';
            }
            
            insert newTask;
            
            return 'SUCCESS: Call scheduled with ID ' + newTask.Id;
            
        } catch (Exception e) {
            System.debug('Error creating scheduled call: ' + e.getMessage());
            throw new AuraHandledException('Failed to schedule call: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, String>> searchContacts(String searchTerm) {
        List<Map<String, String>> contactResults = new List<Map<String, String>>();
        
        if (String.isBlank(searchTerm) || searchTerm.length() < 2) {
            return contactResults;
        }
        
        try {
            System.debug('Searching contacts with term: ' + searchTerm);
            
            // Search contacts by name or email - improved search logic
            String wildcardSearch = '%' + searchTerm + '%';
            System.debug('Wildcard search: ' + wildcardSearch);
            
            // For multi-word searches, create individual word searches
            List<String> searchWords = searchTerm.split(' ');
            String multiWordQuery = '';
            
            // Build dynamic WHERE clause for better name matching
            if (searchWords.size() > 1) {
                // Multi-word search: each word should be found in the name
                List<String> wordConditions = new List<String>();
                for (String word : searchWords) {
                    if (String.isNotBlank(word)) {
                        wordConditions.add('Name LIKE \'%' + String.escapeSingleQuotes(word) + '%\'');
                    }
                }
                multiWordQuery = '(' + String.join(wordConditions, ' AND ') + ')';
            }
            
            String finalQuery = 'SELECT Id, Name, Email, Phone, Account.Name FROM Contact WHERE (';
            finalQuery += 'Name LIKE :wildcardSearch OR Email LIKE :wildcardSearch';
            if (String.isNotBlank(multiWordQuery)) {
                finalQuery += ' OR ' + multiWordQuery;
            }
            finalQuery += ') AND IsDeleted = false ORDER BY Name ASC LIMIT 10';
            
            System.debug('Final SOQL query: ' + finalQuery);
            List<Contact> contacts = Database.query(finalQuery);
            
            System.debug('SOQL returned ' + contacts.size() + ' contacts');
            
            // Convert to simplified format for LWC
            for (Contact contact : contacts) {
                System.debug('Processing contact: ' + contact.Name + ' (' + contact.Email + ')');
                Map<String, String> contactMap = new Map<String, String>();
                contactMap.put('Id', contact.Id);
                contactMap.put('Name', contact.Name);
                contactMap.put('Email', contact.Email != null ? contact.Email : '');
                contactMap.put('Phone', contact.Phone != null ? contact.Phone : '');
                contactMap.put('Account', contact.Account != null ? contact.Account.Name : '');
                contactResults.add(contactMap);
            }
            
            System.debug('Returning ' + contactResults.size() + ' formatted contacts for search: ' + searchTerm);
            return contactResults;
            
        } catch (Exception e) {
            System.debug('Error searching contacts: ' + e.getMessage());
            throw new AuraHandledException('Failed to search contacts: ' + e.getMessage());
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getActiveCandidates() {
        List<Map<String, Object>> candidateResults = new List<Map<String, Object>>();
        
        try {
            // Query for candidates with Active/In Process status using actual available fields
            List<Candidate__c> activeCandidates = [
                SELECT Id, Name, Email__c, Phone__c, Contact__c,
                       Contact__r.Name, Contact__r.Email, Contact__r.Phone, Contact__r.Title,
                       Status__c, CreatedDate, LastModifiedDate, OwnerId, Owner.Name
                FROM Candidate__c 
                WHERE Status__c = 'Active/In Process'
                ORDER BY LastModifiedDate DESC
                LIMIT 50
            ];
            
            System.debug('Found ' + activeCandidates.size() + ' active candidates');
            
            // Format candidates for display using actual field values
            for (Candidate__c candidate : activeCandidates) {
                Map<String, Object> candidateMap = new Map<String, Object>();
                candidateMap.put('id', candidate.Id);
                
                // Use Contact name first (real person name), fall back to auto-generated Candidate name
                String displayName = 'Unknown Name';
                if (candidate.Contact__r != null && String.isNotBlank(candidate.Contact__r.Name)) {
                    displayName = candidate.Contact__r.Name;
                } else if (String.isNotBlank(candidate.Name)) {
                    displayName = candidate.Name;
                }
                candidateMap.put('name', displayName);
                
                // Use candidate email first, fall back to related contact email
                String email = '';
                if (String.isNotBlank(candidate.Email__c)) {
                    email = candidate.Email__c;
                } else if (candidate.Contact__r != null && String.isNotBlank(candidate.Contact__r.Email)) {
                    email = candidate.Contact__r.Email;
                }
                candidateMap.put('email', email);
                candidateMap.put('emailLink', String.isNotBlank(email) ? 'mailto:' + email : null);
                
                // Use candidate phone first, fall back to related contact phone
                String phone = '';
                if (String.isNotBlank(candidate.Phone__c)) {
                    phone = candidate.Phone__c;
                } else if (candidate.Contact__r != null && String.isNotBlank(candidate.Contact__r.Phone)) {
                    phone = candidate.Contact__r.Phone;
                }
                candidateMap.put('phone', phone);
                candidateMap.put('phoneLink', String.isNotBlank(phone) ? 'tel:' + phone : null);
                
                // Use contact title as position if available
                String position = 'Insurance Agent'; // Default
                if (candidate.Contact__r != null && String.isNotBlank(candidate.Contact__r.Title)) {
                    position = candidate.Contact__r.Title;
                }
                candidateMap.put('position', position);
                
                candidateMap.put('status', candidate.Status__c != null ? candidate.Status__c : 'Unknown');
                candidateMap.put('leadSource', 'Recruiter Portal'); // Default since field doesn't exist
                candidateMap.put('experience', 'To Be Determined'); // Default since field doesn't exist
                candidateMap.put('location', 'Remote'); // Default since field doesn't exist
                candidateMap.put('nextMeeting', 'Not Scheduled'); // Default since field doesn't exist
                candidateMap.put('ownerName', candidate.Owner != null ? candidate.Owner.Name : 'Unassigned');
                candidateMap.put('createdDate', candidate.CreatedDate.format('MM/dd/yyyy'));
                candidateMap.put('lastModified', candidate.LastModifiedDate.format('MM/dd/yyyy'));
                
                candidateResults.add(candidateMap);
            }
            
            System.debug('Returning ' + candidateResults.size() + ' formatted active candidates');
            return candidateResults;
            
        } catch (Exception e) {
            System.debug('Error fetching active candidates: ' + e.getMessage());
            throw new AuraHandledException('Failed to fetch active candidates: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static String updateCandidate(String candidateId, String candidateName, String email, String phone, String position, String status, String officeLocation, String salesManager, String recruiter, String summary, String allNotes) {
        try {
            System.debug('Updating candidate: ' + candidateId);
            
            // Get the candidate record with Contact lookup
            Candidate__c candidate = [SELECT Id, Name, Contact__c, Contact__r.Id, Email__c, Phone__c, Position__c, Status__c, Office_Location_Picklist__c, Sales_Manager__c, RecruiterPicklist__c, Candidate_Summary__c, All_Notes__c FROM Candidate__c WHERE Id = :candidateId LIMIT 1];
            
            // Update or create Contact if candidate name is provided
            if (String.isNotBlank(candidateName)) {
                Contact candidateContact;
                
                if (candidate.Contact__c != null) {
                    // Update existing contact
                    candidateContact = candidate.Contact__r;
                } else {
                    // Create new contact
                    candidateContact = new Contact();
                }
                
                // Parse name (assume "First Last" format)
                List<String> nameParts = candidateName.split(' ');
                if (nameParts.size() >= 2) {
                    candidateContact.FirstName = nameParts[0];
                    // Join remaining parts as last name
                    String lastName = '';
                    for (Integer i = 1; i < nameParts.size(); i++) {
                        if (i > 1) lastName += ' ';
                        lastName += nameParts[i];
                    }
                    candidateContact.LastName = lastName;
                } else {
                    candidateContact.FirstName = candidateName;
                    candidateContact.LastName = 'Candidate';
                }
                
                candidateContact.Email = email;
                candidateContact.Phone = phone;
                
                if (candidate.Contact__c != null) {
                    update candidateContact;
                } else {
                    insert candidateContact;
                    candidate.Contact__c = candidateContact.Id;
                }
            }
            
            // Update candidate fields
            candidate.Email__c = email;
            candidate.Phone__c = phone;
            
            if (String.isNotBlank(position)) {
                candidate.Position__c = position;
            }
            if (String.isNotBlank(status)) {
                candidate.Status__c = status;
            }
            if (String.isNotBlank(officeLocation)) {
                candidate.Office_Location_Picklist__c = officeLocation;
            }
            if (String.isNotBlank(salesManager)) {
                candidate.Sales_Manager__c = salesManager;
            }
            if (String.isNotBlank(recruiter)) {
                candidate.RecruiterPicklist__c = recruiter;
            }
            if (String.isNotBlank(summary)) {
                candidate.Candidate_Summary__c = summary;
            }
            if (String.isNotBlank(allNotes)) {
                candidate.All_Notes__c = allNotes;
            }
            
            update candidate;
            
            System.debug('Candidate updated successfully: ' + candidateName);
            return 'SUCCESS';
            
        } catch (Exception e) {
            System.debug('Error updating candidate: ' + e.getMessage());
            throw new AuraHandledException('Failed to update candidate: ' + e.getMessage());
        }
    }
    
    /**
     * Get Active/In Process candidates for a specific sales manager
     * @param salesManager The name of the sales manager
     * @return List of candidates with their details
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getCandidatesBySalesManager(String salesManager) {
        List<Map<String, Object>> candidateList = new List<Map<String, Object>>();
        
        try {
            System.debug('Getting candidates for sales manager: ' + salesManager);
            
            // Build list of manager names to query based on reassignment logic
            List<String> managerNames = new List<String>();
            managerNames.add(salesManager);
            
            // Include inactive managers whose candidates are reassigned to this manager
            if (salesManager == 'Bradley Sofonia') {
                managerNames.add('Scott Primm');
            } else if (salesManager == 'Elizabeth Kagele') {
                managerNames.add('Diljeet Masuda');
            }
            
            // Query Active/In Process candidates for the specified sales manager(s)
            List<Candidate__c> candidates = [
                SELECT Id, Name, Email__c, Phone__c, Position__c, Status__c,
                       Office_Location_Picklist__c, Sales_Manager__c, 
                       RecruiterPicklist__c, Next_Meeting_Date__c,
                       CreatedDate, LastModifiedDate
                FROM Candidate__c 
                WHERE Status__c = 'Active/In Process'
                AND Sales_Manager__c IN :managerNames
                ORDER BY Name ASC
            ];
            
            System.debug('Found ' + candidates.size() + ' candidates for ' + salesManager + ' (including reassigned)');
            
            // Format each candidate
            for (Candidate__c candidate : candidates) {
                Map<String, Object> candidateData = new Map<String, Object>();
                candidateData.put('id', candidate.Id);
                candidateData.put('name', candidate.Name);
                candidateData.put('email', candidate.Email__c != null ? candidate.Email__c : '');
                candidateData.put('phone', candidate.Phone__c != null ? candidate.Phone__c : '');
                candidateData.put('emailLink', candidate.Email__c != null ? 'mailto:' + candidate.Email__c : '');
                candidateData.put('phoneLink', candidate.Phone__c != null ? 'tel:' + candidate.Phone__c : '');
                candidateData.put('position', candidate.Position__c != null ? candidate.Position__c : 'Insurance Agent');
                candidateData.put('status', candidate.Status__c);
                candidateData.put('location', candidate.Office_Location_Picklist__c != null ? candidate.Office_Location_Picklist__c : 'Remote');
                candidateData.put('salesManager', candidate.Sales_Manager__c);
                candidateData.put('recruiter', candidate.RecruiterPicklist__c != null ? candidate.RecruiterPicklist__c : 'Unassigned');
                candidateData.put('nextMeeting', candidate.Next_Meeting_Date__c != null ? String.valueOf(candidate.Next_Meeting_Date__c) : 'Not Scheduled');
                candidateData.put('leadSource', 'Recruiter Portal');
                candidateData.put('experience', 'To Be Determined');
                candidateData.put('createdDate', candidate.CreatedDate);
                candidateData.put('lastModified', candidate.LastModifiedDate);
                
                candidateList.add(candidateData);
            }
            
        } catch (Exception e) {
            System.debug('Error in getCandidatesBySalesManager: ' + e.getMessage());
            throw new AuraHandledException('Failed to get candidates: ' + e.getMessage());
        }
        
        return candidateList;
    }
    
    // Comparator class to sort interview counts descending
    private class InterviewCountComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Integer countA = (Integer)a.get('count');
            Integer countB = (Integer)b.get('count');
            return countB - countA; // Descending order
        }
    }
    
    @AuraEnabled
    public static String createFeedbackCase(String submittedById, String feedbackType, String priority, String subject, String description) {
        try {
            // Create Feedback record
            Feedback__c feedback = new Feedback__c();
            feedback.Subject__c = subject;
            feedback.Description__c = description;
            feedback.Feedback_Type__c = feedbackType;
            feedback.Status__c = 'New';
            feedback.Submitted_By__c = UserInfo.getUserId();
            
            // Set priority
            if (String.isNotBlank(priority)) {
                feedback.Priority__c = priority;
            } else {
                feedback.Priority__c = 'Medium';
            }
            
            // Leave Assigned_To__c null for unassigned queue
            
            insert feedback;
            
            return feedback.Id;
            
        } catch (Exception e) {
            System.debug('Error creating feedback: ' + e.getMessage());
            throw new AuraHandledException('Failed to create feedback: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static Task getTaskDetails(String taskId) {
        try {
            return [
                SELECT Id, Subject, Status, ActivityDate, Priority, Description,
                       CallDisposition, WhoId, Who.Name, WhatId, What.Name
                FROM Task
                WHERE Id = :taskId
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Failed to get task details: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void updateTaskRecord(String taskId, String subject, String status, Date activityDate, String priority, String description) {
        try {
            Task taskToUpdate = [SELECT Id FROM Task WHERE Id = :taskId LIMIT 1];
            
            if (String.isNotBlank(subject)) {
                taskToUpdate.Subject = subject;
            }
            if (String.isNotBlank(status)) {
                taskToUpdate.Status = status;
            }
            if (activityDate != null) {
                taskToUpdate.ActivityDate = activityDate;
            }
            if (String.isNotBlank(priority)) {
                taskToUpdate.Priority = priority;
            }
            // Allow setting description to null to clear it
            taskToUpdate.Description = description;
            
            update taskToUpdate;
        } catch (Exception e) {
            throw new AuraHandledException('Failed to update task: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static List<Map<String, Object>> getRecentNotes() {
        List<Map<String, Object>> notesList = new List<Map<String, Object>>();
        
        try {
            String currentUserId = UserInfo.getUserId();
            System.debug('Getting recent notes for user: ' + currentUserId);
            
            // Query ContentVersion to get note data with ContentDocument info
            // ContentVersion stores the actual content, ContentDocument is the container
            // Filter by current user's notes (OwnerId = current user)
            List<ContentVersion> contentVersions = [
                SELECT Id, ContentDocumentId, Title, TextPreview, CreatedDate, 
                       CreatedBy.Name, OwnerId, FileType
                FROM ContentVersion 
                WHERE FileType = 'SNOTE'
                AND OwnerId = :currentUserId
                ORDER BY CreatedDate DESC 
                LIMIT 50
            ];
            
            System.debug('Found ' + contentVersions.size() + ' notes');
            
            // Get ContentDocumentIds to query for related records
            Set<Id> contentDocumentIds = new Set<Id>();
            for (ContentVersion cv : contentVersions) {
                contentDocumentIds.add(cv.ContentDocumentId);
            }
            
            // Query ContentDocumentLink to find attached records
            Map<Id, List<String>> documentToRecordNames = new Map<Id, List<String>>();
            if (!contentDocumentIds.isEmpty()) {
                List<ContentDocumentLink> links = [
                    SELECT ContentDocumentId, LinkedEntityId, LinkedEntity.Name
                    FROM ContentDocumentLink
                    WHERE ContentDocumentId IN :contentDocumentIds
                    AND LinkedEntityId != :currentUserId
                ];
                
                for (ContentDocumentLink link : links) {
                    if (!documentToRecordNames.containsKey(link.ContentDocumentId)) {
                        documentToRecordNames.put(link.ContentDocumentId, new List<String>());
                    }
                    documentToRecordNames.get(link.ContentDocumentId).add(link.LinkedEntity.Name);
                }
            }
            
            // Format notes for display
            for (ContentVersion cv : contentVersions) {
                Map<String, Object> noteData = new Map<String, Object>();
                noteData.put('id', cv.Id);
                noteData.put('contentDocumentId', cv.ContentDocumentId);
                noteData.put('title', cv.Title);
                noteData.put('preview', cv.TextPreview != null ? cv.TextPreview : 'No preview available');
                noteData.put('createdDate', cv.CreatedDate);
                noteData.put('createdBy', cv.CreatedBy.Name);
                
                // Get attached record names
                List<String> attachedRecords = documentToRecordNames.get(cv.ContentDocumentId);
                if (attachedRecords != null && !attachedRecords.isEmpty()) {
                    noteData.put('attachedTo', String.join(attachedRecords, ', '));
                } else {
                    noteData.put('attachedTo', 'Not attached to any record');
                }
                
                notesList.add(noteData);
            }
            
            System.debug('Returning ' + notesList.size() + ' formatted notes');
            
        } catch (Exception e) {
            System.debug('Error in getRecentNotes: ' + e.getMessage());
            System.debug('Stack trace: ' + e.getStackTraceString());
        }
        
        return notesList;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getReportedFycThisQuarter() {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> chartData = new List<Map<String, Object>>();
        Decimal totalFyc = 0;
        
        try {
            // Get the current fiscal quarter start and end dates
            Integer currentMonth = Date.today().month();
            Integer monthsToSubtract = Math.mod(currentMonth - 1, 3);
            Date quarterStart = Date.today().toStartOfMonth().addMonths(-monthsToSubtract);
            Date quarterEnd = quarterStart.addMonths(3).addDays(-1);
            
            // Query Opportunities reported this quarter and aggregate by Soliciting Agent
            // This matches the dashboard table "Reported FYC This Quarter"
            AggregateResult[] groupedResults = [
                SELECT Soliciting_Agent__c, Soliciting_Agent__r.Name, SUM(FYC__c) totalFyc
                FROM Opportunity
                WHERE Reported_Date__c >= :quarterStart 
                AND Reported_Date__c <= :quarterEnd
                AND FYC__c != null
                AND Soliciting_Agent__c != null
                GROUP BY Soliciting_Agent__c, Soliciting_Agent__r.Name
                ORDER BY SUM(FYC__c) DESC
            ];
            
            // Define color palette for the chart
            List<String> colors = new List<String>{
                '#5B9BD5', // Blue
                '#70AD47', // Green
                '#FFC000', // Yellow
                '#C55A11', // Orange
                '#7030A0', // Purple
                '#44546A', // Dark Blue
                '#ED7D31', // Light Orange
                '#A5A5A5'  // Gray
            };
            
            // Only show top 4 agents, group the rest as "Other"
            Integer maxAgents = 4;
            Integer colorIndex = 0;
            Decimal otherTotal = 0;
            
            for (Integer i = 0; i < groupedResults.size(); i++) {
                AggregateResult ar = groupedResults[i];
                String agentName = (String) ar.get('Name');
                Decimal fycAmount = (Decimal) ar.get('totalFyc');
                
                if (agentName == null) {
                    agentName = 'Other';
                }
                
                if (fycAmount == null) {
                    fycAmount = 0;
                }
                
                totalFyc += fycAmount;
                
                // Add to top 4, or accumulate in "Other"
                if (i < maxAgents) {
                    Integer colorIdx = Math.mod(colorIndex, colors.size());
                    String color = colors[colorIdx];
                    
                    Map<String, Object> agentData = new Map<String, Object>();
                    agentData.put('name', agentName);
                    agentData.put('value', fycAmount);
                    agentData.put('formattedValue', '$' + String.valueOf(fycAmount.setScale(2).format()));
                    agentData.put('color', color);
                    agentData.put('colorStyle', 'background-color: ' + color + ';');
                    
                    chartData.add(agentData);
                    colorIndex++;
                } else {
                    // Accumulate remaining agents into "Other"
                    otherTotal += fycAmount;
                }
            }
            
            // Add "Other" category if there are agents beyond top 4
            if (otherTotal > 0) {
                Integer colorIdx = Math.mod(colorIndex, colors.size());
                String color = colors[colorIdx];
                
                Map<String, Object> otherData = new Map<String, Object>();
                otherData.put('name', 'Other');
                otherData.put('value', otherTotal);
                otherData.put('formattedValue', '$' + String.valueOf(otherTotal.setScale(2).format()));
                otherData.put('color', color);
                otherData.put('colorStyle', 'background-color: ' + color + ';');
                
                chartData.add(otherData);
            }
            
            result.put('data', chartData);
            result.put('total', totalFyc);
            result.put('quarterStart', quarterStart);
            result.put('quarterEnd', quarterEnd);
            
        } catch (Exception e) {
            System.debug('Error in getReportedFycThisQuarter: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving FYC data: ' + e.getMessage());
        }
        
        return result;
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getActiveUsersThisMonth() {
        Map<String, Object> result = new Map<String, Object>();
        Map<String, Integer> userActivityMap = new Map<String, Integer>();
        Integer totalRecords = 0;
        
        try {
            // Get current month date range
            Date monthStart = Date.today().toStartOfMonth();
            Date monthEnd = monthStart.addMonths(1).addDays(-1);
            
            // Query Candidates created this month, grouped by CreatedBy
            AggregateResult[] candidateResults = [
                SELECT CreatedBy.Name userName, COUNT(Id) recordCount
                FROM Candidate__c
                WHERE CreatedDate >= :monthStart 
                AND CreatedDate <= :monthEnd
                AND CreatedBy.IsActive = true
                GROUP BY CreatedBy.Name
            ];
            
            // Add candidate counts to map
            for (AggregateResult ar : candidateResults) {
                String userName = (String) ar.get('userName');
                Integer count = (Integer) ar.get('recordCount');
                
                if (userName != null && count != null) {
                    userActivityMap.put(userName, count);
                    totalRecords += count;
                }
            }
            
            // Query Interviews created this month, grouped by Conducted_By
            AggregateResult[] interviewResults = [
                SELECT Conducted_By__r.Name userName, COUNT(Id) recordCount
                FROM Interview__c
                WHERE CreatedDate >= :monthStart 
                AND CreatedDate <= :monthEnd
                AND Conducted_By__c != null
                AND Conducted_By__r.IsActive = true
                GROUP BY Conducted_By__r.Name
            ];
            
            // Add interview counts to map (combine with existing candidate counts)
            for (AggregateResult ar : interviewResults) {
                String userName = (String) ar.get('userName');
                Integer count = (Integer) ar.get('recordCount');
                
                if (userName != null && count != null) {
                    Integer existingCount = userActivityMap.get(userName);
                    if (existingCount != null) {
                        userActivityMap.put(userName, existingCount + count);
                    } else {
                        userActivityMap.put(userName, count);
                    }
                    totalRecords += count;
                }
            }
            
            // Convert map to list and sort by count descending
            List<Map<String, Object>> userData = new List<Map<String, Object>>();
            for (String userName : userActivityMap.keySet()) {
                Map<String, Object> userRecord = new Map<String, Object>();
                userRecord.put('name', userName);
                userRecord.put('count', userActivityMap.get(userName));
                userData.add(userRecord);
            }
            
            // Sort by count descending
            userData.sort(new ActivityCountComparator());
            
            result.put('data', userData);
            result.put('total', totalRecords);
            result.put('monthStart', monthStart);
            result.put('monthEnd', monthEnd);
            
        } catch (Exception e) {
            System.debug('Error in getActiveUsersThisMonth: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving active users data: ' + e.getMessage());
        }
        
        return result;
    }
    
    // Comparator class for sorting user activity by count
    private class ActivityCountComparator implements Comparator<Map<String, Object>> {
        public Integer compare(Map<String, Object> a, Map<String, Object> b) {
            Integer countA = (Integer) a.get('count');
            Integer countB = (Integer) b.get('count');
            
            if (countA == null) countA = 0;
            if (countB == null) countB = 0;
            
            // Sort descending (highest count first)
            return countB - countA;
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String, Object> getOpportunityStages() {
        Map<String, Object> result = new Map<String, Object>();
        List<Map<String, Object>> stagesList = new List<Map<String, Object>>();
        Decimal totalAmount = 0;
        
        try {
            // Query Opportunities grouped by StageName
            // Filters match the dashboard: open opportunities with amounts
            AggregateResult[] stageResults = [
                SELECT StageName, COUNT(Id) oppCount, SUM(Amount) totalAmount
                FROM Opportunity
                WHERE IsClosed = false
                AND Amount != null
                GROUP BY StageName
                ORDER BY SUM(Amount) DESC
            ];
            
            // Process results
            for (AggregateResult ar : stageResults) {
                String stageName = (String) ar.get('StageName');
                Integer oppCount = (Integer) ar.get('oppCount');
                Decimal stageAmount = (Decimal) ar.get('totalAmount');
                
                if (stageName != null && stageAmount != null) {
                    totalAmount += stageAmount;
                    
                    Map<String, Object> stageData = new Map<String, Object>();
                    stageData.put('name', stageName);
                    stageData.put('count', oppCount);
                    stageData.put('amount', stageAmount);
                    
                    stagesList.add(stageData);
                }
            }
            
            result.put('stages', stagesList);
            result.put('total', totalAmount);
            
        } catch (Exception e) {
            System.debug('Error in getOpportunityStages: ' + e.getMessage());
            throw new AuraHandledException('Error retrieving opportunity stages: ' + e.getMessage());
        }
        
        return result;
    }
}