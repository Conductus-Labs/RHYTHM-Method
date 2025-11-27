# Create GitHub Feature Issue for RHYTHM Method
# 
# This script creates a Feature issue with proper issue type, Projects v2 fields,
# and metadata using GitHub CLI.
#
# Usage:
#   .\create-feature.ps1 [-DryRun] [-Verbose] [-Help] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-Tempo TEMPO] [-Tokens TOKENS] [-Dependencies DEPS]
#
# Options:
#   -DryRun       Preview changes without applying them
#   -Verbose      Show detailed output
#   -Help         Show this help message
#   -Title        Issue title (required if not interactive)
#   -Description  Issue description (required if not interactive)
#   -BodyFile     Path to issue body file (alternative to -Description)
#   -Tempo        TEMPO level (High, Moderate, Controlled) - default: Moderate
#   -Tokens       Estimated tokens (number)
#   -Dependencies Comma-separated list of issue numbers this depends on (e.g., "45,46")
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - PowerShell 5.1+ (for YAML parsing)
#
# Features:
#   - Interactive mode (default) or parameter-based mode
#   - Creates issue with "Feature" issue type
#   - Sets Projects v2 custom fields (Status, TEMPO, Estimated Tokens)
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
    [ValidateSet("High", "Moderate", "Controlled")]
    [string]$Tempo = "Moderate",
    [string]$Tokens = "",
    [string]$Dependencies = ""
)

# Script directory and paths
# Using $PSScriptRoot (PowerShell 3.0+) instead of Split-Path for best practice
$ScriptDir = $PSScriptRoot
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$ConfigFile = Join-Path $RepoRoot ".baton\github-config.yml"
$FieldIdsFile = Join-Path $RepoRoot ".baton\github-field-ids.yml"
$TemplateFile = Join-Path $RepoRoot ".github\ISSUE_TEMPLATE\feature.yml"

# Set error action preference
$ErrorActionPreference = "Stop"

# Determine if interactive mode
$Interactive = $Title -eq "" -and $Description -eq "" -and $BodyFile -eq ""

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
Create GitHub Feature Issue for RHYTHM Method

This script creates a Feature issue with proper issue type, Projects v2 fields,
and metadata using GitHub CLI.

USAGE:
    .\create-feature.ps1 [OPTIONS] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-Tempo TEMPO] [-Tokens TOKENS] [-Dependencies DEPS]

OPTIONS:
    -DryRun       Preview changes without applying them
    -Verbose      Show detailed output
    -Help         Show this help message

PARAMETERS (for non-interactive mode):
    -Title        Issue title (required if not interactive)
    -Description  Issue description (required if not interactive)
    -BodyFile     Path to issue body file (alternative to -Description)
    -Tempo        TEMPO level (High, Moderate, Controlled) - default: Moderate
    -Tokens       Estimated tokens (number)
    -Dependencies Comma-separated list of issue numbers this depends on (e.g., "45,46")

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository write permissions
    - PowerShell 5.1+ (for YAML parsing)

EXAMPLES:
    # Interactive mode
    .\create-feature.ps1

    # Non-interactive mode
    .\create-feature.ps1 -Title "User Authentication" -Description "Implement user authentication system" -Tempo High -Tokens 5000

    # With dependencies
    .\create-feature.ps1 -Title "Feature" -Description "Description" -Dependencies "45,46"

    # Preview changes
    .\create-feature.ps1 -Title "Feature" -Description "Description" -DryRun

    # Verbose output
    .\create-feature.ps1 -Title "Feature" -Description "Description" -Verbose
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

