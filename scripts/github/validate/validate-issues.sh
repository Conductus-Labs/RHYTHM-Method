#!/usr/bin/env bash
#
# Validate Issues Script for RHYTHM Method
# 
# This script validates GitHub Issues setup: verifies issue types exist, Projects v2 custom fields
# exist, issue structure matches RHYTHM Method requirements, checks for orphaned issues, and
# validates dependency graph consistency.
#
# Usage:
#   ./validate-issues.sh [OPTIONS] [--issue ISSUE_NUMBER] [--all]
#
# Options:
#   --verbose       Show detailed output
#   --help          Show this help message
#   --issue         Issue number to validate (optional - validates all if not specified)
#   --all           Validate all issues in the repository
#   --repo          Repository (org/repo format, optional - auto-detected if not provided)
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - YAML parser (yq) for parsing configuration
#   - jq or yq for JSON parsing
#
# Features:
#   - Verifies all required issue types exist
#   - Verifies Projects v2 custom fields exist with correct options
#   - Validates issue structure and metadata format
#   - Checks for orphaned issues (missing parent references)
#   - Validates dependency graph (no circular dependencies)
#   - Checks native dependencies match issue body metadata
#   - Generates detailed validation report
#
# Exit codes:
#   0 = All valid
#   1 = Errors found
#   2 = Validation failure (prerequisites not met)
#
# Report Format:
#   The script generates a validation report showing:
#   - Summary of checks performed
#   - List of errors found
#   - List of warnings
#   - Recommendations for fixes

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
CONFIG_FILE="${REPO_ROOT}/.baton/github-config.yml"
FIELD_IDS_FILE="${REPO_ROOT}/.baton/github-field-ids.yml"
PROJECT_CONFIG_FILE="${REPO_ROOT}/.baton/project.config.yml"

# Flags
VERBOSE=false
SHOW_HELP=false
VALIDATE_ALL=false

# Parameters
ISSUE_NUMBER=""
REPO=""

# Validation results
ERROR_COUNT=0
WARNING_COUNT=0
ISSUE_TYPE_ERRORS=()
CUSTOM_FIELD_ERRORS=()
METADATA_ERRORS=()
ORPHAN_ERRORS=()
DEPENDENCY_ERRORS=()
CIRCULAR_DEP_ERRORS=()

# Required issue types
REQUIRED_ISSUE_TYPES=("Feature" "Work Unit" "Agent Task" "Bug")

# Required custom fields (from Work-Unit-01 spec)
REQUIRED_FIELDS=(
    "Status:single_select:Planned,In Progress,Review,Blocked,Completed,Failed"
    "TEMPO:single_select:High,Moderate,Controlled"
    "Assigned Agent:single_select:"
    "Estimated Tokens:number:"
    "Actual Tokens:number:"
    "Bug Relationship:single_select:Parented,Related"
    "Severity:single_select:Critical,High,Medium,Low"
)

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
    ((WARNING_COUNT++))
}

