# End-to-End Workflow Example

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Complete Workflow Walkthrough

This document provides a complete, realistic example of RHYTHM Method in practice, walking through a feature from specification to completion with actual content and decisions.

## Overview

This example demonstrates how RHYTHM Method workflows operate in practice, showing:
- How a Feature is specified and approved
- How Work Units are created and reviewed
- How Work Units are broken down into Agent Tasks
- How execution cycles run with real progress
- How quality gates validate work
- How the cycle completes and improves

**Scenario:** Building a user authentication system for a web application.

---

## Scenario: User Authentication System

**Project Context:**
- **Project:** E-commerce Platform
- **Feature:** User Authentication System
- **Business Value:** Enable users to create accounts, log in, and manage their sessions securely
- **Technical Context:** REST API backend, PostgreSQL database, JWT tokens for session management

---

## Step 1: Feature Specification

### Feature Specification Document

**Feature Name:** User Authentication System

**Business Value:**
Users need to create accounts and log in to access personalized features, view order history, and manage their profile. This feature enables the core user experience and is a prerequisite for all user-specific functionality.

**Validation Criteria:**
- Users can create accounts with email and password
- Users can log in with valid credentials
- Users receive JWT tokens for authenticated requests
- Passwords are securely hashed (bcrypt)
- Sessions expire after 24 hours of inactivity
- Invalid login attempts are rate-limited (5 attempts per 15 minutes)

**Technical Constraints:**
- Must use existing PostgreSQL database
- Must integrate with existing user service architecture
- Must follow existing API design patterns
- Must support CORS for frontend integration

**Dependencies:**
- Database schema must be created first
- User service infrastructure must be available
- JWT library must be integrated

**Deployment:**
- Feature can be deployed independently
- Requires database migration
- No breaking changes to existing APIs

### Feature Specification Approval

**Agent Action:** RHYTHM Agent creates Feature Specification document

**Human Review:** User reviews specification and provides feedback:
- "Add requirement for password reset functionality"
- "Clarify JWT token expiration handling"
- "Specify rate limiting implementation details"

**Agent Response:** RHYTHM Agent updates specification:
- Adds password reset to validation criteria
- Clarifies JWT expiration (24 hours from last activity)
- Specifies rate limiting (Redis-based, 5 attempts per 15 minutes per IP)

**Human Approval:** ✅ User approves updated specification

**Status:** Feature Specification approved, ready for Work Unit Creation

---

## Step 2: Work Unit Creation

### Work Unit Breakdown

**Agent Action:** RHYTHM Agent analyzes Feature Specification and creates Work Unit breakdown:

**Work Unit 1: Database Schema Setup**
- Create user table schema
- Create session table schema
- Create indexes for performance
- **Dependencies:** None (Level 0)
- **Estimated Tokens:** 800 tokens (2 hours at 400 tokens/hour)

**Work Unit 2: User Model and Service**
- Implement User model
- Implement password hashing service
- Implement user creation logic
- **Dependencies:** Work Unit 1 (Level 1)
- **Estimated Tokens:** 1,200 tokens (3 hours at 400 tokens/hour)

**Work Unit 3: Authentication API Endpoints**
- POST /api/auth/register endpoint
- POST /api/auth/login endpoint
- POST /api/auth/logout endpoint
- **Dependencies:** Work Unit 2 (Level 2)
- **Estimated Tokens:** 1,500 tokens (3.75 hours at 400 tokens/hour)

**Work Unit 4: JWT Token Management**
- JWT token generation service
- JWT token validation middleware
- Token refresh logic
- **Dependencies:** Work Unit 2 (Level 2)
- **Estimated Tokens:** 1,000 tokens (2.5 hours at 400 tokens/hour)

**Work Unit 5: Rate Limiting and Security**
- Redis-based rate limiting
- Password strength validation
- Security headers and CORS configuration
- **Dependencies:** Work Unit 3 (Level 3)
- **Estimated Tokens:** 900 tokens (2.25 hours at 400 tokens/hour)

**Total Feature Estimation:** 5,400 tokens + 648 tokens (12% Feature Overhead) = **6,048 tokens**

### Work Unit Creation Approval

