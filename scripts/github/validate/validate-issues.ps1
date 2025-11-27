# Validate Issues Script for RHYTHM Method
# 
# This script validates GitHub Issues setup: verifies issue types exist, Projects v2 custom fields
# exist, issue structure matches RHYTHM Method requirements, checks for orphaned issues, and
# validates dependency graph consistency.
#
# Usage:
#   .\validate-issues.ps1 [-Verbose] [-Help] [-Issue ISSUE_NUMBER] [-All] [-Repo REPO]
#
# Options:
#   -Verbose        Show detailed output
#   -Help           Show this help message
#   -Issue          Issue number to validate (optional - validates all if not specified)
#   -All            Validate all issues in the repository
#   -Repo           Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - PowerShell 5.1+ (for YAML parsing)
#   - yq or jq for JSON parsing
#
# Features:
#   - Verifies all required issue types exist
#   - Verifies Projects v2 custom fields exist with correct options
#   - Validates issue structure and metadata format
#   - Checks for orphaned issues (missing parent references)
#   - Validates dependency graph (no circular dependencies)
#   - Checks native dependencies match issue body metadata
#   - Generates detailed validation report
#
# Exit codes:
#   0 = All valid
#   1 = Errors found
#   2 = Validation failure (prerequisites not met)
#
# Report Format:
#   The script generates a validation report showing:
#   - Summary of checks performed
#   - List of errors found
#   - List of warnings
#   - Recommendations for fixes

[CmdletBinding()]
param(
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
$ProjectConfigFile = Join-Path $RepoRoot ".baton\project.config.yml"

# Set error action preference
$ErrorActionPreference = "Stop"

# Validation results
$script:ErrorCount = 0
$script:WarningCount = 0
$script:IssueTypeErrors = @()
$script:CustomFieldErrors = @()
$script:MetadataErrors = @()
$script:OrphanErrors = @()
$script:DependencyErrors = @()
$script:CircularDepErrors = @()

# Required issue types
$RequiredIssueTypes = @("Feature", "Work Unit", "Agent Task", "Bug")

# Required custom fields (from Work-Unit-01 spec)
$RequiredFields = @(
    "Status:single_select:Planned,In Progress,Review,Blocked,Completed,Failed",
    "TEMPO:single_select:High,Moderate,Controlled",
    "Assigned Agent:single_select:",
    "Estimated Tokens:number:",
    "Actual Tokens:number:",
    "Bug Relationship:single_select:Parented,Related",
    "Severity:single_select:Critical,High,Medium,Low"
)

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
    $script:WarningCount++
}

function Write-Error {
    param([string]$Message)
    Write-Host "✗ $Message" -ForegroundColor Red
    $script:ErrorCount++
}

function Write-VerboseMessage {
    param([string]$Message)
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose") -or $VerbosePreference -eq "Continue") {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkBlue
    }
}

# Show help message
function Show-Help {
    Write-Host @"
Validate Issues Script for RHYTHM Method

This script validates GitHub Issues setup: verifies issue types exist, Projects v2 custom fields
exist, issue structure matches RHYTHM Method requirements, checks for orphaned issues, and
validates dependency graph consistency.

USAGE:
    .\validate-issues.ps1 [OPTIONS] [-Issue ISSUE_NUMBER] [-All]

OPTIONS:
    -Verbose        Show detailed output
    -Help           Show this help message
    -Issue          Issue number to validate (optional - validates all if not specified)
    -All            Validate all issues in the repository
    -Repo           Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Validate all issues
    .\validate-issues.ps1 -All

    # Validate a single issue
    .\validate-issues.ps1 -Issue 45

    # Verbose output
    .\validate-issues.ps1 -All -Verbose

VALIDATION CHECKS:
    - Issue types: Verifies all 4 required types exist
    - Custom fields: Verifies all 7 required fields exist with correct options
    - Issue metadata: Validates RHYTHM Method metadata format
    - Parent-child relationships: Checks parent issues exist and are correct type
    - Dependencies: Validates native dependencies match issue body metadata
    - Dependency graph: Checks for circular dependencies
    - Projects v2: Verifies issues are linked to project

EXIT CODES:
    0 = All valid
    1 = Errors found
    2 = Validation failure (prerequisites not met)

"@
}

