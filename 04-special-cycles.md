# Special Cycles

This document details the special cycles that operate within and alongside the main flow cycles.

---

## Quality Check Cycle

**Note:** Quality checks are integrated into the Task Execution Cycle. This cycle documents the quality validation process that occurs at different levels.

### Overview

The Quality Check Cycle ensures work meets standards and specifications through multi-level validation with specialized quality gates at Agent Task and Feature levels.

**Agents:** WA (Review Engineer), WA (Quality Engineer)

**Integration Point:** Task Execution Cycle

---

### Agent Task Level Quality Checks

Performed within Task Execution Cycle by specialized WAs after development work completes.

#### Review Phase

**Agent:** WA (Review Engineer)

**Purpose:** Validate code quality and standards compliance

**Process:**
- WA (Review Engineer) reviews Pull Request
- Examines:
  - Code quality and standards compliance
  - Logic correctness
  - Documentation completeness
  - Test coverage
- Leaves review comments:
  - `NO ISSUES => APPROVED`
  - `ANY ISSUES => REJECTED WITH DETAILS`

**Outputs:**
- APPROVED: Continue to Quality Validation
- REJECTED: Loop back to Development Engineer for fixes

**Loop Protection:**
- Review loop threshold (default: 3)
- HITL triggered when threshold exceeded

#### Quality Validation Phase

**Agent:** WA (Quality Engineer)

**Purpose:** Validate work against Work Unit specification and run automated quality gates

**Process:**
- WA (Quality Engineer) validates work
- Runs automated quality gates:
  - Integration testing with other Agent Tasks
  - Performance validation
  - Security scanning
  - Specification compliance check
- Reports results:
  - `PASS => Agent Task COMPLETE`
  - `FAIL WITH DETAILS => Loop to fixes`

**Outputs:**
- PASS: Agent Task marked COMPLETE
- FAIL: Loop back to Development Engineer for fixes

**Loop Protection:**
- Quality loop threshold (default: 3)
- HITL triggered when threshold exceeded

---

### Feature Level Quality Checks

Performed when all Work Units for a Feature are complete.

**Agent:** WA (Quality Engineer)

**Purpose:** Comprehensive end-to-end validation of complete Feature

**Process:**
- WA (Quality Engineer) runs Feature-level quality gates:
  - End-to-end integration testing across ALL Work Units
  - Feature specification compliance validation
  - Performance testing against Feature requirements
  - Security validation for complete Feature
  - Documentation completeness check
  - User acceptance criteria validation
- Reports results:
  - `PASS WITH WORK UNIT DETAILS => Feature COMPLETE`
  - `FAIL WITH WORK UNIT DETAILS => Affected Work Units reopened`

**Outputs:**
- PASS: Feature marked COMPLETE (after HITL approval)
- FAIL: Affected Work Units returned to IN PROGRESS state

---

### Quality Failure Severity and Handling

Quality failures are classified by severity and handled accordingly:

#### Critical Failures

**Definition:** Block work immediately, require HITL intervention

**Examples:**
- Security vulnerabilities
- System crashes
- Data corruption
- Critical specification violations

**Handling:**
- Cannot proceed without human approval
- May require emergency override with post-validation
- Emergency priority HITL checkpoint
- Root cause analysis required
- May require specification or architecture changes

#### High Failures

**Definition:** Flag work, require human review before proceeding

**Examples:**
- Performance degradation
- Major specification violations
- Breaking changes to APIs
- Significant test coverage gaps

**Handling:**
- Requires risk assessment and mitigation plan
- High-priority HITL checkpoint
- May proceed with documented risks after human review
- Remediation plan required

#### Medium Failures

**Definition:** Flag work, allow continuation with notification

**Examples:**
- Code style violations
- Minor performance issues
- Non-critical specification deviations
- Documentation incompleteness

**Handling:**
- Schedule post-validation
- Normal-priority notification
- Fix in next iteration or Work Unit
- Track in quality metrics

#### Low Failures

**Definition:** Log for review, allow continuation

**Examples:**
- Documentation gaps
- Minor test failures
- Code comment issues
- Non-functional improvements

**Handling:**
- Review during Cycle Review Process
- Low-priority notification
- Optional fix
- Track in quality metrics for trends

---

