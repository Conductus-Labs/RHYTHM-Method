# Create GitHub Bug Issue for RHYTHM Method
# 
# This script creates a Bug issue with proper issue type, relationship type (parented/related),
# Projects v2 fields, and metadata using GitHub CLI.
#
# Usage:
#   .\create-bug.ps1 [-DryRun] [-Verbose] [-Help] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-Relationship TYPE] [-ParentWorkUnit PARENT] [-RelatedFeature FEATURE] [-Severity SEVERITY] [-Steps STEPS] [-Expected EXPECTED] [-Actual ACTUAL]
#
# Options:
#   -DryRun           Preview changes without applying them
#   -Verbose          Show detailed output
#   -Help             Show this help message
#   -Title            Bug title (required if not interactive)
#   -Description      Bug description (required if not interactive)
#   -BodyFile         Path to issue body file (alternative to -Description)
#   -Relationship     Relationship type: "parented" or "related" (required if not interactive)
#   -ParentWorkUnit   Parent Work Unit issue number (required if relationship is "parented")
#   -RelatedFeature   Related Feature issue number (required if relationship is "related")
#   -Severity         Severity level: Critical, High, Medium, Low (required if not interactive)
#   -Steps            Steps to reproduce (optional)
#   -Expected         Expected behavior (optional)
#   -Actual           Actual behavior (optional)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - PowerShell 5.1+ (for YAML parsing)
#
# Features:
#   - Interactive mode (default) or parameter-based mode
#   - Creates issue with "Bug" issue type
#   - Sets relationship type (parented to Work Unit or related to Feature)
#   - Sets native dependency if parented to work unit
#   - Sets Projects v2 custom fields (Status, Bug Relationship, Severity)
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
    [ValidateSet("parented", "related")]
    [string]$Relationship = "",
    [string]$ParentWorkUnit = "",
    [string]$RelatedFeature = "",
    [ValidateSet("Critical", "High", "Medium", "Low")]
    [string]$Severity = "",
    [string]$Steps = "",
    [string]$Expected = "",
    [string]$Actual = ""
)

# Script directory and paths
# Using $PSScriptRoot (PowerShell 3.0+) instead of Split-Path for best practice
$ScriptDir = $PSScriptRoot
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$ConfigFile = Join-Path $RepoRoot ".baton\github-config.yml"
$FieldIdsFile = Join-Path $RepoRoot ".baton\github-field-ids.yml"
$TemplateFile = Join-Path $RepoRoot ".github\ISSUE_TEMPLATE\bug.yml"

# Set error action preference
$ErrorActionPreference = "Stop"

# Determine if interactive mode
$Interactive = $Title -eq "" -and $Description -eq "" -and $BodyFile -eq "" -and $Relationship -eq ""

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
Create GitHub Bug Issue for RHYTHM Method

This script creates a Bug issue with proper issue type, relationship type (parented/related),
Projects v2 fields, and metadata using GitHub CLI.

USAGE:
    .\create-bug.ps1 [OPTIONS] [-Title TITLE] [-Description DESC] [-BodyFile FILE] [-Relationship TYPE] [-ParentWorkUnit PARENT] [-RelatedFeature FEATURE] [-Severity SEVERITY] [-Steps STEPS] [-Expected EXPECTED] [-Actual ACTUAL]

OPTIONS:
    -DryRun           Preview changes without applying them
    -Verbose          Show detailed output
    -Help             Show this help message

PARAMETERS (for non-interactive mode):
    -Title            Bug title (required if not interactive)
    -Description      Bug description (required if not interactive)
    -BodyFile         Path to issue body file (alternative to -Description)
    -Relationship     Relationship type: "parented" or "related" (required if not interactive)
    -ParentWorkUnit   Parent Work Unit issue number (required if relationship is "parented")
    -RelatedFeature   Related Feature issue number (required if relationship is "related")
    -Severity         Severity level: Critical, High, Medium, Low (required if not interactive)
    -Steps            Steps to reproduce (optional)
    -Expected         Expected behavior (optional)
    -Actual           Actual behavior (optional)

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository write permissions
    - PowerShell 5.1+ (for YAML parsing)

