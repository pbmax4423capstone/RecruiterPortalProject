// Execute batch job to fix all candidate names

Database.executeBatch(new BatchFixCandidateNames(), 200);
System.debug('Batch job started to fix candidate names');
