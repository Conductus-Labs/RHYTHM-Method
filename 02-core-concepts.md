# Core Concepts

This document explains the fundamental concepts that underpin the RHYTHM Method.

## Agent Types

RHYTHM Method uses three distinct agent types, each with specific expertise and responsibilities:

### BA (Baton Agent)

**Expertise:** Baton Framework specialist

**Responsibilities:**
- Project initialization and setup
- Baton Framework configuration
- Agent file creation and management
- Cognitive file management
- Workflow file management
- Knowledge file management
- Integration with Baton ecosystem

**When BA is Used:**
- Project Initialisation cycle
- Project Interview Process
- Setting up `.baton/` directory structure
- Creating and managing Baton Framework components

### RA (RHYTHM Agent)

**Expertise:** RHYTHM Method specialist

**Responsibilities:**
- Method orchestration across all cycles
- Feature specification and management
- Work Unit creation and coordination
- Dependency detection and prioritisation
- Token roll-up aggregation
- Cycle coordination and state transitions
- HITL checkpoint management
- Metric collection and analysis

**When RA is Used:**
- Feature Specification cycle
- Work Unit Creation cycle
- Challenge Cycle (orchestration)
- Task Breakdown cycle (orchestration)
- Task Execution cycle (orchestration)
- Dependency-driven Prioritisation cycle
- Feature Interview Process
- Cycle Review Process
- Human-in-the-Loop Check Process

### WA (Worker Agent)

**Expertise:** Specialized execution

**Sub-roles:**
- **Development Engineer**: Writes code, creates documentation, performs implementation work
- **Review Engineer**: Reviews code quality, validates standards compliance
- **Quality Engineer**: Runs quality gates, validates specifications, performs testing

**Responsibilities:**
- Execute Agent Tasks
- Review work from other WAs
- Validate quality gates
- Create Agent Task specifications during Task Breakdown
- Challenge Work Unit specifications during Challenge Cycle
- Provide specialized domain expertise

**When WA is Used:**
- Challenge Cycle (reviews and challenges)
- Task Breakdown cycle (creating Agent Tasks)
- Task Execution cycle (all three sub-roles)
- Quality Check Cycle (Review and Quality Engineers)

---

## TEMPO

**Definition:** The speed/pace at which agents operate and the frequency of Human-in-the-Loop checkpoints.

### TEMPO Levels

RHYTHM Method defines three TEMPO levels that control HITL checkpoint frequency:

#### High TEMPO
- **HITL Checkpoints:** ~3-5 gates per feature cycle
- **Focus:** Critical decision points only
- **Use Case:** Fast iteration, well-understood work, high agent autonomy
- **Human Involvement:** Strategic decisions, high-risk approvals
- **Response Time:** Faster expected response times
- **Risk Level:** Higher autonomy, requires mature agents and clear standards

#### Moderate TEMPO (Default)
- **HITL Checkpoints:** ~8-12 gates per feature cycle
- **Focus:** Key decision points and validation checkpoints
- **Use Case:** Balanced oversight, typical projects
- **Human Involvement:** Feature approvals, Work Unit validations, cycle reviews
- **Response Time:** Standard response times
- **Risk Level:** Balanced autonomy and oversight

#### Controlled TEMPO
- **HITL Checkpoints:** ~15-20 gates per feature cycle
- **Focus:** Comprehensive oversight at every major step
- **Use Case:** High-risk work, regulatory requirements, learning phase
- **Human Involvement:** Frequent approvals, detailed reviews, close monitoring
- **Response Time:** Longer acceptable response times
- **Risk Level:** Lower autonomy, maximum human oversight

### TEMPO Configuration

TEMPO is configured in `Project.Config`:

```yaml
rhythm:
  default_tempo: "moderate"  # high | moderate | controlled
  max_challenge_loops: 3
  max_review_loops: 3
  max_quality_loops: 3
  hitl_triggers:
    - "quality_score < 80"
    - "challenge_conflict"
    - "dependency_conflict"
```

