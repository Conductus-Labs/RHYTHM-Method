# Work Unit Status Update (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Update on Work Unit progress  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.work-unit-status-update",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "backend-agent-001",
    "agentType": "backend-agent"
  },
  "toAgents": [
    {
      "agentId": "frontend-agent-001",
      "agentType": "frontend-agent"
    },
    {
      "agentId": "qa-agent-001",
      "agentType": "qa-agent"
    }
  ],
  "workUnit": {
    "workUnitId": "wu-001",
    "featureId": "feat-001",
    "title": "User authentication API",
    "status": "in-progress",
    "progress": 0.75,
    "estimatedTokens": 2000,
    "actualTokens": 1500,
    "tasks": {
      "total": 5,
      "completed": 3,
      "inProgress": 1,
      "blocked": 1
    },
    "dependencies": {
      "blocking": [],
      "waiting": ["wu-003"]
    },
    "qualityGates": {
      "passed": 2,
      "failed": 0,
      "pending": 1
    }
  },
  "updateType": "progress",
  "notes": "Three tasks completed. One task blocked waiting for dependency wu-003."
}
```

## Update Types

- `progress`: Progress update
- `status-change`: Status changed (e.g., in-progress → blocked)
- `completion`: Work Unit completed
- `failure`: Work Unit failed
- `blocked`: Work Unit is blocked

## Required Fields

- `messageType`: Must be "a2a.work-unit-status-update"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent providing the update
- `toAgents`: List of agents that need this update
- `workUnit`: Work Unit information
- `updateType`: Type of update

## Optional Fields

- `notes`: Additional context about the update
- `blockingIssues`: List of issues blocking progress
- `nextSteps`: Planned next steps

