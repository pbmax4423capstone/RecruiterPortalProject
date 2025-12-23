// Create 30 random test Contacts and Candidates - Source: Referral
// Run this in the Recruiting Sandbox

List<Contact> contacts = new List<Contact>();
List<Map<String, String>> candidateData = new List<Map<String, String>>();

// Candidate 1
candidateData.add(new Map<String, String>{
    'FirstName' => 'Michael',
    'LastName' => 'Rodriguez',
    'MobilePhone' => '(714) 555-1234',
    'PersonalEmail' => 'mrodriguez85@gmail.com',
    'WorkPhone' => '(714) 555-4321',
    'WorkEmail' => 'michael.rodriguez@statefarmagency.com',
    'LinkedIn' => 'https://www.linkedin.com/in/michael-rodriguez-insurance',
    'JobTitle' => 'Insurance Sales Representative',
    'City' => 'Irvine',
    'State' => 'California',
    'Zip' => '92618',
    'College' => 'UC Irvine',
    'Degree' => 'Bachelor of Business Administration'
});

// Candidate 2
candidateData.add(new Map<String, String>{
    'FirstName' => 'Jennifer',
    'LastName' => 'Chen',
    'MobilePhone' => '(626) 555-2345',
    'PersonalEmail' => 'jchen.california@yahoo.com',
    'WorkPhone' => '(626) 555-5432',
    'WorkEmail' => 'jennifer.chen@allstate.com',
    'LinkedIn' => 'https://www.linkedin.com/in/jennifer-chen-ins',
    'JobTitle' => 'Senior Insurance Agent',
    'City' => 'Pasadena',
    'State' => 'California',
    'Zip' => '91101',
    'College' => 'UCLA',
    'Degree' => 'Bachelor of Arts, Economics'
});

// Candidate 3
candidateData.add(new Map<String, String>{
    'FirstName' => 'Robert',
    'LastName' => 'Martinez',
    'MobilePhone' => '(562) 555-3456',
    'PersonalEmail' => 'robmartinez77@hotmail.com',
    'WorkPhone' => '(562) 555-6543',
    'WorkEmail' => 'rmartinez@farmersagent.com',
    'LinkedIn' => 'https://www.linkedin.com/in/robert-martinez-ca',
    'JobTitle' => 'Property & Casualty Agent',
    'City' => 'Downey',
    'State' => 'California',
    'Zip' => '90241',
    'College' => 'Cal State Fullerton',
    'Degree' => 'Bachelor of Science, Finance'
});

// Candidate 4
candidateData.add(new Map<String, String>{
    'FirstName' => 'Amanda',
    'LastName' => 'Thompson',
    'MobilePhone' => '(949) 555-4567',
    'PersonalEmail' => 'amanda.t.thompson@gmail.com',
    'WorkPhone' => '(949) 555-7654',
    'WorkEmail' => 'athompson@libertymutual.com',
    'LinkedIn' => 'https://www.linkedin.com/in/amanda-thompson-oc',
    'JobTitle' => 'Life Insurance Specialist',
    'City' => 'Newport Beach',
    'State' => 'California',
    'Zip' => '92660',
    'College' => 'USC',
    'Degree' => 'Bachelor of Science, Business'
});

// Candidate 5
candidateData.add(new Map<String, String>{
    'FirstName' => 'David',
    'LastName' => 'Nguyen',
    'MobilePhone' => '(714) 555-5678',
    'PersonalEmail' => 'davidnguyen.oc@gmail.com',
    'WorkPhone' => '(714) 555-8765',
    'WorkEmail' => 'dnguyen@progressive.com',
    'LinkedIn' => 'https://www.linkedin.com/in/david-nguyen-broker',
    'JobTitle' => 'Commercial Lines Broker',
    'City' => 'Garden Grove',
    'State' => 'California',
    'Zip' => '92840',
    'College' => 'Cal State Long Beach',
    'Degree' => 'Bachelor of Arts, Business'
});

