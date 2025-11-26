# Priority Change Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for priority change  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.priority-change-request",
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
  "workItem": {
    "workItemId": "wu-002",
    "workItemType": "work-unit",
    "title": "User Profile Frontend",
    "currentPriority": "normal",
    "proposedPriority": "high"
  },
  "changeRequest": {
    "reason": "Critical path blocker for Feature feat-001",
    "businessImpact": "Delays user authentication feature delivery",
    "currentQueuePosition": 5,
    "proposedQueuePosition": 1
  },
  "priority": "high",
  "requiresResponseBy": "2025-11-26T12:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.priority-change-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting change
- `toUser`: User to approve
- `workItem`: Work item information
- `changeRequest`: Change request details

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `impactAnalysis`: Analysis of impact on other work items

