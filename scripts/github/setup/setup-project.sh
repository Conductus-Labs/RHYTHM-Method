#!/usr/bin/env bash
#
# Setup GitHub Project v2 for RHYTHM Method
# 
# This script creates a GitHub Project v2 with all required custom fields
# (Status, TEMPO, Assigned Agent, Tokens, Bug Relationship, Severity)
# using GitHub CLI.
#
# Usage:
#   ./setup-project.sh [--dry-run] [--verbose] [--help]
#
# Options:
#   --dry-run    Preview changes without applying them
#   --verbose    Show detailed output
#   --help       Show this help message
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository admin permissions (required for Projects v2)
#   - YAML parser (yq) for parsing configuration
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

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../templates"
CONFIG_TEMPLATE="${TEMPLATE_DIR}/github-config.yml.template"
CONFIG_FILE="${REPO_ROOT}/.baton/github-config.yml"
FIELD_IDS_TEMPLATE="${TEMPLATE_DIR}/github-field-ids.yml.template"
FIELD_IDS_FILE="${REPO_ROOT}/.baton/github-field-ids.yml"
PROJECT_CONFIG_FILE="${REPO_ROOT}/.baton/project.config.yml"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false
NON_INTERACTIVE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1" >&2
    fi
}

# Show help message
show_help() {
    cat << EOF
Setup GitHub Project v2 for RHYTHM Method

This script creates a GitHub Project v2 with all required custom fields
(Status, TEMPO, Assigned Agent, Tokens, Bug Relationship, Severity)
using GitHub CLI.

USAGE:
    ${0##*/} [OPTIONS]

OPTIONS:
    --dry-run    Preview changes without applying them
    --verbose    Show detailed output
    --help       Show this help message

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository admin permissions (required for Projects v2)
    - YAML parser (yq) for parsing configuration

EXAMPLES:
    # Interactive setup
    ${0##*/}

    # Preview changes
    ${0##*/} --dry-run

    # Verbose output
    ${0##*/} --verbose

    # Help
    ${0##*/} --help
EOF
    exit 0
}

# Parse command line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help|-h)
                SHOW_HELP=true
                shift
                ;;
            --non-interactive)
                NON_INTERACTIVE=true
                shift
                ;;
            *)
                log_error "Unknown parameter: $1"
                show_help
                exit 2
                ;;
        esac
    done
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check for gh CLI
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install from: https://cli.github.com/"
        exit 2
    fi
    log_verbose "GitHub CLI found: $(gh --version | head -n1)"

    # Check gh authentication
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_info "Please run: gh auth login"
        exit 2
    fi
    log_verbose "GitHub CLI is authenticated"

    # Check for yq
    if ! command -v yq &> /dev/null; then
        log_error "yq (YAML parser) is not installed"
        log_info "Install from: https://github.com/mikefarah/yq"
        log_info "Or use:"
        log_info "  - macOS: brew install yq"
        log_info "  - Linux: apt-get install yq (or see https://github.com/mikefarah/yq#install)"
        log_info "  - Windows: winget install mikefarah.yq"
        exit 2
    fi
    log_verbose "yq found: $(yq --version)"

    log_success "Prerequisites validated"
}

# Ensure config file exists
ensure_config_file() {
    log_info "Ensuring configuration file exists..."

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        if [[ ! -f "${CONFIG_TEMPLATE}" ]]; then
            log_error "Configuration template not found: ${CONFIG_TEMPLATE}"
            exit 2
        fi

        # Create .baton directory if it doesn't exist
        mkdir -p "$(dirname "${CONFIG_FILE}")"

        # Copy template
        cp "${CONFIG_TEMPLATE}" "${CONFIG_FILE}"
        log_success "Configuration file created from template"
    else
        log_verbose "Configuration file already exists"
    fi
}

# Ensure field IDs file exists
ensure_field_ids_file() {
    log_info "Ensuring field IDs file exists..."

    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        if [[ ! -f "${FIELD_IDS_TEMPLATE}" ]]; then
            log_error "Field IDs template not found: ${FIELD_IDS_TEMPLATE}"
            exit 2
        fi

        # Create .baton directory if it doesn't exist
        mkdir -p "$(dirname "${FIELD_IDS_FILE}")"

        # Copy template
        cp "${FIELD_IDS_TEMPLATE}" "${FIELD_IDS_FILE}"
        log_success "Field IDs file created from template"
    else
        log_verbose "Field IDs file already exists"
    fi
}

# Auto-detect repository from current git repository
# Note: Log messages are sent to stderr so they don't interfere with command substitution
auto_detect_repository() {
    log_info "Auto-detecting repository from current git repository..." >&2

    if ! gh repo view --json owner,name --jq '.owner.login + "/" + .name' >/dev/null 2>&1; then
        log_warning "Could not auto-detect repository from current git repository" >&2
        return 1
    fi

    local repo
    repo=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null)
    
    if [[ -z "${repo}" ]]; then
        log_warning "Could not auto-detect repository" >&2
        return 1
    fi

    log_verbose "Auto-detected repository: ${repo}" >&2
    # Output only the repository string to stdout (for command substitution)
    echo "${repo}"
    return 0
}

# Validate repository format (org/repo)
validate_repository_format() {
    local repo=$1

    if [[ ! "${repo}" =~ ^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$ ]]; then
        log_error "Invalid repository format: ${repo}"
        log_info "Repository must be in format: org/repo (e.g., Conductus-Labs/RHYTHM-Method)"
        return 1
    fi

    return 0
}

# Get repository from config or prompt user
get_repository() {
    local repo

    # Try to read from config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        repo=$(yq eval '.github.repository // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${repo}" && "${repo}" != "null" ]]; then
            if validate_repository_format "${repo}"; then
                log_verbose "Repository from config: ${repo}"
                echo "${repo}"
                return 0
            else
                log_warning "Repository format in config is invalid, will prompt for new value"
                repo=""
            fi
        fi
    fi

    # Try auto-detection
    # Note: auto_detect_repository() already redirects log messages to stderr, so we don't need 2>&1 here
    if repo=$(auto_detect_repository); then
        # Clean up any log output that might have been captured (defensive programming)
        repo=$(echo "${repo}" | grep -E '^[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+$' | head -n1 || echo "${repo}")
        
        if validate_repository_format "${repo}"; then
            log_info "Auto-detected repository: ${repo}"
            if [[ "${NON_INTERACTIVE}" == "true" ]]; then
                # In non-interactive mode, use auto-detected repository without prompting
                echo "${repo}"
                return 0
            else
                read -p "Use this repository? [Y/n]: " confirm
                if [[ "${confirm}" =~ ^[Nn]$ ]]; then
                    repo=""
                fi
            fi
        else
            log_warning "Auto-detected repository format is invalid, will prompt for new value"
            repo=""
        fi
    fi

    # Prompt user if still not set
    if [[ -z "${repo}" ]]; then
        if [[ "${NON_INTERACTIVE}" == "true" ]]; then
            log_error "Repository name is required"
            log_info "Could not auto-detect repository and non-interactive mode is enabled"
            log_info "Please set repository in config file or run in interactive mode"
            exit 2
        fi
        
        while [[ -z "${repo}" ]]; do
            read -p "Enter GitHub repository (format: org/repo): " repo
            if [[ -z "${repo}" ]]; then
                log_error "Repository name is required"
                exit 2
            fi
            if ! validate_repository_format "${repo}"; then
                log_error "Invalid repository format: ${repo}"
                log_info "Repository must be in format: org/repo (e.g., Conductus-Labs/RHYTHM-Method)"
                repo=""
                continue
            fi
        done
    fi

    # Update config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        yq eval ".github.repository = \"${repo}\"" -i "${CONFIG_FILE}" 2>/dev/null || {
            log_warning "Could not update config file with repository"
        }
    fi

    echo "${repo}"
}

