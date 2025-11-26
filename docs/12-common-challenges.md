# Common Challenges with RHYTHM Method

**Version:** 1.0.0  
**Last Updated:** 2025-01-XX  
**Status:** Initial Draft - For Review

## Overview

This document addresses common challenges teams face when adopting RHYTHM Method and provides practical solutions to overcome them.

## Challenge 1: Understanding TEMPO

**Problem**: Teams struggle with fast TEMPO (hours vs. weeks)

**Solution**:

- Start with Moderate TEMPO
- Gradually increase as team adapts
- Use HITL gates to maintain control
- Provide training on TEMPO concepts
- See [TEMPO](05-tempo.md) for detailed information

## Challenge 2: Dependency Management

**Problem**: Complex dependency graphs are difficult to manage

**Solution**:

- Use automated dependency detection
- Visualize dependency graph
- Prioritize dependency resolution
- Human review of critical dependencies
- See [Dependency Management](09-dependency-management.md) for detailed information

## Challenge 3: Token Estimation

**Problem**: Token estimation is initially inaccurate

**Solution**:

- Start with rough estimates
- Learn from historical data
- Refine estimation models
- Use pattern recognition
- See [Estimation](08-estimation.md) for detailed information

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

---

## Navigation

**Previous:** [Tooling](11-tooling.md) - Tools and integrations

---

## Change History

| Version | Date       | Author  | Description                    |
| ------- | ---------- | ------- | ------------------------------ |
| 1.0.0   | 2025-11-24 | Initial | Initial common challenges guide |

