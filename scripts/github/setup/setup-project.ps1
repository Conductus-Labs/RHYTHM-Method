# Setup GitHub Project v2 for RHYTHM Method
# 
# This script creates a GitHub Project v2 with all required custom fields
# (Status, TEMPO, Assigned Agent, Tokens, Bug Relationship, Severity)
# using GitHub CLI.
#
# Usage:
#   .\setup-project.ps1 [-DryRun] [-Verbose] [-Help]
#
# Options:
#   -DryRun    Preview changes without applying them
#   -Verbose   Show detailed output
#   -Help      Show this help message
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository admin permissions (required for Projects v2)
#   - PowerShell 5.1+ (for ConvertFrom-Yaml or yq)
#
# Features:
#   - API rate limiting with exponential backoff (handles 429 errors)
#   - Idempotent operations (safe to run multiple times)
#   - Progress indicators for multiple fields
#   - Dynamic Assigned Agent field population from project.config.yml
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
$TemplateDir = Join-Path $ScriptDir "..\templates"
$ConfigTemplate = Join-Path $TemplateDir "github-config.yml.template"
$ConfigFile = Join-Path $RepoRoot ".baton\github-config.yml"
$FieldIdsTemplate = Join-Path $TemplateDir "github-field-ids.yml.template"
$FieldIdsFile = Join-Path $RepoRoot ".baton\github-field-ids.yml"
$ProjectConfigFile = Join-Path $RepoRoot ".baton\project.config.yml"

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
    if ($ExitCode -ne 0) { exit $ExitCode }
}

function Write-VerboseMessage {
    param([string]$Message)
    $PSCmdlet.WriteVerbose($Message)
}

# Show help message
function Show-Help {
    $helpText = @"
Setup GitHub Project v2 for RHYTHM Method

This script creates a GitHub Project v2 with all required custom fields
(Status, TEMPO, Assigned Agent, Tokens, Bug Relationship, Severity)
using GitHub CLI.

USAGE:
    .\setup-project.ps1 [OPTIONS]

OPTIONS:
    -DryRun    Preview changes without applying them
    -Verbose   Show detailed output
    -Help      Show this help message

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository admin permissions (required for Projects v2)
    - PowerShell 5.1+ (for YAML parsing)

EXAMPLES:
    # Interactive setup
    .\setup-project.ps1

    # Preview changes
    .\setup-project.ps1 -DryRun

    # Verbose output
    .\setup-project.ps1 -Verbose

EXIT CODES:
    0 = Success
    1 = Error
    2 = Validation failure
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
        Write-Error "GitHub CLI (gh) is not installed" 2
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
        Write-Error "GitHub CLI is not authenticated" 2
        Write-Info "Run: gh auth login"
        $errors++
    }

    # Check for YAML parser
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
        Write-Error "Prerequisites validation failed" 2
    }

    Write-Success "Prerequisites validated"
}

# Parse YAML file
function Read-YamlConfig {
    param([string]$FilePath)

    if (Test-Command "yq") {
        $yamlContent = yq eval '.' $FilePath 2>&1
        if ($LASTEXITCODE -eq 0) {
            return $yamlContent | ConvertFrom-Json
        }
    }

    # Fallback: Simple YAML parsing
    $content = Get-Content $FilePath -Raw
    $config = @{}

    # Parse repository
    if ($content -match 'repository:\s*(.+?)(?:\s*#|$)') {
        $repo = $matches[1].Trim().Trim('"').Trim("'")
        if ($repo -ne "null") {
            $config.repository = $repo
        }
    }

    # Parse project name
    if ($content -match '(?s)project:\s+name:\s*(.+?)(?:\s*#|$)') {
        $name = $matches[1].Trim().Trim('"').Trim("'")
        if ($name -ne "null") {
            $config.project_name = $name
        }
    }

    # Parse project description
    if ($content -match '(?s)description:\s*(.+?)(?:\s*#|$)') {
        $desc = $matches[1].Trim().Trim('"').Trim("'")
        if ($desc -ne "null") {
            $config.project_description = $desc
        }
    }

    return $config
}

