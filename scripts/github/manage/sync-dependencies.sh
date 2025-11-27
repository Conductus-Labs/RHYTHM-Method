#!/usr/bin/env bash
#
# Sync Dependencies Script for RHYTHM Method
# 
# This script reads issue body metadata and syncs dependencies to native GitHub Issue Dependencies.
# It parses the "Dependencies:" field from the RHYTHM Method metadata section and creates
# "blocked by" relationships using GitHub CLI.
#
# Usage:
#   ./sync-dependencies.sh [OPTIONS] [--issue ISSUE_NUMBER] [--all]
#
# Options:
#   --dry-run       Preview changes without applying them
#   --verbose       Show detailed output
#   --help          Show this help message
#   --issue         Issue number to sync (required if not --all)
#   --all           Sync all issues in the repository
#   --repo          Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - YAML parser (yq) for parsing configuration (optional)
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

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONFIG_FILE="${REPO_ROOT}/.baton/github-config.yml"
FIELD_IDS_FILE="${REPO_ROOT}/.baton/github-field-ids.yml"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false
SYNC_ALL=false

# Parameters
ISSUE_NUMBER=""
REPO=""

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
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Show help message
show_help() {
    cat << EOF
Sync Dependencies Script for RHYTHM Method

This script reads issue body metadata and syncs dependencies to native GitHub Issue Dependencies.
It parses the "Dependencies:" field from the RHYTHM Method metadata section and creates
"blocked by" relationships using GitHub CLI.

USAGE:
    ${0##*/} [OPTIONS] [--issue ISSUE_NUMBER] [--all]

OPTIONS:
    --dry-run       Preview changes without applying them
    --verbose       Show detailed output
    --help          Show this help message
    --issue         Issue number to sync (required if not --all)
    --all           Sync all issues in the repository
    --repo          Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Sync dependencies for a single issue
    ${0##*/} --issue 45

    # Sync dependencies for all issues
    ${0##*/} --all

    # Preview changes (dry-run)
    ${0##*/} --issue 45 --dry-run

    # Verbose output
    ${0##*/} --issue 45 --verbose

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
            --issue)
                ISSUE_NUMBER="$2"
                shift 2
                ;;
            --all)
                SYNC_ALL=true
                shift
                ;;
            --repo)
                REPO="$2"
                shift 2
                ;;
            *)
                log_error "Unknown option: $1"
                show_help
                exit 2
                ;;
        esac
    done
}

# Check prerequisites
check_prerequisites() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI (gh) is not installed"
        log_info "Install from: https://cli.github.com/"
        exit 1
    fi

    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_info "Run: gh auth login"
        exit 1
    fi
}

# Get repository
get_repository() {
    if [[ -n "${REPO}" ]]; then
        echo "${REPO}"
        return 0
    fi

    # Try to get from config file
    if [[ -f "${CONFIG_FILE}" ]] && command -v yq &> /dev/null; then
        local config_repo
        config_repo=$(yq eval '.github.repository // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${config_repo}" && "${config_repo}" != "null" ]]; then
            log_verbose "Using repository from config: ${config_repo}"
            echo "${config_repo}"
            return 0
        fi
    fi

    # Try auto-detection
    local detected_repo
    detected_repo=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null || echo "")
    
    if [[ -n "${detected_repo}" ]]; then
        log_verbose "Auto-detected repository: ${detected_repo}"
        echo "${detected_repo}"
        return 0
    fi

    log_error "Could not determine repository"
    log_info "Please provide --repo org/repo or ensure you're in a git repository"
    return 1
}

# Get issue body
get_issue_body() {
    local repo=$1
    local issue_number=$2

    local body
    body=$(gh issue view "${issue_number}" --repo "${repo}" --json body --jq '.body' 2>/dev/null || echo "")
    
    if [[ -z "${body}" || "${body}" == "null" ]]; then
        log_warning "Issue #${issue_number} has no body or is not accessible"
        return 1
    fi

    echo "${body}"
    return 0
}

