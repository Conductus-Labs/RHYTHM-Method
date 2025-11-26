# Quality Gate Failure Notification (A2U)

**Message Type:** Agent-to-User  
**Purpose:** Notify user of quality gate failure  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2u.quality-gate-failure-notification",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "qa-agent-001",
    "agentType": "qa-agent"
  },
  "toUser": {
    "userId": "user-001",
    "userName": "Project Owner"
  },
  "qualityGate": {
    "gateId": "gate-001",
    "gateType": "automated-tests",
    "gateName": "Unit Tests",
    "status": "failed",
    "workUnit": {
      "workUnitId": "wu-001",
      "title": "User Login API Endpoint"
    }
  },
  "failureDetails": {
    "failureReason": "3 unit tests failed",
    "failedTests": [
      {
        "testName": "test_login_with_valid_credentials",
        "error": "AssertionError: Expected status 200, got 401"
      },
      {
        "testName": "test_login_with_invalid_credentials",
        "error": "AssertionError: Expected status 401, got 500"
      }
    ],
    "testResults": "link-to-test-results",
    "severity": "high"
  },
  "actionRequired": "review-and-approve-fix",
  "priority": "high",
  "blockingWork": ["wu-002", "wu-003"]
}
```

## Required Fields

- `messageType`: Must be "a2u.quality-gate-failure-notification"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Agent reporting the failure
- `toUser`: User to notify
- `qualityGate`: Quality gate information
- `failureDetails`: Details about the failure

## Optional Fields

- `actionRequired`: What action is required from user
- `blockingWork`: Work items blocked by this failure
- `retryAttempts`: Number of retry attempts made

