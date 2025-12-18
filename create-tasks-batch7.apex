List<Task> tasksToInsert = new List<Task>();

tasksToInsert.add(new Task(Subject='F>up', WhoId=null, ActivityDate=Date.valueOf('2025-11-19'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call'));
tasksToInsert.add(new Task(Subject='Call', WhoId='003Vo00000ktRKiIAM', ActivityDate=Date.valueOf('2025-11-23'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call'));

insert tasksToInsert;
System.debug('Created ' + tasksToInsert.size() + ' call tasks');