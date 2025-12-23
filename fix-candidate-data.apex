// Fix Candidate Data - Update Status and Highest_Level_Achieved based on completed interviews

// Map Interview_Type__c values to Highest_Level_Achieved__c values
// Interview types: Ci-First, Align-2nd, Plan-3rd, Present-4th, Optional-5th
// HLA values: 0-Prequal, Ci_1st, Align (2nd), Plan_3rd, Present-4th, Optional_5th, 6-Offer Acc
Map<String, String> interviewTypeToHLA = new Map<String, String>{
    'Ci-First' => 'Ci_1st',
    'Align-2nd' => 'Align (2nd)',
    'Plan-3rd' => 'Plan_3rd',
    'Present-4th' => 'Present-4th',
    'Optional-5th' => 'Optional_5th'
};

// Define order of stages (higher index = more advanced)
Map<String, Integer> stageOrder = new Map<String, Integer>{
    '0-Prequal' => 0,
    'Ci_1st' => 1,
    'Align (2nd)' => 2,
    'Plan_3rd' => 3,
    'Present-4th' => 4,
    'Optional_5th' => 5,
    '6-Offer Acc' => 6,
    '7-Contracted' => 7
};

// Get all candidates
List<Candidate__c> candidates = [SELECT Id, Name, Status__c, Highest_Level_Achieved__c FROM Candidate__c];

// Get all completed interviews grouped by candidate
Map<Id, List<Interview__c>> interviewsByCandidate = new Map<Id, List<Interview__c>>();
for (Interview__c i : [SELECT Id, Candidate__c, Interview_Type__c, Interview_Status__c 
                        FROM Interview__c 
                        WHERE Interview_Status__c = 'Completed'
                        ORDER BY Candidate__c]) {
    if (!interviewsByCandidate.containsKey(i.Candidate__c)) {
        interviewsByCandidate.put(i.Candidate__c, new List<Interview__c>());
    }
    interviewsByCandidate.get(i.Candidate__c).add(i);
}

List<Candidate__c> toUpdate = new List<Candidate__c>();

for (Candidate__c c : candidates) {
    Boolean needsUpdate = false;
    
    // Fix Status__c if not already 'Active/In Process'
    if (c.Status__c != 'Active/In Process') {
        c.Status__c = 'Active/In Process';
        needsUpdate = true;
        System.debug('Updating Status for ' + c.Name + ': ' + c.Status__c + ' -> Active/In Process');
    }
    
    // Find highest completed interview for this candidate
    String highestHLA = '0-Prequal';
    Integer highestOrder = 0;
    
    if (interviewsByCandidate.containsKey(c.Id)) {
        for (Interview__c interview : interviewsByCandidate.get(c.Id)) {
            String hlaValue = interviewTypeToHLA.get(interview.Interview_Type__c);
            if (hlaValue != null) {
                Integer order = stageOrder.get(hlaValue);
                if (order != null && order > highestOrder) {
                    highestOrder = order;
                    highestHLA = hlaValue;
                }
            }
        }
    }
    
    // Update Highest_Level_Achieved__c if different
    if (c.Highest_Level_Achieved__c != highestHLA) {
        System.debug('Updating HLA for ' + c.Name + ': ' + c.Highest_Level_Achieved__c + ' -> ' + highestHLA);
        c.Highest_Level_Achieved__c = highestHLA;
        needsUpdate = true;
    }
    
    if (needsUpdate) {
        toUpdate.add(c);
    }
}

if (!toUpdate.isEmpty()) {
    update toUpdate;
    System.debug('Updated ' + toUpdate.size() + ' candidates');
}

// Verification
System.debug('');
System.debug('=== VERIFICATION ===');
System.debug('Candidates by Highest Level Achieved:');
for (AggregateResult ar : [SELECT Highest_Level_Achieved__c hla, COUNT(Id) cnt 
                            FROM Candidate__c 
                            GROUP BY Highest_Level_Achieved__c 
                            ORDER BY Highest_Level_Achieved__c]) {
    System.debug(ar.get('hla') + ': ' + ar.get('cnt'));
}

System.debug('');
System.debug('Candidates by Status:');
for (AggregateResult ar : [SELECT Status__c status, COUNT(Id) cnt 
                            FROM Candidate__c 
                            GROUP BY Status__c]) {
    System.debug(ar.get('status') + ': ' + ar.get('cnt'));
}
