# Processes

This document details the supporting processes used within the RHYTHM Method flow cycles.

---

## Project Interview Process

**Purpose:** Create foundational project configuration through structured interview.

**Agent:** BA (Baton Agent)

**Triggered By:** Project Initialisation cycle

**Process:**

1. Only Predefined Question:
   "What is the end goal of this project?"
2. Generate dynamic follow-up questions based on user's response + project scan if available.
3. Create `Project.Manifest` from template
4. Create `Project.Config` from template

**Outputs:**
- `.baton/Project.Manifest.md` - Project overview, goals, stakeholders, standards
- `.baton/project.config.yml` - Project configuration, TEMPO settings, integrations

**See Also:**
- [Project Setup](11-project-setup.md) for detailed templates
- [Project Initialisation Cycle](03-flow-cycles.md#cycle-project-initialisation)

---

## Feature Interview Process

**Purpose:** Create detailed Feature specifications through structured interview and analysis.

**Agent:** RA (RHYTHM Agent)

**Triggered By:** Feature Specification cycle

**Process:**

- RA initiates Feature Interview
- RA reads Project.Manifest and Project.Config
- RA reviews existing Features and Work Units for context
- RA prepares initial analysis of Feature scope
- **RA conducts interview with User:**
  - **Core Questions:**
    - What is the business value and objective of this Feature?
    - Who are the users and what are their requirements?
    - What are the validation criteria for Feature completion?
    - What technical constraints or interfaces must be considered?
  - **Dynamic Follow-up Questions** based on:
    - User's responses
    - Project context from Project.Manifest
    - Existing Feature dependencies
    - Technical constraints and architecture
- **RA performs automated dependency analysis:**
  - Code analysis (imports, function calls, type references)
  - Specification analysis (explicit and implicit dependency mentions)
  - API analysis (API contracts, interface definitions)
  - Pattern recognition (historical patterns)
  - Knowledge dependencies (may require manual identification)
  - RA flags critical dependencies for User review
- **RA creates Feature Specification:**
  - **Business value and objectives** (why this Feature exists)
  - **User requirements and validation criteria** (what defines "done")
  - **Technical constraints and interfaces** (how it integrates)
  - **Dependencies** (what must exist first)
  - **Acceptance criteria** (how to validate completion)
  - Machine-readable format (YAML/JSON)
  - Human-readable documentation
- [[Human-in-the-Loop Check Process]]
  `TEMPO: High/Moderate/Controlled - Feature Specification Approval`
- **IF** *User approves*
  - RA sets Feature state to **READY**
  - RA adds Feature to Project.Manifest
  - RA updates dependency graph
  - RA calculates impact on existing Features
  - RA logs Feature specification for future context
- **ELSE IF** *User rejects*
  - RA refines specification based on User feedback
  - Loop back to Feature Specification creation

**Inputs:**
- Project.Manifest
- Project.Config
- Existing Features and Work Units
- User requirements

**Outputs:**
- Feature specification (YAML/JSON + markdown)
- Feature state: **READY**
- Updated dependency graph
- Feature added to Project.Manifest

**See Also:**
- [Feature Specification Cycle](03-flow-cycles.md#cycle-feature-specification)
- [Work Breakdown Structure - Feature](07-work-breakdown-structure.md#feature)

---

## Cycle Review Process

**Purpose:** Analyze execution cycles, identify improvements, and adapt the methodology for better results.

**Agent:** RA + all WAs involved, optionally User based on TEMPO

**Triggered:** After major cycle completion (Feature completion, Work Unit completion, or periodic review)

**Process:**

- **RA performs automated analysis:**
  - **Cycle Performance Metrics:**
    - Number of iterations per cycle (Task Breakdown, Task Execution, Challenge, etc.)
    - HITL intervention frequency and reasons
    - Loop threshold triggers (challenge, review, quality loops)
  - **Token Estimation Accuracy:**
    - Estimated vs. actual token usage by Agent Task
    - Token usage by category (Code, Analysis, Documentation, Validation)
    - Estimation accuracy trends over time
    - Outliers and estimation misses
  - **Dependency Resolution Effectiveness:**
    - Dependency detection accuracy (false positives/negatives)
    - Dependency resolution time
    - Blocked work frequency and duration
    - Critical path changes
    - Parallel execution efficiency
  - **Quality Gate Results:**
    - Review rejection rates by WA (Review Engineer)
    - Quality gate failure rates by WA (Quality Engineer)
    - Failure severity distribution
    - Common failure patterns
    - Fix iteration counts
    - Override frequency and justifications
    - Time to quality approval
- **RA identifies improvement opportunities:**
  - **Process Inefficiencies:** Excessive iterations, loop threshold triggers, persistent quality failures, recurring dependency issues
  - **Estimation Issues:** Over/under-estimation patterns, poor estimation accuracy by category
  - **Quality Issues:** Recurring failure patterns, inappropriate quality gate thresholds, WA skill gaps
  - **Workflow Optimizations:** HITL automation opportunities, dependency detection improvements, WA coordination improvements
- **RA suggests process improvements:**
  - Update estimation models based on actual token usage
  - Refine quality gate thresholds based on failure patterns
  - Adjust loop thresholds (challenge, review, quality)
  - Optimize HITL checkpoint placement
  - Improve dependency detection rules
  - Update WA coordination patterns
  - Propose methodology refinements
- **WAs provide cycle feedback:**
  - Each WA reviews their portion of the cycle
  - WAs identify challenges encountered
  - WAs suggest improvements for their specialization
  - WAs flag blockers or process issues
  - WAs share learnings and insights
- **Collaborative review and improvement:**
  - RA and WAs discuss findings together
  - Identify root causes of issues
  - Prioritize improvements by impact
  - Agree on action items for next cycle
  - Document learnings and decisions
- **IF** *TEMPO: Moderate or Controlled*
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: Moderate/Controlled - Cycle Review Approval`
  - User reviews cycle analysis and metrics
  - User approves or adjusts process improvement suggestions
  - User provides strategic guidance
  - User decides on methodology changes
- **ELSE IF** *TEMPO: High*
  - RA and WAs implement approved improvements automatically
  - User receives summary notification
  - User can optionally review if desired
- **RA implements approved improvements:**
  - Update Project.Config with new settings (thresholds, checkpoints, etc.)
  - Update estimation models
  - Refine quality gates
  - Enhance dependency detection rules
  - Document changes in Project.Manifest
  - Apply learnings to future cycles
- **RA logs cycle review for learning integration:**
  - Store cycle metrics and analysis
  - Build historical performance data
  - Enable trend analysis across cycles
  - Support continuous methodology improvement

**Inputs:**
- Cycle execution metrics
- Token usage data (estimated vs. actual)
- Dependency resolution data
- Quality gate results
- HITL intervention logs
- Loop threshold trigger events

**Outputs:**
- Cycle analysis report
- Improvement recommendations
- Updated Project.Config (if approved)
- Updated estimation models
- Updated quality gate thresholds
- Updated dependency detection rules
- Documented learnings

**Frequency:**
- After Feature completion (mandatory)
- After significant Work Unit batches (optional, TEMPO-dependent)
- Periodic review (weekly/sprint-based, configurable)

**See Also:**
- [Core Concepts - Continuous Improvement](02-core-concepts.md#cycle-review-and-continuous-improvement)
- [Best Practices](13-best-practices.md)

---

## Human-in-the-Loop Check Process

**Purpose:** Enable strategic human oversight and control while maintaining fast agent execution through configurable checkpoints.

**Agent:** RA (RHYTHM Agent)

**Triggered:** At specific cycle checkpoints based on TEMPO level configuration

**Process:**

- **RA identifies HITL checkpoint:**
  - Checkpoint defined in cycle workflow
    `Example: Feature specification approval, Work Unit completion`
  - RA checks Project.Config for TEMPO level
  - RA determines if checkpoint is enabled for current TEMPO level:
    - **High TEMPO:** ~3-5 gates per feature cycle (critical decision points only)
    - **Moderate TEMPO:** ~8-12 gates per feature cycle (key decision points and validation checkpoints)
    - **Controlled TEMPO:** ~15-20 gates per feature cycle (comprehensive oversight)
  - RA checks HITL trigger conditions from Project.Config:
    - Quality score thresholds
    - Challenge conflicts
    - Dependency conflicts
    - Loop threshold exceeded (challenge, review, quality)
    - Critical path blocked
- **RA determines priority level:**
  - **Emergency:** Critical failures, system instability, production issues (Expected Response: < 15 minutes)
  - **High Priority:** High-priority work, critical path blockers, major decisions (Expected Response: < 2 hours)
  - **Normal Priority:** Routine approvals, non-critical decisions (Expected Response: < 8 hours)
  - **Low Priority:** Optional reviews, informational notifications (Expected Response: < 24 hours)
- **RA prepares checkpoint information:**
  - **Context Package:**
    - What decision/approval is needed
    - Why this checkpoint was triggered
    - Current state of work (Feature, Work Unit, Agent Task)
    - Relevant specifications and dependencies
    - Agent analysis and recommendations
    - Risk assessment (if applicable)
    - Options available to User
  - **Supporting Data:**
    - Cycle metrics and performance data
    - Quality gate results
    - Dependency graph visualization
    - Historical context (similar past decisions)
- **RA notifies User:**
  - Send notification through configured channels (IDE, email, Slack, etc.)
  - Include priority level and expected response time
  - Provide direct link to checkpoint in IDE/interface
  - Include summary of what's needed
  - Set timeout based on priority level
- **User reviews checkpoint:**
  - User reviews context package and supporting data
  - User evaluates agent recommendations
  - User considers business context and strategic alignment
  - User makes decision based on business requirements, technical feasibility, resource constraints, strategic direction
- **User provides decision:**
  - Options: Approval | Rejection | Modification | Escalation | Defer
- **RA handles User decision:**
  - **IF** *APPROVED*
    - RA proceeds with cycle
    - RA updates work item states
    - RA logs approval for audit trail
    - Continue to next step in cycle
  - **ELSE IF** *REJECTED*
    - RA updates work item state appropriately
    - RA communicates feedback to relevant agents
    - RA triggers revision cycle
    - Loop back to appropriate cycle step
  - **ELSE IF** *MODIFIED*
    - RA applies User modifications
    - RA updates specifications/configurations
    - RA communicates changes to agents
    - Continue with modifications applied
  - **ELSE IF** *ESCALATED*
    - RA routes to appropriate stakeholder
    - RA pauses work until escalation resolved
  - **ELSE IF** *DEFERRED*
    - RA queues work for later review
    - RA logs deferral reason
    - RA notifies affected agents
- **IF** *TIMEOUT EXCEEDED*
  - **IF** *Low-Risk Work (Normal/Low Priority)*
    - Auto-approve after timeout (with notification)
      `Conditions: Work is low-risk, well-defined, agent confidence is high`
    - RA logs auto-approval
    - User can override auto-approval later if needed
  - **ELSE IF** *High-Risk Work (High Priority/Emergency)*
    - Queue work, wait for human response
    - Escalate to backup approver (if configured in Project.Config)
    - **Escalation Levels:**
      1. Notify User again (reminder)
      2. Escalate to backup approver
      3. Escalate to project lead or manager
      4. Emergency escalation for critical issues
    - Critical work blocked until approval received
- **RA logs checkpoint for metrics:**
  - Log checkpoint type and priority
  - Log response time
  - Log decision (approved/rejected/modified)
  - Log timeout events (if any)
  - Log escalations (if any)
  - Track for Cycle Review Process:
    - HITL intervention frequency
    - Response time patterns
    - Auto-approval effectiveness
    - Checkpoint optimization opportunities

**Configuration:**

HITL checkpoints are fully configurable in Project.Config:

- **TEMPO Level:** Sets default checkpoint frequency (High/Moderate/Controlled)
- **Per-Project Configuration:** Override TEMPO for specific features/work units
- **Per-Gate Configuration:** Enable/disable specific checkpoints regardless of TEMPO
- **Timeout Settings:** Configure timeout periods by priority level
- **Auto-Approval Settings:** Configure auto-approval conditions for low-risk work
- **Escalation Settings:** Configure backup approvers and escalation procedures
- **Availability Windows:** Configure User availability schedule and timezone

**Best Practices:**

1. Set clear response time expectations for each priority level
2. Configure appropriate timeouts based on work priority
3. Enable auto-approval for low-risk, well-defined work
4. Set up backup approvers for critical work
5. Monitor response times and adjust expectations
6. Use batch approvals to reduce overhead when possible
7. Configure availability windows based on timezone

**See Also:**
- [Core Concepts - HITL](02-core-concepts.md#human-in-the-loop-hitl)
- [TEMPO Configuration](10-tempo-configuration.md)

---

## Process Integration

All processes integrate with the main flow cycles:

**Project Interview Process:**
- Used in: Project Initialisation cycle
- Creates: Project.Manifest, Project.Config

**Feature Interview Process:**
- Used in: Feature Specification cycle
- Creates: Feature specifications

**Cycle Review Process:**
- Used in: After all major cycles
- Outputs: Process improvements, updated models

**Human-in-the-Loop Check Process:**
- Used in: Throughout all cycles at checkpoints
- Enables: Strategic human oversight

**See Also:**
- [Flow Cycles](03-flow-cycles.md)
- [Special Cycles](04-special-cycles.md)
- [Best Practices](13-best-practices.md)

---

## Change History

| Version | Date       | Author | Description                                            |
| ------- | ---------- | ------ | ------------------------------------------------------ |
| 1.0.0   | 2025-12-14 | Agent  | Complete documentation of all supporting processes     |
