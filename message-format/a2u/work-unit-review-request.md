# Work Unit Review Request (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Request review of Work Unit  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.work-unit-review-request",
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
    "description": "Implement POST /api/auth/login endpoint",
    "specification": "link-to-specification",
    "estimatedTokens": 2000,
    "estimatedDuration": "1 execution cycle (4-6 hours)",
    "dependencies": [],
    "acceptanceCriteria": [
      "Endpoint accepts email and password",
      "Returns JWT token on success",
      "Returns 401 on invalid credentials",
      "Includes rate limiting"
    ]
  },
  "reviewType": "specification-review",
  "reviewCriteria": [
    "Clarity of specification",
    "Completeness of requirements",
    "Feasibility of implementation",
    "Consistency with feature goals"
  ],
  "agentFeedback": {
    "issues": [],
    "assumptions": [
      "JWT library is available",
      "User model exists"
    ],
    "recommendations": [
      "Consider adding refresh token support",
      "Add password strength requirements"
    ]
  },
  "priority": "normal",
  "requiresResponseBy": "2025-11-26T16:00:00Z"
}
```

## Required Fields

- `messageType`: Must be "a2u.work-unit-review-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent requesting review
- `toUser`: User to review
- `workUnit`: Work Unit details
- `reviewType`: Type of review requested

## Optional Fields

- `reviewCriteria`: Criteria for review
- `agentFeedback`: Agent's feedback and analysis
- `requiresResponseBy`: When response is needed by

