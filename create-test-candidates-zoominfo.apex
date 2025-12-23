// Create test Contacts and Candidates from ZoomInfo export
// Run this in the Recruiting Sandbox

List<Contact> contacts = new List<Contact>();
List<Map<String, String>> candidateData = new List<Map<String, String>>();

// Candidate 1: Thomas Camaione
candidateData.add(new Map<String, String>{
    'FirstName' => 'Thomas',
    'LastName' => 'Camaione',
    'MobilePhone' => '(949) 355-1469',
    'PersonalEmail' => 'tcamsurf@gmail.com',
    'WorkPhone' => '(801) 365-0632',
    'WorkEmail' => 'thomas.camaione@hubinternational.com',
    'LinkedIn' => 'https://www.linkedin.com/in/thomas-camaione-381243105',
    'JobTitle' => 'Commercial Insurance Broker (Trucking & Transportation)',
    'City' => 'Costa Mesa',
    'State' => 'California',
    'Zip' => '92626',
    'Company' => 'Hub International',
    'College' => 'Southern Utah University',
    'Degree' => 'Bachelor of Science'
});

// Candidate 2: Arya Fiouzi
candidateData.add(new Map<String, String>{
    'FirstName' => 'Arya',
    'LastName' => 'Fiouzi',
    'MobilePhone' => '(818) 536-8271',
    'PersonalEmail' => 'aryaf@hotmail.com',
    'WorkPhone' => '(424) 901-8007',
    'WorkEmail' => 'arya@fisandassociates.com',
    'LinkedIn' => 'https://www.linkedin.com/in/arya-fiouzi-23364433',
    'JobTitle' => 'Life Insurance Specialist',
    'City' => 'Los Angeles',
    'State' => 'California',
    'Zip' => '90024',
    'Company' => 'Fiouzi Insurance Services',
    'College' => '',
    'Degree' => ''
});

// Candidate 3: Harold Smith
candidateData.add(new Map<String, String>{
    'FirstName' => 'Harold',
    'LastName' => 'Smith',
    'MobilePhone' => '(310) 490-1178',
    'PersonalEmail' => 'connollysmith@gmail.com',
    'WorkPhone' => '(310) 893-2120',
    'WorkEmail' => 'harold@lyddy.com',
    'LinkedIn' => 'https://www.linkedin.com/in/harold-smith-a4a08122',
    'JobTitle' => 'Insurance Agent and Broker',
    'City' => 'Los Angeles',
    'State' => 'California',
    'Zip' => '90025',
    'Company' => 'Lyddy Martin',
    'College' => '',
    'Degree' => ''
});

// Candidate 4: Carol Marjak
candidateData.add(new Map<String, String>{
    'FirstName' => 'Carol',
    'LastName' => 'Marjak',
    'MobilePhone' => '(714) 321-2069',
    'PersonalEmail' => 'ponderosa36@hotmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'carol@employersins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/carol-marjak-55a52754',
    'JobTitle' => 'Insurance Agent and Broker',
    'City' => 'Anaheim',
    'State' => 'California',
    'Zip' => '92807',
    'Company' => 'Employers Insurance',
    'College' => 'Cal State Long Beach',
    'Degree' => 'Bachelor of Arts, Speech Communications'
});

// Candidate 5: Alan Harris
candidateData.add(new Map<String, String>{
    'FirstName' => 'Alan',
    'LastName' => 'Harris',
    'MobilePhone' => '(818) 620-8070',
    'PersonalEmail' => 'gogebic3305@hotmail.com',
    'WorkPhone' => '(818) 752-4299',
    'WorkEmail' => 'alan@hexam.com',
    'LinkedIn' => 'https://www.linkedin.com/in/alan-harris-84001311',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Studio City',
    'State' => 'California',
    'Zip' => '91604',
    'Company' => 'Hexam',
    'College' => 'DePaul University',
    'Degree' => 'Bachelor of Arts, Bus/Law'
});

// Candidate 6: Kerry Wakely
candidateData.add(new Map<String, String>{
    'FirstName' => 'Kerry',
    'LastName' => 'Wakely',
    'MobilePhone' => '(714) 612-0797',
    'PersonalEmail' => 'ktwakely@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'kerry@piascins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/kerrytwakely',
    'JobTitle' => 'Commercial Insurance Broker',
    'City' => 'Commerce',
    'State' => 'California',
    'Zip' => '90040',
    'Company' => 'PIASC Insurance Services',
    'College' => 'University of Minnesota-Twin Cities',
    'Degree' => 'BIS'
});

// Candidate 7: David Hood
candidateData.add(new Map<String, String>{
    'FirstName' => 'David',
    'LastName' => 'Hood',
    'MobilePhone' => '(760) 445-0619',
    'PersonalEmail' => 'elev8chrishood@gmail.com',
    'WorkPhone' => '(714) 577-4542',
    'WorkEmail' => 'dave.hood@nfp.com',
    'LinkedIn' => 'https://www.linkedin.com/in/david-hood-8883b83a',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Santa Ana',
    'State' => 'California',
    'Zip' => '92705',
    'Company' => 'NFP',
    'College' => '',
    'Degree' => ''
});

// Candidate 8: Bradley Scott
candidateData.add(new Map<String, String>{
    'FirstName' => 'Bradley',
    'LastName' => 'Scott',
    'MobilePhone' => '(832) 922-5041',
    'PersonalEmail' => '',
    'WorkPhone' => '(626) 243-9604',
    'WorkEmail' => 'brads@arroyoins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/bradley-scott-234656325',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Pasadena',
    'State' => 'California',
    'Zip' => '91107',
    'Company' => 'Arroyo Insurance Services',
    'College' => '',
    'Degree' => ''
});

// Candidate 9: Luis Orozco
candidateData.add(new Map<String, String>{
    'FirstName' => 'Luis',
    'LastName' => 'Orozco',
    'MobilePhone' => '(949) 500-5003',
    'PersonalEmail' => 'luisdanielorozco72.lo@gmail.com',
    'WorkPhone' => '(714) 399-0106',
    'WorkEmail' => 'luis@samedayinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/luis-orozco-517027112',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Long Beach',
    'State' => 'California',
    'Zip' => '90813',
    'Company' => 'Sameday Insurance Services',
    'College' => 'California State University-Long Beach',
    'Degree' => 'Bachelors Degree'
});

// Candidate 10: Richard Cooper
candidateData.add(new Map<String, String>{
    'FirstName' => 'Richard',
    'LastName' => 'Cooper',
    'MobilePhone' => '(818) 398-7721',
    'PersonalEmail' => 'rbcooper65@cox.net',
    'WorkPhone' => '(949) 220-2340',
    'WorkEmail' => 'rich@builderschoiceinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/rich-cooper-a6b431103',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Newport Beach',
    'State' => 'California',
    'Zip' => '92661',
    'Company' => 'Builders\' Choice Insurance Services',
    'College' => 'Moorpark College',
    'Degree' => 'Business Administration'
});

// Candidate 11: James Kim
candidateData.add(new Map<String, String>{
    'FirstName' => 'James',
    'LastName' => 'Kim',
    'MobilePhone' => '',
    'PersonalEmail' => 'kim66921@gmail.com',
    'WorkPhone' => '(310) 586-3371',
    'WorkEmail' => 'james.kim@jsbinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/james-kim-b44986122',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Los Angeles',
    'State' => 'California',
    'Zip' => '90035',
    'Company' => 'JSB Insurance Services',
    'College' => '',
    'Degree' => ''
});

// Candidate 12: Scott Swanson
candidateData.add(new Map<String, String>{
    'FirstName' => 'Scott',
    'LastName' => 'Swanson',
    'MobilePhone' => '(562) 537-4852',
    'PersonalEmail' => 'sswany7@gmail.com',
    'WorkPhone' => '(562) 264-1494',
    'WorkEmail' => 'scott@christiancharlesinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/scott-swanson-7811582a',
    'JobTitle' => 'Commercial Insurance Broker',
    'City' => 'Long Beach',
    'State' => 'California',
    'Zip' => '90804',
    'Company' => 'Christian Charles Insurance Services',
    'College' => 'University Of California',
    'Degree' => 'History'
});

// Candidate 13: Connie Stevenson
candidateData.add(new Map<String, String>{
    'FirstName' => 'Connie',
    'LastName' => 'Stevenson',
    'MobilePhone' => '',
    'PersonalEmail' => 'eewphotography@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'connie@johnsonwood.com',
    'LinkedIn' => 'https://www.linkedin.com/in/conniestevenson',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Carlsbad',
    'State' => 'California',
    'Zip' => '92010',
    'Company' => 'Johnson & Wood Insurance Services',
    'College' => '',
    'Degree' => ''
});

// Candidate 14: Robert Jennings
candidateData.add(new Map<String, String>{
    'FirstName' => 'Robert',
    'LastName' => 'Jennings',
    'MobilePhone' => '(562) 310-3079',
    'PersonalEmail' => '',
    'WorkPhone' => '',
    'WorkEmail' => 'bobj@calgard.com',
    'LinkedIn' => 'https://www.linkedin.com/in/robert-jennings-psyd-cpcu-9606901a6',
    'JobTitle' => 'Insurance Agent - Broker',
    'City' => 'San Dimas',
    'State' => 'California',
    'Zip' => '91773',
    'Company' => 'Calgard Associates',
    'College' => '',
    'Degree' => ''
});

// Candidate 15: Cindy Uehara
candidateData.add(new Map<String, String>{
    'FirstName' => 'Cindy',
    'LastName' => 'Uehara',
    'MobilePhone' => '(808) 348-1274',
    'PersonalEmail' => '',
    'WorkPhone' => '',
    'WorkEmail' => 'cindy@rayainsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/cindy-uehara-cic-400a8b85',
    'JobTitle' => 'Insurance Broker',
    'City' => 'San Gabriel',
    'State' => 'California',
    'Zip' => '91776',
    'Company' => 'The John L Raya Insurance Group',
    'College' => 'California State University-Los Angeles',
    'Degree' => 'Bachelor of Science'
});

// Candidate 16: Steve Beck
candidateData.add(new Map<String, String>{
    'FirstName' => 'Steve',
    'LastName' => 'Beck',
    'MobilePhone' => '(818) 624-3138',
    'PersonalEmail' => 'tbirdbecky@yahoo.com',
    'WorkPhone' => '(818) 643-7390',
    'WorkEmail' => 'sbeck@libertycompany.com',
    'LinkedIn' => 'https://www.linkedin.com/in/steve-beck-42b650226',
    'JobTitle' => 'Insurance Sales Agent',
    'City' => 'Woodland Hills',
    'State' => 'California',
    'Zip' => '91367',
    'Company' => 'Liberty',
    'College' => 'UC-Santa Barbara',
    'Degree' => 'Bachelor, Business Economics'
});

// Candidate 17: David Weeks
candidateData.add(new Map<String, String>{
    'FirstName' => 'David',
    'LastName' => 'Weeks',
    'MobilePhone' => '(951) 447-5433',
    'PersonalEmail' => 'djweeks227@hotmail.com',
    'WorkPhone' => '(951) 973-0969',
    'WorkEmail' => 'dweeks@orrandassociates.com',
    'LinkedIn' => 'https://www.linkedin.com/in/david-weeks-76b15a12a',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Wildomar',
    'State' => 'California',
    'Zip' => '92595',
    'Company' => 'Orr and Associates',
    'College' => 'California State University, Fullerton',
    'Degree' => 'Mathematics'
});

// Candidate 18: Maro Maraslian
candidateData.add(new Map<String, String>{
    'FirstName' => 'Maro',
    'LastName' => 'Maraslian',
    'MobilePhone' => '(818) 231-4746',
    'PersonalEmail' => 'maroharutiunian@sbcglobal.net',
    'WorkPhone' => '',
    'WorkEmail' => 'maro@landingins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/maro-maraslian-857714117',
    'JobTitle' => 'Insurance Agent and Broker',
    'City' => 'Buena Park',
    'State' => 'California',
    'Zip' => '90621',
    'Company' => 'Landing Insurance Agency',
    'College' => '',
    'Degree' => ''
});

// Candidate 19: Carol Roane
candidateData.add(new Map<String, String>{
    'FirstName' => 'Carol',
    'LastName' => 'Roane',
    'MobilePhone' => '(949) 310-1919',
    'PersonalEmail' => 'carol_roane@sbcglobal.net',
    'WorkPhone' => '(949) 429-7000',
    'WorkEmail' => 'carol@insuresaver.com',
    'LinkedIn' => 'https://www.linkedin.com/in/carol-roane-0962445',
    'JobTitle' => 'Group Health Life Insurance Broker',
    'City' => 'Laguna Niguel',
    'State' => 'California',
    'Zip' => '92677',
    'Company' => 'InsureSaver Insurance Agency',
    'College' => '',
    'Degree' => ''
});

// Candidate 20: Sky Merit
candidateData.add(new Map<String, String>{
    'FirstName' => 'Sky',
    'LastName' => 'Merit',
    'MobilePhone' => '(954) 479-9619',
    'PersonalEmail' => 'meritschuyler@gmail.com',
    'WorkPhone' => '(714) 384-6540',
    'WorkEmail' => 'sky.merit@commainsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/sky-merit-03080538',
    'JobTitle' => 'Insurance Professional',
    'City' => 'Lake Forest',
    'State' => 'California',
    'Zip' => '92630',
    'Company' => 'Comma Insurance',
    'College' => '',
    'Degree' => ''
});

// Candidate 21: Dawn Grant
candidateData.add(new Map<String, String>{
    'FirstName' => 'Dawn',
    'LastName' => 'Grant',
    'MobilePhone' => '(858) 922-7127',
    'PersonalEmail' => 'dmgdelmar@yahoo.com',
    'WorkPhone' => '(760) 466-1588',
    'WorkEmail' => 'dawn@aviains.com',
    'LinkedIn' => 'https://www.linkedin.com/in/dawn-grant-2a77354',
    'JobTitle' => 'Insurance Agent',
    'City' => 'Carlsbad',
    'State' => 'California',
    'Zip' => '92008',
    'Company' => 'Alta Vista Insurance Agency',
    'College' => 'Bowling Green State University',
    'Degree' => 'Bachelor Degree'
});

// Candidate 22: Ruby Zakarian
candidateData.add(new Map<String, String>{
    'FirstName' => 'Ruby',
    'LastName' => 'Zakarian',
    'MobilePhone' => '(818) 744-3692',
    'PersonalEmail' => '',
    'WorkPhone' => '',
    'WorkEmail' => 'ruby@capitaleliteins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/capitaleliteins-65b8b8194',
    'JobTitle' => 'P & C Insurance Agent Broker',
    'City' => 'North Hollywood',
    'State' => 'California',
    'Zip' => '91605',
    'Company' => 'Capital Elite Insurance',
    'College' => '',
    'Degree' => ''
});

// Candidate 23: Alice Bannister
candidateData.add(new Map<String, String>{
    'FirstName' => 'Alice',
    'LastName' => 'Bannister',
    'MobilePhone' => '(714) 943-3173',
    'PersonalEmail' => 'alicembannister@gmail.com',
    'WorkPhone' => '(714) 536-6086',
    'WorkEmail' => 'lisa@bai-ins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/lisa-bannister-15610357',
    'JobTitle' => 'Insurance Agent',
    'City' => 'Huntington Beach',
    'State' => 'California',
    'Zip' => '92648',
    'Company' => 'Bannister & Associates Insurance Agency',
    'College' => '',
    'Degree' => ''
});

// Candidate 24: Lisa Sandoval
candidateData.add(new Map<String, String>{
    'FirstName' => 'Lisa',
    'LastName' => 'Sandoval',
    'MobilePhone' => '(562) 619-3858',
    'PersonalEmail' => 'letsactup@yahoo.com',
    'WorkPhone' => '',
    'WorkEmail' => 'lisa@lisasandovalinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/lisa-sandoval-60367b15',
    'JobTitle' => 'Health Insurance Broker',
    'City' => 'Long Beach',
    'State' => 'California',
    'Zip' => '90815',
    'Company' => 'Lisa Sandoval Insurance Services',
    'College' => 'San Diego State University',
    'Degree' => ''
});

// Candidate 25: Babs Hernandez
candidateData.add(new Map<String, String>{
    'FirstName' => 'Babs',
    'LastName' => 'Hernandez',
    'MobilePhone' => '(213) 722-1737',
    'PersonalEmail' => '',
    'WorkPhone' => '',
    'WorkEmail' => 'babs@capitanoinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/babs-hernandez-4a425415',
    'JobTitle' => 'Commercial And Personal Lines Insurance Broker',
    'City' => 'West Covina',
    'State' => 'California',
    'Zip' => '91791',
    'Company' => 'Christ Spang & Capitano Insurance',
    'College' => '',
    'Degree' => ''
});

// Candidate 26: Devashi Whaylen
candidateData.add(new Map<String, String>{
    'FirstName' => 'Devashi',
    'LastName' => 'Whaylen',
    'MobilePhone' => '',
    'PersonalEmail' => '',
    'WorkPhone' => '(360) 949-1414',
    'WorkEmail' => 'devashi_whaylen@sysmetrx.com',
    'LinkedIn' => '',
    'JobTitle' => 'Insurance Agent',
    'City' => '',
    'State' => 'California',
    'Zip' => '90703',
    'Company' => 'Sysmetrx',
    'College' => '',
    'Degree' => ''
});

// Candidate 27: Judy Flowers
candidateData.add(new Map<String, String>{
    'FirstName' => 'Judy',
    'LastName' => 'Flowers',
    'MobilePhone' => '(714) 396-1294',
    'PersonalEmail' => 'weeteddi@aol.com',
    'WorkPhone' => '',
    'WorkEmail' => 'judy@williamsinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/judy-flowers-656700b',
    'JobTitle' => 'Professional Insurance Agent',
    'City' => 'Fullerton',
    'State' => 'California',
    'Zip' => '92832',
    'Company' => 'Williams',
    'College' => '',
    'Degree' => ''
});

// Candidate 28: Nichole Lucas
candidateData.add(new Map<String, String>{
    'FirstName' => 'Nichole',
    'LastName' => 'Lucas',
    'MobilePhone' => '(240) 319-9519',
    'PersonalEmail' => '',
    'WorkPhone' => '',
    'WorkEmail' => 'nichole@piascins.com',
    'LinkedIn' => 'https://www.linkedin.com/in/nichole-lucas-b1532985',
    'JobTitle' => 'Commercial Insurance Broker',
    'City' => 'Commerce',
    'State' => 'California',
    'Zip' => '90040',
    'Company' => 'PIASC Insurance Services',
    'College' => 'University of Arkansas Grantham',
    'Degree' => 'MBA Project Management'
});

// Candidate 29: Leslie Hayes
candidateData.add(new Map<String, String>{
    'FirstName' => 'Leslie',
    'LastName' => 'Hayes',
    'MobilePhone' => '(909) 268-1638',
    'PersonalEmail' => 'ljhayes8844@att.net',
    'WorkPhone' => '(909) 932-2127',
    'WorkEmail' => 'lhayes@kessleralair.com',
    'LinkedIn' => 'https://www.linkedin.com/in/leslie-hayes-a59a2010',
    'JobTitle' => 'Insurance Agent',
    'City' => 'Upland',
    'State' => 'California',
    'Zip' => '91786',
    'Company' => 'Kessler Alair Insurance Services',
    'College' => 'Chaffey College',
    'Degree' => ''
});

// Candidate 30: Robin Naversen
candidateData.add(new Map<String, String>{
    'FirstName' => 'Robin',
    'LastName' => 'Naversen',
    'MobilePhone' => '(562) 221-5512',
    'PersonalEmail' => 'btoy247365@hotmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'rnaversen@olsonduncan.com',
    'LinkedIn' => 'https://www.linkedin.com/in/robin-naversen-a7494567',
    'JobTitle' => 'Personal Insurance Sales Agent',
    'City' => 'Torrance',
    'State' => 'California',
    'Zip' => '90505',
    'Company' => 'ISU-The Olson Duncan Agency',
    'College' => '',
    'Degree' => ''
});

