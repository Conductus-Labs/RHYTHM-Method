#!/usr/bin/env bash
#
# Create GitHub Bug Issue for RHYTHM Method
# 
# This script creates a Bug issue with proper issue type, relationship type (parented/related),
# Projects v2 fields, and metadata using GitHub CLI.
#
# Usage:
#   ./create-bug.sh [OPTIONS] [--title TITLE] [--description DESC] [--body-file FILE] [--relationship TYPE] [--parent-work-unit PARENT] [--related-feature FEATURE] [--severity SEVERITY] [--steps STEPS] [--expected EXPECTED] [--actual ACTUAL]
#
# Options:
#   --dry-run           Preview changes without applying them
#   --verbose           Show detailed output
#   --help              Show this help message
#   --title             Bug title (required if not interactive)
#   --description       Bug description (required if not interactive)
#   --body-file         Path to issue body file (alternative to --description)
#   --relationship      Relationship type: "parented" or "related" (required if not interactive)
#   --parent-work-unit  Parent Work Unit issue number (required if relationship is "parented")
#   --related-feature   Related Feature issue number (required if relationship is "related")
#   --severity          Severity level: Critical, High, Medium, Low (required if not interactive)
#   --steps             Steps to reproduce (optional)
#   --expected          Expected behavior (optional)
#   --actual            Actual behavior (optional)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Repository write permissions
#   - YAML parser (yq) for parsing configuration
#
# Features:
#   - Interactive mode (default) or parameter-based mode
#   - Creates issue with "Bug" issue type
#   - Sets relationship type (parented to Work Unit or related to Feature)
#   - Sets native dependency if parented to work unit
#   - Sets Projects v2 custom fields (Status, Bug Relationship, Severity)
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
TEMPLATE_FILE="${REPO_ROOT}/.github/ISSUE_TEMPLATE/bug.yml"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false
INTERACTIVE=true

# Issue parameters
ISSUE_TITLE=""
ISSUE_DESCRIPTION=""
ISSUE_BODY_FILE=""
BUG_RELATIONSHIP=""
PARENT_WORK_UNIT=""
RELATED_FEATURE=""
SEVERITY=""
STEPS_TO_REPRODUCE=""
EXPECTED_BEHAVIOR=""
ACTUAL_BEHAVIOR=""

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
Create GitHub Bug Issue for RHYTHM Method

This script creates a Bug issue with proper issue type, relationship type (parented/related),
Projects v2 fields, and metadata using GitHub CLI.

