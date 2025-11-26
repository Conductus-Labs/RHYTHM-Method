# Execution Cycle Approval Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for execution cycle scope  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.execution-cycle-approval-request",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "rhythm-expert-agent-001",
    "agentType": "rhythm-expert-agent"
  },
  "toUser": {
    "userId": "user-001",
    "userName": "Project Owner"
  },
  "executionCycle": {
    "cycleId": "cycle-001",
    "estimatedDuration": "4-6 hours",
    "estimatedTokens": 2000,
    "workUnits": [
      {
        "workUnitId": "wu-001",
        "title": "User Login API Endpoint",
        "estimatedTokens": 2000
      }
    ],
    "tasks": [
      {
        "taskId": "task-001",
        "title": "Create login endpoint handler",
        "assignedAgent": "backend-agent-001"
      }
    ],
    "dependencies": {
      "blocking": [],
      "ready": ["wu-001"]
    }
  },
  "priority": "normal",
  "requiresResponseBy": "2025-11-26T11:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.execution-cycle-approval-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting approval
- `toUser`: User to approve
- `executionCycle`: Execution cycle details

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `cycleNotes`: Notes about the execution cycle

