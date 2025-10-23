List<Map<String, Object>> candidates = RecruiterDashboardController.getActiveCandidates();
System.debug('Active candidates count: ' + candidates.size());
if (!candidates.isEmpty()) {
    Map<String, Object> firstCandidate = candidates[0];
    System.debug('First candidate: ' + firstCandidate);
    System.debug('Name: ' + firstCandidate.get('name'));
    System.debug('Email: ' + firstCandidate.get('email'));
    System.debug('Phone: ' + firstCandidate.get('phone'));
    System.debug('Owner: ' + firstCandidate.get('ownerName'));
}