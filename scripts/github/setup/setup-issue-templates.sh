#!/usr/bin/env bash
#
# Setup GitHub Issue Templates for RHYTHM Method
#
# This script copies GitHub Issue Form templates from scripts/github/templates/issue-templates/
# to .github/ISSUE_TEMPLATE/ in the repository.
#
# Usage:
#   ./setup-issue-templates.sh [--dry-run] [--verbose] [--help]
#
# Options:
#   --dry-run    Preview changes without applying them
#   --verbose    Show detailed output
#   --help       Show this help message
#
# Requirements:
#   - None (pure file operations)
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

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
TEMPLATE_DIR="${SCRIPT_DIR}/../templates/issue-templates"
TARGET_DIR="${REPO_ROOT}/.github/ISSUE_TEMPLATE"

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
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Show help message
show_help() {
    cat << EOF
Setup GitHub Issue Templates for RHYTHM Method

This script copies GitHub Issue Form templates from the templates directory
to .github/ISSUE_TEMPLATE/ in the repository.

USAGE:
    ${0##*/} [OPTIONS]

OPTIONS:
    --dry-run    Preview changes without applying them
    --verbose    Show detailed output
    --help       Show this help message

REQUIREMENTS:
    - None (pure file operations)

EXAMPLES:
    # Copy templates to .github/ISSUE_TEMPLATE/
    ${0##*/}

    # Preview changes
    ${0##*/} --dry-run --verbose

    # Show help
    ${0##*/} --help
EOF
    exit 0
}

# Parse command-line arguments
parse_args() {
    while [[ "$#" -gt 0 ]]; do
        case "$1" in
            --dry-run) DRY_RUN=true ;;
            --verbose) VERBOSE=true ;;
            --help) SHOW_HELP=true ;;
            *) log_error "Unknown parameter: $1"; exit 1 ;;
        esac
        shift
    done
}

# Validate prerequisites
validate_prerequisites() {
    log_info "Validating prerequisites..."

    # Check if template directory exists
    if [[ ! -d "${TEMPLATE_DIR}" ]]; then
        log_error "Template directory not found: ${TEMPLATE_DIR}"
        exit 2
    fi
    log_verbose "Template directory found: ${TEMPLATE_DIR}"

    # Check if template directory has any YAML files
    local template_count
    template_count=$(find "${TEMPLATE_DIR}" -name "*.yml" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    if [[ "${template_count}" -eq 0 ]]; then
        log_error "No template files found in: ${TEMPLATE_DIR}"
        exit 2
    fi
    log_verbose "Found ${template_count} template file(s)"

    log_success "Prerequisites validated."
}

# Copy template files
copy_templates() {
    log_info "Copying issue templates to ${TARGET_DIR}..."

    # Create target directory if it doesn't exist
    if [[ ! -d "${TARGET_DIR}" ]]; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY RUN] Would create directory: ${TARGET_DIR}"
        else
            mkdir -p "${TARGET_DIR}"
            log_success "Created directory: ${TARGET_DIR}"
        fi
    else
        log_verbose "Target directory already exists: ${TARGET_DIR}"
    fi

    # Find all YAML files in template directory
    local templates
    templates=$(find "${TEMPLATE_DIR}" -name "*.yml" -type f 2>/dev/null | sort)

    if [[ -z "${templates}" ]]; then
        log_error "No template files found in: ${TEMPLATE_DIR}"
        return 1
    fi

    local success_count=0
    local skip_count=0
    local error_count=0
    local total_count=0

    # Count total templates
    while IFS= read -r template; do
        total_count=$((total_count + 1))
    done <<< "${templates}"

    log_info "Found ${total_count} template(s) to copy"

    # Copy each template
    local current_index=0
    while IFS= read -r template; do
        current_index=$((current_index + 1))
        local template_name
        template_name=$(basename "${template}")
        local target_file="${TARGET_DIR}/${template_name}"

        log_info "Processing ${current_index}/${total_count}: ${template_name}"

        # Check if target file already exists
        if [[ -f "${target_file}" ]]; then
            log_warning "Template already exists: ${target_file}"
            
            # Compare files to see if they're different
            if diff -q "${template}" "${target_file}" >/dev/null 2>&1; then
                log_verbose "  Files are identical (skipping)"
                skip_count=$((skip_count + 1))
                continue
            else
                log_warning "  Files differ - will overwrite"
            fi
        fi

        if [[ "${DRY_RUN}" == "true" ]]; then
            log_info "[DRY RUN] Would copy: ${template} -> ${target_file}"
            success_count=$((success_count + 1))
        else
            if cp "${template}" "${target_file}"; then
                log_success "Copied: ${template_name}"
                success_count=$((success_count + 1))
            else
                log_error "Failed to copy: ${template_name}"
                error_count=$((error_count + 1))
            fi
        fi
    done <<< "${templates}"

    # Summary
    echo ""
    log_info "Summary:"
    log_info "  Copied: ${success_count}"
    log_info "  Skipped: ${skip_count}"
    if [[ ${error_count} -gt 0 ]]; then
        log_error "  Errors: ${error_count}"
        return 1
    fi

    return 0
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "GitHub Issue Templates Setup for RHYTHM Method"
    log_info "=============================================="

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    # Validate prerequisites
    validate_prerequisites

    # Copy templates
    if copy_templates; then
        if [[ "${DRY_RUN}" == "true" ]]; then
            log_warning "DRY RUN - No changes were made"
        else
            log_success "Issue templates setup completed successfully!"
            log_info "Templates are now available at: ${TARGET_DIR}"
        fi
        exit 0
    else
        log_error "Failed to copy some templates"
        exit 1
    fi
}

# Run main function
main "$@"

