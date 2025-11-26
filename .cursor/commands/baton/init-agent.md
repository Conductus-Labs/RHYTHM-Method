---
description: Initialize any agent for a new session (lists available agents or initializes specified agent)
argument-hint: <optional: agent-short-name | -list>
---

# Init Agent Command

Execute the agent-initialisation workflow to initialize any agent for a new session. This command can list available agents or initialize a specific agent.

## Instructions

You are executing the init-agent command. Follow these steps in order:

### Step 1: Load Project Configuration

**Action:** Read the project configuration file to get the list of available agents.

- **File**: `.baton/project.config.yml`
- **Purpose**: Extract enabled agents list for validation and listing
- **Extract**:
  - `agents.enabled` array containing agent entries with `name` and `path` fields
  - Store agent list for use in subsequent steps

**Error Handling:**

- **If project.config.yml does not exist:**
  - Display error message:
    ```
    ❌ Error: Project configuration file not found

    File: .baton/project.config.yml

    The project has not been initialized. Please run /project-init first.
    ```
  - Stop execution

- **If agents.enabled is missing or empty:**
  - Display error message:
    ```
    ❌ Error: No agents configured

    No agents are enabled in project.config.yml. Please add agents to the agents.enabled array.
    ```
  - Stop execution

**Action:** Read project.config.yml and extract the agents.enabled array. If file doesn't exist or agents list is empty, display error and stop execution.

### Step 2: Parse Command Arguments

**Action:** Parse command arguments to determine behavior.

1. **Check for arguments:**
   - If no arguments provided: Go to Step 4 (List Agents)
   - If argument is `-list` or `--list`: Go to Step 4 (List Agents)
   - If argument is an agent short name: Go to Step 5 (Validate Agent)

2. **Extract agent short name:**
   - If argument provided and not `-list`/`--list`, treat as agent short name
   - Store agent short name for validation in Step 5

**Action:** Parse arguments and determine next step based on argument value.

### Step 3: List Available Agents (Conditional)

**Action:** Display list of available agents from project.config.yml.

**When to execute:** This step executes when:
- No arguments provided, OR
- Argument is `-list` or `--list`

**Display Format:**

```
Available Agents:
- {agent-name-1}
- {agent-name-2}
- {agent-name-3}
```

**Implementation:**
- Extract `name` field from each entry in `agents.enabled` array
- Display formatted list
- Exit command (do NOT proceed to workflow execution)

**Action:** If listing agents, display the formatted list and exit. Do not proceed to workflow execution.

### Step 4: Validate Agent Short Name (Conditional)

**Action:** Validate that the provided agent short name exists in project.config.yml.

**When to execute:** This step executes when an agent short name argument is provided.

1. **Check agent exists in config:**
   - Search `agents.enabled` array for entry where `name` field matches provided agent short name
   - If not found: Display error with available agents list and exit
   - If found: Continue to next validation

2. **Verify agent file exists:**
   - Read `path` field from matching agent entry
   - Check if agent file exists at specified path
   - If file does not exist: Display error and exit
   - If file exists: Continue to Step 6

**Error Messages:**

- **Agent not found in config:**
  ```
  ❌ Error: Agent '{agent_short_name}' not found

  Available agents:
  - {agent-name-1}
  - {agent-name-2}

  Please use one of the available agents listed above.
  ```

- **Agent file not found:**
  ```
  ❌ Error: Agent file not found

  Agent: {agent_short_name}
  Expected path: {path_from_config}

  Please verify the agent file exists at the specified path in project.config.yml.
  ```

**Action:** Validate agent short name exists in config and agent file exists. If validation fails, display error and exit. If validation succeeds, continue to Step 6.

### Step 5: Load Workflow Definition

**Action:** Read the agent-initialisation workflow file.

- **File**: `.baton/workflows/agent-initialisation.yml`
- **Purpose**: Complete workflow definition with steps, error handling, and command references
- **Extract**:
  - Workflow name and purpose
  - Prerequisites
  - Workflow steps
  - Error handling mechanisms
  - Command references

**Action:** Read and understand the complete workflow definition.

### Step 6: Execute Agent Initialisation Workflow

**Action:** Execute the agent-initialisation workflow with the validated agent short-name parameter.

**Workflow Execution:**

- **Workflow File**: `.baton/workflows/agent-initialisation.yml`
- **Parameter**: Pass `agent_short_name: {validated_agent_short_name}` to the workflow
- **Execution Method**: Follow the workflow steps as defined in the workflow file

**Workflow Steps:**

1. Follow each step in the workflow file in order
2. Pass the `agent_short_name: {validated_agent_short_name}` parameter to workflow steps that require it
3. Execute actions as specified in each workflow step
4. Handle decision points according to workflow definition
5. Follow error handling strategies from workflow file

**Action:** Execute the workflow with the validated agent short name parameter.

### Step 7: Confirm Completion

**Action:** Provide completion summary from workflow execution.

The workflow will provide a confirmation message. Display the workflow's completion message to the user.

## Important Notes

- This command executes the agent-initialisation workflow
- The workflow handles all initialization steps
- Agent short-name is provided as a command argument or can be listed
- If no argument or `-list` is provided, the command lists available agents and exits
- Always use system date commands, never hardcode dates
- Workflow file location: `.baton/workflows/agent-initialisation.yml`
- Project config file location: `.baton/project.config.yml`
- Agent files are located at paths specified in `agents.enabled` array in project.config.yml

## Usage Examples

- `/init-agent` - Lists all available agents
- `/init-agent -list` - Lists all available agents
- `/init-agent baton-agent` - Initializes the baton-agent
- `/init-agent cli-engineer` - Initializes the cli-engineer agent