# Check prerequisites
function Test-Prerequisites {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed"
        Write-Info "Install from: https://cli.github.com/"
        exit 2
    }

    $null = gh auth status 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI is not authenticated"
        Write-Info "Run: gh auth login"
        exit 2
    }

    if (-not (Test-Command "yq") -and -not (Test-Command "jq")) {
        Write-Error "YAML/JSON parser (yq or jq) is not installed"
        Write-Info "Install from: https://github.com/mikefarah/yq or https://stedolan.github.io/jq/"
        exit 2
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

# Get organization from repository
function Get-Organization {
    param([string]$Repo)
    return ($Repo -split '/')[0]
}

# Validate issue types
function Test-IssueTypes {
    param([string]$Org)

    Write-Info "Validating issue types..."

    try {
        $existingTypes = gh api "orgs/$Org/issue-types" --jq '.[].name' 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Could not retrieve issue types from organization"
            $script:IssueTypeErrors += "Could not query issue types API"
            return $false
        }

        $typesArray = @($existingTypes -split "`n" | Where-Object { $_ -ne "" })
        $missingTypes = @()

        foreach ($requiredType in $RequiredIssueTypes) {
            if ($typesArray -contains $requiredType) {
                Write-Success "Issue type exists: $requiredType"
                Write-VerboseMessage "  ✓ $requiredType"
            } else {
                $missingTypes += $requiredType
                Write-Error "Missing issue type: $requiredType"
                $script:IssueTypeErrors += "Missing issue type: $requiredType"
            }
        }

        if ($missingTypes.Count -eq 0) {
            Write-Success "All required issue types exist"
            return $true
        } else {
            Write-Error "Missing $($missingTypes.Count) issue type(s)"
            return $false
        }
    } catch {
        Write-Error "Failed to validate issue types: $_"
        $script:IssueTypeErrors += "Error validating issue types: $_"
        return $false
    }
}

# Get project ID
function Get-ProjectId {
    if (-not (Test-Path $FieldIdsFile)) {
        return $null
    }

    if (Test-Command "yq") {
        $projectId = yq eval '.project.id // ""' $FieldIdsFile 2>&1
        if ($LASTEXITCODE -eq 0 -and $projectId -and $projectId -ne "null") {
            return $projectId.Trim()
        }
    }

    return $null
}

# Validate Projects v2 custom fields
function Test-CustomFields {
    param([string]$ProjectId)

    Write-Info "Validating Projects v2 custom fields..."

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
                                ... on ProjectV2Field {
                                    id
                                    name
                                    dataType
                                }
                            }
                        }
                    }
                }
            }
        " 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Error "Could not query project fields"
            $script:CustomFieldErrors += "Could not query Projects v2 fields API"
            return $false
        }

        # Parse fields from response
        $fieldNames = @()
        if (Test-Command "jq") {
            $fieldNames = @($response | jq -r '.data.node.fields.nodes[] | "\(.name):\(.dataType)"' 2>&1 | Where-Object { $_ -ne "" })
        } elseif (Test-Command "yq") {
            $fieldNames = @($response | yq eval '.data.node.fields.nodes[] | "\(.name):\(.dataType)"' - 2>&1 | Where-Object { $_ -ne "" })
        }

        Write-VerboseMessage "Found fields: $($fieldNames -join ', ')"

        # Validate each required field
        $missingFields = @()
        foreach ($fieldSpec in $RequiredFields) {
            $parts = $fieldSpec -split ':'
            $fieldName = $parts[0]
            $fieldType = $parts[1]
            $expectedOptions = if ($parts.Count -gt 2) { $parts[2] } else { "" }

            # Check if field exists
            $fieldExists = $fieldNames | Where-Object { $_ -like "$fieldName:*" } | Measure-Object | Select-Object -ExpandProperty Count

            if ($fieldExists -eq 0) {
                Write-Error "Missing custom field: $fieldName"
                $script:CustomFieldErrors += "Missing field: $fieldName (type: $fieldType)"
                $missingFields += $fieldName
            } else {
                Write-Success "Custom field exists: $fieldName"
                Write-VerboseMessage "  ✓ $fieldName ($fieldType)"

                # Validate options for single-select fields
                if ($fieldType -eq "single_select" -and $expectedOptions) {
                    Test-FieldOptions $response $fieldName $expectedOptions
                }
            }
        }

        if ($missingFields.Count -eq 0) {
            Write-Success "All required custom fields exist"
            return $true
        } else {
            Write-Error "Missing $($missingFields.Count) custom field(s)"
            return $false
        }
    } catch {
        Write-Error "Failed to validate custom fields: $_"
        $script:CustomFieldErrors += "Error validating custom fields: $_"
        return $false
    }
}

