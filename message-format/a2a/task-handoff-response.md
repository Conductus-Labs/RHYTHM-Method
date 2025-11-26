# Task Handoff Response (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Response to task handoff request  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.task-handoff-response",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:05:00Z",
  "fromAgent": {
    "agentId": "frontend-agent-001",
    "agentType": "frontend-agent"
  },
  "toAgent": {
    "agentId": "backend-agent-001",
    "agentType": "backend-agent"
  },
  "requestId": "handoff-request-12345",
  "response": "accepted",
  "taskId": "task-12345",
  "acceptanceNotes": "Task accepted. Will integrate authentication API into frontend login flow.",
  "estimatedCompletionTime": "2025-11-26T14:00:00Z",
  "questions": [],
  "concerns": []
}
```

## Response Values

- `accepted`: Agent accepts the handoff
- `rejected`: Agent rejects the handoff (must provide reason)
- `needs-clarification`: Agent needs more information before accepting

## Required Fields

- `messageType`: Must be "a2a.task-handoff-response"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Responding agent information
- `toAgent`: Original requesting agent information
- `requestId`: ID of the original handoff request
- `response`: Response status (accepted, rejected, needs-clarification)
- `taskId`: ID of the task being handed off

## Optional Fields

- `acceptanceNotes`: Notes about acceptance or plans
- `estimatedCompletionTime`: Estimated completion time
- `questions`: List of questions about the task
- `concerns`: List of concerns about the task
- `rejectionReason`: Required if response is "rejected"