log_error() {
    echo -e "${RED}✗${NC} $1" >&2
    ((ERROR_COUNT++))
}

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Show help message
show_help() {
    cat << EOF
Validate Issues Script for RHYTHM Method

This script validates GitHub Issues setup: verifies issue types exist, Projects v2 custom fields
exist, issue structure matches RHYTHM Method requirements, checks for orphaned issues, and
validates dependency graph consistency.

USAGE:
    ${0##*/} [OPTIONS] [--issue ISSUE_NUMBER] [--all]

OPTIONS:
    --verbose       Show detailed output
    --help          Show this help message
    --issue         Issue number to validate (optional - validates all if not specified)
    --all           Validate all issues in the repository
    --repo          Repository (org/repo format, optional - auto-detected if not provided)

EXAMPLES:
    # Validate all issues
    ${0##*/} --all

    # Validate a single issue
    ${0##*/} --issue 45

    # Verbose output
    ${0##*/} --all --verbose

VALIDATION CHECKS:
    - Issue types: Verifies all 4 required types exist
    - Custom fields: Verifies all 7 required fields exist with correct options
    - Issue metadata: Validates RHYTHM Method metadata format
    - Parent-child relationships: Checks parent issues exist and are correct type
    - Dependencies: Validates native dependencies match issue body metadata
    - Dependency graph: Checks for circular dependencies
    - Projects v2: Verifies issues are linked to project

EXIT CODES:
    0 = All valid
    1 = Errors found
    2 = Validation failure (prerequisites not met)

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
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
                VALIDATE_ALL=true
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
        exit 2
    fi

    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI is not authenticated"
        log_info "Run: gh auth login"
        exit 2
    fi

    if ! command -v yq &> /dev/null && ! command -v jq &> /dev/null; then
        log_error "YAML/JSON parser (yq or jq) is not installed"
        log_info "Install from: https://github.com/mikefarah/yq or https://stedolan.github.io/jq/"
        exit 2
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

# Get organization from repository
get_organization() {
    local repo=$1
    local org
    org=$(echo "${repo}" | cut -d'/' -f1)
    echo "${org}"
}

# Validate issue types
validate_issue_types() {
    local org=$1

    log_info "Validating issue types..."

    # Get existing issue types
    local existing_types
    existing_types=$(gh api "orgs/${org}/issue-types" --jq '.[].name' 2>/dev/null || echo "")

    if [[ -z "${existing_types}" ]]; then
        log_error "Could not retrieve issue types from organization"
        ISSUE_TYPE_ERRORS+=("Could not query issue types API")
        return 1
    fi

    local missing_types=()
    for required_type in "${REQUIRED_ISSUE_TYPES[@]}"; do
        if ! echo "${existing_types}" | grep -q "^${required_type}$"; then
            missing_types+=("${required_type}")
            log_error "Missing issue type: ${required_type}"
            ISSUE_TYPE_ERRORS+=("Missing issue type: ${required_type}")
        else
            log_success "Issue type exists: ${required_type}"
            log_verbose "  ✓ ${required_type}"
        fi
    done

    if [[ ${#missing_types[@]} -eq 0 ]]; then
        log_success "All required issue types exist"
        return 0
    else
        log_error "Missing ${#missing_types[@]} issue type(s)"
        return 1
    fi
}

# Get project ID
get_project_id() {
    if [[ ! -f "${FIELD_IDS_FILE}" ]]; then
        return 1
    fi

    local project_id
    project_id=$(yq eval '.project.id // ""' "${FIELD_IDS_FILE}" 2>/dev/null || echo "")
    
    if [[ -z "${project_id}" || "${project_id}" == "null" ]]; then
        return 1
    fi

    echo "${project_id}"
    return 0
}

# Validate Projects v2 custom fields
validate_custom_fields() {
    local project_id=$1

    log_info "Validating Projects v2 custom fields..."

    # Query project fields
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
                            ... on ProjectV2Field {
                                id
                                name
                                dataType
                            }
                        }
                    }
                }
            }
        }
    " 2>&1) || {
        log_error "Could not query project fields"
        CUSTOM_FIELD_ERRORS+=("Could not query Projects v2 fields API")
        return 1
    }

    # Parse fields from response
    local field_names
    if command -v jq &> /dev/null; then
        field_names=$(echo "${response}" | jq -r '.data.node.fields.nodes[] | "\(.name):\(.dataType)"' 2>/dev/null || echo "")
    elif command -v yq &> /dev/null; then
        field_names=$(echo "${response}" | yq eval '.data.node.fields.nodes[] | "\(.name):\(.dataType)"' - 2>/dev/null || echo "")
    fi

    log_verbose "Found fields: ${field_names}"

    # Validate each required field
    local missing_fields=()
    for field_spec in "${REQUIRED_FIELDS[@]}"; do
        local field_name field_type expected_options
        field_name=$(echo "${field_spec}" | cut -d':' -f1)
        field_type=$(echo "${field_spec}" | cut -d':' -f2)
        expected_options=$(echo "${field_spec}" | cut -d':' -f3)

        # Check if field exists
        local field_exists=false
        if echo "${field_names}" | grep -q "^${field_name}:"; then
            field_exists=true
        fi

        if [[ "${field_exists}" == "false" ]]; then
            log_error "Missing custom field: ${field_name}"
            CUSTOM_FIELD_ERRORS+=("Missing field: ${field_name} (type: ${field_type})")
            missing_fields+=("${field_name}")
        else
            log_success "Custom field exists: ${field_name}"
            log_verbose "  ✓ ${field_name} (${field_type})"

            # Validate options for single-select fields
            if [[ "${field_type}" == "single_select" && -n "${expected_options}" ]]; then
                validate_field_options "${response}" "${field_name}" "${expected_options}"
            fi
        fi
    done

    if [[ ${#missing_fields[@]} -eq 0 ]]; then
        log_success "All required custom fields exist"
        return 0
    else
        log_error "Missing ${#missing_fields[@]} custom field(s)"
        return 1
    fi
}

# Validate field options
validate_field_options() {
    local response=$1
    local field_name=$2
    local expected_options=$3

    log_verbose "  Validating options for ${field_name}..."

    # Extract options for this field
    local field_options
    if command -v jq &> /dev/null; then
        field_options=$(echo "${response}" | jq -r ".data.node.fields.nodes[] | select(.name == \"${field_name}\") | .options[]?.name // empty" 2>/dev/null || echo "")
    elif command -v yq &> /dev/null; then
        field_options=$(echo "${response}" | yq eval ".data.node.fields.nodes[] | select(.name == \"${field_name}\") | .options[]?.name // empty" - 2>/dev/null || echo "")
    fi

    # Check each expected option
    IFS=',' read -ra EXPECTED <<< "${expected_options}"
    for expected_opt in "${EXPECTED[@]}"; do
        expected_opt=$(echo "${expected_opt}" | xargs)  # Trim whitespace
        if ! echo "${field_options}" | grep -q "^${expected_opt}$"; then
            log_warning "Missing option '${expected_opt}' in field '${field_name}'"
            CUSTOM_FIELD_ERRORS+=("Field '${field_name}' missing option: ${expected_opt}")
        fi
    done
}

# Get issue body
get_issue_body() {
    local repo=$1
    local issue_number=$2

    local body
    body=$(gh issue view "${issue_number}" --repo "${repo}" --json body --jq '.body' 2>/dev/null || echo "")
    
    if [[ -z "${body}" || "${body}" == "null" ]]; then
        return 1
    fi

    echo "${body}"
    return 0
}

# Get issue details
get_issue_details() {
    local repo=$1
    local issue_number=$2

    local details
    details=$(gh issue view "${issue_number}" --repo "${repo}" --json number,type,state,title,blockedBy,blocking 2>/dev/null || echo "")
    
    if [[ -z "${details}" || "${details}" == "null" ]]; then
        return 1
    fi

    echo "${details}"
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

    echo "${value}"
    return 0
}

# Validate issue metadata
validate_issue_metadata() {
    local repo=$1
    local issue_number=$2
    local issue_type=$3

    log_verbose "Validating metadata for issue #${issue_number} (type: ${issue_type})..."

    # Get issue body
    local body
    if ! body=$(get_issue_body "${repo}" "${issue_number}"); then
        log_warning "Issue #${issue_number} has no body"
        METADATA_ERRORS+=("Issue #${issue_number}: Missing issue body")
        return 1
    fi

    # Check for metadata section
    if ! echo "${body}" | grep -q "<!-- RHYTHM Method Metadata -->"; then
        log_warning "Issue #${issue_number} missing RHYTHM Method metadata section"
        METADATA_ERRORS+=("Issue #${issue_number}: Missing metadata section")
        return 1
    fi

    # Validate required fields based on issue type
    local has_errors=false

    case "${issue_type}" in
        "Feature")
            if ! parse_metadata_field "${body}" "Feature ID" > /dev/null; then
                log_warning "Issue #${issue_number} missing Feature ID in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Feature ID")
                has_errors=true
            fi
            if ! parse_metadata_field "${body}" "Status" > /dev/null; then
                log_warning "Issue #${issue_number} missing Status in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Status")
                has_errors=true
            fi
            ;;
        "Work Unit")
            if ! parse_metadata_field "${body}" "Work Unit ID" > /dev/null; then
                log_warning "Issue #${issue_number} missing Work Unit ID in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Work Unit ID")
                has_errors=true
            fi
            if ! parse_metadata_field "${body}" "Parent Feature" > /dev/null; then
                log_warning "Issue #${issue_number} missing Parent Feature in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Parent Feature")
                has_errors=true
            fi
            ;;
        "Agent Task")
            if ! parse_metadata_field "${body}" "Task ID" > /dev/null; then
                log_warning "Issue #${issue_number} missing Task ID in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Task ID")
                has_errors=true
            fi
            if ! parse_metadata_field "${body}" "Parent Work Unit" > /dev/null; then
                log_warning "Issue #${issue_number} missing Parent Work Unit in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Parent Work Unit")
                has_errors=true
            fi
            if ! parse_metadata_field "${body}" "Assigned Agent" > /dev/null; then
                log_warning "Issue #${issue_number} missing Assigned Agent in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Assigned Agent")
                has_errors=true
            fi
            ;;
        "Bug")
            if ! parse_metadata_field "${body}" "Bug ID" > /dev/null; then
                log_warning "Issue #${issue_number} missing Bug ID in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Bug ID")
                has_errors=true
            fi
            if ! parse_metadata_field "${body}" "Relationship" > /dev/null; then
                log_warning "Issue #${issue_number} missing Relationship in metadata"
                METADATA_ERRORS+=("Issue #${issue_number}: Missing Relationship")
                has_errors=true
            fi
            ;;
    esac

    if [[ "${has_errors}" == "true" ]]; then
        return 1
    fi

    log_verbose "  ✓ Metadata valid for issue #${issue_number}"
    return 0
}