# Parse dependencies from issue body metadata
parse_dependencies_from_metadata() {
    local body=$1

    # Extract the RHYTHM Method metadata section
    local metadata_section
    metadata_section=$(echo "${body}" | sed -n '/<!-- RHYTHM Method Metadata -->/,/<!-- \/RHYTHM Method Metadata -->/p' || echo "${body}" | sed -n '/<!-- RHYTHM Method Metadata -->/,$p')

    if [[ -z "${metadata_section}" ]]; then
        log_verbose "No RHYTHM Method metadata section found"
        return 1
    fi

    # Extract Dependencies line
    local dependencies_line
    dependencies_line=$(echo "${metadata_section}" | grep -i "^\*\*Dependencies:" || echo "")

    if [[ -z "${dependencies_line}" ]]; then
        log_verbose "No Dependencies field found in metadata"
        return 1
    fi

    # Extract issue numbers (format: #123, #456, etc.)
    # Remove "**Dependencies:" prefix and extract #numbers
    local issue_numbers
    issue_numbers=$(echo "${dependencies_line}" | sed -E 's/^\*\*Dependencies:\*\*\s*//' | grep -oE '#[0-9]+' | sed 's/#//' || echo "")

    if [[ -z "${issue_numbers}" ]]; then
        log_verbose "No issue numbers found in Dependencies field"
        return 1
    fi

    # Return space-separated list of issue numbers
    echo "${issue_numbers}"
    return 0
}

# Get existing blocked-by dependencies
get_existing_blocked_by() {
    local repo=$1
    local issue_number=$2

    local blocked_by
    blocked_by=$(gh issue view "${issue_number}" --repo "${repo}" --json blockedBy --jq '.blockedBy[].number // empty' 2>/dev/null || echo "")
    
    if [[ -z "${blocked_by}" ]]; then
        echo ""
        return 0
    fi

    # Return space-separated list
    echo "${blocked_by}"
    return 0
}

# Set issue dependency (blocked by) using GitHub REST API
# Note: This endpoint may return 404 if not available for the repository/organization
set_issue_dependency() {
    local repo=$1
    local issue_number=$2
    local blocked_by_issue=$3

    log_verbose "Setting dependency: issue #${issue_number} blocked by #${blocked_by_issue}..."

    # Parse owner and repo name
    local owner
    local repo_name
    owner=$(echo "${repo}" | cut -d'/' -f1)
    repo_name=$(echo "${repo}" | cut -d'/' -f2)

    # Get blocked-by issue ID (numeric ID, not issue number)
    local blocked_by_issue_id
    blocked_by_issue_id=$(gh api "repos/${owner}/${repo_name}/issues/${blocked_by_issue}" --jq '.id' 2>/dev/null || echo "")
    
    if [[ -z "${blocked_by_issue_id}" || "${blocked_by_issue_id}" == "null" ]]; then
        log_warning "Could not get issue ID for blocked-by issue #${blocked_by_issue}"
        return 1
    fi

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
    local response
    response=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        "repos/${owner}/${repo_name}/issues/${issue_number}/dependencies" \
        -F "blocked_by_issue_id=${blocked_by_issue_id}" \
        2>&1)
    local exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        log_success "Set dependency: #${issue_number} is now blocked by #${blocked_by_issue}"
        return 0
    else
        # Check for 404 - endpoint may not be available
        if echo "${response}" | grep -qiE "404|Not Found"; then
            log_warning "Dependency API endpoint not available (404) for issue #${issue_number}"
            log_verbose "The GitHub REST API endpoint for dependencies is not available for this repository."
            log_verbose "Dependencies are stored in issue body metadata and can be set manually via GitHub web UI."
            return 1
        # Check if dependency already exists or other expected errors
        elif echo "${response}" | grep -qiE "already exists|duplicate|422"; then
            log_verbose "Dependency already exists: #${issue_number} is already blocked by #${blocked_by_issue}"
            return 0
        else
            log_warning "Could not set dependency: #${issue_number} blocked by #${blocked_by_issue}"
            log_verbose "Error: ${response}"
            return 1
        fi
    fi
}

