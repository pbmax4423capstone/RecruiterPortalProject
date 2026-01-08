String candidateId = 'a02Vo00000oJ7dhIAC';
String nextType = InterviewSequenceHelper.getNextInterviewType(candidateId);
System.debug('Next suggested interview type: ' + nextType);
InterviewSequenceHelper.InterviewSummary summary = InterviewSequenceHelper.getCandidateInterviewSummary(candidateId);
System.debug('Interview summary: ' + summary.summaryText);
System.debug('Total completed: ' + summary.totalCompleted);
