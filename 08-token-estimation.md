# Token-Based Estimation

## Overview

RHYTHM Method uses **token-based estimation** to replace abstract story points with precise, measurable factors. Token estimation leverages agent capabilities for accurate analysis and enables precise capacity planning.

**Business Value:** Token-based estimation provides measurable, data-driven estimates that improve over time. Unlike abstract story points that vary between teams and individuals, tokens represent actual work factors (code, analysis, documentation, validation) that can be tracked and refined. This leads to more accurate capacity planning, fewer surprises, better resource allocation, and data-driven decision making. Teams can confidently commit to work knowing estimates are based on measurable factors, not subjective judgment.

## What is Token Estimation?

Token estimation calculates work based on measurable factors ([tokens](03-dictionary.md#token)) rather than abstract concepts (story points). Tokens represent:

- **Code Generation**: Lines of code, complexity, patterns
- **Analysis**: Requirements analysis, dependency analysis, design work
- **Documentation**: Code comments, API docs, specifications
- **Validation**: Testing, code review, quality checks

### Calibration and Adjustment

**Important:** All formulas, multipliers, and rates provided in this document are starting points based on general software development practices. They should be calibrated per project based on:

- Historical data from similar projects
- Programming language and framework characteristics
- Team experience and domain expertise
- Project complexity and requirements

**Language/Framework Considerations:**

- Different languages may have different token-to-LOC ratios
- Framework complexity may affect pattern multipliers
- Integration complexity varies by technology stack
- Calibrate starting values based on project-specific data

## Token Estimation Formula

### Basic Token Count

For a [Work Unit](03-dictionary.md#work-unit) or [Agent Task](03-dictionary.md#agent-task):

```
Total Tokens = Code Tokens + Analysis Tokens + Documentation Tokens + Validation Tokens
```

### Token Components

**Code Tokens:**

- Lines of code (adjusted for complexity)
- Pattern complexity (simple, moderate, complex)
- Framework/library usage
- Integration complexity

**Analysis Tokens:**

- Requirements analysis
- Dependency analysis
- Design work
- Architecture decisions

**Documentation Tokens:**

- Code comments
- API documentation
- Specification updates
- User documentation

**Validation Tokens:**

- Unit tests
- Integration tests
- Code review
- Quality checks

### Code Token Calculation Formula

Code tokens are calculated using the following formula:

```
Code Tokens = Base LOC Tokens × Complexity Multiplier × Pattern Multiplier × Integration Multiplier
```

**Base LOC to Tokens:**

- Standard conversion: 1 line of code ≈ 2-4 tokens (average 3 tokens/LOC)
- Accounts for code generation including syntax, structure, and context

**Complexity Multipliers:**

- **Simple** (1.0x): Straightforward logic, minimal branching
- **Moderate** (1.5x): Some conditionals, loops, error handling
- **Complex** (2.5x): Nested logic, multiple patterns, complex algorithms

**Pattern Multipliers:**

- **Simple pattern** (1.0x): Single responsibility, clear structure
- **Moderate pattern** (1.3x): Multiple responsibilities, some abstraction
- **Complex pattern** (1.8x): Multiple abstractions, design patterns, frameworks

**Integration Multiplier:**

- **No integration** (1.0x): Standalone code
- **Simple integration** (1.2x): Single API/service integration
- **Complex integration** (1.5x): Multiple services, async, complex error handling

**Note:** These multipliers are starting points and should be calibrated per project based on historical data.

### Pattern Complexity Definitions

**Simple Pattern:**

- Single responsibility
- Linear flow (no complex branching)
- Minimal abstraction
- Standard library usage
- **Examples**: CRUD operations, simple data transformations, basic validations

**Moderate Pattern:**

- 2-3 responsibilities
- Some conditional logic and loops
- Basic abstractions (interfaces, simple inheritance)
- Framework usage (standard patterns)
- **Examples**: API endpoints with validation, service layer with business logic, basic design patterns

**Complex Pattern:**

- Multiple responsibilities or high abstraction
- Complex control flow (nested conditionals, multiple loops)
- Advanced abstractions (polymorphism, composition, multiple design patterns)
- Custom framework usage or complex library integration
- **Examples**: Multi-step workflows, complex state machines, advanced architectural patterns

## Estimation Process

### 1. Agent Task Estimation

Estimation starts at the [Agent Task](03-dictionary.md#agent-task) level:

1. **Analyze Task Requirements**
   
   - Review task specification
   - Identify code, analysis, documentation, validation needs
   - Assess complexity factors

2. **Calculate Token Components**
   
   - Estimate Code Tokens
   - Estimate Analysis Tokens
   - Estimate Documentation Tokens
   - Estimate Validation Tokens

3. **Calculate Total Tokens**
   
   - Sum all token components
   - Apply complexity adjustments
   - Validate against similar tasks

### 2. Roll-Up Estimation

Token estimates roll up from lower levels to higher levels:

**Work Unit Estimation:**

```
Work Unit Tokens = Sum of all Agent Task Tokens + Work Unit Overhead
```

**Feature Estimation:**

```
Feature Tokens = Sum of all Work Unit Tokens + Feature Overhead
```

**Project Manifest Estimation:**

```
Project Manifest Tokens = Sum of all Feature Tokens + Project Overhead
```

### 3. Overhead Factors

Overhead accounts for coordination, integration, and management:

**Work Unit Overhead: 5-8% (Default: 6%)**

- **Rationale**: Agent coordination, integration testing between tasks, minor refactoring
- **Calculation**: `Work Unit Overhead = Sum of Agent Task Tokens × 0.06`
- **Example**: 3,450 tokens × 0.06 = 207 tokens (rounded to 200)

**Feature Overhead: 10-15% (Default: 12%)**

- **Rationale**: Feature integration, deployment preparation, cross-work-unit testing, documentation consolidation
- **Calculation**: `Feature Overhead = Sum of Work Unit Tokens × 0.12`
- **Example**: 10,000 tokens × 0.12 = 1,200 tokens

**Project Overhead: 15-20% (Default: 17%)**

- **Rationale**: Project management, cross-feature coordination, architecture decisions, infrastructure setup
- **Calculation**: `Project Overhead = Sum of Feature Tokens × 0.17`
- **Example**: 50,000 tokens × 0.17 = 8,500 tokens

**Adjustment Factors:**

- **Low complexity project**: Reduce overhead by 2-3%
- **High complexity project**: Increase overhead by 3-5%
- **New team/domain**: Increase overhead by 5-10%

**Note:** These percentages align with industry standards and serve as good defaults. Calibrate based on project-specific historical data.

## Token Throughput Rate

### Agent Throughput

Each [agent](03-dictionary.md#agent) has a [token throughput rate](03-dictionary.md#token-throughput-rate) measured in tokens per hour:

```
Throughput Rate = Tokens Processed / Time (hours)
```

### Throughput Factors

Throughput rates vary based on:

- **Agent Capability**: Model performance, specialization
- **Task Complexity**: Simple vs. complex tasks
- **Domain Expertise**: Agent specialization level
- **Tool Support**: Available tools and integrations

### Baseline Throughput Rates

**Agent-Specific Baseline Rates (tokens/hour):**

**General Purpose Agents:**

- **Basic agent**: 150-200 tokens/hour
- **Standard agent**: 200-250 tokens/hour
- **Advanced agent**: 250-350 tokens/hour

**Specialized Agents:**

- **Research/analysis agent**: 180-220 tokens/hour (analysis-heavy)
- **Code generation agent**: 250-350 tokens/hour (code-focused)
- **Documentation agent**: 200-280 tokens/hour (documentation-focused)
- **Testing/validation agent**: 180-240 tokens/hour (testing-focused)

**Throughput Adjustment Factors:**

- **Simple tasks**: +20% throughput
- **Complex tasks**: -30% throughput
- **Domain expertise match**: +15% throughput
- **New domain**: -20% throughput
- **Tool support available**: +10% throughput

**Project-Specific Calibration:**

1. Start with agent-specific baseline rates above
2. Track actual throughput for first 10-20 tasks
3. Calculate average: `Actual Throughput = Total Tokens / Total Hours`
4. Adjust baseline rates based on historical data
5. Recalibrate quarterly or after 50+ tasks

**Note:** Throughput rates should be both agent-specific (baseline) and project-specific (calibrated). These starting points may need adjustment based on programming language, framework, and project characteristics.

### Capacity Planning

**Important:** Agents are not limited by time—they can work continuously. Capacity planning in RHYTHM Method is about **user availability** and **HITL checkpoint frequency**, not agent working hours.

**Capacity Constraints:**

1. **User Availability for HITL Checkpoints**
   
   - How often can the user review and approve work?
   - What are the user's availability windows?
   - Expected response times for approvals?

2. **HITL Gate Configuration**
   
   - High TEMPO: Fewer HITL gates → more work can flow
   - Moderate TEMPO: Balanced HITL gates → steady flow
   - Controlled TEMPO: More HITL gates → slower flow, more control

3. **Work Queue Sizing**
   
   - Size work queue based on user's capacity to review/approve
   - Consider user's availability patterns (daily, weekly)
   - Account for user response time expectations

**Example Capacity Planning:**

- **User available 2 hours/day for reviews**
- **HITL gates configured for every Work Unit completion**
- **Average Work Unit: 3,650 tokens (5.75 hours at 200 tokens/hour)**
- **Capacity**: ~2 Work Units per day (limited by user review time, not agent time)

**Note:** Throughput rates (tokens/hour) are used to estimate **how long work will take**, not to limit agent capacity. Agents can work continuously; the bottleneck is user availability for HITL checkpoints.

## Estimation Accuracy

### Improving Accuracy

Token estimation accuracy improves over time through:

1. **Historical Data**: Learn from completed tasks
2. **Pattern Recognition**: Identify similar tasks
3. **Complexity Analysis**: Refine complexity factors
4. **Agent Performance**: Track actual vs. estimated throughput

### Estimation Refinement

Estimates are continuously refined:

- **Before Execution**: Initial estimation based on specifications
- **During Execution**: Real-time updates based on progress
- **After Execution**: Post-cycle analysis and learning
- **Historical Learning**: Pattern recognition and model updates

## Tracking Actual Token Usage

**Critical Requirement:** To build historical data, compare estimates to actuals, and improve estimation accuracy, you **must track actual token usage** throughout each execution cycle. Without actual token tracking, estimation improvement is impossible.

### What to Track

Track actual tokens used for each component during execution:

**Code Tokens (Actual):**

- Actual lines of code generated
- Actual complexity encountered
- Actual patterns used
- Actual integration complexity

**Analysis Tokens (Actual):**

- Actual requirements analysis performed
- Actual dependency analysis done
- Actual design work completed
- Actual architecture decisions made

**Documentation Tokens (Actual):**

- Actual code comments written
- Actual API documentation created
- Actual specification updates made
- Actual user documentation produced

**Validation Tokens (Actual):**

- Actual unit tests written
- Actual integration tests created
- Actual code review time spent
- Actual quality checks performed

### When to Track

**During Execution Cycle:**

- Track tokens as work progresses
- Record token usage for each Agent Task
- Aggregate tokens at Work Unit completion
- Document token breakdown at Feature completion

**After Execution Cycle:**

- Finalize actual token counts
- Compare to estimated tokens
- Record variance (over/under estimation)
- Store in historical database

### How to Track

**Automated Tracking (Recommended):**

- Agent execution logs capture token usage automatically
- LLM API responses include token counts (input + output tokens)
- Development tools track code generation tokens
- Testing tools track validation tokens
- Documentation tools track documentation tokens

**Manual Tracking (If Needed):**

- Manually record token counts if automated tracking unavailable
- Use token counting tools for code analysis
- Estimate manual work (code review, quality checks) based on time spent
- Document tracking methodology for consistency

**Tracking Format:**

```
Agent Task: [Task Name]
Estimated Tokens: [Total]
Actual Tokens:
  - Code: [actual]
  - Analysis: [actual]
  - Documentation: [actual]
  - Validation: [actual]
Total Actual: [sum]
Variance: [actual - estimated]
Variance %: [(actual - estimated) / estimated × 100]
```

### Storing Historical Data

**Data Storage Requirements:**

- Store actual token counts for every completed Agent Task
- Include metadata: task type, complexity, pattern, agent type, date
- Maintain searchable database for pattern matching
- Enable aggregation by task type, complexity level, agent specialization

**Data Structure:**

- Agent Task level: Detailed breakdown by component
- Work Unit level: Aggregated from Agent Tasks
- Feature level: Aggregated from Work Units
- Project level: Aggregated from Features

### Using Historical Data

**For Estimation Improvement:**

1. Query historical data for similar tasks
2. Compare estimated vs. actual tokens
3. Identify patterns in estimation variance
4. Adjust multipliers and factors based on actual data
5. Refine throughput rates based on actual performance

**For Calibration:**

- Use historical data to calibrate complexity multipliers
- Adjust pattern multipliers based on actual usage
- Refine overhead percentages from actual overhead observed
- Update throughput rates from actual agent performance

**For Estimation Dashboard:**

- Historical data feeds the estimation dashboard
- Enables "Current estimates vs. actuals" visualization
- Provides estimation accuracy metrics
- Supports throughput rate tracking over time

### Integration with Execution Cycles

**During Task Execution:**

- Agents log token usage as they work
- Real-time token tracking updates estimates
- Alerts if actual usage significantly exceeds estimates

**At Work Unit Completion:**

- Finalize actual token counts
- Compare to Work Unit estimate
- Record variance and learnings
- Update historical database

**At Cycle Review:**

- Analyze token usage patterns
- Identify estimation improvements
- Update estimation models
- Refine calibration factors

**Note:** Without tracking actual token usage, the entire estimation improvement cycle breaks down. Tracking actual tokens is not optional—it's essential for the RHYTHM Method to function effectively.

## Work Unit Duration Guidelines

### Execution Cycle Duration: Up to 8 Hours (Guideline)

**Guideline, Not Hard Limit:**

- **Maximum Duration**: Work Units should be designed to complete in 8 hours or less
- **Minimum Duration**: No minimum—cycles can be less than 2 hours if work is completed sooner
- **Purpose**: Maintains focus, enables rapid iteration, supports continuous execution
- **Flexibility**: Not a hard limit—exceptions are allowed with human approval

### When Estimation Exceeds 8 Hours

**If Work Unit estimation exceeds 8 hours:**

1. **Preferred: Split the Work Unit** (Recommended)
   
   - Break into smaller Work Units that each fit within 8 hours
   - Maintain logical boundaries and clear dependencies
   - Each resulting Work Unit should be independently valuable
   - Example: 9-hour Work Unit → Split into 4-hour and 5-hour Work Units

2. **Alternative: Extend Execution Cycle** (Requires Approval)
   
   - If work cannot be reasonably split, extend execution cycle beyond 8 hours
   - Requires human approval and justification
   - Should be exception, not standard practice
   - Consider impact on TEMPO and continuous execution model

3. **Alternative: Reduce Scope**
   
   - Reduce Work Unit scope to fit within 8 hours
   - Defer remaining work to subsequent Work Units
   - Maintain clear boundaries and completion criteria

### Parallel Execution and Duration

**Important:** Parallel execution (multiple agents working simultaneously) does **not** change the execution cycle duration. It only changes the **calendar time** required.

- **Execution Cycle Duration**: Time from start to completion (up to 8 hours target)
- **Calendar Time with Parallel Work**: May be less than duration if agents work in parallel
- **Example**: 8-hour Work Unit with 2 agents in parallel = 4 hours calendar time, but still an 8-hour execution cycle

### Work Unit Splitting Criteria

**Consider splitting when:**

- Estimation exceeds 8 hours
- Work Unit contains multiple distinct deliverables
- Dependencies allow logical separation
- Each resulting Work Unit provides independent value

**Avoid splitting when:**

- Work is tightly coupled and cannot be separated
- Splitting would create artificial boundaries
- Dependencies make splitting impractical
- Work is already at optimal granularity

## Estimation in Practice

### Example: Agent Task Estimation

**Task**: Create user authentication API endpoint

**Step-by-Step Token Calculation:**

**Code Tokens Calculation:**

- Estimated LOC: 150 lines
- Base tokens: 150 × 3 = 450 tokens
- Complexity: Moderate (1.5x) → 450 × 1.5 = 675 tokens
- Pattern: Moderate (1.3x) → 675 × 1.3 = 878 tokens
- Integration: Simple (1.2x) → 878 × 1.2 = 1,053 tokens
- Rounded: **500 tokens** (conservative estimate for endpoint + validation + error handling)

**Analysis Tokens Calculation:**

- Requirements analysis: 50 tokens (security requirements review)
- Dependency analysis: 30 tokens (checking auth dependencies)
- Design work: 80 tokens (API design, request/response structure)
- Architecture decisions: 40 tokens (authentication strategy)
- **Total: 200 tokens**

**Documentation Tokens Calculation:**

- Code comments: 40 tokens (inline documentation)
- API documentation: 80 tokens (endpoint spec, parameters, responses)
- Specification updates: 20 tokens (updating feature spec)
- User documentation: 10 tokens (if needed)
- **Total: 150 tokens**

**Validation Tokens Calculation:**

- Unit tests: 120 tokens (test cases for endpoint logic)
- Integration tests: 100 tokens (API integration tests)
- Code review: 50 tokens (review time)
- Quality checks: 30 tokens (linting, security checks)
- **Total: 300 tokens**

**Total Tokens**: 500 + 200 + 150 + 300 = **1,150 tokens**

**Estimated Duration**:

- Agent throughput: 200 tokens/hour (standard agent baseline)
- Estimated time: 1,150 / 200 = **5.75 hours**

### Example: Work Unit Estimation

**Work Unit**: User authentication system

**Agent Tasks:**

- Task 1: Authentication API endpoint (1,150 tokens)
- Task 2: Password hashing service (800 tokens)
- Task 3: JWT token management (900 tokens)
- Task 4: Authentication middleware (600 tokens)

**Work Unit Tokens**: 3,450 + 207 (6% overhead: 3,450 × 0.06 = 207, rounded to 200) = 3,650 tokens

**Estimated Duration**:

- Parallel execution: 2 agents at 200 tokens/hour each
- Estimated time: 3,650 / 400 = 9.125 hours

**Note:** This Work Unit exceeds the 8-hour execution cycle guideline. Options:

1. **Split the Work Unit** into smaller Work Units (recommended)
2. **Extend the execution cycle** if the work cannot be reasonably split (requires human approval)
3. **Reduce scope** to fit within execution cycle constraints

See [Work Unit Duration Guidelines](#work-unit-duration-guidelines) for detailed guidance.

## Estimation Best Practices

For comprehensive estimation best practices, see [Best Practices](10-best-practices.md#estimation-best-practices).

**Key Practices:**

- Start with Agent Tasks: Always estimate at the Agent Task level first, then roll up
- Track and Use Historical Data: Track actual token usage and leverage historical data
- Let Agents Auto-Estimate: Let agents auto-estimate by default, review only high-value/high-risk work
- Validate Estimates Continuously: Regularly validate estimates by comparing to actual token usage

**See [Tracking Actual Token Usage](#tracking-actual-token-usage) section for detailed tracking requirements.**

## Estimation Tools

### Automated Estimation

**Estimation is primarily automated** in RHYTHM Method. Agents automatically estimate work based on specifications, with minimal human intervention required.

**Automation Level:**

**Fully Automated (Agent-Driven):**

- **Specification Analysis**: Agents analyze specifications automatically
- **Complexity Assessment**: Agents identify complexity factors from specifications
- **Token Calculation**: Agents calculate all token components automatically
- **Roll-Up Estimates**: Agents automatically roll up from Agent Tasks → Work Units → Features
- **Pattern Matching**: Agents match work to historical patterns for estimation
- **Estimation Time**: The time agents spend estimating is **included in Analysis Tokens**

**Human Involvement (Minimal):**

- **Validation**: Humans review estimates for high-value or high-risk work
- **Calibration**: Humans adjust multipliers based on project learnings
- **Override**: Humans can override estimates when needed (rare)

**How Agents Auto-Estimate:**

1. **Specification Parsing**: Agents parse specifications (YAML/JSON/Markdown) automatically
2. **Pattern Recognition**: Agents match specifications to historical patterns
3. **Complexity Analysis**: Agents assess complexity from specification content
4. **Token Calculation**: Agents apply formulas and multipliers automatically
5. **Historical Lookup**: Agents query historical data for similar tasks
6. **Roll-Up**: Agents automatically aggregate estimates up the WBS hierarchy

**Estimation Time Included in Tokens:**

The time agents spend performing estimation is **included in Analysis Tokens**:

- **Requirements Analysis**: Includes time to analyze specifications for estimation
- **Dependency Analysis**: Includes time to identify dependencies for estimation
- **Design Work**: Includes time to understand design requirements for estimation
- **Architecture Decisions**: Includes time to understand architectural context for estimation

**Example**: If an agent spends 10 minutes analyzing a specification to estimate tokens, that analysis time is included in the Analysis Tokens component of the estimate.

**Tools Supporting Token Estimation:**

**Agent Capabilities:**

- **LLM-Based Analysis**: Agents use LLM capabilities to analyze specifications
- **Code Analysis Tools**: Static analysis tools help estimate code complexity
- **Pattern Matching**: Historical data databases for pattern matching
- **Dependency Analyzers**: Tools that help identify dependencies for estimation

**Estimation Automation Tools:**

- **Specification Parsers**: Parse structured specifications (YAML/JSON/Markdown)
- **Historical Data Queries**: Query databases of completed work for similar patterns
- **Complexity Analyzers**: Analyze code patterns, dependencies, integrations
- **Token Calculators**: Automated calculation engines applying formulas and multipliers

**Estimation Workflow:**

1. **Agent receives specification** → Automatically parses and analyzes
2. **Agent identifies patterns** → Matches to historical data
3. **Agent calculates tokens** → Applies formulas automatically
4. **Agent provides estimate** → Includes all components and roll-ups
5. **Human reviews (if needed)** → Only for high-value/high-risk work
6. **Estimate approved** → Ready for execution

**Estimation Overhead:**

**Minimal Overhead:**

- Estimation is automated, so overhead is low
- Estimation time is included in Analysis Tokens (not separate overhead)
- Agents can estimate multiple tasks in parallel
- Historical data lookup is fast (automated queries)

**Estimation Performance:**

- **Single Agent Task**: Typically estimated in seconds to minutes
- **Work Unit (4-5 tasks)**: Estimated in minutes
- **Feature (multiple Work Units)**: Estimated in minutes to hours (depending on complexity)
- **Parallel Estimation**: Multiple tasks can be estimated simultaneously

**For detailed best practices, see [Best Practices](10-best-practices.md#estimation-best-practices).**

### Estimation Dashboards

Real-time visibility into:

- Current estimates vs. actuals (requires actual token tracking)
- Estimation accuracy metrics (calculated from historical actual token data)
- Throughput rate tracking (based on actual token usage over time)
- Capacity planning (based on user availability and HITL checkpoints)
- Estimation automation metrics (how often estimates are auto-approved vs. require review)

**Note:** Estimation dashboards require actual token usage data from execution cycles. Without tracking actual tokens, dashboards cannot display meaningful comparisons or accuracy metrics.

## Summary

Token-based estimation in RHYTHM Method provides precise, measurable estimates that replace abstract story points. By calculating tokens for code generation, analysis, documentation, and validation, and rolling up from Agent Tasks to Work Units to Features, RHYTHM Method enables accurate estimation of work duration and user capacity planning (based on HITL checkpoint availability, not agent working hours). **Critical to the methodology:** Actual token usage must be tracked during every execution cycle to build historical data, compare estimates to actuals, and continuously improve estimation accuracy through historical learning and pattern recognition.

---

## Navigation

**Previous:** [Work Breakdown Structure](07-work-breakdown-structure.md) - WBS hierarchy and relationships
**Next:** [Dependency Management](09-dependency-management.md) - Dependency-driven prioritization

---

## Change History

| Version | Date       | Author              | Description                                                                                                                                    |
| ------- | ---------- | ------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- |
| 1.0.0   | 2025-11-24 | Initial             | Initial estimation documentation                                                                                                               |
| 1.1.0   | 2025-11-26 | rhythm-expert-agent | Added detailed formulas, multipliers, overhead percentages, baseline throughput rates, calibration guidance, and Work Unit duration guidelines |
| 1.2.0   | 2025-12-14 | Agent               | Migrated to numbered format in RHYTHM-Method documentation repository structure                                                                |
