# Flow Cycles

This document details the six main flow cycles that comprise the RHYTHM Method execution model.

## Agent Key

- **BA** => Baton Agent (Baton Framework expert)
- **RA** => RHYTHM Agent (RHYTHM Method expert)
- **WA** => Worker Agent (Specialized execution: Development, Review, Quality Engineers)

---

## CYCLE: Project Initialisation

**Purpose:** Initialize a project with RHYTHM Method, creating foundational configuration files and understanding project context.

**Triggered By:** User initiating RHYTHM Method for a new or existing project

**Agent:** BA (Baton Agent)

**Process:**

- **IF** *EXISTING PROJECT*
  - BA executes scans & analyse project files
  - Baton Agent executes [[Project Interview Process]] with findings
  - [[Human-in-the-Loop Check Process]]
   `TEMPO: High/Moderate/Controlled`
  - User & BA run complete [[Cycle Review Process]]
- **ELSE IF** *NEW PROJECT*
  - BA runs [[Project Interview Process]]
  - [[Human-in-the-Loop Check Process]]
   `TEMPO: High/Moderate/Controlled`
  - User & BA run complete [[Cycle Review Process]]

**Outputs:**
- `Project.Manifest.md` - Project overview, goals, stakeholders, standards
- `Project.Config.yml` - Project configuration, TEMPO settings, integrations
- Project state set to **OPEN**

