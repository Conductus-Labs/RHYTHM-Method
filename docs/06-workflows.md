# RHYTHM Method Workflows

**Version:** 1.1.0  
**Last Updated:** 2025-11-26  
**Status:** Updated with Work Unit Review Clarifications

## Overview

RHYTHM Method workflows are designed for **agents with human integration**. Workflows leverage agent capabilities (speed, precision, automation) while maintaining essential human oversight and strategic control.

## Core Workflows

The following diagram illustrates how RHYTHM Method workflows connect and flow together:

```
One-Time Setup:
  1. Project Initialization

Planning & Preparation Cycle:
  2. Feature Specification
  3. Work Unit Creation
  4. Work Unit Review
  5. Work Unit Breakdown

Execution Cycle:
  6. Work Queue
  → Task Execution
  7. Continuous Planning
  8. Dependency Management
  9. Quality Assurance
  10. Cycle Review
```

> **Note:** Project Initialization (step 1) is a one-time setup that occurs only once at the beginning of a project. All other workflows are ongoing and repeat as needed throughout the project lifecycle.

### 1. Project Initialization

**Purpose:** Establish the foundation for RHYTHM Method in a project.

**Process:**

1. **Create Project Manifest**

   - Single source of truth for project requirements
   - Project information repository
   - Decision log for architectural decisions and requirement changes
   - Human validation required

2. **Configure RHYTHM Settings**

   - TEMPO settings (High, Moderate, Controlled) - see [TEMPO](05-tempo.md)
   - HITL gate configuration
   - Agent capacity and specialization
   - Quality gate thresholds

3. **Initialize Work Queue**
   - Set up dependency tracking
   - Configure prioritization rules
   - Establish validation criteria

**Human Involvement:**

- Validate Project Manifest
- Approve RHYTHM configuration
- Provide strategic guidance

**Agent Involvement:**

- Generate Project Manifest template
- Analyze project structure and dependencies
- Set up automated workflows

### 2. Feature Specification

**Purpose:** Create detailed specifications for features before implementation.

**Process:**

1. **Feature Definition**

   - Business value and objectives
   - User requirements and validation criteria
   - Technical constraints and interfaces
   - Human validation required

2. **Dependency Analysis**

   - Automated dependency detection (see [Dependency Management](09-dependency-management.md))
   - Dependency graph updates
   - Impact analysis
   - Human review of critical dependencies

3. **Specification Creation**
   - Detailed, structured specification document
   - Machine-readable format (YAML/JSON)
   - Validation criteria definition
   - Human approval required

**Human Involvement:**

- Define business requirements
- Validate specifications
- Approve feature scope
- Review critical dependencies

**Agent Involvement:**

- Analyze requirements
- Detect dependencies automatically
- Generate specification documents
- Validate specification completeness

### 3. Work Unit Creation

**Purpose:** Break down features into executable work units.

**Process:**

1. **Feature Breakdown**

   - Analyze feature specification
   - Identify work unit boundaries
   - Define work unit dependencies
   - Human validation of breakdown

2. **Work Unit Specification**

   - Detailed work unit requirements
   - Agent Task identification
   - Agent assignment planning
   - Token estimation

3. **Work Unit Assignment**
   - Add to prioritized work queue
   - Dependency-driven prioritization
   - Agent capacity allocation
   - Human approval for high-priority work

**Human Involvement:**

- Validate work unit breakdown
- Approve work unit priorities
- Review agent assignments

**Agent Involvement:**

- Analyze feature specifications
- Create work unit breakdown
- Estimate tokens
- Update dependency graph

### 4. Work Unit Review

**Purpose:** Review and refine Features and Work Units created by Users and the RHYTHM Agent, providing feedback, challenges, and acceptance before proceeding to breakdown. This workflow validates that specifications are clear, complete, and feasible before breaking them down into executable tasks.

**Key Distinction from Work Unit Breakdown:**

- **Work Unit Review**: Validates and refines the Work Unit specification itself (what needs to be built)
- **Work Unit Breakdown**: Creates executable Agent Tasks from an approved Work Unit specification (how it will be built)

**Process:**

