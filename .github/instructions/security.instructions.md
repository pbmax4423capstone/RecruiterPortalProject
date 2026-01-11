---
description: 'Security best practices for RecruiterPortal (OWASP, Salesforce Security)'
applyTo: '**/*.cls, **/*.trigger, **/*.js, force-app/**'
---

<!--
Attribution: Adapted from github.com/github/awesome-copilot/instructions/security-and-owasp.instructions.md
Customized for Salesforce RecruiterPortal security requirements
-->

# Security Best Practices for RecruiterPortal

## Salesforce-Specific Security

### 1. CRUD and FLS (Field-Level Security)

**Always check permissions before SOQL/DML operations:**

```apex
// ✅ GOOD: Check object access
public with sharing class CandidateService {
    public static List<Candidate__c> getCandidates() {
        if (!Schema.sObjectType.Candidate__c.isAccessible()) {
            throw new SecurityException('No access to Candidate object');
        }
        
        List<Candidate__c> candidates = [
            SELECT Id, First_Name__c, Last_Name__c, Stage__c
            FROM Candidate__c
            WITH SECURITY_ENFORCED
        ];
        
        return Security.stripInaccessible(
            AccessType.READABLE,
            candidates
        ).getRecords();
    }
    
    public static void updateCandidates(List<Candidate__c> candidates) {
        if (!Schema.sObjectType.Candidate__c.isUpdateable()) {
            throw new SecurityException('No update access to Candidate object');
        }
        
        update candidates;
    }
}

// ❌ BAD: No permission checks
public class InsecureService {
    public static List<Candidate__c> getCandidates() {
        return [SELECT Id, First_Name__c FROM Candidate__c];
    }
}
```

### 2. Sharing Rules

**Use `with sharing` by default:**

```apex
// ✅ GOOD: Enforces sharing rules
public with sharing class CandidateController {
    // Respects OWD, sharing rules, manual shares
}

// Use WITHOUT SHARING only when necessary and document why
public without sharing class SystemAdminService {
    // Used for system operations that need elevated access
    // SECURITY NOTE: Only called from privileged contexts
}

// ✅ GOOD: Inherit caller's sharing context
public inherited sharing class UtilityClass {
    // Inherits sharing from calling class
}
```

### 3. SOQL Injection Prevention

**Always escape user input:**

```apex
// ✅ GOOD: Escape user input
public static List<Candidate__c> searchCandidates(String searchTerm) {
    String safeTerm = String.escapeSingleQuotes(searchTerm);
    
    return Database.query(
        'SELECT Id, First_Name__c, Last_Name__c FROM Candidate__c ' +
        'WHERE Last_Name__c LIKE \'%' + safeTerm + '%\' LIMIT 100'
    );
}

// ✅ BETTER: Use bind variables
public static List<Candidate__c> searchCandidates(String searchTerm) {
    String pattern = '%' + searchTerm + '%';
    return [
        SELECT Id, First_Name__c, Last_Name__c
        FROM Candidate__c
        WHERE Last_Name__c LIKE :pattern
        LIMIT 100
    ];
}

// ❌ BAD: Direct concatenation (SOQL injection risk)
public static List<Candidate__c> insecureSearch(String searchTerm) {
    return Database.query(
        'SELECT Id FROM Candidate__c WHERE Last_Name__c = \'' + searchTerm + '\''
    );
}
```

### 4. Cross-Site Scripting (XSS) in LWC

**Sanitize user input in templates:**

```javascript
// ✅ GOOD: Use {data} for automatic escaping
<template>
    <div>{candidateName}</div>
    <lightning-formatted-text value={userInput}></lightning-formatted-text>
</template>

// ❌ BAD: innerHTML with user data
<template>
    <div lwc:dom="manual"></div>
</template>

connectedCallback() {
    // SECURITY RISK: XSS vulnerability
    this.template.querySelector('div').innerHTML = this.userInput;
}

// ✅ GOOD: Sanitize if innerHTML is necessary
import DOMPurify from 'dompurify';

connectedCallback() {
    const sanitized = DOMPurify.sanitize(this.userInput);
    this.template.querySelector('div').innerHTML = sanitized;
}
```

### 5. Secure API Calls

**Use Named Credentials for external integrations:**

```apex
// ✅ GOOD: Use Named Credentials
public class LinkedInAPIService {
    private static final String NAMED_CREDENTIAL = 'callout:LinkedIn_API';
    
    public static HttpResponse importCandidate(String profileUrl) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(NAMED_CREDENTIAL + '/v1/people');
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        
        return new Http().send(req);
    }
}

// ❌ BAD: Hardcoded credentials
public class InsecureAPIService {
    private static final String API_KEY = 'sk_live_12345'; // NEVER DO THIS
    private static final String ENDPOINT = 'https://api.example.com';
}
```

## OWASP Top 10 for Salesforce

### A01: Broken Access Control

**Enforce least privilege:**

```apex
// ✅ GOOD: Check user permissions
public static Boolean canViewDashboard() {
    return Schema.sObjectType.Candidate__c.isAccessible() &&
           Schema.sObjectType.Interview__c.isAccessible();
}

@AuraEnabled(cacheable=true)
public static Map<String, Object> getDashboardData() {
    if (!canViewDashboard()) {
        throw new AuraHandledException('Insufficient permissions');
    }
    
    // Return data
}

// ✅ GOOD: Profile/Permission Set checks
if (FeatureManagement.checkPermission('View_Recruiter_Dashboard')) {
    // Allow access
}
```

### A02: Cryptographic Failures

**Protect sensitive data:**