# Ensure config file exists
function Ensure-ConfigFile {
    Write-Info "Ensuring configuration file exists..."

    if (-not (Test-Path $ConfigFile)) {
        Write-Info "Configuration file not found, copying from template..."

        if (-not (Test-Path $ConfigTemplate)) {
            Write-Error "Template file not found: $ConfigTemplate" 2
        }

        $batonDir = Split-Path -Parent $ConfigFile
        if (-not (Test-Path $batonDir)) {
            New-Item -ItemType Directory -Path $batonDir -Force | Out-Null
        }

        Copy-Item $ConfigTemplate $ConfigFile
        Write-Success "Configuration file created from template"
    } else {
        Write-VerboseMessage "Configuration file already exists"
    }
}

# Ensure field IDs file exists
function Ensure-FieldIdsFile {
    Write-Info "Ensuring field IDs file exists..."

    if (-not (Test-Path $FieldIdsFile)) {
        Write-Info "Field IDs file not found, copying from template..."

        if (-not (Test-Path $FieldIdsTemplate)) {
            Write-Error "Field IDs template not found: $FieldIdsTemplate" 2
        }

        $batonDir = Split-Path -Parent $FieldIdsFile
        if (-not (Test-Path $batonDir)) {
            New-Item -ItemType Directory -Path $batonDir -Force | Out-Null
        }

        Copy-Item $FieldIdsTemplate $FieldIdsFile
        Write-Success "Field IDs file created from template"
    } else {
        Write-VerboseMessage "Field IDs file already exists"
    }
}

# Auto-detect repository
function Get-AutoDetectedRepository {
    Write-Info "Auto-detecting repository from current git repository..."

    try {
        $repo = gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>&1
        if ($LASTEXITCODE -eq 0 -and $repo) {
            Write-VerboseMessage "Auto-detected repository: $repo"
            return $repo.Trim()
        }
    } catch {
        Write-VerboseMessage "Could not auto-detect repository: $_"
    }

    return $null
}

# Validate repository format (org/repo)
function Test-RepositoryFormat {
    param([string]$Repo)

    if ($Repo -notmatch '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$') {
        Write-Error "Invalid repository format: $Repo" 0
        Write-Info "Repository must be in format: org/repo (e.g., Conductus-Labs/RHYTHM-Method)"
        return $false
    }

    return $true
}