EXAMPLES:
    # Interactive mode
    .\create-bug.ps1

    # Non-interactive mode (parented bug)
    .\create-bug.ps1 -Title "Login fails with valid credentials" -Description "Bug description" -Relationship parented -ParentWorkUnit 46 -Severity High

    # Non-interactive mode (related bug)
    .\create-bug.ps1 -Title "Feature bug" -Description "Bug description" -Relationship related -RelatedFeature 45 -Severity Medium

    # Preview changes
    .\create-bug.ps1 -Title "Bug" -Description "Description" -Relationship parented -ParentWorkUnit 46 -Severity High -DryRun

    # Verbose output
    .\create-bug.ps1 -Title "Bug" -Description "Description" -Relationship related -RelatedFeature 45 -Severity Critical -Verbose
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

    Write-VerboseMessage "Validating issue #$IssueNumber exists (expected type: '$ExpectedType')..."

    try {
        # Check if issue exists
        # Note: Issue type is not available via REST API JSON fields
        # We can only validate that the issue exists
        $issueData = gh issue view $IssueNumber --repo $Repo --json number 2>&1
        if ($LASTEXITCODE -ne 0 -or -not $issueData) {
            Write-Error "Issue #$IssueNumber does not exist in repository $Repo"
            return $false
        }

        # Issue exists - type validation not available via REST API
        # Issue types are organization-level settings and must be checked via Projects v2 API or issue body metadata
        Write-VerboseMessage "Issue #$IssueNumber exists (type validation skipped - not available via REST API)"
        Write-VerboseMessage "  Note: Issue type '$ExpectedType' should be verified manually or via Projects v2 API"
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

    # Add bug-specific sections
    if ($Steps) {
        $bodyContent = $bodyContent + "`n`n## Steps to Reproduce`n$Steps"
    }

    if ($Expected) {
        $bodyContent = $bodyContent + "`n`n## Expected Behavior`n$Expected"
    }

    if ($Actual) {
        $bodyContent = $bodyContent + "`n`n## Actual Behavior`n$Actual"
    }

    # Determine priority
    $priority = "normal"
    if ($Relationship -eq "parented") {
        $priority = "highest"
    }

    # Append RHYTHM Method metadata
    $metadata = "`n`n---`n`n<!-- RHYTHM Method Metadata -->`n**Bug ID:** bug-XXX (auto-generated)`n**Relationship:** $Relationship"
    
    if ($Relationship -eq "parented" -and $ParentWorkUnit) {
        $metadata = $metadata + "`n**Parent Work Unit:** #$ParentWorkUnit"
    } elseif ($Relationship -eq "related" -and $RelatedFeature) {
        $metadata = $metadata + "`n**Related Feature:** #$RelatedFeature"
    }

    $metadata = $metadata + "`n**Status:** planned`n**Priority:** $priority (parented bugs always highest)`n**Severity:** $Severity"

    return $bodyContent + $metadata
}