// Candidate 6
candidateData.add(new Map<String, String>{
    'FirstName' => 'Sarah',
    'LastName' => 'Williams',
    'MobilePhone' => '(858) 555-6789',
    'PersonalEmail' => 'sarahwilliams.sd@yahoo.com',
    'WorkPhone' => '(858) 555-9876',
    'WorkEmail' => 'swilliams@geico.com',
    'LinkedIn' => 'https://www.linkedin.com/in/sarah-williams-sd',
    'JobTitle' => 'Insurance Account Manager',
    'City' => 'San Diego',
    'State' => 'California',
    'Zip' => '92101',
    'College' => 'San Diego State',
    'Degree' => 'Bachelor of Science, Marketing'
});

// Candidate 7
candidateData.add(new Map<String, String>{
    'FirstName' => 'Christopher',
    'LastName' => 'Lee',
    'MobilePhone' => '(310) 555-7890',
    'PersonalEmail' => 'chrislee.la@gmail.com',
    'WorkPhone' => '(310) 555-0987',
    'WorkEmail' => 'clee@travelers.com',
    'LinkedIn' => 'https://www.linkedin.com/in/christopher-lee-ins',
    'JobTitle' => 'Insurance Underwriter',
    'City' => 'Torrance',
    'State' => 'California',
    'Zip' => '90501',
    'College' => 'Loyola Marymount',
    'Degree' => 'Bachelor of Business Administration'
});

// Candidate 8
candidateData.add(new Map<String, String>{
    'FirstName' => 'Michelle',
    'LastName' => 'Garcia',
    'MobilePhone' => '(818) 555-8901',
    'PersonalEmail' => 'mgarcia.sfv@hotmail.com',
    'WorkPhone' => '(818) 555-1098',
    'WorkEmail' => 'mgarcia@nationwide.com',
    'LinkedIn' => 'https://www.linkedin.com/in/michelle-garcia-agent',
    'JobTitle' => 'Personal Lines Agent',
    'City' => 'Glendale',
    'State' => 'California',
    'Zip' => '91201',
    'College' => 'Cal State Northridge',
    'Degree' => 'Bachelor of Arts, Communications'
});

// Candidate 9
candidateData.add(new Map<String, String>{
    'FirstName' => 'Jason',
    'LastName' => 'Brown',
    'MobilePhone' => '(909) 555-9012',
    'PersonalEmail' => 'jbrown.ie@gmail.com',
    'WorkPhone' => '(909) 555-2109',
    'WorkEmail' => 'jason.brown@aaa.com',
    'LinkedIn' => 'https://www.linkedin.com/in/jason-brown-ie',
    'JobTitle' => 'Auto Insurance Specialist',
    'City' => 'Ontario',
    'State' => 'California',
    'Zip' => '91761',
    'College' => 'UC Riverside',
    'Degree' => 'Bachelor of Arts, Business'
});

// Candidate 10
candidateData.add(new Map<String, String>{
    'FirstName' => 'Nicole',
    'LastName' => 'Davis',
    'MobilePhone' => '(951) 555-0123',
    'PersonalEmail' => 'nicoledavis.rv@yahoo.com',
    'WorkPhone' => '(951) 555-3210',
    'WorkEmail' => 'ndavis@hartford.com',
    'LinkedIn' => 'https://www.linkedin.com/in/nicole-davis-broker',
    'JobTitle' => 'Health Insurance Broker',
    'City' => 'Riverside',
    'State' => 'California',
    'Zip' => '92501',
    'College' => 'Cal Baptist University',
    'Degree' => 'Bachelor of Science, Healthcare Admin'
});

// Candidate 11
candidateData.add(new Map<String, String>{
    'FirstName' => 'Brian',
    'LastName' => 'Wilson',
    'MobilePhone' => '(619) 555-1122',
    'PersonalEmail' => 'brianwilson.sd@gmail.com',
    'WorkPhone' => '(619) 555-2211',
    'WorkEmail' => 'bwilson@chubb.com',
    'LinkedIn' => 'https://www.linkedin.com/in/brian-wilson-chubb',
    'JobTitle' => 'Commercial Insurance Producer',
    'City' => 'Chula Vista',
    'State' => 'California',
    'Zip' => '91910',
    'College' => 'Point Loma Nazarene',
    'Degree' => 'Bachelor of Business Administration'
});