USAGE:
    ${0##*/} [OPTIONS] [--title TITLE] [--description DESC] [--body-file FILE] [--relationship TYPE] [--parent-work-unit PARENT] [--related-feature FEATURE] [--severity SEVERITY] [--steps STEPS] [--expected EXPECTED] [--actual ACTUAL]

OPTIONS:
    --dry-run           Preview changes without applying them
    --verbose           Show detailed output
    --help              Show this help message

PARAMETERS (for non-interactive mode):
    --title             Bug title (required if not interactive)
    --description       Bug description (required if not interactive)
    --body-file         Path to issue body file (alternative to --description)
    --relationship      Relationship type: "parented" or "related" (required if not interactive)
    --parent-work-unit  Parent Work Unit issue number (required if relationship is "parented")
    --related-feature   Related Feature issue number (required if relationship is "related")
    --severity          Severity level: Critical, High, Medium, Low (required if not interactive)
    --steps             Steps to reproduce (optional)
    --expected          Expected behavior (optional)
    --actual            Actual behavior (optional)

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Repository write permissions
    - YAML parser (yq) for parsing configuration

EXAMPLES:
    # Interactive mode
    ${0##*/}

    # Non-interactive mode (parented bug)
    ${0##*/} --title "Login fails with valid credentials" --description "Bug description" --relationship parented --parent-work-unit 46 --severity High

    # Non-interactive mode (related bug)
    ${0##*/} --title "Feature bug" --description "Bug description" --relationship related --related-feature 45 --severity Medium

    # Preview changes
    ${0##*/} --title "Bug" --description "Description" --relationship parented --parent-work-unit 46 --severity High --dry-run

    # Verbose output
    ${0##*/} --title "Bug" --description "Description" --relationship related --related-feature 45 --severity Critical --verbose
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
            --relationship)
                BUG_RELATIONSHIP="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --parent-work-unit)
                PARENT_WORK_UNIT="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --related-feature)
                RELATED_FEATURE="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --severity)
                SEVERITY="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --steps)
                STEPS_TO_REPRODUCE="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --expected)
                EXPECTED_BEHAVIOR="$2"
                INTERACTIVE=false
                shift 2
                ;;
            --actual)
                ACTUAL_BEHAVIOR="$2"
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

# Validate issue exists and has correct type
validate_issue_exists_and_type() {
    local repo=$1
    local issue_number=$2
    local expected_type=$3

    log_verbose "Validating issue #${issue_number} exists and is type '${expected_type}'..."

    # Check if issue exists
    local issue_data
    issue_data=$(gh issue view "${issue_number}" --repo "${repo}" --json number,type 2>/dev/null || echo "")
    
    if [[ -z "${issue_data}" ]]; then
        log_error "Issue #${issue_number} does not exist in repository ${repo}"
        return 1
    fi

    # Check issue type
    local issue_type
    issue_type=$(echo "${issue_data}" | yq eval '.type // ""' - 2>/dev/null || echo "")
    
    if [[ -z "${issue_type}" ]]; then
        log_warning "Could not determine issue type for #${issue_number}, continuing anyway"
        return 0
    fi

    if [[ "${issue_type}" != "${expected_type}" ]]; then
        log_error "Issue #${issue_number} is type '${issue_type}', expected '${expected_type}'"
        return 1
    fi

    log_verbose "Issue #${issue_number} validated: type '${issue_type}'"
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

# Interactive prompt for issue details
prompt_issue_details() {
    log_info "Enter Bug details:"
    echo

    # Title
    while [[ -z "${ISSUE_TITLE}" ]]; do
        read -p "Bug title: " ISSUE_TITLE
        if [[ -z "${ISSUE_TITLE}" ]]; then
            log_error "Title is required"
        fi
    done

    # Relationship type
    if [[ -z "${BUG_RELATIONSHIP}" ]]; then
        log_info "Bug relationship type:"
        echo "  1) Parented to Work Unit"
        echo "  2) Related to Feature"
        read -p "Select [1]: " rel_choice
        case "${rel_choice:-1}" in
            1) BUG_RELATIONSHIP="parented" ;;
            2) BUG_RELATIONSHIP="related" ;;
            *) BUG_RELATIONSHIP="parented" ;;
        esac
    fi

    # Parent Work Unit or Related Feature
    if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
        while [[ -z "${PARENT_WORK_UNIT}" ]]; do
            read -p "Parent Work Unit issue number (e.g., 46): " PARENT_WORK_UNIT
            if [[ -z "${PARENT_WORK_UNIT}" ]]; then
                log_error "Parent Work Unit is required for parented bugs"
            fi
        done
    elif [[ "${BUG_RELATIONSHIP}" == "related" ]]; then
        while [[ -z "${RELATED_FEATURE}" ]]; do
            read -p "Related Feature issue number (e.g., 45): " RELATED_FEATURE
            if [[ -z "${RELATED_FEATURE}" ]]; then
                log_error "Related Feature is required for related bugs"
            fi
        done
    fi

    # Severity
    if [[ -z "${SEVERITY}" ]]; then
        log_info "Severity level:"
        echo "  1) Critical"
        echo "  2) High"
        echo "  3) Medium"
        echo "  4) Low"
        read -p "Select [3]: " sev_choice
        case "${sev_choice:-3}" in
            1) SEVERITY="Critical" ;;
            2) SEVERITY="High" ;;
            3) SEVERITY="Medium" ;;
            4) SEVERITY="Low" ;;
            *) SEVERITY="Medium" ;;
        esac
    fi

    # Description
    if [[ -z "${ISSUE_DESCRIPTION}" && -z "${ISSUE_BODY_FILE}" ]]; then
        log_info "Enter bug description (end with Ctrl+D or empty line):"
        ISSUE_DESCRIPTION=$(cat)
    fi

    # Steps to reproduce
    if [[ -z "${STEPS_TO_REPRODUCE}" ]]; then
        log_info "Steps to reproduce (optional, end with Ctrl+D or empty line):"
        STEPS_TO_REPRODUCE=$(cat)
    fi

    # Expected behavior
    if [[ -z "${EXPECTED_BEHAVIOR}" ]]; then
        read -p "Expected behavior (optional): " EXPECTED_BEHAVIOR
    fi

    # Actual behavior
    if [[ -z "${ACTUAL_BEHAVIOR}" ]]; then
        read -p "Actual behavior (optional): " ACTUAL_BEHAVIOR
    fi
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

    # Build full body with bug-specific sections
    if [[ -n "${STEPS_TO_REPRODUCE}" ]]; then
        body_content="${body_content}

## Steps to Reproduce
${STEPS_TO_REPRODUCE}"
    fi

    if [[ -n "${EXPECTED_BEHAVIOR}" ]]; then
        body_content="${body_content}

## Expected Behavior
${EXPECTED_BEHAVIOR}"
    fi

    if [[ -n "${ACTUAL_BEHAVIOR}" ]]; then
        body_content="${body_content}

## Actual Behavior
${ACTUAL_BEHAVIOR}"
    fi

    # Append RHYTHM Method metadata
    local priority="normal"
    if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
        priority="highest"
    fi

    body_content="${body_content}

---

<!-- RHYTHM Method Metadata -->
**Bug ID:** bug-XXX (auto-generated)
**Relationship:** ${BUG_RELATIONSHIP}"
    
    if [[ "${BUG_RELATIONSHIP}" == "parented" && -n "${PARENT_WORK_UNIT}" ]]; then
        body_content="${body_content}
