# RHYTHM Method Best Practices

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Initial Draft - For Review

## Overview

This document provides best practices for implementing and using RHYTHM Method effectively. These practices are based on the core principles of RHYTHM Method and real-world implementation experience.

## TEMPO Best Practices

### Configure TEMPO Appropriately

**Practice**: Start with Moderate TEMPO and adjust based on project needs.

- **High TEMPO**: For well-defined, low-risk work
- **Moderate TEMPO**: Default setting, balanced approach
- **Controlled TEMPO**: For critical, high-risk work

**Benefits**: Appropriate TEMPO ensures fast execution while maintaining control.

### Use HITL Gates Strategically

**Practice**: Configure Human-in-the-Loop gates at critical decision points.

- **Critical Decisions**: Require human approval
- **Validation Checkpoints**: Human validation of specifications
- **Strategic Guidance**: Human input for business decisions
- **Quality Oversight**: Human review of quality gates

**Benefits**: Strategic HITL gates maintain human control without slowing TEMPO unnecessarily.

## Flow Best Practices

### Maintain Continuous Execution

**Practice**: Keep work flowing continuously without artificial boundaries.

- **No Sprint Boundaries**: Work happens continuously
- **Dependency-Driven**: Work ordered by dependencies
- **Real-Time Queue**: Queue updated in real-time
- **Parallel Execution**: Maximize parallel work

**Benefits**: Continuous execution maximizes agent productivity and reduces delays.

### Prioritize by Dependencies First

**Practice**: Always prioritize dependencies before business value.

- **Dependency Levels**: Work ordered by dependency levels
- **Business Value**: Within same level, prioritize by business value
- **Human Override**: Strategic overrides require approval
- **Critical Path**: Identify and prioritize critical path

**Benefits**: Dependency-driven prioritization prevents blocked work and ensures correct execution order.

## Control Best Practices

### Configure HITL Gates Appropriately

**Practice**: Balance human oversight with agent autonomy.

- **Critical Points**: HITL at critical decision points
- **Validation**: Human validation of specifications
- **Approval**: Human approval for major decisions
- **Strategic Input**: Human guidance for business context

**Benefits**: Appropriate HITL gates maintain human control while allowing fast TEMPO.

### Maintain Real-Time Visibility

**Practice**: Provide real-time visibility into all work and decisions.

- **Dashboards**: Real-time work status dashboards
- **Dependency Graph**: Visual dependency graph
- **Quality Metrics**: Real-time quality metrics
- **Progress Tracking**: Real-time progress tracking

**Benefits**: Real-time visibility enables human oversight without slowing execution.

## Coordination Best Practices

### Enable Multi-Agent Collaboration

**Practice**: Structure work to enable effective multi-agent collaboration.

- **Structured Interfaces**: Clear interfaces between agents
- **Shared Context**: Shared context and dependency awareness
- **Coordination Mechanisms**: Automated coordination and conflict resolution
- **Specialization**: Leverage agent specialization

**Benefits**: Multi-agent collaboration enables complex work while maintaining coordination.

### Use Structured Communication

**Practice**: Use structured interfaces for agent-to-agent communication.

- **Machine-Readable**: Structured, machine-readable formats
- **Clear Contracts**: Clear contracts and interfaces
- **Validation**: Automated validation of communication
- **Documentation**: Clear documentation of interfaces

**Benefits**: Structured communication enables reliable multi-agent coordination.

## Precision Best Practices

### Estimate at Agent Task Level

**Practice**: Always estimate at the Agent Task level first, then roll up.

- **Direct Estimation**: Estimate Agent Tasks directly
- **Roll-Up**: Roll up to Work Units and Features
- **Historical Data**: Use historical data for accuracy
- **Pattern Recognition**: Use pattern recognition for similar tasks

**Benefits**: Task-level estimation provides accurate, measurable estimates.

### Continuously Refine Estimates

**Practice**: Continuously refine estimates based on actual execution.

- **Historical Learning**: Learn from completed tasks
- **Pattern Recognition**: Identify and use patterns
- **Complexity Factors**: Refine complexity factors
- **Throughput Rates**: Update agent throughput rates

**Benefits**: Continuous refinement improves estimation accuracy over time.

## Adaptive Best Practices

### Review Execution Cycles Regularly

**Practice**: Regularly review execution cycles to identify improvements.

- **Cycle Analysis**: Analyze cycle performance
- **Process Effectiveness**: Assess process effectiveness
- **Improvement Opportunities**: Identify improvement opportunities
- **Methodology Refinement**: Refine methodology based on learnings