**Human Review:** User reviews Work Unit breakdown:
- "Work Unit 3 seems large - can it be split?"
- "Work Unit 4 and 5 can run in parallel after Work Unit 2"

**Agent Response:** RHYTHM Agent adjusts:
- Splits Work Unit 3 into:
  - Work Unit 3A: Registration and Login endpoints (1,000 tokens)
  - Work Unit 3B: Logout endpoint (500 tokens)
- Notes that Work Units 4 and 5 can run in parallel after Work Unit 2

**Human Approval:** ✅ User approves Work Unit breakdown

**Status:** Work Units created, ready for Work Unit Review

---

## Step 3: Work Unit Review

### Work Unit 1 Review

**Reviewing Agent:** Technical-writer-agent reviews Work Unit 1 specification

**Review Feedback:**
- ✅ **Clarity:** Specification is clear and well-defined
- ✅ **Completeness:** All necessary information present (schema details, indexes, constraints)
- ✅ **Feasibility:** Can be completed in execution cycle (2 hours estimated)
- ⚠️ **Suggestion:** Consider adding migration rollback strategy

**Agent Response:** RHYTHM Agent adds migration rollback strategy to specification

**Review Acceptance:** ✅ Work Unit 1 approved, ready for breakdown

### Work Unit 2 Review

**Reviewing Agent:** Technical-writer-agent reviews Work Unit 2 specification

**Review Feedback:**
- ✅ **Clarity:** Requirements are clear
- ✅ **Completeness:** All components specified
- ✅ **Feasibility:** 3 hours is within execution cycle limit
- ⚠️ **Challenge:** "Password hashing service" - should this be a separate service or part of User model?

**Resolution:** User clarifies - password hashing should be a utility service, not part of User model. Specification updated.

**Review Acceptance:** ✅ Work Unit 2 approved, ready for breakdown

### Work Unit 3A Review

**Reviewing Agent:** Technical-writer-agent reviews Work Unit 3A specification

**Review Feedback:**
- ✅ **Clarity:** Endpoint specifications are clear
- ✅ **Completeness:** Request/response formats specified
- ✅ **Feasibility:** 2.5 hours estimated, within execution cycle
- ✅ **Dependencies:** Correctly identified (Work Unit 2)

**Review Acceptance:** ✅ Work Unit 3A approved, ready for breakdown

**Status:** All Work Units reviewed and approved, ready for Work Unit Breakdown

---

## Step 4: Work Unit Breakdown

### Work Unit 1 Breakdown

**Agent Action:** RHYTHM Agent breaks down Work Unit 1 into Agent Tasks:

**Agent Task 1.1: Create User Table Schema**
- Define user table structure (id, email, password_hash, created_at, updated_at)
- Create migration file
- **Estimated Tokens:** 200 tokens
- **Assigned to:** Backend Agent

**Agent Task 1.2: Create Session Table Schema**
- Define session table structure (id, user_id, token, expires_at, created_at)
- Create migration file
- **Estimated Tokens:** 150 tokens
- **Assigned to:** Backend Agent

**Agent Task 1.3: Create Database Indexes**
- Create indexes on email (unique), user_id (foreign key), token (lookup)
- Add to migration file
- **Estimated Tokens:** 100 tokens
- **Assigned to:** Backend Agent

**Agent Task 1.4: Create Migration Rollback**
- Define rollback logic for migration
- Test rollback procedure
- **Estimated Tokens:** 150 tokens
- **Assigned to:** Backend Agent

**Agent Task 1.5: Validate Migration**
- Test migration on development database
- Verify schema constraints
- **Estimated Tokens:** 200 tokens
- **Assigned to:** QA Agent

**Total Work Unit 1 Tokens:** 800 tokens + 48 tokens (6% overhead) = **848 tokens**

### Work Unit Breakdown Approval

**Human Review:** User reviews task breakdown:
- "Task assignments look appropriate"
- "Dependencies between tasks are clear"

**Human Approval:** ✅ Work Unit 1 breakdown approved, tasks ready for execution

**Status:** Work Unit 1 tasks added to work queue

---

## Step 5: Execution Cycle - Work Unit 1

### Work Queue Status

