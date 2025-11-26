# Conflict Resolution Request (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Request for conflict resolution  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.conflict-resolution-request",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "backend-agent-001",
    "agentType": "backend-agent"
  },
  "conflictingAgents": [
    {
      "agentId": "frontend-agent-001",
      "agentType": "frontend-agent"
    }
  ],
  "conflictType": "code-conflict",
  "conflictDetails": {
    "conflictLocation": "src/api/auth.ts",
    "conflictDescription": "Both agents modified the same file simultaneously",
    "conflictingChanges": {
      "agent1": "link-to-changes-1",
      "agent2": "link-to-changes-2"
    },
    "impact": "high",
    "affectedWorkItems": ["task-12345", "task-12346"]
  },
  "proposedResolution": "merge-changes",
  "requiresHumanIntervention": false
}
```

## Conflict Types

- `code-conflict`: Code merge conflict
- `resource-conflict`: Resource access conflict
- `dependency-conflict`: Dependency resolution conflict
- `priority-conflict`: Priority assignment conflict

## Required Fields

- `messageType`: Must be "a2a.conflict-resolution-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent reporting the conflict
- `conflictingAgents`: List of agents involved in conflict
- `conflictType`: Type of conflict
- `conflictDetails`: Details about the conflict

## Optional Fields

- `proposedResolution`: Proposed resolution approach
- `requiresHumanIntervention`: Whether human intervention is needed
- `escalationLevel`: Escalation level if auto-resolution fails

