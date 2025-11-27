#!/usr/bin/env bash
#
# Create GitHub Feature Issue for RHYTHM Method
# 
# This script creates a Feature issue with proper issue type, Projects v2 fields,
# and metadata using GitHub CLI.
#
# Usage:
#   ./create-feature.sh [OPTIONS] [--title TITLE] [--description DESC] [--body-file FILE] [--tempo TEMPO] [--tokens TOKENS] [--dependencies DEPS]
#
# Options:
#   --dry-run       Preview changes without applying them
#   --verbose       Show detailed output
#   --help          Show this help message
#   --title         Issue title (required if not interactive)
#   --description   Issue description (required if not interactive)
#   --body-file     Path to issue body file (alternative to --description)
#   --tempo         TEMPO level (High, Moderate, Controlled) - default: Moderate
#   --tokens        Estimated tokens (number)
#   --dependencies  Comma-separated list of issue numbers this depends on (e.g., "45,46")
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - YAML parser (yq) for parsing configuration
#
# Features:
#   - Interactive mode (default) or parameter-based mode
#   - Creates issue with "Feature" issue type
#   - Sets Projects v2 custom fields (Status, TEMPO, Estimated Tokens)
#   - Links issue to Project if configured
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
TEMPLATE_FILE="${REPO_ROOT}/.github/ISSUE_TEMPLATE/feature.yml"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false
INTERACTIVE=true

# Issue parameters
ISSUE_TITLE=""
ISSUE_DESCRIPTION=""
ISSUE_BODY_FILE=""
TEMPO_LEVEL="Moderate"
ESTIMATED_TOKENS=""
DEPENDENCIES=""

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
Create GitHub Feature Issue for RHYTHM Method

This script creates a Feature issue with proper issue type, Projects v2 fields,
and metadata using GitHub CLI.

