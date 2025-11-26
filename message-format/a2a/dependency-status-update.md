# Dependency Status Update (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Update on dependency resolution status  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.dependency-status-update",
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
    }
  ],
  "dependency": {
    "dependencyId": "dep-001",
    "dependencyType": "code",
    "fromWorkItem": {
      "workItemId": "wu-001",
      "workItemType": "work-unit",
      "title": "User authentication API"
    },
    "toWorkItem": {
      "workItemId": "wu-002",
      "workItemType": "work-unit",
      "title": "User profile frontend"
    },
    "status": "resolved",
    "resolutionDetails": {
      "apiEndpoint": "POST /api/auth/login",
      "apiDocumentation": "link-to-docs",
      "testResults": "all-tests-passing",
      "deploymentStatus": "deployed-to-staging"
    }
  }
}
```

## Status Values

- `blocked`: Dependency is blocking dependent work
- `in-progress`: Dependency work is in progress
- `resolved`: Dependency is resolved and ready
- `failed`: Dependency work failed

## Required Fields

- `messageType`: Must be "a2a.dependency-status-update"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent providing the update
- `toAgents`: List of agents that depend on this work
- `dependency`: Dependency information
- `dependency.status`: Current status of the dependency

## Optional Fields

- `resolutionDetails`: Details about how dependency was resolved
- `estimatedResolutionTime`: Estimated time for resolution (if not resolved)
- `blockingIssues`: List of issues blocking resolution