**Queue Order (Dependency-Driven):**
1. Work Unit 1 (Level 0, no dependencies) - **READY**
2. Work Unit 2 (Level 1, depends on Work Unit 1) - **BLOCKED**
3. Work Unit 3A (Level 2, depends on Work Unit 2) - **BLOCKED**
4. Work Unit 3B (Level 2, depends on Work Unit 2) - **BLOCKED**
5. Work Unit 4 (Level 2, depends on Work Unit 2) - **BLOCKED**
6. Work Unit 5 (Level 3, depends on Work Unit 3A) - **BLOCKED**

### Task Execution

**Execution Cycle Start:** 2025-11-26 09:00:00

**Agent Task 1.1: Create User Table Schema**
- **Agent:** Backend Agent
- **Status:** ✅ Completed
- **Actual Tokens:** 180 tokens (under estimate)
- **Duration:** 27 minutes
- **Output:** Migration file created, schema validated

**Agent Task 1.2: Create Session Table Schema**
- **Agent:** Backend Agent
- **Status:** ✅ Completed
- **Actual Tokens:** 165 tokens (slightly over estimate)
- **Duration:** 25 minutes
- **Output:** Session table migration created

**Agent Task 1.3: Create Database Indexes**
- **Agent:** Backend Agent
- **Status:** ✅ Completed
- **Actual Tokens:** 95 tokens (under estimate)
- **Duration:** 14 minutes
- **Output:** Indexes added to migration

**Agent Task 1.4: Create Migration Rollback**
- **Agent:** Backend Agent
- **Status:** ✅ Completed
- **Actual Tokens:** 140 tokens (under estimate)
- **Duration:** 21 minutes
- **Output:** Rollback logic implemented and tested

**Agent Task 1.5: Validate Migration**
- **Agent:** QA Agent
- **Status:** ✅ Completed
- **Actual Tokens:** 190 tokens (under estimate)
- **Duration:** 29 minutes
- **Output:** Migration tested, all constraints validated

**Execution Cycle End:** 2025-11-26 11:16:00

**Total Actual Tokens:** 770 tokens (vs. 848 estimated)
**Total Duration:** 2 hours 16 minutes
**Variance:** -9.2% (under estimate)

### Quality Assurance

**Quality Gates:**
- ✅ **Code Quality:** All code passes linting and formatting checks
- ✅ **Migration Validation:** Migration runs successfully on test database
- ✅ **Rollback Validation:** Rollback procedure tested and verified
- ✅ **Schema Constraints:** All constraints (unique, foreign keys) validated
- ✅ **Documentation:** Migration documented with comments

**Quality Gate Results:** ✅ All gates passed

### Work Unit 1 Completion

**Status:** ✅ Work Unit 1 Complete

**Dependency Resolution:**
- Work Unit 2 is now **UNBLOCKED** (dependency on Work Unit 1 resolved)
- Work Unit 2 moves to **READY** status in work queue

**Cycle Review:**
- **Estimation Accuracy:** Good (9.2% under estimate, within acceptable range)
- **Execution Efficiency:** Tasks completed efficiently, no blockers
- **Quality:** All quality gates passed
- **Learning:** Migration tasks are well-understood, estimates were conservative

---

## Step 6: Execution Cycle - Work Unit 2

### Work Queue Update

**Queue Order (Updated):**
1. ~~Work Unit 1~~ - **COMPLETE**
2. Work Unit 2 (Level 1, dependencies resolved) - **READY** ⬅️ **NEXT**
3. Work Unit 3A (Level 2, depends on Work Unit 2) - **BLOCKED**
4. Work Unit 3B (Level 2, depends on Work Unit 2) - **BLOCKED**
5. Work Unit 4 (Level 2, depends on Work Unit 2) - **BLOCKED**
6. Work Unit 5 (Level 3, depends on Work Unit 3A) - **BLOCKED**

### Task Execution

**Execution Cycle Start:** 2025-11-26 11:30:00

**Work Unit 2 Breakdown:**
- Agent Task 2.1: Implement User Model (400 tokens)
- Agent Task 2.2: Implement Password Hashing Service (350 tokens)
- Agent Task 2.3: Implement User Creation Logic (450 tokens)