# Validate field options
function Test-FieldOptions {
    param(
        [string]$Response,
        [string]$FieldName,
        [string]$ExpectedOptions
    )

    Write-VerboseMessage "  Validating options for $FieldName..."

    # Extract options for this field
    $fieldOptions = @()
    if (Test-Command "jq") {
        $fieldOptions = @($Response | jq -r ".data.node.fields.nodes[] | select(.name == `"$FieldName`") | .options[]?.name // empty" 2>&1 | Where-Object { $_ -ne "" })
    } elseif (Test-Command "yq") {
        $fieldOptions = @($Response | yq eval ".data.node.fields.nodes[] | select(.name == `"$FieldName`") | .options[]?.name // empty" - 2>&1 | Where-Object { $_ -ne "" })
    }

    # Check each expected option
    $expectedArray = $ExpectedOptions -split ','
    foreach ($expectedOpt in $expectedArray) {
        $expectedOpt = $expectedOpt.Trim()
        if ($fieldOptions -notcontains $expectedOpt) {
            Write-Warning "Missing option '$expectedOpt' in field '$FieldName'"
            $script:CustomFieldErrors += "Field '$FieldName' missing option: $expectedOpt"
        }
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

    return $null
}

# Get issue details
function Get-IssueDetails {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    try {
        $details = gh issue view $IssueNumber --repo $Repo --json number,type,state,title,blockedBy,blocking 2>&1
        if ($LASTEXITCODE -eq 0 -and $details -and $details -ne "null") {
            return $details
        }
    } catch {
        # Ignore
    }

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
    return $value
}

# Validate issue metadata
function Test-IssueMetadata {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$IssueType
    )

    Write-VerboseMessage "Validating metadata for issue #$IssueNumber (type: $IssueType)..."

    # Get issue body
    $body = Get-IssueBody $Repo $IssueNumber
    if (-not $body) {
        Write-Warning "Issue #$IssueNumber has no body"
        $script:MetadataErrors += "Issue #$IssueNumber: Missing issue body"
        return $false
    }

    # Check for metadata section
    if ($body -notmatch "<!-- RHYTHM Method Metadata -->") {
        Write-Warning "Issue #$IssueNumber missing RHYTHM Method metadata section"
        $script:MetadataErrors += "Issue #$IssueNumber: Missing metadata section"
        return $false
    }

    # Validate required fields based on issue type
    $hasErrors = $false

    switch ($IssueType) {
        "Feature" {
            if (-not (Get-MetadataField $body "Feature ID")) {
                Write-Warning "Issue #$IssueNumber missing Feature ID in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Feature ID"
                $hasErrors = $true
            }
            if (-not (Get-MetadataField $body "Status")) {
                Write-Warning "Issue #$IssueNumber missing Status in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Status"
                $hasErrors = $true
            }
        }
        "Work Unit" {
            if (-not (Get-MetadataField $body "Work Unit ID")) {
                Write-Warning "Issue #$IssueNumber missing Work Unit ID in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Work Unit ID"
                $hasErrors = $true
            }
            if (-not (Get-MetadataField $body "Parent Feature")) {
                Write-Warning "Issue #$IssueNumber missing Parent Feature in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Parent Feature"
                $hasErrors = $true
            }
        }
        "Agent Task" {
            if (-not (Get-MetadataField $body "Task ID")) {
                Write-Warning "Issue #$IssueNumber missing Task ID in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Task ID"
                $hasErrors = $true
            }
            if (-not (Get-MetadataField $body "Parent Work Unit")) {
                Write-Warning "Issue #$IssueNumber missing Parent Work Unit in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Parent Work Unit"
                $hasErrors = $true
            }
            if (-not (Get-MetadataField $body "Assigned Agent")) {
                Write-Warning "Issue #$IssueNumber missing Assigned Agent in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Assigned Agent"
                $hasErrors = $true
            }
        }
        "Bug" {
            if (-not (Get-MetadataField $body "Bug ID")) {
                Write-Warning "Issue #$IssueNumber missing Bug ID in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Bug ID"
                $hasErrors = $true
            }
            if (-not (Get-MetadataField $body "Relationship")) {
                Write-Warning "Issue #$IssueNumber missing Relationship in metadata"
                $script:MetadataErrors += "Issue #$IssueNumber: Missing Relationship"
                $hasErrors = $true
            }
        }
    }

    if ($hasErrors) {
        return $false
    }

    Write-VerboseMessage "  ✓ Metadata valid for issue #$IssueNumber"
    return $true
}

