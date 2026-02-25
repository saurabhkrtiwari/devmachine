#!/bin/bash

# DevMachine Installation Script
# For end users to install DevMachine on their system

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
INSTALL_DIR="${HOME}/devmachine"
BIN_DIR="${HOME}/bin"
CONFIG_DIR="${HOME}/.config/devmachine"

# Utility functions
log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }

# Check if running on Ubuntu
check_os() {
    if [[ ! -f /etc/os-release ]]; then
        log_warn "Cannot detect OS. Installation may proceed but with no guarantees."
        return 0
    fi

    source /etc/os-release
    if [[ "${ID}" != "ubuntu" ]]; then
        log_warn "This script is designed for Ubuntu Linux."
        log_warn "You're running: ${NAME} ${VERSION_ID}"
        log_warn "Some features may not work as expected."
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled."
            exit 1
        fi
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    local missing=()

    # Check Bash version
    if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
        missing+=("Bash 4.4+ (found: ${BASH_VERSION})")
    fi

    # Check required commands
    for cmd in curl wget tar unzip; do
        if ! command -v "${cmd}" &> /dev/null; then
            missing+=("${cmd}")
        fi
    done

    # Check Docker (optional)
    if ! command -v docker &> /dev/null; then
        log_warn "Docker is not installed. Some modules may not work."
    fi

    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing prerequisites:"
        for item in "${missing[@]}"; do
            echo "  - ${item}"
        done
        echo ""
        log_error "Please install missing prerequisites and try again."
        exit 1
    fi

    log_success "All prerequisites met."
}

# Clone repository
clone_repository() {
    log_info "Cloning DevMachine repository..."

    if [[ -d "${INSTALL_DIR}" ]]; then
        log_error "${INSTALL_DIR} already exists."
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_error "Installation cancelled."
            exit 1
        fi
        rm -rf "${INSTALL_DIR}"
    fi

    if ! git clone https://github.com/saurabhkrtiwari/devmachine.git "${INSTALL_DIR}"; then
        log_error "Failed to clone repository."
        exit 1
    fi

    log_success "Repository cloned to ${INSTALL_DIR}"
}

# Create configuration
create_config() {
    log_info "Creating configuration..."

    mkdir -p "${CONFIG_DIR}"

    if [[ ! -f "${CONFIG_DIR}/devmachine.conf" ]]; then
        cp "${INSTALL_DIR}/config/devmachine.conf.example" "${CONFIG_DIR}/devmachine.conf"
        log_info "Created configuration file: ${CONFIG_DIR}/devmachine.conf"
        log_info "Please edit this file to configure your AI provider."
    fi
}

# Make scripts executable
make_executable() {
    log_info "Making scripts executable..."

    chmod +x "${INSTALL_DIR}/devmachine"
    chmod +x "${INSTALL_DIR}/modules"/*.sh
    chmod +x "${INSTALL_DIR}/ai"/*.sh
    chmod +x "${INSTALL_DIR}/ai/providers"/*.sh
    chmod +x "${INSTALL_DIR}/"*.sh

    log_success "All scripts made executable."
}

# Create bin directory and symlink
install_bin() {
    log_info "Installing DevMachine to PATH..."

    # Create bin directory if it doesn't exist
    mkdir -p "${BIN_DIR}"

    # Create symlink
    if [[ -L "${BIN_DIR}/devmachine" ]]; then
        rm "${BIN_DIR}/devmachine"
    fi

    ln -sf "${INSTALL_DIR}/devmachine" "${BIN_DIR}/devmachine"

    # Add to PATH if not already there
    if ! grep -q "${BIN_DIR}" ~/.bashrc 2>/dev/null; then
        echo "" >> ~/.bashrc
        echo "# DevMachine CLI" >> ~/.bashrc
        echo "export PATH=\"${BIN_DIR}:\${PATH}\"" >> ~/.bashrc
        log_info "Added ${BIN_DIR} to PATH in ~/.bashrc"
    fi

    log_success "DevMachine installed to ${BIN_DIR}/devmachine"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."

    # Check if devmachine is in PATH
    if ! command -v devmachine &> /dev/null; then
        log_error "devmachine not found in PATH."
        log_info "Please run: source ~/.bashrc"
        return 1
    fi

    # Check version
    local version
    version=$(devmachine --version 2>/dev/null | head -n1)
    if [[ -n "${version}" ]]; then
        log_success "DevMachine version: ${version}"
    else
        log_error "Failed to get version."
        return 1
    fi

    # Check help
    if devmachine --help &> /dev/null; then
        log_success "Help command works."
    else
        log_warn "Help command has unexpected behavior (expected)."
    fi

    log_success "Installation verified!"
}

# Run initial setup
initial_setup() {
    log_info "Running initial setup..."

    cd "${INSTALL_DIR}"

    # Run verification
    if ./verify_setup.sh > /dev/null 2>&1; then
        log_success "System checks passed."
    else
        log_warn "Some system checks failed. Check the logs for details."
    fi

    # Run doctor
    log_info "Running system diagnostics..."
    if devmachine doctor &> /dev/null; then
        log_success "System diagnostics passed."
    else
        log_warn "System diagnostics found some issues."
    fi
}

# Main installation
main() {
    echo ""
    echo "🚀 DevMachine Installation"
    echo "========================"
    echo ""

    # Check if already installed
    if command -v devmachine &> /dev/null; then
        log_error "DevMachine is already installed."
        log_info "Version: $(devmachine --version 2>/dev/null)"
        read -p "Do you want to reinstall? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 0
        fi
    fi

    # Run installation steps
    check_os
    echo ""
    check_prerequisites
    echo ""
    clone_repository
    echo ""
    create_config
    echo ""
    make_executable
    echo ""
    install_bin
    echo ""
    verify_installation
    echo ""
    initial_setup
    echo ""

    # Show next steps
    log_success "🎉 DevMachine installed successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Configure your AI provider:"
    echo "   nano ${CONFIG_DIR}/devmachine.conf"
    echo ""
    echo "2. Source your bashrc to update PATH:"
    echo "   source ~/.bashrc"
    echo ""
    echo "3. Try DevMachine:"
    echo "   devmachine --version"
    echo "   devmachine list"
    echo "   devmachine doctor"
    echo ""
    echo "4. Install your first tool:"
    echo "   sudo devmachine add jdk 21"
    echo ""
    echo "For more information, see: ${INSTALL_DIR}/README.md"
}

# Run main function
main "$@"