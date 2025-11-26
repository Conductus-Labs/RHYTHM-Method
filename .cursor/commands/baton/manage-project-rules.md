---
description: Add, update, delete, or show rules in project boundaries file
argument-hint: <add|update|delete|show> [<RULE-NAME>] ["<RULE-DESCRIPTION>"] (description required only for add/update, rule-name not required for show)
---

# Manage Project Rules Command

Execute the manage-boundary-rule workflow to add, update, delete, or show rules in project boundaries file.

## Instructions

You are executing the manage-project-rules command. Follow these steps in order:

### Step 1: Parse Command Arguments

**Action:** Parse and validate command arguments.

1. **Extract arguments:**
   - Operation: `{add|update|delete|show}` (required) - determines the operation to perform
   - Rule name: `{RULE-NAME}` (required for add/update/delete, not required for show) - name of the rule to add/update/delete
   - Rule description: `"{RULE-DESCRIPTION}"` (required only if operation is `add` or `update`) - description of the rule

2. **Validate arguments:**
   - If operation is not `add`, `update`, `delete`, or `show`: Display error and stop
   - If operation is `add`, `update`, or `delete` and `RULE-NAME` is missing: Display error and stop
   - If operation is `add` or `update` and `RULE-DESCRIPTION` is missing: Display error and stop
   - If operation is `show`: No additional arguments required

**Error Messages:**

- **Invalid operation:**
  ```
  ❌ Error: Invalid operation

  Operation must be either 'add', 'update', 'delete', or 'show'.
  Usage: /manage-project-rules {add|update|delete|show} [<RULE-NAME>] ["<RULE-DESCRIPTION>"]
  ```

- **Missing rule name:**
  ```
  ❌ Error: Rule name required

  You must provide a name for the rule when using add, update, or delete operations.
  Usage: /manage-project-rules {add|update|delete} <RULE-NAME> ["<RULE-DESCRIPTION>"]
  ```

- **Missing rule description:**
  ```
  ❌ Error: Rule description required

  You must provide a description for the rule when adding or updating.
  Usage: /manage-project-rules {add|update} <RULE-NAME> "<RULE-DESCRIPTION>"
  ```

**Action:** Parse arguments and validate. If validation fails, display error and stop execution.

### Step 2: Handle Show Operation (Conditional)

**Action:** If operation is `show`, display rules and exit without executing workflow.

**When to execute:** This step executes when operation is `show`.

1. **Load boundaries file:**
   - Read `.baton/boundaries/project-boundaries.md`
   - Parse YAML frontmatter
   - Extract "Always Do" section

2. **Display rules:**
   - Format and display all rules from the "Always Do" section
   - Show rule categories and their action items
   - Display in a clean, readable format

3. **Exit:** Do NOT proceed to workflow execution

**Action:** If operation is `show`, load boundaries file, display rules, and exit. Do not proceed to workflow execution.

### Step 3: Load Workflow Definition (Conditional)

**Action:** Read the manage-boundary-rule workflow file.

**When to execute:** This step executes when operation is NOT `show`.

- **File**: `.baton/workflows/manage-boundary-rule.yml`
- **Purpose**: Complete workflow definition with steps, error handling, and command references
- **Extract**:
  - Workflow name and purpose
  - Prerequisites
  - Workflow steps
  - Error handling mechanisms
  - Command references

**Action:** Read and understand the complete workflow definition.

### Step 4: Execute Manage Boundary Rule Workflow (Conditional)

**Action:** Execute the manage-boundary-rule workflow with the validated parameters.

**When to execute:** This step executes when operation is NOT `show`.

**Workflow Execution:**

- **Workflow File**: `.baton/workflows/manage-boundary-rule.yml`
- **Parameters**: Pass the following to the workflow:
  - `operation: {add|update|delete}`
  - `boundary_type: "project"`
  - `rule_name: {RULE-NAME}`
  - `rule_description: {RULE-DESCRIPTION}` (only if operation is `add` or `update`)
- **Execution Method**: Follow the workflow steps as defined in the workflow file

**Action:** Execute the workflow with the validated parameters.

### Step 5: Confirm Completion (Conditional)

**Action:** Provide completion summary from workflow execution.

**When to execute:** This step executes when operation is NOT `show`.

The workflow will provide a confirmation message. Display the workflow's completion message to the user.

## Important Notes

- This command executes the manage-boundary-rule workflow for add/update/delete operations
- The `show` operation displays rules without executing the workflow
- Rules are managed in the "Always Do" section
- Workflow file location: `.baton/workflows/manage-boundary-rule.yml`
- Boundaries files location: `.baton/boundaries/`

## Usage Examples

- `/manage-project-rules show` - Shows all rules in project boundaries
- `/manage-project-rules add "Version Management" "Update version numbers following semantic versioning when modifying files"` - Adds a rule to project boundaries
- `/manage-project-rules update "Version Management" "Update version numbers following semantic versioning when modifying files outside hidden folders"` - Updates an existing rule
- `/manage-project-rules delete "Version Management"` - Deletes a rule from project boundaries

