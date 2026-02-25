#!/bin/bash

# DevMachine Setup Verification Script
# This script verifies the DevMachine installation

set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly CONFIG_DIR="${SCRIPT_DIR}/config"
readonly MODULES_DIR="${SCRIPT_DIR}/modules"
readonly AI_DIR="${SCRIPT_DIR}/ai"

echo "DevMachine Setup Verification"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test functions
test_file() {
    local file="$1"
    local desc="$2"

    if [[ -f "${file}" ]]; then
        echo -e "${GREEN}✓${NC} ${desc}: ${file}"
        return 0
    else
        echo -e "${RED}✗${NC} ${desc}: ${file} (missing)"
        return 1
    fi
}

test_executable() {
    local file="$1"
    local desc="$2"

    if [[ -x "${file}" ]]; then
        echo -e "${GREEN}✓${NC} ${desc}: ${file}"
        return 0
    else
        echo -e "${RED}✗${NC} ${desc}: ${file} (not executable)"
        return 1
    fi
}

test_command() {
    local cmd="$1"
    local desc="$2"

    if command -v "${cmd}" &> /dev/null; then
        echo -e "${GREEN}✓${NC} ${desc}: ${cmd}"
        return 0
    else
        echo -e "${RED}✗${NC} ${desc}: ${cmd} (not found)"
        return 1
    fi
}

# Check system requirements
echo "1. System Requirements"
echo "---------------------"
PREREQS=0

# Bash version
if [[ ${BASH_VERSINFO[0]} -ge 4 ]]; then
    echo -e "${GREEN}✓${NC} Bash version: ${BASH_VERSION}"
else
    echo -e "${RED}✗${NC} Bash version 4.4+ required (found: ${BASH_VERSION})"
    ((PREREQS++))
fi

# Ubuntu check (if available)
if [[ -f /etc/os-release ]]; then
    source /etc/os-release
    if [[ "${ID}" == "ubuntu" ]]; then
        echo -e "${GREEN}✓${NC} OS: ${NAME} ${VERSION_ID}"
    else
        echo -e "${YELLOW}!${NC} OS: ${NAME} (${ID}) - Ubuntu recommended"
    fi
fi

# Docker
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        echo -e "${GREEN}✓${NC} Docker: running"
    else
        echo -e "${YELLOW}!${NC} Docker: installed but not running"
    fi
else
    echo -e "${YELLOW}!${NC} Docker: not installed (optional for some modules)"
fi

echo ""

# Check project structure
echo "2. Project Structure"
echo "--------------------"
STRUCTURE=0

test_file "${SCRIPT_DIR}/devmachine" "Main CLI"
test_executable "${SCRIPT_DIR}/devmachine" "CLI executable"
test_file "${SCRIPT_DIR}/README.md" "Documentation"
test_file "${SCRIPT_DIR}/LICENSE" "License"
test_file "${SCRIPT_DIR}/SETUP.md" "Setup guide"
test_file "${SCRIPT_DIR}/.gitignore" "Git ignore"
test_file "${CONFIG_DIR}/devmachine.conf.example" "Config template"
test_executable "${AI_DIR}/ai_engine.sh" "AI engine"
test_executable "${AI_DIR}/validator.sh" "Validator"
test_executable "${AI_DIR}/sandbox.sh" "Sandbox"
test_executable "${AI_DIR}/providers/openai.sh" "OpenAI provider"

echo ""

# Check modules
echo "3. Modules"
echo "----------"
MODULES_DIR="${SCRIPT_DIR}/modules"
MODULES=0

for module in "${MODULES_DIR}"/*.sh; do
    if [[ -f "${module}" ]]; then
        local module_name="${module##*/}"
        if test_executable "${module}" "Module: ${module_name}"; then
            # Check if module has required functions
            if grep -q "install()" "${module}" && \
               grep -q "remove()" "${module}" && \
               grep -q "status()" "${module}; then
                echo -e "  ${GREEN}✓${NC} Required functions found"
            else
                echo -e "  ${RED}✗${NC} Missing required functions"
                ((MODULES++))
            fi
        else
            ((MODULES++))
        fi
    fi
done

echo ""

# Check CLI functionality
echo "4. CLI Tests"
echo "------------"
CLI_TESTS=0

# Test help
if "${SCRIPT_DIR}/devmachine" --help &> /dev/null; then
    echo -e "${GREEN}✓${NC} Help command works"
else
    echo -e "${RED}✗${NC} Help command failed"
    ((CLI_TESTS++))
fi

# Test version
if "${SCRIPT_DIR}/devmachine" --version &> /dev/null; then
    echo -e "${GREEN}✓${NC} Version command works"
else
    echo -e "${RED}✗${NC} Version command failed"
    ((CLI_TESTS++))
fi

# Test list
if "${SCRIPT_DIR}/devmachine" list &> /dev/null; then
    echo -e "${GREEN}✓${NC} List command works"
else
    echo -e "${RED}✗${NC} List command failed"
    ((CLI_TESTS++))
fi

echo ""

# Summary
echo "5. Summary"
echo "----------"
TOTAL_TESTS=$((PREREQS + STRUCTURE + MODULES + CLI_TESTS))

if [[ ${TOTAL_TESTS} -eq 0 ]]; then
    echo -e "${GREEN}All tests passed!${NC}"
    echo ""
    echo "DevMachine is ready to use!"
    echo ""
    echo "Next steps:"
    echo "1. Copy config: cp ${CONFIG_DIR}/devmachine.conf.example ~/.devmachine.conf"
    echo "2. Edit config with your AI API keys"
    echo "3. Run: devmachine doctor"
    echo "4. Try: devmachine list"
    exit 0
else
    echo -e "${RED}Some tests failed.${NC}"
    echo ""
    echo "Please fix the issues above before using DevMachine."
    exit 1
fi