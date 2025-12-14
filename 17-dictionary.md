# RHYTHM Method Dictionary

This dictionary provides comprehensive definitions of all key terms, concepts, and terminology used in RHYTHM Method. Use this as a reference to ensure consistent terminology throughout documentation and implementation.

---

## Core Methodology Terms

### RHYTHM Method
**R**apid, **H**igh-**Y**ield, **T**oken-based, **H**uman-in-loop, **M**anagement

A project management methodology specifically designed for AI agents with strategic human integration. RHYTHM Method bridges the gap between traditional human-focused methodologies and pure agentic processes.

### TEMPO
The speed/pace at which agents operate and the frequency of Human-in-the-Loop checkpoints. TEMPO has three levels: High, Moderate, and Controlled.

**Usage:** "The project is running at High TEMPO with minimal HITL gates."

### Flow
Continuous execution without artificial boundaries (no sprints). Work happens continuously based on dependency-driven prioritization.

**Usage:** "Maintain continuous flow by keeping the work queue populated."

---

## Agent Types

### BA (Baton Agent)
Baton Framework specialist responsible for project initialization, Baton configuration, and framework setup.

**Usage:** "The BA creates the Project.Manifest during project initialization."

### RA (RHYTHM Agent)
RHYTHM Method specialist responsible for orchestrating all cycles, managing dependencies, coordinating agents, and ensuring methodology compliance.

**Usage:** "The RA coordinates the Challenge Cycle and manages HITL checkpoints."

### WA (Worker Agent)
Specialized execution agent with three sub-roles: Development Engineer, Review Engineer, and Quality Engineer.

**Usage:** "WAs execute Agent Tasks and participate in the Challenge Cycle."

#### Development Engineer
WA sub-role responsible for actual implementation work (code, documentation, analysis).

**Usage:** "The Development Engineer implements the Agent Task."

#### Review Engineer
WA sub-role responsible for code review and quality validation.

**Usage:** "The Review Engineer reviews the PR for standards compliance."

#### Quality Engineer
WA sub-role responsible for running quality gates and validation.

**Usage:** "The Quality Engineer validates the Work Unit against specifications."

---

## Work Breakdown Structure

### Project Manifest
Single top-level container for a project. Replaces the concept of "Epics" from traditional methodologies. Contains project overview, goals, stakeholders, and high-level information.

**File:** `.baton/Project.Manifest.md`

**Usage:** "The Project Manifest defines the project's goals and success metrics."

**NOT:** "Epic", "Project Plan", "Master Document"

### Feature
Deliverable functionality that provides business value. Features are broken down into Work Units.

**States:** NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE

**Usage:** "The Feature specification defines user-facing functionality."

**NOT:** "User Story", "Requirement", "Module"

### Work Unit
Specific piece of work that can be completed within a single execution cycle (up to 8 hours). Work Units are broken down into Agent Tasks.

**States:** NEW → REVIEWED → READY → IN PROGRESS → IN REVIEW → COMPLETE

**Usage:** "Each Work Unit should be independently deliverable."

**NOT:** "Unit of Work", "Task Group", "Sprint Item"

### Agent Task
Smallest unit of executable work, assigned to a single agent, typically 30 minutes to 2 hours.

**States:** NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE

**Usage:** "Agent Tasks are estimated using token-based estimation."

**NOT:** "Task", "Subtask", "Work Item"

### Bug
Defect or issue found during development or production. Bugs have two relationship types: Parented (to Work Unit) or Related (to Feature).

**States:** NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE

**Usage:** "Bugs found during development are parented to the Work Unit."

**NOT:** "Defect", "Issue", "Problem"

---

## Cycles and Processes

### Cycle
A structured workflow in RHYTHM Method with defined inputs, processes, and outputs.

**Types:** Project Initialisation, Feature Specification, Work Unit Creation, Challenge, Task Breakdown, Task Execution, Quality Check, Dependency-driven Prioritisation

**Usage:** "The Challenge Cycle validates Work Unit specifications."

**NOT:** "Sprint", "Phase", "Stage"

### Execution Cycle
Focused work period up to 8 hours for completing a Work Unit.

**Usage:** "Work Units should be sized to fit within a single execution cycle."

**NOT:** "Sprint", "Iteration", "Cycle" (alone)

### Challenge Cycle
Peer review cycle where WAs review and challenge Work Unit specifications before breakdown into Agent Tasks.

**Usage:** "The Challenge Cycle ensures Work Units are feasible and complete."

### Quality Check Cycle
Validation cycle that runs quality gates at Agent Task, Work Unit, and Feature levels.

**Usage:** "The Quality Check Cycle validates specification compliance."

### Dependency-driven Prioritisation Cycle
Continuous cycle that prioritizes work based on dependency analysis.

**Usage:** "Dependency-driven Prioritisation ensures work happens in the correct order."

---

## Human Integration

### User
Human stakeholder who provides input, makes decisions, and approves work. The primary human role in RHYTHM Method.

**Usage:** "The User approves the Feature specification."

**NOT:** "Customer", "Stakeholder", "Client", "Product Owner"

