# Task Handoff Request (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Request to hand off a task to another agent  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.task-handoff-request",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "backend-agent-001",
    "agentType": "backend-agent"
  },
  "toAgent": {
    "agentId": "frontend-agent-001",
    "agentType": "frontend-agent"
  },
  "task": {
    "taskId": "task-12345",
    "workUnitId": "wu-001",
    "featureId": "feat-001",
    "taskType": "agent-task",
    "title": "Implement user authentication API endpoint",
    "description": "Create POST /api/auth/login endpoint with JWT token generation",
    "status": "in-progress",
    "progress": 0.75,
    "estimatedTokens": 500,
    "actualTokens": 375,
    "dependencies": ["task-12340"],
    "context": {
      "codeLocation": "src/api/auth.ts",
      "relatedFiles": ["src/models/user.ts", "src/utils/jwt.ts"],
      "specification": "link-to-spec",
      "testFiles": ["tests/api/auth.test.ts"]
    }
  },
  "handoffReason": "task-requires-frontend-integration",
  "handoffNotes": "API endpoint is complete and tested. Frontend agent needs to integrate the authentication flow.",
  "requiredCapabilities": ["frontend-integration", "api-consumption"],
  "priority": "normal"
}
```

## Required Fields

- `messageType`: Must be "a2a.task-handoff-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Source agent information
- `toAgent`: Target agent information
- `task`: Task details being handed off
- `handoffReason`: Reason for handoff
- `priority`: Priority level (low, normal, high, critical)

## Optional Fields

- `handoffNotes`: Additional context for receiving agent
- `requiredCapabilities`: Capabilities needed to complete task
- `task.context`: Additional task context (code location, files, etc.)

## Response

The receiving agent should respond with [Task Handoff Response](task-handoff-response.md).

