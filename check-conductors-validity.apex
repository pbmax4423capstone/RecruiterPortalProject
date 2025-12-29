// Check all conductors in proposed migration records
// Valid conductors: Tim Denton, Bradley Sofonia, Elizabeth Kagele, Michael Yang, Rachyll Tenny, Scott Grove, Son Le, Van Hess

Set<String> validConductors = new Set<String>{
    'Tim Denton', 'Bradley Sofonia', 'Elizabeth Kagele', 'Michael Yang', 
    'Rachyll Tenny', 'Scott Grove', 'Son Le', 'Van Hess'
};

System.debug('=== CHECKING CONDUCTOR VALIDITY ===\n');

// 1. AI Conductors
System.debug('--- AI (Attraction) Conductors ---');
List<AggregateResult> aiConductors = [
    SELECT AI_Conducted_By__c conductor, COUNT(Id) cnt
    FROM Candidate__c
    WHERE Attraction_Interview_Date_Completed__c != null
    GROUP BY AI_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];
Integer aiValid = 0;
Integer aiInvalid = 0;
for (AggregateResult ar : aiConductors) {
    String conductor = (String)ar.get('conductor');
    Integer count = (Integer)ar.get('cnt');
    Boolean isValid = validConductors.contains(conductor);
    if (isValid) {
        aiValid += count;
    } else {
        aiInvalid += count;
        System.debug('INVALID: ' + conductor + ' (' + count + ' interviews)');
    }
}
System.debug('Valid AI interviews: ' + aiValid);
System.debug('Invalid AI interviews: ' + aiInvalid + '\n');

// 2. SI1 Conductors
System.debug('--- SI1 Conductors ---');
List<AggregateResult> si1Conductors = [
    SELECT SI_1_Conducted_By__c conductor, COUNT(Id) cnt
    FROM Candidate__c
    WHERE SI_1_Date_Completed__c != null
    GROUP BY SI_1_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];
Integer si1Valid = 0;
Integer si1Invalid = 0;
for (AggregateResult ar : si1Conductors) {
    String conductor = (String)ar.get('conductor');
    Integer count = (Integer)ar.get('cnt');
    Boolean isValid = validConductors.contains(conductor);
    if (isValid) {
        si1Valid += count;
    } else {
        si1Invalid += count;
        System.debug('INVALID: ' + conductor + ' (' + count + ' interviews)');
    }
}
System.debug('Valid SI1 interviews: ' + si1Valid);
System.debug('Invalid SI1 interviews: ' + si1Invalid + '\n');

// 3. SI2 Conductors
System.debug('--- SI2 Conductors ---');
List<AggregateResult> si2Conductors = [
    SELECT SI_2_Conducted_By__c conductor, COUNT(Id) cnt
    FROM Candidate__c
    WHERE SI_2_Date_Completed__c != null
    GROUP BY SI_2_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];
Integer si2Valid = 0;
Integer si2Invalid = 0;
for (AggregateResult ar : si2Conductors) {
    String conductor = (String)ar.get('conductor');
    Integer count = (Integer)ar.get('cnt');
    Boolean isValid = validConductors.contains(conductor);
    if (isValid) {
        si2Valid += count;
    } else {
        si2Invalid += count;
        System.debug('INVALID: ' + conductor + ' (' + count + ' interviews)');
    }
}
System.debug('Valid SI2 interviews: ' + si2Valid);
System.debug('Invalid SI2 interviews: ' + si2Invalid + '\n');

// 4. SI3 Conductors (should only be Brad/Tim)
System.debug('--- SI3 Conductors (Brad/Tim only) ---');
List<AggregateResult> si3Conductors = [
    SELECT SI_3_Conducted_By__c conductor, COUNT(Id) cnt
    FROM Candidate__c
    WHERE SI_3_Completed__c != null
    AND (SI_3_Conducted_By__c = 'Brad Sofonia' 
         OR SI_3_Conducted_By__c = 'Tim Denton' 
         OR SI_3_Conducted_By__c = 'Bradley Sofonia')
    GROUP BY SI_3_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];
for (AggregateResult ar : si3Conductors) {
    String conductor = (String)ar.get('conductor');
    Integer count = (Integer)ar.get('cnt');
    System.debug(conductor + ': ' + count + ' interviews');
}
System.debug('All SI3 are Brad/Tim by filter\n');

// 5. Career Conductors
System.debug('--- Career Presentation Conductors ---');
List<AggregateResult> cpConductors = [
    SELECT CP_Conducted_By__c conductor, COUNT(Id) cnt
    FROM Candidate__c
    WHERE Career_Presentation_Date_Completed__c != null
    GROUP BY CP_Conducted_By__c
    ORDER BY COUNT(Id) DESC
];
Integer cpValid = 0;
Integer cpInvalid = 0;
for (AggregateResult ar : cpConductors) {
    String conductor = (String)ar.get('conductor');
    Integer count = (Integer)ar.get('cnt');
    Boolean isValid = validConductors.contains(conductor);
    if (isValid) {
        cpValid += count;
    } else {
        cpInvalid += count;
        System.debug('INVALID: ' + conductor + ' (' + count + ' interviews)');
    }
}
System.debug('Valid Career interviews: ' + cpValid);
System.debug('Invalid Career interviews: ' + cpInvalid + '\n');

System.debug('=== SUMMARY ===');
System.debug('AI: ' + aiValid + ' valid, ' + aiInvalid + ' invalid (will fail)');
System.debug('SI1: ' + si1Valid + ' valid, ' + si1Invalid + ' invalid (will fail)');
System.debug('SI2: ' + si2Valid + ' valid, ' + si2Invalid + ' invalid (will fail)');
System.debug('SI3: 22 all valid (Brad/Tim only)');
System.debug('Career: ' + cpValid + ' valid, ' + cpInvalid + ' invalid (will fail)');
System.debug('\nTOTAL VALID: ' + (aiValid + si1Valid + si2Valid + 22 + cpValid));
System.debug('TOTAL INVALID: ' + (aiInvalid + si1Invalid + si2Invalid + cpInvalid));