**Execution Progress:**
- **11:30-12:15:** Agent Task 2.1 completed (User Model implemented)
- **12:15-12:50:** Agent Task 2.2 completed (Password Hashing Service implemented)
- **12:50-14:00:** Agent Task 2.3 completed (User Creation Logic implemented)

**Bug Found During Development:**
- **Issue:** Password validation not checking minimum length
- **Classification:** Development bug (parented to Work Unit 2)
- **Action:** Fixed immediately (added 8-character minimum requirement)
- **Impact:** +50 tokens, +10 minutes

**Execution Cycle End:** 2025-11-26 14:10:00

**Total Actual Tokens:** 1,250 tokens (vs. 1,200 estimated)
**Total Duration:** 2 hours 40 minutes
**Variance:** +4.2% (slightly over estimate, due to bug fix)

### Quality Assurance

**Quality Gates:**
- ✅ **Code Quality:** All code passes checks
- ✅ **Unit Tests:** User model tests pass (95% coverage)
- ✅ **Password Security:** Password hashing verified (bcrypt, salt rounds = 10)
- ✅ **Integration Tests:** User creation flow tested end-to-end
- ⚠️ **Code Review:** Minor suggestion - add input sanitization

**Code Review Response:** Input sanitization added (email format validation, SQL injection prevention)

**Quality Gate Results:** ✅ All gates passed (after code review feedback addressed)

### Work Unit 2 Completion

**Status:** ✅ Work Unit 2 Complete

**Dependency Resolution:**
- Work Units 3A, 3B, and 4 are now **UNBLOCKED**
- Work Units 3A, 3B, and 4 move to **READY** status
- Work Units 3A and 3B can execute in parallel
- Work Unit 4 can execute in parallel with 3A/3B

**Cycle Review:**
- **Estimation Accuracy:** Excellent (4.2% over estimate, well within acceptable range)
- **Bug Handling:** Development bug caught and fixed during cycle (demonstrates parented bug workflow)
- **Quality:** All quality gates passed after addressing code review feedback
- **Learning:** Password security requirements well-understood, estimates accurate

---

## Step 7: Parallel Execution - Work Units 3A, 3B, and 4

### Work Queue Update

**Queue Order (Updated):**
1. ~~Work Unit 1~~ - **COMPLETE**
2. ~~Work Unit 2~~ - **COMPLETE**
3. Work Unit 3A (Level 2, dependencies resolved) - **READY** ⬅️ **EXECUTING**
4. Work Unit 3B (Level 2, depends on Work Unit 3A) - **BLOCKED**
5. Work Unit 4 (Level 2, dependencies resolved) - **READY** ⬅️ **EXECUTING** (parallel)
6. Work Unit 5 (Level 3, depends on Work Unit 3A) - **BLOCKED**

**Note:** Work Units 3A and 4 can execute in parallel (both depend on Work Unit 2, no dependency between them).

### Parallel Execution

**Execution Cycle Start:** 2025-11-26 14:30:00

**Work Unit 3A Execution:**
- Agent Task 3A.1: POST /api/auth/register endpoint (500 tokens)
- Agent Task 3A.2: POST /api/auth/login endpoint (500 tokens)
- **Status:** ✅ Completed at 16:45:00
- **Actual Tokens:** 1,050 tokens (vs. 1,000 estimated)
- **Duration:** 2 hours 15 minutes

**Work Unit 4 Execution (Parallel):**
- Agent Task 4.1: JWT Token Generation Service (400 tokens)
- Agent Task 4.2: JWT Token Validation Middleware (350 tokens)
- Agent Task 4.3: Token Refresh Logic (250 tokens)
- **Status:** ✅ Completed at 17:00:00
- **Actual Tokens:** 1,020 tokens (vs. 1,000 estimated)
- **Duration:** 2 hours 30 minutes

**Work Unit 3B Execution (After 3A):**
- Agent Task 3B.1: POST /api/auth/logout endpoint (500 tokens)
- **Status:** ✅ Completed at 17:30:00
- **Actual Tokens:** 480 tokens (vs. 500 estimated)
- **Duration:** 1 hour 15 minutes

### Quality Assurance