### HITL (Human-in-the-Loop)
Strategic human oversight and control at critical decision points while maintaining fast agent execution.

**Usage:** "HITL checkpoints are configured based on TEMPO level."

### HITL Checkpoint
Specific point where human approval, validation, or decision is required.

**Types:** Approval, Validation, Decision

**Usage:** "Feature approval is a HITL checkpoint at all TEMPO levels."

### HITL Gate
Same as HITL Checkpoint.

**Usage:** "High TEMPO has ~3-5 HITL gates per feature cycle."

---

## Estimation and Metrics

### Token
Unit of measurement for AI model consumption. Used as the basis for estimation in RHYTHM Method.

**Usage:** "Estimate tokens across four categories: Code, Analysis, Documentation, Validation."

**NOT:** "Story Points", "Hours", "Effort"

### Token Estimation
Methodology for estimating work using AI model token consumption instead of abstract story points.

**Usage:** "Token estimation provides precise, measurable estimates."

### Code Tokens
Tokens used for code generation and implementation.

**Usage:** "Code Tokens = Base LOC Tokens × Complexity × Pattern × Integration"

### Analysis Tokens
Tokens used for reading context, understanding requirements, and planning.

**Usage:** "Analysis Tokens account for context gathering and planning work."

### Documentation Tokens
Tokens used for creating documentation, comments, and explanations.

**Usage:** "Documentation Tokens include inline comments and README updates."

### Validation Tokens
Tokens used for testing, validation, and quality checks.

**Usage:** "Validation Tokens cover unit tests and integration testing."

### Token Roll-Up
Aggregation of token estimates from lower levels to higher levels (Agent Task → Work Unit → Feature).

**Usage:** "Token roll-up provides Feature-level estimates from Agent Task estimates."

### Estimated Tokens
Token estimate calculated during Task Breakdown cycle.

**Usage:** "Estimated tokens are compared to actual tokens for variance analysis."

### Actual Tokens
Actual token consumption tracked during Task Execution cycle.

**Usage:** "Actual tokens are used to refine future estimates."

### Token Variance
Difference between estimated and actual token usage.

**Usage:** "Token variance analysis improves estimation accuracy over time."

---

## Dependencies

### Dependency
Relationship where one work item requires another work item to be completed first.

**Types:** Technical, Data, Integration, Knowledge

**Usage:** "Dependencies are automatically detected and tracked."

### Technical Dependency
Code, API, or infrastructure dependency.

**Example:** Work Unit B imports code from Work Unit A

### Data Dependency
Database schema, data model, or migration dependency.

**Example:** Work Unit C requires database schema from Work Unit D

### Integration Dependency
External service, third-party API, or system integration dependency.

**Example:** Work Unit E integrates with payment service from Work Unit F

### Knowledge Dependency
Domain understanding, architectural decision, or design decision dependency.

**Example:** Work Unit G requires ADR decision before proceeding

### Dependency Level
Hierarchical level in the dependency graph (Level 0 = no dependencies, Level N = depends on Level N-1).

**Usage:** "Level 0 work can start immediately."

### Critical Path
Sequence of dependent tasks that determines the minimum time to complete a Feature.

**Usage:** "Blocked critical path triggers high-priority HITL notification."

---

## Quality and Review

### Quality Gate
Validation checkpoint that ensures work meets standards and specifications.

**Levels:** Agent Task, Work Unit, Feature

**Usage:** "Quality gates validate specification compliance."

### Quality Score
Numeric score representing quality assessment results.

**Usage:** "Quality score < 80 triggers HITL checkpoint."

### Review Loop
Iterative review process where WA (Review Engineer) reviews work and WA (Development Engineer) addresses feedback.

**Usage:** "Review loop threshold is 3 iterations by default."

### Challenge Loop
Iterative challenge process during Challenge Cycle where WAs challenge specifications and RA addresses challenges.

**Usage:** "Challenge loop threshold exceeded triggers HITL intervention."

### Quality Loop
Iterative quality validation process where work is tested, issues are fixed, and retested.

**Usage:** "Quality loop threshold is configurable in Project.Config."

### Loop Threshold
Maximum number of iterations allowed before HITL intervention is triggered.

**Default:** 3 for all loop types (configurable)

**Usage:** "Loop thresholds prevent infinite loops and ensure human oversight."

---

## Configuration

### Project.Manifest
High-level project understanding document capturing WHAT, WHY, WHO, and SUCCESS METRICS.

**Location:** `.baton/Project.Manifest.md`

**Format:** Markdown with structured sections

**Usage:** "Project.Manifest is relatively stable and updated quarterly."

### Project.Config
Operational configuration file for agents containing tools, resources, workflows, and settings.

**Location:** `.baton/project.config.yml`

**Format:** Pure YAML

**Usage:** "Project.Config changes frequently as operational needs evolve."

### TEMPO Level
Configuration setting that determines HITL checkpoint frequency.

**Values:** High, Moderate, Controlled

**Usage:** "Set TEMPO level in Project.Config rhythm section."

---

## States and Transitions