// Candidate 12
candidateData.add(new Map<String, String>{
    'FirstName' => 'Stephanie',
    'LastName' => 'Miller',
    'MobilePhone' => '(760) 555-2233',
    'PersonalEmail' => 'smiller.palm@hotmail.com',
    'WorkPhone' => '(760) 555-3322',
    'WorkEmail' => 'stephanie.miller@metlife.com',
    'LinkedIn' => 'https://www.linkedin.com/in/stephanie-miller-ps',
    'JobTitle' => 'Financial Services Agent',
    'City' => 'Palm Springs',
    'State' => 'California',
    'Zip' => '92262',
    'College' => 'Cal State San Bernardino',
    'Degree' => 'Bachelor of Arts, Finance'
});

// Candidate 13
candidateData.add(new Map<String, String>{
    'FirstName' => 'Kevin',
    'LastName' => 'Anderson',
    'MobilePhone' => '(805) 555-3344',
    'PersonalEmail' => 'kanderson.vc@gmail.com',
    'WorkPhone' => '(805) 555-4433',
    'WorkEmail' => 'kanderson@prudential.com',
    'LinkedIn' => 'https://www.linkedin.com/in/kevin-anderson-vc',
    'JobTitle' => 'Life & Annuity Specialist',
    'City' => 'Ventura',
    'State' => 'California',
    'Zip' => '93001',
    'College' => 'CSU Channel Islands',
    'Degree' => 'Bachelor of Science, Business'
});

// Candidate 14
candidateData.add(new Map<String, String>{
    'FirstName' => 'Rachel',
    'LastName' => 'Taylor',
    'MobilePhone' => '(559) 555-4455',
    'PersonalEmail' => 'rtaylor.fresno@yahoo.com',
    'WorkPhone' => '(559) 555-5544',
    'WorkEmail' => 'rachel.taylor@amfam.com',
    'LinkedIn' => 'https://www.linkedin.com/in/rachel-taylor-fresno',
    'JobTitle' => 'Insurance Sales Manager',
    'City' => 'Fresno',
    'State' => 'California',
    'Zip' => '93721',
    'College' => 'Fresno State',
    'Degree' => 'Bachelor of Science, Management'
});

// Candidate 15
candidateData.add(new Map<String, String>{
    'FirstName' => 'Daniel',
    'LastName' => 'Jackson',
    'MobilePhone' => '(661) 555-5566',
    'PersonalEmail' => 'djackson.bako@gmail.com',
    'WorkPhone' => '(661) 555-6655',
    'WorkEmail' => 'daniel.jackson@safeco.com',
    'LinkedIn' => 'https://www.linkedin.com/in/daniel-jackson-bako',
    'JobTitle' => 'Insurance Producer',
    'City' => 'Bakersfield',
    'State' => 'California',
    'Zip' => '93301',
    'College' => 'Cal State Bakersfield',
    'Degree' => 'Bachelor of Arts, Business Admin'
});

// Candidate 16
candidateData.add(new Map<String, String>{
    'FirstName' => 'Laura',
    'LastName' => 'White',
    'MobilePhone' => '(408) 555-6677',
    'PersonalEmail' => 'laurawhite.sj@hotmail.com',
    'WorkPhone' => '(408) 555-7766',
    'WorkEmail' => 'lwhite@zurich.com',
    'LinkedIn' => 'https://www.linkedin.com/in/laura-white-sj',
    'JobTitle' => 'Commercial Risk Consultant',
    'City' => 'San Jose',
    'State' => 'California',
    'Zip' => '95112',
    'College' => 'San Jose State',
    'Degree' => 'Bachelor of Science, Risk Management'
});

// Candidate 17
candidateData.add(new Map<String, String>{
    'FirstName' => 'Andrew',
    'LastName' => 'Harris',
    'MobilePhone' => '(510) 555-7788',
    'PersonalEmail' => 'aharris.eb@gmail.com',
    'WorkPhone' => '(510) 555-8877',
    'WorkEmail' => 'andrew.harris@aig.com',
    'LinkedIn' => 'https://www.linkedin.com/in/andrew-harris-eb',
    'JobTitle' => 'Corporate Insurance Advisor',
    'City' => 'Oakland',
    'State' => 'California',
    'Zip' => '94612',
    'College' => 'UC Berkeley',
    'Degree' => 'Bachelor of Arts, Economics'
});

