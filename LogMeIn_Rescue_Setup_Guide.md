# LogMeIn Rescue Integration - Session Data Mapping Setup

## Current Configuration Status

### Objects Installed:
- ✅ `logmein__Rescue_Session__c` - Stores session data
- ✅ `logmein__Lightning_Custom_Fields__c` - Controls field mappings
- ✅ `logmein__RescueIntegration__c` - Integration settings
- ✅ `logmein__Rescue_Log__c` - Session logs

### Current Session Activity:
- Latest Session: RS-0000034 (Created: 2025-09-24)
- Sessions are successfully creating and linking to Cases
- PIN Numbers are being captured

## Issue: Session Data Not Creating/Updating Records

Based on your configuration, you have one Lightning Custom Fields record with mappings:
- Custom Field 0: `SuppliedName`
- Custom Field 1: `SuppliedName`
- Custom Field 2: `SuppliedPhone`
- Custom Field 3: `Agency__c`

However, these mappings need to be properly configured to create records.

## Setup Steps to Fix Session Data Mapping

### Step 1: Access LogMeIn Rescue Configuration
1. Go to Setup → Search for "LogMeIn Rescue"
2. Click on "LogMeIn Rescue Configuration" or navigate to the Custom Settings

### Step 2: Configure Lightning Custom Fields (Field Mapping)

The `logmein__Lightning_Custom_Fields__c` object controls what data from the Rescue session gets mapped to Salesforce fields.

**Current Record ID:** `a175f00000TBpStAAL`

**Field Mapping Structure:**
- `Name`: Unique identifier for this mapping configuration
- `logmein__Custom_Field_0__c` through `logmein__Custom_Field_5__c`: Define which fields to map

**To properly configure:**

1. Navigate to Setup → Custom Settings → Lightning Custom Fields
2. Click "Manage"
3. Edit the existing record (a175f00000TBpSt) or create a new one

### Step 3: Define Field Mappings

For each Custom Field (0-5), you need to specify:
- **Source Field**: The field name from the Rescue session (e.g., `SuppliedName`, `SuppliedEmail`, `SuppliedPhone`)
- **Target Object**: The Salesforce object to create/update (e.g., `Case`, `Contact`, `Lead`)
- **Target Field**: The API name of the field on the target object

**Example Configuration for Creating Cases:**

```
Custom_Field_0__c: SuppliedName → Case.Subject
Custom_Field_1__c: SuppliedEmail → Case.SuppliedEmail
Custom_Field_2__c: SuppliedPhone → Case.SuppliedPhone
Custom_Field_3__c: SuppliedCompany → Case.SuppliedCompany
Custom_Field_4__c: Description → Case.Description
Custom_Field_5__c: Origin → Case.Origin (set to "Rescue Session")
```

**Example Configuration for Custom Object:**

If you want to create records on a custom object (e.g., `Support_Ticket__c`):

```
Custom_Field_0__c: SuppliedName → Support_Ticket__c.Customer_Name__c
Custom_Field_1__c: SuppliedEmail → Support_Ticket__c.Email__c
Custom_Field_2__c: SuppliedPhone → Support_Ticket__c.Phone__c
Custom_Field_3__c: PIN_Number → Support_Ticket__c.Session_PIN__c
```

### Step 4: Available Rescue Session Fields

These are the fields you can map FROM the Rescue session:

**Session Information:**
- `Pin_Number__c` - The PIN used for the session
- `Pin_Type__c` - Type of PIN (PIN, LENS_PIN, etc.)
- `Name` - Auto-number name (RS-0000XXX)
- `CreatedDate` - When session started
- `Case__c` - Linked Case (if exists)

**Web Form Fields** (if using pre-chat form):
- `SuppliedName` - Customer's name
- `SuppliedEmail` - Customer's email
- `SuppliedPhone` - Customer's phone
- `SuppliedCompany` - Customer's company
- Any custom web form fields you've configured

### Step 5: Configure Automatic Record Creation

To enable automatic record creation after a session ends:

1. Go to Setup → Custom Settings → RescueIntegration
2. Enable "Create Records Automatically" (if available)
3. Specify the Object Name (e.g., `Case` or `Custom_Object__c`)
4. Optionally specify Record Type Name

### Step 6: Test the Configuration

1. Start a new Rescue session
2. End the session
3. Check if a record was created on your target object
4. Verify the field mappings are working correctly

## Troubleshooting

### If Records Are Not Being Created:

1. **Check Rescue Log Object:**
   ```soql
   SELECT Id, Name, logmein__Error_Message__c, logmein__Session__c, CreatedDate
   FROM logmein__Rescue_Log__c
   ORDER BY CreatedDate DESC
   LIMIT 10
   ```

2. **Verify Field API Names:**
   - Ensure target field API names are correct
   - Custom fields must end with `__c`
   - Standard fields use their API name (e.g., `Subject`, `Description`)

3. **Check User Permissions:**
   - User must have Create permission on target object
   - User must have Edit permission on target fields

4. **Review Rescue Session Creation:**
   ```soql
   SELECT Id, Name, logmein__Pin_Number__c, logmein__Case__c, CreatedDate
   FROM logmein__Rescue_Session__c
   ORDER BY CreatedDate DESC
   LIMIT 5
   ```

## Current Configuration to Update

Based on your existing record, you should update it to have proper format. The current values look incomplete:

**Current:** 
- Custom_Field_0__c: `SuppliedName`
- Custom_Field_1__c: `SuppliedName`
- Custom_Field_2__c: `SuppliedPhone`
- Custom_Field_3__c: `Agency__c`

**These should be in format:** `SourceField|TargetObject.TargetField`

**Example Corrected Format:**
- Custom_Field_0__c: `SuppliedName|Case.Subject`
- Custom_Field_1__c: `SuppliedEmail|Case.SuppliedEmail`
- Custom_Field_2__c: `SuppliedPhone|Case.SuppliedPhone`
- Custom_Field_3__c: `PIN_Number|Case.Description`

## Next Steps

1. **Open the Custom Settings** in your Production org
2. **Edit the Lightning Custom Fields record** (ID: a175f00000TBpStAAL)
3. **Update the field mappings** using the format above
4. **Test with a new Rescue session**
5. **Check Rescue Logs** for any errors

## Additional Resources

- LogMeIn Rescue Documentation: Check the PDF guide sections on "Field Mapping" and "Automatic Record Creation"
- Salesforce Object API Names: Setup → Object Manager → [Your Object] → Fields
- Test in Sandbox first if available before implementing in Production

## Need Help?

If you need specific field mappings for your objects, please provide:
1. What object you want to create records on (Case, Custom Object, etc.)
2. What fields you want to populate
3. What data you're collecting in your Rescue web form
