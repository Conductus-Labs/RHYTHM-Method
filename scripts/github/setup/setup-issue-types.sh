#!/usr/bin/env bash
#
# Setup GitHub Issue Types for RHYTHM Method
# 
# This script creates GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
# at the organization level using GitHub CLI.
#
# Usage:
#   ./setup-issue-types.sh [--dry-run] [--verbose] [--help]
#
# Options:
#   --dry-run    Preview changes without applying them
#   --verbose    Show detailed output
#   --help       Show this help message
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Organization admin permissions
#   - YAML parser (yq) for parsing configuration
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

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../templates"
CONFIG_TEMPLATE="${TEMPLATE_DIR}/github-config.yml.template"
CONFIG_FILE="${REPO_ROOT}/.baton/github-config.yml"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false

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
Setup GitHub Issue Types for RHYTHM Method

This script creates GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
at the organization level using GitHub CLI.

USAGE:
    ${0##*/} [OPTIONS]

OPTIONS:
    --dry-run    Preview changes without applying them
    --verbose    Show detailed output
    --help       Show this help message

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Organization admin permissions
    - YAML parser (yq) for parsing configuration

EXAMPLES:
    # Interactive setup
    ${0##*/}

    # Preview changes
    ${0##*/} --dry-run

    # Verbose output
    ${0##*/} --verbose

EXIT CODES:
    0 = Success
    1 = Error
    2 = Validation failure

For more information, see: https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/managing-issue-types-in-an-organization
EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --dry-run)
                DRY_RUN=true
                shift
                ;;
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                SHOW_HELP=true
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 2
                ;;
        esac
    done
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate prerequisites
validate_prerequisites() {
    local errors=0

    log_info "Validating prerequisites..."

    # Check GitHub CLI
    if ! command_exists gh; then
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install from: https://cli.github.com/"
        errors=$((errors + 1))
    else
        local gh_version
        gh_version=$(gh --version | head -n1)
        log_verbose "GitHub CLI found: ${gh_version}"
    fi

    # Check authentication
    if ! gh auth status >/dev/null 2>&1; then
        log_error "GitHub CLI is not authenticated"
        log_info "Run: gh auth login"
        errors=$((errors + 1))
    else
        # Check for admin:org scope (required for creating issue types)
        local auth_status_output
        auth_status_output=$(gh auth status 2>&1 || echo "")
        if [[ -z "${auth_status_output}" ]] || ! echo "${auth_status_output}" | grep -qi "admin:org"; then
            log_warning "GitHub CLI authentication may be missing 'admin:org' scope"
            log_info "Issue Types require organization admin permissions"
            log_info "If you encounter permission errors, run: gh auth refresh -s admin:org"
        fi
        log_verbose "GitHub CLI is authenticated"
    fi

    # Check yq (YAML parser)
    if ! command_exists yq; then
        log_error "yq (YAML parser) is not installed"
        log_info "Install from: https://github.com/mikefarah/yq"
        log_info "Or use:"
        log_info "  - macOS: brew install yq"
        log_info "  - Linux: apt-get install yq (or see https://github.com/mikefarah/yq#install)"
        log_info "  - Windows: winget install mikefarah.yq"
        errors=$((errors + 1))
    else
        local yq_version
        yq_version=$(yq --version 2>/dev/null || echo "yq installed")
        log_verbose "yq found: ${yq_version}"
    fi

    if [[ $errors -gt 0 ]]; then
        log_error "Prerequisites validation failed"
        exit 2
    fi

    log_success "All prerequisites validated"
}

# Ensure config file exists (copy from template if needed)
ensure_config_file() {
    log_info "Ensuring configuration file exists..."

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_info "Configuration file not found, copying from template..."
        
        if [[ ! -f "${CONFIG_TEMPLATE}" ]]; then
            log_error "Template file not found: ${CONFIG_TEMPLATE}"
            exit 1
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

# Auto-detect organization from current repository
auto_detect_organization() {
    # Note: Log messages are sent to stderr so they don't interfere with command substitution
    log_info "Auto-detecting organization from current repository..." >&2

    if ! gh repo view --json owner --jq '.owner.login' >/dev/null 2>&1; then
        log_warning "Could not auto-detect organization from current repository" >&2
        return 1
    fi

    local org
    org=$(gh repo view --json owner --jq '.owner.login' 2>/dev/null)
    
    if [[ -z "${org}" ]]; then
        log_warning "Could not auto-detect organization" >&2
        return 1
    fi

    log_verbose "Auto-detected organization: ${org}" >&2
    # Output only the organization name to stdout (for command substitution)
    echo "${org}"
    return 0
}

# Get organization from config or prompt user
get_organization() {
    local org

    # Try to read from config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        org=$(yq eval '.github.organization // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${org}" && "${org}" != "null" ]]; then
            log_verbose "Organization from config: ${org}"
            echo "${org}"
            return 0
        fi
    fi

    # Try auto-detection
    # Note: auto_detect_organization() already redirects log messages to stderr, so we don't need 2>&1 here
    if org=$(auto_detect_organization); then
        # Clean up any log output that might have been captured (defensive programming)
        org=$(echo "${org}" | grep -E '^[a-zA-Z0-9_.-]+$' | head -n1 || echo "${org}")
        
        if [[ -n "${org}" ]]; then
            log_info "Auto-detected organization: ${org}"
            read -p "Use this organization? [Y/n]: " confirm
            if [[ "${confirm}" =~ ^[Nn]$ ]]; then
                org=""
            fi
        else
            org=""
        fi
    fi

    # Prompt user if still not set
    if [[ -z "${org}" ]]; then
        read -p "Enter GitHub organization name: " org
        if [[ -z "${org}" ]]; then
            log_error "Organization name is required"
            exit 2
        fi
    fi

    # Update config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        yq eval ".github.organization = \"${org}\"" -i "${CONFIG_FILE}" 2>/dev/null || {
            log_warning "Could not update config file with organization"
        }
    fi

    echo "${org}"
}

# Check if user has org admin permissions
check_org_permissions() {
    local org=$1

    log_info "Checking organization admin permissions..."

    # Check if user has admin permissions using user/memberships endpoint
    # The orgs/${org} endpoint doesn't return permission information for the authenticated user
    local has_admin
    local membership_role
    local api_response
    
    # Clean up org name in case it contains log output (defensive)
    org=$(echo "${org}" | grep -E '^[a-zA-Z0-9_.-]+$' | head -n1 || echo "${org}")
    
    membership_role=$(gh api "user/memberships/orgs/${org}" --jq '.role // ""' 2>/dev/null || echo "")
    
    if [[ -z "${membership_role}" ]]; then
        log_error "Failed to check organization membership for: ${org}"
        log_info "This may indicate:"
        log_info "  1. Missing 'admin:org' scope - run: gh auth refresh -s admin:org"
        log_info "  2. Organization name is incorrect"
        log_info "  3. You are not a member of this organization"
        exit 2
    fi
    
    if [[ "${membership_role}" == "admin" ]]; then
        has_admin="true"
    else
        has_admin="false"
    fi

    if [[ "${has_admin}" != "true" ]]; then
        log_error "You do not have organization admin permissions for: ${org}"
        log_info "Issue Types can only be created by organization owners/admins"
        log_info "Your current role: ${membership_role:-unknown}"
        if [[ -z "${membership_role}" ]]; then
            log_info "Unable to determine role - this may indicate missing 'admin:org' scope"
            log_info "Try running: gh auth refresh -s admin:org"
        fi
        log_info "Please request org admin access or have an org admin run this script"
        exit 2
    fi

    log_success "Organization admin permissions verified"
}

# List existing issue types
list_existing_issue_types() {
    local org=$1
    local existing_types

    log_verbose "Checking existing issue types..."

    existing_types=$(gh api "orgs/${org}/issue-types" --jq '.[].name' 2>/dev/null || echo "")

    if [[ -z "${existing_types}" ]]; then
        log_verbose "No existing issue types found"
        return 0
    fi

    log_verbose "Existing issue types:"
    while IFS= read -r type; do
        log_verbose "  - ${type}"
    done <<< "${existing_types}"

    echo "${existing_types}"
}

# Check if issue type exists
issue_type_exists() {
    local org=$1
    local type_name=$2
    local existing_types=$3

    # Handle empty existing_types gracefully
    if [[ -z "${existing_types}" ]]; then
        return 1
    fi

    if echo "${existing_types}" | grep -q "^${type_name}$"; then
        return 0
    fi
    return 1
}

# Create issue type
create_issue_type() {
    local org=$1
    local name=$2
    local description=$3
    local color=$4

    log_info "Creating issue type: ${name}"

    # Convert hex color to color name if needed
    # GitHub API may require color names instead of hex
    local api_color="${color}"
    case "${color}" in
        "#1f77b4"|"#1F77B4")
            api_color="blue"
            ;;
        "#2ca02c"|"#2CA02C")
            api_color="green"
            ;;
        "#ff7f0e"|"#FF7F0E")
            api_color="orange"
            ;;
        "#d62728"|"#D62728")
            api_color="red"
            ;;
        *)
            # Try to use hex color as-is, API will validate
            api_color="${color}"
            ;;
    esac

    log_verbose "  Name: ${name}"
    log_verbose "  Description: ${description}"
    log_verbose "  Color: ${color} (API: ${api_color})"

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create issue type: ${name}"
        return 0
    fi

    # Create issue type via GitHub API with rate limiting retry logic
    local max_retries=3
    local retry_delay=1
    local attempt=0
    local response
    local exit_code=0

    while [[ ${attempt} -lt ${max_retries} ]]; do
        response=$(gh api \
            --method POST \
            -H "Accept: application/vnd.github+json" \
            "orgs/${org}/issue-types" \
            -f "name=${name}" \
            -f "description=${description}" \
            -f "is_enabled=true" \
            -f "color=${api_color}" \
            2>&1)
        exit_code=$?

        if [[ ${exit_code} -eq 0 ]]; then
            log_success "Created issue type: ${name}"
            return 0
        fi

        # Check for rate limit error (429) or rate limit message
        if echo "${response}" | grep -qiE "rate limit|429|too many requests"; then
            attempt=$((attempt + 1))
            if [[ ${attempt} -lt ${max_retries} ]]; then
                log_warning "Rate limit hit, waiting ${retry_delay}s before retry (attempt ${attempt}/${max_retries})..."
                sleep ${retry_delay}
                retry_delay=$((retry_delay * 2))  # Exponential backoff
                continue
            else
                log_error "Rate limit exceeded after ${max_retries} attempts. Please try again later."
                return 1
            fi
        fi

        # Check for already exists error (not a failure case)
        if echo "${response}" | grep -qiE "already exists|duplicate"; then
            log_warning "Issue type '${name}' already exists (skipping)"
            return 0
        fi

        # Other errors - don't retry
        log_error "Failed to create issue type '${name}': ${response}"
        return ${exit_code}
    done

    log_error "Failed to create issue type '${name}' after ${max_retries} attempts"
    return 1
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "GitHub Issue Types Setup for RHYTHM Method"
    log_info "=========================================="

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    # Validate prerequisites
    validate_prerequisites

    # Ensure config file exists
    ensure_config_file

    # Get organization
    local org
    org=$(get_organization)
    log_info "Using organization: ${org}"

    # Check permissions
    check_org_permissions "${org}"

    # Read issue types from config
    log_info "Reading issue types from configuration..."

    if [[ ! -f "${CONFIG_FILE}" ]]; then
        log_error "Configuration file not found: ${CONFIG_FILE}"
        exit 1
    fi

    # Get existing issue types
    local existing_types
    existing_types=$(list_existing_issue_types "${org}")

    # Read issue types from config
    local issue_types_count
    issue_types_count=$(yq eval '.issue_types | length' "${CONFIG_FILE}" 2>/dev/null || echo "0")

    if [[ "${issue_types_count}" -eq 0 ]]; then
        log_error "No issue types found in configuration file"
        exit 1
    fi

    log_info "Found ${issue_types_count} issue type(s) to create"

    # Process each issue type
    local success_count=0
    local skip_count=0
    local error_count=0
    local current_index=0

    for ((i=0; i<issue_types_count; i++)); do
        current_index=$((i + 1))
        log_info "Processing ${current_index}/${issue_types_count}:"
        local name
        local description
        local color

        name=$(yq eval ".issue_types[${i}].name" "${CONFIG_FILE}" 2>/dev/null || echo "")
        description=$(yq eval ".issue_types[${i}].description" "${CONFIG_FILE}" 2>/dev/null || echo "")
        color=$(yq eval ".issue_types[${i}].color" "${CONFIG_FILE}" 2>/dev/null || echo "")

        if [[ -z "${name}" ]]; then
            log_warning "Skipping issue type at index ${i} (missing name)"
            error_count=$((error_count + 1))
            continue
        fi

        # Check if already exists
        if issue_type_exists "${org}" "${name}" "${existing_types}"; then
            log_warning "Issue type '${name}' already exists (skipping)"
            skip_count=$((skip_count + 1))
            continue
        fi

        # Create issue type
        if create_issue_type "${org}" "${name}" "${description}" "${color}"; then
            success_count=$((success_count + 1))
        else
            error_count=$((error_count + 1))
        fi
    done

    # Summary
    echo ""
    log_info "Summary:"
    log_info "  Created: ${success_count}"
    log_info "  Skipped: ${skip_count}"
    if [[ ${error_count} -gt 0 ]]; then
        log_error "  Errors: ${error_count}"
        exit 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN - No changes were made"
    else
        log_success "Issue types setup completed successfully!"
    fi
}

# Run main function
main "$@"

