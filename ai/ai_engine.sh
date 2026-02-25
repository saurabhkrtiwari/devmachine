#!/bin/bash

# AI Engine - Core functionality for AI-powered module generation

readonly AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROVIDERS_DIR="${AI_DIR}/providers"
readonly TMP_DIR="${AI_DIR}/../tmp"
readonly MODULES_DIR="${AI_DIR}/../modules"

# Utility functions
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; }
log_success() { echo "[SUCCESS] $*"; }

# Generate module using AI
ai_generate_module() {
    local prompt="$1"
    local module_name=""
    local safe_prompt="Create a ${prompt} module for DevMachine. The module must implement install(), remove(), and status() functions."

    # Generate module name from prompt
    module_name=$(echo "${prompt}" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//g' | sed 's/-$//g')
    module_name="${module_name// /-}.sh"

    log_info "Generating module: ${module_name}"

    # Generate AI content
    local ai_output
    if ! ai_output=$(ai_generate "${safe_prompt}"); then
        log_error "Failed to generate module content"
        return 1
    fi

    # Save to temp file
    local temp_module="${TMP_DIR}/${module_name}"
    echo "${ai_output}" > "${temp_module}"

    # Validate the generated module
    if ! validate_module "${temp_module}"; then
        log_error "Generated module failed validation"
        rm -f "${temp_module}"
        return 1
    fi

    # Sandbox test
    if ! sandbox_test "${temp_module}"; then
        log_error "Generated module failed sandbox test"
        rm -f "${temp_module}"
        return 1
    fi

    # Move to modules directory
    if mv "${temp_module}" "${MODULES_DIR}/${module_name}"; then
        chmod +x "${MODULES_DIR}/${module_name}"
        log_success "Module generated successfully: ${module_name}"
        log_info "Available for use: devmachine add ${module_name%.sh}"
    else
        log_error "Failed to move module to production directory"
        rm -f "${temp_module}"
        return 1
    fi
}

# Generate AI content
ai_generate() {
    local prompt="$1"

    # Load provider configuration
    if ! load_config; then
        log_error "Failed to load configuration"
        return 1
    fi

    if [[ -z "${CONFIG_AI_PROVIDER:-}" ]]; then
        log_error "AI provider not configured"
        return 1
    fi

    local provider_script="${PROVIDERS_DIR}/${CONFIG_AI_PROVIDER}.sh"
    if [[ ! -f "${provider_script}" ]]; then
        log_error "AI provider not found: ${CONFIG_AI_PROVIDER}"
        return 1
    fi

    # Execute provider
    source "${provider_script}"
    if ! ai_generate_content "${prompt}"; then
        return 1
    fi
}

# Validate module structure and safety
validate_module() {
    local module_path="$1"

    log_info "Validating module: ${module_path}"

    # Check file exists
    if [[ ! -f "${module_path}" ]]; then
        log_error "Module file not found: ${module_path}"
        return 1
    fi

    # Check if file is executable
    chmod +x "${module_path}"

    # Check required functions
    local required_functions=("install" "remove" "status")
    for func in "${required_functions[@]}"; do
        if ! grep -q "^${func}()" "${module_path}"; then
            log_error "Required function missing: ${func}()"
            return 1
        fi
    done

    # Check bash syntax
    if ! bash -n "${module_path}"; then
        log_error "Bash syntax errors found in module"
        return 1
    fi

    # Check for dangerous patterns
    local dangerous_patterns=(
        "rm -rf /"
        "mkfs"
        "dd if="
        ":(){ :|:& };:"  # Fork bomb
        "wget.*-O-.*|bash"
        "curl.*|bash"
        "exec.*bash"
        "sudo.*rm"
        "system.*rm"
    )

    for pattern in "${dangerous_patterns[@]}"; do
        if grep -q "${pattern}" "${module_path}"; then
            log_error "Dangerous pattern found: ${pattern}"
            return 1
        fi
    done

    # Check for hardcoded credentials
    if grep -q -E "password|secret|token|key|auth" "${module_path}"; then
        log_warn "Potential credentials found in module - review manually"
    fi

    log_success "Module validation passed"
    return 0
}

# Sandbox test module functions
sandbox_test() {
    local module_path="$1"

    log_info "Running sandbox test: ${module_path}"

    # Create sandbox environment
    local sandbox_dir="${TMP_DIR}/sandbox"
    mkdir -p "${sandbox_dir}"

    # Create mock commands
    cat > "${sandbox_dir}/mock_sudo" << 'EOF'
#!/bin/bash
echo "MOCK: sudo $*"
exit 0
EOF
    chmod +x "${sandbox_dir}/mock_sudo"

    cat > "${sandbox_dir}/mock_rm" << 'EOF'
#!/bin/bash
echo "MOCK: rm $*"
# Block dangerous patterns
if [[ "$*" == *" -rf "* && "$*" == *" /"* ]]; then
    echo "ERROR: Attempting to delete root directory"
    exit 1
fi
exit 0
EOF
    chmod +x "${sandbox_dir}/mock_rm"

    cat > "${sandbox_dir}/mock_docker" << 'EOF'
#!/bin/bash
echo "MOCK: docker $*"
exit 0
EOF
    chmod +x "${sandbox_dir}/mock_docker"

    # Test each function in dry-run mode
    local functions=("install" "remove" "status")
    local test_result=0

    for func in "${functions[@]}"; do
        log_info "Testing function: ${func}"

        # Create test script
        cat > "${sandbox_dir}/test_${func}.sh" << EOF
#!/bin/bash
# Override PATH to use mock commands
export PATH="${sandbox_dir}:\${PATH}"
export SUDO_ASKPASS="${sandbox_dir}/mock_sudo"

# Mock important commands
source "${module_path}"

# Call function with dummy arguments
${func} --dry-run
EOF

        # Execute test
        if ! bash "${sandbox_dir}/test_${func}.sh" &> "${sandbox_dir}/test_${func}.log"; then
            log_error "Function ${func} failed sandbox test"
            log_error "Test log:"
            cat "${sandbox_dir}/test_${func}.log"
            test_result=1
            break
        fi
    done

    # Clean up
    rm -rf "${sandbox_dir}"

    if [[ ${test_result} -eq 0 ]]; then
        log_success "Sandbox test passed"
    fi

    return ${test_result}
}

# Load configuration
load_config() {
    local config_file="${AI_DIR}/../config/devmachine.conf"
    if [[ ! -f "${config_file}" ]]; then
        log_error "Configuration file not found: ${config_file}"
        return 1
    fi

    while IFS='=' read -r key value; do
        [[ -z "${key}" || "${key}" =~ ^[[:space:]]*# ]] && continue
        value="${value%\"}"
        value="${value#\"}"
        declare -g "CONFIG_${key}=${value}"
    done < "${config_file}"
}

# Entry point for direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo "AI Engine for DevMachine"
    echo "This is not meant to be executed directly."
    exit 1
fi