# Get project name from config or prompt user
get_project_name() {
    local project_name

    # Try to read from config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        project_name=$(yq eval '.project.name // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${project_name}" && "${project_name}" != "null" ]]; then
            log_verbose "Project name from config: ${project_name}"
            echo "${project_name}"
            return 0
        fi
    fi

    # Prompt user
    read -p "Enter project name (e.g., 'RHYTHM Method Project'): " project_name
    if [[ -z "${project_name}" ]]; then
        log_error "Project name is required"
        exit 2
    fi

    # Update config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        yq eval ".project.name = \"${project_name}\"" -i "${CONFIG_FILE}" 2>/dev/null || {
            log_warning "Could not update config file with project name"
        }
    fi

    echo "${project_name}"
}

# Get project description from config or prompt user
get_project_description() {
    local project_description

    # Try to read from config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        project_description=$(yq eval '.project.description // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${project_description}" && "${project_description}" != "null" ]]; then
            log_verbose "Project description from config: ${project_description}"
            echo "${project_description}"
            return 0
        fi
    fi

    # Prompt user
    read -p "Enter project description (e.g., 'RHYTHM Method work item tracking and management'): " project_description
    if [[ -z "${project_description}" ]]; then
        project_description="RHYTHM Method work item tracking and management"
        log_info "Using default description: ${project_description}"
    fi

    # Update config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        yq eval ".project.description = \"${project_description}\"" -i "${CONFIG_FILE}" 2>/dev/null || {
            log_warning "Could not update config file with project description"
        }
    fi

    echo "${project_description}"
}

