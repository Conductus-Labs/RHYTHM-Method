# RHYTHM Method Message Formats

**Version:** 1.0.0  
**Last Updated:** 2025-11-26  
**Status:** Initial Draft - For Review

## Overview

RHYTHM Method uses standardized message formats to ensure consistent communication between agents and users. The Baton Framework enforces these formats to maintain consistency across all RHYTHM Method implementations.

## Communication Types

### Agent-to-Agent (A2A) Messages

Messages between specialized agents for coordination, handoffs, and collaboration.

**Available A2A Message Templates:**
- [Task Handoff Request](a2a/task-handoff-request.md) - Request to hand off a task to another agent
- [Task Handoff Response](a2a/task-handoff-response.md) - Response to task handoff request
- [Dependency Status Update](a2a/dependency-status-update.md) - Update on dependency resolution status
- [Work Unit Status Update](a2a/work-unit-status-update.md) - Update on Work Unit progress
- [Resource Request](a2a/resource-request.md) - Request for shared resources
- [Conflict Resolution Request](a2a/conflict-resolution-request.md) - Request for conflict resolution
- [Coordination Request](a2a/coordination-request.md) - Request for multi-agent coordination *(To Be Developed)*
- [Context Sharing](a2a/context-sharing.md) - Share context between agents *(To Be Developed)*
- [Quality Gate Notification](a2a/quality-gate-notification.md) - Notify agents of quality gate results *(To Be Developed)*

### Agent-to-User (A2U) Messages

Messages from agents to users for approvals, notifications, and requests.

**Available A2U Message Templates:**
- [Feature Specification Approval Request](a2u/feature-specification-approval-request.md) - Request approval for Feature specification
- [Work Unit Review Request](a2u/work-unit-review-request.md) - Request review of Work Unit
- [Work Unit Breakdown Approval Request](a2u/work-unit-breakdown-approval-request.md) - Request approval for Work Unit breakdown
- [Execution Cycle Approval Request](a2u/execution-cycle-approval-request.md) - Request approval for execution cycle scope
- [Quality Gate Failure Notification](a2u/quality-gate-failure-notification.md) - Notify user of quality gate failure
- [Deployment Approval Request](a2u/deployment-approval-request.md) - Request approval for production deployment
- [Dependency Override Request](a2u/dependency-override-request.md) - Request approval for dependency override
- [Priority Change Request](a2u/priority-change-request.md) - Request approval for priority change
- [Work Unit Failure Notification](a2u/work-unit-failure-notification.md) - Notify user of Work Unit failure
- [Status Update](a2u/status-update.md) - Regular status update to user

## Work Item Templates

Standardized templates for RHYTHM Method work items.

**Available Work Item Templates:**
- [Project Manifest Template](work-items/project-manifest-template.md) - Template for Project Manifest
- [Feature Template](work-items/feature-template.md) - Template for Feature specification
- [Work Unit Template](work-items/work-unit-template.md) - Template for Work Unit specification
- [Agent Task Template](work-items/agent-task-template.md) - Template for Agent Task specification
- [Bug Template](work-items/bug-template.md) - Template for Bug reports (parented and related)

## Message Format Standards

All messages follow these standards:

1. **Structured Format**: Messages use structured formats (JSON, YAML, or Markdown with defined sections)
2. **Required Fields**: Each message type has required fields that must be present
3. **Optional Fields**: Optional fields provide additional context when needed
4. **Validation**: Messages are validated against their schema before processing
5. **Versioning**: Message formats are versioned to support evolution

## Usage in Baton Framework

The Baton Framework automatically:
- Validates messages against templates
- Enforces required fields
- Provides message templates for agents
- Ensures consistent communication across all agents

## Implementation

When implementing RHYTHM Method:
1. Use the provided message templates
2. Ensure all agents use the same message formats
3. Validate messages before processing
4. Update templates as needed (with versioning)

---

## Navigation

**Previous:** [Documentation Overview](../docs/01-overview.md)  
**Next:** [Agent-to-Agent Messages](a2a/) or [Agent-to-User Messages](a2u/)

---

## Change History

| Version | Date       | Author              | Description                    |
| ------- | ---------- | ------------------- | ------------------------------ |
| 1.0.0   | 2025-11-26 | rhythm-expert-agent | Initial message format documentation |