# Validate parent-child relationships
function Test-ParentRelationships {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$IssueType,
        [string]$Body
    )

    Write-VerboseMessage "Validating parent relationships for issue #$IssueNumber..."

    $parentField = ""
    $expectedParentType = ""

    switch ($IssueType) {
        "Work Unit" {
            $parentField = "Parent Feature"
            $expectedParentType = "Feature"
        }
        "Agent Task" {
            $parentField = "Parent Work Unit"
            $expectedParentType = "Work Unit"
        }
        "Bug" {
            # Bugs can have either Parent Work Unit or Related Feature
            $relationship = Get-MetadataField $Body "Relationship"
            if ($relationship -eq "parented") {
                $parentField = "Parent Work Unit"
                $expectedParentType = "Work Unit"
            } elseif ($relationship -eq "related") {
                $parentField = "Related Feature"
                $expectedParentType = "Feature"
            } else {
                # No parent validation needed if relationship is not parented/related
                return $true
            }
        }
        default {
            # Features don't have parents
            return $true
        }
    }

    if (-not $parentField) {
        return $true
    }

    # Get parent issue number
    $parentRef = Get-MetadataField $Body $parentField
    if (-not $parentRef) {
        Write-Warning "Issue #$IssueNumber missing $parentField"
        $script:OrphanErrors += "Issue #$IssueNumber: Missing $parentField"
        return $false
    }

    # Extract issue number (format: #123)
    $parentMatch = [regex]::Match($parentRef, '#(\d+)')
    if (-not $parentMatch.Success) {
        Write-Warning "Issue #$IssueNumber has invalid $parentField format: $parentRef"
        $script:OrphanErrors += "Issue #$IssueNumber: Invalid $parentField format: $parentRef"
        return $false
    }

    $parentNumber = $parentMatch.Groups[1].Value

    # Check if parent exists
    $parentDetails = Get-IssueDetails $Repo $parentNumber
    if (-not $parentDetails) {
        Write-Warning "Issue #$IssueNumber references non-existent parent: #$parentNumber"
        $script:OrphanErrors += "Issue #$IssueNumber: Parent issue #$parentNumber does not exist"
        return $false
    }

    # Check parent type
    $parentType = ""
    if (Test-Command "jq") {
        $parentType = $parentDetails | jq -r '.type // ""' 2>&1
    } elseif (Test-Command "yq") {
        $parentType = $parentDetails | yq eval '.type // ""' - 2>&1
    }

    if ($parentType -ne $expectedParentType) {
        Write-Warning "Issue #$IssueNumber parent #$parentNumber is type '$parentType', expected '$expectedParentType'"
        $script:OrphanErrors += "Issue #$IssueNumber: Parent #$parentNumber is wrong type ($parentType, expected $expectedParentType)"
        return $false
    }

    Write-VerboseMessage "  ✓ Parent relationship valid for issue #$IssueNumber"
    return $true
}

# Get dependencies from metadata
function Get-DependenciesFromMetadata {
    param([string]$Body)

    $dependenciesLine = $Body | Select-String -Pattern "^\*\*Dependencies:" -CaseSensitive:$false
    if (-not $dependenciesLine) {
        return @()
    }

    # Extract issue numbers (format: #123, #456, etc.)
    $matches = [regex]::Matches($dependenciesLine.Line, '#(\d+)')
    $issueNumbers = $matches | ForEach-Object { $_.Groups[1].Value }

    return $issueNumbers
}