1. **Agent Review**

   - **Reviewing Agents**: Specialized agents (e.g., technical-writer-agent, analysis agents) or the RHYTHM Agent review Feature and Work Unit specifications
   - **Review Criteria**: Agents evaluate specifications against:
     - **Clarity**: Requirements are unambiguous and well-defined
     - **Completeness**: All necessary information is present (business value, validation criteria, technical constraints, dependencies)
     - **Feasibility**: Work can be completed within execution cycle constraints (up to 8 hours)
     - **Consistency**: Specifications align with Project Manifest and existing features
     - **Testability**: Validation criteria are clear and measurable
   - **Feedback Format**: Structured feedback includes:
     - **Issues Found**: Specific problems with clarity, completeness, or feasibility
     - **Assumptions Challenged**: Unstated assumptions that need clarification
     - **Missing Information**: Required details not present in specification
     - **Suggestions**: Recommended improvements or clarifications
     - **Risk Identification**: Potential issues that could affect execution
   - **Challenge Triggers**: Agents challenge assumptions when:
     - Requirements are ambiguous or open to interpretation
     - Technical constraints are unclear or missing
     - Dependencies are not fully identified
     - Validation criteria are vague or unmeasurable
     - Business value is not clearly articulated
     - Work scope appears too large for a single execution cycle
   - Human review of agent feedback

2. **Review Resolution**

   - Address agent feedback and challenges
   - Update specifications based on review findings
   - Resolve conflicts or ambiguities identified
   - Clarify assumptions and add missing information
   - Human approval of resolved items

3. **Review Acceptance**
   - Final validation that all review items are resolved
   - Approval from all stakeholders (User, reviewing agents)
   - **Ready for Breakdown Criteria**: Work Unit is marked ready when:
     - Specification is clear and unambiguous
     - All required information is present
     - Feasibility is confirmed (can be completed in execution cycle)
     - Dependencies are identified
     - Validation criteria are defined
     - No outstanding challenges or unresolved issues
   - Human sign-off required to proceed to Work Unit Breakdown

**Human Involvement:**

- Review agent feedback and challenges
- Resolve conflicts and ambiguities
- Update specifications based on agent feedback
- Approve updated specifications
- Provide final sign-off marking Work Unit as ready for breakdown

**Agent Involvement:**

- Review Feature and Work Unit specifications using structured criteria
- Provide structured feedback on clarity, completeness, and feasibility
- Challenge assumptions and identify potential issues
- Suggest improvements or clarifications
- Validate specification completeness against review criteria

**Review Output:**

- Updated specification document (if changes were made)
- Review feedback document (structured feedback from agents)
- Resolution log (how each challenge/issue was addressed)
- Acceptance confirmation (Work Unit marked as ready for breakdown)

> **Note:** This workflow is similar to backlog refinement in traditional methodologies, but adapted for agentic review and human validation. The review focuses on specification quality before task breakdown, ensuring Work Units are well-defined and feasible before execution planning begins.

### 5. Work Unit Breakdown

**Purpose:** Break down approved Work Units into executable Agent Tasks after Work Unit Review is complete. See [Work Breakdown Structure](07-work-breakdown-structure.md) for WBS details and [Estimation](08-estimation.md) for token estimation.

**Process:**

1. **Task Identification**

   - Analyze approved Work Unit specification
   - Identify required Agent Tasks
   - Determine task dependencies
   - Estimate task complexity and token requirements
   - Human validation of task breakdown

2. **Task Specification**

   - Create detailed Agent Task specifications
   - Define task acceptance criteria
   - Assign tasks to specialized agents
   - Set task priorities within Work Unit
   - Human approval of task assignments

3. **Task Readiness**
   - Validate all tasks are properly specified
   - Ensure dependencies are identified
   - Confirm agent assignments are appropriate
   - Mark tasks as ready for execution
   - Human approval for task readiness

**Human Involvement:**

- Validate task breakdown
- Approve task specifications
- Review and approve agent assignments
- Provide final approval for task readiness

**Agent Involvement:**

- Analyze Work Unit specifications
- Create Agent Task breakdown
- Identify task dependencies
- Estimate token requirements
- Assign tasks to appropriate specialized agents

### 6. Work Queue

**Purpose:** Maintain a prioritized queue of ready Agent Tasks waiting for execution. See [Dependency Management](09-dependency-management.md) for dependency-driven prioritization details.

