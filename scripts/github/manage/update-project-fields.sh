#!/usr/bin/env bash
#
# Update Project Fields Script for RHYTHM Method
# 
# This script reads issue body metadata and updates corresponding Projects v2 custom fields.
# It parses metadata fields (Status, TEMPO, Tokens, etc.) and updates Projects v2 fields
# using the GitHub Projects v2 API.
#
# Usage:
#   ./update-project-fields.sh [OPTIONS] [--issue ISSUE_NUMBER] [--all]
#
# Options:
#   --dry-run       Preview changes without applying them
#   --verbose       Show detailed output
#   --help          Show this help message
#   --issue         Issue number to update (required if not --all)
#   --all           Update all issues in the repository
#   --repo          Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - YAML parser (yq) for parsing configuration
#   - jq or yq for JSON parsing
#
# Features:
#   - Parses metadata from issue body (Status, TEMPO, Tokens, etc.)
#   - Updates Projects v2 custom fields
#   - Uses option ID lookup for single-select fields
#   - Validates field values before updates
#   - Idempotent (safe to run multiple times)
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
UPDATE_ALL=false

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
Update Project Fields Script for RHYTHM Method

This script reads issue body metadata and updates corresponding Projects v2 custom fields.
It parses metadata fields (Status, TEMPO, Tokens, etc.) and updates Projects v2 fields
using the GitHub Projects v2 API.

USAGE:
    ${0##*/} [OPTIONS] [--issue ISSUE_NUMBER] [--all]

OPTIONS:
    --dry-run       Preview changes without applying them
    --verbose       Show detailed output
    --help          Show this help message
    --issue         Issue number to update (required if not --all)
    --all           Update all issues in the repository
    --repo          Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Update project fields for a single issue
    ${0##*/} --issue 45

    # Update project fields for all issues
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
                UPDATE_ALL=true
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

# Get project ID from field IDs file
get_project_id() {
    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        log_warning "Field IDs file not found: ${FIELD_IDS_FILE}"
        log_info "Project field updates will be skipped"
        return 1
    fi

    local project_id
    project_id=$(yq eval '.project.id // ""' "${FIELD_IDS_FILE}" 2>/dev/null || echo "")
    
    if [[ -z "${project_id}" || "${project_id}" == "null" ]]; then
        log_warning "Project ID not found in field IDs file"
        log_info "Project field updates will be skipped"
        return 1
    fi

    echo "${project_id}"
    return 0
}

# Get field ID from field IDs file
get_field_id() {
    local field_name=$1
    
    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        return 1
    fi

    local field_id
    field_id=$(yq eval ".custom_fields[] | select(.name == \"${field_name}\") | .id // \"\"" "${FIELD_IDS_FILE}" 2>/dev/null || echo "")
    
    if [[ -z "${field_id}" || "${field_id}" == "null" ]]; then
        return 1
    fi

    echo "${field_id}"
    return 0
}

# Get issue node ID (GraphQL ID) from issue number
get_issue_node_id() {
    local repo=$1
    local issue_number=$2

    local node_id
    node_id=$(gh issue view "${issue_number}" --repo "${repo}" --json id --jq '.id' 2>/dev/null || echo "")
    
    if [[ -z "${node_id}" ]]; then
        return 1
    fi

    echo "${node_id}"
    return 0
}

# Get option ID for a single-select field value
get_option_id() {
    local project_id=$1
    local field_id=$2
    local option_name=$3

    log_verbose "Querying option ID for '${option_name}' in field ${field_id}..."

    # Query all fields to find the one we need
    local response
    response=$(gh api graphql -f query="
        query {
            node(id: \"${project_id}\") {
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
    " 2>&1) || {
        log_warning "Could not query project fields: ${response}"
        return 1
    }

    # Extract option ID using jq or yq
    local option_id
    if command -v jq &> /dev/null; then
        option_id=$(echo "${response}" | jq -r ".data.node.fields.nodes[] | select(.id == \"${field_id}\") | .options[] | select(.name == \"${option_name}\") | .id" 2>/dev/null || echo "")
    elif command -v yq &> /dev/null; then
        # yq parsing for GraphQL response
        option_id=$(echo "${response}" | yq eval '.data.node.fields.nodes[] | select(.id == "'"${field_id}"'") | .options[] | select(.name == "'"${option_name}"'") | .id' - 2>/dev/null || echo "")
    fi

    if [[ -z "${option_id}" || "${option_id}" == "null" ]]; then
        log_warning "Could not find option ID for '${option_name}' in field ${field_id}"
        return 1
    fi

    echo "${option_id}"
    return 0
}

# Update Projects v2 single-select field value
update_project_single_select_field() {
    local project_id=$1
    local issue_node_id=$2
    local field_id=$3
    local field_name=$4
    local option_name=$5

    log_verbose "Updating single-select field '${field_name}' to '${option_name}'..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would update field '${field_name}' to: ${option_name}"
        return 0
    fi

    # Get option ID
    local option_id
    if ! option_id=$(get_option_id "${project_id}" "${field_id}" "${option_name}"); then
        log_warning "Could not get option ID for '${option_name}', skipping field update"
        return 1
    fi

    log_verbose "Found option ID: ${option_id}"

    # Update field value using Projects v2 GraphQL API
    local response
    response=$(gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"${project_id}\"
                itemId: \"${issue_node_id}\"
                fieldId: \"${field_id}\"
                value: {
                    singleSelectOptionId: \"${option_id}\"
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }
    " 2>&1) || {
        log_warning "Could not update field value: ${response}"
        return 1
    }

    log_verbose "Field '${field_name}' updated to '${option_name}'"
    return 0
}

# Update Projects v2 number field value
update_project_number_field() {
    local project_id=$1
    local issue_node_id=$2
    local field_id=$3
    local field_value=$4

    log_verbose "Updating number field value: ${field_value}..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would update number field to: ${field_value}"
        return 0
    fi

    # Update number field value using Projects v2 GraphQL API
    local response
    response=$(gh api graphql -f query="
        mutation {
            updateProjectV2ItemFieldValue(input: {
                projectId: \"${project_id}\"
                itemId: \"${issue_node_id}\"
                fieldId: \"${field_id}\"
                value: {
                    number: ${field_value}
                }
            }) {
                projectV2Item {
                    id
                }
            }
        }
    " 2>&1) || {
        log_warning "Could not update number field value: ${response}"
        return 1
    }

    log_verbose "Number field value updated"
    return 0
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

# Parse metadata field value from issue body
parse_metadata_field() {
    local body=$1
    local field_name=$2

    # Extract the RHYTHM Method metadata section
    local metadata_section
    metadata_section=$(echo "${body}" | sed -n '/<!-- RHYTHM Method Metadata -->/,/<!-- \/RHYTHM Method Metadata -->/p' || echo "${body}" | sed -n '/<!-- RHYTHM Method Metadata -->/,$p')

    if [[ -z "${metadata_section}" ]]; then
        return 1
    fi

    # Extract field line (format: **Field Name:** value)
    local field_line
    field_line=$(echo "${metadata_section}" | grep -i "^\*\*${field_name}:" || echo "")

    if [[ -z "${field_line}" ]]; then
        return 1
    fi

    # Extract value (remove **Field Name:** prefix and trim)
    local value
    value=$(echo "${field_line}" | sed -E "s/^\*\*${field_name}:\*\*\s*//" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' || echo "")

    if [[ -z "${value}" || "${value}" == "[updated during execution]" || "${value}" == "[count]" ]]; then
        return 1
    fi

    echo "${value}"
    return 0
}

# Normalize status value
normalize_status() {
    local status=$1
    case "${status,,}" in
        planned|plan)
            echo "Planned"
            ;;
        in-progress|inprogress|progress)
            echo "In Progress"
            ;;
        review)
            echo "Review"
            ;;
        blocked)
            echo "Blocked"
            ;;
        completed|complete|done)
            echo "Completed"
            ;;
        failed|failure)
            echo "Failed"
            ;;
        *)
            echo "${status}"
            ;;
    esac
}

# Normalize TEMPO value
normalize_tempo() {
    local tempo=$1
    case "${tempo,,}" in
        high)
            echo "High"
            ;;
        moderate|mod)
            echo "Moderate"
            ;;
        controlled|control)
            echo "Controlled"
            ;;
        *)
            echo "${tempo}"
            ;;
    esac
}

# Check if issue is in project
is_issue_in_project() {
    local project_id=$1
    local issue_node_id=$2

    log_verbose "Checking if issue is in project..."

    # Query project to see if issue is a member
    local response
    response=$(gh api graphql -f query="
        query {
            node(id: \"${project_id}\") {
                ... on ProjectV2 {
                    items(first: 100) {
                        nodes {
                            content {
                                ... on Issue {
                                    id
                                }
                            }
                        }
                    }
                }
            }
        }
    " 2>&1) || {
        # If query fails, assume issue might not be in project
        return 1
    }

    # Check if issue node ID is in the response
    if echo "${response}" | grep -q "${issue_node_id}"; then
        return 0
    fi

    return 1
}

# Add issue to project if not already added
ensure_issue_in_project() {
    local project_id=$1
    local issue_node_id=$2

    if is_issue_in_project "${project_id}" "${issue_node_id}"; then
        log_verbose "Issue is already in project"
        return 0
    fi

    log_verbose "Adding issue to project..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would add issue to project"
        return 0
    fi

    # Add issue to project using Projects v2 API
    local response
    response=$(gh api graphql -f query="
        mutation {
            addProjectV2ItemById(input: {
                projectId: \"${project_id}\"
                contentId: \"${issue_node_id}\"
            }) {
                item {
                    id
                }
            }
        }
    " 2>&1) || {
        log_warning "Could not add issue to project (may already be added): ${response}"
        return 1
    }

    log_verbose "Issue added to project"
    return 0
}