**Work Unit 3A Quality Gates:**
- ✅ **API Tests:** Registration and login endpoints tested
- ✅ **Integration Tests:** End-to-end authentication flow validated
- ✅ **Security:** Input validation and SQL injection prevention verified
- ✅ **Documentation:** API documentation generated

**Work Unit 4 Quality Gates:**
- ✅ **JWT Validation:** Token generation and validation tested
- ✅ **Security:** Token expiration and refresh logic verified
- ✅ **Middleware Tests:** Authentication middleware tested
- ✅ **Integration:** JWT service integrated with authentication endpoints

**Work Unit 3B Quality Gates:**
- ✅ **API Tests:** Logout endpoint tested
- ✅ **Session Management:** Token invalidation verified
- ✅ **Integration:** Logout integrated with session management

**All Quality Gates:** ✅ Passed

### Dependency Resolution

**Status Updates:**
- ✅ Work Unit 3A Complete → Work Unit 3B unblocked
- ✅ Work Unit 4 Complete
- ✅ Work Unit 3B Complete → Work Unit 5 unblocked

**Work Queue Status:**
- Work Unit 5 is now **READY** (all dependencies resolved)

---

## Step 8: Final Execution Cycle - Work Unit 5

### Work Queue Update

**Queue Order (Final):**
1. ~~Work Unit 1~~ - **COMPLETE**
2. ~~Work Unit 2~~ - **COMPLETE**
3. ~~Work Unit 3A~~ - **COMPLETE**
4. ~~Work Unit 3B~~ - **COMPLETE**
5. ~~Work Unit 4~~ - **COMPLETE**
6. Work Unit 5 (Level 3, dependencies resolved) - **READY** ⬅️ **EXECUTING**

### Task Execution

**Execution Cycle Start:** 2025-11-26 18:00:00

**Work Unit 5 Breakdown:**
- Agent Task 5.1: Redis-based Rate Limiting (350 tokens)
- Agent Task 5.2: Password Strength Validation (200 tokens)
- Agent Task 5.3: Security Headers and CORS (350 tokens)

**Execution Progress:**
- **18:00-19:05:** Agent Task 5.1 completed (Rate limiting implemented and tested)
- **19:05-19:35:** Agent Task 5.2 completed (Password validation rules implemented)
- **19:35-20:20:** Agent Task 5.3 completed (Security headers and CORS configured)

**Execution Cycle End:** 2025-11-26 20:20:00

**Total Actual Tokens:** 920 tokens (vs. 900 estimated)
**Total Duration:** 2 hours 20 minutes
**Variance:** +2.2% (slightly over estimate)

### Quality Assurance

**Quality Gates:**
- ✅ **Rate Limiting:** Redis integration tested, rate limits enforced correctly
- ✅ **Password Validation:** Strength rules validated (8+ chars, uppercase, lowercase, number, special)
- ✅ **Security Headers:** CORS, XSS protection, content security policy verified
- ✅ **Integration Tests:** All security features tested end-to-end
- ✅ **Performance:** Rate limiting doesn't impact performance (< 10ms overhead)

**Quality Gate Results:** ✅ All gates passed

### Work Unit 5 Completion

**Status:** ✅ Work Unit 5 Complete

**Feature Status:** ✅ **All Work Units Complete**

---

## Step 9: Feature Completion and Deployment

### Feature Validation

**Validation Against Criteria:**
- ✅ Users can create accounts with email and password
- ✅ Users can log in with valid credentials
- ✅ Users receive JWT tokens for authenticated requests
- ✅ Passwords are securely hashed (bcrypt, salt rounds = 10)
- ✅ Sessions expire after 24 hours of inactivity
- ✅ Invalid login attempts are rate-limited (5 attempts per 15 minutes)
- ✅ Password reset functionality implemented
- ✅ JWT token expiration handling clarified and implemented

**All Validation Criteria Met:** ✅

### Deployment Approval

**Deployment Request:**
- **Feature:** User Authentication System
- **Work Units:** 5 Work Units, all complete
- **Quality Gates:** All passed
- **Validation:** All criteria met
- **Database Migration:** Ready for production

**Human Review:** User reviews deployment package:
- Reviews code changes
- Reviews database migration
- Reviews security configurations
- Reviews API documentation