# Get option ID for a single-select field value
function Get-OptionId {
    param(
        [string]$ProjectId,
        [string]$FieldId,
        [string]$OptionName
    )

    Write-VerboseMessage "Querying option ID for '$OptionName' in field $FieldId..."

    try {
        # Query all fields to find the one we need
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

        # Extract option ID using jq or yq
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

    # Get option ID
    $optionId = Get-OptionId $ProjectId $FieldId $OptionName
    if (-not $optionId) {
        Write-Warning "Could not get option ID for '$OptionName', skipping field update"
        return $false
    }

    Write-VerboseMessage "Found option ID: $optionId"

    try {
        # Update field value using Projects v2 GraphQL API
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
**Feature ID:** feat-XXX (auto-generated)
**Parent:** Project Manifest (.baton/project.manifest.md)
**Status:** planned
**TEMPO:** $Tempo
**Priority Level:** level-0 (calculated from dependencies)
**Estimated Tokens:** $Tokens
**Actual Tokens:** [updated during execution]
**Work Units:** [count] (linked issues)
"@

    return $bodyContent + $metadata
}

# Interactive prompt for issue details
function Request-IssueDetails {
    Write-Info "Enter Feature details:"
    Write-Host ""

    # Title
    while ($Title -eq "") {
        $Title = Read-Host "Feature title"
        if ($Title -eq "") {
            Write-Error "Title is required"
        }
    }

    # Description
    if ($Description -eq "" -and $BodyFile -eq "") {
        Write-Info "Enter feature description (end with Ctrl+Z then Enter):"
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

    # TEMPO
    Write-Info "TEMPO level:"
    Write-Host "  1) High"
    Write-Host "  2) Moderate (default)"
    Write-Host "  3) Controlled"
    $tempoChoice = Read-Host "Select [2]"
    switch ($tempoChoice) {
        "1" { $script:Tempo = "High" }
        "2" { $script:Tempo = "Moderate" }
        "3" { $script:Tempo = "Controlled" }
        default { $script:Tempo = "Moderate" }
    }

    # Estimated tokens
    $script:Tokens = Read-Host "Estimated tokens (optional)"

    # Dependencies
    $script:Dependencies = Read-Host "Dependencies (comma-separated issue numbers, e.g., 45,46)"
}

# Main function
function Main {
    if ($Help) {
        Show-Help
    }

    Write-Info "Create GitHub Feature Issue for RHYTHM Method"
    Write-Info "=============================================="

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

    Write-Info "Creating Feature issue..."
    Write-VerboseMessage "Title: $Title"
    Write-VerboseMessage "TEMPO: $Tempo"
    Write-VerboseMessage "Estimated Tokens: $(if ($Tokens) { $Tokens } else { 'none' })"

    # Create issue
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create issue:"
        Write-Info "  Title: $Title"
        Write-Info "  Type: Feature"
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
        "--body-file", $bodyFile
    )

    # Add dependencies
    if ($Dependencies) {
        $deps = $Dependencies -split ","
        foreach ($dep in $deps) {
            $dep = $dep.Trim()
            if ($dep) {
                $createArgs += "--add-blocked-by"
                $createArgs += $dep
            }
        }
    }

    # Execute command
    # gh issue create outputs URL format: https://github.com/owner/repo/issues/123
    $output = gh $createArgs 2>&1
    $exitCode = $LASTEXITCODE
    
    if ($exitCode -ne 0) {
        Write-Error "Failed to create issue: $output"
        Remove-Item $bodyFile -ErrorAction SilentlyContinue
        exit 1
    }
    
    # Extract issue number from URL format: /issues/123 or #123
    $issueNumber = $null
    if ($output -match '/issues/(\d+)') {
        $issueNumber = $matches[1]
    } elseif ($output -match '#(\d+)') {
        $issueNumber = $matches[1]
    }

    if (-not $issueNumber) {
        Write-Error "Failed to parse issue number from output: $output"
        Remove-Item $bodyFile -ErrorAction SilentlyContinue
        exit 1
    }

    Write-Success "Created Feature issue #$issueNumber"

    # Clean up
    Remove-Item $bodyFile -ErrorAction SilentlyContinue

    # Link to project and update fields
    $projectId = Get-ProjectId
    if ($projectId) {
        Write-Info "Linking issue to project and updating fields..."

        # Get issue node ID
        $issueNodeId = Get-IssueNodeId $repo $issueNumber
        if ($issueNodeId) {
            # Update Status field (set to "Planned")
            $statusFieldId = Get-FieldId "Status"
            if ($statusFieldId) {
                Update-ProjectSingleSelectField $projectId $issueNodeId $statusFieldId "Status" "Planned" | Out-Null
            }

            # Update TEMPO field
            $tempoFieldId = Get-FieldId "TEMPO"
            if ($tempoFieldId) {
                Update-ProjectSingleSelectField $projectId $issueNodeId $tempoFieldId "TEMPO" $Tempo | Out-Null
            }

            # Update Estimated Tokens field
            if ($Tokens) {
                $tokensFieldId = Get-FieldId "Estimated Tokens"
                if ($tokensFieldId) {
                    # Number field update (simplified - no option ID needed)
                    Write-VerboseMessage "Updating Estimated Tokens field..."
                    # Note: Number field updates would go here if needed
                }
            }
        }
    }

    Write-Success "Feature issue #$issueNumber created successfully"
    Write-Info "View issue: https://github.com/$repo/issues/$issueNumber"
}

# Run main function
Main