# Get repository from config or prompt user
function Get-Repository {
    $repo = $null

    if (Test-Path $ConfigFile) {
        try {
            if (Test-Command "yq") {
                $repo = yq eval '.github.repository // ""' $ConfigFile 2>&1
                if ($LASTEXITCODE -eq 0 -and $repo -and $repo -ne "null") {
                    if (Test-RepositoryFormat $repo.Trim()) {
                        Write-VerboseMessage "Repository from config: $repo"
                        return $repo.Trim()
                    } else {
                        Write-Warning "Repository format in config is invalid, will prompt for new value"
                        $repo = $null
                    }
                }
            } else {
                $config = Read-YamlConfig $ConfigFile
                if ($config.repository) {
                    $repo = $config.repository
                    if (-not (Test-RepositoryFormat $repo)) {
                        Write-Warning "Repository format in config is invalid, will prompt for new value"
                        $repo = $null
                    }
                }
            }
        } catch {
            Write-VerboseMessage "Could not read repository from config: $_"
        }
    }

    # Try auto-detection
    if (-not $repo) {
        $autoRepo = Get-AutoDetectedRepository
        if ($autoRepo) {
            if (Test-RepositoryFormat $autoRepo) {
                Write-Info "Auto-detected repository: $autoRepo"
                $confirm = Read-Host "Use this repository? [Y/n]"
                if ($confirm -match '^[Yy]|^$') {
                    $repo = $autoRepo
                }
            } else {
                Write-Warning "Auto-detected repository format is invalid, will prompt for new value"
            }
        }
    }

    # Prompt user if still not set
    while (-not $repo) {
        $repo = Read-Host "Enter GitHub repository (format: org/repo)"
        if (-not $repo) {
            Write-Error "Repository name is required" 2
        } elseif (-not (Test-RepositoryFormat $repo)) {
            $repo = $null
            continue
        }
    }

    # Update config file
    if (Test-Command "yq" -and (Test-Path $ConfigFile)) {
        try {
            yq eval ".github.repository = `"$repo`"" -i $ConfigFile 2>&1 | Out-Null
        } catch {
            Write-VerboseMessage "Could not update config file with repository"
        }
    }

    return $repo
}

# Get project name
function Get-ProjectName {
    $projectName = $null

    if (Test-Path $ConfigFile) {
        try {
            if (Test-Command "yq") {
                $projectName = yq eval '.project.name // ""' $ConfigFile 2>&1
                if ($LASTEXITCODE -eq 0 -and $projectName -and $projectName -ne "null") {
                    Write-VerboseMessage "Project name from config: $projectName"
                    return $projectName.Trim()
                }
            } else {
                $config = Read-YamlConfig $ConfigFile
                if ($config.project_name) {
                    $projectName = $config.project_name
                }
            }
        } catch {
            Write-VerboseMessage "Could not read project name from config: $_"
        }
    }

    # Prompt user
    $projectName = Read-Host "Enter project name (e.g., 'RHYTHM Method Project')"
    if (-not $projectName) {
        Write-Error "Project name is required" 2
    }

    # Update config file
    if (Test-Command "yq" -and (Test-Path $ConfigFile)) {
        try {
            yq eval ".project.name = `"$projectName`"" -i $ConfigFile 2>&1 | Out-Null
        } catch {
            Write-VerboseMessage "Could not update config file with project name"
        }
    }

    return $projectName
}

# Get project description
function Get-ProjectDescription {
    $projectDescription = $null

    if (Test-Path $ConfigFile) {
        try {
            if (Test-Command "yq") {
                $projectDescription = yq eval '.project.description // ""' $ConfigFile 2>&1
                if ($LASTEXITCODE -eq 0 -and $projectDescription -and $projectDescription -ne "null") {
                    Write-VerboseMessage "Project description from config: $projectDescription"
                    return $projectDescription.Trim()
                }
            } else {
                $config = Read-YamlConfig $ConfigFile
                if ($config.project_description) {
                    $projectDescription = $config.project_description
                }
            }
        } catch {
            Write-VerboseMessage "Could not read project description from config: $_"
        }
    }

    # Prompt user
    $projectDescription = Read-Host "Enter project description (e.g., 'RHYTHM Method work item tracking and management')"
    if (-not $projectDescription) {
        $projectDescription = "RHYTHM Method work item tracking and management"
        Write-Info "Using default description: $projectDescription"
    }

    # Update config file
    if (Test-Command "yq" -and (Test-Path $ConfigFile)) {
        try {
            yq eval ".project.description = `"$projectDescription`"" -i $ConfigFile 2>&1 | Out-Null
        } catch {
            Write-VerboseMessage "Could not update config file with project description"
        }
    }

    return $projectDescription
}

# Check repo permissions
function Test-RepoPermissions {
    param([string]$Repo)

    Write-Info "Checking repository admin permissions..."

    try {
        $hasAdmin = gh api "repos/$Repo" --jq '.permissions.admin // false' 2>&1
        if ($LASTEXITCODE -ne 0) {
            throw "API call failed"
        }

        if ($hasAdmin -ne "true") {
            Write-Error "You do not have repository admin permissions for: $Repo" 2
            Write-Info "Projects v2 can only be created by repository admins"
            Write-Info "Please request repo admin access or have a repo admin run this script"
        }

        Write-Success "Repository admin permissions verified"
    } catch {
        Write-Error "Failed to check permissions: $_" 2
    }
}

# Check if project exists
function Test-ProjectExists {
    param(
        [string]$Repo,
        [string]$ProjectName
    )

    Write-VerboseMessage "Checking if project '$ProjectName' already exists..."

    try {
        $projects = gh api "repos/$Repo/projects" --jq '.[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $projectNames = $projects | Where-Object { $_ -ne "" }
            return $null -ne ($projectNames | Where-Object { $_ -eq $ProjectName })
        }
    } catch {
        Write-VerboseMessage "Could not check existing projects: $_"
    }

    return $false
}

# Get existing project ID
function Get-ProjectId {
    param(
        [string]$Repo,
        [string]$ProjectName
    )

    Write-VerboseMessage "Getting project ID for '$ProjectName'..."

    try {
        $projectId = gh api "repos/$Repo/projects" --jq ".[] | select(.name == `"$ProjectName`") | .id" 2>&1
        if ($LASTEXITCODE -eq 0 -and $projectId) {
            return $projectId.Trim()
        }
    } catch {
        Write-VerboseMessage "Could not get project ID: $_"
    }

    return $null
}

