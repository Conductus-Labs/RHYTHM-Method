# Sync Dependencies Script for RHYTHM Method
# 
# This script reads issue body metadata and syncs dependencies to native GitHub Issue Dependencies.
# It parses the "Dependencies:" field from the RHYTHM Method metadata section and creates
# "blocked by" relationships using GitHub CLI.
#
# Usage:
#   .\sync-dependencies.ps1 [-DryRun] [-Verbose] [-Help] [-Issue ISSUE_NUMBER] [-All] [-Repo REPO]
#
# Options:
#   -DryRun         Preview changes without applying them
#   -Verbose        Show detailed output
#   -Help           Show this help message
#   -Issue          Issue number to sync (required if not -All)
#   -All            Sync all issues in the repository
#   -Repo           Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - PowerShell 5.1+ (for YAML parsing)
#
# Features:
#   - Parses "Dependencies:" from issue body metadata
#   - Creates native GitHub Issue Dependencies (blocked by relationships)
#   - Idempotent (safe to run multiple times)
#   - Handles existing dependencies gracefully
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
Sync Dependencies Script for RHYTHM Method

This script reads issue body metadata and syncs dependencies to native GitHub Issue Dependencies.
It parses the "Dependencies:" field from the RHYTHM Method metadata section and creates
"blocked by" relationships using GitHub CLI.

USAGE:
    .\sync-dependencies.ps1 [OPTIONS] [-Issue ISSUE_NUMBER] [-All]

OPTIONS:
    -DryRun         Preview changes without applying them
    -Verbose        Show detailed output
    -Help           Show this help message
    -Issue          Issue number to sync (required if not -All)
    -All            Sync all issues in the repository
    -Repo           Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Sync dependencies for a single issue
    .\sync-dependencies.ps1 -Issue 45

    # Sync dependencies for all issues
    .\sync-dependencies.ps1 -All

    # Preview changes (dry-run)
    .\sync-dependencies.ps1 -Issue 45 -DryRun

    # Verbose output
    .\sync-dependencies.ps1 -Issue 45 -Verbose

"@
}

# Check prerequisites
function Test-Prerequisites {
    if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
        Write-Error "GitHub CLI (gh) is not installed"
        Write-Info "Install from: https://cli.github.com/"
        exit 1
    }

    $null = gh auth status 2>&1
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

# Parse dependencies from issue body metadata
function Get-DependenciesFromMetadata {
    param([string]$Body)

    # Extract the RHYTHM Method metadata section
    $metadataStart = $Body.IndexOf("<!-- RHYTHM Method Metadata -->")
    if ($metadataStart -eq -1) {
        Write-VerboseMessage "No RHYTHM Method metadata section found"
        return @()
    }

    $metadataEnd = $Body.IndexOf("<!-- /RHYTHM Method Metadata -->", $metadataStart)
    if ($metadataEnd -eq -1) {
        $metadataEnd = $Body.Length
    }

    $metadataSection = $Body.Substring($metadataStart, $metadataEnd - $metadataStart)

    # Extract Dependencies line
    $dependenciesLine = $metadataSection | Select-String -Pattern "^\*\*Dependencies:" -CaseSensitive:$false
    if (-not $dependenciesLine) {
        Write-VerboseMessage "No Dependencies field found in metadata"
        return @()
    }

    # Extract issue numbers (format: #123, #456, etc.)
    $depMatches = [regex]::Matches($dependenciesLine.Line, '#(\d+)')
    if ($depMatches.Count -eq 0) {
        Write-VerboseMessage "No issue numbers found in Dependencies field"
        return @()
    }

    $issueNumbers = $depMatches | ForEach-Object { $_.Groups[1].Value }
    return $issueNumbers
}

# Get existing blocked-by dependencies
function Get-ExistingBlockedBy {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    try {
        $blockedBy = gh issue view $IssueNumber --repo $Repo --json blockedBy --jq '.blockedBy[].number // empty' 2>&1
        if ($LASTEXITCODE -eq 0 -and $blockedBy) {
            return ($blockedBy -split "`n" | Where-Object { $_ -ne "" })
        }
    } catch {
        # Ignore
    }

    return @()
}