// Candidate 18
candidateData.add(new Map<String, String>{
    'FirstName' => 'Emily',
    'LastName' => 'Clark',
    'MobilePhone' => '(925) 555-8899',
    'PersonalEmail' => 'eclark.cc@yahoo.com',
    'WorkPhone' => '(925) 555-9988',
    'WorkEmail' => 'emily.clark@massmutual.com',
    'LinkedIn' => 'https://www.linkedin.com/in/emily-clark-cc',
    'JobTitle' => 'Financial Advisor',
    'City' => 'Walnut Creek',
    'State' => 'California',
    'Zip' => '94596',
    'College' => 'Saint Mary\'s College',
    'Degree' => 'Bachelor of Science, Finance'
});

// Candidate 19
candidateData.add(new Map<String, String>{
    'FirstName' => 'Mark',
    'LastName' => 'Robinson',
    'MobilePhone' => '(707) 555-9900',
    'PersonalEmail' => 'mrobinson.napa@gmail.com',
    'WorkPhone' => '(707) 555-0099',
    'WorkEmail' => 'mark.robinson@principal.com',
    'LinkedIn' => 'https://www.linkedin.com/in/mark-robinson-napa',
    'JobTitle' => 'Benefits Consultant',
    'City' => 'Napa',
    'State' => 'California',
    'Zip' => '94559',
    'College' => 'Sonoma State',
    'Degree' => 'Bachelor of Arts, Business'
});

// Candidate 20
candidateData.add(new Map<String, String>{
    'FirstName' => 'Jessica',
    'LastName' => 'Lewis',
    'MobilePhone' => '(831) 555-0011',
    'PersonalEmail' => 'jlewis.monterey@hotmail.com',
    'WorkPhone' => '(831) 555-1100',
    'WorkEmail' => 'jessica.lewis@lincoln.com',
    'LinkedIn' => 'https://www.linkedin.com/in/jessica-lewis-mb',
    'JobTitle' => 'Retirement Planning Specialist',
    'City' => 'Monterey',
    'State' => 'California',
    'Zip' => '93940',
    'College' => 'CSU Monterey Bay',
    'Degree' => 'Bachelor of Science, Business Admin'
});

// Candidate 21
candidateData.add(new Map<String, String>{
    'FirstName' => 'Ryan',
    'LastName' => 'Walker',
    'MobilePhone' => '(209) 555-1122',
    'PersonalEmail' => 'rwalker.stockton@gmail.com',
    'WorkPhone' => '(209) 555-2211',
    'WorkEmail' => 'ryan.walker@transamerica.com',
    'LinkedIn' => 'https://www.linkedin.com/in/ryan-walker-cv',
    'JobTitle' => 'Insurance Agent',
    'City' => 'Stockton',
    'State' => 'California',
    'Zip' => '95202',
    'College' => 'University of Pacific',
    'Degree' => 'Bachelor of Science, Business'
});

// Candidate 22
candidateData.add(new Map<String, String>{
    'FirstName' => 'Megan',
    'LastName' => 'Hall',
    'MobilePhone' => '(916) 555-2233',
    'PersonalEmail' => 'mhall.sac@yahoo.com',
    'WorkPhone' => '(916) 555-3322',
    'WorkEmail' => 'megan.hall@equitable.com',
    'LinkedIn' => 'https://www.linkedin.com/in/megan-hall-sac',
    'JobTitle' => 'Wealth Management Advisor',
    'City' => 'Sacramento',
    'State' => 'California',
    'Zip' => '95814',
    'College' => 'Sacramento State',
    'Degree' => 'Bachelor of Arts, Finance'
});

