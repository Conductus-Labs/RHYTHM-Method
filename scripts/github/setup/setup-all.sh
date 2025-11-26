#!/usr/bin/env bash
#
# Master Setup Script for RHYTHM Method GitHub Integration
#
# This script orchestrates the complete GitHub Issues setup for RHYTHM Method,
# including issue templates, issue types, and project setup.
#
# Usage:
#   ./setup-all.sh [--dry-run] [--verbose] [--help] [--non-interactive] [--skip-templates] [--skip-issue-types] [--skip-project]
#
# Options:
#   --dry-run           Preview changes without applying them
#   --verbose           Show detailed output
#   --help              Show this help message
#   --non-interactive   Use config file values without prompting
#   --skip-templates    Skip issue templates setup
#   --skip-issue-types  Skip issue types setup
#   --skip-project      Skip project setup
#
# Requirements:
#   - GitHub CLI (gh) installed and authenticated
#   - Organization admin permissions (for issue types)
#   - Repository admin permissions (for project)
#   - YAML parser (yq) for parsing configuration
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

set -euo pipefail

# Script directory and paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"

# Flags
DRY_RUN=false
VERBOSE=false
SHOW_HELP=false
NON_INTERACTIVE=false
SKIP_TEMPLATES=false
SKIP_ISSUE_TYPES=false
SKIP_PROJECT=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Setup steps tracking
STEPS_TO_RUN=()
STEPS_COMPLETED=()
STEPS_FAILED=()

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

log_step() {
    echo -e "${CYAN}→${NC} $1"
}

log_verbose() {
    if [[ "${VERBOSE}" == "true" ]]; then
        echo -e "${BLUE}[VERBOSE]${NC} $1"
    fi
}

# Show help message
show_help() {
    cat << EOF
Master Setup Script for RHYTHM Method GitHub Integration

This script orchestrates the complete GitHub Issues setup for RHYTHM Method,
including issue templates, issue types, and project setup.

USAGE:
    ${0##*/} [OPTIONS]

OPTIONS:
    --dry-run           Preview changes without applying them
    --verbose           Show detailed output
    --help              Show this help message
    --non-interactive   Use config file values without prompting
    --skip-templates    Skip issue templates setup
    --skip-issue-types  Skip issue types setup
    --skip-project      Skip project setup

SETUP STEPS:
    1. Issue Templates    - Copy templates to .github/ISSUE_TEMPLATE/
    2. Issue Types        - Create GitHub Issue Types (Feature, Work Unit, Agent Task, Bug)
    3. Project Setup      - Create GitHub Project v2 with custom fields

REQUIREMENTS:
    - GitHub CLI (gh) installed and authenticated
    - Organization admin permissions (for issue types)
    - Repository admin permissions (for project)
    - YAML parser (yq) for parsing configuration

EXAMPLES:
    # Interactive setup (wizard mode)
    ${0##*/}

    # Preview all changes
    ${0##*/} --dry-run --verbose

    # Non-interactive setup (use config)
    ${0##*/} --non-interactive

    # Skip specific steps
    ${0##*/} --skip-templates --skip-issue-types

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
            --non-interactive) NON_INTERACTIVE=true ;;
            --skip-templates) SKIP_TEMPLATES=true ;;
            --skip-issue-types) SKIP_ISSUE_TYPES=true ;;
            --skip-project) SKIP_PROJECT=true ;;
            *) log_error "Unknown parameter: $1"; exit 1 ;;
        esac
        shift
    done
}

# Check if script exists and is executable
check_script() {
    local script_path=$1
    local script_name=$2

    if [[ ! -f "${script_path}" ]]; then
        log_error "Required script not found: ${script_name}"
        log_info "Expected location: ${script_path}"
        return 1
    fi

    if [[ ! -x "${script_path}" ]]; then
        log_warning "Script not executable: ${script_path}"
        log_info "Making script executable..."
        chmod +x "${script_path}" || {
            log_error "Failed to make script executable"
            return 1
        }
    fi

    return 0
}

# Run a setup script
run_setup_script() {
    local script_name=$1
    local script_path="${SCRIPT_DIR}/${script_name}"
    local step_description=$2

    log_step "Running: ${step_description}"

    # Check if script exists
    if ! check_script "${script_path}" "${script_name}"; then
        return 1
    fi

    # Build command with flags
    local cmd="${script_path}"
    if [[ "${DRY_RUN}" == "true" ]]; then
        cmd="${cmd} --dry-run"
    fi
    if [[ "${VERBOSE}" == "true" ]]; then
        cmd="${cmd} --verbose"
    fi

    log_verbose "Executing: ${cmd}"

    # Run the script
    if eval "${cmd}"; then
        log_success "Completed: ${step_description}"
        STEPS_COMPLETED+=("${step_description}")
        return 0
    else
        local exit_code=$?
        log_error "Failed: ${step_description} (exit code: ${exit_code})"
        STEPS_FAILED+=("${step_description}")
        return ${exit_code}
    fi
}

