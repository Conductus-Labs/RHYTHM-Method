---
description: Updates the agent context file with a summary of the current chat session
---

# Sync Context Command

Execute the context-synchronisation workflow to update the `.baton/context/{agent-name}-context.md` file with a summary of the current session.

## Instructions

You are executing the sync-context command. Follow these steps in order:

### Step 1: Load Workflow Definition

**Action:** Read the context-synchronisation workflow file.

- **File**: `.baton/workflows/context-synchronisation.yml`
- **Purpose**: Complete workflow definition with steps, error handling, and command references
- **Extract**:
  - Workflow name and purpose
  - Prerequisites
  - Workflow steps
  - Error handling mechanisms
  - Command references

**Action:** Read and understand the complete workflow definition.

### Step 2: Execute Context Synchronisation Workflow

**Action:** Execute the context-synchronisation workflow by following all steps defined in the workflow file.

- **Workflow File**: `.baton/workflows/context-synchronisation.yml`
- **Execution Method**: Follow each workflow step in order
- **Workflow will**:
  - Validate agent scope
  - Load or create context file using sub-flows
  - Collect session information
  - Update context file with new session entry
  - Display confirmation message

### Step 3: Confirm Completion

**Action:** Provide completion summary from workflow execution.

The workflow will provide a confirmation message. Display the workflow's completion message to the user, including:

- Context file location
- Session summary information
- Status of update

## Important Notes

- This command executes the context-synchronisation workflow
- Only agents with the context-management scope can execute this command
- Always use system date commands, never hardcode dates
- Workflow file location: `.baton/workflows/context-synchronisation.yml`
- Context file location: `.baton/context/{agent-name}-context.md`
- For workflow details, error handling, and message templates, refer to the workflow file

