# Work Unit Failure Notification (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Notify user of Work Unit failure  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.work-unit-failure-notification",
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
    "title": "User Login API Endpoint",
    "status": "failed"
  },
  "failureDetails": {
    "failureReason": "Multiple task failures",
    "failedTasks": [
      {
        "taskId": "task-001",
        "title": "Create login endpoint handler",
        "failureReason": "Database connection timeout"
      }
    ],
    "rootCause": "Infrastructure issue - database unavailable",
    "failureTime": "2025-11-26T09:45:00Z",
    "retryAttempts": 2
  },
  "impact": {
    "blockedWork": ["wu-002", "wu-003"],
    "affectedFeatures": ["feat-001"],
    "estimatedDelay": "2-4 hours"
  },
  "recoveryOptions": [
    {
      "option": "retry",
      "description": "Retry Work Unit after infrastructure fix",
      "estimatedTime": "1-2 hours"
    },
    {
      "option": "split",
      "description": "Split Work Unit into smaller units",
      "estimatedTime": "2-3 hours"
    },
    {
      "option": "cancel",
      "description": "Cancel Work Unit and replan",
      "estimatedTime": "1 hour"
    }
  ],
  "priority": "high",
  "actionRequired": "select-recovery-option"
}
```

## Required Fields

- `messageType`: Must be "a2u.work-unit-failure-notification"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent reporting the failure
- `toUser`: User to notify
- `workUnit`: Work Unit information
- `failureDetails`: Details about the failure

## Optional Fields

- `impact`: Impact of the failure
- `recoveryOptions`: Available recovery options
- `actionRequired`: What action is required from user

