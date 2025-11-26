# Deployment Approval Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for production deployment  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.deployment-approval-request",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "devops-agent-001",
    "agentType": "devops-agent"
  },
  "toUser": {
    "userId": "user-001",
    "userName": "Project Owner"
  },
  "deployment": {
    "deploymentId": "deploy-001",
    "environment": "production",
    "workUnits": [
      {
        "workUnitId": "wu-001",
        "title": "User Login API Endpoint",
        "featureId": "feat-001"
      }
    ],
    "changes": {
      "filesChanged": 5,
      "linesAdded": 250,
      "linesRemoved": 10,
      "changeSummary": "Added user login API endpoint with JWT authentication"
    },
    "qualityGates": {
      "passed": 5,
      "failed": 0,
      "results": "link-to-quality-gate-results"
    },
    "rollbackPlan": "link-to-rollback-plan"
  },
  "riskAssessment": {
    "riskLevel": "low",
    "riskFactors": [
      "New feature, no existing functionality affected",
      "All quality gates passed",
      "Comprehensive test coverage"
    ]
  },
  "priority": "high",
  "requiresResponseBy": "2025-11-26T14:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.deployment-approval-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting approval
- `toUser`: User to approve
- `deployment`: Deployment details
- `riskAssessment`: Risk assessment

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `deploymentNotes`: Additional deployment notes

