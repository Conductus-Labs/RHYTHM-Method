# Setup GitHub Issue Types for RHYTHM Method
# 
# This script creates GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
# at the organization level using GitHub CLI.
#
# Usage:
#   .\setup-issue-types.ps1 [-DryRun] [-Verbose] [-Help]
#
# Options:
#   -DryRun    Preview changes without applying them
#   -Verbose   Show detailed output
#   -Help      Show this help message
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Organization admin permissions
#   - PowerShell 5.1+ (for ConvertFrom-Yaml or yq)
#
# Features:
#   - API rate limiting with exponential backoff (handles 429 errors)
#   - Idempotent operations (safe to run multiple times)
#   - Progress indicators for multiple issue types
#
# Exit codes:
#   0 = Success
#   1 = Error
#   2 = Validation failure

[CmdletBinding()]
param(
    [switch]$DryRun,
    [switch]$Help
)

# Script directory and paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$TemplateDir = Join-Path $ScriptDir "..\templates"
$ConfigTemplate = Join-Path $TemplateDir "github-config.yml.template"
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
    if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent -or $VerbosePreference -eq "Continue") {
        Write-Host "[VERBOSE] $Message" -ForegroundColor DarkBlue
    }
}

# Show help message
function Show-Help {
    $helpText = @"
Setup GitHub Issue Types for RHYTHM Method

This script creates GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
at the organization level using GitHub CLI.

USAGE:
    .\setup-issue-types.ps1 [OPTIONS]

OPTIONS:
    -DryRun    Preview changes without applying them
    -Verbose   Show detailed output
    -Help      Show this help message

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Organization admin permissions
    - PowerShell 5.1+ (for YAML parsing)

EXAMPLES:
    # Interactive setup
    .\setup-issue-types.ps1

    # Preview changes
    .\setup-issue-types.ps1 -DryRun

    # Verbose output
    .\setup-issue-types.ps1 -Verbose

EXIT CODES:
    0 = Success
    1 = Error
    2 = Validation failure

For more information, see: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/managing-issue-types-in-an-organization
"@
    Write-Host $helpText
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
    } else {
        $ghVersion = (gh --version | Select-Object -First 1)
        Write-VerboseMessage "GitHub CLI found: $ghVersion"
    }

    # Check authentication
    try {
        $null = gh auth status 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "Not authenticated"
        }
        Write-VerboseMessage "GitHub CLI is authenticated"
    } catch {
        Write-Error "GitHub CLI is not authenticated"
        Write-Info "Run: gh auth login"
        $errors++
    }

    # Check for YAML parser (yq or PowerShell YAML module)
    $hasYq = Test-Command "yq"
    $hasYamlModule = $null -ne (Get-Module -ListAvailable -Name powershell-yaml)

    if (-not $hasYq -and -not $hasYamlModule) {
        Write-Warning "YAML parser not found (yq or powershell-yaml module)"
        Write-Info "Install yq from: https://github.com/mikefarah/yq"
        Write-Info "Or install PowerShell module: Install-Module -Name powershell-yaml"
        Write-Info "Script will attempt to use basic YAML parsing"
    } else {
        if ($hasYq) {
            $yqVersion = (yq --version 2>&1 | Select-Object -First 1)
            Write-VerboseMessage "yq found: $yqVersion"
        } else {
            Write-VerboseMessage "powershell-yaml module found"
        }
    }

    if ($errors -gt 0) {
        Write-Error "Prerequisites validation failed"
        exit 2
    }

    Write-Success "All prerequisites validated"
}

# Parse YAML file (simple parser for basic YAML structure)
function Read-YamlConfig {
    param([string]$FilePath)

    if (Test-Command "yq") {
        # Use yq if available
        $yamlContent = yq eval '.' $FilePath 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $yamlContent | ConvertFrom-Json
        }
    }

    # Fallback: Simple YAML parsing for our specific structure
    $content = Get-Content $FilePath -Raw
    $config = @{}

    # Parse organization
    if ($content -match 'organization:\s*(.+?)(?:\s*#|$)') {
        $org = $matches[1].Trim().Trim('"').Trim("'")
        if ($org -ne "null") {
            $config.organization = $org
        }
    }

    # Parse issue types
    $issueTypes = @()
    $issueTypePattern = '(?s)- name:\s*"([^"]+)"\s+description:\s*"([^"]+)"\s+color:\s*"([^"]+)"'
    $matches = [regex]::Matches($content, $issueTypePattern)
    
    foreach ($match in $matches) {
        $issueTypes += @{
            name = $match.Groups[1].Value
            description = $match.Groups[2].Value
            color = $match.Groups[3].Value
        }
    }

    $config.issue_types = $issueTypes
    return $config
}

