# RHYTHM Method Dictionary

**Version:** 1.2.0  
**Last Updated:** 2025-11-26  
**Status:** Updated with Relationship Definitions Clarification

This dictionary defines key terms and concepts used throughout RHYTHM Method documentation.

## Core Concepts

### Agent

An AI system capable of performing development tasks autonomously or semi-autonomously. Agents can be specialized (Backend Agent, Frontend Agent, QA Agent, etc.) or general ([RHYTHM Agent](#rhythm-agent)).

### Agentic Development Environment (ADE)

A development environment where [AI agents](#agent) perform development work, either autonomously or in coordination with humans.

### Bug

A defect or issue that needs to be fixed. In RHYTHM Method, Bugs must be [**parented**](#parented) to a [Work Unit](#work-unit) (bug found during development) or [**related**](#related) to a [Feature](#feature) (bug found in production).

### Dependency

A relationship where one work item requires another to be completed first. Dependencies can be technical (code, API, infrastructure), data (database schema), integration (external services), or knowledge (domain understanding).

### Dependency-Driven Prioritization

A mandatory prioritization rule in RHYTHM Method where work is ordered by [dependency graph](#dependency-graph) first, then by business value within the same dependency level. [Dependencies](#dependency) must be resolved before dependent work can begin.

### Project Manifest

The top-level container for all [Features](#feature) in a RHYTHM Method project. The Project Manifest **completely replaces Epics** from traditional product management processes (Scrum, Kanban, etc.) and replaces Constitution files from [Spec-Driven Development](#spec-driven-development-sdd).

**Important:** Epics do **not** exist in RHYTHM Method. The Project Manifest is the only top-level container.

**Comparison to Traditional Epics:**
- **Traditional Epics**: Optional, can be multiple per project
- **Project Manifest**: Mandatory, exactly one per project
- **Traditional Epics**: Only serve as top-level containers
- **Project Manifest**: Serves three roles: (1) top-level container for all Features, (2) project information repository (similar to Constitutions in SDD), and (3) decision log tracking architectural decisions and requirement changes (similar to ADRs)

**Implementation and Storage:**

The Project Manifest is stored as a markdown file (`.baton/project.manifest.md`) in the repository. This file serves as the **single source of truth** for project information.

**Relationship to Project Management Tools:**

The Project Manifest markdown file is the authoritative source. Features may be tracked in project management tools (GitHub Issues, Azure DevOps, Jira, etc.), but the Project Manifest file maintains the conceptual parent-child relationship.

**Important Considerations:**
- **Single Source of Truth**: The markdown file (`.baton/project.manifest.md`) is the source of truth
- **PM Tool Integration**: Features tracked in PM tools (e.g., GitHub Issues) reference the Project Manifest conceptually, not through direct links
- **Sync Concerns**: To avoid sync issues, the Project Manifest should **not** be duplicated in PM tools. Instead:
  - Project Manifest = Markdown file (source of truth)
  - Features = Tracked in PM tools, conceptually parented to Project Manifest
  - The markdown file links to or references Features, but doesn't duplicate PM tool data
- **Git Ignore**: The `.baton/` directory (containing the Project Manifest) is typically in `.gitignore`, meaning the Project Manifest is local to each developer/agent environment, not committed to the repository

This creates a single source of truth that both [Users](#user) and [Agents](#agent) can reference to understand project requirements and their evolution.

### Execution Cycle

A focused work period in RHYTHM Method, up to 8 hours (some cycles may be less than 2 hours), that replaces traditional 2-week sprints. Execution cycles focus on single [features](#feature), [dependency](#dependency) chains, or project objectives and result in deployed, tested, validated code.

### Feature

A required deliverable unit of functionality that provides business value. Features must contain [Work Units](#work-unit), can be deployed independently, and have clear validation criteria.

### Human-in-the-Loop (HITL)

The integration of human oversight, decision-making, and validation at critical points in the development process. HITL ensures humans provide strategic input, validate [specifications](#specification), and approve major decisions while [agents](#agent) handle execution.

### RHYTHM Agent

A specialized [agent](#agent) responsible for coordination, prioritization, and [user](#user) management in RHYTHM Method. The RHYTHM Agent replaces the traditional Project Manager Agent for [agentic development environments](#agentic-development-environment-ade).

**Terminology Clarification:**
- **"RHYTHM Agent"** is the role/type name (conceptual term for the agent responsible for RHYTHM Method coordination)
- **"rhythm-expert-agent"** is a specific implementation/agent name (the actual agent that performs this role in the Baton Framework)
- **"baton-agent"** (baton-framework-agent) is a different agent responsible for Baton Framework management, not RHYTHM Method coordination

**In Practice:**
The `rhythm-expert-agent` is the agent that performs the RHYTHM Agent role. When documentation refers to "RHYTHM Agent," it means the agent responsible for RHYTHM Method coordination (typically implemented as the `rhythm-expert-agent`). The term "RHYTHM Agent" is used in documentation to refer to the role, while `rhythm-expert-agent` is the specific agent name used in configuration and implementation.

### RHYTHM Method

**R**apid, **H**igh-**Y**ield, **T**oken-based, **H**uman-in-loop, **M**anagement - A project management methodology specifically designed for [agents](#agent) with human integration. RHYTHM Method adapts proven principles from Agile, Scrum, Kanban, and [Spec-Driven Development](#spec-driven-development-sdd) for AI [agent](#agent) teams.

### Scope Creep

The uncontrolled expansion of project scope beyond original requirements. RHYTHM Method prevents scope creep by distinguishing between bugs (fix in current work) and new requests (create new [Work Unit](#work-unit)).

### Specification

A detailed, structured document that acts as a contract defining what will be built. Specifications include system behavior, constraints, interfaces, and test expectations. In RHYTHM Method, specifications are created before implementation and validated by [users](#user).

### Agent Task

The smallest unit of executable work in RHYTHM Method. Agent Tasks must belong to a [Work Unit](#work-unit), can be completed by a single [agent](#agent), typically taking less than 1 hour, and have clear completion criteria.

### TEMPO

A concept within RHYTHM Method describing the **speed/pace at which agents operate**. [Agents](#agent) work at fast computational speeds (hours, not weeks), but [RHYTHM](#rhythm) ensures control, flow, and [HITL](#human-in-the-loop-hitl) integration.

### Token

A unit of measurement used in RHYTHM Method for estimation. Tokens represent code generation, analysis, documentation, and validation work. [Token estimation](#token-estimation) replaces abstract story points with precise, measurable factors.

### Token Estimation

A precise estimation method in RHYTHM Method that calculates work based on measurable factors ([tokens](#token)) rather than abstract concepts (story points). Token estimates account for code generation, analysis, documentation, and validation.

### User

The human stakeholder who provides requirements, validates [specifications](#specification), makes strategic decisions, and approves deliverables. In RHYTHM Method, "User" replaces traditional terms like "customer" or "stakeholder" to emphasize the [Human-in-the-Loop](#human-in-the-loop-hitl) relationship.

### Work Unit

A required agentic-specific term for a specific piece of work that can be completed in a single [execution cycle](#execution-cycle). Work Units must belong to a [Feature](#feature), contain [Agent Tasks](#agent-task), and are the atomic unit of work assignment to specialized [agents](#agent).

## Methodology Terms

### Continuous Execution Model

An execution model in RHYTHM Method where work happens continuously without discrete sprints. [Agents](#agent) pull work from a prioritized queue, work in parallel, and deploy when validated.

### Dependency Graph

A real-time visualization of all [dependencies](#dependency) between [work units](#work-unit). The dependency graph is automatically maintained and used for [prioritization](#dependency-driven-prioritization) and critical path identification.

### Quality Gate

An automated checkpoint where code, tests, and [specifications](#specification) are validated. Quality gates may also include [Human-in-the-Loop](#human-in-the-loop-hitl) review and approval at critical milestones.

### Spec-Driven Development (SDD)

A development methodology where detailed, structured [specifications](#specification) act as contracts between [agents](#agent), [users](#user), and the system. All work begins with comprehensive specifications that are validated before implementation.

**Note:** RHYTHM Method is an alternative to SDD, not a modification of it. RHYTHM Method can incorporate SDD principles but is designed specifically for agents with human integration.

### Work Breakdown Structure (WBS)

The hierarchical structure for organizing work in RHYTHM Method: [Project Manifest](#project-manifest) → [Features](#feature) → [Work Units](#work-unit) → [Agent Tasks](#agent-task).

## Process Terms

### Continuous Planning

A planning approach in RHYTHM Method where plans are continuously updated based on real-time information, rather than being fixed for sprint durations.

### Dynamic Replanning

The ability to instantly replan when priorities or [dependencies](#dependency) change, without the overhead of meetings or coordination that makes replanning costly for human teams.

### Living Documents

Documents that are automatically maintained and updated as work progresses. [Specifications](#specification), roadmaps, and plans are living documents in RHYTHM Method, staying current without manual maintenance.

### Real-Time Visibility

Complete visibility into all work, progress, and decisions in real-time through automated dashboards, rather than periodic status updates or meetings.

## Agent Terms

### Agent Capacity

The maximum amount of work that can be completed given **user availability** for Human-in-the-Loop (HITL) checkpoints and approvals. Agents are not limited by time—they can work continuously. Capacity is constrained by how often users can review, approve, and provide strategic input at HITL gates. See [Estimation](08-estimation.md) for capacity planning details.

### Agent Coordination

The process by which multiple specialized [agents](#agent) work together on complex tasks, coordinating through structured interfaces and shared context.

### Agent Specialization

The focus of an [agent](#agent) on a specific domain (Backend, Frontend, DevOps, QA, etc.). Specialized agents have deep expertise in their domain.

### Multi-Agent Collaboration

The coordination of multiple specialized [agents](#agent) working together on complex tasks, enabled by structured interfaces and shared context.

## Estimation Terms

### Token Throughput Rate

The rate at which an [agent](#agent) processes [tokens](#token), measured in tokens per hour. Throughput rates vary by agent capability and task complexity.

### Token Count

The total number of [tokens](#token) required for a [work unit](#work-unit), calculated as: Code Tokens + Analysis Tokens + Documentation Tokens + Validation Tokens.

### Roll-Up Estimation

The process of aggregating estimates from lower levels to higher levels in the [WBS](#work-breakdown-structure-wbs) hierarchy ([Agent Task](#agent-task) → [Work Unit](#work-unit) → [Feature](#feature) → [Project Manifest](#project-manifest)).

## Work Item Relationships

### Parented

A parent-child relationship where a child item belongs to a parent. In RHYTHM Method:

- **Work Units** are parented to **Features** (Work Unit belongs to Feature)
- **Agent Tasks** are parented to **Work Units** (Agent Task belongs to Work Unit)
- **Bugs (Development)** are parented to **Work Units** (bug found during development, fixed within current execution cycle)

**Key Characteristic**: Parented items are part of the parent's scope and must be completed as part of the parent.

### Related

A relationship where items are connected but not in a parent-child hierarchy. In RHYTHM Method:

- **Bugs (Production)** are related to **Features** (bug found in production, requires new Work Unit to fix)
- **Work Units** can be related to other **Work Units** (non-dependency relationships, e.g., related functionality)

**Key Characteristic**: Related items are separate work items that may require their own Work Units or have independent completion criteria.

### Dependency

See **Dependency** in Core Concepts section.

---

## Navigation

**Previous:** [Getting Started](02-getting-started.md) - How to adopt RHYTHM Method  
**Next:** [Principles](04-principles.md) - Core principles of RHYTHM Method

---

## Change History

| Version | Date       | Author              | Description                                                          |
| ------- | ---------- | ------------------- | -------------------------------------------------------------------- |
| 1.0.0   | 2025-11-24 | Initial             | Initial RHYTHM dictionary docs                                        |
| 1.1.0   | 2025-11-26 | rhythm-expert-agent | Clarified RHYTHM Agent terminology: role vs implementation, relationship to rhythm-expert-agent and baton-agent |
| 1.2.0   | 2025-11-26 | rhythm-expert-agent | Clarified Parented vs Related relationship definitions with examples and key characteristics |
