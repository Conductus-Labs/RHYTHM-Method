# Bug Template

**Work Item Type:** Bug  
**Purpose:** Defect or issue that needs to be fixed  
**Version:** 1.0.0

## Template Structure

### Parented Bug (Development Bug)

```markdown
# Bug: [Bug Title]

**Bug ID:** [bug-id]  
**Version:** [version]  
**Last Updated:** [date]  
**Status:** [status]  
**Relationship:** Parented to [Work Unit ID]

## Bug Overview

**Bug Title:** [Brief title describing the bug]  
**Bug Description:** [Detailed description of the bug]

**Bug Type:**
[Type: code-defect, test-failure, integration-issue, etc.]

**Severity:**
[Severity: critical, high, medium, low]

**Priority:**
[Priority: highest (parented bugs always highest priority)]

## Bug Details

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Environment:**
- [Environment details]

## Context

**Work Unit:** [Work Unit ID] - [Work Unit Name]  
**Feature:** [Feature ID] - [Feature Name]  
**Discovered During:** [Task Execution, Quality Assurance, etc.]

**Related Code:**
- [File 1]: [Line numbers or description]
- [File 2]: [Line numbers or description]

**Related Tests:**
- [Test 1]: [Description]

## Fix

**Root Cause:**
[Analysis of root cause]

**Fix Approach:**
[How the bug will be fixed]

**Fix Status:**
[Status: identified, in-progress, fixed, verified]

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0.0 | [date] | [author] | Bug discovered and reported |
```

### Related Bug (Production Bug)

```markdown
# Bug: [Bug Title]

**Bug ID:** [bug-id]  
**Version:** [version]  
**Last Updated:** [date]  
**Status:** [status]  
**Relationship:** Related to [Feature ID]

## Bug Overview

**Bug Title:** [Brief title describing the bug]  
**Bug Description:** [Detailed description of the bug]

**Bug Type:**
[Type: production-defect, user-reported, security-issue, etc.]

**Severity:**
[Severity: critical, high, medium, low]

**Priority:**
[Priority: based on severity and business impact]

## Bug Details

**Steps to Reproduce:**
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Environment:**
- [Environment details]
- **Production:** [Yes/No]

**User Impact:**
[Description of impact on users]

## Context

**Feature:** [Feature ID] - [Feature Name]  
**Discovered:** [Production, User Report, Testing, etc.]  
**Reported By:** [User/Agent/System]

**Related Work Units:**
- [Work Unit 1]: [Description]
- [Work Unit 2]: [Description]

## Fix Work Unit

**Fix Work Unit:** [Work Unit ID] - [Work Unit Name]  
**Fix Status:** [Status: planned, in-progress, fixed, verified]

**Fix Approach:**
[How the bug will be fixed]

## Change History

| Version | Date | Author | Description |
|---------|------|--------|-------------|
| 1.0.0 | [date] | [author] | Bug discovered and reported |
```

## Required Fields

- Bug Title
- Bug Description
- Bug Type
- Severity
- Steps to Reproduce
- Expected Behavior
- Actual Behavior
- Relationship (Parented or Related)

## Optional Fields

- Priority (for Related bugs)
- Environment
- User Impact
- Root Cause
- Fix Approach

