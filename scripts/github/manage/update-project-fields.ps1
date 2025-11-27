# Update Project Fields Script for RHYTHM Method
# 
# This script reads issue body metadata and updates corresponding Projects v2 custom fields.
# It parses metadata fields (Status, TEMPO, Tokens, etc.) and updates Projects v2 fields
# using the GitHub Projects v2 API.
#
# Usage:
#   .\update-project-fields.ps1 [-DryRun] [-Verbose] [-Help] [-Issue ISSUE_NUMBER] [-All] [-Repo REPO]
#
# Options:
#   -DryRun         Preview changes without applying them
#   -Verbose        Show detailed output
#   -Help           Show this help message
#   -Issue          Issue number to update (required if not -All)
#   -All            Update all issues in the repository
#   -Repo           Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - PowerShell 5.1+ (for YAML parsing)
#
# Features:
#   - Parses metadata from issue body (Status, TEMPO, Tokens, etc.)
#   - Updates Projects v2 custom fields
#   - Uses option ID lookup for single-select fields
#   - Validates field values before updates
#   - Idempotent (safe to run multiple times)
#   - Supports single issue or batch operations
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
    [string]$Issue = "",
    [switch]$All,
    [string]$Repo = ""
)

# Script directory and paths
# Using $PSScriptRoot (PowerShell 3.0+) instead of Split-Path for best practice
$ScriptDir = $PSScriptRoot
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$ConfigFile = Join-Path $RepoRoot ".baton\github-config.yml"
$FieldIdsFile = Join-Path $RepoRoot ".baton\github-field-ids.yml"

# Set error action preference
$ErrorActionPreference = "Stop"

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
    # Check if verbose flag was explicitly provided (simplified check)
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose") -or $VerbosePreference -eq "Continue") {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkBlue
    }
}

# Show help message
function Show-Help {
    Write-Host @"
Update Project Fields Script for RHYTHM Method

This script reads issue body metadata and updates corresponding Projects v2 custom fields.
It parses metadata fields (Status, TEMPO, Tokens, etc.) and updates Projects v2 fields
using the GitHub Projects v2 API.

USAGE:
    .\update-project-fields.ps1 [OPTIONS] [-Issue ISSUE_NUMBER] [-All]

OPTIONS:
    -DryRun         Preview changes without applying them
    -Verbose        Show detailed output
    -Help           Show this help message
    -Issue          Issue number to update (required if not -All)
    -All            Update all issues in the repository
    -Repo           Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Update project fields for a single issue
    .\update-project-fields.ps1 -Issue 45

    # Update project fields for all issues
    .\update-project-fields.ps1 -All

    # Preview changes (dry-run)
    .\update-project-fields.ps1 -Issue 45 -DryRun

    # Verbose output
    .\update-project-fields.ps1 -Issue 45 -Verbose

"@
}

# Check prerequisites
function Test-Prerequisites {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed"
        Write-Info "Install from: https://cli.github.com/"
        exit 1
    }

    $authStatus = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI is not authenticated"
        Write-Info "Run: gh auth login"
        exit 1
    }

    Write-VerboseMessage "Prerequisites validated"
}