// Candidate 23
candidateData.add(new Map<String, String>{
    'FirstName' => 'Tyler',
    'LastName' => 'Young',
    'MobilePhone' => '(530) 555-3344',
    'PersonalEmail' => 'tyoung.chico@gmail.com',
    'WorkPhone' => '(530) 555-4433',
    'WorkEmail' => 'tyler.young@voya.com',
    'LinkedIn' => 'https://www.linkedin.com/in/tyler-young-norcal',
    'JobTitle' => 'Employee Benefits Specialist',
    'City' => 'Chico',
    'State' => 'California',
    'Zip' => '95928',
    'College' => 'Chico State',
    'Degree' => 'Bachelor of Science, Business Admin'
});

// Candidate 24
candidateData.add(new Map<String, String>{
    'FirstName' => 'Ashley',
    'LastName' => 'King',
    'MobilePhone' => '(323) 555-4455',
    'PersonalEmail' => 'aking.la@hotmail.com',
    'WorkPhone' => '(323) 555-5544',
    'WorkEmail' => 'ashley.king@northwestern.com',
    'LinkedIn' => 'https://www.linkedin.com/in/ashley-king-la',
    'JobTitle' => 'Financial Representative',
    'City' => 'Los Angeles',
    'State' => 'California',
    'Zip' => '90012',
    'College' => 'Pepperdine University',
    'Degree' => 'Bachelor of Science, Finance'
});

// Candidate 25
candidateData.add(new Map<String, String>{
    'FirstName' => 'Brandon',
    'LastName' => 'Wright',
    'MobilePhone' => '(213) 555-5566',
    'PersonalEmail' => 'bwright.dtla@gmail.com',
    'WorkPhone' => '(213) 555-6655',
    'WorkEmail' => 'brandon.wright@aflac.com',
    'LinkedIn' => 'https://www.linkedin.com/in/brandon-wright-dtla',
    'JobTitle' => 'Supplemental Insurance Agent',
    'City' => 'Los Angeles',
    'State' => 'California',
    'Zip' => '90017',
    'College' => 'Cal State LA',
    'Degree' => 'Bachelor of Arts, Marketing'
});

// Candidate 26
candidateData.add(new Map<String, String>{
    'FirstName' => 'Brittany',
    'LastName' => 'Lopez',
    'MobilePhone' => '(562) 555-6677',
    'PersonalEmail' => 'blopez.lb@yahoo.com',
    'WorkPhone' => '(562) 555-7766',
    'WorkEmail' => 'brittany.lopez@cigna.com',
    'LinkedIn' => 'https://www.linkedin.com/in/brittany-lopez-lb',
    'JobTitle' => 'Group Benefits Consultant',
    'City' => 'Long Beach',
    'State' => 'California',
    'Zip' => '90802',
    'College' => 'Cal State Long Beach',
    'Degree' => 'Bachelor of Science, Healthcare Admin'
});

// Candidate 27
candidateData.add(new Map<String, String>{
    'FirstName' => 'Justin',
    'LastName' => 'Hill',
    'MobilePhone' => '(714) 555-7788',
    'PersonalEmail' => 'jhill.oc@gmail.com',
    'WorkPhone' => '(714) 555-8877',
    'WorkEmail' => 'justin.hill@anthem.com',
    'LinkedIn' => 'https://www.linkedin.com/in/justin-hill-oc',
    'JobTitle' => 'Health Insurance Agent',
    'City' => 'Anaheim',
    'State' => 'California',
    'Zip' => '92801',
    'College' => 'Chapman University',
    'Degree' => 'Bachelor of Arts, Business'
});

// Candidate 28
candidateData.add(new Map<String, String>{
    'FirstName' => 'Samantha',
    'LastName' => 'Scott',
    'MobilePhone' => '(949) 555-8899',
    'PersonalEmail' => 'sscott.oc@hotmail.com',
    'WorkPhone' => '(949) 555-9988',
    'WorkEmail' => 'samantha.scott@unum.com',
    'LinkedIn' => 'https://www.linkedin.com/in/samantha-scott-oc',
    'JobTitle' => 'Disability Insurance Specialist',
    'City' => 'Laguna Beach',
    'State' => 'California',
    'Zip' => '92651',
    'College' => 'UC Irvine',
    'Degree' => 'Bachelor of Science, Economics'
});