**Human Approval:** ✅ Deployment approved

### Deployment

**Deployment Process:**
1. Database migration executed (Work Unit 1)
2. Code deployed to staging environment
3. Integration tests run on staging
4. Security audit completed
5. Code deployed to production
6. Production smoke tests passed

**Deployment Status:** ✅ **Feature Deployed Successfully**

**Deployment Time:** 2025-11-26 21:00:00

---

## Step 10: Cycle Review and Learning

### Feature-Level Review

**Feature Metrics:**
- **Total Estimated Tokens:** 6,048 tokens
- **Total Actual Tokens:** 5,840 tokens
- **Estimation Variance:** -3.4% (excellent accuracy)
- **Total Duration:** ~11 hours (across 5 execution cycles)
- **Quality Gates:** 100% pass rate
- **Bugs Found:** 1 development bug (fixed during cycle)

### Process Analysis

**What Went Well:**
- ✅ Estimation accuracy was excellent (within 5% for all Work Units)
- ✅ Parallel execution worked effectively (Work Units 3A and 4)
- ✅ Dependency management ensured correct execution order
- ✅ Quality gates caught issues early (code review feedback)
- ✅ Development bug was caught and fixed during cycle (parented bug workflow)

**Areas for Improvement:**
- ⚠️ Initial Work Unit 3 was too large (split into 3A and 3B)
- ⚠️ Code review feedback could be caught earlier (consider adding to Work Unit Review)
- ✅ Migration rollback strategy was valuable addition

### Learning Integration

**Estimation Refinements:**
- Migration tasks: Slightly reduce estimates (actuals were consistently under)
- API endpoint tasks: Estimates were accurate
- Security tasks: Estimates were accurate

**Process Improvements:**
- Work Unit Review should include code review checklist
- Consider splitting large Work Units earlier in the process
- Parallel execution opportunities should be identified during Work Unit Creation

**Historical Data Updated:**
- Migration task patterns: Added to historical database
- API endpoint patterns: Added to historical database
- Security implementation patterns: Added to historical database

---

## Key Takeaways

### Methodology in Practice

1. **Dependency-Driven Prioritization Works:**
   - Work Units executed in correct order automatically
   - No blocked work waiting unnecessarily
   - Parallel execution maximized where possible

2. **Token Estimation is Accurate:**
   - All Work Units within 5% of estimates
   - Historical data improves accuracy over time
   - Pattern recognition helps with similar work

3. **Quality Gates Catch Issues Early:**
   - Code review feedback addressed before deployment
   - Security validation caught potential issues
   - Integration tests validated end-to-end flows

4. **Work Unit Review is Valuable:**
   - Caught specification issues before breakdown
   - Clarified ambiguous requirements
   - Improved Work Unit quality

5. **Continuous Planning Adapts:**
   - Work queue updated automatically as dependencies resolved
   - Parallel execution opportunities identified
   - No manual replanning needed

### Real-World Insights

- **Execution cycles are realistic:** 2-3 hours per Work Unit is typical
- **Parallel execution speeds delivery:** Work Units 3A and 4 completed simultaneously
- **Bug handling is efficient:** Development bugs fixed within cycle, no separate workflow needed
- **Human oversight is strategic:** Approvals at key decision points, not every step

---

## See Also

- [Workflows](06-workflows.md) - Detailed workflow processes
- [Work Breakdown Structure](07-work-breakdown-structure.md) - WBS hierarchy and relationships
- [Estimation](08-estimation.md) - Token estimation methodology
- [Dependency Management](09-dependency-management.md) - Dependency-driven prioritization
- [TEMPO](05-tempo.md) - Understanding execution speed
- [Best Practices](10-best-practices.md) - Implementation guidance

---

## Navigation

**Previous:** [Error Handling](13-error-handling.md) - Error handling and failure recovery  
**Next:** [Quick Reference](15-quick-reference.md) - Formulas and decision trees

---

## Change History

| Version | Date       | Author              | Description                    |
| ------- | ---------- | ------------------- | ------------------------------ |
| 1.0.0   | 2025-11-26 | technical-writer-agent | Initial end-to-end workflow example |

