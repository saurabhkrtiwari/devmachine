#!/bin/bash

# Validator - Standalone module validation tool

readonly AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${AI_DIR}/ai_engine.sh"

# Usage
usage() {
    echo "Module Validator for DevMachine"
    echo ""
    echo "Usage: ${0} <module_path>"
    echo ""
    echo "Validates a module file for:"
    echo "  - Required functions (install, remove, status)"
    echo "  - Bash syntax"
    echo "  - Dangerous patterns"
    echo "  - Security checks"
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

    echo "Validating module: ${module_path}"
    echo "================================"

    if validate_module "${module_path}"; then
        echo ""
        echo "✓ Module validation PASSED"
        exit 0
    else
        echo ""
        echo "✗ Module validation FAILED"
        exit 1
    fi
}

# Entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi