import csv

# These are the candidate names that were successfully matched/imported
# (from the earlier import log)
matched_candidates = {
    'Angie Larson', 'Alec Bucklen', 'Alonso Maciel', 'Andrew Moran',
    'Calix Boldt', 'Colton Livingston', 'Craig Lytle', 'David Smith',
    'Dominic McLaughlin', 'Emily Pendleton', 'Faye Ferguson', 'Gwyneth Landaburu',
    'Heather Hackett', 'Jacob Pesicka', 'Jennifer Ronquillo', 'Jesse Goldberg',
    'Jonathan Espinoza', 'Katerina Minevich', 'Kim Tapia', 'Kyle Ouellette',
    'Marcus Filardi', 'Marisol ONeil', 'Mary Beth Jackson', 'Matt Diamond',
    'Michael Donatucci', 'Michael Madsen', 'Monte Soderquist', 'Paras Bengco',
    'Pierre Marcel Perez', 'Pierre Perez', 'Preston Lee', 'Raymond Yin',
    'Robert Wilson', 'Roger Olson', 'Sabrina Moya', 'Salina Bouasangouane',
    'Skyler Fleming', 'Toby Taylor', 'Travis Jorgensen', 'Tyler Jones',
    'Washington Ibarra', 'Yvonne Garcia', 'Zack Jones', 'Daisa Alvarez',
    'Adam Pryor'
}

# Read all interviews
with open('all_interviews.csv', 'r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    interviews = list(reader)

# Find unmatched interviews (those not imported)
unmatched_interviews = []

for interview in interviews:
    # Extract candidate name from interview name
    name_parts = interview['Name'].split(' - ')
    candidate_name = name_parts[0].strip()
    
    # Check if this interview's candidate was matched
    if candidate_name not in matched_candidates:
        unmatched_interviews.append({
            'Interview_Name': interview['Name'],
            'Candidate_Name': candidate_name,
            'Old_Candidate_ID': interview['Candidate__c'],
            'Interviewer': interview['Interviewer_s__c'],
            'Interview_Type': interview['Interview_Type__c'],
            'Date_Completed': interview['Date_Completed__c'],
            'Date_Scheduled': interview['Date_Time_Scheduled__c'],
            'Status': interview['Interview_Status__c']
        })

# Write unmatched interviews to CSV
with open('unmatched_interviews.csv', 'w', newline='', encoding='utf-8') as f:
    if unmatched_interviews:
        fieldnames = ['Interview_Name', 'Candidate_Name', 'Old_Candidate_ID', 'Interviewer', 
                     'Interview_Type', 'Date_Completed', 'Date_Scheduled', 'Status']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(unmatched_interviews)

print(f"Found {len(unmatched_interviews)} unmatched interviews\n")
print("=" * 100)
print(f"{'Interview Name':<50} {'Candidate Name':<30} {'Type':<15}")
print("=" * 100)

for interview in unmatched_interviews:
    print(f"{interview['Interview_Name']:<50} {interview['Candidate_Name']:<30} {interview['Interview_Type']:<15}")

print("=" * 100)
print(f"\nDetailed information saved to: unmatched_interviews.csv")
print("\nReasons for unmatched:")
test_candidates = [i for i in unmatched_interviews if 'Test Candidate' in i['Candidate_Name']]
id_candidates = [i for i in unmatched_interviews if i['Candidate_Name'].startswith('a02')]
other_candidates = [i for i in unmatched_interviews if i not in test_candidates and i not in id_candidates]

print(f"  - Test Candidates (don't exist in production): {len(test_candidates)}")
print(f"  - Candidates with ID as name (data corruption): {len(id_candidates)}")
print(f"  - Other candidates (may have been deleted): {len(other_candidates)}")