# Get native blocked-by dependencies
function Get-NativeBlockedBy {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    try {
        $blockedBy = gh issue view $IssueNumber --repo $Repo --json blockedBy --jq '.blockedBy[].number // empty' 2>&1
        if ($LASTEXITCODE -eq 0 -and $blockedBy) {
            return @($blockedBy -split "`n" | Where-Object { $_ -ne "" })
        }
    } catch {
        # Ignore
    }

    return @()
}

# Validate dependencies match
function Test-DependenciesMatch {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$Body
    )

    Write-VerboseMessage "Validating dependencies for issue #$IssueNumber..."

    # Get dependencies from metadata
    $metadataDeps = Get-DependenciesFromMetadata $Body

    # Get native dependencies
    $nativeDeps = Get-NativeBlockedBy $Repo $IssueNumber

    # Check for mismatches
    $hasMismatch = $false

    # Check metadata deps exist in native
    foreach ($dep in $metadataDeps) {
        if ($nativeDeps -notcontains $dep) {
            Write-Warning "Issue #$IssueNumber: Dependency #$dep in metadata but not in native dependencies"
            $script:DependencyErrors += "Issue #$IssueNumber: Missing native dependency #$dep"
            $hasMismatch = $true
        }
    }

    # Check native deps exist in metadata (less critical, but good to know)
    foreach ($native in $nativeDeps) {
        if ($metadataDeps -notcontains $native) {
            Write-VerboseMessage "Issue #$IssueNumber: Native dependency #$native not in metadata (acceptable)"
        }
    }

    if ($hasMismatch) {
        return $false
    }

    Write-VerboseMessage "  ✓ Dependencies match for issue #$IssueNumber"
    return $true
}

# Check for circular dependencies (simple DFS)
function Test-CircularDependencies {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    $visited = @{}
    $path = @()

    # Recursive function to check cycles
    function Test-Cycle {
        param(
            [string]$Current,
            [array]$CurrentPath
        )

        # Check if current is in path (cycle detected)
        if ($CurrentPath -contains $Current) {
            # Found cycle
            $cyclePath = "$($CurrentPath -join ' -> ') -> $Current"
            Write-Error "Circular dependency detected: $cyclePath"
            $script:CircularDepErrors += "Circular dependency: $cyclePath"
            return $false
        }

        # Add to path
        $newPath = $CurrentPath + @($Current)

        # Get dependencies
        $deps = Get-NativeBlockedBy $Repo $Current

        # Check each dependency
        foreach ($dep in $deps) {
            if (-not (Test-Cycle $dep $newPath)) {
                return $false
            }
        }

        return $true
    }

    if (-not (Test-Cycle $IssueNumber @())) {
        return $false
    }

    return $true
}

# Validate a single issue
function Test-SingleIssue {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    Write-Info "Validating issue #$IssueNumber..."

    # Get issue details
    $issueDetails = Get-IssueDetails $Repo $IssueNumber
    if (-not $issueDetails) {
        Write-Error "Issue #$IssueNumber not found or not accessible"
        return $false
    }

    # Extract issue type
    $issueType = ""
    if (Test-Command "jq") {
        $issueType = $issueDetails | jq -r '.type // ""' 2>&1
    } elseif (Test-Command "yq") {
        $issueType = $issueDetails | yq eval '.type // ""' - 2>&1
    }

    if (-not $issueType) {
        Write-Warning "Issue #$IssueNumber has no issue type"
        $script:MetadataErrors += "Issue #$IssueNumber: Missing issue type"
    }

    # Get issue body
    $body = Get-IssueBody $Repo $IssueNumber
    if (-not $body) {
        Write-Warning "Issue #$IssueNumber has no body"
        $script:MetadataErrors += "Issue #$IssueNumber: Missing issue body"
    } else {
        # Validate metadata
        if ($issueType) {
            Test-IssueMetadata $Repo $IssueNumber $issueType | Out-Null
        }

        # Validate parent relationships
        if ($issueType) {
            Test-ParentRelationships $Repo $IssueNumber $issueType $body | Out-Null
        }

        # Validate dependencies match
        Test-DependenciesMatch $Repo $IssueNumber $body | Out-Null
    }

    # Check for circular dependencies
    Test-CircularDependencies $Repo $IssueNumber | Out-Null

    return $true
}