# Show setup summary
show_summary() {
    echo ""
    log_info "Setup Summary"
    log_info "============="
    echo ""

    if [[ ${#STEPS_TO_RUN[@]} -eq 0 ]]; then
        log_warning "No setup steps will be executed (all skipped)"
        return
    fi

    log_info "Steps to execute:"
    local step_num=1
    for step in "${STEPS_TO_RUN[@]}"; do
        echo "  ${step_num}. ${step}"
        step_num=$((step_num + 1))
    done

    echo ""
    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN MODE - No changes will be made"
    fi

    if [[ "${NON_INTERACTIVE}" == "true" ]]; then
        log_info "Non-interactive mode: Using config file values"
    else
        log_info "Interactive mode: You will be prompted for configuration"
    fi

    echo ""
    if [[ "${NON_INTERACTIVE}" != "true" ]]; then
        read -p "Continue with setup? [Y/n]: " confirm
        if [[ "${confirm}" =~ ^[Nn]$ ]]; then
            log_info "Setup cancelled by user"
            exit 0
        fi
    fi
}

# Interactive wizard: select steps to run
interactive_wizard() {
    log_info "RHYTHM Method GitHub Setup Wizard"
    log_info "=================================="
    echo ""

    # Issue Templates
    if [[ "${SKIP_TEMPLATES}" != "true" ]]; then
        read -p "Setup issue templates? [Y/n]: " confirm
        if [[ ! "${confirm}" =~ ^[Nn]$ ]]; then
            STEPS_TO_RUN+=("Issue Templates")
        else
            SKIP_TEMPLATES=true
        fi
    fi

    # Issue Types
    if [[ "${SKIP_ISSUE_TYPES}" != "true" ]]; then
        read -p "Setup issue types? [Y/n]: " confirm
        if [[ ! "${confirm}" =~ ^[Nn]$ ]]; then
            STEPS_TO_RUN+=("Issue Types")
        else
            SKIP_ISSUE_TYPES=true
        fi
    fi

    # Project Setup
    if [[ "${SKIP_PROJECT}" != "true" ]]; then
        read -p "Setup project and custom fields? [Y/n]: " confirm
        if [[ ! "${confirm}" =~ ^[Nn]$ ]]; then
            STEPS_TO_RUN+=("Project Setup")
        else
            SKIP_PROJECT=true
        fi
    fi
}

# Non-interactive mode: determine steps from flags
non_interactive_setup() {
    if [[ "${SKIP_TEMPLATES}" != "true" ]]; then
        STEPS_TO_RUN+=("Issue Templates")
    fi
    if [[ "${SKIP_ISSUE_TYPES}" != "true" ]]; then
        STEPS_TO_RUN+=("Issue Types")
    fi
    if [[ "${SKIP_PROJECT}" != "true" ]]; then
        STEPS_TO_RUN+=("Project Setup")
    fi
}

# Main function
main() {
    parse_args "$@"

    if [[ "${SHOW_HELP}" == "true" ]]; then
        show_help
        exit 0
    fi

    log_info "RHYTHM Method GitHub Integration - Master Setup"
    log_info "==============================================="
    echo ""

    # Determine which steps to run
    if [[ "${NON_INTERACTIVE}" == "true" ]]; then
        non_interactive_setup
    else
        interactive_wizard
    fi

    # Show summary
    show_summary

    # Execute setup steps
    local total_steps=${#STEPS_TO_RUN[@]}
    local current_step=0

    for step in "${STEPS_TO_RUN[@]}"; do
        current_step=$((current_step + 1))
        echo ""
        log_info "Step ${current_step}/${total_steps}: ${step}"
        log_info "----------------------------------------"

        case "${step}" in
            "Issue Templates")
                if ! run_setup_script "setup-issue-templates.sh" "Issue Templates Setup"; then
                    log_error "Issue templates setup failed"
                    if [[ "${DRY_RUN}" != "true" ]]; then
                        log_warning "Continuing with remaining steps..."
                    fi
                fi
                ;;
            "Issue Types")
                if ! run_setup_script "setup-issue-types.sh" "Issue Types Setup"; then
                    log_error "Issue types setup failed"
                    if [[ "${DRY_RUN}" != "true" ]]; then
                        log_warning "Continuing with remaining steps..."
                    fi
                fi
                ;;
            "Project Setup")
                if ! run_setup_script "setup-project.sh" "Project Setup"; then
                    log_error "Project setup failed"
                    if [[ "${DRY_RUN}" != "true" ]]; then
                        log_warning "Continuing with remaining steps..."
                    fi
                fi
                ;;
            *)
                log_error "Unknown step: ${step}"
                ;;
        esac
    done

    # Final summary
    echo ""
    log_info "Setup Summary"
    log_info "============="
    echo ""
    log_info "Completed: ${#STEPS_COMPLETED[@]} step(s)"
    for step in "${STEPS_COMPLETED[@]}"; do
        log_success "  ✓ ${step}"
    done

    if [[ ${#STEPS_FAILED[@]} -gt 0 ]]; then
        echo ""
        log_error "Failed: ${#STEPS_FAILED[@]} step(s)"
        for step in "${STEPS_FAILED[@]}"; do
            log_error "  ✗ ${step}"
        done
        exit 1
    fi

    if [[ "${DRY_RUN}" == "true" ]]; then
        log_warning "DRY RUN - No changes were made"
    else
        log_success "All setup steps completed successfully!"
        log_info "Your GitHub repository is now configured for RHYTHM Method."
    fi
}

# Run main function
main "$@"

