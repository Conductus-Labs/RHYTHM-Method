# GitHub Issue Templates for RHYTHM Method

This directory contains the source templates for GitHub Issue Forms used in the RHYTHM Method.

## Templates

- **feature.yml** - Feature issue template
- **work-unit.yml** - Work Unit issue template
- **agent-task.yml** - Agent Task issue template
- **bug.yml** - Bug issue template

## Usage

These templates are copied to `.github/ISSUE_TEMPLATE/` by the setup scripts:

```bash
# Bash
./scripts/github/setup/setup-issue-templates.sh

# PowerShell
.\scripts\github\setup\setup-issue-templates.ps1
```

## Value Mapping for Issue Creation Scripts

When creating issues programmatically, the following value mappings should be used:

### Bug Relationship Mapping

- **"Parented to Work Unit"** → **"parented"** (in metadata)
- **"Related to Feature"** → **"related"** (in metadata)

### TEMPO Values

TEMPO values are capitalized in templates (High, Moderate, Controlled) to match dropdown options. Metadata should preserve capitalization for readability, or convert to lowercase if strict format is required.

### Assigned Agent

The Assigned Agent dropdown options should match the agents configured in `.baton/project.config.yml` under `agents.enabled[].name`. The template includes common agents, but should be updated to match your project's configuration.

## Template Structure

All templates follow GitHub Issue Forms format and include:

1. **Form Fields** - Input fields for issue creation
2. **Projects v2 Field Mapping** - Documentation of how form fields map to Projects v2 custom fields
3. **RHYTHM Method Metadata** - Structured metadata section that will be added to issue body

## Notes

- **Zero Labels:** All templates use `labels: []` - categorization is done via native GitHub features (Issue Types, Dependencies, Projects v2)
- **Issue Types:** Issue types are set via `gh` CLI or API, not in templates
- **Metadata:** Metadata sections are automatically maintained by the Baton Framework and GitHub Actions workflows

