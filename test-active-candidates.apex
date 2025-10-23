// Test the getActiveCandidates method
List<Map<String, Object>> result = RecruiterDashboardController.getActiveCandidates();
System.debug('Active candidates result: ' + result);
System.debug('Number of active candidates found: ' + result.size());

for(Map<String, Object> candidate : result) {
    System.debug('Candidate: ' + candidate.get('Name') + ' - ' + candidate.get('Email') + ' - Status: ' + candidate.get('Status'));
}