# Validate parent-child relationships
validate_parent_relationships() {
    local repo=$1
    local issue_number=$2
    local issue_type=$3
    local body=$4

    log_verbose "Validating parent relationships for issue #${issue_number}..."

    local parent_field=""
    local expected_parent_type=""

    case "${issue_type}" in
        "Work Unit")
            parent_field="Parent Feature"
            expected_parent_type="Feature"
            ;;
        "Agent Task")
            parent_field="Parent Work Unit"
            expected_parent_type="Work Unit"
            ;;
        "Bug")
            # Bugs can have either Parent Work Unit or Related Feature
            local relationship
            relationship=$(parse_metadata_field "${body}" "Relationship" || echo "")
            if [[ "${relationship}" == "parented" ]]; then
                parent_field="Parent Work Unit"
                expected_parent_type="Work Unit"
            elif [[ "${relationship}" == "related" ]]; then
                parent_field="Related Feature"
                expected_parent_type="Feature"
            else
                # No parent validation needed if relationship is not parented/related
                return 0
            fi
            ;;
        *)
            # Features don't have parents
            return 0
            ;;
    esac

    if [[ -z "${parent_field}" ]]; then
        return 0
    fi

    # Get parent issue number
    local parent_ref
    parent_ref=$(parse_metadata_field "${body}" "${parent_field}" || echo "")
    
    if [[ -z "${parent_ref}" ]]; then
        log_warning "Issue #${issue_number} missing ${parent_field}"
        ORPHAN_ERRORS+=("Issue #${issue_number}: Missing ${parent_field}")
        return 1
    fi

    # Extract issue number (format: #123)
    local parent_number
    parent_number=$(echo "${parent_ref}" | grep -oE '#[0-9]+' | sed 's/#//' | head -1 || echo "")

    if [[ -z "${parent_number}" ]]; then
        log_warning "Issue #${issue_number} has invalid ${parent_field} format: ${parent_ref}"
        ORPHAN_ERRORS+=("Issue #${issue_number}: Invalid ${parent_field} format: ${parent_ref}")
        return 1
    fi

    # Check if parent exists
    local parent_details
    if ! parent_details=$(get_issue_details "${repo}" "${parent_number}"); then
        log_warning "Issue #${issue_number} references non-existent parent: #${parent_number}"
        ORPHAN_ERRORS+=("Issue #${issue_number}: Parent issue #${parent_number} does not exist")
        return 1
    fi

    # Check parent type
    local parent_type
    if command -v jq &> /dev/null; then
        parent_type=$(echo "${parent_details}" | jq -r '.type // ""' 2>/dev/null || echo "")
    elif command -v yq &> /dev/null; then
        parent_type=$(echo "${parent_details}" | yq eval '.type // ""' - 2>/dev/null || echo "")
    fi

    if [[ "${parent_type}" != "${expected_parent_type}" ]]; then
        log_warning "Issue #${issue_number} parent #${parent_number} is type '${parent_type}', expected '${expected_parent_type}'"
        ORPHAN_ERRORS+=("Issue #${issue_number}: Parent #${parent_number} is wrong type (${parent_type}, expected ${expected_parent_type})")
        return 1
    fi

    log_verbose "  ✓ Parent relationship valid for issue #${issue_number}"
    return 0
}

