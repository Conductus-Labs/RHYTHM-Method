# Create GitHub Agent Task Issue for RHYTHM Method
# 
# This script creates an Agent Task issue with proper issue type, parent work unit dependency,
# assigned agent, Projects v2 fields, and metadata using GitHub CLI.
#
# Usage:
#   .\create-agent-task.ps1 [-DryRun] [-Verbose] [-Help] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-ParentWorkUnit PARENT] [-AssignedAgent AGENT] [-Tokens TOKENS] [-Dependencies DEPS]
#
# Options:
#   -DryRun           Preview changes without applying them
#   -Verbose          Show detailed output
#   -Help             Show this help message
#   -Title            Issue title (required if not interactive)
#   -Description      Issue description (required if not interactive)
#   -BodyFile         Path to issue body file (alternative to -Description)
#   -ParentWorkUnit   Parent Work Unit issue number (required if not interactive)
#   -AssignedAgent    Assigned agent name (required if not interactive)
#   -Tokens           Estimated tokens (number)
#   -Dependencies     Comma-separated list of issue numbers this depends on (e.g., "47,48")
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - PowerShell 5.1+ (for YAML parsing)
#
# Features:
#   - Interactive mode (default) or parameter-based mode
#   - Creates issue with "Agent Task" issue type
#   - Sets native dependency on parent work unit
#   - Sets Projects v2 custom fields (Status, Assigned Agent, Estimated Tokens)
#   - Links issue to Project if configured
#   - Supports dry-run mode
#
# Exit codes:
#   0 = Success
#   1 = Error
#   2 = Validation failure

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Help,
    [string]$Title = "",
    [string]$Description = "",
    [string]$BodyFile = "",
    [string]$ParentWorkUnit = "",
    [string]$AssignedAgent = "",
    [string]$Tokens = "",
    [string]$Dependencies = ""
)

# Script directory and paths
# Using $PSScriptRoot (PowerShell 3.0+) instead of Split-Path for best practice
$ScriptDir = $PSScriptRoot
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$ConfigFile = Join-Path $RepoRoot ".baton\github-config.yml"
$FieldIdsFile = Join-Path $RepoRoot ".baton\github-field-ids.yml"
$TemplateFile = Join-Path $RepoRoot ".github\ISSUE_TEMPLATE\agent-task.yml"
$ProjectConfigFile = Join-Path $RepoRoot ".baton\project.config.yml"

# Set error action preference
$ErrorActionPreference = "Stop"

# Determine if interactive mode
$Interactive = $Title -eq "" -and $Description -eq "" -and $BodyFile -eq "" -and $ParentWorkUnit -eq "" -and $AssignedAgent -eq ""

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "ℹ $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "✓ $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠ $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
}

function Write-VerboseMessage {
    param([string]$Message)
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -or $VerbosePreference -eq "Continue") {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkBlue
    }
}

# Show help message
function Show-Help {
    $helpText = @"
Create GitHub Agent Task Issue for RHYTHM Method

This script creates an Agent Task issue with proper issue type, parent work unit dependency,
assigned agent, Projects v2 fields, and metadata using GitHub CLI.

USAGE:
    .\create-agent-task.ps1 [OPTIONS] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-ParentWorkUnit PARENT] [-AssignedAgent AGENT] [-Tokens TOKENS] [-Dependencies DEPS]

OPTIONS:
    -DryRun           Preview changes without applying them
    -Verbose          Show detailed output
    -Help             Show this help message

PARAMETERS (for non-interactive mode):
    -Title            Issue title (required if not interactive)
    -Description      Issue description (required if not interactive)
    -BodyFile         Path to issue body file (alternative to -Description)
    -ParentWorkUnit   Parent Work Unit issue number (required if not interactive)
    -AssignedAgent    Assigned agent name (required if not interactive)
    -Tokens           Estimated tokens (number)
    -Dependencies     Comma-separated list of issue numbers this depends on (e.g., "47,48")

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository write permissions
    - PowerShell 5.1+ (for YAML parsing)

EXAMPLES:
    # Interactive mode
    .\create-agent-task.ps1

    # Non-interactive mode
    .\create-agent-task.ps1 -Title "Create Login Handler" -Description "Create login API handler" -ParentWorkUnit 46 -AssignedAgent cli-engineer-agent -Tokens 500

    # With dependencies
    .\create-agent-task.ps1 -Title "Agent Task" -Description "Description" -ParentWorkUnit 46 -AssignedAgent cli-engineer-agent -Dependencies "47,48"

    # Preview changes
    .\create-agent-task.ps1 -Title "Agent Task" -Description "Description" -ParentWorkUnit 46 -AssignedAgent cli-engineer-agent -DryRun

    # Verbose output
    .\create-agent-task.ps1 -Title "Agent Task" -Description "Description" -ParentWorkUnit 46 -AssignedAgent cli-engineer-agent -Verbose
"@
    Write-Host $helpText
    exit 0
}

# Check if command exists
function Test-Command {
    param([string]$Command)
    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Validate prerequisites
function Test-Prerequisites {
    Write-Info "Validating prerequisites..."

    $errors = 0

    # Check GitHub CLI
    if (-not (Test-Command "gh")) {
        Write-Error "GitHub CLI (gh) is not installed"
        Write-Info "Install from: https://cli.github.com/"
        $errors++
    }

    # Check authentication
    try {
        $null = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Not authenticated"
        }
    } catch {
        Write-Error "GitHub CLI is not authenticated"
        Write-Info "Run: gh auth login"
        $errors++
    }

    # Check for YAML parser
    if (-not (Test-Command "yq")) {
        Write-Warning "YAML parser (yq) not found - some features may be limited"
    }

    if ($errors -gt 0) {
        Write-Error "Prerequisites validation failed"
        exit 2
    }

    Write-VerboseMessage "Prerequisites validated"
}

# Get repository from config or auto-detect
function Get-Repository {
    # Try to read from config file
    if (Test-Path $ConfigFile) {
        if (Test-Command "yq") {
            $repo = yq eval '.github.repository // ""' $ConfigFile 2>&1
            if ($repo -and $repo -ne "null" -and $LASTEXITCODE -eq 0) {
                Write-VerboseMessage "Repository from config: $repo"
                return $repo.Trim()
            }
        }
    }

    # Try auto-detection
    try {
        $repo = gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>&1
        if ($LASTEXITCODE -eq 0 -and $repo) {
            Write-VerboseMessage "Auto-detected repository: $repo"
            return $repo.Trim()
        }
    } catch {
        # Ignore
    }

    Write-Error "Could not determine repository"
    return $null
}

# Get project ID from field IDs file
function Get-ProjectId {
    if (-not (Test-Path $FieldIdsFile)) {
        Write-Warning "Field IDs file not found: $FieldIdsFile"
        Write-Info "Project linking will be skipped"
        return $null
    }

    if (Test-Command "yq") {
        $projectId = yq eval '.project.id // ""' $FieldIdsFile 2>&1
        if ($LASTEXITCODE -eq 0 -and $projectId -and $projectId -ne "null") {
            return $projectId.Trim()
        }
    }

    Write-Warning "Project ID not found in field IDs file"
    Write-Info "Project linking will be skipped"
    return $null
}

# Get field ID from field IDs file
function Get-FieldId {
    param([string]$FieldName)
    
    if (-not (Test-Path $FieldIdsFile)) {
        return $null
    }

    if (Test-Command "yq") {
        $fieldId = yq eval ".custom_fields[] | select(.name == `"$FieldName`") | .id // `"`"" $FieldIdsFile 2>&1
        if ($LASTEXITCODE -eq 0 -and $fieldId -and $fieldId -ne "null") {
            return $fieldId.Trim()
        }
    }

    return $null
}

