Schema.DescribeFieldResult dfr = Candidate__c.Agency__c.getDescribe();
System.debug('=== AGENCY PICKLIST VALUES ===');
for (Schema.PicklistEntry pe : dfr.getPicklistValues()) { 
    System.debug(pe.getValue()); 
}

Schema.DescribeFieldResult dfr2 = Candidate__c.Status__c.getDescribe();
System.debug('');
System.debug('=== STATUS PICKLIST VALUES ===');
for (Schema.PicklistEntry pe : dfr2.getPicklistValues()) { 
    System.debug(pe.getValue()); 
}

Schema.DescribeFieldResult dfr3 = Candidate__c.Contract_Type__c.getDescribe();
System.debug('');
System.debug('=== CANDIDATE CONTRACT_TYPE PICKLIST VALUES ===');
for (Schema.PicklistEntry pe : dfr3.getPicklistValues()) { 
    System.debug(pe.getValue()); 
}

Schema.DescribeFieldResult dfr4 = ALC__c.Contract_Type__c.getDescribe();
System.debug('');
System.debug('=== ALC CONTRACT_TYPE PICKLIST VALUES ===');
for (Schema.PicklistEntry pe : dfr4.getPicklistValues()) { 
    System.debug(pe.getValue()); 
}

Schema.DescribeFieldResult dfr5 = ALC__c.Stage__c.getDescribe();
System.debug('');
System.debug('=== ALC STAGE PICKLIST VALUES ===');
for (Schema.PicklistEntry pe : dfr5.getPicklistValues()) { 
    System.debug(pe.getValue()); 
}