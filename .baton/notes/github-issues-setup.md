# GitHub Issues Setup for RHYTHM Method

**Version:** 1.0.0  
**Date:** 2025-11-26  
**Author:** rhythm-expert-agent  
**Status:** For Review by CLI-Agent

## Overview

This document provides a comprehensive specification for how GitHub Issues should be configured to support RHYTHM Method workflows. The setup enables tracking of Features, Work Units, Agent Tasks, and Bugs while maintaining the RHYTHM Method hierarchy and supporting Baton Framework integration.

**Key Principles:**
- GitHub Issues represent RHYTHM Method work items (Features, Work Units, Agent Tasks, Bugs)
- Project Manifest is **NOT** a GitHub Issue (it's a markdown file: `.baton/project.manifest.md`)
- Issues use labels, custom fields, and relationships to maintain RHYTHM Method structure
- Baton Framework integrates with GitHub Issues for automated workflow management
- All communication follows RHYTHM Method message formats (A2A, A2U)

---

## Issue Type Mapping

### RHYTHM Method → GitHub Issues

| RHYTHM Method Work Item | GitHub Issue Type | Notes |
|------------------------|-------------------|-------|
| **Project Manifest** | ❌ **Not an Issue** | Stored as `.baton/project.manifest.md` (markdown file) |
| **Feature** | ✅ **Issue** | Type: `feature` |
| **Work Unit** | ✅ **Issue** | Type: `work-unit` |
| **Agent Task** | ✅ **Issue** | Type: `agent-task` |
| **Bug (Parented)** | ✅ **Issue** | Type: `bug`, Relationship: `parented` |
| **Bug (Related)** | ✅ **Issue** | Type: `bug`, Relationship: `related` |

**Important:** Project Manifest is **never** a GitHub Issue. It's a markdown file that serves as the single source of truth. Features are conceptually parented to the Project Manifest, but this relationship is maintained in the Project Manifest file itself, not through GitHub Issue relationships.

---

## Labels System

### Primary Labels (Required)

**Work Item Type Labels:**
- `rhythm:feature` - Feature work item
- `rhythm:work-unit` - Work Unit work item
- `rhythm:agent-task` - Agent Task work item
- `rhythm:bug` - Bug work item

**Status Labels:**
- `rhythm:status:planned` - Work item is planned but not started
- `rhythm:status:in-progress` - Work item is actively being worked on
- `rhythm:status:review` - Work item is in review (HITL checkpoint)
- `rhythm:status:blocked` - Work item is blocked by dependencies
- `rhythm:status:completed` - Work item is completed
- `rhythm:status:failed` - Work item failed and needs attention

**Priority Labels (for dependency-driven prioritization):**
- `rhythm:priority:level-0` - No dependencies (highest priority)
- `rhythm:priority:level-1` - Depends on Level 0
- `rhythm:priority:level-2` - Depends on Level 1
- `rhythm:priority:level-n` - Depends on Level N-1

**TEMPO Labels:**
- `rhythm:tempo:high` - High TEMPO configuration
- `rhythm:tempo:moderate` - Moderate TEMPO (default)
- `rhythm:tempo:controlled` - Controlled TEMPO

**Bug Relationship Labels:**
- `rhythm:bug:parented` - Bug parented to Work Unit (development bug)
- `rhythm:bug:related` - Bug related to Feature (production bug)

### Secondary Labels (Optional)

**Agent Labels:**
- `rhythm:agent:backend` - Assigned to backend agent
- `rhythm:agent:frontend` - Assigned to frontend agent
- `rhythm:agent:qa` - Assigned to QA agent
- `rhythm:agent:devops` - Assigned to DevOps agent
- `rhythm:agent:rhythm-expert` - Assigned to RHYTHM expert agent

**Dependency Type Labels:**
- `rhythm:dep:technical` - Technical dependency
- `rhythm:dep:data` - Data dependency
- `rhythm:dep:integration` - Integration dependency
- `rhythm:dep:knowledge` - Knowledge dependency

**Quality Labels:**
- `rhythm:quality:gate-passed` - Quality gate passed
- `rhythm:quality:gate-failed` - Quality gate failed
- `rhythm:quality:needs-review` - Needs quality review

**Workflow Stage Labels:**
- `rhythm:stage:specification` - Feature Specification stage
- `rhythm:stage:work-unit-creation` - Work Unit Creation stage
- `rhythm:stage:work-unit-review` - Work Unit Review stage
- `rhythm:stage:work-unit-breakdown` - Work Unit Breakdown stage
- `rhythm:stage:execution` - Task Execution stage
- `rhythm:stage:quality-assurance` - Quality Assurance stage

---

## Issue Templates

### Feature Issue Template

**File:** `.github/ISSUE_TEMPLATE/feature.yml`

```yaml
name: Feature
description: Create a new Feature for RHYTHM Method
title: "[Feature] "
labels: ["rhythm:feature", "rhythm:status:planned"]
body:
  - type: markdown
    attributes:
      value: |
        ## Feature Specification
        
        This template creates a Feature work item in RHYTHM Method.
        Features are deliverable units of functionality that provide business value.
        
  - type: input
    id: feature-name
    attributes:
      label: Feature Name
      description: Brief, descriptive name for the feature
      placeholder: "User Authentication System"
    validations:
      required: true
      
  - type: textarea
    id: feature-description
    attributes:
      label: Feature Description
      description: Detailed description of what this feature accomplishes
      placeholder: |
        Complete user authentication system with login, registration, and password reset.
        Enables user accounts and personalized experience.
    validations:
      required: true
      
  - type: textarea
    id: business-value
    attributes:
      label: Business Value
      description: Why this feature is valuable to the business
      placeholder: |
        Enables user accounts and personalized experience.
        Required for user engagement and retention.
    validations:
      required: true
      
  - type: textarea
    id: user-value
    attributes:
      label: User Value
      description: Value this feature provides to end users
      placeholder: "Users can create accounts, login securely, and manage their profiles"
    validations:
      required: false
      
  - type: textarea
    id: functional-requirements
    attributes:
      label: Functional Requirements
      description: List of functional requirements (one per line)
      placeholder: |
        - Users can register with email and password
        - Users can login with credentials
        - Users can reset forgotten passwords
        - JWT tokens are generated and validated
    validations:
      required: true
      
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      description: Criteria that must be met for feature completion (one per line)
      placeholder: |
        - [ ] All Work Units completed
        - [ ] All validation criteria met
        - [ ] Quality gates passed
        - [ ] Deployed to production
        - [ ] Documentation complete
    validations:
      required: true
      
  - type: textarea
    id: dependencies
    attributes:
      label: Dependencies
      description: List dependencies on other Features or Work Units (format: #issue-number - description)
      placeholder: |
        - None (Level 0 - no dependencies)
        - Or: #123 - Database schema must be created first
    validations:
      required: false
      
  - type: input
    id: estimated-tokens
    attributes:
      label: Estimated Tokens
      description: Estimated total tokens for this feature (will be calculated from Work Units)
      placeholder: "5000"
    validations:
      required: false
      
  - type: dropdown
    id: tempo-level
    attributes:
      label: TEMPO Level
      description: TEMPO level for this feature
      options:
        - High TEMPO
        - Moderate TEMPO (Default)
        - Controlled TEMPO
      default: 1
    validations:
      required: true
```

**Example Feature Issue:**

```markdown
# Feature: User Authentication System

**Feature ID:** feat-001  
**Status:** rhythm:status:planned  
**TEMPO:** rhythm:tempo:moderate  
**Priority Level:** rhythm:priority:level-0

## Feature Description

Complete user authentication system with login, registration, and password reset. Enables user accounts and personalized experience.

## Business Value

Enables user accounts and personalized experience. Required for user engagement and retention. Foundation for all user-specific features.

## User Value

Users can create accounts, login securely, and manage their profiles. Provides secure access to personalized features.

## Functional Requirements

- Users can register with email and password
- Users can login with credentials
- Users can reset forgotten passwords
- JWT tokens are generated and validated
- Password strength requirements enforced
- Rate limiting on authentication endpoints

## Acceptance Criteria

- [ ] All Work Units completed
- [ ] All validation criteria met
- [ ] Quality gates passed
- [ ] Deployed to production
- [ ] Documentation complete
- [ ] Security audit passed

## Work Units

**Total:** 0  
**Completed:** 0  
**In Progress:** 0  
**Planned:** 0

_Work Units will be created and linked here during Work Unit Creation workflow._

## Dependencies

**Dependencies On:**
- None (Level 0 - no dependencies)

**Dependencies From:**
- #45 - User Profile Feature (depends on this Feature)

## Estimation

**Estimated Tokens:** 5000 (calculated from Work Units)  
**Estimated Duration:** 2-3 execution cycles  
**Estimated Execution Cycles:** 2-3

## Related Issues

- Work Units: _Will be linked when created_
- Related Bugs: _None yet_

---

**Created:** 2025-11-26  
**Last Updated:** 2025-11-26
```

### Work Unit Issue Template

**File:** `.github/ISSUE_TEMPLATE/work-unit.yml`

```yaml
name: Work Unit
description: Create a new Work Unit for RHYTHM Method
title: "[Work Unit] "
labels: ["rhythm:work-unit", "rhythm:status:planned"]
body:
  - type: markdown
    attributes:
      value: |
        ## Work Unit Specification
        
        This template creates a Work Unit work item in RHYTHM Method.
        Work Units are specific pieces of work completed in a single execution cycle (up to 8 hours).
        
  - type: input
    id: work-unit-name
    attributes:
      label: Work Unit Name
      description: Brief, descriptive name for the work unit
      placeholder: "User Login API Endpoint"
    validations:
      required: true
      
  - type: input
    id: parent-feature
    attributes:
      label: Parent Feature
      description: Link to parent Feature issue (format: #issue-number)
      placeholder: "#123"
    validations:
      required: true
      
  - type: textarea
    id: work-unit-description
    attributes:
      label: Work Unit Description
      description: Brief description of what this work unit accomplishes
      placeholder: "Implement POST /api/auth/login endpoint with JWT token generation"
    validations:
      required: true
      
  - type: textarea
    id: specification
    attributes:
      label: Detailed Specification
      description: Detailed specification of what needs to be done
      placeholder: |
        Create POST /api/auth/login endpoint that:
        - Accepts email and password in request body
        - Validates credentials against user database
        - Generates JWT token on successful authentication
        - Returns 401 on invalid credentials
        - Includes rate limiting (10 requests per minute)
    validations:
      required: true
      
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      description: Criteria that must be met for work unit completion (one per line)
      placeholder: |
        - [ ] Endpoint accepts email and password
        - [ ] Returns JWT token on success
        - [ ] Returns 401 on invalid credentials
        - [ ] Includes rate limiting
        - [ ] Unit tests written and passing
    validations:
      required: true
      
  - type: textarea
    id: dependencies
    attributes:
      label: Dependencies
      description: List dependencies on other Work Units or Agent Tasks (format: #issue-number - description)
      placeholder: |
        - None
        - Or: #124 - User model must be created first
    validations:
      required: false
      
  - type: input
    id: estimated-tokens
    attributes:
      label: Estimated Tokens
      description: Estimated total tokens for this work unit
      placeholder: "2000"
    validations:
      required: false
      
  - type: input
    id: estimated-duration
    attributes:
      label: Estimated Duration
      description: Estimated duration in hours (target: up to 8 hours)
      placeholder: "4-6 hours"
    validations:
      required: false
```

**Example Work Unit Issue:**

```markdown
# Work Unit: User Login API Endpoint

**Work Unit ID:** wu-001  
**Parent Feature:** #45 (User Authentication System)  
**Status:** rhythm:status:in-progress  
**Priority Level:** rhythm:priority:level-0  
**TEMPO:** rhythm:tempo:moderate

## Work Unit Description

Implement POST /api/auth/login endpoint with JWT token generation and rate limiting.

## Purpose

Create the core authentication endpoint that allows users to login and receive JWT tokens for authenticated requests.

## Detailed Specification

Create POST /api/auth/login endpoint that:
- Accepts email and password in request body (JSON)
- Validates credentials against user database
- Generates JWT token on successful authentication
- Returns JWT token in response (expires in 24 hours)
- Returns 401 Unauthorized on invalid credentials
- Includes rate limiting (10 requests per minute per IP)
- Logs authentication attempts (success and failure)

## Technical Approach

- Use Express.js for endpoint implementation
- Use bcrypt for password verification
- Use jsonwebtoken library for JWT generation
- Use express-rate-limit for rate limiting
- Store JWT secret in environment variables

## Acceptance Criteria

- [ ] Endpoint accepts email and password
- [ ] Returns JWT token on success (status 200)
- [ ] Returns 401 on invalid credentials
- [ ] Includes rate limiting (10 req/min)
- [ ] Unit tests written and passing
- [ ] Integration tests written and passing
- [ ] API documentation updated
- [ ] Code reviewed and approved

## Agent Tasks

**Total:** 5  
**Completed:** 2  
**In Progress:** 1  
**Planned:** 2

- #201 - Create login endpoint handler (Completed)
- #202 - Implement JWT token generation (Completed)
- #203 - Add input validation (In Progress)
- #204 - Write unit tests (Planned)
- #205 - Add API documentation (Planned)

## Dependencies

**Dependencies On:**
- None (Level 0 - no dependencies)

**Dependencies From:**
- #206 - User Profile Frontend (depends on this Work Unit)

## Estimation

**Estimated Tokens:** 2000
- Code Tokens: 1200
- Analysis Tokens: 300
- Documentation Tokens: 300
- Validation Tokens: 200

**Estimated Duration:** 4-6 hours (target: up to 8 hours)  
**Actual Duration:** _Will be tracked during execution_

## Quality Gates

**Required Quality Gates:**
- [x] Code quality checks (passed)
- [ ] Unit tests (pending)
- [ ] Integration tests (pending)
- [ ] Security scan (pending)

## Related Issues

- Parent Feature: #45 (User Authentication System)
- Agent Tasks: #201, #202, #203, #204, #205
- Parented Bugs: _None yet_

---

**Created:** 2025-11-26  
**Last Updated:** 2025-11-26 14:30
```

### Agent Task Issue Template

**File:** `.github/ISSUE_TEMPLATE/agent-task.yml`

```yaml
name: Agent Task
description: Create a new Agent Task for RHYTHM Method
title: "[Agent Task] "
labels: ["rhythm:agent-task", "rhythm:status:planned"]
body:
  - type: markdown
    attributes:
      value: |
        ## Agent Task Specification
        
        This template creates an Agent Task work item in RHYTHM Method.
        Agent Tasks are the smallest unit of executable work (typically 30 minutes to 2 hours).
        
  - type: input
    id: task-name
    attributes:
      label: Task Name
      description: Brief, descriptive name for the task
      placeholder: "Create login endpoint handler"
    validations:
      required: true
      
  - type: input
    id: parent-work-unit
    attributes:
      label: Parent Work Unit
      description: Link to parent Work Unit issue (format: #issue-number)
      placeholder: "#123"
    validations:
      required: true
      
  - type: dropdown
    id: assigned-agent
    attributes:
      label: Assigned Agent
      description: Agent type assigned to this task
      options:
        - backend-agent
        - frontend-agent
        - qa-agent
        - devops-agent
        - rhythm-expert-agent
      default: 0
    validations:
      required: true
      
  - type: textarea
    id: task-description
    attributes:
      label: Task Description
      description: Brief description of what this task accomplishes
      placeholder: "Create Express.js route handler for POST /api/auth/login endpoint"
    validations:
      required: true
      
  - type: textarea
    id: specification
    attributes:
      label: Detailed Specification
      description: Detailed specification of what needs to be done
      placeholder: |
        Create Express.js route handler that:
        - Accepts POST requests to /api/auth/login
        - Parses email and password from request body
        - Validates request body format
        - Returns appropriate error responses for invalid input
    validations:
      required: true
      
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance Criteria
      description: Criteria that must be met for task completion (one per line)
      placeholder: |
        - [ ] Route handler created
        - [ ] Request body parsing implemented
        - [ ] Input validation implemented
        - [ ] Error handling implemented
    validations:
      required: true
      
  - type: textarea
    id: files-to-modify
    attributes:
      label: Files to Modify
      description: List of files that need to be modified (one per line)
      placeholder: |
        - src/routes/auth.ts (add login route)
        - src/middleware/validation.ts (add login validation)
    validations:
      required: false
      
  - type: textarea
    id: files-to-create
    attributes:
      label: Files to Create
      description: List of files that need to be created (one per line)
      placeholder: |
        - src/controllers/authController.ts (new file)
    validations:
      required: false
      
  - type: textarea
    id: dependencies
    attributes:
      label: Dependencies
      description: List dependencies on other Agent Tasks (format: #issue-number - description)
      placeholder: |
        - None
        - Or: #201 - User model must exist first
    validations:
      required: false
      
  - type: input
    id: estimated-tokens
    attributes:
      label: Estimated Tokens
      description: Estimated total tokens for this task
      placeholder: "500"
    validations:
      required: false
```

**Example Agent Task Issue:**

```markdown
# Agent Task: Create login endpoint handler

**Task ID:** task-001  
**Parent Work Unit:** #46 (User Login API Endpoint)  
**Assigned Agent:** backend-agent  
**Status:** rhythm:status:completed  
**Priority Level:** rhythm:priority:level-0

## Task Description

Create Express.js route handler for POST /api/auth/login endpoint with request parsing and validation.

## Task Type

Code implementation

## Detailed Specification

Create Express.js route handler that:
- Accepts POST requests to /api/auth/login
- Parses email and password from request body (JSON)
- Validates request body format (email format, password presence)
- Returns 400 Bad Request for invalid input format
- Returns appropriate error messages for validation failures
- Sets up structure for authentication logic (to be implemented in next task)

## Implementation Details

- Use Express.js Router for route definition
- Use express-validator for input validation
- Use TypeScript for type safety
- Follow existing code patterns in the codebase

## Files to Modify

- `src/routes/auth.ts` - Add login route handler
- `src/middleware/validation.ts` - Add login validation middleware

## Files to Create

- `src/controllers/authController.ts` - New controller file (structure only)

## Acceptance Criteria

- [x] Route handler created at POST /api/auth/login
- [x] Request body parsing implemented
- [x] Input validation implemented (email format, password presence)
- [x] Error handling implemented (400 for invalid input)
- [x] Code follows project standards
- [x] TypeScript types defined

## Dependencies

**Dependencies On:**
- None (Level 0 - no dependencies)

**Dependencies From:**
- #202 - Implement JWT token generation (depends on this task)

## Estimation

**Estimated Tokens:** 500
- Code Tokens: 300
- Analysis Tokens: 100
- Documentation Tokens: 50
- Validation Tokens: 50

**Estimated Duration:** 1-2 hours  
**Actual Duration:** 1.5 hours

## Context

**Related Files:**
- `src/routes/auth.ts` - Route definitions
- `src/middleware/validation.ts` - Validation middleware
- `src/models/user.ts` - User model (referenced)

**Related Specifications:**
- Work Unit #46 - User Login API Endpoint

## Related Issues

- Parent Work Unit: #46 (User Login API Endpoint)
- Dependent Task: #202 (Implement JWT token generation)

---

**Created:** 2025-11-26 10:00  
**Completed:** 2025-11-26 11:30  
**Last Updated:** 2025-11-26 11:30
```

### Bug Issue Template

**File:** `.github/ISSUE_TEMPLATE/bug.yml`

```yaml
name: Bug
description: Report a bug in RHYTHM Method
title: "[Bug] "
labels: ["rhythm:bug", "rhythm:status:planned"]
body:
  - type: markdown
    attributes:
      value: |
        ## Bug Report
        
        This template creates a Bug work item in RHYTHM Method.
        Bugs must be either parented to a Work Unit (development bugs) or related to a Feature (production bugs).
        
  - type: dropdown
    id: bug-relationship
    attributes:
      label: Bug Relationship
      description: How is this bug related to work items?
      options:
        - Parented to Work Unit (found during development)
        - Related to Feature (found in production/after completion)
      default: 0
    validations:
      required: true
      
  - type: input
    id: parent-work-unit
    attributes:
      label: Parent Work Unit (if parented)
      description: Link to Work Unit where bug was found (format: #issue-number)
      placeholder: "#123"
    validations:
      required: false
      
  - type: input
    id: related-feature
    attributes:
      label: Related Feature (if related)
      description: Link to Feature where bug occurs (format: #issue-number)
      placeholder: "#45"
    validations:
      required: false
      
  - type: input
    id: bug-title
    attributes:
      label: Bug Title
      description: Brief description of the bug
      placeholder: "Login endpoint returns 500 error for valid credentials"
    validations:
      required: true
      
  - type: textarea
    id: bug-description
    attributes:
      label: Bug Description
      description: Detailed description of the bug
      placeholder: "When providing valid email and password, the login endpoint returns 500 Internal Server Error instead of 200 with JWT token"
    validations:
      required: true
      
  - type: dropdown
    id: severity
    attributes:
      label: Severity
      description: Bug severity level
      options:
        - Critical (system down, data loss)
        - High (major functionality broken)
        - Medium (minor functionality issues)
        - Low (cosmetic, minor issues)
      default: 2
    validations:
      required: true
      
  - type: textarea
    id: steps-to-reproduce
    attributes:
      label: Steps to Reproduce
      description: Steps to reproduce the bug (one per line)
      placeholder: |
        1. Send POST request to /api/auth/login
        2. Provide valid email: user@example.com
        3. Provide valid password: Password123!
        4. Observe 500 error response
    validations:
      required: true
      
  - type: textarea
    id: expected-behavior
    attributes:
      label: Expected Behavior
      description: What should happen
      placeholder: "Should return 200 OK with JWT token in response body"
    validations:
      required: true
      
  - type: textarea
    id: actual-behavior
    attributes:
      label: Actual Behavior
      description: What actually happens
      placeholder: "Returns 500 Internal Server Error with error message in response"
    validations:
      required: true
      
  - type: textarea
    id: environment
    attributes:
      label: Environment
      description: Environment where bug was found
      placeholder: |
        - Environment: Development
        - Browser/Client: Postman
        - Server: Node.js v18.0.0
        - Database: PostgreSQL 14.0
    validations:
      required: false
```

**Example Parented Bug (Development Bug):**

```markdown
# Bug: Login endpoint returns 500 error for valid credentials

**Bug ID:** bug-001  
**Relationship:** Parented to #46 (User Login API Endpoint)  
**Status:** rhythm:status:completed  
**Priority:** Highest (parented bugs always highest priority)  
**Severity:** High

## Bug Description

When providing valid email and password, the login endpoint returns 500 Internal Server Error instead of 200 OK with JWT token.

## Bug Type

Code defect

## Steps to Reproduce

1. Send POST request to /api/auth/login
2. Provide valid email: user@example.com
3. Provide valid password: Password123!
4. Observe 500 error response

## Expected Behavior

Should return 200 OK with JWT token in response body:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 86400
}
```

## Actual Behavior

Returns 500 Internal Server Error:
```json
{
  "error": "Internal Server Error",
  "message": "Cannot read property 'id' of undefined"
}
```

## Environment

- Environment: Development
- Work Unit: #46 (User Login API Endpoint)
- Feature: #45 (User Authentication System)
- Discovered During: Task Execution (Agent Task #201)

## Root Cause

JWT token generation attempts to access `user.id` but user object is undefined due to missing database query result handling.

## Fix

**Fix Approach:**
- Added null check for user object before JWT generation
- Added proper error handling for database query failures
- Added validation to ensure user exists before token generation

**Fix Status:** Fixed and verified

## Related Code

- `src/controllers/authController.ts` - Line 45-50 (JWT generation)
- `src/services/authService.ts` - Line 30-35 (User lookup)

## Related Issues

- Parent Work Unit: #46 (User Login API Endpoint)
- Fixed in: Agent Task #201 (same task where bug was found)

---

**Created:** 2025-11-26 11:00  
**Fixed:** 2025-11-26 11:45  
**Verified:** 2025-11-26 12:00
```

**Example Related Bug (Production Bug):**

```markdown
# Bug: Password reset email not sent in production

**Bug ID:** bug-002  
**Relationship:** Related to #45 (User Authentication System)  
**Status:** rhythm:status:planned  
**Priority:** High (based on severity)  
**Severity:** High

## Bug Description

Users report that password reset emails are not being sent when requesting password reset in production environment.

## Bug Type

Production defect

## Steps to Reproduce

1. Navigate to password reset page
2. Enter registered email address
3. Click "Send Reset Link"
4. Check email inbox (no email received)

## Expected Behavior

Should receive password reset email within 2 minutes with reset link.

## Actual Behavior

No email is received. No error message is shown to user.

## Environment

- Environment: Production
- Feature: #45 (User Authentication System)
- Discovered: User report
- Reported By: User (user@example.com)

## User Impact

Users cannot reset forgotten passwords, requiring manual intervention from support team.

## Fix Work Unit

**Fix Work Unit:** #47 (Fix password reset email delivery)  
**Fix Status:** Planned

**Fix Approach:**
- Investigate email service configuration
- Verify SMTP credentials
- Test email delivery in staging
- Fix configuration and deploy

## Related Issues

- Related Feature: #45 (User Authentication System)
- Fix Work Unit: #47 (Fix password reset email delivery)

---

**Created:** 2025-11-26 15:00  
**Reported By:** User  
**Fix Work Unit:** #47 (Planned)
```

---

## Custom Fields and Metadata

### Using GitHub Issue Forms and Metadata

GitHub Issues don't support custom fields directly, but we can use:

1. **Issue Body Structure** - Structured markdown sections in issue body
2. **Labels** - For categorization and filtering
3. **Milestones** - For grouping (optional, can represent Features)
4. **Projects** - For kanban-style boards (optional)
5. **Comments** - For status updates and HITL checkpoints

### Required Metadata in Issue Body

Each issue type should include structured metadata in the body:

**Feature Issues:**
```markdown
<!-- RHYTHM Method Metadata -->
**Feature ID:** feat-001
**Parent:** Project Manifest (.baton/project.manifest.md)
**Status:** planned|in-progress|review|blocked|completed|failed
**TEMPO:** high|moderate|controlled
**Priority Level:** level-0|level-1|level-2|level-n
**Estimated Tokens:** [number]
**Actual Tokens:** [number] (updated during execution)
**Work Units:** [count] (linked issues)
```

**Work Unit Issues:**
```markdown
<!-- RHYTHM Method Metadata -->
**Work Unit ID:** wu-001
**Parent Feature:** #45
**Status:** planned|in-progress|review|blocked|completed|failed
**Priority Level:** level-0|level-1|level-2|level-n
**Estimated Tokens:** [number]
**Actual Tokens:** [number] (updated during execution)
**Estimated Duration:** [hours] (target: up to 8 hours)
**Actual Duration:** [hours] (tracked during execution)
**Agent Tasks:** [count] (linked issues)
**Dependencies:** [list of #issue-numbers]
```

**Agent Task Issues:**
```markdown
<!-- RHYTHM Method Metadata -->
**Task ID:** task-001
**Parent Work Unit:** #46
**Assigned Agent:** backend-agent|frontend-agent|qa-agent|devops-agent|rhythm-expert-agent
**Status:** planned|in-progress|review|blocked|completed|failed
**Priority Level:** level-0|level-1|level-2|level-n
**Estimated Tokens:** [number]
**Actual Tokens:** [number] (updated during execution)
**Estimated Duration:** [hours] (typically 30 minutes to 2 hours)
**Actual Duration:** [hours] (tracked during execution)
**Dependencies:** [list of #issue-numbers]
```

**Bug Issues:**
```markdown
<!-- RHYTHM Method Metadata -->
**Bug ID:** bug-001
**Relationship:** parented|related
**Parent Work Unit:** #46 (if parented)
**Related Feature:** #45 (if related)
**Status:** planned|in-progress|review|blocked|completed|failed
**Priority:** highest|high|normal|low (parented bugs always highest)
**Severity:** critical|high|medium|low
**Fix Work Unit:** #47 (if related bug, requires new Work Unit)
```

---

## Issue Relationships and Linking

### Parent-Child Relationships

**GitHub Limitations:**
- GitHub Issues don't have native parent-child relationships
- We use issue linking and labels to maintain relationships

**Implementation:**

1. **Feature → Work Unit:**
   - Work Unit issue body includes: `**Parent Feature:** #45`
   - Feature issue body lists Work Units: `- #46 - User Login API Endpoint`
   - Use `rhythm:feature` and `rhythm:work-unit` labels for filtering

2. **Work Unit → Agent Task:**
   - Agent Task issue body includes: `**Parent Work Unit:** #46`
   - Work Unit issue body lists Agent Tasks: `- #201 - Create login endpoint handler`
   - Use `rhythm:work-unit` and `rhythm:agent-task` labels for filtering

3. **Bug Relationships:**
   - Parented Bug: `**Parent Work Unit:** #46` + `rhythm:bug:parented` label
   - Related Bug: `**Related Feature:** #45` + `rhythm:bug:related` label

### Dependency Tracking

**Implementation:**

1. **In Issue Body:**
   ```markdown
   ## Dependencies
   
   **Dependencies On:**
   - #46 - User Login API Endpoint (must be completed first)
   - #47 - User Profile API (must be completed first)
   
   **Dependencies From:**
   - #48 - User Profile Frontend (depends on this Work Unit)
   ```

2. **Using GitHub Issue Linking:**
   - Use `Depends on #46` or `Blocked by #46` syntax (GitHub auto-links)
   - GitHub will show "Linked Issues" section

3. **Using Labels for Dependency Levels:**
   - `rhythm:priority:level-0` - No dependencies
   - `rhythm:priority:level-1` - Depends on Level 0
   - `rhythm:priority:level-2` - Depends on Level 1
   - etc.

**Example Dependency Chain:**

```
#45 (Feature) - Level 0
  └─ #46 (Work Unit) - Level 0
      └─ #201 (Agent Task) - Level 0
      └─ #202 (Agent Task) - Level 1 (depends on #201)
  └─ #47 (Work Unit) - Level 1 (depends on #46)
      └─ #203 (Agent Task) - Level 0
```

---

## Work Queue Management

### Work Queue as GitHub Issues

**Implementation:**

1. **Work Queue = Filtered Issue List:**
   - Filter: `is:open label:rhythm:agent-task label:rhythm:priority:level-0`
   - This shows all ready Agent Tasks (no dependencies)

2. **Priority Ordering:**
   - Sort by dependency level (level-0 first)
   - Within same level, sort by business value (manual or custom field)
   - GitHub doesn't support custom sorting, so use labels or manual ordering

3. **Queue Status:**
   - `rhythm:status:planned` - In queue, ready to execute
   - `rhythm:status:in-progress` - Currently executing
   - `rhythm:status:blocked` - Blocked by dependencies
   - `rhythm:status:review` - In HITL review

### Baton Framework Integration

**Baton Framework manages the work queue:**
- Reads GitHub Issues via API
- Filters by dependency level and status
- Orders by priority (dependency level + business value)
- Assigns tasks to agents
- Updates issue status automatically

**GitHub Issues serve as:**
- Storage for work item data
- Visibility for humans
- Integration point for Baton Framework

---

## HITL Checkpoints and Approvals

### HITL Checkpoints as Issue Comments

**Implementation:**

1. **Feature Specification Approval:**
   - Agent creates Feature issue with `rhythm:status:review` label
   - Agent adds comment: `@user-username Please review and approve Feature specification`
   - User reviews and comments: `✅ Approved` or `❌ Request changes: [reason]`
   - Agent updates status based on response

2. **Work Unit Review:**
   - Agent creates Work Unit issue with `rhythm:status:review` label
   - Agent adds comment with review request (using A2U message format)
   - User reviews and comments approval or feedback
   - Agent updates status and addresses feedback

3. **Work Unit Breakdown Approval:**
   - Agent adds comment listing all Agent Tasks
   - User reviews task breakdown and comments approval
   - Agent creates Agent Task issues and links them

4. **Execution Cycle Approval:**
   - Agent adds comment: `Ready to execute Work Unit #46. Estimated duration: 4-6 hours.`
   - User comments approval
   - Agent updates status to `rhythm:status:in-progress`

5. **Deployment Approval:**
   - Agent adds comment: `Ready to deploy Feature #45 to production. [deployment details]`
   - User reviews and comments approval
   - Agent proceeds with deployment

### HITL Comment Format

**Standard Format:**
```markdown
## HITL Checkpoint: [Checkpoint Name]

**Request Type:** [approval|review|notification]
**Priority:** [immediate|high|normal|low]
**Requires Response By:** [date/time]

[Request details using A2U message format]

**Options:**
- ✅ Approve
- ❌ Request Changes: [reason]
- ⏸️ Defer: [reason]
```

**Example:**
```markdown
## HITL Checkpoint: Feature Specification Approval

**Request Type:** approval
**Priority:** high
**Requires Response By:** 2025-11-26 16:00

**Feature:** User Authentication System (#45)

**Specification:** [link to specification]

**Business Value:** Enables user accounts and personalized experience.

**Validation Criteria:**
- Users can register with email and password
- Users can login with credentials
- Users can reset forgotten passwords
- JWT tokens are generated and validated

**Options:**
- ✅ Approve
- ❌ Request Changes: [reason]
- ⏸️ Defer: [reason]

@project-owner Please review and approve.
```

---

## Status Workflow

### Status Transitions

**Feature Status Flow:**
```
planned → in-progress → review → completed
                ↓
            blocked (if dependencies unresolved)
                ↓
            failed (if cannot be completed)
```

**Work Unit Status Flow:**
```
planned → review (Work Unit Review) → in-progress → review (Quality Assurance) → completed
                ↓
            blocked (if dependencies unresolved)
                ↓
            failed (if cannot be completed)
```

**Agent Task Status Flow:**
```
planned → in-progress → review (if needed) → completed
                ↓
            blocked (if dependencies unresolved)
                ↓
            failed (if cannot be completed)
```

**Bug Status Flow:**
```
planned → in-progress → completed (fixed and verified)
                ↓
            blocked (if cannot be fixed)
```

### Status Labels

- `rhythm:status:planned` - Work item is planned
- `rhythm:status:in-progress` - Work item is actively being worked on
- `rhythm:status:review` - Work item is in review (HITL checkpoint)
- `rhythm:status:blocked` - Work item is blocked by dependencies
- `rhythm:status:completed` - Work item is completed
- `rhythm:status:failed` - Work item failed and needs attention

---

## Estimation and Token Tracking

### Token Storage in Issues

**Implementation:**

1. **Estimated Tokens:**
   - Stored in issue body: `**Estimated Tokens:** 2000`
   - Breakdown: `- Code Tokens: 1200`, `- Analysis Tokens: 300`, etc.

2. **Actual Tokens:**
   - Updated during execution: `**Actual Tokens:** 1850` (updated by Baton Framework)
   - Used for historical learning and estimation improvement

3. **Token Breakdown:**
   ```markdown
   ## Estimation
   
   **Estimated Tokens:** 2000
   - Code Tokens: 1200
   - Analysis Tokens: 300
   - Documentation Tokens: 300
   - Validation Tokens: 200
   
   **Actual Tokens:** 1850 (updated 2025-11-26 14:30)
   - Code Tokens: 1100
   - Analysis Tokens: 280
   - Documentation Tokens: 300
   - Validation Tokens: 170
   ```

### Token Roll-Up

**Work Unit Tokens:**
- Rolled up from Agent Tasks: Sum of all Agent Task tokens in Work Unit

**Feature Tokens:**
- Rolled up from Work Units: Sum of all Work Unit tokens in Feature

**Project Manifest Tokens:**
- Rolled up from Features: Sum of all Feature tokens (stored in `.baton/project.manifest.md`)

**Baton Framework:**
- Automatically calculates roll-ups
- Updates parent issues when child issues are updated
- Maintains token totals in issue bodies

---

## Automation and Workflows

### GitHub Actions for RHYTHM Method

**Recommended Actions:**

1. **Issue Creation Automation:**
   - Validate issue template completeness
   - Auto-assign labels based on issue type
   - Set default status to `rhythm:status:planned`
   - Link to parent issue if specified

2. **Dependency Detection:**
   - Parse dependencies from issue body
   - Update dependency level labels
   - Update priority labels based on dependency level
   - Notify when dependencies are resolved

3. **Status Updates:**
   - Update status labels based on workflow stage
   - Notify when work items are blocked
   - Update parent issue when child issues change status

4. **Token Tracking:**
   - Parse token estimates from issue body
   - Calculate roll-ups for parent issues
   - Update parent issue bodies with rolled-up tokens

5. **HITL Notifications:**
   - Notify users when HITL checkpoints are reached
   - Remind users of pending approvals
   - Escalate if approvals are delayed

### Baton Framework Integration

**Baton Framework:**
- Reads GitHub Issues via GitHub API
- Creates/updates issues based on RHYTHM Method workflows
- Manages work queue and task assignment
- Tracks token usage and updates estimates
- Handles HITL checkpoints and approvals
- Maintains dependency graph

**GitHub Issues:**
- Serve as storage and visibility layer
- Provide human-readable work item tracking
- Enable manual intervention when needed
- Support Baton Framework automation

---

## Project Organization

### GitHub Projects (Optional)

**Kanban Board Setup:**

**Columns:**
1. **Backlog** - `rhythm:status:planned`
2. **In Progress** - `rhythm:status:in-progress`
3. **Review** - `rhythm:status:review`
4. **Blocked** - `rhythm:status:blocked`
5. **Completed** - `rhythm:status:completed`

**Filters:**
- By Work Item Type: Feature, Work Unit, Agent Task, Bug
- By Priority Level: Level 0, Level 1, Level 2, etc.
- By TEMPO: High, Moderate, Controlled
- By Agent: Backend, Frontend, QA, DevOps

### Milestones (Optional)

**Usage:**
- Can represent Features (one milestone per feature)
- Can represent execution cycles (one milestone per cycle)
- Can represent releases (one milestone per release)

**Recommendation:** Use sparingly. RHYTHM Method doesn't require milestones, but they can be useful for grouping.

---

## Examples: Complete Workflow

### Example 1: Feature Creation to Completion

**Step 1: Create Feature Issue**

```markdown
# Feature: User Authentication System

**Feature ID:** feat-001
**Status:** rhythm:status:planned
**TEMPO:** rhythm:tempo:moderate
**Priority Level:** rhythm:priority:level-0

[Feature specification details...]

## Work Units

**Total:** 0
**Completed:** 0
**In Progress:** 0
**Planned:** 0

_Work Units will be created during Work Unit Creation workflow._
```

**Step 2: Work Unit Creation**

Agent creates Work Unit issues:
- #46 - User Login API Endpoint
- #47 - User Registration API
- #48 - Password Reset API

Agent updates Feature issue:
```markdown
## Work Units

**Total:** 3
**Completed:** 0
**In Progress:** 0
**Planned:** 3

- #46 - User Login API Endpoint (planned)
- #47 - User Registration API (planned)
- #48 - Password Reset API (planned)
```

**Step 3: Work Unit Review**

Agent adds comment to Work Unit #46:
```markdown
## HITL Checkpoint: Work Unit Review

**Request Type:** review
**Priority:** normal

**Work Unit:** User Login API Endpoint (#46)

[Review request details...]

@project-owner Please review Work Unit specification.
```

User reviews and comments:
```markdown
✅ Approved. Proceed with breakdown.
```

Agent updates Work Unit status to approved.

**Step 4: Work Unit Breakdown**

Agent creates Agent Task issues:
- #201 - Create login endpoint handler
- #202 - Implement JWT token generation
- #203 - Add input validation
- #204 - Write unit tests
- #205 - Add API documentation

Agent updates Work Unit issue:
```markdown
## Agent Tasks

**Total:** 5
**Completed:** 0
**In Progress:** 0
**Planned:** 5

- #201 - Create login endpoint handler (planned)
- #202 - Implement JWT token generation (planned)
- #203 - Add input validation (planned)
- #204 - Write unit tests (planned)
- #205 - Add API documentation (planned)
```

**Step 5: Execution**

Agent updates Agent Task #201 status to `rhythm:status:in-progress`.

Agent completes task and updates:
- Status: `rhythm:status:completed`
- Actual Tokens: 450 (updated from estimated 500)
- Actual Duration: 1.5 hours

Agent updates Work Unit #46:
- Agent Tasks Completed: 1/5
- Actual Tokens: 450 (rolled up from tasks)

**Step 6: Quality Assurance**

All Agent Tasks complete. Agent runs quality gates.

Agent adds comment:
```markdown
## Quality Gate Results

**Work Unit:** #46 - User Login API Endpoint

**Quality Gates:**
- ✅ Code quality checks (passed)
- ✅ Unit tests (all passing)
- ✅ Integration tests (all passing)
- ✅ Security scan (passed)

**Status:** All quality gates passed. Ready for deployment approval.
```

**Step 7: Deployment Approval**

Agent adds comment:
```markdown
## HITL Checkpoint: Deployment Approval

**Request Type:** approval
**Priority:** high

**Feature:** User Authentication System (#45)
**Work Unit:** User Login API Endpoint (#46)

**Deployment Details:**
- Environment: Production
- Changes: New POST /api/auth/login endpoint
- Quality Gates: All passed
- Rollback Plan: [link to rollback plan]

**Options:**
- ✅ Approve Deployment
- ❌ Request Changes
- ⏸️ Defer

@project-owner Please approve production deployment.
```

User approves. Agent deploys and updates Feature issue:
- Work Units Completed: 1/3
- Status: `rhythm:status:in-progress` (other Work Units still in progress)

**Step 8: Completion**

All Work Units complete. Agent updates Feature issue:
- Status: `rhythm:status:completed`
- All Work Units: Completed
- All Acceptance Criteria: Met
- Deployed to Production: Yes

---

## Integration with Baton Framework

### Baton Framework Responsibilities

1. **Issue Creation:**
   - Creates GitHub Issues from RHYTHM Method work items
   - Uses issue templates
   - Sets appropriate labels and metadata

2. **Issue Updates:**
   - Updates issue status based on workflow progress
   - Updates token estimates and actuals
   - Updates dependency levels
   - Maintains parent-child relationships

3. **Work Queue Management:**
   - Reads GitHub Issues via API
   - Filters by dependency level and status
   - Orders by priority
   - Assigns tasks to agents

4. **HITL Checkpoint Management:**
   - Creates HITL checkpoint comments
   - Monitors user responses
   - Updates issue status based on approvals
   - Escalates if approvals are delayed

5. **Dependency Tracking:**
   - Parses dependencies from issue bodies
   - Updates dependency level labels
   - Notifies when dependencies are resolved
   - Updates blocked status

6. **Token Tracking:**
   - Parses token estimates from issue bodies
   - Calculates roll-ups for parent issues
   - Updates actual tokens during execution
   - Maintains historical data

### GitHub Issues Responsibilities

1. **Storage:**
   - Store work item data (specifications, status, metadata)
   - Maintain issue history and comments
   - Provide visibility for humans

2. **Visibility:**
   - Display work items in GitHub UI
   - Show relationships and dependencies
   - Enable manual review and intervention

3. **Integration:**
   - Provide API for Baton Framework
   - Support webhooks for automation
   - Enable GitHub Actions workflows

---

## Best Practices

### Issue Creation

1. **Always use issue templates** - Ensures consistency
2. **Set all required labels** - Enables filtering and automation
3. **Link to parent issues** - Maintains hierarchy
4. **Include all metadata** - Token estimates, dependencies, etc.

### Issue Updates

1. **Update status labels** - Keep status current
2. **Update token actuals** - Track for historical learning
3. **Update dependency levels** - Maintain accurate prioritization
4. **Link related issues** - Show relationships

### HITL Checkpoints

1. **Use standard comment format** - Consistent structure
2. **Include all relevant details** - Complete context for decision
3. **Set response deadlines** - Manage expectations
4. **Follow up if delayed** - Escalate if needed

### Dependency Management

1. **List all dependencies** - Complete dependency graph
2. **Update when resolved** - Keep dependency levels current
3. **Notify when blocked** - Alert stakeholders
4. **Track dependency chains** - Understand impact

---

## Summary

GitHub Issues in RHYTHM Method:

1. **Represent work items** - Features, Work Units, Agent Tasks, Bugs
2. **Maintain hierarchy** - Through linking and labels (Project Manifest is markdown file)
3. **Track status** - Using labels and issue body metadata
4. **Manage dependencies** - Through dependency levels and linking
5. **Support HITL** - Through comments and status labels
6. **Track estimation** - Token estimates and actuals in issue bodies
7. **Enable automation** - Via GitHub API and Baton Framework integration

**Key Points:**
- Project Manifest is **NOT** a GitHub Issue (it's `.baton/project.manifest.md`)
- Issues use labels, structured body content, and linking to maintain RHYTHM Method structure
- Baton Framework integrates with GitHub Issues for automated workflow management
- All communication follows RHYTHM Method message formats (A2A, A2U)

---

**Document Version:** 1.0.0  
**Created:** 2025-11-26  
**Status:** Ready for CLI-Agent Review