# Update project fields for a single issue
update_issue_project_fields() {
    local repo=$1
    local issue_number=$2
    local project_id=$3

    log_info "Updating project fields for issue #${issue_number}..."

    # Get issue node ID
    local issue_node_id
    if ! issue_node_id=$(get_issue_node_id "${repo}" "${issue_number}"); then
        log_warning "Skipping issue #${issue_number} - cannot get node ID"
        return 1
    fi

    # Ensure issue is in project
    ensure_issue_in_project "${project_id}" "${issue_node_id}" || true

    # Get issue body
    local body
    if ! body=$(get_issue_body "${repo}" "${issue_number}"); then
        log_warning "Skipping issue #${issue_number} - cannot read body"
        return 1
    fi

    local updated_count=0

    # Update Status field
    local status_value
    if status_value=$(parse_metadata_field "${body}" "Status"); then
        status_value=$(normalize_status "${status_value}")
        local status_field_id
        if status_field_id=$(get_field_id "Status"); then
            if update_project_single_select_field "${project_id}" "${issue_node_id}" "${status_field_id}" "Status" "${status_value}"; then
                ((updated_count++))
            fi
        fi
    fi

    # Update TEMPO field (for Features and Work Units)
    local tempo_value
    if tempo_value=$(parse_metadata_field "${body}" "TEMPO"); then
        tempo_value=$(normalize_tempo "${tempo_value}")
        local tempo_field_id
        if tempo_field_id=$(get_field_id "TEMPO"); then
            if update_project_single_select_field "${project_id}" "${issue_node_id}" "${tempo_field_id}" "TEMPO" "${tempo_value}"; then
                ((updated_count++))
            fi
        fi
    fi

    # Update Estimated Tokens field
    local estimated_tokens
    if estimated_tokens=$(parse_metadata_field "${body}" "Estimated Tokens"); then
        # Validate it's a number
        if [[ "${estimated_tokens}" =~ ^[0-9]+$ ]]; then
            local tokens_field_id
            if tokens_field_id=$(get_field_id "Estimated Tokens"); then
                if update_project_number_field "${project_id}" "${issue_node_id}" "${tokens_field_id}" "${estimated_tokens}"; then
                    ((updated_count++))
                fi
            fi
        fi
    fi

    # Update Actual Tokens field
    local actual_tokens
    if actual_tokens=$(parse_metadata_field "${body}" "Actual Tokens"); then
        # Validate it's a number
        if [[ "${actual_tokens}" =~ ^[0-9]+$ ]]; then
            local actual_tokens_field_id
            if actual_tokens_field_id=$(get_field_id "Actual Tokens"); then
                if update_project_number_field "${project_id}" "${issue_node_id}" "${actual_tokens_field_id}" "${actual_tokens}"; then
                    ((updated_count++))
                fi
            fi
        fi
    fi

    # Update Assigned Agent field (for Agent Tasks)
    local assigned_agent
    if assigned_agent=$(parse_metadata_field "${body}" "Assigned Agent"); then
        local assigned_agent_field_id
        if assigned_agent_field_id=$(get_field_id "Assigned Agent"); then
            if update_project_single_select_field "${project_id}" "${issue_node_id}" "${assigned_agent_field_id}" "Assigned Agent" "${assigned_agent}"; then
                ((updated_count++))
            fi
        fi
    fi

    # Update Severity field (for Bugs)
    local severity
    if severity=$(parse_metadata_field "${body}" "Severity"); then
        # Normalize severity
        case "${severity,,}" in
            critical)
                severity="Critical"
                ;;
            high)
                severity="High"
                ;;
            medium)
                severity="Medium"
                ;;
            low)
                severity="Low"
                ;;
        esac
        local severity_field_id
        if severity_field_id=$(get_field_id "Severity"); then
            if update_project_single_select_field "${project_id}" "${issue_node_id}" "${severity_field_id}" "Severity" "${severity}"; then
                ((updated_count++))
            fi
        fi
    fi

    if [[ ${updated_count} -gt 0 ]]; then
        log_success "Updated ${updated_count} fields for issue #${issue_number}"
    else
        log_info "No fields to update for issue #${issue_number}"
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

    log_info "Update Project Fields Script for RHYTHM Method"
    log_info "=============================================="

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

    # Get project ID
    local project_id
    if ! project_id=$(get_project_id); then
        log_error "Project not configured. Please run setup scripts first."
        exit 1
    fi
    log_verbose "Using project ID: ${project_id}"

    # Validate parameters
    if [[ "${UPDATE_ALL}" != "true" && -z "${ISSUE_NUMBER}" ]]; then
        log_error "Either --issue or --all must be specified"
        show_help
        exit 2
    fi

    if [[ "${UPDATE_ALL}" == "true" && -n "${ISSUE_NUMBER}" ]]; then
        log_error "Cannot specify both --issue and --all"
        show_help
        exit 2
    fi

    # Update project fields
    if [[ "${UPDATE_ALL}" == "true" ]]; then
        log_info "Updating project fields for all issues..."
        
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
            if update_issue_project_fields "${repo}" "${issue_num}" "${project_id}"; then
                ((success++))
            else
                ((skipped++))
            fi
        done <<< "${all_issues}"

        log_info "Update complete: ${success} updated, ${skipped} skipped, ${total} total"
    else
        update_issue_project_fields "${repo}" "${ISSUE_NUMBER}" "${project_id}"
    fi

    log_success "Script completed."
}

# Run main function
main "$@"

