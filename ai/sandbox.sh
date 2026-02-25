#!/bin/bash

# Sandbox - Standalone module sandbox testing tool

readonly AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${AI_DIR}/ai_engine.sh"

# Usage
usage() {
    echo "Module Sandbox for DevMachine"
    echo ""
    echo "Usage: ${0} <module_path>"
    echo ""
    echo "Tests module functions in a safe sandbox environment:"
    echo "  - Mocks dangerous commands"
    echo "  - Runs in dry-run mode"
    echo "  - Validates function behavior"
    exit 1
}

# Main
main() {
    local module_path="$1"

    if [[ -z "${module_path}" ]]; then
        usage
    fi

    if [[ ! -f "${module_path}" ]]; then
        log_error "Module file not found: ${module_path}"
        exit 1
    fi

    echo "Sandbox testing module: ${module_path}"
    echo "===================================="

    if sandbox_test "${module_path}"; then
        echo ""
        echo "✓ Sandbox test PASSED"
        exit 0
    else
        echo ""
        echo "✗ Sandbox test FAILED"
        exit 1
    fi
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi