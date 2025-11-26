# Common Challenges with RHYTHM Method

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Initial Draft - For Review

## Overview

This document addresses common challenges teams face when adopting RHYTHM Method and provides practical solutions to overcome them.

## Challenge 1: Understanding TEMPO

**Symptoms:**
- Team members express concern about fast execution cycles
- Work seems to move too quickly to maintain quality
- Uncertainty about when to use different TEMPO levels
- Confusion about HITL gate configuration

**Diagnosis:**
Teams struggle with fast TEMPO because it represents a fundamental shift from traditional methodologies (weeks → hours). The speed difference (24-168x faster) can feel overwhelming, and teams may not understand how to configure TEMPO appropriately for their context.

**Solution:**
- Start with Moderate TEMPO (default) - balanced approach with regular human oversight
- Gradually increase TEMPO as team adapts and gains confidence
- Use HITL gates strategically to maintain control without slowing execution
- Provide training on TEMPO concepts and decision-making
- See [TEMPO](05-tempo.md) for detailed information and decision matrix

## Challenge 2: Dependency Management

**Problem**: Complex dependency graphs are difficult to manage

**Solution**:

- Use automated dependency detection
- Visualize dependency graph
- Prioritize dependency resolution
- Human review of critical dependencies
- See [Dependency Management](09-dependency-management.md) for detailed information

## Challenge 3: Token Estimation

**Symptoms:**
- Initial token estimates are significantly off (over or under)
- Estimates don't match actual work duration
- Uncertainty about how to improve estimation accuracy
- Difficulty calibrating multipliers and factors

**Diagnosis:**
Token estimation accuracy improves over time as historical data accumulates. Initial estimates may be rough because:
- No historical data exists yet
- Complexity multipliers need calibration
- Team-specific factors aren't accounted for
- Pattern recognition hasn't developed

**Solution:**
- Start with rough estimates using provided formulas and multipliers
- Track actual token usage for every completed task (critical requirement)
- Learn from historical data to refine estimates
- Refine estimation models based on actual vs. estimated variance
- Use pattern recognition to match similar work
- Calibrate multipliers and factors based on project-specific data
- See [Estimation](08-estimation.md) for detailed information and improvement strategies

## Challenge 4: Human Integration

**Problem**: Balancing fast TEMPO with human oversight

**Solution**:

- Configure appropriate HITL gates
- Strategic human input at key points
- Real-time visibility and dashboards
- Clear approval processes
- See [Best Practices](10-best-practices.md) for detailed guidance

## Challenge 5: Team Adoption

**Problem**: Team members resist change or don't understand the methodology

**Solution**:

- Provide comprehensive training
- Start with small pilot projects
- Demonstrate value through quick wins
- Involve team in methodology refinement
- Share success stories and learnings

## Challenge 6: Tool Integration

**Problem**: Integrating RHYTHM Method with existing tools is complex

**Solution**:

- Use provided setup scripts
- Start with one tool at a time
- Leverage automation where possible
- Customize integration as needed
- See [Tooling](11-tooling.md) for detailed information

## Challenge 7: Workflow Approval Bottlenecks

**Problem**: Sequential workflow approvals create bottlenecks that slow down fast TEMPO

**Solution**:

- Configure TEMPO-based approval streamlining (High TEMPO = more auto-approval)
- Enable parallel review processes where dependencies allow
- Use automated approval for well-defined, low-risk work
- Batch approvals to reduce human overhead
- Start with Moderate TEMPO and increase automation as team gains experience
- See [Workflows](06-workflows.md) for workflow optimization strategies

## Challenge 8: Project Manifest Sync Issues

**Problem**: Project Manifest stored in markdown file may get out of sync with PM tools

**Solution**:

- **Don't duplicate**: Project Manifest should NOT be duplicated in PM tools (e.g., GitHub Issues)
- **Single source of truth**: Markdown file (`.baton/project.manifest.md`) is the source of truth
- **Conceptual relationships**: Features in PM tools are conceptually parented to Project Manifest
- **Commit to source control**: Add exceptions to `.gitignore` to commit Project Manifest and Project Config
- See [Work Breakdown Structure](07-work-breakdown-structure.md) for implementation details

## Challenge 9: Estimation Overhead

**Problem**: Token estimation seems like it could be a bottleneck if done manually

**Solution**:

- **Automated estimation**: Agents automatically estimate from specifications
- **Minimal overhead**: Estimation time is included in Analysis Tokens (not separate)
- **Parallel processing**: Multiple tasks can be estimated simultaneously
- **Trust automation**: Review estimates only for high-value/high-risk work
- **Historical learning**: Use historical data to improve accuracy over time
- See [Estimation](08-estimation.md) for automated estimation details

## Frequently Asked Questions (FAQ)

### Q: How is RHYTHM Method different from Agile/Scrum?

**A:** RHYTHM Method is designed specifically for AI agents with human integration, not adapted from human-focused methodologies. Key differences:
- **Time Scale:** Execution cycles (hours) vs. sprints (weeks)
- **Estimation:** Token-based (precise) vs. story points (abstract)
- **Prioritization:** Dependency-driven (dependencies first) vs. business value first
- **Execution:** Continuous vs. discrete sprints
- **Planning:** Real-time continuous planning vs. sprint planning meetings

See [Principles](04-principles.md) for detailed comparison.

### Q: Can I use RHYTHM Method with my existing project management tool?

**A:** Yes! RHYTHM Method can be integrated with GitHub, Azure DevOps, Jira, and custom tools. Setup scripts are available (or coming soon) for each tool. See [Tooling](11-tooling.md) for integration options.

### Q: What if my Work Unit estimation exceeds 8 hours?

**A:** You have three options:
1. **Preferred:** Split the Work Unit into smaller units (each < 8 hours)
2. **Alternative:** Extend the execution cycle (requires human approval)
3. **Alternative:** Reduce scope to fit within 8 hours

See [Work Breakdown Structure](07-work-breakdown-structure.md) for detailed guidance.

### Q: How do I convert from story points to tokens?

**A:** Use historical data to map story points to tokens. Rough starting point:
- 1 Story Point: ~200-300 tokens (simple work)
- 2 Story Points: ~400-600 tokens (moderate work)
- 3 Story Points: ~600-900 tokens (complex work)
- 5 Story Points: ~1000-1500 tokens (very complex work)
- 8 Story Points: ~1500-2500 tokens (extremely complex work)

**Note:** These are starting points. Calibrate based on your team's historical data. See [Getting Started](02-getting-started.md) for migration guidance.

### Q: What happens if humans are unavailable for HITL checkpoints?

**A:** RHYTHM Method includes timeout mechanisms:
- **Low-Risk Work:** Auto-approve after timeout (with notification)
- **High-Risk Work:** Queue work, wait for human response
- **Critical Work:** Escalate to backup approver or emergency procedures

Response time expectations and timeout configurations are defined in [TEMPO](05-tempo.md).

### Q: How do I choose the right TEMPO level?

**A:** Start with **Moderate TEMPO** (default) unless you have specific reasons:
- **High TEMPO:** Well-defined, low-risk work, experienced team, limited user availability
- **Controlled TEMPO:** Critical/high-risk work, new team/domain, frequent user availability needed

See [TEMPO](05-tempo.md) for detailed decision matrix and [Quick Reference](15-quick-reference.md) for decision tree.

### Q: What's the difference between a bug "parented" to a Work Unit vs. "related" to a Feature?

**A:**
- **Parented to Work Unit:** Bug found during development → Fixed within current execution cycle (part of Work Unit scope)
- **Related to Feature:** Bug found in production → Requires new Work Unit to fix (separate work item)

This distinction prevents scope creep and eliminates "is it a bug?" debates. See [Work Breakdown Structure](07-work-breakdown-structure.md) for complete bug lifecycle.

### Q: How does dependency-driven prioritization work?

**A:** Dependencies are prioritized first, then business value within the same dependency level:
1. **Level 0:** Work with no dependencies (highest priority)
2. **Level 1:** Work with dependencies on Level 0
3. **Level N:** Work with dependencies on Level N-1
4. **Within Level:** Business value determines order

This ensures prerequisites are completed before dependent work begins. See [Dependency Management](09-dependency-management.md) for details.

### Q: Can I use RHYTHM Method without the Baton Framework?

**A:** Yes, RHYTHM Method is a methodology that can be implemented manually or with custom tooling. However, the **Baton Framework** provides:
- Standardized message formats (A2A, A2U)
- Automated workflows
- Integration with project management tools
- Consistent communication

Using Baton Framework is recommended but not required. See [Overview](01-overview.md) for Baton Framework details.

### Q: How accurate is token estimation initially?

**A:** Initial estimates may be rough, but accuracy improves over time through:
- Historical data from completed tasks
- Pattern recognition for similar work
- Refinement of complexity factors
- Agent performance tracking

Start with rough estimates and refine as you build historical data. See [Estimation](08-estimation.md) for improvement strategies.

### Q: What if multiple agents need the same resource?

**A:** RHYTHM Method includes conflict resolution mechanisms:
- **Automatic Resolution:** Dependency-driven (prerequisites first), priority-based, first-come-first-served
- **Human Escalation:** Unresolvable conflicts, strategic decisions, complex multi-factor conflicts
- **Conflict Prevention:** Clear boundaries, proper dependency management, resource allocation

See [Principles](04-principles.md) for coordination details.

### Q: How do I migrate from Scrum/Kanban to RHYTHM Method?

**A:** Follow the migration guide in [Getting Started](02-getting-started.md):
1. **Assess Current State:** Inventory existing work items
2. **Map Work Items:** User Stories → Features, Tasks → Work Units, etc.
3. **Handle In-Progress Work:** Complete current sprint or migrate mid-sprint
4. **Project Setup:** Create Project Manifest, configure RHYTHM settings
5. **Gradual Adoption:** Start with new work, migrate existing work gradually
6. **Team Training:** Provide comprehensive training on RHYTHM Method

See [Getting Started](02-getting-started.md) for complete migration guide.

---

## Navigation

**Previous:** [Tooling](11-tooling.md) - Tools and integrations  
**Next:** [Error Handling](13-error-handling.md) - Error handling and failure recovery

---

## Change History

| Version | Date       | Author              | Description                    |
| ------- | ---------- | ------------------- | ------------------------------ |
| 1.0.0   | 2025-11-24 | Initial             | Initial common challenges guide |
| 1.1.0   | 2025-11-26 | technical-writer-agent | Added FAQ section with common questions |