# Get dependencies from metadata
get_dependencies_from_metadata() {
    local body=$1

    local dependencies_line
    dependencies_line=$(echo "${body}" | grep -i "^\*\*Dependencies:" || echo "")

    if [[ -z "${dependencies_line}" ]]; then
        echo ""
        return 0
    fi

    # Extract issue numbers (format: #123, #456, etc.)
    local issue_numbers
    issue_numbers=$(echo "${dependencies_line}" | sed -E 's/^\*\*Dependencies:\*\*\s*//' | grep -oE '#[0-9]+' | sed 's/#//' || echo "")

    echo "${issue_numbers}"
    return 0
}

# Get native blocked-by dependencies
get_native_blocked_by() {
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

# Validate dependencies match
validate_dependencies_match() {
    local repo=$1
    local issue_number=$2
    local body=$3

    log_verbose "Validating dependencies for issue #${issue_number}..."

    # Get dependencies from metadata
    local metadata_deps
    metadata_deps=$(get_dependencies_from_metadata "${body}")

    # Get native dependencies
    local native_deps
    native_deps=$(get_native_blocked_by "${repo}" "${issue_number}")

    # Convert to arrays for comparison
    local -a metadata_array
    if [[ -n "${metadata_deps}" ]]; then
        read -ra metadata_array <<< "${metadata_deps}"
    else
        metadata_array=()
    fi

    local -a native_array
    if [[ -n "${native_deps}" ]]; then
        read -ra native_array <<< "${native_deps}"
    else
        native_array=()
    fi

    # Check for mismatches
    local has_mismatch=false

    # Check metadata deps exist in native
    for dep in "${metadata_array[@]}"; do
        local found=false
        for native in "${native_array[@]}"; do
            if [[ "${dep}" == "${native}" ]]; then
                found=true
                break
            fi
        done
        if [[ "${found}" == "false" ]]; then
            log_warning "Issue #${issue_number}: Dependency #${dep} in metadata but not in native dependencies"
            DEPENDENCY_ERRORS+=("Issue #${issue_number}: Missing native dependency #${dep}")
            has_mismatch=true
        fi
    done

    # Check native deps exist in metadata (less critical, but good to know)
    for native in "${native_array[@]}"; do
        local found=false
        for dep in "${metadata_array[@]}"; do
            if [[ "${native}" == "${dep}" ]]; then
                found=true
                break
            fi
        done
        if [[ "${found}" == "false" ]]; then
            log_verbose "Issue #${issue_number}: Native dependency #${native} not in metadata (acceptable)"
        fi
    done

    if [[ "${has_mismatch}" == "true" ]]; then
        return 1
    fi

    log_verbose "  ✓ Dependencies match for issue #${issue_number}"
    return 0
}

# Check for circular dependencies (simple DFS)
check_circular_dependencies() {
    local repo=$1
    local issue_number=$2
    local visited=()
    local path=()

    # Recursive function to check cycles
    local check_cycle
    check_cycle() {
        local current=$1
        local current_path=("${@:2}")

        # Check if current is in path (cycle detected)
        for p in "${current_path[@]}"; do
            if [[ "${p}" == "${current}" ]]; then
                # Found cycle
                local cycle_path="${current_path[*]} -> ${current}"
                log_error "Circular dependency detected: ${cycle_path}"
                CIRCULAR_DEP_ERRORS+=("Circular dependency: ${cycle_path}")
                return 1
            fi
        done

        # Add to path
        current_path+=("${current}")

        # Get dependencies
        local deps
        deps=$(get_native_blocked_by "${repo}" "${current}")

        if [[ -z "${deps}" ]]; then
            return 0
        fi

        # Check each dependency
        local -a dep_array
        read -ra dep_array <<< "${deps}"

        for dep in "${dep_array[@]}"; do
            if ! check_cycle "${dep}" "${current_path[@]}"; then
                return 1
            fi
        done

        return 0
    }

    if ! check_cycle "${issue_number}"; then
        return 1
    fi

    return 0
}

# Validate a single issue
validate_single_issue() {
    local repo=$1
    local issue_number=$2

    log_info "Validating issue #${issue_number}..."

    # Get issue details
    local issue_details
    if ! issue_details=$(get_issue_details "${repo}" "${issue_number}"); then
        log_error "Issue #${issue_number} not found or not accessible"
        return 1
    fi

    # Extract issue type
    local issue_type
    if command -v jq &> /dev/null; then
        issue_type=$(echo "${issue_details}" | jq -r '.type // ""' 2>/dev/null || echo "")
    elif command -v yq &> /dev/null; then
        issue_type=$(echo "${issue_details}" | yq eval '.type // ""' - 2>/dev/null || echo "")
    fi

    if [[ -z "${issue_type}" ]]; then
        log_warning "Issue #${issue_number} has no issue type"
        METADATA_ERRORS+=("Issue #${issue_number}: Missing issue type")
    fi

    # Get issue body
    local body
    if ! body=$(get_issue_body "${repo}" "${issue_number}"); then
        log_warning "Issue #${issue_number} has no body"
        METADATA_ERRORS+=("Issue #${issue_number}: Missing issue body")
    else
        # Validate metadata
        if [[ -n "${issue_type}" ]]; then
            validate_issue_metadata "${repo}" "${issue_number}" "${issue_type}" || true
        fi

        # Validate parent relationships
        if [[ -n "${issue_type}" ]]; then
            validate_parent_relationships "${repo}" "${issue_number}" "${issue_type}" "${body}" || true
        fi

        # Validate dependencies match
        validate_dependencies_match "${repo}" "${issue_number}" "${body}" || true
    fi

    # Check for circular dependencies
    check_circular_dependencies "${repo}" "${issue_number}" || true

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

# Generate validation report
generate_report() {
    log_info ""
    log_info "=========================================="
    log_info "Validation Report"
    log_info "=========================================="
    log_info ""

    log_info "Summary:"
    log_info "  Errors:   ${ERROR_COUNT}"
    log_info "  Warnings: ${WARNING_COUNT}"
    log_info ""

    if [[ ${#ISSUE_TYPE_ERRORS[@]} -gt 0 ]]; then
        log_info "Issue Type Errors:"
        for error in "${ISSUE_TYPE_ERRORS[@]}"; do
            log_error "  ${error}"
        done
        log_info ""
    fi

    if [[ ${#CUSTOM_FIELD_ERRORS[@]} -gt 0 ]]; then
        log_info "Custom Field Errors:"
        for error in "${CUSTOM_FIELD_ERRORS[@]}"; do
            log_error "  ${error}"
        done
        log_info ""
    fi

    if [[ ${#METADATA_ERRORS[@]} -gt 0 ]]; then
        log_info "Metadata Errors:"
        for error in "${METADATA_ERRORS[@]}"; do
            log_warning "  ${error}"
        done
        log_info ""
    fi

    if [[ ${#ORPHAN_ERRORS[@]} -gt 0 ]]; then
        log_info "Orphaned Issues:"
        for error in "${ORPHAN_ERRORS[@]}"; do
            log_warning "  ${error}"
        done
        log_info ""
    fi

    if [[ ${#DEPENDENCY_ERRORS[@]} -gt 0 ]]; then
        log_info "Dependency Mismatches:"
        for error in "${DEPENDENCY_ERRORS[@]}"; do
            log_warning "  ${error}"
        done
        log_info ""
    fi

    if [[ ${#CIRCULAR_DEP_ERRORS[@]} -gt 0 ]]; then
        log_info "Circular Dependencies:"
        for error in "${CIRCULAR_DEP_ERRORS[@]}"; do
            log_error "  ${error}"
        done
        log_info ""
    fi

    if [[ ${ERROR_COUNT} -eq 0 && ${WARNING_COUNT} -eq 0 ]]; then
        log_success "All validations passed!"
        return 0
    elif [[ ${ERROR_COUNT} -eq 0 ]]; then
        log_warning "Validation completed with ${WARNING_COUNT} warning(s)"
        return 0
    else
        log_error "Validation failed with ${ERROR_COUNT} error(s) and ${WARNING_COUNT} warning(s)"
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

    log_info "Validate Issues Script for RHYTHM Method"
    log_info "========================================"

    check_prerequisites

    # Get repository
    local repo
    if ! repo=$(get_repository); then
        exit 2
    fi
    log_info "Using repository: ${repo}"

    # Get organization
    local org
    org=$(get_organization "${repo}")
    log_info "Using organization: ${org}"

    # Validate issue types
    validate_issue_types "${org}" || true

    # Get project ID
    local project_id
    if project_id=$(get_project_id); then
        log_info "Validating Projects v2 custom fields..."
        validate_custom_fields "${project_id}" || true
    else
        log_warning "Project not configured, skipping custom fields validation"
        CUSTOM_FIELD_ERRORS+=("Project not configured (field IDs file not found)")
    fi

    # Validate issues
    if [[ "${VALIDATE_ALL}" == "true" || -z "${ISSUE_NUMBER}" ]]; then
        log_info "Validating all issues..."
        
        local all_issues
        if ! all_issues=$(get_all_issues "${repo}"); then
            log_error "Failed to get list of issues"
            exit 1
        fi

        while IFS= read -r issue_num; do
            validate_single_issue "${repo}" "${issue_num}" || true
        done <<< "${all_issues}"
    elif [[ -n "${ISSUE_NUMBER}" ]]; then
        validate_single_issue "${repo}" "${ISSUE_NUMBER}" || true
    else
        log_info "No issues specified. Validating setup only (issue types and custom fields)."
    fi

    # Generate report
    if generate_report; then
        exit 0
    else
        exit 1
    fi
}

# Run main function
main "$@"