### Failure Retry and Remediation

#### Transient Failures

**Definition:** Temporary issues that may resolve on retry

**Examples:**
- Network timeouts
- Temporary service unavailability
- Rate limiting
- Flaky tests

**Handling:**
- Automatic retry (1-2 attempts)
- Exponential backoff for network issues
- Log retry attempts
- If persists after retries, treat as persistent failure

#### Persistent Failures

**Definition:** Consistent failures that require investigation and resolution

**Examples:**
- Specification ambiguity causing repeated review rejections
- Architectural constraints blocking implementation
- Insufficient Agent Task specification
- Missing dependencies or tools

**Handling:**
- Root cause analysis required
- Process review to identify systemic issues
- Escalation to HITL for guidance
- May require:
  - Specification clarification
  - Architecture decision
  - Agent Task modification
  - Work Unit split
  - Dependency resolution

#### Override Mechanisms

**Purpose:** Allow human to override quality gate failures when justified

**Requirements:**
- Human approval required
- Justification documented
- Risk assessment provided
- Mitigation plan defined
- Post-validation scheduled (if applicable)

**Use Cases:**
- Known limitations with planned future fixes
- Technical debt accepted for velocity
- External constraints preventing full compliance
- Regulatory or business exceptions

**Process:**
1. WA (Quality Engineer) flags failure for override consideration
2. HITL checkpoint triggered (High priority)
3. User reviews:
   - Failure details
   - Impact assessment
   - Risk analysis
   - Proposed mitigation
4. User decides:
   - **Approve Override**: Work proceeds with documented exception
   - **Reject Override**: Work returns for fixes
   - **Request Changes**: Modify mitigation plan and resubmit

---

### Quality Metrics Tracking

RA logs quality metrics for Cycle Review Process:

#### Review Metrics
- Review rejection rates by WA (Review Engineer)
- Common review issues and patterns
- Review cycle time (time from PR creation to approval)
- Review loop counts per Agent Task
- Review loop threshold triggers

#### Quality Gate Metrics
- Quality gate failure rates by WA (Quality Engineer)
- Failure severity distribution (Critical, High, Medium, Low)
- Common failure patterns and root causes
- Fix iteration counts per Agent Task
- Quality loop counts per Agent Task
- Quality loop threshold triggers

#### Override Metrics
- Override frequency and reasons
- Override justifications and risk assessments
- Post-validation completion rates
- Technical debt tracking from overrides

#### Time Metrics
- Time to quality approval per Agent Task
- Time to remediation per failure type
- Review throughput (Agent Tasks per time period)
- Quality gate throughput

