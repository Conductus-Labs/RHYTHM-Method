# Dependency Override Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for dependency override  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.dependency-override-request",
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
  "dependency": {
    "dependencyId": "dep-001",
    "fromWorkItem": {
      "workItemId": "wu-001",
      "title": "User Authentication API"
    },
    "toWorkItem": {
      "workItemId": "wu-002",
      "title": "User Profile Frontend"
    },
    "dependencyType": "code",
    "status": "blocked"
  },
  "overrideRequest": {
    "reason": "Dependency is delayed, but workaround available",
    "workaround": "Use mock API for frontend development",
    "risk": "low",
    "impact": "Frontend can proceed with mock, will integrate real API when ready"
  },
  "priority": "normal",
  "requiresResponseBy": "2025-11-26T16:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.dependency-override-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting override
- `toUser`: User to approve
- `dependency`: Dependency information
- `overrideRequest`: Override request details

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `alternativeApproach`: Alternative approach if override not approved

