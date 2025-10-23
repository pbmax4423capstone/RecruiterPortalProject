public inherited sharing class RecruiterDashboardController {
    
    @AuraEnabled(cacheable=true)
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
        
        // Get recent activity data
        List<Map<String, Object>> recentActivity = getRecentActivity();
        dashboardData.put('recentActivity', recentActivity);
        
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
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
                
                // Reassign candidates according to specifications
                if (managerName == 'Scott Primm') {
                    // Add Scott Primm's candidates to Bradley Sofonia
                    managerName = 'Bradley Sofonia';
                } else if (managerName == 'Diljeet Masuda') {
                    // Add Diljeet Masuda's candidates to Elizabeth Kagele
                    managerName = 'Elizabeth Kagele';
                }
                // Skip if this is one of the excluded managers (already reassigned above)
                
                // Accumulate counts for managers (in case of multiple reassignments)
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

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInterviewStatsByType() {
        Map<String, Object> interviewStats = new Map<String, Object>();
        
        try {
            // Get interview counts by type
            List<AggregateResult> typeResults = [
                SELECT Interview_Type__c type, COUNT(Id) cnt
                FROM Interview__c 
                WHERE Interview_Type__c != null
                GROUP BY Interview_Type__c
                ORDER BY Interview_Type__c
            ];
            
            // Initialize all types to 0
            Map<String, Integer> typeCounts = new Map<String, Integer>{
                'Attraction' => 0,
                'SI1' => 0,
                'SI2' => 0,
                'SI3' => 0,
                'Career' => 0
            };
            
            // Populate actual counts
            for (AggregateResult result : typeResults) {
                String type = (String)result.get('type');
                Integer count = (Integer)result.get('cnt');
                
                if (typeCounts.containsKey(type)) {
                    typeCounts.put(type, count);
                }
            }
            
            // Calculate totals
            Integer totalInterviews = 0;
            for (Integer count : typeCounts.values()) {
                totalInterviews += count;
            }
            
            // Get this week's interviews
            Date weekStart = Date.today().toStartOfWeek();
            Date weekEnd = weekStart.addDays(6);
            
            Integer thisWeekCount = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE CreatedDate >= :weekStart 
                AND CreatedDate <= :weekEnd
            ];
            
            // Get scheduled interviews (assuming we have a date field for scheduling)
            Integer scheduledCount = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE Interview_Status__c = 'Scheduled'
            ];
            
            interviewStats.put('attraction', typeCounts.get('Attraction'));
            interviewStats.put('si1', typeCounts.get('SI1'));
            interviewStats.put('si2', typeCounts.get('SI2'));
            interviewStats.put('si3', typeCounts.get('SI3'));
            interviewStats.put('career', typeCounts.get('Career'));
            interviewStats.put('total', totalInterviews);
            interviewStats.put('thisWeek', thisWeekCount);
            interviewStats.put('scheduled', scheduledCount);
            
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

    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getInterviewStatsByInterviewer() {
        List<Map<String, Object>> interviewerStats = new List<Map<String, Object>>();
        
        try {
            // Get interview counts by interviewer and type
            List<AggregateResult> results = [
                SELECT Conducted_By__c interviewer, 
                       Conducted_By__r.Name interviewerName, 
                       Interview_Type__c type, 
                       COUNT(Id) cnt
                FROM Interview__c 
                WHERE Conducted_By__c != null 
                AND Interview_Type__c != null
                GROUP BY Conducted_By__c, Conducted_By__r.Name, Interview_Type__c
                ORDER BY Conducted_By__r.Name, Interview_Type__c
            ];
            
            // Group results by interviewer
            Map<Id, Map<String, Object>> interviewerMap = new Map<Id, Map<String, Object>>();
            
            for (AggregateResult result : results) {
                Id interviewerId = (Id)result.get('interviewer');
                String interviewerName = (String)result.get('interviewerName');
                String type = (String)result.get('type');
                Integer count = (Integer)result.get('cnt');
                
                if (!interviewerMap.containsKey(interviewerId)) {
                    interviewerMap.put(interviewerId, new Map<String, Object>{
                        'interviewerId' => interviewerId,
                        'interviewerName' => interviewerName,
                        'attraction' => 0,
                        'si1' => 0,
                        'si2' => 0,
                        'si3' => 0,
                        'career' => 0,
                        'total' => 0
                    });
                }
                
                Map<String, Object> interviewer = interviewerMap.get(interviewerId);
                
                // Map the type to lowercase for consistency
                if (type == 'Attraction') {
                    interviewer.put('attraction', count);
                } else if (type == 'SI1') {
                    interviewer.put('si1', count);
                } else if (type == 'SI2') {
                    interviewer.put('si2', count);
                } else if (type == 'SI3') {
                    interviewer.put('si3', count);
                } else if (type == 'Career') {
                    interviewer.put('career', count);
                }
                
                // Update total
                Integer currentTotal = (Integer)interviewer.get('total');
                interviewer.put('total', currentTotal + count);
            }
            
            // Convert to list and sort by total interviews (descending)
            interviewerStats.addAll(interviewerMap.values());
            
        } catch (Exception e) {
            System.debug('Error in getInterviewStatsByInterviewer: ' + e.getMessage());
        }
        
        return interviewerStats;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getInterviewTypeWithInterviewerStats() {
        Map<String, Object> result = new Map<String, Object>();
        
        try {
            // Query ALL interviews by type and interviewer - no filtering
            List<AggregateResult> results = [
                SELECT Interview_Type__c type, 
                       Conducted_By__r.Name interviewerName,
                       COUNT(Id) cnt
                FROM Interview__c 
                WHERE Conducted_By__c != null 
                AND Interview_Type__c != null
                GROUP BY Interview_Type__c, Conducted_By__r.Name
                ORDER BY Interview_Type__c, COUNT(Id) DESC
            ];
            
            System.debug('Total interview results found: ' + results.size());
            
            // Initialize structure for each interview type
            Map<String, List<Map<String, Object>>> typeStats = new Map<String, List<Map<String, Object>>>{
                'Attraction' => new List<Map<String, Object>>(),
                'SI1' => new List<Map<String, Object>>(),
                'SI2' => new List<Map<String, Object>>(),
                'SI3' => new List<Map<String, Object>>(),
                'Career' => new List<Map<String, Object>>()
            };
            
            // Populate the data
            for (AggregateResult ar : results) {
                String type = (String)ar.get('type');
                String interviewer = (String)ar.get('interviewerName');
                Integer count = (Integer)ar.get('cnt');
                
                System.debug('Processing: Type=' + type + ', Interviewer=' + interviewer + ', Count=' + count);
                
                if (typeStats.containsKey(type)) {
                    typeStats.get(type).add(new Map<String, Object>{
                        'interviewer' => interviewer,
                        'count' => count
                    });
                }
            }
            
            result.put('attractionByInterviewer', typeStats.get('Attraction'));
            result.put('si1ByInterviewer', typeStats.get('SI1'));
            result.put('si2ByInterviewer', typeStats.get('SI2'));
            result.put('si3ByInterviewer', typeStats.get('SI3'));
            result.put('careerByInterviewer', typeStats.get('Career'));
            
            System.debug('Final result: ' + result);
            
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

    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRecentActivity() {
        List<Map<String, Object>> activities = new List<Map<String, Object>>();
        
        try {
            // Get recent interviews
            List<Interview__c> recentInterviews = [
                SELECT Id, Name, Interview_Type__c, Interview_Status__c, CreatedDate,
                       Candidate__r.Name, Conducted_By__r.Name
                FROM Interview__c 
                ORDER BY CreatedDate DESC 
                LIMIT 10
            ];
            
            for (Interview__c interview : recentInterviews) {
                Map<String, Object> activity = new Map<String, Object>();
                activity.put('id', interview.Id);
                activity.put('type', 'Interview');
                activity.put('title', interview.Name);
                activity.put('subtitle', 'Type: ' + interview.Interview_Type__c + ' | Status: ' + interview.Interview_Status__c);
                activity.put('candidateName', interview.Candidate__r?.Name);
                activity.put('interviewerName', interview.Conducted_By__r?.Name);
                activity.put('date', interview.CreatedDate);
                activities.add(activity);
            }
        } catch (Exception e) {
            System.debug('Error in getRecentActivity: ' + e.getMessage());
        }
        
        return activities;
    }
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getRachyllCallDetails(String callType) {
        // Backward compatibility shim that returns current user's details
        return getCurrentUserCallDetails(callType);
    }
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getCurrentUserCallDetails(String callType) {
        List<Map<String, Object>> callDetails = new List<Map<String, Object>>();
        try {
            Date today = Date.today();
            String whereClause = '';
            switch on callType {
                when 'scheduled' { whereClause = 'AND ActivityDate >= TODAY'; }
                when 'pastdue'   { whereClause = 'AND ActivityDate < TODAY'; }
            }
            String query = 'SELECT Id, Subject, ActivityDate, Status, Description, WhatId, WhoId, ' +
                           'What.Name, Who.Name ' +
                           'FROM Task ' +
                           'WHERE OwnerId = \'' + String.escapeSingleQuotes(UserInfo.getUserId()) + '\' ' +
                           'AND Type = \'Call\' ' +
                           'AND IsClosed = false ' +
                           whereClause + ' ' +
                           'ORDER BY ActivityDate ASC LIMIT 50';
            List<Task> tasks = Database.query(query);
            for (Task task : tasks) {
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
        } catch (Exception e) {
            System.debug('Error in getCurrentUserCallDetails: ' + e.getMessage());
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
    public static String completeCallWithNotesAndSchedule(String taskId, String notes, Date nextCallDate) {
        try {
            // Complete the current task
            Task taskToComplete = [
                SELECT Id, Status, Description, WhatId, WhoId, OwnerId, Subject
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
    
    @AuraEnabled(cacheable=true)
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
    
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getPastDueCalls() {
        List<Map<String, Object>> pastDueCalls = new List<Map<String, Object>>();
        
        try {
            // Get past due tasks (ActivityDate < TODAY and Status != 'Completed')
            List<Task> pastDueTasks = [
                SELECT Id, Subject, Description, ActivityDate, Status, OwnerId, Owner.Name, 
                       WhatId, What.Name, CreatedDate
                FROM Task 
                WHERE ActivityDate < TODAY 
                AND Status != 'Completed'
                AND Status != 'Deferred'
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
    
    @AuraEnabled
    public static Map<String, String> getCurrentUserInfo() {
        Map<String, String> result = new Map<String, String>();
        try {
            User currentUser = [SELECT Id, Name, Email FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            result.put('id', currentUser.Id);
            result.put('name', currentUser.Name);
            result.put('email', currentUser.Email);
        } catch (Exception e) {
            System.debug('Error getting current user info: ' + e.getMessage());
            result.put('id', UserInfo.getUserId());
            result.put('name', UserInfo.getName());
            result.put('email', '');
        }
        return result;
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
    
    @AuraEnabled(cacheable=true)
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
}
