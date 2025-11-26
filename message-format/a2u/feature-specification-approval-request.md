# Feature Specification Approval Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request approval for Feature specification  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.feature-specification-approval-request",
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
  "feature": {
    "featureId": "feat-001",
    "title": "User Authentication System",
    "description": "Complete user authentication system with login, registration, and password reset",
    "businessValue": "Enables user accounts and personalized experience",
    "specification": "link-to-specification",
    "validationCriteria": [
      "Users can register with email and password",
      "Users can login with credentials",
      "Users can reset forgotten passwords",
      "JWT tokens are generated and validated"
    ],
    "dependencies": [],
    "estimatedTokens": 5000,
    "estimatedDuration": "2-3 execution cycles"
  },
  "requestType": "approval",
  "priority": "high",
  "requiresResponseBy": "2025-11-26T14:00:00Z",
  "approvalOptions": {
    "approve": "Approve feature specification and proceed",
    "request-changes": "Request changes to specification",
    "reject": "Reject feature specification"
  }
}
```

## Required Fields

- `messageType`: Must be "a2u.feature-specification-approval-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting approval
- `toUser`: User to approve
- `feature`: Feature specification details
- `requestType`: Type of request (approval, review, etc.)
- `priority`: Priority level

## Optional Fields

- `requiresResponseBy`: When response is needed by
- `approvalOptions`: Available approval options
- `context`: Additional context for decision

