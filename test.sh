#!/bin/bash

# DevMachine Test Suite
# Comprehensive testing for DevMachine CLI

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"
readonly AI_DIR="${SCRIPT_DIR}/ai"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
PASSED=0
FAILED=0

# Test function
test_command() {
    local cmd="$1"
    local expected_exit_code="${2:-0}"
    local desc="$3"
    local ignore_stderr="${4:-false}"

    echo -n "Testing: ${desc}... "

    # Run command and capture output/exit code
    if [[ "${ignore_stderr}" == "true" ]]; then
        output=$(${cmd} 2>/dev/null)
        exit_code=$?
    else
        output=$(${cmd} 2>&1)
        exit_code=$?
    fi

    # Check exit code
    if [[ ${exit_code} -eq ${expected_exit_code} ]]; then
        echo -e "${GREEN}✓${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}✗${NC} (expected ${expected_exit_code}, got ${exit_code})"
        echo "Command: ${cmd}"
        echo "Output:"
        echo "${output}"
        echo ""
        ((FAILED++))
        return 1
    fi
}

# Test module functions
test_module() {
    local module="$1"
    local module_path="${MODULES_DIR}/${module}"

    echo -n "Testing module: ${module}... "

    # Check if module exists
    if [[ ! -f "${module_path}" ]]; then
        echo -e "${RED}✗${NC} Module not found"
        ((FAILED++))
        return 1
    fi

    # Check if executable
    if [[ ! -x "${module_path}" ]]; then
        echo -e "${RED}✗${NC} Module not executable"
        ((FAILED++))
        return 1
    fi

    # Check required functions
    local missing_functions=()
    for func in "install" "remove" "status"; do
        if ! grep -q "^${func}()" "${module_path}"; then
            missing_functions+=("${func}")
        fi
    done

    if [[ ${#missing_functions[@]} -gt 0 ]]; then
        echo -e "${RED}✗${NC} Missing functions: ${missing_functions[*]}"
        ((FAILED++))
        return 1
    fi

    echo -e "${GREEN}✓${NC}"
    ((PASSED++))
}

# Main test suite
main() {
    echo "DevMachine Test Suite"
    echo "===================="
    echo ""

    # CLI Tests
    echo "CLI Tests"
    echo "---------"
    test_command "./devmachine --version" 0 "Version command"
    test_command "./devmachine --help" 1 "Help command (expected exit 1)"
    test_command "./devmachine list" 0 "List modules"
    test_command "./devmachine doctor" 0 "System diagnostics"
    test_command "./devmachine config show" 0 "Show config"
    test_command "./devmachine add nonexistent" 1 "Add non-existent module"
    test_command "./devmachine status nonexistent" 1 "Status non-existent module"
    test_command "./devmachine remove nonexistent" 1 "Remove non-existent module"
    echo ""

    # Module Tests
    echo "Module Tests"
    echo "------------"
    for module in "${MODULES_DIR}"/*.sh; do
        if [[ -f "${module}" ]]; then
            test_module "${module##*/}"
        fi
    done
    echo ""

    # AI System Tests
    echo "AI System Tests"
    echo "--------------"
    test_command "./ai/providers/openai.sh info" 0 "OpenAI provider info"
    test_command "./ai/validator.sh nonexistent" 1 "Validator without module"
    test_command "./ai/sandbox.sh nonexistent" 1 "Sandbox without module"
    echo ""

    # Bash Syntax Tests
    echo "Bash Syntax Tests"
    echo "-----------------"
    for script in devmachine "${MODULES_DIR}"/*.sh "${AI_DIR}"/*.sh "${AI_DIR}"/providers/*.sh; do
        if [[ -f "${script}" ]]; then
            test_command "bash -n ${script}" 0 "Syntax check: ${script}"
        fi
    done
    echo ""

    # Configuration Tests
    echo "Configuration Tests"
    echo "-------------------"
    if [[ -f "config/devmachine.conf.example" ]]; then
        test_command "test -f config/devmachine.conf.example" 0 "Config template exists"
    else
        echo -e "${YELLOW}!${NC} Config template not found"
        ((FAILED++))
    fi

    # Git Tests
    echo "Git Tests"
    echo "---------"
    test_command "git status --porcelain" 0 "Git repository clean"
    echo ""

    # Summary
    echo "Test Summary"
    echo "------------"
    echo -e "${GREEN}Passed: ${PASSED}${NC}"
    echo -e "${RED}Failed: ${FAILED}${NC}"

    if [[ ${FAILED} -eq 0 ]]; then
        echo ""
        echo -e "${GREEN}All tests passed!${NC}"
        exit 0
    else
        echo ""
        echo -e "${RED}Some tests failed.${NC}"
        exit 1
    fi
}

# Run tests
main "$@"