**Process:**

1. **Queue Management**

   - Receive Agent Tasks from [Work Unit Breakdown](#5-work-unit-breakdown)
   - Apply dependency-driven prioritization
   - Order tasks by dependency resolution status
   - Maintain real-time queue status

2. **Task Readiness Validation**

   - Verify all dependencies are resolved
   - Confirm task specifications are complete
   - Check agent capacity availability
   - Human approval for high-priority items

3. **Queue Updates**
   - Real-time updates from [Continuous Planning](#7-continuous-planning)
   - [Dependency Management](#8-dependency-management) reordering
   - Priority adjustments based on business value
   - Human visibility and control

**Human Involvement:**

- Review queue priorities
- Approve high-priority task execution
- Override prioritization when needed
- Strategic queue management

**Agent Involvement:**

- Automatically maintain queue order
- Update priorities based on dependency changes
- Real-time queue status reporting
- Capacity-aware queue management

### Task Execution

**Purpose:** Execute Agent Tasks pulled from the [Work Queue](#6-work-queue), performing the actual development work in focused execution cycles (up to 8 hours, some cycles may be less than 2 hours). See [TEMPO](05-tempo.md) for details on execution cycles.

**Process:**

1. **Task Pulling**

   - Pull ready Agent Tasks from [Work Queue](#6-work-queue)
   - Verify dependencies are resolved
   - Allocate specialized agents
   - Human approval for cycle scope

2. **Parallel Task Execution**

   - Specialized agents execute assigned tasks
   - Parallel execution across multiple agents
   - Real-time status updates
   - Automated dependency resolution during execution

3. **Execution Monitoring**
   - Real-time progress tracking
   - Automated status reporting
   - Blocked task detection
   - Human visibility through dashboards

**Human Involvement:**

- Approve execution cycle scope
- Monitor execution progress
- Resolve blockers when needed
- Strategic guidance

**Agent Involvement:**

- Execute tasks at fast TEMPO
- Coordinate multi-agent work
- Automated task execution
- Real-time status reporting

> **Note:** Task Execution is part of the Execution Cycle workflow. After tasks are executed, they flow through [Quality Assurance](#9-quality-assurance) for validation and [Cycle Review](#10-cycle-review) for process improvement. Task Execution also triggers [Continuous Planning](#7-continuous-planning) and [Dependency Management](#8-dependency-management) to keep the system synchronized.

### 7. Continuous Planning

**Purpose:** Maintain up-to-date plans based on real-time information. See [Estimation](08-estimation.md) for token-based capacity planning details.

**Process:**

1. **Real-Time Plan Updates**

   - Automatic plan updates as work progresses
   - Dependency graph changes
   - Priority adjustments
   - Capacity reallocation

2. **Dynamic Replanning**

   - Instant replanning when priorities change
   - Dependency resolution updates
   - Work queue reordering
   - Human notification of major changes

3. **Capacity Planning**
   - Token-based capacity calculation (see [Estimation](08-estimation.md))
   - Agent throughput rate analysis
   - Work queue prioritization
   - Human review of capacity plans

**Human Involvement:**

- Review major plan changes
- Approve priority adjustments
- Strategic guidance

**Agent Involvement:**

- Automated plan updates
- Dependency analysis
- Capacity calculations
- Real-time replanning

### 8. Dependency Management

**Purpose:** Manage dependencies automatically with human oversight. See [Dependency Management](09-dependency-management.md) for detailed information.

**Process:**

1. **Dependency Detection**

   - Automated dependency analysis
   - Technical, data, integration, knowledge dependencies
   - Dependency graph maintenance
   - Human review of critical dependencies

2. **Dependency Resolution**

   - Dependency-driven prioritization
   - Work queue ordering
   - Parallel execution where possible
   - Human approval for dependency overrides

3. **Dependency Tracking**
   - Real-time dependency graph
   - Critical path identification
   - Blocked work detection
   - Human visibility and alerts

**Human Involvement:**

- Review critical dependencies
- Approve dependency overrides
- Strategic dependency decisions

**Agent Involvement:**

- Automated dependency detection
- Dependency graph maintenance
- Prioritization automation
- Real-time tracking

### 9. Quality Assurance

**Purpose:** Ensure quality through automated gates and HITL checkpoints.

**Process:**

1. **Automated Quality Gates**

   - Code quality checks
   - Automated testing
   - Performance validation
   - Security scanning

2. **HITL Checkpoints**

   - Human review at critical milestones
   - Specification validation
   - Deployment approval
   - Strategic decision points

3. **Continuous Validation**
   - Real-time quality monitoring
   - Automated test execution
   - Validation against specifications
   - Quality metrics tracking

**Human Involvement:**

- Review quality gate results
- Approve deployments
- Strategic quality decisions

**Agent Involvement:**

- Automated quality checks
- Test execution
- Quality metrics collection
- Real-time reporting

### 10. Cycle Review

**Purpose:** Analyze execution cycles and improve the process.

**Process:**

1. **Automated Analysis**

   - Cycle performance metrics
   - Token estimation accuracy (see [Estimation](08-estimation.md))
   - Dependency resolution effectiveness (see [Dependency Management](09-dependency-management.md))
   - Quality gate results

2. **Process Improvement**

   - Identify improvement opportunities
   - Suggest workflow optimizations
   - Update estimation models
   - Refine quality gates

3. **Learning Integration**
   - Update methodology based on learnings
   - Improve agent coordination
   - Optimize HITL checkpoints
   - Enhance dependency management

**Human Involvement:**

- Review cycle analysis
- Approve process improvements
- Strategic methodology decisions

**Agent Involvement:**

- Automated cycle analysis
- Process improvement suggestions
- Methodology refinement
- Learning integration

> **Note:** Workflows embody the six core principles of RHYTHM Method (TEMPO, Flow, Control, Coordination, Precision, Adaptive). See [Principles](04-principles.md) for detailed explanations of these principles.

## Workflow Integration

### Workflows Work Together

RHYTHM Method workflows are integrated:

- **[Project Initialization](#1-project-initialization)** → Sets up all workflows
- **[Feature Specification](#2-feature-specification)** → Feeds into [Work Unit Creation](#3-work-unit-creation)
- **[Work Unit Creation](#3-work-unit-creation)** → Feeds into [Work Unit Review](#4-work-unit-review)
- **[Work Unit Review](#4-work-unit-review)** → Feeds into [Work Unit Breakdown](#5-work-unit-breakdown)
- **[Work Unit Breakdown](#5-work-unit-breakdown)** → Feeds into [Work Queue](#6-work-queue)
- **[Work Queue](#6-work-queue)** → Feeds into Task Execution
- **Task Execution** → Feeds into [Quality Assurance](#9-quality-assurance)
- **[Quality Assurance](#9-quality-assurance)** → Feeds into [Cycle Review](#10-cycle-review)
- **Task Execution** → Triggers [Continuous Planning](#7-continuous-planning) and [Dependency Management](#8-dependency-management)
- **[Continuous Planning](#7-continuous-planning)** → Informs [Work Queue](#6-work-queue)
- **[Dependency Management](#8-dependency-management)** → Informs [Work Queue](#6-work-queue)
- **[Quality Assurance](#9-quality-assurance)** → Validates Task Execution
- **[Cycle Review](#10-cycle-review)** → Improves Task Execution and all workflows

### Optimizing Workflow Flow: Reducing Bottlenecks

**The Challenge:**
The sequential workflow (Feature Specification → Work Unit Creation → Work Unit Review → Work Unit Breakdown → Work Queue) can create bottlenecks if each step requires human approval, defeating the purpose of fast TEMPO.

**Optimization Strategies:**

#### 1. TEMPO-Based Approval Streamlining

**High TEMPO:**
- **Feature Specification**: Human approval required
- **Work Unit Creation**: Auto-approved if Feature approved
- **Work Unit Review**: Auto-approved for well-defined work (agent review only)
- **Work Unit Breakdown**: Auto-approved if Review passed
- **Work Queue**: Auto-approved for ready tasks

**Moderate TEMPO (Default):**
- **Feature Specification**: Human approval required
- **Work Unit Creation**: Human approval for high-value work, auto-approved for routine work
- **Work Unit Review**: Human approval required
- **Work Unit Breakdown**: Human approval for task assignments
- **Work Queue**: Human approval for high-priority items

**Controlled TEMPO:**
- All steps require human approval (comprehensive oversight)

#### 2. Parallel Review Processes

**Work Unit Review and Breakdown Can Overlap:**
- While Work Unit A is being reviewed, Work Unit B can be broken down (if already reviewed)
- Multiple Work Units can be reviewed in parallel by different agents
- Review feedback can be addressed while breakdown proceeds for other Work Units

**Parallel Feature Processing:**
- Multiple Features can be specified simultaneously
- Work Unit Creation can happen in parallel for different Features
- Review and Breakdown can happen in parallel for different Work Units

#### 3. Automated Approval Criteria

**Auto-Approval Triggers (High/Moderate TEMPO):**
- **Well-Defined Work**: Specifications match established patterns → Auto-approved
- **Low-Risk Work**: Work Units with clear requirements, no dependencies → Auto-approved
- **Routine Work**: Similar to previously completed work → Auto-approved
- **Agent Confidence**: Agent review passes with high confidence score → Auto-approved

**Human Approval Required:**
- **High-Risk Work**: Complex integrations, critical systems, new domains
- **Ambiguous Requirements**: Specifications unclear or incomplete
- **High Business Value**: Strategic features requiring business validation
- **Agent Uncertainty**: Agent review flags issues or low confidence

#### 4. Streamlined Approval for Well-Defined Work

**Well-Defined Work Characteristics:**
- Clear, complete specifications
- Established patterns (similar to previous work)
- Low complexity
- Minimal dependencies
- Standard technology stack

**Streamlined Process:**
1. Agent performs review automatically
2. If review passes (high confidence, no issues) → Auto-approved
3. If review flags issues → Human approval required
4. Human can batch-approve multiple well-defined Work Units

#### 5. Batch Approvals

**Efficiency Strategy:**
- Humans can review and approve multiple Work Units in a batch
- Approval queue shows all pending approvals
- Human reviews batch, approves all that pass criteria
- Reduces context switching and approval overhead

#### 6. Approval Delegation and Defaults

**Approval Delegation:**
- Low-risk Work Units can be auto-approved based on agent confidence
- High-risk Work Units always require human approval
- Medium-risk Work Units can be delegated to agents with human oversight

**Default Behaviors:**
- If human unavailable: Auto-approve low-risk work, queue high-risk work
- Timeout mechanisms: Auto-approve after timeout for low-risk work (with notification)
- Escalation: High-risk work escalates if human doesn't respond

#### 7. Workflow Bypass for Urgent Work

**Emergency/Urgent Work:**
- Critical bugs or urgent features can bypass some approval steps
- Requires explicit human override
- Post-approval review after execution
- Used sparingly for true emergencies

**For detailed workflow best practices, see [Best Practices](10-best-practices.md#workflow-best-practices).**

### Continuous Improvement

Workflows improve over time:

- Cycle Review analyzes workflow effectiveness
- Process improvements are integrated automatically
- Methodology evolves based on learnings
- Human feedback enhances workflows

## Summary

RHYTHM Method workflows are designed for agents with human integration, enabling agents to operate at their full potential (fast TEMPO) while ensuring humans maintain strategic control and oversight (RHYTHM). The core workflows include one-time setup (Project Initialization), planning and preparation cycles (Feature Specification, Work Unit Creation, Work Unit Review, Work Unit Breakdown), and execution cycles (Work Queue, Task Execution, Continuous Planning, Dependency Management, Quality Assurance, Cycle Review). These workflows work together in an integrated system that supports continuous execution, dependency-driven prioritization, and human-in-the-loop checkpoints.

---

## Navigation

**Previous:** [TEMPO](05-tempo.md) - Understanding TEMPO: the speed/pace at which agents operate  
**Next:** [Work Breakdown Structure](07-work-breakdown-structure.md) - WBS hierarchy

---

## Change History

| Version | Date       | Author              | Description                                                                                                                                                |
| ------- | ---------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0.0   | 2025-11-24 | Initial             | Initial RHYTHM workflows docs                                                                                                                              |
| 1.1.0   | 2025-11-26 | rhythm-expert-agent | Clarified Work Unit Review workflow: agent roles, review criteria, feedback format, ready-for-breakdown criteria, and distinction from Work Unit Breakdown |