// Candidate 29
candidateData.add(new Map<String, String>{
    'FirstName' => 'Eric',
    'LastName' => 'Green',
    'MobilePhone' => '(818) 555-9900',
    'PersonalEmail' => 'egreen.sfv@gmail.com',
    'WorkPhone' => '(818) 555-0099',
    'WorkEmail' => 'eric.green@statefarm.com',
    'LinkedIn' => 'https://www.linkedin.com/in/eric-green-sfv',
    'JobTitle' => 'Agency Owner',
    'City' => 'Burbank',
    'State' => 'California',
    'Zip' => '91502',
    'College' => 'Cal State Northridge',
    'Degree' => 'Bachelor of Science, Business Admin'
});

// Candidate 30
candidateData.add(new Map<String, String>{
    'FirstName' => 'Christina',
    'LastName' => 'Adams',
    'MobilePhone' => '(626) 555-0011',
    'PersonalEmail' => 'cadams.sgv@yahoo.com',
    'WorkPhone' => '(626) 555-1100',
    'WorkEmail' => 'christina.adams@farmers.com',
    'LinkedIn' => 'https://www.linkedin.com/in/christina-adams-sgv',
    'JobTitle' => 'Insurance Consultant',
    'City' => 'Arcadia',
    'State' => 'California',
    'Zip' => '91006',
    'College' => 'Cal Poly Pomona',
    'Degree' => 'Bachelor of Science, Finance'
});

// Create Contacts first
for (Map<String, String> data : candidateData) {
    Contact c = new Contact(
        FirstName = data.get('FirstName'),
        LastName = data.get('LastName'),
        MobilePhone = String.isNotBlank(data.get('MobilePhone')) ? data.get('MobilePhone') : null,
        Email = String.isNotBlank(data.get('PersonalEmail')) ? data.get('PersonalEmail') : data.get('WorkEmail'),
        Phone = String.isNotBlank(data.get('WorkPhone')) ? data.get('WorkPhone') : null,
        Title = data.get('JobTitle'),
        MailingCity = String.isNotBlank(data.get('City')) ? data.get('City') : null,
        MailingState = data.get('State'),
        MailingPostalCode = data.get('Zip')
    );
    contacts.add(c);
}

insert contacts;
System.debug('Inserted ' + contacts.size() + ' contacts');

// Now create Candidates linked to Contacts
List<Candidate__c> candidates = new List<Candidate__c>();

for (Integer i = 0; i < contacts.size(); i++) {
    Contact c = contacts[i];
    Map<String, String> data = candidateData[i];
    
    Candidate__c cand = new Candidate__c(
        Contact__c = c.Id,
        First_Name__c = data.get('FirstName'),
        Last_Name__c = data.get('LastName'),
        Mobile__c = String.isNotBlank(data.get('MobilePhone')) ? data.get('MobilePhone') : null,
        personal_email__c = String.isNotBlank(data.get('PersonalEmail')) ? data.get('PersonalEmail') : null,
        Work_Phone__c = String.isNotBlank(data.get('WorkPhone')) ? data.get('WorkPhone') : null,
        Work_Email_Address__c = String.isNotBlank(data.get('WorkEmail')) ? data.get('WorkEmail') : null,
        Website__c = String.isNotBlank(data.get('LinkedIn')) ? data.get('LinkedIn') : null,
        Current_Occupation__c = String.isNotBlank(data.get('JobTitle')) ? data.get('JobTitle').left(50) : null,
        City__c = String.isNotBlank(data.get('City')) ? data.get('City') : null,
        State_Province__c = data.get('State'),
        Zip_Postal_Code__c = data.get('Zip'),
        School_s_Attended__c = String.isNotBlank(data.get('College')) ? data.get('College') : null,
        Degree_Earned__c = String.isNotBlank(data.get('Degree')) ? data.get('Degree') : null,
        Recruiting_Source__c = 'Referral',
        Status__c = 'New'
    );
    candidates.add(cand);
}

insert candidates;
System.debug('Inserted ' + candidates.size() + ' candidates');

// Output summary
System.debug('=== TEST DATA CREATION COMPLETE ===');
System.debug('Created ' + contacts.size() + ' Contacts');
System.debug('Created ' + candidates.size() + ' Candidates');
System.debug('All candidates set to Status = New, Source = Referral');