### Choosing the Right TEMPO

**Start with Moderate TEMPO** and adjust based on:

- **Agent maturity**: More mature agents → Higher TEMPO
- **Work complexity**: Complex work → Lower TEMPO (Controlled)
- **Risk tolerance**: High risk → Lower TEMPO (Controlled)
- **Team experience**: Experienced with RHYTHM → Higher TEMPO
- **Regulatory requirements**: Compliance needs → Lower TEMPO (Controlled)
- **Historical accuracy**: Good estimation accuracy → Higher TEMPO

**TEMPO can be adjusted:**
- Per project (in Project.Config)
- Per feature (override in feature specification)
- Per Work Unit (override in Work Unit specification)

---

## Human-in-the-Loop (HITL)

**Definition:** Strategic human oversight and control at critical decision points while maintaining fast agent execution.

### HITL Principles

1. **Strategic, Not Constant**: Humans intervene at critical decision points, not every action
2. **Configurable**: TEMPO level determines checkpoint frequency
3. **Priority-Based**: Different priority levels with expected response times
4. **Context-Rich**: Humans receive comprehensive context packages for decisions
5. **Non-Blocking (when possible)**: Low-risk work can auto-approve after timeout
6. **Escalation-Aware**: Critical issues escalate through defined approval chains

### HITL Checkpoint Types

#### Approval Checkpoints
- Feature specification approval
- Work Unit completion approval
- Feature completion approval
- High-impact replanning approval

#### Validation Checkpoints
- Challenge loop threshold exceeded
- Review loop threshold exceeded
- Quality loop threshold exceeded
- Critical dependency validation

#### Decision Checkpoints
- External blocker resolution
- Critical path blocked
- Quality failure severity assessment
- Override requests

### Priority Levels

| Priority | Description | Expected Response | Use Case |
|----------|-------------|-------------------|----------|
| **Emergency** | Critical failures, system instability, production issues | < 15 minutes | Security vulnerabilities, system crashes, data corruption |
| **High** | High-priority work, critical path blockers, major decisions | < 2 hours | Feature approvals on critical path, major architectural decisions |
| **Normal** | Routine approvals, non-critical decisions | < 8 hours | Work Unit approvals, standard feature completions |
| **Low** | Optional reviews, informational notifications | < 24 hours | Cycle review summaries, informational updates |

### Timeout Behavior

**Low-Risk Work (Normal/Low Priority):**
- Auto-approve after timeout with notification
- Conditions: Work is low-risk, well-defined, agent confidence is high
- User can override auto-approval later if needed

**High-Risk Work (High Priority/Emergency):**
- Queue work, wait for human response
- Escalate to backup approver (if configured)
- Critical work blocked until approval received

### Escalation Levels

1. Notify User again (reminder)
2. Escalate to backup approver
3. Escalate to project lead or manager
4. Emergency escalation for critical issues

---

## Token-Based Estimation

**Definition:** Using AI model token consumption as the unit of estimation instead of abstract story points.

### Why Tokens?

**Traditional story points are abstract:**
- "3 points" means different things to different teams
- No direct correlation to actual effort
- Difficult to compare across projects
- Not meaningful for AI agents

**Tokens are precise:**
- Direct measurement of AI model consumption
- Consistent across all agents
- Measurable and trackable
- Enables accurate forecasting

### Token Categories

Agent Tasks are estimated across four token categories:

1. **Code Tokens**: Tokens used for code generation and implementation
2. **Analysis Tokens**: Tokens used for reading context, understanding requirements
3. **Documentation Tokens**: Tokens used for creating documentation, comments
4. **Validation Tokens**: Tokens used for testing, validation, quality checks

**Total Estimated Tokens = Code + Analysis + Documentation + Validation**

### Token Roll-Up Hierarchy

```text
Agent Task (estimated tokens)
    ↓ (roll-up)
Work Unit (sum of Agent Task estimated tokens)
    ↓ (roll-up)
Feature (sum of Work Unit estimated tokens)
```