# Set issue dependency (blocked by) using GitHub REST API
# Note: This endpoint may return 404 if not available for the repository/organization
function Set-IssueDependency {
    param(
        [string]$Repo,
        [string]$IssueNumber,
        [string]$BlockedByIssue
    )

    Write-VerboseMessage "Setting dependency: issue #$IssueNumber blocked by #$BlockedByIssue..."

    # Parse owner and repo name
    $owner = ($Repo -split "/")[0]
    $repoName = ($Repo -split "/")[1]

    # Get blocked-by issue ID (numeric ID, not issue number)
    $blockedByIssueId = gh api "repos/$owner/$repoName/issues/$BlockedByIssue" --jq '.id' 2>&1
    
    if ($LASTEXITCODE -ne 0 -or -not $blockedByIssueId -or $blockedByIssueId -eq "null") {
        Write-Warning "Could not get issue ID for blocked-by issue #$BlockedByIssue"
        return $false
    }

    # GitHub REST API: Add issue dependency (blocked by)
    # POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies
    # Body: { "blocked_by_issue_id": <integer> }
    # Note: blocked_by_issue_id must be the numeric ID, not the issue number
    # Documentation: https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2022-11-28
    # 
    # IMPORTANT: This endpoint may return 404 if:
    # 1. Issue dependencies feature is not enabled for the repository/organization
    # 2. The feature requires specific GitHub plan (Enterprise, etc.)
    # 3. The endpoint is not available in the current API version
    # 4. Fine-grained token doesn't have "Issues" write permission
    #
    # If the endpoint is not available, dependencies are stored in issue body metadata
    # and can be set manually via GitHub web UI
    $response = gh api --method POST -H "Accept: application/vnd.github+json" "repos/$owner/$repoName/issues/$IssueNumber/dependencies" -F "blocked_by_issue_id=$blockedByIssueId" 2>&1
    $exitCode = $LASTEXITCODE

    if ($exitCode -eq 0) {
        Write-Success "Set dependency: #$IssueNumber is now blocked by #$BlockedByIssue"
        return $true
    } else {
        # Check for 404 - endpoint may not be available
        if ($response -match "404|Not Found") {
            Write-Warning "Dependency API endpoint not available (404) for issue #$IssueNumber"
            Write-VerboseMessage "The GitHub REST API endpoint for dependencies is not available for this repository."
            Write-VerboseMessage "Dependencies are stored in issue body metadata and can be set manually via GitHub web UI."
            return $false
        # Check if dependency already exists or other expected errors
        } elseif ($response -match "already exists|duplicate|422") {
            Write-VerboseMessage "Dependency already exists: #$IssueNumber is already blocked by #$BlockedByIssue"
            return $true
        } else {
            Write-Warning "Could not set dependency: #$IssueNumber blocked by #$BlockedByIssue"
            Write-VerboseMessage "Error: $response"
            return $false
        }
    }
}

# Sync dependencies for a single issue
function Sync-IssueDependencies {
    param(
        [string]$Repo,
        [string]$IssueNumber
    )

    Write-Info "Syncing dependencies for issue #$IssueNumber..."

    # Get issue body
    $body = Get-IssueBody $Repo $IssueNumber
    if (-not $body) {
        Write-Warning "Skipping issue #$IssueNumber - cannot read body"
        return $false
    }

    # Parse dependencies from metadata
    $metadataDeps = Get-DependenciesFromMetadata $body
    if ($metadataDeps.Count -eq 0) {
        Write-VerboseMessage "Issue #$IssueNumber has no dependencies in metadata"
        return $true
    }

    Write-VerboseMessage "Found dependencies in metadata: $($metadataDeps -join ', ')"

    # Get existing dependencies
    $existingDeps = Get-ExistingBlockedBy $Repo $IssueNumber
    Write-VerboseMessage "Existing blocked-by dependencies: $(if ($existingDeps.Count -eq 0) { 'none' } else { $existingDeps -join ', ' })"

    # Find dependencies to add
    $addedCount = 0
    foreach ($dep in $metadataDeps) {
        if ($existingDeps -contains $dep) {
            Write-VerboseMessage "Dependency already exists: #$IssueNumber blocked by #$dep"
        } else {
            if ($DryRun) {
                Write-Info "[DRY RUN] Would add dependency: issue #$IssueNumber blocked by #$dep"
            } else {
                Write-VerboseMessage "Adding dependency: issue #$IssueNumber blocked by #$dep"
                
                # Validate dependency issue exists
                $null = gh issue view $dep --repo $Repo --json number 2>&1
                if ($LASTEXITCODE -eq 0) {
                    # Use REST API to set dependency (gh issue edit --add-blocked-by doesn't exist)
                    if (Set-IssueDependency -Repo $Repo -IssueNumber $IssueNumber -BlockedByIssue $dep) {
                        $addedCount++
                    } else {
                        # Dependency setting failed (likely 404 - API not available)
                        # Dependencies are still recorded in issue body metadata
                        Write-VerboseMessage "Dependency will remain in issue body metadata for manual processing"
                    }
                } else {
                    Write-Warning "Dependency issue #$dep does not exist, skipping"
                }
            }
        }
    }

    if ($DryRun) {
        Write-Info "[DRY RUN] Would add $($metadataDeps.Count) dependencies for issue #$IssueNumber"
    } elseif ($addedCount -gt 0) {
        Write-Success "Added $addedCount dependencies for issue #$IssueNumber"
    } else {
        Write-Info "All dependencies already synced for issue #$IssueNumber"
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

    Write-Info "Sync Dependencies Script for RHYTHM Method"
    Write-Info "==========================================="

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

    # Sync dependencies
    if ($All) {
        Write-Info "Syncing dependencies for all issues..."
        
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
            if (Sync-IssueDependencies $repo $issueNum) {
                $success++
            } else {
                $skipped++
            }
        }

        Write-Info "Sync complete: $success synced, $skipped skipped, $total total"
    } else {
        Sync-IssueDependencies $repo $Issue
    }

    Write-Success "Script completed."
}

# Run main function
Main