# Test if command exists
function Test-Command {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Get repository
function Get-Repository {
    if ($Repo) {
        return $Repo
    }

    # Try to get from config file
    if (Test-Path $ConfigFile) {
        if (Test-Command "yq") {
            $configRepo = yq eval '.github.repository // ""' $ConfigFile 2>&1
            if ($LASTEXITCODE -eq 0 -and $configRepo -and $configRepo -ne "null") {
                Write-VerboseMessage "Using repository from config: $configRepo"
                return $configRepo.Trim()
            }
        }
    }

    # Try auto-detection
    try {
        $detectedRepo = gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>&1
        if ($LASTEXITCODE -eq 0 -and $detectedRepo) {
            Write-VerboseMessage "Auto-detected repository: $detectedRepo"
            return $detectedRepo.Trim()
        }
    } catch {
        # Ignore
    }

    Write-Error "Could not determine repository"
    Write-Info "Please provide -Repo org/repo or ensure you're in a git repository"
    return $null
}

# Get project ID from field IDs file
function Get-ProjectId {
    if (-not (Test-Path $FieldIdsFile)) {
        Write-Warning "Field IDs file not found: $FieldIdsFile"
        Write-Info "Project field updates will be skipped"
        return $null
    }

    if (Test-Command "yq") {
        $projectId = yq eval '.project.id // ""' $FieldIdsFile 2>&1
        if ($LASTEXITCODE -eq 0 -and $projectId -and $projectId -ne "null") {
            return $projectId.Trim()
        }
    }

    Write-Warning "Project ID not found in field IDs file"
    Write-Info "Project field updates will be skipped"
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

# Update Projects v2 number field value
function Update-ProjectNumberField {
    param(
        [string]$ProjectId,
        [string]$IssueNodeId,
        [string]$FieldId,
        [string]$FieldValue
    )

    Write-VerboseMessage "Updating number field value: $FieldValue..."

    if ($DryRun) {
        Write-VerboseMessage "[DRY RUN] Would update number field to: $FieldValue"
        return $true
    }

    try {
        $response = gh api graphql -f query="
            mutation {
                updateProjectV2ItemFieldValue(input: {
                    projectId: `"$ProjectId`"
                    itemId: `"$IssueNodeId`"
                    fieldId: `"$FieldId`"
                    value: {
                        number: $FieldValue
                    }
                }) {
                    projectV2Item {
                        id
                    }
                }
            }
        " 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Warning "Could not update number field value: $response"
            return $false
        }

        Write-VerboseMessage "Number field value updated"
        return $true
    } catch {
        Write-Warning "Failed to update number field: $_"
        return $false
    }
}

# Get issue body
function Get-IssueBody {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    try {
        $body = gh issue view $IssueNumber --repo $Repo --json body --jq '.body' 2>&1
        if ($LASTEXITCODE -eq 0 -and $body -and $body -ne "null") {
            return $body
        }
    } catch {
        # Ignore
    }

    Write-Warning "Issue #$IssueNumber has no body or is not accessible"
    return $null
}

# Parse metadata field value from issue body
function Get-MetadataField {
    param(
        [string]$Body,
        [string]$FieldName
    )

    # Extract the RHYTHM Method metadata section
    $metadataStart = $Body.IndexOf("<!-- RHYTHM Method Metadata -->")
    if ($metadataStart -eq -1) {
        return $null
    }

    $metadataEnd = $Body.IndexOf("<!-- /RHYTHM Method Metadata -->", $metadataStart)
    if ($metadataEnd -eq -1) {
        $metadataEnd = $Body.Length
    }

    $metadataSection = $Body.Substring($metadataStart, $metadataEnd - $metadataStart)

    # Extract field line (format: **Field Name:** value)
    $pattern = "\*\*$FieldName:\*\*\s*(.+?)(?:\n|$)"
    $match = [regex]::Match($metadataSection, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    if (-not $match.Success) {
        return $null
    }

    $value = $match.Groups[1].Value.Trim()
    if ($value -eq "" -or $value -eq "[updated during execution]" -or $value -eq "[count]") {
        return $null
    }

    return $value
}

# Normalize status value
function Normalize-Status {
    param([string]$Status)
    
    switch ($Status.ToLower()) {
        { $_ -in "planned", "plan" } { return "Planned" }
        { $_ -in "in-progress", "inprogress", "progress" } { return "In Progress" }
        "review" { return "Review" }
        "blocked" { return "Blocked" }
        { $_ -in "completed", "complete", "done" } { return "Completed" }
        { $_ -in "failed", "failure" } { return "Failed" }
        default { return $Status }
    }
}

# Normalize TEMPO value
function Normalize-Tempo {
    param([string]$Tempo)
    
    switch ($Tempo.ToLower()) {
        "high" { return "High" }
        { $_ -in "moderate", "mod" } { return "Moderate" }
        { $_ -in "controlled", "control" } { return "Controlled" }
        default { return $Tempo }
    }
}

# Update project fields for a single issue
function Update-IssueProjectFields {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$ProjectId
    )

    Write-Info "Updating project fields for issue #$IssueNumber..."

    # Get issue node ID
    $issueNodeId = Get-IssueNodeId $Repo $IssueNumber
    if (-not $issueNodeId) {
        Write-Warning "Skipping issue #$IssueNumber - cannot get node ID"
        return $false
    }

    # Get issue body
    $body = Get-IssueBody $Repo $IssueNumber
    if (-not $body) {
        Write-Warning "Skipping issue #$IssueNumber - cannot read body"
        return $false
    }

    $updatedCount = 0

    # Update Status field
    $statusValue = Get-MetadataField $body "Status"
    if ($statusValue) {
        $statusValue = Normalize-Status $statusValue
        $statusFieldId = Get-FieldId "Status"
        if ($statusFieldId) {
            if (Update-ProjectSingleSelectField $ProjectId $issueNodeId $statusFieldId "Status" $statusValue) {
                $updatedCount++
            }
        }
    }

    # Update TEMPO field (for Features and Work Units)
    $tempoValue = Get-MetadataField $body "TEMPO"
    if ($tempoValue) {
        $tempoValue = Normalize-Tempo $tempoValue
        $tempoFieldId = Get-FieldId "TEMPO"
        if ($tempoFieldId) {
            if (Update-ProjectSingleSelectField $ProjectId $issueNodeId $tempoFieldId "TEMPO" $tempoValue) {
                $updatedCount++
            }
        }
    }

    # Update Estimated Tokens field
    $estimatedTokens = Get-MetadataField $body "Estimated Tokens"
    if ($estimatedTokens) {
        if ($estimatedTokens -match '^\d+$') {
            $tokensFieldId = Get-FieldId "Estimated Tokens"
            if ($tokensFieldId) {
                if (Update-ProjectNumberField $ProjectId $issueNodeId $tokensFieldId $estimatedTokens) {
                    $updatedCount++
                }
            }
        }
    }

    # Update Actual Tokens field
    $actualTokens = Get-MetadataField $body "Actual Tokens"
    if ($actualTokens) {
        if ($actualTokens -match '^\d+$') {
            $actualTokensFieldId = Get-FieldId "Actual Tokens"
            if ($actualTokensFieldId) {
                if (Update-ProjectNumberField $ProjectId $issueNodeId $actualTokensFieldId $actualTokens) {
                    $updatedCount++
                }
            }
        }
    }

    # Update Assigned Agent field (for Agent Tasks)
    $assignedAgent = Get-MetadataField $body "Assigned Agent"
    if ($assignedAgent) {
        $assignedAgentFieldId = Get-FieldId "Assigned Agent"
        if ($assignedAgentFieldId) {
            if (Update-ProjectSingleSelectField $ProjectId $issueNodeId $assignedAgentFieldId "Assigned Agent" $assignedAgent) {
                $updatedCount++
            }
        }
    }

    # Update Severity field (for Bugs)
    $severity = Get-MetadataField $body "Severity"
    if ($severity) {
        # Normalize severity
        switch ($severity.ToLower()) {
            "critical" { $severity = "Critical" }
            "high" { $severity = "High" }
            "medium" { $severity = "Medium" }
            "low" { $severity = "Low" }
        }
        $severityFieldId = Get-FieldId "Severity"
        if ($severityFieldId) {
            if (Update-ProjectSingleSelectField $ProjectId $issueNodeId $severityFieldId "Severity" $severity) {
                $updatedCount++
            }
        }
    }

    if ($updatedCount -gt 0) {
        Write-Success "Updated $updatedCount fields for issue #$IssueNumber"
    } else {
        Write-Info "No fields to update for issue #$IssueNumber"
    }

    return $true
}

# Get all issues in repository
function Get-AllIssues {
    param([string]$Repo)

    Write-VerboseMessage "Fetching all issues from repository..."

    try {
        $issues = gh issue list --repo $Repo --json number --jq '.[].number' 2>&1
        if ($LASTEXITCODE -eq 0 -and $issues) {
            return ($issues -split "`n" | Where-Object { $_ -ne "" })
        }
    } catch {
        # Ignore
    }

    Write-Warning "No issues found in repository"
    return @()
}

# Main function
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Info "Update Project Fields Script for RHYTHM Method"
    Write-Info "=============================================="

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    Test-Prerequisites

    # Get repository
    $repo = Get-Repository
    if (-not $repo) {
        exit 1
    }
    Write-Info "Using repository: $repo"

    # Get project ID
    $projectId = Get-ProjectId
    if (-not $projectId) {
        Write-Error "Project not configured. Please run setup scripts first."
        exit 1
    }
    Write-VerboseMessage "Using project ID: $projectId"

    # Validate parameters
    if (-not $All -and -not $Issue) {
        Write-Error "Either -Issue or -All must be specified"
        Show-Help
        exit 2
    }

    if ($All -and $Issue) {
        Write-Error "Cannot specify both -Issue and -All"
        Show-Help
        exit 2
    }

    # Update project fields
    if ($All) {
        Write-Info "Updating project fields for all issues..."
        
        $allIssues = Get-AllIssues $repo
        if ($allIssues.Count -eq 0) {
            Write-Error "Failed to get list of issues"
            exit 1
        }

        $total = 0
        $success = 0
        $skipped = 0

        foreach ($issueNum in $allIssues) {
            $total++
            if (Update-IssueProjectFields $repo $issueNum $projectId) {
                $success++
            } else {
                $skipped++
            }
        }

        Write-Info "Update complete: $success updated, $skipped skipped, $total total"
    } else {
        Update-IssueProjectFields $repo $Issue $projectId
    }

    Write-Success "Script completed."
}

# Run main function
Main

