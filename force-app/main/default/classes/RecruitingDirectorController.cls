/**
 * Controller for Recruiting Director Dashboard
 * 
 * Provides global and individual sales manager metrics with date range filtering.
 * Authorized for Rachyll Tenny and Neilie Torres only.
 * 
 * @author Recruiter Portal Development Team
 * @date 2026-01-07
 */
public without sharing class RecruitingDirectorController {
    
    /**
     * Returns list of sales managers for picker
     * 
     * @return List<Map<String,String>> with label and value keys
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String,String>> getSalesManagerList() {
        List<Map<String,String>> options = new List<Map<String,String>>();
        
        try {
            // Check if user has access to Candidate object and Sales_Manager__c field
            if (!Schema.sObjectType.Candidate__c.isAccessible() || 
                !Schema.sObjectType.Candidate__c.fields.Sales_Manager__c.isAccessible()) {
                System.debug('User does not have access to Candidate__c.Sales_Manager__c field');
                // Return just "All Sales Managers" option as fallback
                options.add(new Map<String,String>{
                    'label' => 'All Sales Managers',
                    'value' => 'All Sales Managers'
                });
                return options;
            }
            
            // Add "All Sales Managers" option first
            options.add(new Map<String,String>{
                'label' => 'All Sales Managers',
                'value' => 'All Sales Managers'
            });
            
            // Query distinct sales managers from candidates
            List<AggregateResult> managers = [
                SELECT Sales_Manager__c 
                FROM Candidate__c 
                WHERE Sales_Manager__c != null
                GROUP BY Sales_Manager__c
                ORDER BY Sales_Manager__c
            ];
            
            for (AggregateResult ar : managers) {
                String managerName = (String)ar.get('Sales_Manager__c');
                options.add(new Map<String,String>{
                    'label' => managerName,
                    'value' => managerName
                });
            }
            
        } catch (Exception e) {
            System.debug('Error loading sales managers: ' + e.getMessage());
            // Return at least the "All Sales Managers" option
            if (options.isEmpty()) {
                options.add(new Map<String,String>{
                    'label' => 'All Sales Managers',
                    'value' => 'All Sales Managers'
                });
            }
        }
        
        return options;
    }
    
    /**
     * Returns metrics for specific sales manager with date range filter
     * 
     * @param managerName Sales manager name
     * @param dateRange 'This Month', 'This Quarter', or 'This Year'
     * @return Map<String,Object> containing metric counts
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getMetricsForManager(String managerName, String dateRange) {
        Map<String,Object> metrics = new Map<String,Object>();
        
        try {
            // Total Candidates (lifetime, no date filter)
            Integer totalCandidates = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Sales_Manager__c = :managerName
            ];
            metrics.put('totalCandidates', totalCandidates);
            
            // Upcoming Interviews
            Integer upcomingInterviews = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE Candidate__r.Sales_Manager__c = :managerName
                AND Date_Time_Scheduled__c >= TODAY
                AND Interview_Status__c = 'Scheduled'
            ];
            metrics.put('upcomingInterviews', upcomingInterviews);
            
            // Active Pipeline
            Integer activePipeline = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Sales_Manager__c = :managerName
                AND Status__c = 'Active/In Process'
            ];
            metrics.put('activePipeline', activePipeline);
            
            // On Contract B
            Integer onContractB = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Candidate__r.Sales_Manager__c = :managerName
                AND Contract_Type__c = 'B'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractB', onContractB);
            
            // On Contract A
            Integer onContractA = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Candidate__r.Sales_Manager__c = :managerName
                AND Contract_Type__c = 'A'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractA', onContractA);
            
            // Hired This [Period] - uses date range
            String hireDateFilter = getDateRangeFilter(dateRange, 'Contract_Effective__c');
            String hiredQuery = 'SELECT COUNT() FROM ALC__c WHERE Candidate__r.Sales_Manager__c = :managerName AND Stage__c = \'Contracting Complete\' AND ' + hireDateFilter;
            Integer hiredThisPeriod = Database.countQuery(hiredQuery);
            metrics.put('hiredThisPeriod', hiredThisPeriod);
            
            // Completed Interviews - uses date range
            String interviewDateFilter = getDateRangeFilter(dateRange, 'Date_Completed__c');
            String interviewQuery = 'SELECT COUNT() FROM Interview__c WHERE Candidate__r.Sales_Manager__c = :managerName AND Interview_Status__c = \'Completed\' AND ' + interviewDateFilter;
            Integer completedInterviews = Database.countQuery(interviewQuery);
            metrics.put('completedInterviewsThisPeriod', completedInterviews);
            
        } catch (Exception e) {
            System.debug('Error in getMetricsForManager: ' + e.getMessage());
        }
        
        return metrics;
    }
    
    /**
     * Returns aggregated metrics across all sales managers
     * 
     * @param dateRange 'This Month', 'This Quarter', or 'This Year'
     * @return Map<String,Object> containing aggregated metric counts
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getGlobalMetrics(String dateRange) {
        Map<String,Object> metrics = new Map<String,Object>();
        
        try {
            // Total Candidates (lifetime)
            Integer totalCandidates = [SELECT COUNT() FROM Candidate__c];
            metrics.put('totalCandidates', totalCandidates);
            
            // Upcoming Interviews
            Integer upcomingInterviews = [
                SELECT COUNT() 
                FROM Interview__c 
                WHERE Date_Time_Scheduled__c >= TODAY
                AND Interview_Status__c = 'Scheduled'
            ];
            metrics.put('upcomingInterviews', upcomingInterviews);
            
            // Active Pipeline
            Integer activePipeline = [
                SELECT COUNT() 
                FROM Candidate__c 
                WHERE Status__c = 'Active/In Process'
            ];
            metrics.put('activePipeline', activePipeline);
            
            // On Contract B
            Integer onContractB = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Contract_Type__c = 'B'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractB', onContractB);
            
            // On Contract A
            Integer onContractA = [
                SELECT COUNT() 
                FROM ALC__c 
                WHERE Contract_Type__c = 'A'
                AND Stage__c = 'Contracting Complete'
            ];
            metrics.put('onContractA', onContractA);
            
            // Hired This [Period]
            String hireDateFilter = getDateRangeFilter(dateRange, 'Contract_Effective__c');
            String hiredQuery = 'SELECT COUNT() FROM ALC__c WHERE Stage__c = \'Contracting Complete\' AND ' + hireDateFilter;
            Integer hiredThisPeriod = Database.countQuery(hiredQuery);
            metrics.put('hiredThisPeriod', hiredThisPeriod);
            
            // Completed Interviews
            String interviewDateFilter = getDateRangeFilter(dateRange, 'Date_Completed__c');
            String interviewQuery = 'SELECT COUNT() FROM Interview__c WHERE Interview_Status__c = \'Completed\' AND ' + interviewDateFilter;
            Integer completedInterviews = Database.countQuery(interviewQuery);
            metrics.put('completedInterviewsThisPeriod', completedInterviews);
            
        } catch (Exception e) {
            System.debug('Error in getGlobalMetrics: ' + e.getMessage());
        }
        
        return metrics;
    }
    
    /**
     * Returns comparison data for chart rendering
     * 
     * @param metricType 'totalCandidates' or 'activePipeline'
     * @param dateRange Not used for these metrics
     * @return Map<String,Object> with labels and values arrays
     */
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getManagerComparison(String metricType, String dateRange) {
        Map<String,Object> chartData = new Map<String,Object>();
        List<String> labels = new List<String>();
        List<Integer> values = new List<Integer>();
        
        try {
            if (metricType == 'totalCandidates') {
                List<AggregateResult> results = [
                    SELECT Sales_Manager__c manager, COUNT(Id) total
                    FROM Candidate__c
                    WHERE Sales_Manager__c != null
                    GROUP BY Sales_Manager__c
                    ORDER BY COUNT(Id) DESC
                ];
                
                for (AggregateResult ar : results) {
                    labels.add((String)ar.get('manager'));
                    values.add((Integer)ar.get('total'));
                }
            } else if (metricType == 'activePipeline') {
                List<AggregateResult> results = [
                    SELECT Sales_Manager__c manager, COUNT(Id) total
                    FROM Candidate__c
                    WHERE Sales_Manager__c != null
                    AND Status__c = 'Active/In Process'
                    GROUP BY Sales_Manager__c
                    ORDER BY COUNT(Id) DESC
                ];
                
                for (AggregateResult ar : results) {
                    labels.add((String)ar.get('manager'));
                    values.add((Integer)ar.get('total'));
                }
            }
            
            chartData.put('labels', labels);
            chartData.put('values', values);
            
        } catch (Exception e) {
            System.debug('Error in getManagerComparison: ' + e.getMessage());
        }
        
        return chartData;
    }
    
    /**
     * Helper method to build date range filter for SOQL
     * 
     * @param dateRange 'This Month', 'This Quarter', or 'This Year'
     * @param fieldName Date field to filter on
     * @return String SOQL WHERE clause fragment
     */
    private static String getDateRangeFilter(String dateRange, String fieldName) {
        if (dateRange == 'This Quarter') {
            return fieldName + ' = THIS_QUARTER';
        } else if (dateRange == 'This Year') {
            return fieldName + ' = THIS_YEAR';
        } else {
            // Default to 'This Month'
            return fieldName + ' = THIS_MONTH';
        }
    }
    
    /**
     * Retrieves detailed list of all candidates or filtered by manager
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange Not used for this metric
     * @return List<Map<String,Object>> candidate records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getCandidatesList(String managerName, String dateRange) {
        List<Map<String,Object>> candidateList = new List<Map<String,Object>>();
        
        try {
            String query = 'SELECT Id, Name, Status__c, Highest_Level_Achieved__c, ' +
                          'Email__c, Phone__c, Office_Location__c, Sales_Manager__c, CreatedDate ' +
                          'FROM Candidate__c ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'WHERE Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY CreatedDate DESC LIMIT 500';
            
            List<Candidate__c> candidates = Database.query(query);
            
            for (Candidate__c candidate : candidates) {
                Map<String,Object> candidateMap = new Map<String,Object>();
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
     * Retrieves upcoming interviews list filtered by manager
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange Not used for this metric
     * @return List<Map<String,Object>> interview records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getUpcomingInterviewsList(String managerName, String dateRange) {
        List<Map<String,Object>> interviewList = new List<Map<String,Object>>();
        
        try {
            String query = 'SELECT Id, Name, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Date_Time_Scheduled__c, Interview_Type__c, Interview_Status__c, Interviewer_s__c ' +
                          'FROM Interview__c ' +
                          'WHERE Date_Time_Scheduled__c >= TODAY AND Interview_Status__c = \'Scheduled\' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Candidate__r.Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY Date_Time_Scheduled__c ASC LIMIT 500';
            
            List<Interview__c> interviews = Database.query(query);
            
            for (Interview__c interview : interviews) {
                Map<String,Object> interviewMap = new Map<String,Object>();
                interviewMap.put('id', interview.Id);
                interviewMap.put('name', interview.Name);
                interviewMap.put('candidateName', interview.Candidate__r.Name);
                interviewMap.put('interviewDate', interview.Date_Time_Scheduled__c);
                interviewMap.put('interviewType', interview.Interview_Type__c);
                interviewMap.put('status', interview.Interview_Status__c);
                interviewMap.put('interviewer', interview.Interviewer_s__c);
                interviewMap.put('salesManagerName', interview.Candidate__r.Sales_Manager__c);
                interviewMap.put('recordUrl', '/' + interview.Id);
                interviewList.add(interviewMap);
            }
        } catch (Exception e) {
            System.debug('Error in getUpcomingInterviewsList: ' + e.getMessage());
        }
        
        return interviewList;
    }
    
    /**
     * Retrieves active pipeline candidates filtered by manager
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange Not used for this metric
     * @return List<Map<String,Object>> candidate records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getActivePipelineList(String managerName, String dateRange) {
        List<Map<String,Object>> candidateList = new List<Map<String,Object>>();
        
        try {
            String query = 'SELECT Id, Name, Status__c, Highest_Level_Achieved__c, ' +
                          'Email__c, Phone__c, Sales_Manager__c, LastModifiedDate ' +
                          'FROM Candidate__c ' +
                          'WHERE Status__c = \'Active/In Process\' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY LastModifiedDate DESC LIMIT 500';
            
            List<Candidate__c> candidates = Database.query(query);
            
            for (Candidate__c candidate : candidates) {
                Map<String,Object> candidateMap = new Map<String,Object>();
                candidateMap.put('id', candidate.Id);
                candidateMap.put('name', candidate.Name);
                candidateMap.put('status', candidate.Status__c);
                candidateMap.put('highestLevel', candidate.Highest_Level_Achieved__c);
                candidateMap.put('email', candidate.Email__c);
                candidateMap.put('phone', candidate.Phone__c);
                candidateMap.put('salesManagerName', candidate.Sales_Manager__c);
                candidateMap.put('recordUrl', '/' + candidate.Id);
                candidateList.add(candidateMap);
            }
        } catch (Exception e) {
            System.debug('Error in getActivePipelineList: ' + e.getMessage());
        }
        
        return candidateList;
    }
    
    /**
     * Retrieves Contract B list filtered by manager
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange Not used for this metric
     * @return List<Map<String,Object>> ALC records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getContractBList(String managerName, String dateRange) {
        List<Map<String,Object>> alcList = new List<Map<String,Object>>();
        
        try {
            String query = 'SELECT Id, Name, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Contract_Type__c, Stage__c, Contract_Effective__c ' +
                          'FROM ALC__c ' +
                          'WHERE Contract_Type__c = \'B\' AND Stage__c = \'Contracting Complete\' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Candidate__r.Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY Contract_Effective__c DESC LIMIT 500';
            
            List<ALC__c> alcs = Database.query(query);
            
            for (ALC__c alc : alcs) {
                Map<String,Object> alcMap = new Map<String,Object>();
                alcMap.put('id', alc.Id);
                alcMap.put('name', alc.Name);
                alcMap.put('candidateName', alc.Candidate__r.Name);
                alcMap.put('contractType', alc.Contract_Type__c);
                alcMap.put('stage', alc.Stage__c);
                alcMap.put('contractEffective', alc.Contract_Effective__c);
                alcMap.put('salesManagerName', alc.Candidate__r.Sales_Manager__c);
                alcMap.put('recordUrl', '/' + alc.Id);
                alcList.add(alcMap);
            }
        } catch (Exception e) {
            System.debug('Error in getContractBList: ' + e.getMessage());
        }
        
        return alcList;
    }
    
    /**
     * Retrieves Contract A list filtered by manager
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange Not used for this metric
     * @return List<Map<String,Object>> ALC records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getContractAList(String managerName, String dateRange) {
        List<Map<String,Object>> alcList = new List<Map<String,Object>>();
        
        try {
            String query = 'SELECT Id, Name, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Contract_Type__c, Stage__c, Contract_Effective__c ' +
                          'FROM ALC__c ' +
                          'WHERE Contract_Type__c = \'A\' AND Stage__c = \'Contracting Complete\' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Candidate__r.Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY Contract_Effective__c DESC LIMIT 500';
            
            List<ALC__c> alcs = Database.query(query);
            
            for (ALC__c alc : alcs) {
                Map<String,Object> alcMap = new Map<String,Object>();
                alcMap.put('id', alc.Id);
                alcMap.put('name', alc.Name);
                alcMap.put('candidateName', alc.Candidate__r.Name);
                alcMap.put('contractType', alc.Contract_Type__c);
                alcMap.put('stage', alc.Stage__c);
                alcMap.put('contractEffective', alc.Contract_Effective__c);
                alcMap.put('salesManagerName', alc.Candidate__r.Sales_Manager__c);
                alcMap.put('recordUrl', '/' + alc.Id);
                alcList.add(alcMap);
            }
        } catch (Exception e) {
            System.debug('Error in getContractAList: ' + e.getMessage());
        }
        
        return alcList;
    }
    
    /**
     * Retrieves hired candidates list with date range filter
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange 'This Month', 'This Quarter', or 'This Year'
     * @return List<Map<String,Object>> ALC records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getHiredList(String managerName, String dateRange) {
        List<Map<String,Object>> alcList = new List<Map<String,Object>>();
        
        try {
            String hireDateFilter = getDateRangeFilter(dateRange, 'Contract_Effective__c');
            
            String query = 'SELECT Id, Name, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Contract_Type__c, Stage__c, Contract_Effective__c ' +
                          'FROM ALC__c ' +
                          'WHERE Stage__c = \'Contracting Complete\' AND ' + hireDateFilter + ' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Candidate__r.Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY Contract_Effective__c DESC LIMIT 500';
            
            List<ALC__c> alcs = Database.query(query);
            
            for (ALC__c alc : alcs) {
                Map<String,Object> alcMap = new Map<String,Object>();
                alcMap.put('id', alc.Id);
                alcMap.put('name', alc.Name);
                alcMap.put('candidateName', alc.Candidate__r.Name);
                alcMap.put('contractType', alc.Contract_Type__c);
                alcMap.put('stage', alc.Stage__c);
                alcMap.put('contractEffective', alc.Contract_Effective__c);
                alcMap.put('salesManagerName', alc.Candidate__r.Sales_Manager__c);
                alcMap.put('recordUrl', '/' + alc.Id);
                alcList.add(alcMap);
            }
        } catch (Exception e) {
            System.debug('Error in getHiredList: ' + e.getMessage());
        }
        
        return alcList;
    }
    
    /**
     * Retrieves completed interviews list with date range filter
     * 
     * @param managerName Sales manager name or 'All Sales Managers'
     * @param dateRange 'This Month', 'This Quarter', or 'This Year'
     * @return List<Map<String,Object>> interview records
     */
    @AuraEnabled(cacheable=false)
    public static List<Map<String,Object>> getCompletedInterviewsList(String managerName, String dateRange) {
        List<Map<String,Object>> interviewList = new List<Map<String,Object>>();
        
        try {
            String interviewDateFilter = getDateRangeFilter(dateRange, 'Date_Completed__c');
            
            String query = 'SELECT Id, Name, Candidate__c, Candidate__r.Name, Candidate__r.Sales_Manager__c, ' +
                          'Date_Time_Scheduled__c, Interview_Type__c, Interview_Status__c, Date_Completed__c, Interviewer_s__c ' +
                          'FROM Interview__c ' +
                          'WHERE Interview_Status__c = \'Completed\' AND ' + interviewDateFilter + ' ';
            
            if (managerName != 'All Sales Managers' && String.isNotBlank(managerName)) {
                query += 'AND Candidate__r.Sales_Manager__c = :managerName ';
            }
            
            query += 'ORDER BY Date_Completed__c DESC LIMIT 500';
            
            List<Interview__c> interviews = Database.query(query);
            
            for (Interview__c interview : interviews) {
                Map<String,Object> interviewMap = new Map<String,Object>();
                interviewMap.put('id', interview.Id);
                interviewMap.put('name', interview.Name);
                interviewMap.put('candidateName', interview.Candidate__r.Name);
                interviewMap.put('interviewDate', interview.Date_Time_Scheduled__c);
                interviewMap.put('interviewType', interview.Interview_Type__c);
                interviewMap.put('interviewStatus', interview.Interview_Status__c);
                interviewMap.put('dateCompleted', interview.Date_Completed__c);
                interviewMap.put('interviewer', interview.Interviewer_s__c);
                interviewMap.put('salesManagerName', interview.Candidate__r.Sales_Manager__c);
                interviewMap.put('recordUrl', '/' + interview.Id);
                interviewList.add(interviewMap);
            }
        } catch (Exception e) {
            System.debug('Error in getCompletedInterviewsList: ' + e.getMessage());
        }
        
        return interviewList;
    }
    
    /**
     * Exports drill-down data to CSV format
     * 
     * @param data List of records from drill-down method
     * @param metricType Type of metric for column headers
     * @return String CSV formatted data
     */
    @AuraEnabled(cacheable=false)
    public static String exportToCsv(List<Map<String,Object>> data, String metricType) {
        String csv = '';
        
        try {
            if (data == null || data.isEmpty()) {
                return 'No data available';
            }
            
            // Build headers based on metric type
            if (metricType == 'totalCandidates' || metricType == 'activePipeline') {
                csv = 'Name,Sales Manager,Status,Email,Phone,Highest Level,Office Location\n';
                
                for (Map<String,Object> record : data) {
                    csv += escapeCsvValue((String)record.get('name')) + ',';
                    csv += escapeCsvValue((String)record.get('salesManagerName')) + ',';
                    csv += escapeCsvValue((String)record.get('status')) + ',';
                    csv += escapeCsvValue((String)record.get('email')) + ',';
                    csv += escapeCsvValue((String)record.get('phone')) + ',';
                    csv += escapeCsvValue((String)record.get('highestLevel')) + ',';
                    csv += escapeCsvValue((String)record.get('officeLocation')) + '\n';
                }
            } else if (metricType == 'upcomingInterviews' || metricType == 'completedInterviews') {
                csv = 'Interview Name,Candidate Name,Sales Manager,Interview Date,Type,Status,Interviewer\n';
                
                for (Map<String,Object> record : data) {
                    csv += escapeCsvValue((String)record.get('name')) + ',';
                    csv += escapeCsvValue((String)record.get('candidateName')) + ',';
                    csv += escapeCsvValue((String)record.get('salesManagerName')) + ',';
                    csv += formatDate((Datetime)record.get('interviewDate')) + ',';
                    csv += escapeCsvValue((String)record.get('interviewType')) + ',';
                    csv += escapeCsvValue((String)record.get('status')) + ',';
                    csv += escapeCsvValue((String)record.get('interviewer')) + '\n';
                }
            } else if (metricType == 'contractB' || metricType == 'contractA' || metricType == 'hired') {
                csv = 'ALC Name,Candidate Name,Sales Manager,Contract Type,Stage,Contract Effective Date\n';
                
                for (Map<String,Object> record : data) {
                    csv += escapeCsvValue((String)record.get('name')) + ',';
                    csv += escapeCsvValue((String)record.get('candidateName')) + ',';
                    csv += escapeCsvValue((String)record.get('salesManagerName')) + ',';
                    csv += escapeCsvValue((String)record.get('contractType')) + ',';
                    csv += escapeCsvValue((String)record.get('stage')) + ',';
                    csv += formatDate((Date)record.get('contractEffective')) + '\n';
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in exportToCsv: ' + e.getMessage());
            csv = 'Error generating CSV: ' + e.getMessage();
        }
        
        return csv;
    }
    
    /**
     * Helper method to escape CSV values
     */
    private static String escapeCsvValue(String value) {
        if (String.isBlank(value)) {
            return '';
        }
        // Escape quotes and wrap in quotes if contains comma
        if (value.contains(',') || value.contains('"') || value.contains('\n')) {
            return '"' + value.replace('"', '""') + '"';
        }
        return value;
    }
    
    /**
     * Helper method to format dates for CSV
     */
    private static String formatDate(Object dateValue) {
        if (dateValue == null) {
            return '';
        }
        if (dateValue instanceof Date) {
            return String.valueOf((Date)dateValue);
        } else if (dateValue instanceof Datetime) {
            return String.valueOf((Datetime)dateValue);
        }
        return String.valueOf(dateValue);
    }
}