**See Also:**
- [Cycle Review Process](05-processes.md#cycle-review-process)
- [Error Handling](15-error-handling.md)

---

## Dependency-driven Prioritisation Cycle

**Purpose:** Ensure work happens in the correct order through dependency-driven prioritization, automatically detecting and managing dependencies across all work items.

**Agent:** RA (RHYTHM Agent)

**Integration Point:** Continuously throughout Task Execution Cycle

---

### Overview

The Dependency-driven Prioritisation Cycle maintains a real-time dependency graph and continuously prioritizes work to ensure:
- Dependencies are completed before dependent work
- Parallel execution is maximized
- Critical path is identified and protected
- Blocked work is detected and escalated

---

### Dependency Types

The RA detects and manages four types of dependencies:

#### Technical Dependencies

**Definition:** Code, APIs, infrastructure

**Examples:**
- Work Unit B imports code from Work Unit A
- Agent Task depends on function created in another Agent Task
- Component requires API endpoint from another Work Unit

**Detection Methods:**
- Code analysis (imports, function calls, type references)
- Static analysis tools (AST parsing)
- Module dependency graphs

#### Data Dependencies

**Definition:** Database schemas, data models, migrations

**Examples:**
- Work Unit C requires database schema from Work Unit D
- Agent Task needs data migration to complete first
- Feature requires specific data models

**Detection Methods:**
- Code analysis (database queries, ORM models)
- Specification analysis (data model references)
- Migration file dependencies

#### Integration Dependencies

**Definition:** External services, third-party APIs, system integrations

**Examples:**
- Work Unit E integrates with payment service from Work Unit F
- Agent Task requires authentication service to be deployed
- Feature depends on external API configuration

**Detection Methods:**
- API contract analysis (OpenAPI/Swagger, GraphQL schemas)
- Service dependency analysis
- Configuration file analysis

#### Knowledge Dependencies

**Definition:** Domain understanding, architectural decisions, design decisions

**Examples:**
- Work Unit G requires ADR decision before proceeding
- Agent Task needs architectural pattern decision
- Feature depends on technology stack decision

**Detection Methods:**
- Specification analysis (ADR references, decision mentions)
- Decision log analysis
- May require manual identification and HITL validation

---

### Dependency Detection Methods

The RA uses multiple automated detection methods:

#### Code Analysis

**Tools:** Static code analysis (AST parsing), dependency graph tools

**Detects:**
- Imports and module dependencies
- Function calls and type references
- File and directory dependencies
- API contracts and interfaces

**Accuracy:** High for technical dependencies

#### Specification Analysis

**Tools:** Natural language processing, pattern matching

**Detects:**
- Explicit dependency mentions ("Requires Feature X", "Depends on Y")
- Implicit references ("Uses API from Z", "Must work with W")
- Specification cross-references

**Accuracy:** Medium - may have false positives/negatives

#### API Analysis

**Tools:** API schema parsers (OpenAPI, GraphQL, gRPC)

**Detects:**
- API contract dependencies
- Interface definitions
- Service dependencies
- External API integrations

**Accuracy:** High for integration dependencies

#### Pattern Recognition

**Tools:** Machine learning, historical analysis

**Detects:**
- Common dependency patterns from past work
- Typical sequences (e.g., "authentication always before authorization")
- Dependency patterns by work type

**Accuracy:** Improves over time with more historical data

---

### False Positive and Negative Handling

#### Manual Review Process

**Trigger:** Critical or ambiguous dependencies detected

**Process:**
1. RA generates dependency detection report
2. RA flags critical dependencies for User review
3. HITL checkpoint triggered (Moderate/Controlled TEMPO)
4. User validates, confirms, or rejects detected dependencies
5. User adds dependencies that automation missed
6. User removes false positive dependencies
7. RA updates dependency graph with corrections

**When Triggered:**
- Critical path dependencies
- Ambiguous specification references
- Conflicting dependency signals
- Knowledge dependencies (often require manual identification)
- First-time dependency patterns

#### Continuous Improvement

**Process:**
1. RA logs manual corrections from HITL reviews
2. RA analyzes patterns in false positives/negatives
3. RA updates detection rules based on corrections
4. RA trains pattern recognition models
5. RA improves accuracy over time

**Metrics Tracked:**
- False positive rate (dependencies detected but not real)
- False negative rate (dependencies missed by automation)
- Manual correction frequency
- Detection accuracy trends

---

### Dependency-Driven Prioritisation Flow

**TRIGGERED BY:**
- New task added
- Task completed
- Dependency change
- Specification change

**Process:**

- RA retrieves current dependency graph
  `Real-time graph maintained throughout execution`
- **IF** *CHANGE IS BATCHED*
  `Multiple changes within batching window (5-15 minutes)`
  - RA queues change for batch processing
  - **WHEN** *BATCH THRESHOLD REACHED OR TIMEOUT*
    - RA processes all queued changes together
    - Reduces thrashing from frequent small changes
- **ELSE IF** *CRITICAL CHANGE*
  `Critical dependency resolved, high-priority work added, work unit failure`
  - RA processes immediately
  - No batching delay
- **ELSE**
  - RA queues for scheduled replanning
    `Periodic validation every N minutes (configurable)`
- RA performs incremental dependency graph update
  `Only update affected subgraph, not full recalculation`
  - **IF** *NEW TASK ADDED*
    - RA detects dependencies for new task:
      - Code analysis (imports, function calls, type references)
      - Specification analysis (explicit mentions, implicit references)
      - API analysis (API contracts, service dependencies)
      - Pattern recognition (historical patterns)
      - Knowledge dependencies (manual identification may be needed)
    - [[Human-in-the-Loop Check Process]]
      `TEMPO: Moderate/Controlled for critical dependencies`
    - RA adds task to dependency graph
    - RA assigns dependency level
      `Level 0 = no dependencies, Level N = depends on Level N-1`
  - **ELSE IF** *TASK COMPLETED*
    - RA marks dependencies as resolved
    - RA updates dependent tasks' status
      `Set to READY if all dependencies resolved`
    - RA identifies newly unblocked work
    - RA notifies User of unblocked critical path work (if applicable)
  - **ELSE IF** *DEPENDENCY ADDED/REMOVED*
    - RA updates affected subgraph only
    - RA recalculates dependency levels for affected tasks
    - RA identifies newly blocked or unblocked work
  - **ELSE IF** *SPECIFICATION CHANGED*
    - RA re-analyzes dependencies for changed task
    - RA updates dependency graph
    - RA detects new or removed dependencies
- RA recalculates critical path
  `Use cached critical path if available, recalculate if major change`
- RA applies dependency-driven prioritization rules:
  - **RULE 1**: Dependencies first (Level 0 > Level 1 > Level N)
  - **RULE 2**: Within same level, business value determines order
  - **RULE 3**: Parallel execution where possible (same level, no conflicts)
- RA updates work queue order
  `Reorder based on new priorities`
- **IF** *HIGH-IMPACT REPLANNING*
  `Affects approved work or in-progress work`
  - [[Human-in-the-Loop Check Process]]
    `TEMPO: High/Moderate/Controlled - human approval required`
  - **IF** *HUMAN DENIES*
    - RA reverts prioritization change
    - RA logs override reason
    - RA maintains previous priority order
  - **ELSE**
    - RA applies new prioritization
    - RA notifies affected agents
- **ELSE**
  - RA applies new prioritization automatically
  - RA updates work queue
- RA detects blocked work
  `Tasks with unresolved dependencies`
  - **IF** *CRITICAL PATH BLOCKED*
    - [[Human-in-the-Loop Check Process]]
      `TEMPO: High/Moderate/Controlled - immediate notification`
    - User reviews blocker and provides resolution:
      - Remove dependency if not actually needed
      - Expedite blocking work
      - Modify specifications to eliminate dependency
      - Implement workaround
  - **ELSE IF** *WORK BLOCKED > THRESHOLD TIME*
    `Configurable threshold (default: 24 hours)`
    - RA notifies user of long-blocked work
    - User can choose to:
      - Accept delayed work
      - Expedite blocking work
      - Remove or modify dependency

---

### Prioritisation Rules

#### RULE 1: Dependencies First

Work is prioritized by dependency level:

```text
Level 0 (no dependencies)
    ↓
Level 1 (depends on Level 0)
    ↓
Level 2 (depends on Level 1)
    ↓
Level N (depends on Level N-1)
```

**Always prioritize lower levels before higher levels.**

#### RULE 2: Business Value Within Same Level

When multiple tasks are at the same dependency level, prioritize by business value:

**Business Value Factors:**
- User impact (high impact > low impact)
- Critical path (critical path > non-critical)
- Risk reduction (risk mitigation > feature addition)
- ROI (high ROI > low ROI)

**Defined in:** Feature and Work Unit specifications

#### RULE 3: Parallel Execution

When tasks are at the same dependency level and have no resource conflicts:

**Execute in parallel to maximize throughput.**

**Resource Conflicts:**
- Same file modifications
- Shared infrastructure components
- Database schema changes
- API contract modifications

**Conflict Resolution:**
- RA detects resource conflicts
- RA serializes conflicting work
- RA prioritizes by business value
- Non-conflicting work executes in parallel

---

### Critical Path Management

**Definition:** The sequence of dependent tasks that determines the minimum time to complete a Feature.

**Critical Path Characteristics:**
- Longest dependency chain from start to completion
- Any delay in critical path delays entire Feature
- Critical path changes as work completes or specifications change

**Critical Path Tracking:**
1. RA calculates critical path for each Feature
2. RA identifies Agent Tasks on critical path
3. RA prioritizes critical path work
4. RA monitors critical path for blockers
5. RA notifies User of critical path changes

**Critical Path Alerts:**
- **Critical Path Blocked**: Immediate High-priority HITL notification
- **Critical Path Delayed**: Normal-priority notification with impact assessment
- **Critical Path Changed**: Informational notification (unless becomes blocked)

---

### Batching and Incremental Updates

To avoid thrashing from frequent dependency graph updates:

#### Batching Window

**Default:** 5-15 minutes (configurable)

**Purpose:** Group multiple small changes for batch processing

**Process:**
1. Changes queued during batching window
2. When threshold reached or timeout occurs:
   - Process all queued changes together
   - Single dependency graph update
   - Single work queue reorder

**Benefits:**
- Reduces computation overhead
- Prevents priority thrashing
- Maintains stability

#### Incremental Updates

**Purpose:** Only update affected portions of dependency graph

**Process:**
1. Identify affected subgraph (tasks with changed dependencies)
2. Recalculate only affected portion
3. Leave unaffected portions unchanged
4. Merge updated subgraph back

**Benefits:**
- Fast updates for large projects
- Scalable to hundreds of tasks
- Minimal computational overhead

#### Critical Change Override

**Purpose:** Bypass batching for critical changes

**Triggers:**
- Critical dependency resolved (unblocks critical path)
- High-priority work added
- Work Unit failure (affects dependencies)

**Process:**
1. Immediate processing (no batching delay)
2. Incremental update applied
3. Work queue reordered immediately
4. Affected agents notified

---

### Prioritisation Metrics

RA logs prioritization metrics for Cycle Review Process:

#### Dependency Metrics
- Dependency detection accuracy (false positives/negatives)
- Dependency types distribution (Technical, Data, Integration, Knowledge)
- Manual correction frequency
- Dependency detection method effectiveness

#### Resolution Metrics
- Dependency resolution time (average time to resolve dependencies)
- Blocked work frequency (how often work is blocked)
- Critical path changes (frequency and impact)
- Blocked work duration (average time work spends blocked)

#### Efficiency Metrics
- Parallel execution efficiency (percentage of work executed in parallel)
- Work queue throughput (tasks completed per time period)
- Critical path optimization (actual vs. theoretical minimum time)
- Resource conflict frequency

#### Process Metrics
- Replanning frequency (how often priorities change)
- High-impact replanning frequency (requiring HITL)
- Batching effectiveness (changes per batch, batch frequency)
- Incremental update performance (update time, affected subgraph size)

**See Also:**
- [Dependency Management](09-dependency-management.md)
- [Cycle Review Process](05-processes.md#cycle-review-process)

---

## Continuous Planning Cycle

**Purpose:** Continuously update plans and forecasts based on actual execution progress.

**Agent:** RA (RHYTHM Agent)

**Integration Point:** Triggered during Task Execution Cycle when tasks complete

**Note:** This cycle is mentioned in the Overview but not detailed. It represents the ongoing planning adjustments as work progresses.

**Key Activities:**
- Update token usage forecasts based on actual vs. estimated
- Adjust remaining work estimates
- Recalculate Feature completion forecasts
- Update resource allocation
- Identify risks based on trends

**Triggers:**
- Agent Task completion
- Work Unit completion
- Significant variance detected (actual vs. estimated)
- Critical path changes

**Outputs:**
- Updated forecasts
- Risk alerts (if trends are concerning)
- Resource reallocation recommendations
- Cycle Review input data

---

## Special Cycle Integration

All special cycles integrate seamlessly with the main flow cycles:

**Quality Check Cycle:**
- Integrated into Task Execution Cycle
- Runs for every Agent Task and Feature
- Provides feedback to Cycle Review

**Dependency-driven Prioritisation Cycle:**
- Runs continuously during Task Execution
- Updates work queue in real-time
- Provides metrics to Cycle Review

**Continuous Planning Cycle:**
- Runs continuously during Task Execution
- Updates forecasts and plans
- Provides metrics to Cycle Review

**See Also:**
- [Flow Cycles](03-flow-cycles.md)
- [Processes](05-processes.md)
- [Best Practices](13-best-practices.md)

---

## Navigation

**Previous:** [Flow Cycles](03-flow-cycles.md) - Main execution cycles
**Next:** [Processes](05-processes.md) - Supporting processes

---

## Change History

| Version | Date       | Author | Description                                                               |
| ------- | ---------- | ------ | ------------------------------------------------------------------------- |
| 1.0.0   | 2025-12-14 | Agent  | Complete documentation of Quality Check and Dependency-driven Prioritisation cycles |
