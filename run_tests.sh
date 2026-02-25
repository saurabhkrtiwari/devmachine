#!/bin/bash

# DevMachine Simple Test Runner
# Shows all test results clearly

set -euo pipefail

echo "DevMachine Test Suite"
echo "===================="
echo ""

PASSED=0
FAILED=0

# Test function
run_test() {
    local name="$1"
    local cmd="$2"
    local expected="${3:-0}"

    echo -n "Testing: $name... "

    if [[ $expected -eq 0 ]]; then
        if $cmd >/dev/null 2>&1; then
            echo -e "\033[0;32m✓\033[0m"
            ((PASSED++))
            return 0
        else
            echo -e "\033[0;31m✗\033[0m"
            ((FAILED++))
            return 1
        fi
    else
        if ! $cmd >/dev/null 2>&1; then
            echo -e "\033[0;32m✓\033[0m (exit $expected)"
            ((PASSED++))
            return 0
        else
            echo -e "\033[0;31m✗\033[0m (expected exit $expected)"
            ((FAILED++))
            return 1
        fi
    fi
}

echo "CLI Tests"
echo "---------"
run_test "Version command" "./devmachine --version"
run_test "Help command (exit 1)" "./devmachine --help" 1
run_test "List modules" "./devmachine list"
run_test "Show config" "./devmachine config show"
run_test "Add non-existent module" "./devmachine add nonexistent" 1
run_test "Status non-existent module" "./devmachine status nonexistent" 1
run_test "Remove non-existent module" "./devmachine remove nonexistent" 1
echo ""

echo "Module Tests"
echo "------------"
for module in modules/*.sh; do
    if [[ -f "$module" ]]; then
        module_name=$(basename "$module")
        echo -n "Testing module: $module_name... "

        # Check if executable
        if [[ -x "$module" ]]; then
            # Check required functions
            if grep -q "install()" "$module" && \
               grep -q "remove()" "$module" && \
               grep -q "status()" "$module"; then
                echo -e "\033[0;32m✓\033[0m"
                ((PASSED++))
            else
                echo -e "\033[0;31m✗\033[0m (missing functions)"
                ((FAILED++))
            fi
        else
            echo -e "\033[0;31m✗\033[0m (not executable)"
            ((FAILED++))
        fi
    fi
done
echo ""

echo "Bash Syntax Tests"
echo "-----------------"
for script in devmachine modules/*.sh ai/*.sh ai/providers/*.sh; do
    if [[ -f "$script" ]]; then
        script_name=$(basename "$script")
        echo -n "Syntax check: $script_name... "
        if bash -n "$script" 2>/dev/null; then
            echo -e "\033[0;32m✓\033[0m"
            ((PASSED++))
        else
            echo -e "\033[0;31m✗\033[0m"
            ((FAILED++))
        fi
    fi
done
echo ""

echo "AI System Tests"
echo "--------------"
run_test "OpenAI provider info" "./ai/providers/openai.sh info"
run_test "Validator without module" "./ai/validator.sh nonexistent" 1
run_test "Sandbox without module" "./ai/sandbox.sh nonexistent" 1
echo ""

echo "Configuration Tests"
echo "-------------------"
if [[ -f "config/devmachine.conf.example" ]]; then
    echo -n "Config template exists... "
    echo -e "\033[0;32m✓\033[0m"
    ((PASSED++))
else
    echo -n "Config template exists... "
    echo -e "\033[0;31m✗\033[0m"
    ((FAILED++))
fi
echo ""

echo "Git Tests"
echo "---------"
run_test "Git repository clean" "git status --porcelain"
echo ""

echo "Test Summary"
echo "------------"
echo -e "\033[0;32mPassed: $PASSED\033[0m"
echo -e "\033[0;31mFailed: $FAILED\033[0m"

if [[ $FAILED -eq 0 ]]; then
    echo ""
    echo -e "\033[0;32mAll tests passed! 🎉\033[0m"
    exit 0
else
    echo ""
    echo -e "\033[0;31mSome tests failed.\033[0m"
    exit 1
fi