USAGE:
    ${0##*/} [OPTIONS] [--title TITLE] [--description DESC] [--body-file FILE] [--tempo TEMPO] [--tokens TOKENS] [--dependencies DEPS]

OPTIONS:
    --dry-run       Preview changes without applying them
    --verbose       Show detailed output
    --help          Show this help message

PARAMETERS (for non-interactive mode):
    --title         Issue title (required if not interactive)
    --description   Issue description (required if not interactive)
    --body-file     Path to issue body file (alternative to --description)
    --tempo         TEMPO level (High, Moderate, Controlled) - default: Moderate
    --tokens        Estimated tokens (number)
    --dependencies  Comma-separated list of issue numbers this depends on (e.g., "45,46")

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository write permissions
    - YAML parser (yq) for parsing configuration

EXAMPLES:
    # Interactive mode
    ${0##*/}

    # Non-interactive mode
    ${0##*/} --title "User Authentication" --description "Implement user authentication system" --tempo High --tokens 5000

    # With dependencies
    ${0##*/} --title "Feature" --description "Description" --dependencies "45,46"

    # Preview changes
    ${0##*/} --title "Feature" --description "Description" --dry-run

    # Verbose output
    ${0##*/} --title "Feature" --description "Description" --verbose
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
            --title)
                ISSUE_TITLE="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --description)
                ISSUE_DESCRIPTION="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --body-file)
                ISSUE_BODY_FILE="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --tempo)
                TEMPO_LEVEL="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --tokens)
                ESTIMATED_TOKENS="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --dependencies)
                DEPENDENCIES="$2"
                INTERACTIVE=false
                shift 2
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
        exit 1
    fi

    # Check for yq
    if ! command -v yq &> /dev/null; then
        log_error "YAML parser (yq) is not installed"
        log_info "Install from: https://github.com/mikefarah/yq"
        exit 1
    fi

    # Check authentication
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_info "Run: gh auth login"
        exit 1
    fi

    log_verbose "Prerequisites validated"
}

# Get repository from config or auto-detect
get_repository() {
    local repo

    # Try to read from config file
    if [[ -f "${CONFIG_FILE}" ]]; then
        repo=$(yq eval '.github.repository // ""' "${CONFIG_FILE}" 2>/dev/null || echo "")
        if [[ -n "${repo}" && "${repo}" != "null" ]]; then
            log_verbose "Repository from config: ${repo}"
            echo "${repo}"
            return 0
        fi
    fi

    # Try auto-detection
    if repo=$(gh repo view --json owner,name --jq '.owner.login + "/" + .name' 2>/dev/null); then
        log_verbose "Auto-detected repository: ${repo}"
        echo "${repo}"
        return 0
    fi

    log_error "Could not determine repository"
    return 1
}

# Get project ID from field IDs file
get_project_id() {
    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        log_warning "Field IDs file not found: ${FIELD_IDS_FILE}"
        log_info "Project linking will be skipped"
        return 1
    fi

    local project_id
    project_id=$(yq eval '.project.id // ""' "${FIELD_IDS_FILE}" 2>/dev/null || echo "")
    
    if [[ -z "${project_id}" || "${project_id}" == "null" ]]; then
        log_warning "Project ID not found in field IDs file"
        log_info "Project linking will be skipped"
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

# Set issue dependency (blocked by) using GitHub REST API
set_issue_dependency() {
    local repo=$1
    local issue_number=$2
    local blocked_by_issue=$3

    log_verbose "Setting dependency: issue #${issue_number} blocked by #${blocked_by_issue}..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would set dependency: #${issue_number} blocked by #${blocked_by_issue}"
        return 0
    fi

    # GitHub Issue Dependencies API - set blocked-by relationship
    # Uses REST API: POST /repos/{owner}/{repo}/issues/{issue_number}/dependencies
    local owner
    local repo_name
    owner=$(echo "${repo}" | cut -d'/' -f1)
    repo_name=$(echo "${repo}" | cut -d'/' -f2)

    local response
    response=$(gh api \
        --method POST \
        -H "Accept: application/vnd.github+json" \
        "repos/${owner}/${repo_name}/issues/${issue_number}/dependencies" \
        -f "blocked_by[]=${blocked_by_issue}" \
        2>&1)
    local exit_code=$?

    if [[ ${exit_code} -eq 0 ]]; then
        log_verbose "Dependency set successfully: #${issue_number} blocked by #${blocked_by_issue}"
        return 0
    else
        # Check if dependency already exists (might return 422 or other error)
        if echo "${response}" | grep -qiE "already exists|duplicate|422"; then
            log_verbose "Dependency already exists: #${issue_number} blocked by #${blocked_by_issue}"
            return 0
        else
            log_warning "Could not set dependency: #${issue_number} blocked by #${blocked_by_issue}"
            log_verbose "Error: ${response}"
            return 1
        fi
    fi
}

# Add issue to project
add_issue_to_project() {
    local project_id=$1
    local issue_node_id=$2

    log_verbose "Adding issue to project ${project_id}..."

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_verbose "[DRY RUN] Would add issue to project"
        return 0
    fi

    # Add issue to project using Projects v2 API
    # Note: This uses the GraphQL API via gh api
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

# Get option ID for a single-select field value
get_option_id() {
    local project_id=$1
    local field_id=$2
    local option_name=$3

    log_verbose "Querying option ID for '${option_name}' in field ${field_id}..."

    # Query field options using GraphQL API
    local response
    response=$(gh api graphql -f query="
        query {
            node(id: \"${project_id}\") {
                ... on ProjectV2 {
                    field(name: \"\") {
                        ... on ProjectV2SingleSelectField {
                            id
                            options {
                                id
                                name
                            }
                        }
                    }
                }
            }
        }
    " 2>&1) || {
        log_warning "Could not query field options: ${response}"
        return 1
    }

    # Query all fields to find the one we need
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

# Interactive prompt for issue details
prompt_issue_details() {
    log_info "Enter Feature details:"
    echo

    # Title
    while [[ -z "${ISSUE_TITLE}" ]]; do
        read -p "Feature title: " ISSUE_TITLE
        if [[ -z "${ISSUE_TITLE}" ]]; then
            log_error "Title is required"
        fi
    done

    # Description
    if [[ -z "${ISSUE_DESCRIPTION}" && -z "${ISSUE_BODY_FILE}" ]]; then
        log_info "Enter feature description (end with Ctrl+D or empty line):"
        ISSUE_DESCRIPTION=$(cat)
    fi

    # TEMPO
    log_info "TEMPO level:"
    echo "  1) High"
    echo "  2) Moderate (default)"
    echo "  3) Controlled"
    read -p "Select [2]: " tempo_choice
    case "${tempo_choice:-2}" in
        1) TEMPO_LEVEL="High" ;;
        2) TEMPO_LEVEL="Moderate" ;;
        3) TEMPO_LEVEL="Controlled" ;;
        *) TEMPO_LEVEL="Moderate" ;;
    esac

    # Estimated tokens
    read -p "Estimated tokens (optional): " ESTIMATED_TOKENS

    # Dependencies
    read -p "Dependencies (comma-separated issue numbers, e.g., 45,46): " DEPENDENCIES
}

# Create issue body with metadata
create_issue_body() {
    local body_content=""
    
    if [[ -n "${ISSUE_BODY_FILE}" && -f "${ISSUE_BODY_FILE}" ]]; then
        body_content=$(cat "${ISSUE_BODY_FILE}")
    elif [[ -n "${ISSUE_DESCRIPTION}" ]]; then
        body_content="${ISSUE_DESCRIPTION}"
    else
        log_error "No issue body content provided"
        return 1
    fi

    # Append RHYTHM Method metadata
    body_content="${body_content}

---

<!-- RHYTHM Method Metadata -->
**Feature ID:** feat-XXX (auto-generated)
**Parent:** Project Manifest (.baton/project.manifest.md)
**Status:** planned
**TEMPO:** ${TEMPO_LEVEL}
**Priority Level:** level-0 (calculated from dependencies)
**Estimated Tokens:** ${ESTIMATED_TOKENS:-}
**Actual Tokens:** [updated during execution]
**Work Units:** [count] (linked issues)"

    echo "${body_content}"
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "Create GitHub Feature Issue for RHYTHM Method"
    log_info "=============================================="

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    # Validate prerequisites
    validate_prerequisites

    # Get repository
    local repo
    if ! repo=$(get_repository); then
        exit 1
    fi
    log_info "Using repository: ${repo}"

    # Interactive mode
    if [[ "${INTERACTIVE}" == "true" ]]; then
        prompt_issue_details
    fi

    # Validate required fields
    if [[ -z "${ISSUE_TITLE}" ]]; then
        log_error "Issue title is required"
        exit 2
    fi

    if [[ -z "${ISSUE_DESCRIPTION}" && -z "${ISSUE_BODY_FILE}" ]]; then
        log_error "Issue description or body file is required"
        exit 2
    fi

    # Create issue body
    local issue_body
    if ! issue_body=$(create_issue_body); then
        exit 1
    fi

    # Create temporary file for issue body
    local body_file
    body_file=$(mktemp)
    echo "${issue_body}" > "${body_file}"

    log_info "Creating Feature issue..."
    log_verbose "Title: ${ISSUE_TITLE}"
    log_verbose "TEMPO: ${TEMPO_LEVEL}"
    log_verbose "Estimated Tokens: ${ESTIMATED_TOKENS:-none}"

    # Create issue
    local issue_number
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create issue:"
        log_info "  Title: ${ISSUE_TITLE}"
        log_info "  Type: Feature"
        log_info "  Body: (see ${body_file})"
        if [[ -n "${DEPENDENCIES}" ]]; then
            log_info "  Dependencies: ${DEPENDENCIES}"
        fi
        rm -f "${body_file}"
        exit 0
    fi

    # Build gh issue create command
    # Note: --type flag doesn't exist in GitHub CLI
    # Issue type must be set via Projects v2 API after creation or via web UI
    local create_cmd=(
        gh issue create
        --repo "${repo}"
        --title "${ISSUE_TITLE}"
        --body-file "${body_file}"
    )

    # Note: Dependencies will be set after creation using gh issue edit
    # (gh issue create doesn't support --add-blocked-by flag)

    # Execute command
    # gh issue create outputs URL format: https://github.com/owner/repo/issues/123
    local create_output
    create_output=$( "${create_cmd[@]}" 2>&1 )
    local create_exit=$?
    
    if [[ ${create_exit} -ne 0 ]]; then
        log_error "Failed to create issue: ${create_output}"
        rm -f "${body_file}"
        exit 1
    fi
    
    # Extract issue number from URL format: /issues/123 or #123
    issue_number=$(echo "${create_output}" | grep -oE '(/issues/[0-9]+|#[0-9]+)' | grep -oE '[0-9]+' | head -1 || echo "")

    if [[ -z "${issue_number}" ]]; then
        log_error "Failed to parse issue number from output: ${create_output}"
        rm -f "${body_file}"
        exit 1
    fi

    log_success "Created Feature issue #${issue_number}"

    # Set dependencies after creation (gh issue create doesn't support --add-blocked-by)
    # Note: gh issue edit also doesn't support --add-blocked-by, so we use REST API directly
    if [[ "${DRY_RUN}" != "true" && -n "${DEPENDENCIES}" ]]; then
        IFS=',' read -ra DEPS <<< "${DEPENDENCIES}"
        for dep in "${DEPS[@]}"; do
            dep=$(echo "${dep}" | xargs)  # Trim whitespace
            if [[ -n "${dep}" ]]; then
                set_issue_dependency "${repo}" "${issue_number}" "${dep}" || true
            fi
        done
    fi

    # Clean up
    rm -f "${body_file}"

    # Link to project and update fields
    local project_id
    if project_id=$(get_project_id); then
        log_info "Linking issue to project and updating fields..."

        # Get issue node ID
        local issue_node_id
        if issue_node_id=$(get_issue_node_id "${repo}" "${issue_number}"); then
            # Add to project
            add_issue_to_project "${project_id}" "${issue_node_id}"

            # Update Status field (set to "Planned")
            local status_field_id
            if status_field_id=$(get_field_id "Status"); then
                update_project_single_select_field "${project_id}" "${issue_node_id}" "${status_field_id}" "Status" "Planned" || true
            fi

            # Update TEMPO field
            local tempo_field_id
            if tempo_field_id=$(get_field_id "TEMPO"); then
                update_project_single_select_field "${project_id}" "${issue_node_id}" "${tempo_field_id}" "TEMPO" "${TEMPO_LEVEL}" || true
            fi

            # Update Estimated Tokens field
            if [[ -n "${ESTIMATED_TOKENS}" ]]; then
                local tokens_field_id
                if tokens_field_id=$(get_field_id "Estimated Tokens"); then
                    update_project_number_field "${project_id}" "${issue_node_id}" "${tokens_field_id}" "${ESTIMATED_TOKENS}" || true
                fi
            fi
        fi
    fi

    log_success "Feature issue #${issue_number} created successfully"
    log_info "View issue: https://github.com/${repo}/issues/${issue_number}"
}

# Run main function
main "$@"