# Ensure config file exists (copy from template if needed)
function Ensure-ConfigFile {
    Write-Info "Ensuring configuration file exists..."

    if (-not (Test-Path $ConfigFile)) {
        Write-Info "Configuration file not found, copying from template..."

        if (-not (Test-Path $ConfigTemplate)) {
            Write-Error "Template file not found: $ConfigTemplate"
            exit 1
        }

        # Create .baton directory if it doesn't exist
        $batonDir = Split-Path -Parent $ConfigFile
        if (-not (Test-Path $batonDir)) {
            New-Item -ItemType Directory -Path $batonDir -Force | Out-Null
        }

        # Copy template
        Copy-Item $ConfigTemplate $ConfigFile
        Write-Success "Configuration file created from template"
    } else {
        Write-VerboseMessage "Configuration file already exists"
    }
}

# Auto-detect organization from current repository
function Get-AutoDetectedOrganization {
    Write-Info "Auto-detecting organization from current repository..."

    try {
        $org = gh repo view --json owner --jq '.owner.login' 2>&1
        if ($LASTEXITCODE -eq 0 -and $org) {
            Write-VerboseMessage "Auto-detected organization: $org"
            return $org.Trim()
        }
    } catch {
        Write-VerboseMessage "Could not auto-detect organization: $_"
    }

    return $null
}

