List<Task> tasksToInsert = new List<Task>();

tasksToInsert.add(new Task(Subject='Call', WhatId='a025f00000MQViHAAX', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f00000Qlis1AAB', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000RhMqYIAV', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000ZV4HyIAL', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000ZV4HyIAL', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f00000MQViHAAX', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f000006PkppAAC', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000fKTj9IAG', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f000006PnSyAAK', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000MIUPjIAP', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000ZVxMhIAL', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f000006PiuUAAS', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000Y11XyIAJ', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000DUh6vIAD', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a025f000006PpOzAAK', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000feExXIAU', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000dUBAsIAO', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000amQVDIA2', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));
tasksToInsert.add(new Task(Subject='Call', WhatId='a02Vo00000gGpL7IAK', ActivityDate=Date.valueOf('2025-11-25'), Status='Not Started', Priority='Normal', OwnerId='0055f00000DqpnpAAB', TaskSubtype='Call', Type='Call'));

insert tasksToInsert;
System.debug('Created ' + tasksToInsert.size() + ' scheduled call tasks for today');