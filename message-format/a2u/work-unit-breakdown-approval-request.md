# Work Unit Breakdown Approval Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for Work Unit breakdown  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.work-unit-breakdown-approval-request",
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
  "workUnit": {
    "workUnitId": "wu-001",
    "featureId": "feat-001",
    "title": "User Login API Endpoint"
  },
  "breakdown": {
    "totalTasks": 5,
    "totalEstimatedTokens": 2000,
    "tasks": [
      {
        "taskId": "task-001",
        "title": "Create login endpoint handler",
        "assignedAgent": "backend-agent-001",
        "estimatedTokens": 500,
        "dependencies": []
      },
      {
        "taskId": "task-002",
        "title": "Implement JWT token generation",
        "assignedAgent": "backend-agent-001",
        "estimatedTokens": 400,
        "dependencies": ["task-001"]
      },
      {
        "taskId": "task-003",
        "title": "Add input validation",
        "assignedAgent": "backend-agent-001",
        "estimatedTokens": 300,
        "dependencies": ["task-001"]
      },
      {
        "taskId": "task-004",
        "title": "Write unit tests",
        "assignedAgent": "qa-agent-001",
        "estimatedTokens": 500,
        "dependencies": ["task-001", "task-002", "task-003"]
      },
      {
        "taskId": "task-005",
        "title": "Add API documentation",
        "assignedAgent": "backend-agent-001",
        "estimatedTokens": 300,
        "dependencies": ["task-001", "task-002"]
      }
    ]
  },
  "priority": "normal",
  "requiresResponseBy": "2025-11-26T16:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.work-unit-breakdown-approval-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting approval
- `toUser`: User to approve
- `workUnit`: Work Unit information
- `breakdown`: Task breakdown details

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `breakdownNotes`: Notes about the breakdown

