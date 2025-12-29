// Abort the currently running migration batch
String jobId = '707Vo00001Yf927IAB';

System.Abortjob(jobId);
System.debug('Aborted job: ' + jobId);
