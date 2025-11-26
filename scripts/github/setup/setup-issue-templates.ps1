# Setup GitHub Issue Templates for RHYTHM Method
#
# This script copies GitHub Issue Form templates from scripts/github/templates/issue-templates/
# to .github/ISSUE_TEMPLATE/ in the repository.
#
# Usage:
#   .\setup-issue-templates.ps1 [-DryRun] [-Verbose] [-Help]
#
# Options:
#   -DryRun    Preview changes without applying them
#   -Verbose   Show detailed output
#   -Help      Show this help message
#
# Requirements:
#   - PowerShell 5.1+ (for file operations)
#
# Features:
#   - Idempotent operations (safe to run multiple times)
#   - Creates .github/ISSUE_TEMPLATE/ directory if it doesn't exist
#   - Preserves existing templates (backup option)
#   - Progress indicators
#
# Exit codes:
#   0 = Success
#   1 = Error
#   2 = Validation failure

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$DryRun,
    [switch]$Help
)

# Script directory and paths
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Resolve-Path (Join-Path $ScriptDir "..\..\..")
$TemplateDir = Join-Path $ScriptDir "..\templates\issue-templates"
$TargetDir = Join-Path $RepoRoot ".github\ISSUE_TEMPLATE"

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
    $PSCmdlet.WriteWarning($Message)
}

function Write-Error {
    param([string]$Message, [int]$ExitCode = 1)
    $PSCmdlet.WriteError((New-Object System.Management.Automation.ErrorRecord((New-Object System.Exception($Message)), "ScriptError", "NotSpecified", $null)))
    exit $ExitCode
}

function Write-VerboseMessage {
    param([string]$Message)
    $PSCmdlet.WriteVerbose($Message)
}

# Show help message
function Show-Help {
    $helpText = @"
Setup GitHub Issue Templates for RHYTHM Method

This script copies GitHub Issue Form templates from the templates directory
to .github/ISSUE_TEMPLATE/ in the repository.

USAGE:
    .\setup-issue-templates.ps1 [OPTIONS]

OPTIONS:
    -DryRun    Preview changes without applying them
    -Verbose   Show detailed output
    -Help      Show this help message

REQUIREMENTS:
    - PowerShell 5.1+ (for file operations)

EXAMPLES:
    .\setup-issue-templates.ps1
    .\setup-issue-templates.ps1 -DryRun -Verbose
    .\setup-issue-templates.ps1 -Help
"@
    Write-Host $helpText
    exit 0
}

# Validate prerequisites
function Test-Prerequisites {
    Write-Info "Validating prerequisites..."

    # Check if template directory exists
    if (-not (Test-Path $TemplateDir -PathType Container)) {
        Write-Error "Template directory not found: $TemplateDir" 2
    }
    Write-VerboseMessage "Template directory found: $TemplateDir"

    # Check if template directory has any YAML files
    $templates = Get-ChildItem -Path $TemplateDir -Filter "*.yml" -File -ErrorAction SilentlyContinue
    
    if (-not $templates -or $templates.Count -eq 0) {
        Write-Error "No template files found in: $TemplateDir" 2
    }
    Write-VerboseMessage "Found $($templates.Count) template file(s)"

    Write-Success "Prerequisites validated."
}

# Copy template files
function Copy-Templates {
    Write-Info "Copying issue templates to $TargetDir..."

    # Create target directory if it doesn't exist
    if (-not (Test-Path $TargetDir -PathType Container)) {
        if ($PSCmdlet.ShouldProcess($TargetDir, "Create directory")) {
            New-Item -Path $TargetDir -ItemType Directory -Force | Out-Null
            Write-Success "Created directory: $TargetDir"
        } else {
            Write-Info "[DRY RUN] Would create directory: $TargetDir"
        }
    } else {
        Write-VerboseMessage "Target directory already exists: $TargetDir"
    }

    # Get all YAML files in template directory
    $templates = Get-ChildItem -Path $TemplateDir -Filter "*.yml" -File | Sort-Object Name

    if (-not $templates -or $templates.Count -eq 0) {
        Write-Error "No template files found in: $TemplateDir"
        return $false
    }

    Write-Info "Found $($templates.Count) template(s) to copy"

    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    $currentIndex = 0

    foreach ($template in $templates) {
        $currentIndex++
        $templateName = $template.Name
        $targetFile = Join-Path $TargetDir $templateName

        Write-Info "Processing $currentIndex/$($templates.Count): $templateName"

        # Check if target file already exists
        if (Test-Path $targetFile -PathType Leaf) {
            Write-Warning "Template already exists: $targetFile"
            
            # Compare files to see if they're different
            $sourceHash = Get-FileHash $template.FullName -Algorithm SHA256
            $targetHash = Get-FileHash $targetFile -Algorithm SHA256

            if ($sourceHash.Hash -eq $targetHash.Hash) {
                Write-VerboseMessage "  Files are identical (skipping)"
                $skipCount++
                continue
            } else {
                Write-Warning "  Files differ - will overwrite"
            }
        }

        if ($PSCmdlet.ShouldProcess($targetFile, "Copy template")) {
            try {
                Copy-Item -Path $template.FullName -Destination $targetFile -Force
                Write-Success "Copied: $templateName"
                $successCount++
            } catch {
                Write-Error "Failed to copy: $templateName - $_"
                $errorCount++
            }
        } else {
            Write-Info "[DRY RUN] Would copy: $($template.FullName) -> $targetFile"
            $successCount++
        }
    }

    # Summary
    Write-Host ""
    Write-Info "Summary:"
    Write-Info "  Copied: $successCount"
    Write-Info "  Skipped: $skipCount"
    if ($errorCount -gt 0) {
        Write-Error "  Errors: $errorCount"
        return $false
    }

    return $true
}

# Main function
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Info "GitHub Issue Templates Setup for RHYTHM Method"
    Write-Info "=============================================="

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    # Validate prerequisites
    Test-Prerequisites

    # Copy templates
    if (Copy-Templates) {
        if ($DryRun) {
            Write-Warning "DRY RUN - No changes were made"
        } else {
            Write-Success "Issue templates setup completed successfully!"
            Write-Info "Templates are now available at: $TargetDir"
        }
        exit 0
    } else {
        Write-Error "Failed to copy some templates"
        exit 1
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