# Check if user has repo admin permissions
check_repo_permissions() {
    local repo=$1

    log_info "Checking repository admin permissions..."

    # Extract org and repo name
    local org
    local repo_name
    org=$(echo "${repo}" | cut -d'/' -f1)
    repo_name=$(echo "${repo}" | cut -d'/' -f2)

    # Check if user has admin permissions
    local has_admin
    has_admin=$(gh api "repos/${repo}" --jq '.permissions.admin // false' 2>/dev/null || echo "false")

    if [[ "${has_admin}" != "true" ]]; then
        log_error "You do not have repository admin permissions for: ${repo}"
        log_info "Projects v2 can only be created by repository admins"
        log_info "Please request repo admin access or have a repo admin run this script"
        exit 2
    fi

    log_success "Repository admin permissions verified"
}

# Check if project already exists
project_exists() {
    local repo=$1
    local project_name=$2

    log_verbose "Checking if project '${project_name}' already exists..."

    # Projects v2 requires GraphQL API
    # Get owner (organization or user) from repository
    local owner
    owner=$(echo "${repo}" | cut -d'/' -f1)
    
    # Query Projects v2 for the owner using GraphQL
    local query="query { organization(login: \"${owner}\") { projectsV2(first: 100) { nodes { title id } } } }"
    local projects
    projects=$(gh api graphql -f query="${query}" --jq '.data.organization.projectsV2.nodes[]?.title' 2>/dev/null || echo "")
    
    # If not an organization, try as user
    if [[ -z "${projects}" ]]; then
        query="query { user(login: \"${owner}\") { projectsV2(first: 100) { nodes { title id } } } }"
        projects=$(gh api graphql -f query="${query}" --jq '.data.user.projectsV2.nodes[]?.title' 2>/dev/null || echo "")
    fi

    if echo "${projects}" | grep -q "^${project_name}$"; then
        return 0
    fi

    return 1
}

# Get existing project ID
get_project_id() {
    local repo=$1
    local project_name=$2

    log_verbose "Getting project ID for '${project_name}'..."

    # Projects v2 requires GraphQL API
    # Get owner (organization or user) from repository
    local owner
    owner=$(echo "${repo}" | cut -d'/' -f1)
    
    # Query Projects v2 for the owner using GraphQL
    local query="query { organization(login: \"${owner}\") { projectsV2(first: 100) { nodes { title id } } } }"
    local project_id
    project_id=$(gh api graphql -f query="${query}" --jq ".data.organization.projectsV2.nodes[] | select(.title == \"${project_name}\") | .id" 2>/dev/null || echo "")
    
    # If not an organization, try as user
    if [[ -z "${project_id}" ]]; then
        query="query { user(login: \"${owner}\") { projectsV2(first: 100) { nodes { title id } } } }"
        project_id=$(gh api graphql -f query="${query}" --jq ".data.user.projectsV2.nodes[] | select(.title == \"${project_name}\") | .id" 2>/dev/null || echo "")
    fi

    if [[ -n "${project_id}" ]]; then
        echo "${project_id}"
        return 0
    fi

    return 1
}