# Get all issues in repository
function Get-AllIssues {
    param([string]$Repo)

    Write-VerboseMessage "Fetching all issues from repository..."

    try {
        $issues = gh issue list --repo $Repo --json number --jq '.[].number' 2>&1
        if ($LASTEXITCODE -eq 0 -and $issues) {
            return @($issues -split "`n" | Where-Object { $_ -ne "" })
        }
    } catch {
        # Ignore
    }

    Write-Warning "No issues found in repository"
    return @()
}

# Generate validation report
function Write-ValidationReport {
    Write-Info ""
    Write-Info "=========================================="
    Write-Info "Validation Report"
    Write-Info "=========================================="
    Write-Info ""

    Write-Info "Summary:"
    Write-Info "  Errors:   $script:ErrorCount"
    Write-Info "  Warnings: $script:WarningCount"
    Write-Info ""

    if ($script:IssueTypeErrors.Count -gt 0) {
        Write-Info "Issue Type Errors:"
        foreach ($error in $script:IssueTypeErrors) {
            Write-Error "  $error"
        }
        Write-Info ""
    }

    if ($script:CustomFieldErrors.Count -gt 0) {
        Write-Info "Custom Field Errors:"
        foreach ($error in $script:CustomFieldErrors) {
            Write-Error "  $error"
        }
        Write-Info ""
    }

    if ($script:MetadataErrors.Count -gt 0) {
        Write-Info "Metadata Errors:"
        foreach ($error in $script:MetadataErrors) {
            Write-Warning "  $error"
        }
        Write-Info ""
    }

    if ($script:OrphanErrors.Count -gt 0) {
        Write-Info "Orphaned Issues:"
        foreach ($error in $script:OrphanErrors) {
            Write-Warning "  $error"
        }
        Write-Info ""
    }

    if ($script:DependencyErrors.Count -gt 0) {
        Write-Info "Dependency Mismatches:"
        foreach ($error in $script:DependencyErrors) {
            Write-Warning "  $error"
        }
        Write-Info ""
    }

    if ($script:CircularDepErrors.Count -gt 0) {
        Write-Info "Circular Dependencies:"
        foreach ($error in $script:CircularDepErrors) {
            Write-Error "  $error"
        }
        Write-Info ""
    }

    if ($script:ErrorCount -eq 0 -and $script:WarningCount -eq 0) {
        Write-Success "All validations passed!"
        return $true
    } elseif ($script:ErrorCount -eq 0) {
        Write-Warning "Validation completed with $script:WarningCount warning(s)"
        return $true
    } else {
        Write-Error "Validation failed with $script:ErrorCount error(s) and $script:WarningCount warning(s)"
        return $false
    }
}

# Main function
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Info "Validate Issues Script for RHYTHM Method"
    Write-Info "========================================"

    Test-Prerequisites

    # Get repository
    $repo = Get-Repository
    if (-not $repo) {
        exit 2
    }
    Write-Info "Using repository: $repo"

    # Get organization
    $org = Get-Organization $repo
    Write-Info "Using organization: $org"

    # Validate issue types
    Test-IssueTypes $org | Out-Null

    # Get project ID
    $projectId = Get-ProjectId
    if ($projectId) {
        Write-Info "Validating Projects v2 custom fields..."
        Test-CustomFields $projectId | Out-Null
    } else {
        Write-Warning "Project not configured, skipping custom fields validation"
        $script:CustomFieldErrors += "Project not configured (field IDs file not found)"
    }

    # Validate issues
    if ($All -or -not $Issue) {
        Write-Info "Validating all issues..."
        
        $allIssues = Get-AllIssues $repo
        if ($allIssues.Count -eq 0) {
            Write-Error "Failed to get list of issues"
            exit 1
        }

        foreach ($issueNum in $allIssues) {
            Test-SingleIssue $repo $issueNum | Out-Null
        }
    } elseif ($Issue) {
        Test-SingleIssue $repo $Issue | Out-Null
    } else {
        Write-Info "No issues specified. Validating setup only (issue types and custom fields)."
    }

    # Generate report
    if (Write-ValidationReport) {
        exit 0
    } else {
        exit 1
    }
}

# Run main function
Main