# Sync dependencies for a single issue
sync_issue_dependencies() {
    local repo=$1
    local issue_number=$2

    log_info "Syncing dependencies for issue #${issue_number}..."

    # Get issue body
    local body
    if ! body=$(get_issue_body "${repo}" "${issue_number}"); then
        log_warning "Skipping issue #${issue_number} - cannot read body"
        return 1
    fi

    # Parse dependencies from metadata
    local metadata_deps
    if ! metadata_deps=$(parse_dependencies_from_metadata "${body}"); then
        log_verbose "Issue #${issue_number} has no dependencies in metadata"
        return 0
    fi

    log_verbose "Found dependencies in metadata: ${metadata_deps}"

    # Get existing dependencies
    local existing_deps
    existing_deps=$(get_existing_blocked_by "${repo}" "${issue_number}")

    log_verbose "Existing blocked-by dependencies: ${existing_deps:-none}"

    # Convert to arrays for comparison
    local -a metadata_array
    read -ra metadata_array <<< "${metadata_deps}"

    local -a existing_array
    if [[ -n "${existing_deps}" ]]; then
        read -ra existing_array <<< "${existing_deps}"
    else
        existing_array=()
    fi

    # Find dependencies to add
    local added_count=0
    for dep in "${metadata_array[@]}"; do
        # Check if dependency already exists
        local exists=false
        for existing in "${existing_array[@]}"; do
            if [[ "${dep}" == "${existing}" ]]; then
                exists=true
                break
            fi
        done

        if [[ "${exists}" == "false" ]]; then
            if [[ "${DRY_RUN}" == "true" ]]; then
                log_info "[DRY RUN] Would add dependency: issue #${issue_number} blocked by #${dep}"
            else
                log_verbose "Adding dependency: issue #${issue_number} blocked by #${dep}"
                
                # Validate dependency issue exists
                local dep_exists
                if dep_exists=$(gh issue view "${dep}" --repo "${repo}" --json number 2>/dev/null); then
                    # Use REST API to set dependency (gh issue edit --add-blocked-by doesn't exist)
                    if set_issue_dependency "${repo}" "${issue_number}" "${dep}"; then
                        ((added_count++))
                    else
                        # Dependency setting failed (likely 404 - API not available)
                        # Dependencies are still recorded in issue body metadata
                        log_verbose "Dependency will remain in issue body metadata for manual processing"
                    fi
                else
                    log_warning "Dependency issue #${dep} does not exist, skipping"
                fi
            fi
        else
            log_verbose "Dependency already exists: #${issue_number} blocked by #${dep}"
        fi
    done

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would add ${#metadata_array[@]} dependencies for issue #${issue_number}"
    elif [[ ${added_count} -gt 0 ]]; then
        log_success "Added ${added_count} dependencies for issue #${issue_number}"
    else
        log_info "All dependencies already synced for issue #${issue_number}"
    fi

    return 0
}

# Get all issues in repository
get_all_issues() {
    local repo=$1

    log_verbose "Fetching all issues from repository..."

    local issues
    issues=$(gh issue list --repo "${repo}" --json number --jq '.[].number' 2>/dev/null || echo "")
    
    if [[ -z "${issues}" ]]; then
        log_warning "No issues found in repository"
        return 1
    fi

    echo "${issues}"
    return 0
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "Sync Dependencies Script for RHYTHM Method"
    log_info "==========================================="

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    check_prerequisites

    # Get repository
    local repo
    if ! repo=$(get_repository); then
        exit 1
    fi
    log_info "Using repository: ${repo}"

    # Validate parameters
    if [[ "${SYNC_ALL}" != "true" && -z "${ISSUE_NUMBER}" ]]; then
        log_error "Either --issue or --all must be specified"
        show_help
        exit 2
    fi

    if [[ "${SYNC_ALL}" == "true" && -n "${ISSUE_NUMBER}" ]]; then
        log_error "Cannot specify both --issue and --all"
        show_help
        exit 2
    fi

    # Sync dependencies
    if [[ "${SYNC_ALL}" == "true" ]]; then
        log_info "Syncing dependencies for all issues..."
        
        local all_issues
        if ! all_issues=$(get_all_issues "${repo}"); then
            log_error "Failed to get list of issues"
            exit 1
        fi

        local total=0
        local success=0
        local skipped=0

        while IFS= read -r issue_num; do
            ((total++))
            if sync_issue_dependencies "${repo}" "${issue_num}"; then
                ((success++))
            else
                ((skipped++))
            fi
        done <<< "${all_issues}"

        log_info "Sync complete: ${success} synced, ${skipped} skipped, ${total} total"
    else
        sync_issue_dependencies "${repo}" "${ISSUE_NUMBER}"
    fi

    log_success "Script completed."
}

# Run main function
main "$@"

