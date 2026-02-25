#!/bin/bash

# JDK Module - Installation and management for Java Development Kits
# Supports versions: 17, 21, 25

readonly MODULE_NAME="jdk"
readonly DOWNLOAD_DIR="${HOME}/Downloads"
readonly INSTALL_DIR="/opt/${MODULE_NAME}"
readonly PROFILE_D_FILE="/etc/profile.d/dev-env-${MODULE_NAME}.sh"

# Utility functions
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; }
log_success() { echo "[SUCCESS] $*"; }

# Check if JDK is already installed
check_installed() {
    local version="$1"
    local java_path="${INSTALL_DIR}/jdk-${version}/bin/java"

    if [[ -x "${java_path}" ]]; then
        if "${java_path}" -version &> /dev/null; then
            log_success "JDK ${version} is already installed"
            return 0
        fi
    fi
    return 1
}

# Install JDK version
install_jdk() {
    local version="$1"
    local jdk_url=""
    local jdk_file=""

    case "${version}" in
        17)
            jdk_url="https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.tar.gz"
            jdk_file="jdk-17_linux-x64_bin.tar.gz"
            ;;
        21)
            jdk_url="https://download.oracle.com/java/21/latest/jdk-21_linux-x64_bin.tar.gz"
            jdk_file="jdk-21_linux-x64_bin.tar.gz"
            ;;
        25)
            jdk_url="https://download.oracle.com/java/25/latest/jdk-25_linux-x64_bin.tar.gz"
            jdk_file="jdk-25_linux-x64_bin.tar.gz"
            ;;
        *)
            log_error "Unsupported JDK version: ${version}"
            log_error "Supported versions: 17, 21, 25"
            return 1
            ;;
    esac

    # Check if already installed
    if check_installed "${version}"; then
        read -p "JDK ${version} is already installed. Reinstall? (y/N): " reinstall
        [[ "${reinstall}" =~ ^[Yy]$ ]] || return 0
    fi

    log_info "Installing JDK ${version}..."

    # Create directories
    mkdir -p "${DOWNLOAD_DIR}" "${INSTALL_DIR}"

    # Download JDK
    log_info "Downloading JDK ${version}..."
    if ! curl -L -o "${DOWNLOAD_DIR}/${jdk_file}" "${jdk_url}"; then
        log_error "Failed to download JDK ${version}"
        return 1
    fi

    # Extract JDK
    log_info "Extracting JDK ${version}..."
    if ! tar -xzf "${DOWNLOAD_DIR}/${jdk_file}" -C "${INSTALL_DIR}"; then
        log_error "Failed to extract JDK ${version}"
        return 1
    fi

    # Clean up
    rm -f "${DOWNLOAD_DIR}/${jdk_file}"

    # Create profile file
    local jdk_path="${INSTALL_DIR}/jdk-${version}"
    cat > "${PROFILE_D_FILE}" << EOF
# JDK ${version} environment variables
export JAVA_HOME="${jdk_path}"
export PATH="\${JAVA_HOME}/bin:\${PATH}"
EOF

    log_success "JDK ${version} installed successfully"
    log_info "Source your profile to use JAVA_HOME: source ~/.bashrc"
}

# Remove JDK version
remove_jdk() {
    local version="$1"
    local jdk_path="${INSTALL_DIR}/jdk-${version}"

    if [[ ! -d "${jdk_path}" ]]; then
        log_warn "JDK ${version} is not installed"
        return 0
    fi

    read -p "Remove JDK ${version} from ${jdk_path}? (y/N): " confirm
    [[ "${confirm}" =~ ^[Yy]$ ]] || return 0

    log_info "Removing JDK ${version}..."

    # Remove installation
    sudo rm -rf "${jdk_path}"

    # Remove profile file if it only contains this JDK
    if [[ -f "${PROFILE_D_FILE}" ]]; then
        if grep -q "export JAVA_HOME=\"${jdk_path}\"" "${PROFILE_D_FILE}"; then
            sudo rm -f "${PROFILE_D_FILE}"
        fi
    fi

    log_success "JDK ${version} removed successfully"
}

# Check JDK status
check_jdk_status() {
    local version="$1"
    local jdk_path="${INSTALL_DIR}/jdk-${version}"

    if [[ ! -d "${jdk_path}" ]]; then
        echo "Status: Not installed"
        return 1
    fi

    local java_path="${jdk_path}/bin/java"
    if [[ ! -x "${java_path}" ]]; then
        echo "Status: Installation corrupted"
        return 1
    fi

    local version_output
    version_output=$("${java_path}" -version 2>&1)
    echo "Status: Installed"
    echo "Version: ${version_output}"
    echo "Java Home: ${jdk_path}"
    echo "Path: ${java_path}"
}

# Main module interface
install() {
    local version="${1:-}"

    if [[ -z "${version}" ]]; then
        echo "Usage: jdk install <version>"
        echo "Supported versions: 17, 21, 25"
        return 1
    fi

    # Check if running with sudo
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "Please run with sudo for installation"
        return 1
    fi

    install_jdk "${version}"
}

remove() {
    local version="${1:-}"

    if [[ -z "${version}" ]]; then
        echo "Usage: jdk remove <version>"
        echo "Supported versions: 17, 21, 25"
        return 1
    fi

    # Check if running with sudo
    if [[ "${EUID}" -ne 0 ]]; then
        log_error "Please run with sudo for removal"
        return 1
    fi

    remove_jdk "${version}"
}

status() {
    local version="${1:-}"

    if [[ -z "${version}" ]]; then
        echo "Usage: jdk status <version>"
        echo "Supported versions: 17, 21, 25"
        return 1
    fi

    check_jdk_status "${version}"
}

# Entry point for direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        install|remove|status)
            "$@"
            ;;
        *)
            echo "JDK Module for DevMachine"
            echo "Usage: ${0} {install|remove|status} <version>"
            exit 1
            ;;
    esac
fi