**Estimated vs. Actual:**
- **Estimated**: Calculated during Task Breakdown cycle
- **Actual**: Tracked during Task Execution cycle
- **Variance Analysis**: Comparison of estimated vs. actual for continuous improvement

### Estimation Formulas

See [Token Estimation](08-token-estimation.md) for detailed formulas and complexity factors.

---

## Dependency-Driven Prioritisation

**Definition:** Automatic work prioritization based on dependency analysis, ensuring work happens in the correct order.

### Dependency Types

1. **Technical Dependencies**: Code, APIs, infrastructure
   - Example: Work Unit B imports code from Work Unit A

2. **Data Dependencies**: Database schemas, data models, migrations
   - Example: Work Unit C requires database schema from Work Unit D

3. **Integration Dependencies**: External services, third-party APIs, system integrations
   - Example: Work Unit E integrates with payment service from Work Unit F

4. **Knowledge Dependencies**: Domain understanding, architectural decisions, design decisions
   - Example: Work Unit G requires ADR decision before proceeding

### Dependency Detection

The RA uses multiple automated detection methods:

- **Code Analysis**: Imports, function calls, type references, file/module dependencies
- **Specification Analysis**: Explicit and implicit dependency mentions
- **API Analysis**: API contracts, interface definitions, service dependencies
- **Pattern Recognition**: Historical patterns and common dependency sequences

### Prioritisation Rules

1. **RULE 1**: Dependencies first (Level 0 > Level 1 > Level N)
2. **RULE 2**: Within same level, business value determines order
3. **RULE 3**: Parallel execution where possible (same level, no conflicts)

**Dependency Levels:**
- Level 0: No dependencies (can start immediately)
- Level 1: Depends on Level 0 work
- Level N: Depends on Level N-1 work

### Critical Path

**Definition:** The sequence of dependent tasks that determines the minimum time to complete a Feature.

**Critical Path Management:**
- RA calculates and tracks critical path
- Critical path changes trigger HITL notifications
- Blocked critical path is high-priority HITL checkpoint
- Parallel execution optimized for non-critical-path work

---

## Cycle Review and Continuous Improvement

**Definition:** Systematic analysis of execution cycles to identify improvements and adapt the methodology.

### What Gets Reviewed

1. **Cycle Performance Metrics**
   - Iteration counts per cycle
   - HITL intervention frequency
   - Loop threshold triggers

2. **Token Estimation Accuracy**
   - Estimated vs. actual token usage
   - Estimation accuracy trends
   - Outliers and misses

3. **Dependency Resolution Effectiveness**
   - Detection accuracy
   - Resolution time
   - Blocked work patterns

4. **Quality Gate Results**
   - Rejection rates
   - Failure patterns
   - Fix iteration counts

### Improvement Loop

```text
Execute Cycle
    ↓
Collect Metrics
    ↓
Analyze Performance
    ↓
Identify Improvements
    ↓
Update Models/Thresholds/Processes
    ↓
Execute Next Cycle (with improvements)
```

### Learning Integration

- **Historical Data**: Build performance database over time
- **Trend Analysis**: Identify patterns across cycles
- **Model Updates**: Refine estimation models based on actuals
- **Process Refinement**: Adjust thresholds, checkpoints, and workflows
- **Knowledge Transfer**: Apply learnings to future work

---

## Quality Gates

**Definition:** Validation checkpoints that ensure work meets standards and specifications before completion.

### Quality Gate Levels

1. **Agent Task Level**
   - Code review by Review Engineer
   - Quality validation by Quality Engineer
   - Specification compliance check

2. **Work Unit Level**
   - Aggregation validation (all Agent Tasks complete)
   - Work Unit specification compliance

3. **Feature Level**
   - End-to-end integration testing
   - Feature specification compliance
   - User acceptance criteria validation

### Quality Failure Severity

