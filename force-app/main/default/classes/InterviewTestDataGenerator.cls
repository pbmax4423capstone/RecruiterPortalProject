public class InterviewTestDataGenerator {
    
    public static void generateInterviewFlowData() {
        // Delete existing Interview records to start fresh
        delete [SELECT Id FROM Interview__c];
        
        // Get existing candidates to link interviews to
        List<Candidate__c> candidates = [SELECT Id, Name, Sales_Manager__c FROM Candidate__c LIMIT 50];
        if (candidates.isEmpty()) {
            System.debug('No candidates found. Please create candidate data first.');
            return;
        }
        
        List<Interview__c> interviewsToInsert = new List<Interview__c>();
        Map<Id, List<Interview__c>> candidateInterviewMap = new Map<Id, List<Interview__c>>();
        
        // Get Users to use as interviewers
        List<User> interviewers = [SELECT Id, Name FROM User WHERE IsActive = true LIMIT 10];
        if (interviewers.isEmpty()) {
            System.debug('No active users found. Using system admin.');
            interviewers.add([SELECT Id, Name FROM User WHERE Id = :UserInfo.getUserId()]);
        }
        
        Integer candidateIndex = 0;
        
        // Phase 1: Create 20 Attraction Interviews (all candidates start here)
        System.debug('Creating 20 Attraction interviews...');
        for (Integer i = 0; i < 20; i++) {
            if (candidateIndex >= candidates.size()) candidateIndex = 0;
            
            Interview__c attraction = new Interview__c();
            attraction.Name = 'Attraction Interview - ' + candidates[candidateIndex].Name;
            attraction.Candidate__c = candidates[candidateIndex].Id;
            attraction.Interview_Type__c = 'Attraction';
            attraction.Conducted_By__c = interviewers[Math.mod(i, interviewers.size())].Id;
            attraction.Date_Time_Scheduled__c = System.now().addDays(-60 + i);
            
            // First 14 proceed to SI1, last 6 get Hold/Decline
            if (i < 14) {
                attraction.Outcome__c = 'Proceed';
            } else {
                attraction.Outcome__c = (Math.mod(i, 2) == 0) ? 'Hold' : 'Decline';
            }
            
            interviewsToInsert.add(attraction);
            
            // Track interviews by candidate
            if (!candidateInterviewMap.containsKey(candidates[candidateIndex].Id)) {
                candidateInterviewMap.put(candidates[candidateIndex].Id, new List<Interview__c>());
            }
            candidateInterviewMap.get(candidates[candidateIndex].Id).add(attraction);
            
            candidateIndex++;
        }
        
        // Insert Attraction interviews first
        insert interviewsToInsert;
        System.debug('Inserted ' + interviewsToInsert.size() + ' Attraction interviews');
        
        // Phase 2: Create 14 SI1 Interviews (from Attraction Proceeds)
        List<Interview__c> si1Interviews = new List<Interview__c>();
        System.debug('Creating 14 SI1 interviews...');
        
        Integer si1Count = 0;
        for (Interview__c attraction : interviewsToInsert) {
            if (attraction.Outcome__c == 'Proceed' && si1Count < 14) {
                Interview__c si1 = new Interview__c();
                si1.Name = 'SI1 Interview - ' + attraction.Name.replace('Attraction', 'SI1');
                si1.Candidate__c = attraction.Candidate__c;
                si1.Interview_Type__c = 'SI1';
                si1.Conducted_By__c = interviewers[Math.mod(si1Count, interviewers.size())].Id;
                si1.Date_Time_Scheduled__c = System.now().addDays(-45 + si1Count);
                
                // 8 proceed to SI2, 6 get Hold/Decline  
                if (si1Count < 8) {
                    si1.Outcome__c = 'Proceed';
                } else {
                    si1.Outcome__c = (Math.mod(si1Count, 2) == 0) ? 'Hold' : 'Decline';
                }
                
                si1Interviews.add(si1);
                candidateInterviewMap.get(attraction.Candidate__c).add(si1);
                si1Count++;
            }
        }
        
        insert si1Interviews;
        System.debug('Inserted ' + si1Interviews.size() + ' SI1 interviews');
        
        // Phase 3: Create SI2 Interviews (from SI1 Proceeds) - Need to update picklist first
        List<Interview__c> si2Interviews = new List<Interview__c>();
        System.debug('Creating SI2 interviews from SI1 proceeds...');
        
        Integer si2Count = 0;
        for (Interview__c si1 : si1Interviews) {
            if (si1.Outcome__c == 'Proceed') {
                Interview__c si2 = new Interview__c();
                si2.Name = 'SI2 Interview - ' + si1.Name.substringAfter(' - ');
                si2.Candidate__c = si1.Candidate__c;
                si2.Interview_Type__c = 'SI2';
                si2.Conducted_By__c = interviewers[Math.mod(si2Count, interviewers.size())].Id;
                si2.Date_Time_Scheduled__c = System.now().addDays(-30 + si2Count);
                
                // For now, use existing outcomes until we update the picklist
                if (si2Count < 3) {
                    si2.Outcome__c = 'Proceed'; // These will become "Proceed to SI3"
                } else {
                    si2.Outcome__c = 'Proceed'; // These will become "Proceed to Career" 
                }
                
                si2Interviews.add(si2);
                candidateInterviewMap.get(si1.Candidate__c).add(si2);
                si2Count++;
            }
        }
        
        insert si2Interviews;
        System.debug('Inserted ' + si2Interviews.size() + ' SI2 interviews');
        
        // Phase 4: Create 6 SI3 Interviews (from some SI2 proceeds)
        List<Interview__c> si3Interviews = new List<Interview__c>();
        System.debug('Creating 6 SI3 interviews...');
        
        Integer si3Count = 0;
        for (Interview__c si2 : si2Interviews) {
            if (si2.Outcome__c == 'Proceed' && si3Count < 6) {
                Interview__c si3 = new Interview__c();
                si3.Name = 'SI3 Interview - ' + si2.Name.substringAfter(' - ');
                si3.Candidate__c = si2.Candidate__c;
                si3.Interview_Type__c = 'SI3';
                si3.Conducted_By__c = interviewers[Math.mod(si3Count, interviewers.size())].Id;
                si3.Date_Time_Scheduled__c = System.now().addDays(-15 + si3Count);
                
                // All SI3 proceed to Career
                si3.Outcome__c = 'Proceed';
                
                si3Interviews.add(si3);
                candidateInterviewMap.get(si2.Candidate__c).add(si3);
                si3Count++;
            }
        }
        
        insert si3Interviews;
        System.debug('Inserted ' + si3Interviews.size() + ' SI3 interviews');
        
        // Phase 5: Create 10 Career Interviews (from SI2 and SI3 proceeds)
        List<Interview__c> careerInterviews = new List<Interview__c>();
        System.debug('Creating 10 Career interviews...');
        
        Integer careerCount = 0;
        
        // Career from SI3 proceeds (should be 6)
        for (Interview__c si3 : si3Interviews) {
            if (si3.Outcome__c == 'Proceed' && careerCount < 10) {
                Interview__c career = new Interview__c();
                career.Name = 'Career Interview - ' + si3.Name.substringAfter(' - ');
                career.Candidate__c = si3.Candidate__c;
                career.Interview_Type__c = 'Career';
                career.Conducted_By__c = interviewers[Math.mod(careerCount, interviewers.size())].Id;
                career.Outcome__c = 'Proceed';
                career.Date_Time_Scheduled__c = System.now().addDays(-5 + careerCount);
                
                careerInterviews.add(career);
                careerCount++;
            }
        }
        
        // Career from SI2 proceeds that didn't go to SI3 (should be 4 more to reach 10 total)
        for (Interview__c si2 : si2Interviews) {
            if (si2.Outcome__c == 'Proceed' && careerCount < 10) {
                // Check if this candidate already has an SI3
                Boolean hasS3 = false;
                for (Interview__c si3 : si3Interviews) {
                    if (si3.Candidate__c == si2.Candidate__c) {
                        hasS3 = true;
                        break;
                    }
                }
                
                if (!hasS3) {
                    Interview__c career = new Interview__c();
                    career.Name = 'Career Interview - ' + si2.Name.substringAfter(' - ');
                    career.Candidate__c = si2.Candidate__c;
                    career.Interview_Type__c = 'Career';
                    career.Conducted_By__c = interviewers[Math.mod(careerCount, interviewers.size())].Id;
                    career.Outcome__c = 'Proceed';
                    career.Date_Time_Scheduled__c = System.now().addDays(-3 + careerCount);
                    
                    careerInterviews.add(career);
                    careerCount++;
                }
            }
        }
        
        insert careerInterviews;
        System.debug('Inserted ' + careerInterviews.size() + ' Career interviews');
        
        // Summary
        System.debug('=== INTERVIEW FLOW DATA GENERATION COMPLETE ===');
        System.debug('Total interviews created: ' + (20 + 14 + si2Interviews.size() + 6 + 10));
        System.debug('- Attraction: 20 (14 proceed, 6 hold/decline)');
        System.debug('- SI1: 14 (8 proceed, 6 hold/decline)');
        System.debug('- SI2: ' + si2Interviews.size() + ' (all proceed for now)');
        System.debug('- SI3: 6 (all proceed)');
        System.debug('- Career: 10 (all proceed)');
        
        System.debug('NOTE: Update SI2 Outcome picklist values and re-run updateSI2Outcomes() method');
    }
    
    // Method to update SI2 outcomes after picklist is updated
    public static void updateSI2Outcomes() {
        List<Interview__c> si2Interviews = [SELECT Id, Name, Candidate__c FROM Interview__c WHERE Interview_Type__c = 'SI2'];
        List<Interview__c> si3Interviews = [SELECT Id, Candidate__c FROM Interview__c WHERE Interview_Type__c = 'SI3'];
        
        Set<Id> candidatesWithSI3 = new Set<Id>();
        for (Interview__c si3 : si3Interviews) {
            candidatesWithSI3.add(si3.Candidate__c);
        }
        
        for (Interview__c si2 : si2Interviews) {
            if (candidatesWithSI3.contains(si2.Candidate__c)) {
                si2.Outcome__c = 'Proceed to SI3';
            } else {
                si2.Outcome__c = 'Proceed to Career';
            }
        }
        
        update si2Interviews;
        System.debug('Updated ' + si2Interviews.size() + ' SI2 interview outcomes');
    }
}