# Create GitHub Project v2
function New-Project {
    param(
        [string]$Repo,
        [string]$ProjectName,
        [string]$ProjectDescription,
        [string]$Visibility
    )

    Write-Info "Creating GitHub Project v2: $ProjectName"

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create project: $ProjectName"
        Write-Info "[DRY RUN]   Description: $ProjectDescription"
        Write-Info "[DRY RUN]   Visibility: $Visibility"
        Write-Info "[DRY RUN]   Repository: $Repo"
        return "dry-run-project-id"
    }

    # Check if project already exists
    if (Test-ProjectExists $Repo $ProjectName) {
        Write-Warning "Project '$ProjectName' already exists"
        $existingId = Get-ProjectId $Repo $ProjectName
        if ($existingId) {
            Write-Info "Using existing project ID: $existingId"
            return $existingId
        }
    }

    # Create project with rate limiting retry logic
    $maxRetries = 3
    $retryDelay = 1
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        try {
            # GitHub Projects v2 API - create project for repository
            # Note: Using repos/{repo}/projects endpoint automatically links project to repository
            # Reference: https://docs.github.com/en/rest/projects/projects#create-a-repository-project
            $response = gh api `
                --method POST `
                -H "Accept: application/vnd.github+json" `
                "repos/$Repo/projects" `
                -f "name=$ProjectName" `
                -f "body=$ProjectDescription" `
                -f "private=$Visibility" `
                2>&1

            if ($LASTEXITCODE -eq 0) {
                if (Test-Command "yq") {
                    $projectId = $response | yq eval '.id' - 2>&1
                } else {
                    $json = $response | ConvertFrom-Json
                    $projectId = $json.id
                }

                if ($projectId) {
                    Write-Success "Created project: $ProjectName (ID: $projectId)"
                    Write-VerboseMessage "Project automatically linked to repository: $Repo"
                    return $projectId.ToString()
                }
            }

            # Extract HTTP status code if available
            $httpStatus = $null
            if ($response -match 'HTTP (\d{3})') {
                $httpStatus = $matches[1]
            }

            # Check for rate limit
            if ($response -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit (HTTP $($httpStatus -or '429')), waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }

            # Other errors
            if ($httpStatus) {
                Write-Error "Failed to create project '$ProjectName' (HTTP $httpStatus): $response"
            } else {
                Write-Error "Failed to create project '$ProjectName': $response"
            }
            return $null
        } catch {
            if ($_.Exception.Message -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit, waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }
            Write-Error "Failed to create project '$ProjectName': $_"
            return $null
        }
    }

    Write-Error "Failed to create project '$ProjectName' after $maxRetries attempts"
    return $null
}

# Get agents from project.config.yml
function Get-AgentsFromConfig {
    Write-VerboseMessage "Reading agents from project.config.yml..."

    if (-not (Test-Path $ProjectConfigFile)) {
        Write-Error "Project config file not found: $ProjectConfigFile" 1
        Write-Info "Assigned Agent field requires .baton/project.config.yml with agents.enabled list"
        return $null
    }

    $agents = @()

    if (Test-Command "yq") {
        $agentNames = yq eval '.agents.enabled[].name' $ProjectConfigFile 2>&1
        if ($LASTEXITCODE -eq 0) {
            $agents = $agentNames | Where-Object { $_ -ne "" }
        }
    } else {
        # Fallback parsing
        $content = Get-Content $ProjectConfigFile -Raw
        $regexMatches = [regex]::Matches($content, '(?m)^\s*-\s*name:\s*(.+)$')
        foreach ($match in $regexMatches) {
            $agentName = $match.Groups[1].Value.Trim().Trim('"').Trim("'")
            if ($agentName) {
                $agents += $agentName
            }
        }
    }

    if ($agents.Count -lt 1) {
        Write-Error "At least 1 agent must be configured (found: $($agents.Count))" 1
        return $null
    }

    if ($agents.Count -gt 25) {
        Write-Error "Too many agents configured (found: $($agents.Count), max: 25)" 1
        Write-Info "GitHub Projects v2 single select fields have a limit of 25 options"
        return $null
    }

    Write-VerboseMessage "Found $($agents.Count) agent(s) in project.config.yml"
    return $agents
}

# Check if field exists
function Test-FieldExists {
    param(
        [string]$ProjectId,
        [string]$FieldName
    )

    Write-VerboseMessage "Checking if field '$FieldName' already exists..."

    try {
        $fields = gh api "projects/$ProjectId/fields" --jq '.[].name' 2>&1
        if ($LASTEXITCODE -eq 0) {
            $fieldNames = $fields | Where-Object { $_ -ne "" }
            return $null -ne ($fieldNames | Where-Object { $_ -eq $FieldName })
        }
    } catch {
        Write-VerboseMessage "Could not check existing fields: $_"
    }

    return $false
}

# Get existing field ID
function Get-FieldId {
    param(
        [string]$ProjectId,
        [string]$FieldName
    )

    Write-VerboseMessage "Getting field ID for '$FieldName'..."

    try {
        $fieldId = gh api "projects/$ProjectId/fields" --jq ".[] | select(.name == `"$FieldName`") | .id" 2>&1
        if ($LASTEXITCODE -eq 0 -and $fieldId) {
            return $fieldId.Trim()
        }
    } catch {
        Write-VerboseMessage "Could not get field ID: $_"
    }

    return $null
}

