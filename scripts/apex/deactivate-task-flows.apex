// Script to deactivate Task flows - run manually in Developer Console
// Go to Setup -> Flows -> Find each flow -> Deactivate

// The following flows need to be deactivated to fix Task completion errors:
// 1. Add Contact Name to Newly Created Activity Record
// 2. Auto-Populate Calls Flow v2
// 3. Create Recurring Calls

// Alternative: Use Metadata API
// This cannot be done via Anonymous Apex - must be done in Setup UI or via Metadata deployment

System.debug('Please deactivate the following flows in Setup -> Flows:');
System.debug('1. Add Contact Name to Newly Created Activity Record');
System.debug('2. Auto-Populate Calls Flow v2');
System.debug('3. Create Recurring Calls');
