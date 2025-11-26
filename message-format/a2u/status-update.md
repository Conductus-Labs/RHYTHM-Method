# Status Update (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Regular status update to user  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.status-update",
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
  "updateType": "periodic",
  "updatePeriod": "hourly",
  "projectStatus": {
    "features": {
      "total": 5,
      "inProgress": 2,
      "completed": 1,
      "blocked": 0
    },
    "workUnits": {
      "total": 15,
      "inProgress": 5,
      "completed": 8,
      "blocked": 2
    },
    "tasks": {
      "total": 45,
      "inProgress": 10,
      "completed": 30,
      "blocked": 5
    }
  },
  "recentActivity": [
    {
      "time": "2025-11-26T09:45:00Z",
      "activity": "Work Unit wu-001 completed",
      "type": "completion"
    },
    {
      "time": "2025-11-26T09:30:00Z",
      "activity": "Work Unit wu-002 blocked by dependency",
      "type": "blocked"
    }
  ],
  "pendingApprovals": 3,
  "blockers": [
    {
      "blockerId": "blocker-001",
      "description": "Work Unit wu-002 waiting for dependency wu-001",
      "severity": "medium"
    }
  ],
  "priority": "low"
}
```

## Update Types

- `periodic`: Regular periodic update
- `milestone`: Milestone reached
- `blocker`: Blocker identified
- `completion`: Work item completed

## Required Fields

- `messageType`: Must be "a2u.status-update"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent providing update
- `toUser`: User receiving update
- `updateType`: Type of update

## Optional Fields

- `projectStatus`: Overall project status
- `recentActivity`: Recent activity summary
- `pendingApprovals`: Number of pending approvals
- `blockers`: List of current blockers