**Parent Work Unit:** #${PARENT_WORK_UNIT}"
    elif [[ "${BUG_RELATIONSHIP}" == "related" && -n "${RELATED_FEATURE}" ]]; then
        body_content="${body_content}
**Related Feature:** #${RELATED_FEATURE}"
    fi

    body_content="${body_content}
**Status:** planned
**Priority:** ${priority} (parented bugs always highest)
**Severity:** ${SEVERITY}"

    echo "${body_content}"
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "Create GitHub Bug Issue for RHYTHM Method"
    log_info "=========================================="

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

    # Validate relationship type
    if [[ -z "${BUG_RELATIONSHIP}" ]]; then
        log_error "Bug relationship type is required (parented or related)"
        exit 2
    fi

    if [[ "${BUG_RELATIONSHIP}" != "parented" && "${BUG_RELATIONSHIP}" != "related" ]]; then
        log_error "Invalid relationship type: ${BUG_RELATIONSHIP}. Must be 'parented' or 'related'"
        exit 2
    fi

    # Validate relationship-specific requirements
    if [[ "${BUG_RELATIONSHIP}" == "parented" && -z "${PARENT_WORK_UNIT}" ]]; then
        log_error "Parent Work Unit issue number is required for parented bugs"
        exit 2
    fi

    if [[ "${BUG_RELATIONSHIP}" == "related" && -z "${RELATED_FEATURE}" ]]; then
        log_error "Related Feature issue number is required for related bugs"
        exit 2
    fi

    # Validate severity
    if [[ -z "${SEVERITY}" ]]; then
        log_error "Severity is required"
        exit 2
    fi

    # Validate parent/related issue exists and is correct type
    if [[ "${DRY_RUN}" != "true" ]]; then
        if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
            if ! validate_issue_exists_and_type "${repo}" "${PARENT_WORK_UNIT}" "Work Unit"; then
                log_error "Parent Work Unit validation failed"
                exit 2
            fi
        elif [[ "${BUG_RELATIONSHIP}" == "related" ]]; then
            if ! validate_issue_exists_and_type "${repo}" "${RELATED_FEATURE}" "Feature"; then
                log_error "Related Feature validation failed"
                exit 2
            fi
        fi
    fi

    log_info "Creating Bug issue..."
    log_verbose "Title: ${ISSUE_TITLE}"
    log_verbose "Relationship: ${BUG_RELATIONSHIP}"
    if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
        log_verbose "Parent Work Unit: #${PARENT_WORK_UNIT}"
    else
        log_verbose "Related Feature: #${RELATED_FEATURE}"
    fi
    log_verbose "Severity: ${SEVERITY}"

    # Create issue
    local issue_number
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_info "[DRY RUN] Would create issue:"
        log_info "  Title: ${ISSUE_TITLE}"
        log_info "  Type: Bug"
        log_info "  Relationship: ${BUG_RELATIONSHIP}"
        if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
            log_info "  Parent Work Unit: #${PARENT_WORK_UNIT}"
        else
            log_info "  Related Feature: #${RELATED_FEATURE}"
        fi
        log_info "  Severity: ${SEVERITY}"
        log_info "  Body: (see ${body_file})"
        rm -f "${body_file}"
        exit 0
    fi

    # Build gh issue create command
    local create_cmd=(
        gh issue create
        --repo "${repo}"
        --title "${ISSUE_TITLE}"
        --body-file "${body_file}"
        --type "Bug"
    )

    # Add dependency if parented to work unit
    if [[ "${BUG_RELATIONSHIP}" == "parented" && -n "${PARENT_WORK_UNIT}" ]]; then
        create_cmd+=(--add-blocked-by "${PARENT_WORK_UNIT}")
    fi

    # Execute command
    issue_number=$( "${create_cmd[@]}" 2>&1 | grep -oE '#[0-9]+' | grep -oE '[0-9]+' || echo "")

    if [[ -z "${issue_number}" ]]; then
        log_error "Failed to create issue"
        rm -f "${body_file}"
        exit 1
    fi

    log_success "Created Bug issue #${issue_number}"

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

            # Update Bug Relationship field
            local bug_relationship_field_id
            if bug_relationship_field_id=$(get_field_id "Bug Relationship"); then
                # Map relationship type to field value
                local relationship_value
                if [[ "${BUG_RELATIONSHIP}" == "parented" ]]; then
                    relationship_value="Parented"
                else
                    relationship_value="Related"
                fi
                update_project_single_select_field "${project_id}" "${issue_node_id}" "${bug_relationship_field_id}" "Bug Relationship" "${relationship_value}" || true
            fi

            # Update Severity field
            local severity_field_id
            if severity_field_id=$(get_field_id "Severity"); then
                update_project_single_select_field "${project_id}" "${issue_node_id}" "${severity_field_id}" "Severity" "${SEVERITY}" || true
            fi
        fi
    fi

    log_success "Bug issue #${issue_number} created successfully"
    log_info "View issue: https://github.com/${repo}/issues/${issue_number}"
}

# Run main function
main "$@"