### State
Current status of a work item in its lifecycle.

**Usage:** "Work Unit state transitions from NEW to REVIEWED after Challenge Cycle."

### State Transition
Change from one state to another, triggered by cycle completion or HITL approval.

**Usage:** "State transitions are tracked for all work items."

### OPEN (Project State)
Project is active and work is ongoing.

**Usage:** "Project state is set to OPEN after initialization."

### CLOSED (Project State)
Project is complete or archived.

**Usage:** "Project state transitions to CLOSED when all Features are complete."

### NEW (Work Item State)
Work item has been created but not yet reviewed or started.

**Usage:** "Features start in NEW state after specification."

### READY (Work Item State)
Work item has been reviewed/approved and is ready for execution.

**Usage:** "Agent Tasks in READY state can be pulled from the work queue."

### REVIEWED (Work Unit State)
Work Unit has passed Challenge Cycle and is ready for Task Breakdown.

**Usage:** "Only REVIEWED Work Units proceed to Task Breakdown."

### IN PROGRESS (Work Item State)
Work item is currently being executed.

**Usage:** "Work Unit transitions to IN PROGRESS when first Agent Task starts."

### IN REVIEW (Work Item State)
Work item execution is complete and undergoing review/validation.

**Usage:** "Feature transitions to IN REVIEW when all Work Units are complete."

### COMPLETE (Work Item State)
Work item has passed all quality gates and is finished.

**Usage:** "Agent Task state is COMPLETE after quality validation passes."

### BLOCKED (Agent Task State)
Agent Task cannot proceed due to external blocker or dependency.

**Usage:** "Blocked tasks are flagged for HITL intervention."

---

## Processes

### Project Interview Process
Structured interview process conducted by BA to gather project information and create Project.Manifest.

**Usage:** "BA runs Project Interview Process during project initialization."

### Feature Interview Process
Structured interview process conducted by RA to gather feature requirements and create Feature specification.

**Usage:** "RA executes Feature Interview Process for each new Feature."

### Cycle Review Process
Review process at the end of each cycle to analyze performance and identify improvements.

**Usage:** "Cycle Review Process enables continuous methodology improvement."

### Human-in-the-Loop Check Process
Process for requesting human approval, validation, or decision at HITL checkpoints.

**Usage:** "HITL Check Process is triggered based on TEMPO configuration."

---

## Bug Relationships

### Parented Bug
Bug found during development, parented to the Work Unit being developed. Fixed within the current execution cycle.

**Usage:** "Parented bugs are part of Work Unit scope."

**Relationship:** Bug → Work Unit (parent)

### Related Bug
Bug found in production, related to a Feature. Requires a new Work Unit to fix.

**Usage:** "Related bugs follow normal prioritization as separate Work Units."

**Relationship:** Bug → Feature (related)

---

## Acronyms and Abbreviations

- **BA**: Baton Agent
- **RA**: RHYTHM Agent
- **WA**: Worker Agent
- **HITL**: Human-in-the-Loop
- **TEMPO**: (Not an acronym, refers to speed/pace)
- **WBS**: Work Breakdown Structure
- **LOC**: Lines of Code
- **PR**: Pull Request
- **ADR**: Architectural Decision Record
- **KPI**: Key Performance Indicator

---

## Terminology to Avoid

These terms are from traditional methodologies and should NOT be used in RHYTHM Method:

| ❌ Avoid | ✅ Use Instead |
|---------|---------------|
| Epic | Project Manifest |
| User Story | Feature |
| Task | Agent Task |
| Unit of Work | Work Unit |
| Sprint | Execution Cycle |
| Story Points | Tokens |
| Iteration | Execution Cycle |
| Backlog | Work Queue |
| Scrum Master | RA (RHYTHM Agent) |
| Product Owner | User |
| Customer | User |
| Stakeholder | User |
| Defect | Bug |
| Issue | Bug (or Work Unit, depending on context) |

---

## Usage Guidelines

### Capitalization

- **Capitalize:** Agent types (BA, RA, WA), TEMPO, HITL, Feature, Work Unit, Agent Task, Bug, Project Manifest
- **Lowercase:** tokens, cycle, workflow, process (unless part of a proper name)

### Plural Forms

- **Features** (not "Feature's")
- **Work Units** (not "Work Unit's")
- **Agent Tasks** (not "Agent Task's")
- **Bugs** (not "Bug's")

### Possessive Forms

- **Feature's specification** (singular possessive)
- **Work Units' dependencies** (plural possessive)

---

## See Also

- [Core Concepts](01-core-concepts.md) - Detailed explanation of core concepts
- [Work Breakdown Structure](06-work-breakdown-structure.md) - WBS hierarchy details
- [Best Practices](12-best-practices.md) - Terminology best practices

---

## Navigation

**Previous:** [Quick Reference](16-quick-reference.md) - Quick reference guide

---

## Change History

| Version | Date       | Author | Description                          |
| ------- | ---------- | ------ | ------------------------------------ |
| 1.0.0   | 2025-12-14 | Agent  | Initial comprehensive dictionary     |
