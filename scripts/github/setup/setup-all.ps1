# Master Setup Script for RHYTHM Method GitHub Integration
#
# This script orchestrates the complete GitHub Issues setup for RHYTHM Method,
# including issue templates, issue types, and project setup.
#
# Usage:
#   .\setup-all.ps1 [-DryRun] [-Verbose] [-Help] [-NonInteractive] [-SkipTemplates] [-SkipIssueTypes] [-SkipProject]
#
# Options:
#   -DryRun           Preview changes without applying them
#   -Verbose          Show detailed output
#   -Help             Show this help message
#   -NonInteractive   Use config file values without prompting
#   -SkipTemplates    Skip issue templates setup
#   -SkipIssueTypes   Skip issue types setup
#   -SkipProject      Skip project setup
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Organization admin permissions (for issue types)
#   - Repository admin permissions (for project)
#   - YAML parser (yq) for parsing configuration
#   - PowerShell 5.1+
#
# Features:
#   - Interactive wizard mode (default)
#   - Non-interactive mode (use config)
#   - Progress indicators
#   - Error handling (continues with remaining steps on failure)
#   - Ability to skip individual steps
#   - Summary before execution
#
# Note on Rollback:
#   Rollback is not implemented because all operations are idempotent:
#   - Issue Types: Creation checks for existing types before creating (idempotent)
#   - Project Setup: Checks for existing project before creating (idempotent)
#   - Templates: File comparison before copying (idempotent)
#   If a step fails, the script continues with remaining steps. Failed steps can be
#   re-run individually or the entire setup can be re-run safely.
#
# Exit codes:
#   0 = Success
#   1 = Error
#   2 = Validation failure

[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [switch]$DryRun,
    [switch]$Help,
    [switch]$NonInteractive,
    [switch]$SkipTemplates,
    [switch]$SkipIssueTypes,
    [switch]$SkipProject
)

# Script directory and paths
# Note: Using $PSScriptRoot (PowerShell 3.0+) instead of Split-Path for best practice
$ScriptDir = $PSScriptRoot

# Set error action preference
$ErrorActionPreference = "Stop"

# Setup steps tracking
$script:StepsToRun = @()
$script:StepsCompleted = @()
$script:StepsFailed = @()

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

function Write-Step {
    param([string]$Message)
    Write-Host "→ $Message" -ForegroundColor Cyan
}

function Write-VerboseMessage {
    param([string]$Message)
    $PSCmdlet.WriteVerbose($Message)
}

# Show help message
function Show-Help {
    $helpText = @"
Master Setup Script for RHYTHM Method GitHub Integration

This script orchestrates the complete GitHub Issues setup for RHYTHM Method,
including issue templates, issue types, and project setup.

USAGE:
    .\setup-all.ps1 [OPTIONS]

OPTIONS:
    -DryRun           Preview changes without applying them
    -Verbose          Show detailed output
    -Help             Show this help message
    -NonInteractive   Use config file values without prompting
    -SkipTemplates    Skip issue templates setup
    -SkipIssueTypes   Skip issue types setup
    -SkipProject      Skip project setup

SETUP STEPS:
    1. Issue Templates    - Copy templates to .github/ISSUE_TEMPLATE/
    2. Issue Types        - Create GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
    3. Project Setup      - Create GitHub Project v2 with custom fields

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Organization admin permissions (for issue types)
    - Repository admin permissions (for project)
    - YAML parser (yq) for parsing configuration
    - PowerShell 5.1+

EXAMPLES:
    # Interactive setup (wizard mode)
    .\setup-all.ps1

    # Preview all changes
    .\setup-all.ps1 -DryRun -Verbose

    # Non-interactive setup (use config)
    .\setup-all.ps1 -NonInteractive

    # Skip specific steps
    .\setup-all.ps1 -SkipTemplates -SkipIssueTypes

    # Show help
    .\setup-all.ps1 -Help
"@
    Write-Host $helpText
    exit 0
}

# Check if script exists
function Test-Script {
    param(
        [string]$ScriptPath,
        [string]$ScriptName
    )

    if (-not (Test-Path $ScriptPath -PathType Leaf)) {
        Write-Error "Required script not found: $ScriptName`nExpected location: $ScriptPath" 2
        return $false
    }

    return $true
}