**Benefits**: Regular reviews enable continuous methodology improvement.

### Learn from Historical Data

**Practice**: Use historical data to improve processes and estimates.

- **Estimation Accuracy**: Improve estimation accuracy
- **Dependency Patterns**: Learn dependency patterns
- **Agent Performance**: Track agent performance
- **Process Optimization**: Optimize processes based on data

**Benefits**: Historical learning enables data-driven improvement.

## Work Breakdown Structure Best Practices

### Create Clear Boundaries

**Practice**: Create clear boundaries between WBS levels.

- **Project Manifest**: Single source of truth
- **Features**: Independent, deployable units
- **Work Units**: Single execution cycle scope
- **Agent Tasks**: Single agent, clear completion criteria

**Benefits**: Clear boundaries enable precise estimation and assignment.

### Minimize Dependencies

**Practice**: Design work to minimize dependencies.

- **Independent Features**: Design independent features where possible
- **Parallel Work Units**: Enable parallel Work Units
- **Clear Interfaces**: Clear interfaces reduce coupling
- **Dependency Analysis**: Analyze and minimize dependencies

**Benefits**: Minimizing dependencies enables parallel execution and faster delivery.

## Estimation Best Practices

### Use Token Estimation

**Practice**: Use token-based estimation instead of story points.

- **Measurable Factors**: Calculate tokens for measurable factors
- **Roll-Up**: Roll up from tasks to work units to features
- **Throughput Rates**: Use agent throughput rates for capacity planning
- **Historical Data**: Use historical data for accuracy

**Benefits**: Token estimation provides precise, measurable estimates.

### Account for All Token Components

**Practice**: Account for all token components in estimation.

- **Code Tokens**: Code generation complexity
- **Analysis Tokens**: Requirements and design work
- **Documentation Tokens**: Documentation requirements
- **Validation Tokens**: Testing and quality checks

**Benefits**: Comprehensive token accounting ensures accurate estimates.

### Start with Agent Tasks

**Practice**: Always estimate at the Agent Task level first, then roll up to higher levels.

- **Direct Estimation**: Estimate Agent Tasks directly using specifications
- **Roll-Up**: Automatically roll up to Work Units and Features
- **Accuracy**: Task-level estimation provides most accurate estimates
- **Validation**: Validate roll-up estimates against similar work

**Benefits**: Task-level estimation provides accurate, measurable estimates that roll up reliably.

### Track and Use Historical Data

**Practice**: Track actual token usage and leverage historical data to improve accuracy.

- **Track Actuals**: Track actual token usage during every execution cycle
- **Historical Lookup**: Query historical data for similar tasks
- **Pattern Recognition**: Use patterns from completed work
- **Continuous Improvement**: Refine estimates based on actual vs. estimated variance

**Benefits**: Historical data enables data-driven estimation improvement and pattern recognition.

### Let Agents Auto-Estimate

**Practice**: Let agents auto-estimate by default, review only high-value/high-risk work.

- **Automated Estimation**: Agents automatically estimate from specifications
- **Minimal Review**: Review estimates for high-value or high-risk work only
- **Trust Automation**: Trust automated estimation for routine, well-defined work
- **Estimation Time**: Estimation time is included in Analysis Tokens (not separate overhead)

**Benefits**: Automated estimation reduces overhead while maintaining accuracy for routine work.

### Validate Estimates Continuously

**Practice**: Regularly validate estimates by comparing to actual token usage.

- **Track Actual Tokens**: Track actual tokens during execution cycles
- **Compare Estimates**: Compare estimated vs. actual tokens for each completed task
- **Analyze Patterns**: Analyze estimation accuracy patterns
- **Refine Models**: Refine estimation models based on actual data

**Benefits**: Continuous validation improves estimation accuracy over time.

## Dependency Management Best Practices

### Identify Dependencies Early

**Practice**: Identify dependencies as early as possible.

- **Feature Specification**: Identify during feature specification
- **Work Unit Creation**: Identify during work unit creation
- **Work Unit Breakdown**: Identify during work unit breakdown
- **Automated Detection**: Use automated dependency detection

**Benefits**: Early identification enables proper prioritization and planning.

### Visualize Dependencies

**Practice**: Visualize dependencies in real-time.

- **Dependency Graph**: Real-time dependency graph
- **Critical Path**: Highlight critical path
- **Blocked Work**: Highlight blocked work
- **Resolution Status**: Track resolution status

**Benefits**: Visualization enables better dependency management and planning.

### Minimize Dependencies

**Practice**: Design work to minimize dependencies.

- **Independent Features**: Design independent features where possible
- **Parallel Work Units**: Enable parallel Work Units
- **Clear Interfaces**: Clear interfaces reduce coupling
- **Dependency Analysis**: Analyze and minimize dependencies during design

**Benefits**: Minimizing dependencies enables parallel execution and faster delivery.

### Track Dependencies Continuously

**Practice**: Continuously track dependencies throughout the project.

- **Real-Time Updates**: Dependency graph updates in real-time
- **Automatic Detection**: New dependencies automatically detected
- **Manual Identification**: Humans can manually identify strategic dependencies
- **Resolution Tracking**: Track dependency resolution status

**Benefits**: Continuous tracking ensures accurate dependency management and prioritization.

## Quality Assurance Best Practices

### Use Automated Quality Gates

**Practice**: Use automated quality gates with configurable HITL.

- **Code Quality**: Automated code quality checks
- **Testing**: Automated testing
- **Performance**: Performance validation
- **Security**: Security scanning

**Benefits**: Automated quality gates ensure quality without slowing TEMPO.

### Configure HITL Appropriately

**Practice**: Configure HITL checkpoints at appropriate quality gates.

- **Critical Milestones**: HITL at critical milestones
- **Specification Validation**: Human validation of specifications
- **Deployment Approval**: Human approval for deployments
- **Strategic Decisions**: Human input for strategic decisions

**Benefits**: Appropriate HITL maintains quality while allowing fast execution.

## Workflow Best Practices

### Optimize Workflow Flow

**Practice**: Configure workflows to reduce approval bottlenecks while maintaining control.

- **TEMPO-Based Streamlining**: Use TEMPO level to determine approval requirements
- **Parallel Processing**: Enable parallel review and breakdown when dependencies allow
- **Auto-Approval**: Enable auto-approval for well-defined, low-risk work
- **Batch Approvals**: Batch approve multiple items to reduce overhead
- **Start Moderate**: Start with Moderate TEMPO and adjust based on team experience

**Benefits**: Optimized workflows maintain fast TEMPO while ensuring appropriate control.

### Use Automated Estimation

**Practice**: Let agents auto-estimate by default, review only when needed.

- **Trust Automation**: Agents automatically estimate from specifications
- **Minimal Review**: Review estimates for high-value/high-risk work only
- **Estimation Included**: Estimation time is included in Analysis Tokens
- **Parallel Estimation**: Multiple tasks can be estimated simultaneously

**Benefits**: Automated estimation reduces overhead and maintains accuracy.

## Bug Handling Best Practices

### Understand Bug Relationships

**Practice**: Clearly distinguish between parented bugs (development) and related bugs (production).

- **Development Bugs**: Parented to Work Unit, fixed within current cycle
- **Production Bugs**: Related to Feature, requires new Work Unit
- **Automatic Classification**: Classification based on when/where bug is found
- **No Debates**: Clear rules eliminate "is it a bug?" and priority debates

**Benefits**: Clear bug relationships eliminate friction and prevent scope creep.

### Prevent Scope Creep

**Practice**: Use clear boundaries to prevent scope creep from bugs.

- **Parented Bugs**: Part of Work Unit scope, fixed within current cycle
- **Related Bugs**: Separate Work Unit, follows normal prioritization
- **New Requests**: Always separate Work Unit, never disguised as bugs
- **Decision Criteria**: Automatic classification based on when/where found

**Benefits**: Clear boundaries prevent scope creep and maintain work integrity.

## Summary

RHYTHM Method best practices focus on leveraging agent capabilities (TEMPO, Flow, Coordination, Precision) while maintaining human control (Control, HITL). By following these practices, teams can achieve fast execution cycles while ensuring quality, coordination, and strategic alignment. Continuous improvement through adaptive practices ensures the methodology evolves and improves over time.

**Note**: For detailed information on specific topics, see the relevant documentation:

- **Estimation**: See [Estimation](08-estimation.md) for detailed token estimation methodology
- **Workflows**: See [Workflows](06-workflows.md) for detailed workflow processes
- **Dependency Management**: See [Dependency Management](09-dependency-management.md) for dependency-driven prioritization
- **Work Breakdown Structure**: See [Work Breakdown Structure](07-work-breakdown-structure.md) for WBS hierarchy

---

## Navigation

**Previous:** [Dependency Management](09-dependency-management.md) - Dependency-driven prioritization  
**Next:** [Tooling](11-tooling.md) - Tools and integrations

---

## Change History

| Version | Date       | Author  | Description                  |
| ------- | ---------- | ------- | ---------------------------- |
| 1.0.0   | 2025-11-24 | Initial | Initial best practices guide |
