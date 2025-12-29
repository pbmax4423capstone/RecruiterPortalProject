// Launch batch deletion of migrated events
DeleteMigratedEventsBatch batch = new DeleteMigratedEventsBatch();
Id jobId = Database.executeBatch(batch, 2000); // 2000 events per batch
System.debug('Started batch deletion job: ' + jobId);
