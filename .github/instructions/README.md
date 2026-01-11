# RecruiterPortal GitHub Copilot Instructions

This directory contains custom instruction files that guide GitHub Copilot to generate better, more context-aware code for the RecruiterPortal project.

## 📋 Available Instructions

### Core Instructions

| File | Description | Applies To |
|------|-------------|------------|
| [apex.instructions.md](apex.instructions.md) | Apex development guidelines, bulkification, governor limits, testing | `**/*.cls`, `**/*.trigger` |
| [lwc.instructions.md](lwc.instructions.md) | Lightning Web Components, SLDS, reactive properties, event handling | `force-app/main/default/lwc/**` |
| [testing.instructions.md](testing.instructions.md) | Apex and Jest testing best practices, coverage requirements | `**/*Test.cls`, `**/*.test.js` |
| [security.instructions.md](security.instructions.md) | OWASP, SOQL injection prevention, CRUD/FLS, XSS protection | `**/*.cls`, `**/*.js`, `force-app/**` |
| [javascript-typescript.instructions.md](javascript-typescript.instructions.md) | Modern JavaScript/TypeScript, async/await, browser extensions | `**/*.js`, `**/*.ts`, `lwc/**`, `chrome-extension-linkedin/**`, `mcp-server/**` |
| [code-review.instructions.md](code-review.instructions.md) | Code review checklist, priority levels, comment format | `**` |

## 🎯 How Instructions Work

GitHub Copilot automatically applies these instructions based on the file patterns specified in each instruction file's frontmatter:

```yaml
---
description: 'Brief description'
applyTo: '**/*.cls, **/*.trigger'  # File patterns
---
```

When you open a file matching the pattern, Copilot uses the relevant instructions to provide better suggestions.

## 🚀 Usage

### During Development

1. **Open a file** - Copilot automatically loads relevant instructions
2. **Start typing** - Get context-aware suggestions
3. **Use comments** - Describe what you want, Copilot generates code following project patterns

Example:
```apex
// Create a method to get candidates by stage with proper security checks
```

Copilot will generate code that:
- Uses `with sharing`
- Checks `isAccessible()`
- Uses `WITH SECURITY_ENFORCED`
- Follows naming conventions
- Includes error handling

### For Code Reviews

Use [code-review.instructions.md](code-review.instructions.md) as a checklist:
- 🔴 Critical issues block merge
- 🟡 Important issues require discussion
- 🟢 Suggestions are optional improvements

### When Writing Tests

[testing.instructions.md](testing.instructions.md) guides you to:
- Create @TestSetup with 200 records
- Test bulk operations
- Use Assert class methods
- Achieve >= 75% Apex, >= 80% Jest coverage

## 📝 Customization

To add a new instruction file:

1. Create `.md` file in this directory
2. Add frontmatter with `description` and `applyTo`
3. Write guidelines in Markdown
4. Commit and push

Example template:

```markdown
---
description: 'Your instruction description'
applyTo: '**/*.yourpattern'
---

# Your Instruction Title

## Guidelines

- Guideline 1
- Guideline 2

## Examples

```code
// Example here
```
```

## 🔗 Related Documentation

- [Main Copilot Instructions](../copilot-instructions.md) - Project overview
- [Cole's Copilot Instructions](../copilot-instructions-cole.md) - Cole-specific guidance
- [Work Coordination](../../WORK_COORDINATION.md) - Collaboration guidelines
- [Shared Planning](../../SHARED_PLANNING.md) - Active tasks
- [Agent Coordination](../../AGENT_COORDINATION.md) - Agent handoff patterns

## 🏗️ Project Patterns

### Apex Patterns
- **Controllers:** `*Controller.cls` - `@AuraEnabled` methods for LWC
- **Services:** `*Service.cls` - Business logic layer
- **Trigger Handlers:** `*TriggerHandler.cls` - One trigger per object
- **Selectors:** `*Selector.cls` - SOQL query layer
- **Tests:** `*Test.cls` - 100% coverage goal

### LWC Patterns
- **Dashboard Components:** `recruiterDashboard`, `contractBPipelineDashboard`
- **Dark Mode:** Subscribe to `DarkModeChannel__c` LMS
- **Auto-Refresh:** Use CDC for real-time updates
- **Jest Tests:** 80%+ coverage required

### Security Patterns
- **Sharing:** `with sharing` by default
- **Permissions:** Check CRUD/FLS before operations
- **Input:** Escape with `String.escapeSingleQuotes()`
- **Queries:** Use bind variables, not dynamic SOQL

## 📊 Metrics

Target code quality metrics:
- ✅ Apex Test Coverage: **75% minimum, 100% goal**
- ✅ Jest Test Coverage: **80% minimum**
- ✅ Code Analyzer: **Severity threshold 2**
- ✅ CRUD/FLS: **100% of SOQL/DML**
- ✅ Bulkification: **All triggers and services**

## 🆘 Getting Help

If instructions aren't working as expected:

1. Check file pattern in `applyTo` matches your file
2. Reload VS Code window
3. Check Copilot status in VS Code
4. Review [GitHub Copilot Docs](https://docs.github.com/en/copilot)

## 🎓 Learning Resources

### Salesforce
- [Apex Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/)
- [LWC Developer Guide](https://developer.salesforce.com/docs/component-library/documentation/en/lwc)
- [Security Best Practices](https://developer.salesforce.com/docs/atlas.en-us.securityImplGuide.meta/securityImplGuide/)

### GitHub Copilot
- [Prompt Engineering](https://docs.github.com/en/copilot/concepts/prompting/prompt-engineering)
- [Custom Instructions](https://code.visualstudio.com/docs/copilot/customization/custom-instructions)
- [Awesome Copilot](https://github.com/github/awesome-copilot)

## 📜 Attribution

These instructions are adapted from [github/awesome-copilot](https://github.com/github/awesome-copilot) and customized for RecruiterPortal's specific requirements.

---

**Last Updated:** 2026-01-08
**Maintained By:** Patrick Baker & Cole Arnold