# Create single_select field
function New-SingleSelectField {
    param(
        [string]$ProjectId,
        [string]$FieldName,
        [string]$OptionsJson,
        [bool]$Required,
        [string]$DefaultValue
    )

    Write-Info "Creating single_select field: $FieldName"

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create field: $FieldName"
        Write-Info "[DRY RUN]   Type: single_select"
        Write-Info "[DRY RUN]   Options: $OptionsJson"
        Write-Info "[DRY RUN]   Required: $Required"
        if ($DefaultValue) {
            Write-Info "[DRY RUN]   Default: $DefaultValue"
            Write-Info "[DRY RUN]   Note: Default values may need to be set manually via GitHub UI or separate API call"
        }
        return "dry-run-field-id"
    }

    # Check if field already exists
    if (Test-FieldExists $ProjectId $FieldName) {
        Write-Warning "Field '$FieldName' already exists"
        $existingId = Get-FieldId $ProjectId $FieldName
        if ($existingId) {
            Write-Info "Using existing field ID: $existingId"
            return $existingId
        }
    }

    # Create field with rate limiting
    $maxRetries = 3
    $retryDelay = 1
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        try {
            # GitHub Projects v2 API - create custom field
            # Note: Projects v2 uses GraphQL API primarily, but REST API is available via gh api
            # Reference: https://docs.github.com/en/rest/projects/fields#create-a-project-field
            # Note: Default values are not supported in field creation API - they must be set manually
            # via GitHub UI or via separate API call after field creation
            $response = gh api `
                --method POST `
                -H "Accept: application/vnd.github+json" `
                "projects/$ProjectId/fields" `
                -f "name=$FieldName" `
                -f "dataType=single_select" `
                -f "options=$OptionsJson" `
                2>&1

            if ($LASTEXITCODE -eq 0) {
                if (Test-Command "yq") {
                    $fieldId = $response | yq eval '.id' - 2>&1
                } else {
                    $json = $response | ConvertFrom-Json
                    $fieldId = $json.id
                }

                if ($fieldId) {
                    Write-Success "Created field: $FieldName (ID: $fieldId)"
                    if ($DefaultValue) {
                        Write-Info "  Note: Default value '$DefaultValue' must be set manually via GitHub UI"
                        Write-Info "  GitHub Projects v2 API does not support setting defaults during field creation"
                    }
                    return $fieldId.ToString()
                }
            }

            # Extract HTTP status code if available
            $httpStatus = $null
            if ($response -match 'HTTP (\d{3})') {
                $httpStatus = $matches[1]
            }

            # Check for rate limit
            if ($response -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit (HTTP $($httpStatus -or '429')), waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }

            # Other errors
            if ($httpStatus) {
                Write-Error "Failed to create field '$FieldName' (HTTP $httpStatus): $response"
            } else {
                Write-Error "Failed to create field '$FieldName': $response"
            }
            return $null
        } catch {
            if ($_.Exception.Message -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit, waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }
            Write-Error "Failed to create field '$FieldName': $_"
            return $null
        }
    }

    Write-Error "Failed to create field '$FieldName' after $maxRetries attempts"
    return $null
}

# Create number field
function New-NumberField {
    param(
        [string]$ProjectId,
        [string]$FieldName,
        [bool]$Required
    )

    Write-Info "Creating number field: $FieldName"

    if ($DryRun) {
        Write-Info "[DRY RUN] Would create field: $FieldName"
        Write-Info "[DRY RUN]   Type: number"
        Write-Info "[DRY RUN]   Required: $Required"
        return "dry-run-field-id"
    }

    # Check if field already exists
    if (Test-FieldExists $ProjectId $FieldName) {
        Write-Warning "Field '$FieldName' already exists"
        $existingId = Get-FieldId $ProjectId $FieldName
        if ($existingId) {
            Write-Info "Using existing field ID: $existingId"
            return $existingId
        }
    }

    # Create field with rate limiting
    $maxRetries = 3
    $retryDelay = 1
    $attempt = 0

    while ($attempt -lt $maxRetries) {
        try {
            $response = gh api `
                --method POST `
                -H "Accept: application/vnd.github+json" `
                "projects/$ProjectId/fields" `
                -f "name=$FieldName" `
                -f "dataType=number" `
                2>&1

            if ($LASTEXITCODE -eq 0) {
                if (Test-Command "yq") {
                    $fieldId = $response | yq eval '.id' - 2>&1
                } else {
                    $json = $response | ConvertFrom-Json
                    $fieldId = $json.id
                }

                if ($fieldId) {
                    Write-Success "Created field: $FieldName (ID: $fieldId)"
                    return $fieldId.ToString()
                }
            }

            # Extract HTTP status code if available
            $httpStatus = $null
            if ($response -match 'HTTP (\d{3})') {
                $httpStatus = $matches[1]
            }

            # Check for rate limit
            if ($response -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit (HTTP $($httpStatus -or '429')), waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }

            # Other errors
            if ($httpStatus) {
                Write-Error "Failed to create field '$FieldName' (HTTP $httpStatus): $response"
            } else {
                Write-Error "Failed to create field '$FieldName': $response"
            }
            return $null
        } catch {
            if ($_.Exception.Message -match "rate limit|429|too many requests") {
                $attempt++
                if ($attempt -lt $maxRetries) {
                    Write-Warning "Rate limit hit, waiting ${retryDelay}s before retry (attempt $attempt/$maxRetries)..."
                    Start-Sleep -Seconds $retryDelay
                    $retryDelay *= 2
                    continue
                } else {
                    Write-Error "Rate limit exceeded after $maxRetries attempts. Please try again later."
                    return $null
                }
            }
            Write-Error "Failed to create field '$FieldName': $_"
            return $null
        }
    }

    Write-Error "Failed to create field '$FieldName' after $maxRetries attempts"
    return $null
}

# Store project ID
function Save-ProjectId {
    param(
        [string]$ProjectId,
        [string]$ProjectName
    )

    Write-VerboseMessage "Storing project ID in field IDs file..."

    if ($DryRun) {
        Write-VerboseMessage "[DRY RUN] Would store project ID: $ProjectId"
        return $true
    }

    if (-not (Test-Path $FieldIdsFile)) {
        Write-Error "Field IDs file not found: $FieldIdsFile" 1
        return $false
    }

    if (Test-Command "yq") {
        try {
            yq eval ".project.id = `"$ProjectId`"" -i $FieldIdsFile 2>&1 | Out-Null
            yq eval ".project.name = `"$ProjectName`"" -i $FieldIdsFile 2>&1 | Out-Null
            Write-VerboseMessage "Stored project ID: $ProjectId"
            return $true
        } catch {
            Write-Warning "Could not update field IDs file with project ID"
            return $false
        }
    }

    return $false
}

# Store field ID
function Save-FieldId {
    param(
        [string]$FieldName,
        [string]$FieldId
    )

    Write-VerboseMessage "Storing field ID for '$FieldName'..."

    if ($DryRun) {
        Write-VerboseMessage "[DRY RUN] Would store field ID: $FieldId for $FieldName"
        return $true
    }

    if (-not (Test-Path $FieldIdsFile)) {
        Write-Error "Field IDs file not found: $FieldIdsFile" 1
        return $false
    }

    if (Test-Command "yq") {
        try {
            # Find field index
            $fieldIndex = yq eval ".custom_fields | to_entries | .[] | select(.value.name == `"$FieldName`") | .key" $FieldIdsFile 2>&1
            if ($LASTEXITCODE -eq 0 -and $fieldIndex) {
                yq eval ".custom_fields[${fieldIndex}].id = `"$FieldId`"" -i $FieldIdsFile 2>&1 | Out-Null
                Write-VerboseMessage "Stored field ID: $FieldId for $FieldName"
                return $true
            } else {
                Write-Warning "Field '$FieldName' not found in field IDs file structure"
                return $false
            }
        } catch {
            Write-Warning "Could not update field IDs file with field ID for $FieldName"
            return $false
        }
    }

    return $false
}

# Main function
function Main {
    if ($Help) {
        Show-Help
    }

    Write-Info "GitHub Project v2 Setup for RHYTHM Method"
    Write-Info "========================================="

    if ($DryRun) {
        Write-Warning "DRY RUN MODE - No changes will be made"
    }

    # Validate prerequisites
    Test-Prerequisites

    # Ensure config files exist
    Ensure-ConfigFile
    Ensure-FieldIdsFile

    # Get repository
    $repo = Get-Repository
    Write-Info "Using repository: $repo"

    # Check permissions
    Test-RepoPermissions $repo

    # Get project configuration
    $projectName = Get-ProjectName
    $projectDescription = Get-ProjectDescription
    $visibility = "private"
    if (Test-Command "yq" -and (Test-Path $ConfigFile)) {
        $visibility = yq eval '.project.visibility // "private"' $ConfigFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            $visibility = "private"
        }
    }

    Write-Info "Project configuration:"
    Write-Info "  Name: $projectName"
    Write-Info "  Description: $projectDescription"
    Write-Info "  Visibility: $visibility"

    # Create project
    $projectId = New-Project $repo $projectName $projectDescription $visibility
    if (-not $projectId) {
        Write-Error "Failed to create project" 1
    }

    # Store project ID
    Save-ProjectId $projectId $projectName

    # Read custom fields from config
    Write-Info "Reading custom fields from configuration..."

    if (-not (Test-Path $ConfigFile)) {
        Write-Error "Configuration file not found: $ConfigFile" 1
    }

    $customFieldsCount = 0
    if (Test-Command "yq") {
        $customFieldsCount = yq eval '.project.custom_fields | length' $ConfigFile 2>&1
        if ($LASTEXITCODE -ne 0) {
            $customFieldsCount = 0
        }
    }

    if ($customFieldsCount -eq 0) {
        Write-Error "No custom fields found in configuration file" 1
    }

    Write-Info "Found $customFieldsCount custom field(s) to create"

    # Process each custom field
    $successCount = 0
    $skipCount = 0
    $errorCount = 0
    $currentIndex = 0

    for ($i = 0; $i -lt $customFieldsCount; $i++) {
        $currentIndex++
        Write-Info "Processing $currentIndex of $customFieldsCount"

        $fieldName = $null
        $fieldType = $null
        $fieldOptions = $null
        $fieldRequired = $false
        $fieldDefault = ""

        if (Test-Command "yq") {
            $fieldName = yq eval ".project.custom_fields[$i].name" $ConfigFile 2>&1
            $fieldType = yq eval ".project.custom_fields[$i].type" $ConfigFile 2>&1
            $fieldRequiredStr = yq eval ".project.custom_fields[$i].required // false" $ConfigFile 2>&1
            $fieldRequired = $fieldRequiredStr -eq "true"
        }

        if (-not $fieldName) {
            Write-Warning "Skipping field at index $i (missing name)"
            $errorCount++
            continue
        }

        Write-Info "  Field: $fieldName (Type: $fieldType)"

        # Handle dynamic Assigned Agent field
        if ($fieldName -eq "Assigned Agent") {
            $dynamic = $false
            if (Test-Command "yq") {
                $dynamicStr = yq eval ".project.custom_fields[$i].dynamic // false" $ConfigFile 2>&1
                $dynamic = $dynamicStr -eq "true"
            }

            if ($dynamic) {
                Write-Info "  Dynamic field: Populating options from project.config.yml..."
                $agents = Get-AgentsFromConfig
                if (-not $agents) {
                    Write-Error "Failed to get agents from project.config.yml" 0
                    $errorCount++
                    continue
                }

                # Convert agents to JSON array
                $agentsArray = $agents | ConvertTo-Json -Compress
                $fieldOptions = $agentsArray

                if (-not $fieldOptions -or $fieldOptions -eq "[]") {
                    Write-Error "No valid agents found for Assigned Agent field" 0
                    $errorCount++
                    continue
                }

                Write-VerboseMessage "  Agents: $fieldOptions"
            } else {
                # Read options from config
                if (Test-Command "yq") {
                    $fieldOptions = yq eval ".project.custom_fields[$i].options | to_json" $ConfigFile 2>&1
                }
            }
        } else {
            # Read options from config for single_select fields
            if ($fieldType -eq "single_select") {
                if (Test-Command "yq") {
                    $fieldOptions = yq eval ".project.custom_fields[$i].options | to_json" $ConfigFile 2>&1
                }
            }
        }

        # Get default value if specified
        if (Test-Command "yq") {
            $fieldDefault = yq eval ".project.custom_fields[$i].default // `"`"" $ConfigFile 2>&1
        }

        # Create field based on type
        $fieldId = $null
        if ($fieldType -eq "single_select") {
            $fieldId = New-SingleSelectField $projectId $fieldName $fieldOptions $fieldRequired $fieldDefault
            if ($fieldId) {
                Save-FieldId $fieldName $fieldId
                $successCount++
            } else {
                $errorCount++
            }
        } elseif ($fieldType -eq "number") {
            $fieldId = New-NumberField $projectId $fieldName $fieldRequired
            if ($fieldId) {
                Save-FieldId $fieldName $fieldId
                $successCount++
            } else {
                $errorCount++
            }
        } else {
            Write-Warning "Unknown field type: $fieldType (skipping)"
            $errorCount++
            continue
        }
    }

    # Summary
    Write-Host ""
    Write-Info "Summary:"
    Write-Info "  Project: $projectName (ID: $projectId)"
    Write-Info "  Fields Created: $successCount"
    Write-Info "  Fields Skipped: $skipCount"
    if ($errorCount -gt 0) {
        Write-Error "  Errors: $errorCount" 1
    }

    if ($DryRun) {
        Write-Warning "DRY RUN - No changes were made"
    } else {
        Write-Success "Project setup completed successfully!"
        Write-Info "Project and field IDs stored in: $FieldIdsFile"
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