# Validate issue exists and has correct type
function Test-IssueExistsAndType {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$ExpectedType
    )

    Write-VerboseMessage "Validating issue #$IssueNumber exists and is type '$ExpectedType'..."

    try {
        $issueData = gh issue view $IssueNumber --repo $Repo --json number,type 2>&1
        if ($LASTEXITCODE -ne 0 -or -not $issueData) {
            Write-Error "Issue #$IssueNumber does not exist in repository $Repo"
            return $false
        }

        if (Test-Command "yq") {
            $issueType = $issueData | yq eval '.type // ""' - 2>&1
            if ($LASTEXITCODE -eq 0 -and $issueType) {
                if ($issueType -ne $ExpectedType) {
                    Write-Error "Issue #$IssueNumber is type '$issueType', expected '$ExpectedType'"
                    return $false
                }
                Write-VerboseMessage "Issue #$IssueNumber validated: type '$issueType'"
                return $true
            }
        }

        Write-Warning "Could not determine issue type for #$IssueNumber, continuing anyway"
        return $true
    } catch {
        Write-Error "Failed to validate issue #$IssueNumber: $_"
        return $false
    }
}

# Get option ID for a single-select field value
function Get-OptionId {
    param(
        [string]$ProjectId,
        [string]$FieldId,
        [string]$OptionName
    )

    Write-VerboseMessage "Querying option ID for '$OptionName' in field $FieldId..."

    try {
        $response = gh api graphql -f query="
            query {
                node(id: `"$ProjectId`") {
                    ... on ProjectV2 {
                        fields(first: 50) {
                            nodes {
                                ... on ProjectV2SingleSelectField {
                                    id
                                    name
                                    options {
                                        id
                                        name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        " 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not query project fields: $response"
            return $null
        }

        $optionId = $null
        if (Test-Command "jq") {
            $optionId = $response | jq -r ".data.node.fields.nodes[] | select(.id == `"$FieldId`") | .options[] | select(.name == `"$OptionName`") | .id" 2>&1
        } elseif (Test-Command "yq") {
            $optionId = $response | yq eval ".data.node.fields.nodes[] | select(.id == `"$FieldId`") | .options[] | select(.name == `"$OptionName`") | .id" - 2>&1
        }

        if (-not $optionId -or $optionId -eq "null" -or $optionId -eq "") {
            Write-Warning "Could not find option ID for '$OptionName' in field $FieldId"
            return $null
        }

        return $optionId.Trim()
    } catch {
        Write-Warning "Failed to get option ID: $_"
        return $null
    }
}

# Update Projects v2 single-select field value
function Update-ProjectSingleSelectField {
    param(
        [string]$ProjectId,
        [string]$IssueNodeId,
        [string]$FieldId,
        [string]$FieldName,
        [string]$OptionName
    )

    Write-VerboseMessage "Updating single-select field '$FieldName' to '$OptionName'..."

    if ($DryRun) {
        Write-VerboseMessage "[DRY RUN] Would update field '$FieldName' to: $OptionName"
        return $true
    }

    $optionId = Get-OptionId $ProjectId $FieldId $OptionName
    if (-not $optionId) {
        Write-Warning "Could not get option ID for '$OptionName', skipping field update"
        return $false
    }

    Write-VerboseMessage "Found option ID: $optionId"

    try {
        $response = gh api graphql -f query="
            mutation {
                updateProjectV2ItemFieldValue(input: {
                    projectId: `"$ProjectId`"
                    itemId: `"$IssueNodeId`"
                    fieldId: `"$FieldId`"
                    value: {
                        singleSelectOptionId: `"$optionId`"
                    }
                }) {
                    projectV2Item {
                        id
                    }
                }
            }
        " 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not update field value: $response"
            return $false
        }

        Write-VerboseMessage "Field '$FieldName' updated to '$OptionName'"
        return $true
    } catch {
        Write-Warning "Failed to update field: $_"
        return $false
    }
}

# Get issue node ID (GraphQL ID) from issue number
function Get-IssueNodeId {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    try {
        $nodeId = gh issue view $IssueNumber --repo $Repo --json id --jq '.id' 2>&1
        if ($LASTEXITCODE -eq 0 -and $nodeId) {
            return $nodeId.Trim()
        }
    } catch {
        # Ignore
    }

    return $null
}

# Get available agents from project.config.yml
function Get-AvailableAgents {
    if (-not (Test-Path $ProjectConfigFile)) {
        Write-Warning "Project config file not found, cannot list available agents"
        return @()
    }

    if (Test-Command "yq") {
        $agents = yq eval '.agents.enabled[].name' $ProjectConfigFile 2>&1
        if ($LASTEXITCODE -eq 0 -and $agents) {
            return $agents -split "`n" | Where-Object { $_ -ne "" }
        }
    }

    Write-Warning "No agents found in project config"
    return @()
}

# Create issue body with metadata
function New-IssueBody {
    $bodyContent = ""
    
    if ($BodyFile -and (Test-Path $BodyFile)) {
        $bodyContent = Get-Content $BodyFile -Raw
    } elseif ($Description) {
        $bodyContent = $Description
    } else {
        Write-Error "No issue body content provided"
        return $null
    }

    # Append RHYTHM Method metadata
    $metadata = @"

---

<!-- RHYTHM Method Metadata -->
**Task ID:** task-XXX (auto-generated)
**Parent Work Unit:** #$ParentWorkUnit
**Assigned Agent:** $AssignedAgent
**Status:** planned
**Priority Level:** level-0 (calculated from dependencies)
**Estimated Tokens:** $Tokens
**Actual Tokens:** [updated during execution]
**Estimated Duration:** [typically 30 minutes to 2 hours]
**Actual Duration:** [tracked during execution]
**Dependencies:** $Dependencies (also tracked via native dependencies)
"@

    return $bodyContent + $metadata
}

# Interactive prompt for issue details
function Request-IssueDetails {
    Write-Info "Enter Agent Task details:"
    Write-Host ""

    # Title
    while ($Title -eq "") {
        $Title = Read-Host "Agent Task title"
        if ($Title -eq "") {
            Write-Error "Title is required"
        }
    }

    # Parent Work Unit
    while ($ParentWorkUnit -eq "") {
        $ParentWorkUnit = Read-Host "Parent Work Unit issue number (e.g., 46)"
        if ($ParentWorkUnit -eq "") {
            Write-Error "Parent Work Unit is required"
        }
    }

    # Assigned Agent
    if ($AssignedAgent -eq "") {
        $availableAgents = Get-AvailableAgents
        
        if ($availableAgents.Count -gt 0) {
            Write-Info "Available agents:"
            foreach ($agent in $availableAgents) {
                Write-Host "  - $agent"
            }
        }
        
        while ($AssignedAgent -eq "") {
            $AssignedAgent = Read-Host "Assigned agent"
            if ($AssignedAgent -eq "") {
                Write-Error "Assigned agent is required"
            }
        }
    }

    # Description
    if ($Description -eq "" -and $BodyFile -eq "") {
        Write-Info "Enter agent task description (end with Ctrl+Z then Enter):"
        $Description = @()
        while ($true) {
            $line = Read-Host
            if ($line -eq "") {
                break
            }
            $Description += $line
        }
        $Description = $Description -join "`n"
    }

    # Estimated tokens
    $script:Tokens = Read-Host "Estimated tokens (optional)"

    # Dependencies
    $script:Dependencies = Read-Host "Dependencies (comma-separated issue numbers, e.g., 47,48)"
}

# Main function
function Main {
    if ($Help) {
        Show-Help
    }

    Write-Info "Create GitHub Agent Task Issue for RHYTHM Method"
    Write-Info "=================================================="

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    # Validate prerequisites
    Test-Prerequisites

    # Get repository
    $repo = Get-Repository
    if (-not $repo) {
        exit 1
    }
    Write-Info "Using repository: $repo"

    # Interactive mode
    if ($Interactive) {
        Request-IssueDetails
    }

    # Validate required fields
    if ($Title -eq "") {
        Write-Error "Issue title is required"
        exit 2
    }

    if ($ParentWorkUnit -eq "") {
        Write-Error "Parent Work Unit issue number is required"
        exit 2
    }

    if ($AssignedAgent -eq "") {
        Write-Error "Assigned agent is required"
        exit 2
    }

    # Validate parent work unit exists and is correct type
    if (-not $DryRun) {
        if (-not (Test-IssueExistsAndType $repo $ParentWorkUnit "Work Unit")) {
            Write-Error "Parent Work Unit validation failed"
            exit 2
        }
    }

    if ($Description -eq "" -and $BodyFile -eq "") {
        Write-Error "Issue description or body file is required"
        exit 2
    }

    # Create issue body
    $issueBody = New-IssueBody
    if (-not $issueBody) {
        exit 1
    }

    # Create temporary file for issue body
    $bodyFile = [System.IO.Path]::GetTempFileName()
    $issueBody | Out-File -FilePath $bodyFile -Encoding UTF8

    Write-Info "Creating Agent Task issue..."
    Write-VerboseMessage "Title: $Title"
    Write-VerboseMessage "Parent Work Unit: #$ParentWorkUnit"
    Write-VerboseMessage "Assigned Agent: $AssignedAgent"
    Write-VerboseMessage "Estimated Tokens: $(if ($Tokens) { $Tokens } else { 'none' })"

    # Create issue
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create issue:"
        Write-Info "  Title: $Title"
        Write-Info "  Type: Agent Task"
        Write-Info "  Parent Work Unit: #$ParentWorkUnit"
        Write-Info "  Assigned Agent: $AssignedAgent"
        Write-Info "  Body: (see $bodyFile)"
        if ($Dependencies) {
            Write-Info "  Dependencies: $Dependencies"
        }
        Remove-Item $bodyFile -ErrorAction SilentlyContinue
        exit 0
    }

    # Build gh issue create command
    # Note: --type flag doesn't exist in GitHub CLI
    # Issue type must be set via Projects v2 API after creation or via web UI
    $createArgs = @(
        "issue", "create",
        "--repo", $repo,
        "--title", $Title,
        "--body-file", $bodyFile,
        "--add-blocked-by", $ParentWorkUnit
    )

    # Add additional dependencies
    if ($Dependencies) {
        $deps = $Dependencies -split ","
        foreach ($dep in $deps) {
            $dep = $dep.Trim()
            if ($dep -and $dep -ne $ParentWorkUnit) {
                $createArgs += "--add-blocked-by"
                $createArgs += $dep
            }
        }
    }

    # Execute command
    $output = gh $createArgs 2>&1
    $issueNumber = $null
    if ($output -match '#(\d+)') {
        $issueNumber = $matches[1]
    }

    if (-not $issueNumber) {
        Write-Error "Failed to create issue: $output"
        Remove-Item $bodyFile -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Success "Created Agent Task issue #$issueNumber"

    # Clean up
    Remove-Item $bodyFile -ErrorAction SilentlyContinue

    # Link to project and update fields (simplified - full implementation requires option ID lookup)
    $projectId = Get-ProjectId
    if ($projectId) {
        Write-Info "Linking issue to project and updating fields..."

        $issueNodeId = Get-IssueNodeId $repo $issueNumber
        if ($issueNodeId) {
            # Update Status field (set to "Planned")
            $statusFieldId = Get-FieldId "Status"
            if ($statusFieldId) {
                Update-ProjectSingleSelectField $projectId $issueNodeId $statusFieldId "Status" "Planned" | Out-Null
            }

            # Update Assigned Agent field
            $assignedAgentFieldId = Get-FieldId "Assigned Agent"
            if ($assignedAgentFieldId) {
                Update-ProjectSingleSelectField $projectId $issueNodeId $assignedAgentFieldId "Assigned Agent" $AssignedAgent | Out-Null
            }
        }
    }

    Write-Success "Agent Task issue #$issueNumber created successfully"
    Write-Info "View issue: https://github.com/$repo/issues/$issueNumber"
}

# Run main function
Main

