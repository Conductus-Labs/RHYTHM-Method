# State Management

This document defines the state transitions for all work item types in RHYTHM Method.

---

## Overview

RHYTHM Method uses structured state transitions to track progress, enable coordination between agents, and provide visibility into work status.

**Key Principles:**
1. States can only transition forward (except for failure loops)
2. State transitions are triggered by specific cycle completions or agent actions
3. HITL checkpoints can occur at state transitions (configured by TEMPO)
4. RA orchestrates most state transitions; WAs set Agent Task states

---

## Project States

```text
OPEN → CLOSED
```

### Transitions

- **OPEN → CLOSED**: Project complete, no further work planned

### Details

| State | Description | Set By | When |
|-------|-------------|--------|------|
| **OPEN** | Project is active and work is ongoing | BA | Project Initialisation complete |
| **CLOSED** | Project is complete and no further work planned | RA or User | All Features complete, project archived |

**Triggered By:**
- **OPEN**: BA during Project Initialisation cycle
- **CLOSED**: User or RA when project complete

---

## Feature States

```text
NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE
                                 ↑            |
                                 |__(fail)____|
```

### Transitions

- **NEW → READY**: After Feature Specification cycle and HITL approval
- **READY → IN PROGRESS**: When Task Breakdown cycle begins for first Work Unit
- **IN PROGRESS → IN REVIEW**: When all Work Units are COMPLETE
- **IN REVIEW → COMPLETE**: When Feature-level quality gates pass and HITL approval received
- **IN REVIEW → IN PROGRESS**: When Feature-level quality gates fail (affected Work Units need fixes)

### Details

| State | Description | Set By | When |
|-------|-------------|--------|------|
| **NEW** | Created during Feature Specification cycle | RA | Feature Interview Process initiated |
| **READY** | Specification approved, ready for breakdown | RA | After Feature Interview Process and HITL approval |
| **IN PROGRESS** | Work Units being created or executed | RA | First Work Unit breakdown begins |
| **IN REVIEW** | All Work Units complete, Feature validation in progress | RA | All Work Units are COMPLETE |
| **COMPLETE** | Feature-level quality gates passed and approved | RA | Feature quality gates pass and HITL approval |

**Failure Loop:**
- **IN REVIEW → IN PROGRESS**: When Feature-level quality gates fail
  - Affected Work Units are reset to IN PROGRESS
  - Development Engineers fix issues
  - Loop back through Task Execution

**HITL Checkpoints:**
- **READY**: Feature specification approval
- **COMPLETE**: Feature completion approval (Moderate/Controlled TEMPO)

---

## Work Unit States

```text
NEW → REVIEWED → READY → IN PROGRESS → IN REVIEW → COMPLETE
                                ↑                      |
                                |______(on failure)____|
```

### Transitions

- **NEW → REVIEWED**: After Challenge Cycle (all WAs approve, no challenges remaining)
- **REVIEWED → READY**: After Task Breakdown cycle (all Agent Tasks created and validated)
- **READY → IN PROGRESS**: When first Agent Task begins execution
- **IN PROGRESS → IN REVIEW**: When all Agent Tasks are IN REVIEW
- **IN REVIEW → COMPLETE**: When all quality gates pass and HITL approval received
- **IN REVIEW → IN PROGRESS**: When quality gates fail (Work Unit needs fixes)

### Details

| State | Description | Set By | When |
|-------|-------------|--------|------|
| **NEW** | Created during Work Unit Creation cycle | RA | Work Unit specification created |
| **REVIEWED** | Challenged and approved by WAs | RA | Challenge Cycle complete (all WAs approve) |
| **READY** | Agent Tasks created, ready for execution | RA | Task Breakdown cycle complete |
| **IN PROGRESS** | Agent Tasks being executed | RA | First Agent Task starts execution |
| **IN REVIEW** | All Agent Tasks complete, validation in progress | RA | All Agent Tasks are IN REVIEW |
| **COMPLETE** | All quality gates passed and approved | RA | Quality gates pass and HITL approval |