# Create GitHub Project v2
create_project() {
    local repo=$1
    local project_name=$2
    local project_description=$3
    local visibility=$4

    # Note: Log messages are sent to stderr so they don't interfere with command substitution
    log_info "Creating GitHub Project v2: ${project_name}" >&2

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create project: ${project_name}" >&2
        log_info "[DRY RUN]   Description: ${project_description}" >&2
        log_info "[DRY RUN]   Visibility: ${visibility}" >&2
        log_info "[DRY RUN]   Repository: ${repo}" >&2
        # Output only the project ID to stdout (for command substitution)
        echo "dry-run-project-id"
        return 0
    fi

    # Check if project already exists
    if project_exists "${repo}" "${project_name}"; then
        log_warning "Project '${project_name}' already exists" >&2
        local existing_id
        if existing_id=$(get_project_id "${repo}" "${project_name}"); then
            log_info "Using existing project ID: ${existing_id}" >&2
            # Output only the project ID to stdout (for command substitution)
            echo "${existing_id}"
            return 0
        fi
    fi

    # Create project via GitHub API with rate limiting retry logic
    local max_retries=3
    local retry_delay=1
    local attempt=0
    local response
    local exit_code=0

    while [[ ${attempt} -lt ${max_retries} ]]; do
        # GitHub Projects v2 API - create project using GraphQL
        # Projects v2 requires GraphQL API, not REST API
        # First, get the repository owner ID (needed for GraphQL mutation)
        local owner
        local owner_id
        owner=$(echo "${repo}" | cut -d'/' -f1)
        
        # Get owner ID (organization or user)
        owner_id=$(gh api graphql -f query="
            query {
                organization(login: \"${owner}\") {
                    id
                }
            }
        " --jq '.data.organization.id' 2>/dev/null || echo "")
        
        # If not an organization, try as user
        if [[ -z "${owner_id}" ]]; then
            owner_id=$(gh api graphql -f query="
                query {
                    user(login: \"${owner}\") {
                        id
                    }
                }
            " --jq '.data.user.id' 2>/dev/null || echo "")
        fi
        
        if [[ -z "${owner_id}" ]]; then
            log_error "Failed to get owner ID for: ${owner}" >&2
            return 1
        fi
        
        # Get repository ID to link project at creation time (optional but recommended)
        local repo_name
        repo_name=$(echo "${repo}" | cut -d'/' -f2)
        local repo_id
        local repo_query="query { repository(owner: \"${owner}\", name: \"${repo_name}\") { id } }"
        repo_id=$(gh api graphql -f query="${repo_query}" --jq '.data.repository.id' 2>/dev/null || echo "")
        
        # Create Projects v2 using GraphQL mutation
        # Note: CreateProjectV2Input only accepts: ownerId, title, repositoryId, teamId, clientMutationId
        # Description and visibility cannot be set at creation time
        # If repositoryId is provided, project is automatically linked to repository
        local graphql_query
        if [[ -n "${repo_id}" ]]; then
            graphql_query="mutation { createProjectV2(input: { ownerId: \"${owner_id}\", title: \"${project_name}\", repositoryId: \"${repo_id}\" }) { projectV2 { id number title } } }"
        else
            graphql_query="mutation { createProjectV2(input: { ownerId: \"${owner_id}\", title: \"${project_name}\" }) { projectV2 { id number title } } }"
        fi
        
        response=$(gh api graphql -F query="${graphql_query}" 2>&1)
        exit_code=$?

        if [[ ${exit_code} -eq 0 ]]; then
            local project_id
            project_id=$(echo "${response}" | yq eval '.data.createProjectV2.projectV2.id' - 2>/dev/null || echo "")
            if [[ -n "${project_id}" ]]; then
                log_success "Created project: ${project_name} (ID: ${project_id})" >&2
                if [[ -n "${repo_id}" ]]; then
                    log_verbose "Project automatically linked to repository: ${repo}" >&2
                else
                    log_verbose "Project created via GraphQL API (not linked to repository)" >&2
                fi
                
                # Note: Project description and visibility cannot be set via CreateProjectV2Input
                # These would need to be set via updateProjectV2 mutation if needed
                if [[ -n "${project_description}" ]]; then
                    log_verbose "Note: Project description cannot be set at creation time (GitHub API limitation)" >&2
                fi
                if [[ "${visibility}" != "private" ]]; then
                    log_verbose "Note: Project visibility cannot be set at creation time (GitHub API limitation)" >&2
                fi
                
                # Output only the project ID to stdout (for command substitution)
                echo "${project_id}"
                return 0
            fi
        fi

        # Check for rate limit error (429) or rate limit message
        if echo "${response}" | grep -qiE "rate limit|429|too many requests"; then
            attempt=$((attempt + 1))
            if [[ ${attempt} -lt ${max_retries} ]]; then
                log_warning "Rate limit hit, waiting ${retry_delay}s before retry (attempt ${attempt}/${max_retries})..." >&2
                sleep ${retry_delay}
                retry_delay=$((retry_delay * 2))  # Exponential backoff
                continue
            else
                log_error "Rate limit exceeded after ${max_retries} attempts. Please try again later." >&2
                return 1
            fi
        fi

        # Extract HTTP status code if available
        local http_status
        http_status=$(echo "${response}" | grep -oE "HTTP [0-9]{3}" | grep -oE "[0-9]{3}" | head -1 || echo "")

        # Other errors - don't retry
        if [[ -n "${http_status}" ]]; then
            log_error "Failed to create project '${project_name}' (HTTP ${http_status}): ${response}" >&2
        else
            log_error "Failed to create project '${project_name}': ${response}" >&2
        fi
        return ${exit_code}
    done

    log_error "Failed to create project '${project_name}' after ${max_retries} attempts" >&2
    return 1
}

# Get agents from project.config.yml for Assigned Agent field
get_agents_from_config() {
    log_verbose "Reading agents from project.config.yml..."

    if [[ ! -f "${PROJECT_CONFIG_FILE}" ]]; then
        log_error "Project config file not found: ${PROJECT_CONFIG_FILE}"
        log_info "Assigned Agent field requires .baton/project.config.yml with agents.enabled list"
        return 1
    fi

    local agents
    agents=$(yq eval '.agents.enabled[].name' "${PROJECT_CONFIG_FILE}" 2>/dev/null || echo "")

    if [[ -z "${agents}" ]]; then
        log_error "No agents found in project.config.yml"
        log_info "Please ensure .baton/project.config.yml contains agents.enabled list"
        return 1
    fi

    # Convert to array and validate count
    local agent_count
    agent_count=$(echo "${agents}" | wc -l | tr -d ' ')

    if [[ ${agent_count} -lt 1 ]]; then
        log_error "At least 1 agent must be configured (found: ${agent_count})"
        return 1
    fi

    if [[ ${agent_count} -gt 25 ]]; then
        log_error "Too many agents configured (found: ${agent_count}, max: 25)"
        log_info "GitHub Projects v2 single select fields have a limit of 25 options"
        return 1
    fi

    log_verbose "Found ${agent_count} agent(s) in project.config.yml"
    echo "${agents}"
    return 0
}

# Check if custom field exists
field_exists() {
    local project_id=$1
    local field_name=$2

    log_verbose "Checking if field '${field_name}' already exists..."

    # Get existing fields for the project using GraphQL
    local query="query { node(id: \"${project_id}\") { ... on ProjectV2 { fields(first: 100) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name } ... on ProjectV2IterationField { id name } ... on ProjectV2DateField { id name } ... on ProjectV2NumberField { id name } } } } } }"
    local fields
    fields=$(gh api graphql -f query="${query}" --jq '.data.node.fields.nodes[].name' 2>/dev/null || echo "")

    if echo "${fields}" | grep -q "^${field_name}$"; then
        return 0
    fi

    return 1
}

# Get existing field ID
get_field_id() {
    local project_id=$1
    local field_name=$2

    log_verbose "Getting field ID for '${field_name}'..."

    # Get existing fields for the project using GraphQL
    local query="query { node(id: \"${project_id}\") { ... on ProjectV2 { fields(first: 100) { nodes { ... on ProjectV2Field { id name } ... on ProjectV2SingleSelectField { id name } ... on ProjectV2IterationField { id name } ... on ProjectV2DateField { id name } ... on ProjectV2NumberField { id name } } } } } }"
    local field_id
    field_id=$(gh api graphql -f query="${query}" --jq ".data.node.fields.nodes[] | select(.name == \"${field_name}\") | .id" 2>/dev/null || echo "")

    if [[ -n "${field_id}" ]]; then
        echo "${field_id}"
        return 0
    fi

    return 1
}

# Create custom field (single_select)
create_single_select_field() {
    local project_id=$1
    local field_name=$2
    local options_json=$3
    local required=$4
    local default_value=$5

    log_info "Creating single_select field: ${field_name}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create field: ${field_name}"
        log_info "[DRY RUN]   Type: single_select"
        log_info "[DRY RUN]   Options: ${options_json}"
        log_info "[DRY RUN]   Required: ${required}"
        if [[ -n "${default_value}" ]]; then
            log_info "[DRY RUN]   Default: ${default_value}"
            log_info "[DRY RUN]   Note: Default values may need to be set manually via GitHub UI or separate API call"
        fi
        echo "dry-run-field-id"
        return 0
    fi

    # Check if field already exists
    if field_exists "${project_id}" "${field_name}"; then
        log_warning "Field '${field_name}' already exists"
        local existing_id
        if existing_id=$(get_field_id "${project_id}" "${field_name}"); then
            log_info "Using existing field ID: ${existing_id}"
            echo "${existing_id}"
            return 0
        fi
    fi

    # Create field via GitHub API with rate limiting retry logic
    local max_retries=3
    local retry_delay=1
    local attempt=0
    local response
    local exit_code=0

    while [[ ${attempt} -lt ${max_retries} ]]; do
        # GitHub Projects v2 API - create custom field using GraphQL
        # Projects v2 requires GraphQL API for field creation
        # Note: Default values are not supported in field creation API - they must be set manually
        # via GitHub UI or via separate API call after field creation
        
        # Parse options JSON into GraphQL format
        # options_json format: [{"name":"Planned","color":"BLUE"},...]
        # GraphQL expects: [{name:"Planned",color:BLUE},...] (no quotes around enum values, no quotes around keys)
        # Build GraphQL options array manually from JSON
        local options_graphql="["
        local first=true
        local option_count
        option_count=$(echo "${options_json}" | yq eval 'length' - 2>/dev/null || echo "0")
        
        for ((i=0; i<option_count; i++)); do
            local opt_name
            local opt_color
            opt_name=$(echo "${options_json}" | yq eval ".[${i}].name" - 2>/dev/null || echo "")
            opt_color=$(echo "${options_json}" | yq eval ".[${i}].color" - 2>/dev/null || echo "")
            
            if [[ -n "${opt_name}" && -n "${opt_color}" ]]; then
                if [[ "${first}" == "true" ]]; then
                    first=false
                else
                    options_graphql+=","
                fi
                options_graphql+="{name:\"${opt_name}\",color:${opt_color}}"
            fi
        done
        options_graphql+="]"
        
        # Build GraphQL mutation
        local mutation="mutation { createProjectV2Field(input: { projectId: \"${project_id}\", dataType: SINGLE_SELECT, name: \"${field_name}\", singleSelectOptions: ${options_graphql} }) { projectV2Field { ... on ProjectV2SingleSelectField { id name } } } }"
        
        response=$(gh api graphql -f query="${mutation}" 2>&1)
        exit_code=$?

        if [[ ${exit_code} -eq 0 ]]; then
            local field_id
            field_id=$(echo "${response}" | yq eval '.data.createProjectV2Field.projectV2Field.id' - 2>/dev/null || echo "")
            if [[ -n "${field_id}" ]]; then
                log_success "Created field: ${field_name} (ID: ${field_id})"
                if [[ -n "${default_value}" ]]; then
                    log_info "  Note: Default value '${default_value}' must be set manually via GitHub UI"
                    log_info "  GitHub Projects v2 API does not support setting defaults during field creation"
                fi
                echo "${field_id}"
                return 0
            fi
        fi

        # Extract HTTP status code if available
        local http_status
        http_status=$(echo "${response}" | grep -oE "HTTP [0-9]{3}" | grep -oE "[0-9]{3}" | head -1 || echo "")

        # Check for rate limit error (429) or rate limit message
        if echo "${response}" | grep -qiE "rate limit|429|too many requests"; then
            attempt=$((attempt + 1))
            if [[ ${attempt} -lt ${max_retries} ]]; then
                log_warning "Rate limit hit (HTTP ${http_status:-429}), waiting ${retry_delay}s before retry (attempt ${attempt}/${max_retries})..."
                sleep ${retry_delay}
                retry_delay=$((retry_delay * 2))  # Exponential backoff
                continue
            else
                log_error "Rate limit exceeded after ${max_retries} attempts. Please try again later."
                return 1
            fi
        fi

        # Other errors - don't retry
        if [[ -n "${http_status}" ]]; then
            log_error "Failed to create field '${field_name}' (HTTP ${http_status}): ${response}"
        else
            log_error "Failed to create field '${field_name}': ${response}"
        fi
        return ${exit_code}
    done

    log_error "Failed to create field '${field_name}' after ${max_retries} attempts"
    return 1
}

# Create custom field (number)
create_number_field() {
    local project_id=$1
    local field_name=$2
    local required=$3

    log_info "Creating number field: ${field_name}"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create field: ${field_name}"
        log_info "[DRY RUN]   Type: number"
        log_info "[DRY RUN]   Required: ${required}"
        echo "dry-run-field-id"
        return 0
    fi

    # Check if field already exists
    if field_exists "${project_id}" "${field_name}"; then
        log_warning "Field '${field_name}' already exists"
        local existing_id
        if existing_id=$(get_field_id "${project_id}" "${field_name}"); then
            log_info "Using existing field ID: ${existing_id}"
            echo "${existing_id}"
            return 0
        fi
    fi

    # Create field via GitHub API with rate limiting retry logic
    local max_retries=3
    local retry_delay=1
    local attempt=0
    local response
    local exit_code=0

    while [[ ${attempt} -lt ${max_retries} ]]; do
        # GitHub Projects v2 API - create custom field using GraphQL
        # Projects v2 requires GraphQL API for field creation
        
        # Build GraphQL mutation
        local mutation="mutation { createProjectV2Field(input: { projectId: \"${project_id}\", dataType: NUMBER, name: \"${field_name}\" }) { projectV2Field { ... on ProjectV2NumberField { id name } } } }"
        
        response=$(gh api graphql -f query="${mutation}" 2>&1)
        exit_code=$?

        if [[ ${exit_code} -eq 0 ]]; then
            local field_id
            field_id=$(echo "${response}" | yq eval '.data.createProjectV2Field.projectV2Field.id' - 2>/dev/null || echo "")
            if [[ -n "${field_id}" ]]; then
                log_success "Created field: ${field_name} (ID: ${field_id})"
                echo "${field_id}"
                return 0
            fi
        fi

        # Extract HTTP status code if available
        local http_status
        http_status=$(echo "${response}" | grep -oE "HTTP [0-9]{3}" | grep -oE "[0-9]{3}" | head -1 || echo "")

        # Check for rate limit error (429) or rate limit message
        if echo "${response}" | grep -qiE "rate limit|429|too many requests"; then
            attempt=$((attempt + 1))
            if [[ ${attempt} -lt ${max_retries} ]]; then
                log_warning "Rate limit hit (HTTP ${http_status:-429}), waiting ${retry_delay}s before retry (attempt ${attempt}/${max_retries})..."
                sleep ${retry_delay}
                retry_delay=$((retry_delay * 2))  # Exponential backoff
                continue
            else
                log_error "Rate limit exceeded after ${max_retries} attempts. Please try again later."
                return 1
            fi
        fi

        # Other errors - don't retry
        if [[ -n "${http_status}" ]]; then
            log_error "Failed to create field '${field_name}' (HTTP ${http_status}): ${response}"
        else
            log_error "Failed to create field '${field_name}': ${response}"
        fi
        return ${exit_code}
    done

    log_error "Failed to create field '${field_name}' after ${max_retries} attempts"
    return 1
}

# Store project ID in field IDs file
store_project_id() {
    local project_id=$1
    local project_name=$2

    log_verbose "Storing project ID in field IDs file..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would store project ID: ${project_id}"
        return 0
    fi

    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        log_error "Field IDs file not found: ${FIELD_IDS_FILE}"
        return 1
    fi

    yq eval ".project.id = \"${project_id}\"" -i "${FIELD_IDS_FILE}" 2>/dev/null || {
        log_warning "Could not update field IDs file with project ID"
        return 1
    }

    yq eval ".project.name = \"${project_name}\"" -i "${FIELD_IDS_FILE}" 2>/dev/null || {
        log_warning "Could not update field IDs file with project name"
        return 1
    }

    log_verbose "Stored project ID: ${project_id}"
    return 0
}

# Store field ID in field IDs file
store_field_id() {
    local field_name=$1
    local field_id=$2

    log_verbose "Storing field ID for '${field_name}'..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would store field ID: ${field_id} for ${field_name}"
        return 0
    fi

    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        log_error "Field IDs file not found: ${FIELD_IDS_FILE}"
        return 1
    fi

    # Find the field in the custom_fields array and update its ID
    local field_index
    field_index=$(yq eval ".custom_fields | to_entries | .[] | select(.value.name == \"${field_name}\") | .key" "${FIELD_IDS_FILE}" 2>/dev/null || echo "")

    if [[ -n "${field_index}" ]]; then
        yq eval ".custom_fields[${field_index}].id = \"${field_id}\"" -i "${FIELD_IDS_FILE}" 2>/dev/null || {
            log_warning "Could not update field IDs file with field ID for ${field_name}"
            return 1
        }
        log_verbose "Stored field ID: ${field_id} for ${field_name}"
        return 0
    else
        log_warning "Field '${field_name}' not found in field IDs file structure"
        return 1
    fi
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "GitHub Project v2 Setup for RHYTHM Method"
    log_info "========================================="

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    # Validate prerequisites
    validate_prerequisites

    # Ensure config files exist
    ensure_config_file
    ensure_field_ids_file

    # Get repository
    local repo
    repo=$(get_repository)
    log_info "Using repository: ${repo}"

    # Check permissions
    check_repo_permissions "${repo}"

    # Get project configuration
    local project_name
    local project_description
    local visibility
    project_name=$(get_project_name)
    project_description=$(get_project_description)
    visibility=$(yq eval '.project.visibility // "private"' "${CONFIG_FILE}" 2>/dev/null || echo "private")

    log_info "Project configuration:"
    log_info "  Name: ${project_name}"
    log_info "  Description: ${project_description}"
    log_info "  Visibility: ${visibility}"

    # Create project
    local project_id
    if ! project_id=$(create_project "${repo}" "${project_name}" "${project_description}" "${visibility}"); then
        log_error "Failed to create project"
        exit 1
    fi

    # Store project ID
    store_project_id "${project_id}" "${project_name}"

    # Read custom fields from config
    log_info "Reading custom fields from configuration..."

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_error "Configuration file not found: ${CONFIG_FILE}"
        exit 1
    fi

    local custom_fields_count
    custom_fields_count=$(yq eval '.project.custom_fields | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")

    if [[ "${custom_fields_count}" -eq 0 ]]; then
        log_error "No custom fields found in configuration file"
        exit 1
    fi

    log_info "Found ${custom_fields_count} custom field(s) to create"

    # Process each custom field
    local success_count=0
    local skip_count=0
    local error_count=0
    local current_index=0

    for ((i=0; i<custom_fields_count; i++)); do
        current_index=$((i + 1))
        log_info "Processing ${current_index}/${custom_fields_count}:"

        local field_name
        local field_type
        local field_options
        local field_required
        local field_default

        field_name=$(yq eval ".project.custom_fields[${i}].name" "${CONFIG_FILE}" 2>/dev/null || echo "")
        field_type=$(yq eval ".project.custom_fields[${i}].type" "${CONFIG_FILE}" 2>/dev/null || echo "")
        field_required=$(yq eval ".project.custom_fields[${i}].required // false" "${CONFIG_FILE}" 2>/dev/null || echo "false")

        if [[ -z "${field_name}" ]]; then
            log_warning "Skipping field at index ${i} (missing name)"
            error_count=$((error_count + 1))
            continue
        fi

        log_info "  Field: ${field_name} (Type: ${field_type})"

        # Handle dynamic Assigned Agent field
        if [[ "${field_name}" == "Assigned Agent" ]]; then
            local dynamic
            dynamic=$(yq eval ".project.custom_fields[${i}].dynamic // false" "${CONFIG_FILE}" 2>/dev/null || echo "false")
            
            if [[ "${dynamic}" == "true" ]]; then
                log_info "  Dynamic field: Populating options from project.config.yml..."
                local agents
                if ! agents=$(get_agents_from_config); then
                    log_error "Failed to get agents from project.config.yml"
                    error_count=$((error_count + 1))
                    continue
                fi

                # Convert agents to JSON array
                # Read agents line by line and convert to JSON array
                local agents_array="["
                local first=true
                while IFS= read -r agent; do
                    if [[ -n "${agent}" ]]; then
                        if [[ "${first}" == "true" ]]; then
                            agents_array="${agents_array}\"${agent}\""
                            first=false
                        else
                            agents_array="${agents_array},\"${agent}\""
                        fi
                    fi
                done <<< "${agents}"
                agents_array="${agents_array}]"
                field_options="${agents_array}"
                
                if [[ -z "${field_options}" || "${field_options}" == "[]" ]]; then
                    log_error "No valid agents found for Assigned Agent field"
                    error_count=$((error_count + 1))
                    continue
                fi

                log_verbose "  Agents: ${field_options}"
            else
                # Read options from config
                field_options=$(yq eval ".project.custom_fields[${i}].options | to_json" "${CONFIG_FILE}" 2>/dev/null || echo "[]")
            fi
        else
            # Read options from config for single_select fields
            if [[ "${field_type}" == "single_select" ]]; then
                field_options=$(yq eval ".project.custom_fields[${i}].options | to_json" "${CONFIG_FILE}" 2>/dev/null || echo "[]")
            fi
        fi

        # Get default value if specified
        field_default=$(yq eval ".project.custom_fields[${i}].default // \"\"" "${CONFIG_FILE}" 2>/dev/null || echo "")

        # Create field based on type
        local field_id
        if [[ "${field_type}" == "single_select" ]]; then
            if field_id=$(create_single_select_field "${project_id}" "${field_name}" "${field_options}" "${field_required}" "${field_default}"); then
                store_field_id "${field_name}" "${field_id}"
                success_count=$((success_count + 1))
            else
                error_count=$((error_count + 1))
            fi
        elif [[ "${field_type}" == "number" ]]; then
            if field_id=$(create_number_field "${project_id}" "${field_name}" "${field_required}"); then
                store_field_id "${field_name}" "${field_id}"
                success_count=$((success_count + 1))
            else
                error_count=$((error_count + 1))
            fi
        else
            log_warning "Unknown field type: ${field_type} (skipping)"
            error_count=$((error_count + 1))
            continue
        fi
    done

    # Summary
    echo ""
    log_info "Summary:"
    log_info "  Project: ${project_name} (ID: ${project_id})"
    log_info "  Fields Created: ${success_count}"
    log_info "  Fields Skipped: ${skip_count}"
    if [[ ${error_count} -gt 0 ]]; then
        log_error "  Errors: ${error_count}"
        exit 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN - No changes were made"
    else
        log_success "Project setup completed successfully!"
        log_info "Project and field IDs stored in: ${FIELD_IDS_FILE}"
    fi
}

# Run main function
main "$@"

