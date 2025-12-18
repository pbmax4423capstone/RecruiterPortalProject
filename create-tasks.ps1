# Load CSV data
$tasks = Import-Csv report1764112415512.csv
$contacts = Import-Csv all-contacts.csv

# Create contact lookup map
$contactMap = @{}
foreach ($c in $contacts) {
    $contactMap[$c.Name] = $c.Id
}

# Create new task records
$newTasks = @()
foreach ($task in $tasks) {
    if ($task.CANDIDATE -and $task.'DUE DATE' -and $task.SUBJECT) {
        $whoId = $contactMap[$task.CANDIDATE]
        if ($whoId) {
            $newTask = [PSCustomObject]@{
                Subject = $task.SUBJECT
                ActivityDate = ([datetime]$task.'DUE DATE').ToString('yyyy-MM-dd')
                CallType = 'Inbound'
                Status = 'Not Started'
                OwnerId = '0055f00000DqpnpAAB'
                WhoId = $whoId
            }
            $newTasks += $newTask
        }
    }
}

# Export to CSV
$newTasks | Export-Csv -Path new-tasks-bulk.csv -NoTypeInformation
Write-Output "Created $($newTasks.Count) tasks"
