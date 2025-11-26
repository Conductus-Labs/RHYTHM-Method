# Resource Request (A2A)

**Message Type:** Agent-to-Agent  
**Purpose:** Request for shared resources  
**Version:** 1.0.0

## Message Structure

```json
{
  "messageType": "a2a.resource-request",
  "version": "1.0.0",
  "timestamp": "2025-11-26T10:00:00Z",
  "fromAgent": {
    "agentId": "backend-agent-001",
    "agentType": "backend-agent"
  },
  "toAgent": {
    "agentId": "devops-agent-001",
    "agentType": "devops-agent"
  },
  "resourceType": "database",
  "resourceDetails": {
    "resourceName": "user-database",
    "action": "create-schema",
    "schemaDefinition": "link-to-schema",
    "requiredCapabilities": ["postgresql", "migrations"]
  },
  "taskId": "task-12345",
  "workUnitId": "wu-001",
  "priority": "high",
  "requestedBy": "2025-11-26T10:00:00Z",
  "neededBy": "2025-11-26T12:00:00Z"
}
```

## Resource Types

- `database`: Database resources
- `api-endpoint`: API endpoint access
- `file`: File or file system access
- `service`: External service access
- `infrastructure`: Infrastructure resources

## Required Fields

- `messageType`: Must be "a2a.resource-request"
- `version`: Message format version
- `timestamp`: ISO 8601 timestamp
- `fromAgent`: Requesting agent
- `toAgent`: Agent managing the resource
- `resourceType`: Type of resource requested
- `resourceDetails`: Details about the resource request
- `priority`: Priority level (low, normal, high, critical)

## Optional Fields

- `taskId`: Related task ID
- `workUnitId`: Related Work Unit ID
- `neededBy`: When resource is needed by
- `estimatedDuration`: Estimated duration of resource use

