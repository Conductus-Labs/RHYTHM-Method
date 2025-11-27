# GitHub Integration Scripts for RHYTHM Method

**Version:** 1.0.0  
**Last Updated:** 2025-11-27

## Overview

This directory contains scripts and workflows for integrating RHYTHM Method with GitHub using native GitHub features:

- **GitHub Issue Types** - For work item classification (Feature, Work Unit, Agent Task, Bug)
- **GitHub Issue Dependencies** - For native "blocked by" / "blocking" relationships
- **GitHub Projects v2** - For custom fields and work queue management
- **GitHub Actions** - For automated synchronization workflows

All scripts are cross-platform (Bash for Unix/macOS/Linux, PowerShell for Windows) and use GitHub CLI (`gh`) for all operations.

## Table of Contents

- [Quick Start](#quick-start)
- [Prerequisites](#prerequisites)
- [Setup Instructions](#setup-instructions)
- [Script Categories](#script-categories)
- [Usage Examples](#usage-examples)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Platform-Specific Notes](#platform-specific-notes)
- [API Reference](#api-reference)
- [Additional Resources](#additional-resources)

## Quick Start

1. **Install Prerequisites:**
   
   ```bash
   # Install GitHub CLI
   # macOS: brew install gh
   # Linux: See https://cli.github.com/manual/installation
   # Windows: winget install GitHub.cli
   
   # Authenticate
   gh auth login
   
   # Install yq (YAML parser)
   # macOS: brew install yq
   # Linux: See https://github.com/mikefarah/yq#install
   # Windows: winget install mikefarah.yq
   ```

2. **Run Setup Scripts:**
   
   ```bash
   # Interactive setup (recommended for first time)
   ./scripts/github/setup/setup-all.sh
   
   # Or run individual setup steps
   ./scripts/github/setup/setup-issue-types.sh
   ./scripts/github/setup/setup-project.sh
   ```

3. **Create Your First Issue:**
   
   ```bash
   # Create a Feature
   ./scripts/github/create/create-feature.sh
   
   # Create a Work Unit
   ./scripts/github/create/create-work-unit.sh
   ```

4. **Install GitHub Actions Workflow:**
   
   ```bash
   # Copy workflow to .github/workflows/
   cp scripts/github/actions/rhythm-sync.yml .github/workflows/
   ```

## Prerequisites

### Quick Checklist

Before you begin, verify you have:

- [ ] GitHub CLI installed and authenticated
- [ ] yq installed (for YAML parsing)
- [ ] Organization admin permissions (for Issue Types setup)
- [ ] Repository admin permissions (for Project setup)
- [ ] Repository write permissions (for daily operations)

### Required Software

1. **GitHub CLI (`gh`)**
   
   - Version: 2.0.0 or later
   - Installation: https://cli.github.com/manual/installation
   - Authentication: `gh auth login`

2. **YAML Parser (`yq`)**
   
   - Version: 4.0.0 or later
   - Installation: https://github.com/mikefarah/yq#install
   - Required for parsing configuration files

3. **Shell Environment:**
   
   - **Unix/macOS/Linux:** Bash 4.0+ (usually pre-installed)
   - **Windows:** PowerShell 5.1+ or PowerShell Core 7.0+

### Required Permissions

1. **Organization Admin** (for Issue Types setup)
   
   - Required to create organization-level issue types
   - Only needed once during initial setup

2. **Repository Admin** (for Project setup)
   
   - Required to create Projects v2 and custom fields
   - Only needed once during initial setup

3. **Repository Write** (for daily operations)
   
   - Required to create issues, update dependencies, and modify project fields
   - Standard contributor permissions

### Authentication

All scripts use GitHub CLI authentication. Ensure you're authenticated:

```bash
# Check authentication status
gh auth status

# Login if needed
gh auth login

# For CI/CD, use token authentication
echo "$GITHUB_TOKEN" | gh auth login --with-token
```

## Setup Instructions

### Step 1: Initial Configuration

The setup scripts will create a configuration file at `.baton/github-config.yml`. You can also create it manually from the template:

```bash
cp scripts/github/templates/github-config.yml.template .baton/github-config.yml
```

Edit the configuration file to set:

- Organization name
- Repository name
- Project name and description

### Step 2: Create Issue Types

Issue Types are organization-level and only need to be created once:

```bash
# Interactive mode (recommended)
./scripts/github/setup/setup-issue-types.sh

# Non-interactive mode (uses config file)
./scripts/github/setup/setup-issue-types.sh --non-interactive
```

**Required Issue Types:**

- Feature
- Work Unit
- Agent Task
- Bug

### Step 3: Create GitHub Project

Create a GitHub Project v2 with custom fields:

```bash
# Interactive mode (recommended)
./scripts/github/setup/setup-project.sh

# Non-interactive mode (uses config file)
./scripts/github/setup/setup-project.sh --non-interactive
```

**Custom Fields Created:**

- Status (Single Select): Planned, In Progress, Review, Blocked, Completed, Failed
- TEMPO (Single Select): High, Moderate, Controlled
- Assigned Agent (Single Select): Dynamically populated from project config
- Estimated Tokens (Number)
- Actual Tokens (Number)
- Bug Relationship (Single Select): Parented, Related
- Severity (Single Select): Critical, High, Medium, Low

### Step 4: Install Issue Templates

Copy issue templates to `.github/ISSUE_TEMPLATE/`:

```bash
./scripts/github/setup/setup-issue-templates.sh
```

### Step 5: Complete Setup (All Steps)

Run the master setup script to do all steps at once:

```bash
# Interactive mode
./scripts/github/setup/setup-all.sh

# Non-interactive mode
./scripts/github/setup/setup-all.sh --non-interactive

# Skip specific steps
./scripts/github/setup/setup-all.sh --skip-templates --skip-issue-types
```

### Step 6: Install GitHub Actions Workflow

Copy the workflow file to enable automated synchronization:

```bash
# Create workflows directory if it doesn't exist
mkdir -p .github/workflows

# Copy workflow
cp scripts/github/actions/rhythm-sync.yml .github/workflows/
```

The workflow will automatically sync dependencies and project fields when issues are created or updated.

## Script Categories

### Setup Scripts (`setup/`)

Scripts for initial setup and configuration:

- **`setup-issue-types.sh/.ps1`** - Create GitHub Issue Types
- **`setup-project.sh/.ps1`** - Create GitHub Project v2 with custom fields
- **`setup-issue-templates.sh/.ps1`** - Install issue templates
- **`setup-all.sh/.ps1`** - Master setup script (runs all setup steps)

### Creation Scripts (`create/`)

Scripts for creating GitHub Issues:

- **`create-feature.sh/.ps1`** - Create Feature issues
- **`create-work-unit.sh/.ps1`** - Create Work Unit issues
- **`create-agent-task.sh/.ps1`** - Create Agent Task issues
- **`create-bug.sh/.ps1`** - Create Bug issues

### Management Scripts (`manage/`)

Scripts for managing issues and project fields:

- **`sync-dependencies.sh/.ps1`** - Sync dependencies from issue body to native dependencies
- **`update-project-fields.sh/.ps1`** - Update Projects v2 fields from issue body metadata

### Validation Scripts (`validate/`)

Scripts for validating GitHub Issues setup:

- **`validate-issues.sh/.ps1`** - Validate issue types, project fields, dependencies, and metadata

### Actions (`actions/`)

GitHub Actions workflows:

- **`rhythm-sync.yml`** - Automated synchronization workflow

## Usage Examples

### Creating Issues

#### Create a Feature

```bash
# Interactive mode
./scripts/github/create/create-feature.sh

# With parameters
./scripts/github/create/create-feature.sh \
  --title "User Authentication System" \
  --description "Implement OAuth2 authentication" \
  --tempo "High" \
  --tokens 5000 \
  --dependencies "45,46"
```

#### Create a Work Unit

```bash
# Interactive mode
./scripts/github/create/create-work-unit.sh

# With parameters
./scripts/github/create/create-work-unit.sh \
  --title "Login API Endpoint" \
  --parent-feature 45 \
  --tempo "Moderate" \
  --tokens 1500 \
  --dependencies "47"
```

#### Create an Agent Task

```bash
# Interactive mode
./scripts/github/create/create-agent-task.sh

# With parameters
./scripts/github/create/create-agent-task.sh \
  --title "Implement JWT Token Generation" \
  --parent-work-unit 46 \
  --assigned-agent "backend-agent" \
  --tokens 500 \
  --dependencies "48"
```

#### Create a Bug

```bash
# Interactive mode
./scripts/github/create/create-bug.sh

# With parameters
./scripts/github/create/create-bug.sh \
  --title "Login fails with special characters" \
  --severity "High" \
  --relationship "parented" \
  --parent-work-unit 46
```

### Managing Dependencies

#### Sync Dependencies for a Single Issue

```bash
# Sync dependencies from issue body metadata to native dependencies
./scripts/github/manage/sync-dependencies.sh --issue 45

# Dry-run (preview changes)
./scripts/github/manage/sync-dependencies.sh --issue 45 --dry-run

# Verbose output
./scripts/github/manage/sync-dependencies.sh --issue 45 --verbose
```

#### Sync Dependencies for All Issues

```bash
# Sync all issues
./scripts/github/manage/sync-dependencies.sh --all

# Dry-run
./scripts/github/manage/sync-dependencies.sh --all --dry-run
```

### Updating Project Fields

#### Update Fields for a Single Issue

```bash
# Update Projects v2 fields from issue body metadata
./scripts/github/manage/update-project-fields.sh --issue 45

# Dry-run
./scripts/github/manage/update-project-fields.sh --issue 45 --dry-run
```

#### Update Fields for All Issues

```bash
# Update all issues
./scripts/github/manage/update-project-fields.sh --all
```

### Validation

#### Validate Single Issue

```bash
# Validate issue #45
./scripts/github/validate/validate-issues.sh --issue 45

# Verbose output
./scripts/github/validate/validate-issues.sh --issue 45 --verbose
```

#### Validate All Issues

```bash
# Validate all issues in repository
./scripts/github/validate/validate-issues.sh --all
```

### Common Options

All scripts support these common options:

- **`--help`** - Show help message
- **`--verbose`** - Show detailed output
- **`--dry-run`** - Preview changes without applying them (where applicable)
- **`--repo org/repo`** - Specify repository (auto-detected if not provided)

## Configuration

### Configuration File

The main configuration file is located at `.baton/github-config.yml`:

```yaml
github:
  organization: "your-org"
  repository: "your-org/your-repo"

issue_types:
  - name: "Feature"
    description: "Deliverable unit of functionality"
    color: "#1f77b4"
  # ... other issue types

project:
  name: "RHYTHM Method Project"
  visibility: "private"
  description: "Work item tracking and management"
  repository: "your-org/your-repo"
  custom_fields:
    # ... custom field definitions
```

### Field IDs File

After project setup, field IDs are stored in `.baton/github-field-ids.yml`:

```yaml
project:
  id: "PVT_kwHO..."
  name: "RHYTHM Method Project"

fields:
  Status:
    id: "PVTSSF_lADO..."
    type: "single_select"
    options:
      Planned: "PVTSSF_lADO..._option_1"
      "In Progress": "PVTSSF_lADO..._option_2"
      # ... other options
  # ... other fields
```

This file is automatically generated and should not be edited manually.

## Troubleshooting

### Common Issues

#### Issue: "GitHub CLI is not authenticated"

**Solution:**

```bash
gh auth login
gh auth status
```

#### Issue: "Organization admin permissions required"

**Solution:**

- Ensure you have organization admin permissions
- Contact your organization administrator
- Issue types can only be created by organization admins

#### Issue: "Repository admin permissions required"

**Solution:**

- Ensure you have repository admin permissions
- Contact your repository administrator
- Projects v2 can only be created by repository admins

#### Issue: "yq: command not found"

**Solution:**

```bash
# macOS
brew install yq

# Linux
# See https://github.com/mikefarah/yq#install

# Windows
winget install mikefarah.yq
```

#### Issue: "Script permission denied"

**Solution:**

```bash
# Make script executable (Unix/macOS/Linux)
chmod +x scripts/github/**/*.sh

# PowerShell scripts don't need chmod on Windows
```

#### Issue: "Rate limit exceeded"

**Solution:**

- Scripts include automatic rate limit handling with exponential backoff
- Wait a few minutes and retry
- Check your GitHub API rate limit: `gh api rate_limit`

#### Issue: "Issue type not found"

**Solution:**

- Ensure issue types have been created: `./scripts/github/setup/setup-issue-types.sh`
- Verify issue types exist: `gh api orgs/{org}/issue-types`

#### Issue: "Project field not found"

**Solution:**

- Ensure project has been created: `./scripts/github/setup/setup-project.sh`
- Verify field IDs file exists: `.baton/github-field-ids.yml`
- Re-run project setup if field IDs are missing

#### Issue: "Dependency issue does not exist"

**Solution:**

- Verify the dependency issue number exists
- Check issue numbers in dependencies list
- Scripts will skip invalid dependency numbers with a warning

### Debugging

Enable verbose output for detailed debugging:

```bash
# Any script with --verbose flag
./scripts/github/create/create-feature.sh --verbose

# Check GitHub CLI version
gh --version

# Check authentication
gh auth status

# Test API access
gh api user
```

### Getting Help

All scripts include help text:

```bash
# Show help for any script
./scripts/github/create/create-feature.sh --help
./scripts/github/manage/sync-dependencies.sh --help
```

## Platform-Specific Notes

### Windows

**PowerShell Scripts:**

- Use `.ps1` scripts (e.g., `create-feature.ps1`)
- PowerShell 5.1+ or PowerShell Core 7.0+ required
- Scripts use `$PSScriptRoot` for path resolution

**Example:**

```powershell
.\scripts\github\create\create-feature.ps1 -Title "My Feature" -Description "Feature description"
```

**Path Separators:**

- Scripts handle Windows path separators (`\`) automatically
- Use forward slashes (`/`) in repository names: `org/repo`

**Line Endings:**

- Git may warn about CRLF line endings - this is normal on Windows
- Scripts work correctly with both LF and CRLF

### macOS / Linux

**Bash Scripts:**

- Use `.sh` scripts (e.g., `create-feature.sh`)
- Bash 4.0+ required (usually pre-installed)
- Make scripts executable: `chmod +x scripts/github/**/*.sh`

**Example:**

```bash
./scripts/github/create/create-feature.sh --title "My Feature" --description "Feature description"
```

**Permissions:**

- Ensure scripts are executable: `chmod +x scripts/github/**/*.sh`
- Check file permissions: `ls -l scripts/github/**/*.sh`

### Cross-Platform Considerations

**Repository Detection:**

- Scripts auto-detect repository from current git directory
- Can be overridden with `--repo org/repo` parameter

**Configuration Files:**

- YAML files use standard YAML format (works on all platforms)
- Path separators are handled automatically

**Exit Codes:**

- All scripts use standard exit codes (0 = success, 1 = error, 2 = validation failure)
- Consistent across platforms

## API Reference

### GitHub CLI Commands Used

#### Issue Types

Manage organization-level issue types for work item classification.

**List existing issue types:**

```bash
gh api orgs/{org}/issue-types
```

**Create a new issue type:**

```bash
gh api orgs/{org}/issue-types -X POST \
  -f name="Feature" \
  -f description="Deliverable unit of functionality"
```

**Update an existing issue type:**

```bash
gh api orgs/{org}/issue-types/{id} -X PATCH \
  -f name="Feature" \
  -f description="Updated description"
```

#### Issue Dependencies

Manage native GitHub Issue Dependencies (blocked by / blocking relationships).

**Create a dependency (mark issue as blocked by another):**

```bash
gh issue edit {issue-number} --add-blocked-by {blocking-issue-number}
```

**Remove a dependency:**

```bash
gh issue edit {issue-number} --remove-blocked-by {blocking-issue-number}
```

**List dependencies for an issue:**

```bash
gh issue view {issue-number} --json blockedBy,blocking
```

#### Projects v2

Manage GitHub Projects v2 and custom fields using GraphQL API.

**Create a new project:**

```bash
gh api graphql -f query='
  mutation {
    createProjectV2(input: {ownerId: "OWNER_ID", title: "Project Name"}) {
      projectV2 { id }
    }
  }
'
```

**Create a custom field in a project:**

```bash
gh api graphql -f query='
  mutation {
    createProjectV2Field(input: {
      projectId: "PROJECT_ID",
      dataType: SINGLE_SELECT,
      name: "Status"
    }) {
      projectV2Field { id }
    }
  }
'
```

**Update a field value for an issue in a project:**

```bash
gh api graphql -f query='
  mutation {
    updateProjectV2ItemFieldValue(input: {
      projectId: "PROJECT_ID",
      itemId: "ITEM_ID",
      fieldId: "FIELD_ID",
      value: { singleSelectOptionId: "OPTION_ID" }
    }) {
      projectV2Item { id }
    }
  }
'
```

#### Issue Creation

Create GitHub Issues with issue types and dependencies.

**Create an issue with a specific issue type:**

```bash
gh issue create \
  --title "[Feature] User Authentication" \
  --body-file issue-body.md \
  --type "Feature"
```

**Create an issue with dependencies:**

```bash
gh issue create \
  --title "[Work Unit] Login API" \
  --body-file work-unit-body.md \
  --type "Work Unit" \
  --add-blocked-by 45
```

### GraphQL Queries

Scripts use GraphQL for Projects v2 operations. Key queries:

- **Get Project ID:** Query organization/repository projects
- **Get Field IDs:** Query project fields and options
- **Update Field Values:** Mutations for single-select, number, and text fields
- **Add Issue to Project:** Mutation to link issue to project

See `.baton/knowledge/github/github-api.md` for detailed GraphQL examples.

## Additional Resources

### Documentation

- **RHYTHM Method Documentation:** `../../docs/`
- **Work Unit Specification:** `.baton/notes/Feature-01/Work-Unit-01.md`
- **GitHub CLI Manual:** https://cli.github.com/manual/
- **GitHub API Documentation:** https://docs.github.com/en/rest
- **GitHub GraphQL API:** https://docs.github.com/en/graphql

### Knowledge Files

- **GitHub CLI Knowledge:** `.baton/knowledge/github/github-cli.md`
- **GitHub API Knowledge:** `.baton/knowledge/github/github-api.md`

### Related Scripts

- **Setup Scripts:** `setup/`
- **Creation Scripts:** `create/`
- **Management Scripts:** `manage/`
- **Validation Scripts:** `validate/`
- **GitHub Actions:** `actions/`

### Support

For issues or questions:

1. Check the troubleshooting section above
2. Review script help: `./script-name.sh --help`
3. Enable verbose output: `./script-name.sh --verbose`
4. Check GitHub CLI status: `gh auth status`
5. Review logs and error messages

---

**Last Updated:** 2025-11-27  
**Maintained by:** cli-engineer-agent