**Failure Loop:**
- **IN REVIEW → IN PROGRESS**: When Agent Task quality gates fail
  - Failed Agent Tasks reset to IN PROGRESS (or earlier state)
  - Development Engineers fix issues
  - Loop back through review and quality validation

**HITL Checkpoints:**
- **REVIEWED**: Work Unit challenge approval (Moderate/Controlled TEMPO)
- **READY**: Task breakdown validation (Moderate/Controlled TEMPO)
- **COMPLETE**: Work Unit completion approval (Controlled TEMPO)

---

## Agent Task States

```text
NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE
```

### Transitions

- **NEW → READY**: Created by WA during Task Breakdown cycle
- **READY → IN PROGRESS**: When WA begins task execution
- **IN PROGRESS → IN REVIEW**: When WA completes development work
- **IN REVIEW → COMPLETE**: When Quality Check Cycle passes all gates

### Details

| State | Description | Set By | When |
|-------|-------------|--------|------|
| **NEW** | Created during Task Breakdown | WA | Task specification created |
| **READY** | Task specification complete, dependencies resolved | WA | Task specification validated, no blockers |
| **IN PROGRESS** | Development work in progress | WA | Development Engineer begins work |
| **IN REVIEW** | Development complete, review and quality validation in progress | WA | Development work complete, PR created |
| **COMPLETE** | Review and quality validation passed | RA | Quality Check Cycle passes |

**Loop Protection:**
- Review loop and quality loop thresholds prevent infinite loops
- HITL triggered when thresholds exceeded
- No explicit state for loop condition (handled within IN REVIEW state)

**HITL Checkpoints:**
- None at Agent Task level (WA Review/Quality Engineers handle validation)
- HITL only triggered when loop thresholds exceeded

---

## Bug States

```text
NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE
```

**Note:** Bugs follow the same state flow as Agent Tasks.

### Transitions

- **NEW → READY**: Bug triaged and ready for assignment
- **READY → IN PROGRESS**: When WA begins bug fix work
- **IN PROGRESS → IN REVIEW**: When WA completes bug fix
- **IN REVIEW → COMPLETE**: When Quality Check Cycle passes all gates

### Details

| State | Description | Set By | When |
|-------|-------------|--------|------|
| **NEW** | Bug reported | System or User | Bug discovered or reported |
| **READY** | Bug triaged, assigned, dependencies resolved | RA or User | Bug analysis complete, priority set |
| **IN PROGRESS** | Bug fix in progress | WA | Development Engineer begins work |
| **IN REVIEW** | Bug fix complete, review and validation in progress | WA | Bug fix complete, PR created |
| **COMPLETE** | Bug fix validated and deployed | RA | Quality gates pass |

---

## State Flow Summary

| Work Item Type | States | Total Transitions | Failure Loop |
|----------------|--------|-------------------|--------------|
| **Project** | OPEN → CLOSED | 2 states, 1 transition | No |
| **Feature** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | 5 states, 5 transitions | Yes (IN REVIEW → IN PROGRESS) |
| **Work Unit** | NEW → REVIEWED → READY → IN PROGRESS → IN REVIEW → COMPLETE | 6 states, 6 transitions | Yes (IN REVIEW → IN PROGRESS) |
| **Agent Task** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | 5 states, 4 transitions | No (loop within IN REVIEW) |
| **Bug** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | 5 states, 4 transitions | No (loop within IN REVIEW) |

---

## State Transition Rules

### General Rules

1. **Forward Progress**: States can only transition forward except for documented failure loops
2. **Cycle-Driven**: State transitions are triggered by specific cycle completions
3. **Agent-Driven**: RA orchestrates most transitions; WAs set Agent Task states
4. **HITL-Aware**: HITL checkpoints can occur at configured state transitions

### HITL Checkpoint States (Typical)

**Feature:**
- **READY**: After specification (High/Moderate/Controlled)
- **IN REVIEW**: After Feature quality gates (Moderate/Controlled)
- **COMPLETE**: After approval (Moderate/Controlled)