// Candidate 31: Stephen Gobrial
candidateData.add(new Map<String, String>{
    'FirstName' => 'Stephen',
    'LastName' => 'Gobrial',
    'MobilePhone' => '(310) 804-6617',
    'PersonalEmail' => 'stephen.gobrial@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'stephen@sgibinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/stephen-gobrial-52880925',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Chatsworth',
    'State' => 'California',
    'Zip' => '91311',
    'Company' => 'SGIB Insurance Services',
    'College' => 'California State University, Northridge',
    'Degree' => 'Finance, Real Estate, & Insurance'
});

// Candidate 32: Corey Baubault
candidateData.add(new Map<String, String>{
    'FirstName' => 'Corey',
    'LastName' => 'Baubault',
    'MobilePhone' => '(951) 531-5142',
    'PersonalEmail' => 'coreybaubault@hotmail.com',
    'WorkPhone' => '(951) 677-6200',
    'WorkEmail' => 'cbaubault@siainc.net',
    'LinkedIn' => 'https://www.linkedin.com/in/corey-baubault-414a98aa',
    'JobTitle' => 'Insurance Broker and District Manager',
    'City' => 'Murrieta',
    'State' => 'California',
    'Zip' => '92562',
    'Company' => 'Steele Insurance Agency',
    'College' => 'New Mexico State University',
    'Degree' => 'Bachelor of Marketing'
});

// Candidate 33: Tj Jeremiah
candidateData.add(new Map<String, String>{
    'FirstName' => 'Tj',
    'LastName' => 'Jeremiah',
    'MobilePhone' => '(760) 613-9039',
    'PersonalEmail' => 'tj.jeremiah@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'tj@shorebreakinsurance.com',
    'LinkedIn' => 'https://www.linkedin.com/in/tj-jeremiah-95003525',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Carlsbad',
    'State' => 'California',
    'Zip' => '92009',
    'Company' => 'Shorebreak Insurance Services',
    'College' => 'California Polytechnic State University-San Luis Obispo',
    'Degree' => 'Bachelor of Science, Social Science'
});

// Candidate 34: Monique Mendiola
candidateData.add(new Map<String, String>{
    'FirstName' => 'Monique',
    'LastName' => 'Mendiola',
    'MobilePhone' => '(559) 852-9442',
    'PersonalEmail' => 'moniquemendiola4040@icloud.com',
    'WorkPhone' => '',
    'WorkEmail' => 'mmendiola@srinsurancegroup.com',
    'LinkedIn' => 'https://www.linkedin.com/in/monique-mendiola-aa8173174',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Rancho Cucamonga',
    'State' => 'California',
    'Zip' => '91730',
    'Company' => 'S & R Insurance Group',
    'College' => '',
    'Degree' => ''
});

// Candidate 35: Austin Fleck
candidateData.add(new Map<String, String>{
    'FirstName' => 'Austin',
    'LastName' => 'Fleck',
    'MobilePhone' => '(609) 305-2499',
    'PersonalEmail' => 'fleckfuture@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'afleck@acrisure.com',
    'LinkedIn' => 'https://www.linkedin.com/in/austin-fleck-602758176',
    'JobTitle' => 'Insurance Broker',
    'City' => 'Dana Point',
    'State' => 'California',
    'Zip' => '92629',
    'Company' => 'Acrisure',
    'College' => 'Cabrini University',
    'Degree' => 'Biological Psychology'
});

// Candidate 36: Stacie Cadilli
candidateData.add(new Map<String, String>{
    'FirstName' => 'Stacie',
    'LastName' => 'Cadilli',
    'MobilePhone' => '(951) 233-0904',
    'PersonalEmail' => 'cadilli34@gmail.com',
    'WorkPhone' => '',
    'WorkEmail' => 'sta@newyorklife.com',
    'LinkedIn' => 'https://www.linkedin.com/in/stacie-cadilli-b0550774',
    'JobTitle' => 'Life Insurance Specialist',
    'City' => 'Chino Hills',
    'State' => 'California',
    'Zip' => '91709',
    'Company' => 'New York Life',
    'College' => 'Broward Community College',
    'Degree' => 'Emergency Medicine EMT/Paramedic'
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
        Recruiting_Source__c = 'LinkedIn',
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
System.debug('All candidates set to Status = New, Source = LinkedIn');