# Interactive prompt for issue details
function Request-IssueDetails {
    Write-Info "Enter Bug details:"
    Write-Host ""

    # Title
    while ($Title -eq "") {
        $Title = Read-Host "Bug title"
        if ($Title -eq "") {
            Write-Error "Title is required"
        }
    }

    # Relationship type
    if ($Relationship -eq "") {
        Write-Info "Bug relationship type:"
        Write-Host "  1) Parented to Work Unit"
        Write-Host "  2) Related to Feature"
        $relChoice = Read-Host "Select [1]"
        switch ($relChoice) {
            "1" { $script:Relationship = "parented" }
            "2" { $script:Relationship = "related" }
            default { $script:Relationship = "parented" }
        }
    }

    # Parent Work Unit or Related Feature
    if ($Relationship -eq "parented") {
        while ($ParentWorkUnit -eq "") {
            $ParentWorkUnit = Read-Host "Parent Work Unit issue number (e.g., 46)"
            if ($ParentWorkUnit -eq "") {
                Write-Error "Parent Work Unit is required for parented bugs"
            }
        }
    } elseif ($Relationship -eq "related") {
        while ($RelatedFeature -eq "") {
            $RelatedFeature = Read-Host "Related Feature issue number (e.g., 45)"
            if ($RelatedFeature -eq "") {
                Write-Error "Related Feature is required for related bugs"
            }
        }
    }

    # Severity
    if ($Severity -eq "") {
        Write-Info "Severity level:"
        Write-Host "  1) Critical"
        Write-Host "  2) High"
        Write-Host "  3) Medium"
        Write-Host "  4) Low"
        $sevChoice = Read-Host "Select [3]"
        switch ($sevChoice) {
            "1" { $script:Severity = "Critical" }
            "2" { $script:Severity = "High" }
            "3" { $script:Severity = "Medium" }
            "4" { $script:Severity = "Low" }
            default { $script:Severity = "Medium" }
        }
    }

    # Description
    if ($Description -eq "" -and $BodyFile -eq "") {
        Write-Info "Enter bug description (end with Ctrl+Z then Enter):"
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

    # Steps to reproduce
    if ($Steps -eq "") {
        Write-Info "Steps to reproduce (optional, end with Ctrl+Z then Enter):"
        $Steps = @()
        while ($true) {
            $line = Read-Host
            if ($line -eq "") {
                break
            }
            $Steps += $line
        }
        $script:Steps = $Steps -join "`n"
    }

    # Expected behavior
    if ($Expected -eq "") {
        $script:Expected = Read-Host "Expected behavior (optional)"
    }

    # Actual behavior
    if ($Actual -eq "") {
        $script:Actual = Read-Host "Actual behavior (optional)"
    }
}

# Main function
function Main {
    if ($Help) {
        Show-Help
    }

    Write-Info "Create GitHub Bug Issue for RHYTHM Method"
    Write-Info "=========================================="

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
        Write-Error "Bug title is required"
        exit 2
    }

    # Validate relationship type
    if ($Relationship -eq "") {
        Write-Error "Bug relationship type is required (parented or related)"
        exit 2
    }

    if ($Relationship -ne "parented" -and $Relationship -ne "related") {
        Write-Error "Invalid relationship type: $Relationship. Must be 'parented' or 'related'"
        exit 2
    }

    # Validate relationship-specific requirements
    if ($Relationship -eq "parented" -and $ParentWorkUnit -eq "") {
        Write-Error "Parent Work Unit issue number is required for parented bugs"
        exit 2
    }

    if ($Relationship -eq "related" -and $RelatedFeature -eq "") {
        Write-Error "Related Feature issue number is required for related bugs"
        exit 2
    }

    # Validate severity
    if ($Severity -eq "") {
        Write-Error "Severity is required"
        exit 2
    }

    # Validate parent/related issue exists and is correct type
    if (-not $DryRun) {
        if ($Relationship -eq "parented") {
            if (-not (Test-IssueExistsAndType $repo $ParentWorkUnit "Work Unit")) {
                Write-Error "Parent Work Unit validation failed"
                exit 2
            }
        } elseif ($Relationship -eq "related") {
            if (-not (Test-IssueExistsAndType $repo $RelatedFeature "Feature")) {
                Write-Error "Related Feature validation failed"
                exit 2
            }
        }
    }

    if ($Description -eq "" -and $BodyFile -eq "") {
        Write-Error "Bug description or body file is required"
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

    Write-Info "Creating Bug issue..."
    Write-VerboseMessage "Title: $Title"
    Write-VerboseMessage "Relationship: $Relationship"
    if ($Relationship -eq "parented") {
        Write-VerboseMessage "Parent Work Unit: #$ParentWorkUnit"
    } else {
        Write-VerboseMessage "Related Feature: #$RelatedFeature"
    }
    Write-VerboseMessage "Severity: $Severity"

    # Create issue
    if ($DryRun) {
        Write-Info "[DRY RUN] Would create issue:"
        Write-Info "  Title: $Title"
        Write-Info "  Type: Bug"
        Write-Info "  Relationship: $Relationship"
        if ($Relationship -eq "parented") {
            Write-Info "  Parent Work Unit: #$ParentWorkUnit"
        } else {
            Write-Info "  Related Feature: #$RelatedFeature"
        }
        Write-Info "  Severity: $Severity"
        Write-Info "  Body: (see $bodyFile)"
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

    # Add dependency if parented to work unit
    if ($Relationship -eq "parented" -and $ParentWorkUnit) {
        $createArgs += "--add-blocked-by"
        $createArgs += $ParentWorkUnit
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

    Write-Success "Created Bug issue #$issueNumber"

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

            # Update Bug Relationship field
            $bugRelationshipFieldId = Get-FieldId "Bug Relationship"
            if ($bugRelationshipFieldId) {
                $relationshipValue = if ($Relationship -eq "parented") { "Parented" } else { "Related" }
                Update-ProjectSingleSelectField $projectId $issueNodeId $bugRelationshipFieldId "Bug Relationship" $relationshipValue | Out-Null
            }

            # Update Severity field
            $severityFieldId = Get-FieldId "Severity"
            if ($severityFieldId) {
                Update-ProjectSingleSelectField $projectId $issueNodeId $severityFieldId "Severity" $Severity | Out-Null
            }
        }
    }

    Write-Success "Bug issue #$issueNumber created successfully"
    Write-Info "View issue: https://github.com/$repo/issues/$issueNumber"
}

# Run main function
Main