# Get organization from config or prompt user
function Get-Organization {
    $org = $null

    # Try to read from config file
    if (Test-Path $ConfigFile) {
        try {
            $config = Read-YamlConfig $ConfigFile
            if ($config.organization -and $config.organization -ne "null") {
                $org = $config.organization
                Write-VerboseMessage "Organization from config: $org"
            }
        } catch {
            Write-VerboseMessage "Could not read organization from config: $_"
        }
    }

    # Try auto-detection
    if (-not $org) {
        $autoOrg = Get-AutoDetectedOrganization
        if ($autoOrg) {
            Write-Info "Auto-detected organization: $autoOrg"
            $confirm = Read-Host "Use this organization? [Y/n]"
            if ($confirm -match '^[Yy]|^$') {
                $org = $autoOrg
            }
        }
    }

    # Prompt user if still not set
    if (-not $org) {
        $org = Read-Host "Enter GitHub organization name"
        if (-not $org) {
            Write-Error "Organization name is required"
            exit 2
        }
    }

    # Update config file (if yq is available)
    if (Test-Command "yq" -and (Test-Path $ConfigFile)) {
        try {
            yq eval ".github.organization = `"$org`"" -i $ConfigFile 2>&1 | Out-Null
        } catch {
            Write-VerboseMessage "Could not update config file with organization"
        }
    }

    return $org
}

# Check if user has org admin permissions
function Test-OrgPermissions {
    param([string]$Org)

    Write-Info "Checking organization admin permissions..."

    try {
        $hasAdmin = gh api "orgs/$Org" --jq '.permissions.admin // false' 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "API call failed"
        }

        if ($hasAdmin -ne "true") {
            Write-Error "You do not have organization admin permissions for: $Org"
            Write-Info "Issue Types can only be created by organization owners/admins"
            Write-Info "Please request org admin access or have an org admin run this script"
            exit 2
        }

        Write-Success "Organization admin permissions verified"
    } catch {
        Write-Error "Failed to check permissions: $_"
        exit 2
    }
}

# List existing issue types
function Get-ExistingIssueTypes {
    param([string]$Org)

    Write-VerboseMessage "Checking existing issue types..."

    try {
        $response = gh api "orgs/$Org/issue-types" --jq '.[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $types = $response | Where-Object { $_ -ne "" }
            if ($types) {
                Write-VerboseMessage "Existing issue types:"
                $types | ForEach-Object { Write-VerboseMessage "  - $_" }
                return @($types)
            } else {
                Write-VerboseMessage "No existing issue types found"
                return @()
            }
        } else {
            Write-Warning "Could not list existing issue types (will attempt to create anyway): $response"
            return @()
        }
    } catch {
        Write-Warning "Could not list existing issue types (will attempt to create anyway): $_"
        return @()
    }
}

# Check if issue type exists
function Test-IssueTypeExists {
    param(
        [string]$TypeName,
        [array]$ExistingTypes
    )

    # Handle empty array gracefully
    if (-not $ExistingTypes -or $ExistingTypes.Count -eq 0) {
        return $false
    }

    # Case-insensitive comparison
    return ($ExistingTypes | Where-Object { $_ -eq $TypeName }) -ne $null
}

# Convert hex color to color name
function Convert-HexToColorName {
    param([string]$HexColor)

    switch ($HexColor.ToUpper()) {
        "#1F77B4" { return "blue" }
        "#2CA02C" { return "green" }
        "#FF7F0E" { return "orange" }
        "#D62728" { return "red" }
        default { return $HexColor }
    }
}

# Create issue type
function New-IssueType {
    param(
        [string]$Org,
        [string]$Name,
        [string]$Description,
        [string]$Color
    )

    Write-Info "Creating issue type: $Name"

    $apiColor = Convert-HexToColorName $Color

    Write-VerboseMessage "  Name: $Name"
    Write-VerboseMessage "  Description: $Description"
    Write-VerboseMessage "  Color: $Color (API: $apiColor)"

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create issue type: $Name"
        return $true
    }

    # Create issue type via GitHub API with rate limiting retry logic
    $maxRetries = 3
    $retryDelay = 1
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        try {
            $response = gh api `
                --method POST `
                -H "Accept: application/vnd.github+json" `
                "orgs/$Org/issue-types" `
                -f "name=$Name" `
                -f "description=$Description" `
                -f "is_enabled=true" `
                -f "color=$apiColor" `
                2>&1

            if ($LASTEXITCODE -eq 0) {
                Write-Success "Created issue type: $Name"
                return $true
            }

            # Check for rate limit error (429) or rate limit message
            if ($response -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit, waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2  # Exponential backoff
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $false
                }
            }

            # Check for already exists error (not a failure case)
            if ($response -match "already exists|duplicate") {
                Write-Warning "Issue type '$Name' already exists (skipping)"
                return $true
            }

            # Other errors - don't retry
            Write-Error "Failed to create issue type '$Name': $response"
            return $false
        } catch {
            # Only retry on rate limit errors
            if ($_.Exception.Message -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit, waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2  # Exponential backoff
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $false
                }
            }
            Write-Error "Failed to create issue type '$Name': $_"
            return $false
        }
    }

    Write-Error "Failed to create issue type '$Name' after $maxRetries attempts"
    return $false
}

# Main function
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Info "GitHub Issue Types Setup for RHYTHM Method"
    Write-Info "=========================================="

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    # Validate prerequisites
    Test-Prerequisites

    # Ensure config file exists
    Ensure-ConfigFile

    # Get organization
    $org = Get-Organization
    Write-Info "Using organization: $org"

    # Check permissions
    Test-OrgPermissions $org

    # Read issue types from config
    Write-Info "Reading issue types from configuration..."

    if (-not (Test-Path $ConfigFile)) {
        Write-Error "Configuration file not found: $ConfigFile"
        exit 1
    }

    $config = Read-YamlConfig $ConfigFile

    if (-not $config.issue_types -or $config.issue_types.Count -eq 0) {
        Write-Error "No issue types found in configuration file"
        exit 1
    }

    Write-Info "Found $($config.issue_types.Count) issue type(s) to create"

    # Get existing issue types
    $existingTypes = Get-ExistingIssueTypes $org

    # Process each issue type
    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    $currentIndex = 0

    foreach ($issueType in $config.issue_types) {
        $currentIndex++
        Write-Info "Processing $currentIndex/$($config.issue_types.Count):"
        $name = $issueType.name
        $description = $issueType.description
        $color = $issueType.color

        if (-not $name) {
            Write-Warning "Skipping issue type (missing name)"
            $errorCount++
            continue
        }

        # Check if already exists
        if (Test-IssueTypeExists $name $existingTypes) {
            Write-Warning "Issue type '$name' already exists (skipping)"
            $skipCount++
            continue
        }

        # Create issue type
        if (New-IssueType $org $name $description $color) {
            $successCount++
        } else {
            $errorCount++
        }
    }

    # Summary
    Write-Host ""
    Write-Info "Summary:"
    Write-Info "  Created: $successCount"
    Write-Info "  Skipped: $skipCount"
    if ($errorCount -gt 0) {
        Write-Error "  Errors: $errorCount"
        exit 1
    }

    if ($DryRun) {
        Write-Warning "DRY RUN - No changes were made"
    } else {
        Write-Success "Issue types setup completed successfully!"
    }
}

# Run main function
try {
    Main
    exit 0
} catch {
    Write-Error "Script failed: $_"
    exit 1
}