| Severity | Action | Example | HITL Required |
|----------|--------|---------|---------------|
| **Critical** | Block immediately | Security vulnerabilities, system crashes, data corruption | Yes - cannot proceed |
| **High** | Flag, require review | Performance degradation, major spec violations | Yes - before proceeding |
| **Medium** | Flag, allow continuation | Code style violations, minor performance issues | No - post-validation |
| **Low** | Log for review | Documentation gaps, minor test failures | No - review in Cycle Review |

### Loop Protection

To prevent infinite loops, RHYTHM Method enforces configurable loop thresholds:

- **Challenge Loop**: Default 3 iterations (triggers HITL)
- **Review Loop**: Default 3 iterations (triggers HITL)
- **Quality Loop**: Default 3 iterations (triggers HITL)

When threshold exceeded:
1. RA flags work for HITL intervention
2. User reviews issue and provides guidance
3. RA resets loop count after HITL resolution

---

## State Management

**Definition:** Structured state transitions for all work items to track progress and enable coordination.

### Work Item Types and States

| Work Item | States | Purpose |
|-----------|--------|---------|
| **Project** | OPEN → CLOSED | Track project lifecycle |
| **Feature** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | Track feature development |
| **Work Unit** | NEW → REVIEWED → READY → IN PROGRESS → IN REVIEW → COMPLETE | Track deliverable units |
| **Agent Task** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | Track individual tasks |
| **Bug** | NEW → READY → IN PROGRESS → IN REVIEW → COMPLETE | Track bug fixes |

### State Transition Triggers

States transition based on:
- Cycle completion (e.g., Challenge Cycle completes → REVIEWED)
- HITL approval (e.g., Feature approval → READY)
- Work completion (e.g., All Agent Tasks complete → IN REVIEW)
- Quality gate results (e.g., Quality gates pass → COMPLETE)

See [State Management](06-state-management.md) for complete state flow diagrams and transition rules.

---

## Project Configuration Files

RHYTHM Method uses two key configuration files:

### Project.Manifest

**Location:** `.baton/Project.Manifest.md`
**Format:** Markdown with structured sections
**Purpose:** High-level project understanding - the WHAT, WHY, WHO, and SUCCESS METRICS

**Key Sections:**
- Project Overview
- Stakeholders
- Goals & Success Metrics
- Scope & Constraints
- Technical Standards
- Architecture Overview
- Dependencies & Integration
- Risks & Mitigation

**Stability:** Relatively stable - captures project essence that doesn't change frequently

### Project.Config

**Location:** `.baton/project.config.yml`
**Format:** Pure YAML
**Purpose:** Project configuration for agents - tools, resources, workflows, settings

**Key Sections:**
- Project metadata
- Source control configuration
- Project management integration
- GenAI configuration
- RHYTHM settings (TEMPO, thresholds, HITL triggers)
- Baton configuration
- Preferences and metadata

**Stability:** Changes more frequently - operational configuration

See [Project Setup](11-project-setup.md) for detailed templates and examples.

---

## Summary

These core concepts form the foundation of RHYTHM Method:

1. **Agent Types**: BA (Baton), RA (RHYTHM), WA (Worker) with specialized roles
2. **TEMPO**: Configurable pace controlling HITL checkpoint frequency
3. **HITL**: Strategic human oversight at critical decision points
4. **Token Estimation**: Precise, measurable estimation using AI tokens
5. **Dependency Management**: Automatic prioritization based on dependencies
6. **Quality Gates**: Multi-level validation with severity-based handling
7. **State Management**: Structured state transitions for coordination
8. **Continuous Improvement**: Cycle review and learning integration
9. **Configuration**: Project.Manifest and Project.Config guide all agents

Understanding these concepts is essential before diving into the [Flow Cycles](03-flow-cycles.md) and [Processes](05-processes.md).

---

## Change History

| Version | Date       | Author | Description                                                    |
| ------- | ---------- | ------ | -------------------------------------------------------------- |
| 1.0.0   | 2025-12-14 | Agent  | Initial comprehensive documentation of RHYTHM Method core concepts |