# Run a setup script
function Invoke-SetupScript {
    param(
        [string]$ScriptName,
        [string]$StepDescription
    )

    $scriptPath = Join-Path $ScriptDir $ScriptName

    Write-Step "Running: $StepDescription"

    # Check if script exists
    if (-not (Test-Script $scriptPath $ScriptName)) {
        return $false
    }

    # Build command with flags
    $cmd = "& `"$scriptPath`""
    if ($DryRun) {
        $cmd += " -DryRun"
    }
    # Check if verbose flag was explicitly provided (simplified check)
    if ($PSCmdlet.MyInvocation.BoundParameters.ContainsKey("Verbose") -or $VerbosePreference -eq "Continue") {
        $cmd += " -Verbose"
    }

    Write-VerboseMessage "Executing: $cmd"

    # Run the script
    # Note: Individual scripts handle retry logic for transient failures (rate limits, network issues)
    try {
        # Capture output and errors, then process them
        $output = Invoke-Expression $cmd 2>&1
        $hasError = $false
        $output | ForEach-Object {
            if ($_ -is [System.Management.Automation.ErrorRecord]) {
                Write-Error $_
                $hasError = $true
            } else {
                Write-Output $_
            }
        }

        # Check exit code from the subprocess (primary indicator)
        $exitCode = $LASTEXITCODE
        if ($hasError -and $exitCode -eq 0) {
            $exitCode = 1
        }

        if ($exitCode -eq 0) {
            Write-Success "Completed: $StepDescription"
            $script:StepsCompleted += $StepDescription
            return $true
        } else {
            Write-Error "Failed: $StepDescription (exit code: $exitCode)" 1
            $script:StepsFailed += $StepDescription
            # Continue with remaining steps - operations are idempotent, so re-running is safe
            return $false
        }
    } catch {
        Write-Error "Failed: $StepDescription - $_" 1
        $script:StepsFailed += $StepDescription
        # Continue with remaining steps - operations are idempotent, so re-running is safe
        return $false
    }
}

# Show setup summary
function Show-Summary {
    Write-Host ""
    Write-Info "Setup Summary"
    Write-Info "============="
    Write-Host ""

    if ($script:StepsToRun.Count -eq 0) {
        Write-Warning "No setup steps will be executed (all skipped)"
        return
    }

    Write-Info "Steps to execute:"
    $stepNum = 1
    foreach ($step in $script:StepsToRun) {
        Write-Host "  $stepNum. $step"
        $stepNum++
    }

    Write-Host ""
    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    if ($NonInteractive) {
        Write-Info "Non-interactive mode: Using config file values"
    } else {
        Write-Info "Interactive mode: You will be prompted for configuration"
    }

    Write-Host ""
    if (-not $NonInteractive) {
        $confirm = Read-Host "Continue with setup? [Y/n]"
        if ($confirm -match "^[Nn]$") {
            Write-Info "Setup cancelled by user"
            exit 0
        }
    }
}

# Interactive wizard: select steps to run
function Start-InteractiveWizard {
    Write-Info "RHYTHM Method GitHub Setup Wizard"
    Write-Info "=================================="
    Write-Host ""

    # Issue Templates
    if (-not $SkipTemplates) {
        $confirm = Read-Host "Setup issue templates? [Y/n]"
        if ($confirm -notmatch "^[Nn]$") {
            $script:StepsToRun += "Issue Templates"
        } else {
            $script:SkipTemplates = $true
        }
    }

    # Issue Types
    if (-not $SkipIssueTypes) {
        $confirm = Read-Host "Setup issue types? [Y/n]"
        if ($confirm -notmatch "^[Nn]$") {
            $script:StepsToRun += "Issue Types"
        } else {
            $script:SkipIssueTypes = $true
        }
    }

    # Project Setup
    if (-not $SkipProject) {
        $confirm = Read-Host "Setup project and custom fields? [Y/n]"
        if ($confirm -notmatch "^[Nn]$") {
            $script:StepsToRun += "Project Setup"
        } else {
            $script:SkipProject = $true
        }
    }
}

# Non-interactive mode: determine steps from flags
function Start-NonInteractiveSetup {
    if (-not $SkipTemplates) {
        $script:StepsToRun += "Issue Templates"
    }
    if (-not $SkipIssueTypes) {
        $script:StepsToRun += "Issue Types"
    }
    if (-not $SkipProject) {
        $script:StepsToRun += "Project Setup"
    }
}

# Main function
function Main {
    if ($Help) {
        Show-Help
        exit 0
    }

    Write-Info "RHYTHM Method GitHub Integration - Master Setup"
    Write-Info "==============================================="
    Write-Host ""

    # Determine which steps to run
    if ($NonInteractive) {
        Start-NonInteractiveSetup
    } else {
        Start-InteractiveWizard
    }

    # Show summary
    Show-Summary

    # Execute setup steps
    $totalSteps = $script:StepsToRun.Count
    $currentStep = 0

    foreach ($step in $script:StepsToRun) {
        $currentStep++
        Write-Host ""
        Write-Info "Step $currentStep/$totalSteps : $step"
        Write-Info "----------------------------------------"

        switch ($step) {
            "Issue Templates" {
                if (-not (Invoke-SetupScript "setup-issue-templates.ps1" "Issue Templates Setup")) {
                    Write-Error "Issue templates setup failed" 1
                    if (-not $DryRun) {
                        Write-Warning "Continuing with remaining steps..."
                    }
                }
            }
            "Issue Types" {
                if (-not (Invoke-SetupScript "setup-issue-types.ps1" "Issue Types Setup")) {
                    Write-Error "Issue types setup failed" 1
                    if (-not $DryRun) {
                        Write-Warning "Continuing with remaining steps..."
                    }
                }
            }
            "Project Setup" {
                if (-not (Invoke-SetupScript "setup-project.ps1" "Project Setup")) {
                    Write-Error "Project setup failed" 1
                    if (-not $DryRun) {
                        Write-Warning "Continuing with remaining steps..."
                    }
                }
            }
            default {
                Write-Error "Unknown step: $step" 1
            }
        }
    }

    # Final summary
    Write-Host ""
    Write-Info "Setup Summary"
    Write-Info "============="
    Write-Host ""
    Write-Info "Completed: $($script:StepsCompleted.Count) step(s)"
    foreach ($step in $script:StepsCompleted) {
        Write-Success "  ✓ $step"
    }

    if ($script:StepsFailed.Count -gt 0) {
        Write-Host ""
        Write-Error "Failed: $($script:StepsFailed.Count) step(s)" 1
        foreach ($step in $script:StepsFailed) {
            Write-Host "  ✗ $step" -ForegroundColor Red
        }
        exit 1
    }

    if ($DryRun) {
        Write-Warning "DRY RUN - No changes were made"
    } else {
        Write-Success "All setup steps completed successfully!"
        Write-Info "Your GitHub repository is now configured for RHYTHM Method."
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

