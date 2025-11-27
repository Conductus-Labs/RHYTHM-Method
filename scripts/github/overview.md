# GitHub Integration Scripts

Setup scripts and workflows for integrating RHYTHM Method with GitHub.

## Overview

These scripts help you set up RHYTHM Method workflows in GitHub using:
- GitHub Issues (for work items)
- GitHub Projects (for project management)
- GitHub Actions (for automation)

## Documentation

**📖 [Complete Documentation (DOCUMENTATION.md)](DOCUMENTATION.md)**

For comprehensive documentation including:
- Quick start guide
- Prerequisites and setup instructions
- Usage examples for all scripts
- Troubleshooting guide
- Platform-specific notes
- API reference

## Quick Start

1. **Install Prerequisites:**
   ```bash
   gh auth login
   # Install yq: brew install yq (macOS) or see DOCUMENTATION.md
   ```

2. **Run Setup:**
   ```bash
   ./scripts/github/setup/setup-all.sh
   ```

3. **Create Issues:**
   ```bash
   ./scripts/github/create/create-feature.sh
   ```

See [DOCUMENTATION.md](DOCUMENTATION.md) for detailed instructions.

## Script Categories

### Setup Scripts (`setup/`)

- `setup-issue-types.sh/.ps1` - Create GitHub Issue Types
- `setup-project.sh/.ps1` - Create GitHub Project v2 with custom fields
- `setup-issue-templates.sh/.ps1` - Install issue templates
- `setup-all.sh/.ps1` - Master setup script

### Creation Scripts (`create/`)

- `create-feature.sh/.ps1` - Create Feature issues
- `create-work-unit.sh/.ps1` - Create Work Unit issues
- `create-agent-task.sh/.ps1` - Create Agent Task issues
- `create-bug.sh/.ps1` - Create Bug issues

### Management Scripts (`manage/`)

- `sync-dependencies.sh/.ps1` - Sync dependencies from issue body to native dependencies
- `update-project-fields.sh/.ps1` - Update Projects v2 fields from issue body metadata

### Validation Scripts (`validate/`)

- `validate-issues.sh/.ps1` - Validate issue types, project fields, dependencies, and metadata

### Actions (`actions/`)

- `rhythm-sync.yml` - Automated synchronization workflow

## Additional Resources

- **Main Documentation:** [DOCUMENTATION.md](DOCUMENTATION.md) - Complete user guide
- **RHYTHM Method Docs:** [../../docs/](../../docs/) - Methodology details
- **GitHub CLI Manual:** https://cli.github.com/manual/