**Work Unit:**
- **REVIEWED**: After challenge (Moderate/Controlled)
- **READY**: After breakdown (Moderate/Controlled)
- **COMPLETE**: After all Agent Tasks complete (Controlled)

**Agent Task:**
- No typical HITL checkpoints (WA Review/Quality Engineers handle validation)
- HITL only when loop thresholds exceeded

### Quality Gate States

**Agent Tasks:**
- **IN REVIEW**: WA Review Engineer + WA Quality Engineer validate before COMPLETE

**Work Units:**
- No explicit quality gate state (aggregation of complete Agent Tasks)

**Features:**
- **IN REVIEW**: WA Quality Engineer validates all Work Units before COMPLETE

---

## State Visualization

### Feature State Flow Diagram

```text
    [NEW]
      |
      | (Feature Interview Process + HITL)
      ↓
   [READY]
      |
      | (Task Breakdown begins)
      ↓
[IN PROGRESS]
      |
      | (All Work Units COMPLETE)
      ↓
  [IN REVIEW] ←─────┐
      |             | (Quality gates fail)
      | (Quality    |
      | gates pass) |
      ↓             |
  [COMPLETE]────────┘
```

### Work Unit State Flow Diagram

```text
     [NEW]
       |
       | (Challenge Cycle + HITL)
       ↓
  [REVIEWED]
       |
       | (Task Breakdown + HITL)
       ↓
    [READY]
       |
       | (First Agent Task begins)
       ↓
[IN PROGRESS]
       |
       | (All Agent Tasks IN REVIEW)
       ↓
  [IN REVIEW] ←─────┐
       |            | (Quality gates fail)
       | (Quality   |
       | gates pass)|
       ↓            |
  [COMPLETE]────────┘
```

### Agent Task State Flow Diagram

```text
     [NEW]
       |
       | (Task specification complete)
       ↓
    [READY]
       |
       | (WA begins execution)
       ↓
[IN PROGRESS]
       |
       | (Development complete, PR created)
       ↓
  [IN REVIEW] ←─────┐
       |            |
       | (Review    | (Review or Quality fail)
       | passes)    | (within loop threshold)
       ↓            |
       | (Quality   |
       | passes)    |
       ↓            |
  [COMPLETE]────────┘
```

---

## State Queries

Agents query work items by state to understand current work status:

**Common Queries:**

```yaml
# Get all Features ready for Work Unit creation
Features WHERE state = READY

# Get all Work Units ready for Task Breakdown
Work Units WHERE state = REVIEWED

# Get all Agent Tasks ready for execution
Agent Tasks WHERE state = READY AND dependencies_resolved = true

# Get all in-progress work
Work Units WHERE state IN (IN PROGRESS, IN REVIEW)
Agent Tasks WHERE state IN (IN PROGRESS, IN REVIEW)

# Get blocked work
Agent Tasks WHERE state = READY AND dependencies_resolved = false

# Get completed Features
Features WHERE state = COMPLETE
```

---

## State Persistence

States are persisted in the project's work tracking system:

**Storage Options:**
- GitHub Issues (with labels for states)
- Jira (using status fields)
- Azure DevOps Boards (using state fields)
- Local files (YAML/JSON)

**State Metadata:**
- Current state
- State transition history (audit trail)
- Timestamp of each transition
- Agent that triggered transition
- HITL approval records (if applicable)

---

## See Also

- [Flow Cycles](03-flow-cycles.md) - Cycles that trigger state transitions
- [Work Breakdown Structure](07-work-breakdown-structure.md) - Work item type definitions
- [Quality Check Cycle](04-special-cycles.md#quality-check-cycle) - Quality validation states

---

## Change History

| Version | Date       | Author | Description                                                  |
| ------- | ---------- | ------ | ------------------------------------------------------------ |
| 1.0.0   | 2025-12-14 | Agent  | Complete state flow documentation for all work item types    |