```apex
// ✅ GOOD: Use Platform Encryption for sensitive fields
// Enable Shield Platform Encryption for:
// - SSN fields
// - Bank account numbers
// - Salary information

// ✅ GOOD: Hash passwords (if storing custom auth)
public static String hashPassword(String password) {
    Blob hash = Crypto.generateDigest('SHA-256', Blob.valueOf(password));
    return EncodingUtil.base64Encode(hash);
}

// ❌ BAD: Store passwords in plain text
public static void savePassword(String password) {
    User_Credential__c cred = new User_Credential__c();
    cred.Password__c = password; // NEVER DO THIS
}
```

### A03: Injection

**Prevent SOQL, XSS, and Command Injection:**

```apex
// ✅ GOOD: Use bind variables
List<Candidate__c> candidates = [
    SELECT Id FROM Candidate__c 
    WHERE Stage__c = :userStage
];

// ✅ GOOD: Validate input
public static void validateStage(String stage) {
    Set<String> validStages = new Set<String>{
        'CI-First', 'Align-Second', 'Plan-Third', 'Present-Fourth', 'Contracted'
    };
    
    if (!validStages.contains(stage)) {
        throw new IllegalArgumentException('Invalid stage: ' + stage);
    }
}

// ❌ BAD: Dynamic SOQL with user input
String query = 'SELECT Id FROM Candidate__c WHERE Stage__c = \'' + userInput + '\'';
List<Candidate__c> results = Database.query(query);
```

### A05: Security Misconfiguration

**Configure securely:**

```xml
<!-- ✅ GOOD: Restrict component access -->
<?xml version="1.0" encoding="UTF-8"?>
<LightningComponentBundle xmlns="http://soap.sforce.com/2006/04/metadata">
    <targets>
        <target>lightning__RecordPage</target>
    </targets>
    <targetConfigs>
        <targetConfig targets="lightning__RecordPage">
            <objects>
                <object>Candidate__c</object>
            </objects>
        </targetConfig>
    </targetConfigs>
</LightningComponentBundle>
```

```apex
// ✅ GOOD: Disable debug logs in production
if (!Test.isRunningTest()) {
    System.debug(LoggingLevel.WARN, 'Production log');
}

// ❌ BAD: Expose stack traces to users
catch (Exception e) {
    throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
}

// ✅ GOOD: Generic error to users, detailed logs for admins
catch (Exception e) {
    System.debug(LoggingLevel.ERROR, 'Full error: ' + e.getStackTraceString());
    throw new AuraHandledException('An error occurred. Please contact your administrator.');
}
```

### A07: Authentication Failures

**Secure session management:**

```apex
// ✅ GOOD: Use Salesforce authentication
// Never implement custom auth without:
// - Multi-factor authentication (MFA)
// - Password complexity requirements
// - Account lockout after failed attempts
// - Session timeout

// ✅ GOOD: Validate session
if (!UserInfo.getUserId().startsWith('005')) {
    throw new SecurityException('Invalid user session');
}

// ✅ GOOD: Use Permission Sets for feature access
public static Boolean hasRecruiterAccess() {
    return [
        SELECT COUNT()
        FROM PermissionSetAssignment
        WHERE AssigneeId = :UserInfo.getUserId()
        AND PermissionSet.Name = 'Recruiter_Dashboard_Access'
    ] > 0;
}
```

## Browser Extension Security

**For chrome-extension-linkedin and edge-extension-linkedin:**

### Content Script Security

```javascript
// ✅ GOOD: Use IIFE guard pattern
(function() {
    if (window.__linkedinToSalesforceLoaded) return;
    window.__linkedinToSalesforceLoaded = true;
    
    // Extension code here
    
    // Validate all user input
    function sanitizeInput(input) {
        return input.replace(/[<>\"\']/g, '');
    }
})();

// ✅ GOOD: Use Content Security Policy
// manifest.json
{
    "content_security_policy": {
        "extension_pages": "script-src 'self'; object-src 'self'"
    }
}

// ❌ BAD: eval() in content scripts
eval(userInput); // NEVER DO THIS
```

### OAuth Security

```javascript
// ✅ GOOD: Use secure OAuth flow
const authConfig = {
    clientId: process.env.CLIENT_ID, // From secure storage
    redirectUri: chrome.identity.getRedirectURL(),
    responseType: 'code',
    scope: 'api'
};

// ✅ GOOD: Validate OAuth tokens
function validateToken(token) {
    if (!token || token.length < 32) {
        throw new Error('Invalid token');
    }
    return token;
}
```

## Security Checklist

### Apex Security
- [ ] All classes use `with sharing` or document why not
- [ ] CRUD/FLS checks before SOQL/DML
- [ ] User input escaped with `String.escapeSingleQuotes()`
- [ ] Bind variables used instead of dynamic SOQL
- [ ] Sensitive data encrypted (Shield Platform Encryption)
- [ ] No hardcoded credentials or API keys
- [ ] Named Credentials used for external APIs
- [ ] Error messages don't expose sensitive information

### LWC Security
- [ ] User input sanitized before display
- [ ] `{data}` binding used for automatic escaping
- [ ] No `innerHTML` with user data (or sanitized with DOMPurify)
- [ ] Lightning components used instead of raw HTML
- [ ] @AuraEnabled methods check permissions
- [ ] Sensitive data not logged to console

### Browser Extension Security
- [ ] Content scripts use IIFE guard pattern
- [ ] No `eval()` or `Function()` with user input
- [ ] OAuth tokens stored securely
- [ ] Content Security Policy configured
- [ ] User input validated and sanitized
- [ ] HTTPS-only communication

## Security Resources

- [Salesforce Security Guide](https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/)
- [Apex Security Best Practices](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_security_best_practices.htm)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [LWC Security](https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.security)
- [Shield Platform Encryption](https://help.salesforce.com/s/articleView?id=sf.security_pe_overview.htm)