**See Also:**
- [Project Interview Process](05-processes.md#project-interview-process)
- [Project Setup](11-project-setup.md)

---

## CYCLE: Feature Specification

**Purpose:** Create detailed Feature specifications through structured interview and automated analysis.

**Triggered By:** User requesting a new Feature

**Agent:** RA (RHYTHM Agent)

**Process:**

- **IF** *EXISTING PROJECT*
  - RA scan project for existing features
  - RA present list of found features
  - User to correct
  - RA saves list of existing features
- RA executes [[Feature Interview Process]]
- [[Human-in-the-Loop Check Process]]
  `TEMPO: High/Moderate/Controlled`
- RA sets Feature state to **READY**
- User & RA run complete [[Cycle Review Process]]
- *OPTIONAL*: Add more features

**Inputs:**
- Project.Manifest
- Project.Config
- Existing Features (if any)
- User requirements

**Outputs:**
- Feature specification (YAML/JSON + markdown)
- Feature state: **READY**
- Updated dependency graph
- Feature added to Project.Manifest

**Key Activities:**
- Structured interview with User
- Automated dependency analysis
- Business value assessment
- Technical constraint identification
- Acceptance criteria definition

**See Also:**
- [Feature Interview Process](05-processes.md#feature-interview-process)
- [Work Breakdown Structure](07-work-breakdown-structure.md#feature)

---

## CYCLE: Work Unit Creation

**Purpose:** Break down a Feature into deliverable Work Units, each representing a cohesive unit of work.

**Triggered By:** Feature in **READY** state

**Agent:** RA (RHYTHM Agent)

**Process:**

- RA generates a list of Work Units for a feature
- **FOR EACH** *WORK UNIT*
  - RA breaks feature into deliverable Work Units
  - [[Human-in-the-Loop Check Process]]
   `TEMPO: Moderate/Controlled`
  - RA sets Work Unit state to **NEW**
- RA run complete [[Cycle Review Process]]
  `Include user if Tempo set to Moderate or Controlled`

**Inputs:**
- Feature specification (READY state)
- Project.Manifest
- Project.Config
- Existing Work Units and dependencies

**Outputs:**
- Work Unit specifications
- Work Unit state: **NEW**
- Updated dependency graph
- Dependency levels assigned

**Key Principles:**
- Each Work Unit should be independently deliverable
- Work Units should have clear interfaces
- Work Units should be sized for completion within single execution cycle
- Dependencies between Work Units should be minimized

**See Also:**
- [Work Breakdown Structure](07-work-breakdown-structure.md#work-unit)
- [Dependency Management](09-dependency-management.md)

---

## CYCLE: Challenge Cycle

**Purpose:** Peer review of Work Unit specifications by specialized Worker Agents to ensure quality, feasibility, and completeness before breakdown into tasks.

**Triggered By:** Work Units in **NEW** state

**Agent:** RA (orchestration) + WAs (reviewers)

**Process:**

- RA generates list of Work Units needing reviewed
- **FOR EACH** *WORK UNIT*
  - **DO**
    - RA analyses Work Unit specification and requirements
    - RA identifies required domain knowledge and specializations
    - RA selects WAs based on:
      - Domain expertise matching Work Unit requirements
      - Technical specializations needed
      - Standards knowledge relevant to the Work Unit
      - Previous experience with similar Work Units
    - **FOR EACH** *SELECTED WA (Reviewer)*
      - WA reviews Work Unit specification using:
        - **Standards**: Coding standards, architectural patterns, best practices
        - **Domain Knowledge**: Business domain expertise, technical domain knowledge
        - **Feasibility**: Can be completed within execution cycle constraints
        - **Clarity**: Requirements are clear and unambiguous
        - **Completeness**: All necessary information is present
      - WA can challenge:
        - RA's Work Unit specification
        - Other WAs' review comments and challenges
        - Assumptions, missing information, unclear requirements
      - WA leaves comment:
        `APPROVED (100% Agreed - no issues found)`
        `CHALLENGED (with specific details and rationale)`
    - RA reviews all comments from WAs
    - **IF** *ANY WA CHALLENGED (RA's work OR other WAs' comments)*
      - **IF** *CHALLENGE LOOP COUNT GREATER THAN MAX CHALLENGE LOOP*
        `Default: 3 (configurable in Project.Config)`
        - [[Human-in-the-Loop Check Process]]
          `TEMPO: High/Moderate/Controlled - challenge loop threshold exceeded`
        - User reviews challenges and provides resolution:
          - Accept Work Unit specification as-is with documented decisions
          - Provide clarification to resolve challenges
          - Modify Work Unit specification based on valid challenges
          - Split Work Unit if scope too large
        - RA resets Challenge Loop count
      - **ELSE**
        - **RA CHALLENGE EVALUATION:**
          - RA evaluates each WA challenge for validity
          - **IF** *RA HAS VALID REASON TO CHALLENGE WA's CHALLENGE*
            - RA challenges WA's challenge with:
              - Specific rationale and evidence
              - References to Standards or Domain Knowledge
              - Alternative perspective or clarification
              - Supporting documentation or examples
            - RA documents counter-challenge
            - WAs review RA's counter-challenge
            - **IF** *WAs ACCEPT RA's COUNTER-CHALLENGE*
              - WA challenge is resolved
              - Continue with remaining challenges
            - **ELSE IF** *WAs REJECT RA's COUNTER-CHALLENGE*
              - Challenge remains unresolved
              - Continue to challenge resolution
          - **ELSE** *RA ACCEPTS WA CHALLENGE AS VALID*
            - RA addresses all valid challenges:
              - Updates Work Unit specification based on valid feedback
              - Clarifies assumptions and adds missing information
              - Resolves conflicts between WA comments
        - RA increments Challenge Loop count
        - Loop back to WA reviews
    - **ELSE** *ALL WAs APPROVED*
      - RA sets Work Unit to READY
      - [[Human-in-the-Loop Check Process]]
        `TEMPO: Moderate/Controlled`
      - RA sets Work Unit state to **REVIEWED**
      - RA resets Challenge Loop count
  - **WHILE** *WORK UNIT STATE EQUALS NEW*
- RA and all WAs complete [[Cycle Review Process]]
  `Include user if HITL Override required`
  `Include user if Tempo set to Moderate or Controlled`

**Inputs:**
- Work Unit specifications (NEW state)
- Project.Manifest (standards, constraints)
- Project.Config (challenge loop threshold)
- Domain knowledge from WAs

**Outputs:**
- Work Unit state: **REVIEWED**
- Challenge comments and resolutions
- Updated Work Unit specifications
- Challenge loop metrics

**Loop Protection:**
- Challenge loop threshold (default: 3)
- HITL triggered when threshold exceeded
- Loop count reset after HITL resolution

**Key Benefits:**
- Early detection of issues before task breakdown
- Leverages specialized domain expertise
- Reduces rework during execution
- Validates feasibility and clarity
- Peer review improves specification quality

**See Also:**
- [Core Concepts - Loop Protection](02-core-concepts.md#loop-protection)
- [Common Challenges](14-common-challenges.md)

---

## CYCLE: Task Breakdown

**Purpose:** Break down reviewed Work Units into detailed Agent Tasks with token estimates, dependencies, and acceptance criteria.

**Triggered By:** Work Units in **REVIEWED** state

**Agent:** RA (orchestration) + WAs (task creation)

**Process:**

- RA retrieves list of Work Units with state **REVIEWED**
- **FOR EACH** *WORK UNIT*
  - RA analyses approved Work Unit specification
  - RA identifies types of work needed and required specialisations
  - RA assigns specialised agents (WAs) based on work types
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: Moderate/Controlled`
  - **FOR EACH** *ASSIGNED WA*
    - WA analyses Work Unit, Related Work Units, and Feature specification for their area
    - WA creates detailed Agent Task specifications for their work
    - WA defines task acceptance criteria
    - WA determines task dependencies within Work Unit
    - WA estimates task complexity and token requirements
      `Use token estimation formulas from 08-estimation.md`
    - WA estimates tokens: Code + Analysis + Documentation + Validation
    - WA sets task priority within Work Unit
    - WA sets Agent Task state to **READY**
  - RA validates all tasks are properly specified
  - RA ensures dependencies are identified across all WA tasks
  - RA confirms agent assignments are appropriate
  - **RA rolls up estimated tokens from Agent Tasks to Work Unit:**
    - RA aggregates all Agent Task estimated tokens (Code + Analysis + Documentation + Validation)
    - RA stores total estimated tokens in Work Unit
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: Moderate/Controlled`
  - RA sets Work Unit state to **READY**
- **RA rolls up estimated tokens from Work Units to Feature:**
  - RA aggregates all Work Unit estimated tokens
  - RA stores total estimated tokens in Feature
- RA sets Feature state to **IN PROGRESS**
- RA and all WAs run complete [[Cycle Review Process]]
  `Include user if Tempo set to Moderate or Controlled`

**Inputs:**
- Work Units (REVIEWED state)
- Feature specification
- Project.Manifest (standards)
- Project.Config (token budgets)

**Outputs:**
- Agent Task specifications with:
  - Detailed requirements
  - Acceptance criteria
  - Token estimates (Code, Analysis, Documentation, Validation)
  - Dependencies
  - Priority
- Agent Task state: **READY**
- Work Unit state: **READY**
- Feature state: **IN PROGRESS**
- Estimated tokens rolled up to Work Unit and Feature

**Token Roll-Up:**

```text
Agent Task 1: 1000 tokens (estimated)
Agent Task 2: 1500 tokens (estimated)
Agent Task 3: 800 tokens (estimated)
    ↓
Work Unit: 3300 tokens (estimated)
    ↓
Feature: Sum of all Work Unit estimated tokens
```

**See Also:**
- [Token Estimation](08-token-estimation.md)
- [Work Breakdown Structure](07-work-breakdown-structure.md#agent-task)

---

## CYCLE: Task Execution

**Purpose:** Execute Agent Tasks with continuous quality validation, review cycles, and dependency-driven prioritization.

**Triggered By:** Agent Tasks in **READY** state

**Agent:** RA (orchestration) + WAs (Development, Review, Quality Engineers)

**Process:**

- RA generates prioritized work queue from Agent Tasks
  `Apply dependency-driven prioritization from 09-dependency-management.md`
- **WHILE** *WORK QUEUE NOT EMPTY*
  - RA pulls ready Agent Tasks from work queue
    `Verify all dependencies are resolved`
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: Controlled for execution cycle scope approval`
  - **FOR EACH** *READY AGENT TASK IN PARALLEL*
    - WA (assigned specialized agent) prepares for task execution
    - WA sets Agent Task state to **IN_PROGRESS**
    - RA sets Work Unit state to **IN PROGRESS** (if not already set)
    - **CONTEXT GATHERING (Prevent Context Drift):**
      - WA reads Agent Task specification
      - WA reads Work Unit specification
      - WA reads Feature specification
      - WA reads Project.Manifest
      - WA reads Project.Config
      - WA reads relevant Standards
        `Coding standards, review requirements, tech stack guidelines`
    - **PLANNING:**
      - WA generates execution plan for Agent Task
      - WA validates plan against specifications and standards
      - WA identifies potential issues or dependencies
    - **EXECUTION:**
      - **WA (Development Engineer)** performs actual development work:
        - Code generation
        - Analysis work
        - Documentation creation
        - Unit testing
      - WA provides real-time status updates
      - WA tracks actual token usage
        `Code tokens, Analysis tokens, Documentation tokens, Validation tokens`
      - **IF** *TASK BLOCKED*
        - WA flags task as **BLOCKED**
        - WA identifies blocker type and notifies RA
        - **IF** *BLOCKER IS DEPENDENCY ON INCOMPLETE TASK*
          - RA updates dependency graph
          - RA moves task back to work queue
          - RA prioritizes blocking task
          `No HITL required - automated dependency management`
        - **ELSE IF** *BLOCKER IS EXTERNAL OR UNCLEAR*
          - [[Human-in-the-Loop Check Process]]
            `TEMPO: High/Moderate/Controlled for blocker resolution`
          - RA updates dependency graph based on resolution
      - **ELSE** *WORK COMPLETE*
        - WA commits work to version control
        - WA creates Pull Request (PR)
        - WA sets Agent Task state to **IN REVIEW**
    - **REVIEW:**
      - **WA (Review Engineer)** reviews the PR
      - WA (Review Engineer) examines:
        - Code quality and standards compliance
        - Logic correctness
        - Documentation completeness
        - Test coverage
      - WA (Review Engineer) leaves review comments:
        `NO ISSUES => APPROVED`
        `ANY ISSUES => REJECTED WITH DETAILS`
      - **IF** *REJECTED*
        - RA increments review loop count for Agent Task
        - **IF** *REVIEW LOOP COUNT > MAX REVIEW LOOP THRESHOLD*
          `Default threshold: 3 loops (configurable in Project.Config)`
          - RA flags Agent Task for HITL intervention
          - [[Human-in-the-Loop Check Process]]
            `TEMPO: High/Moderate/Controlled - loop threshold exceeded`
          - User reviews issue and provides guidance:
            - Accept work as-is with documented exceptions
            - Provide specific guidance to resolve issue
            - Reassign to different WA (Development Engineer)
            - Modify Agent Task specification if needed
          - RA resets review loop count
        - **ELSE**
          - WA (Development Engineer) addresses review comments
          - WA (Development Engineer) updates PR
          - Loop back to REVIEW
      - **ELSE IF** *APPROVED*
        - RA resets review loop count
        - Continue to QUALITY VALIDATION
    - **QUALITY VALIDATION:**
      - **WA (Quality Engineer)** validates work against Work Unit specification
      - WA (Quality Engineer) runs automated quality gates:
        - Integration testing with other Agent Tasks
        - Performance validation
        - Security scanning
        - Specification compliance check
      - **IF** *QUALITY GATES FAIL*
        - RA increments quality loop count for Agent Task
        - **IF** *QUALITY LOOP COUNT > MAX QUALITY LOOP THRESHOLD*
          `Default threshold: 3 loops (configurable in Project.Config)`
          - RA flags Agent Task for HITL intervention
          - [[Human-in-the-Loop Check Process]]
            `TEMPO: High/Moderate/Controlled - loop threshold exceeded`
          - User reviews issue and provides guidance:
            - Accept work with documented quality exceptions
            - Adjust quality gate thresholds if too strict
            - Provide specific guidance to resolve failures
            - Reassign to different WA (Development Engineer)
            - Modify Agent Task or Work Unit specification
          - RA resets quality loop count
        - **ELSE**
          - WA (Quality Engineer) documents failures
          - WA (Development Engineer) fixes issues
          - Loop back to REVIEW
      - **ELSE IF** *QUALITY GATES PASS*
        - RA resets quality loop count
        - WA (Quality Engineer) approves Agent Task
        - RA sets Agent Task state to **COMPLETE**
  - RA updates work queue based on completed tasks
    `Dependency-driven Prioritisation Cycle triggered`
  - RA triggers [[Continuous Planning Cycle]]
    `Update plans based on progress`
- **WHEN** *ALL TASKS FOR WORK UNIT COMPLETE*
  - RA aggregates Work Unit results
  - RA validates Work Unit completion criteria
  - **RA rolls up actual tokens from Agent Tasks to Work Unit:**
    - RA aggregates all Agent Task actual tokens (Code + Analysis + Documentation + Validation)
    - RA stores total actual tokens in Work Unit
    - RA compares actual vs. estimated tokens for variance analysis
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: Controlled for Work Unit completion approval`
  - RA sets Work Unit state to **COMPLETE**
- **WHEN** *ALL WORK UNITS FOR FEATURE COMPLETE*
  - RA sets Feature state to **IN REVIEW**
  - **FEATURE QUALITY VALIDATION:**
    - **WA (Quality Engineer)** runs comprehensive Feature-level quality gates:
      - End-to-end integration testing across ALL Work Units
      - Feature specification compliance validation
      - Performance testing against Feature requirements
      - Security validation for complete Feature
      - Documentation completeness check
      - User acceptance criteria validation
    - **IF** *QUALITY GATES FAIL*
      - WA (Quality Engineer) documents failures by Work Unit
      - RA sets affected Work Units state to **IN PROGRESS**
      - WAs (Development Engineers) fix issues
      - Loop back to affected Work Units
    - **ELSE IF** *QUALITY GATES PASS*
      - **RA rolls up actual tokens from Work Units to Feature:**
        - RA aggregates all Work Unit actual tokens
        - RA stores total actual tokens in Feature
        - RA compares actual vs. estimated tokens for variance analysis
      - [[Human-in-the-Loop Check Process]]
        `TEMPO: Moderate/Controlled for Feature completion approval`
      - RA sets Feature state to **COMPLETE**
- RA and all WAs complete [[Cycle Review Process]]
  `Include user if Tempo set to Moderate or Controlled`

**Inputs:**
- Agent Tasks (READY state)
- Work Unit specifications
- Feature specifications
- Project.Manifest, Project.Config
- Dependency graph

**Outputs:**
- Completed code, documentation, tests
- Pull Requests reviewed and merged
- Agent Task state: **COMPLETE**
- Work Unit state: **COMPLETE**
- Feature state: **COMPLETE**
- Actual token usage tracked and rolled up
- Variance analysis (estimated vs. actual)
- Execution metrics for Cycle Review

**Loop Protection:**
- Review loop threshold (default: 3)
- Quality loop threshold (default: 3)
- HITL triggered when thresholds exceeded

**Token Tracking:**

```text
Agent Task 1: 1200 tokens (actual) vs 1000 (estimated) = +20% variance
Agent Task 2: 1400 tokens (actual) vs 1500 (estimated) = -7% variance
Agent Task 3: 850 tokens (actual) vs 800 (estimated) = +6% variance
    ↓
Work Unit: 3450 tokens (actual) vs 3300 (estimated) = +4.5% variance
    ↓
Feature: Sum of all Work Unit actual tokens with variance analysis
```

**See Also:**
- [Quality Check Cycle](04-special-cycles.md#quality-check-cycle)
- [Dependency-driven Prioritisation Cycle](04-special-cycles.md#dependency-driven-prioritisation-cycle)
- [Token Estimation](08-token-estimation.md)
- [Dependency Management](09-dependency-management.md)

---

## Cycle Relationships

The six flow cycles work together in sequence:

```text
Project Initialisation (once per project)
    ↓
Feature Specification (per feature)
    ↓
Work Unit Creation (per feature)
    ↓
Challenge Cycle (per Work Unit batch)
    ↓
Task Breakdown (per Work Unit)
    ↓
Task Execution (per Agent Task batch)
    ↓
[Loop back to Feature Specification for next feature]
```

**Parallel Execution:**
- Multiple Features can be in different cycles simultaneously
- Work Units can be challenged in parallel
- Agent Tasks execute in parallel (dependency-permitting)

**Cycle Dependencies:**
- Work Unit Creation depends on Feature Specification
- Challenge Cycle depends on Work Unit Creation
- Task Breakdown depends on Challenge Cycle completion
- Task Execution depends on Task Breakdown

**See Also:**
- [Special Cycles](04-special-cycles.md) - Quality Check and Dependency-driven Prioritisation
- [Processes](05-processes.md) - Supporting processes used within cycles
- [State Management](06-state-management.md) - State transitions triggered by cycles

---

## Change History

| Version | Date       | Author | Description                                          |
| ------- | ---------- | ------ | ---------------------------------------------------- |
| 1.0.0   | 2025-12-14 | Agent  | Complete documentation of all 6 main flow cycles     |
