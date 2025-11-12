/**
 * Execute the Candidate -> Event interview migration.
 * - Performs DML upsert using Event.External_Id__c for idempotency.
 * - Prints a summary with counts and first 50 warnings/errors.
 *
 * Optionally scope to a subset of Candidate Ids by populating candidateIds below.
 */
Set<Id> candidateIds = new Set<Id>();
// Example: candidateIds.add('a051x00000ABCDEFG'); // leave empty to process all

Time defaultStart = Time.newInstance(9, 0, 0, 0);
Integer durationMins = 60;

CandidateToEventInterviewMigration.Result r =
    CandidateToEventInterviewMigration.migrate(candidateIds, false, defaultStart, durationMins);

System.debug('MIGRATION RUN RESULT: ' + r.toString());
Integer show = 0;
for (String w : r.warnings) {
    if (show++ >= 50) { System.debug('... more warnings not shown'); break; }
    System.debug('WARN: ' + w);
}
show = 0;
for (String e : r.errors) {
    if (show++ >= 50) { System.debug('... more errors not shown'); break; }
    System.debug('ERROR: ' + e);
}
