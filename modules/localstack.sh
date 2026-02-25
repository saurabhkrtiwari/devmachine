#!/bin/bash

# LocalStack Module - AWS Cloud environment emulator for local development

readonly MODULE_NAME="localstack"
readonly DOWNLOAD_DIR="${HOME}/Downloads"
readonly CONFIG_DIR="${HOME}/.devmachine/${MODULE_NAME}"
readonly VOLUME_NAME="localstack-data"

# Utility functions
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*"; }
log_error() { echo "[ERROR] $*"; }
log_success() { echo "[SUCCESS] $*"; }

# Check if Docker is available
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker is required but not installed"
        return 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker daemon is not running"
        return 1
    fi
    return 0
}

# Check if LocalStack is already running
check_running() {
    if docker ps --format "table {{.Names}}" | grep -q "^localstack$"; then
        return 0
    fi
    return 1
}

# Check if LocalStack is installed
check_installed() {
    if docker images --format "table {{.Repository}}" | grep -q "^localstack$"; then
        return 0
    fi
    return 1
}

# Check LocalStack status
check_status() {
    if ! check_docker; then
        echo "Status: Docker not available"
        return 1
    fi

    if check_running; then
        echo "Status: Running"
        echo "Container ID: $(docker ps --format "{{.ID}}" --filter "name=^localstack$")"
        echo "Port: 4566"
        echo "Logs: docker logs localstack"
    elif check_installed; then
        echo "Status: Installed but not running"
        echo "Start with: devmachine add localstack"
    else
        echo "Status: Not installed"
        return 1
    fi
}

# Install LocalStack
install_localstack() {
    log_info "Installing LocalStack..."

    # Check if running with sudo for Docker operations
    if [[ "${EUID}" -eq 0 ]]; then
        log_warn "Running as root. Docker operations may have permission issues."
        log_warn "Consider running without sudo for LocalStack operations."
    fi

    # Create config directory
    mkdir -p "${CONFIG_DIR}"

    # Create default configuration
    cat > "${CONFIG_DIR}/docker-compose.yml" << EOF
version: '3.8'
services:
  localstack:
    image: localstack/localstack:latest
    container_name: localstack
    ports:
      - "4566:4566"
      - "4571:4571"
    environment:
      - SERVICES=s3,sqs,lambda,dynamodb,ec2,cloudformation
      - DEBUG=1
      - DATA_DIR=/tmp/localstack
    volumes:
      - localstack-data:/tmp/localstack
    restart: unless-stopped

volumes:
  localstack-data:
EOF

    log_success "LocalStack configuration created"
    log_info "Configuration file: ${CONFIG_DIR}/docker-compose.yml"
}

# Start LocalStack
start_localstack() {
    if check_running; then
        log_info "LocalStack is already running"
        return 0
    fi

    if ! check_installed; then
        log_info "Installing LocalStack first..."
        install_localstack
    fi

    log_info "Starting LocalStack..."

    # Navigate to config directory
    cd "${CONFIG_DIR}"

    # Start with docker-compose
    if command -v docker-compose &> /dev/null; then
        docker-compose up -d
    else
        # Use docker compose for newer versions
        docker compose up -d
    fi

    # Wait for startup
    log_info "Waiting for LocalStack to start..."
    sleep 10

    if check_running; then
        log_success "LocalStack started successfully"
        log_info "Endpoint: http://localhost:4566"
        log_info "AWS CLI: aws --endpoint-url=http://localhost:4566 s3 ls"
    else
        log_error "Failed to start LocalStack"
        log_error "Check logs: docker logs localstack"
        return 1
    fi
}

# Stop LocalStack
stop_localstack() {
    if ! check_running; then
        log_info "LocalStack is not running"
        return 0
    fi

    log_info "Stopping LocalStack..."

    cd "${CONFIG_DIR}"

    if command -v docker-compose &> /dev/null; then
        docker-compose down
    else
        docker compose down
    fi

    log_success "LocalStack stopped"
}

# Remove LocalStack
remove_localstack() {
    if ! check_installed; then
        log_info "LocalStack is not installed"
        return 0
    fi

    # Stop if running
    if check_running; then
        read -p "LocalStack is running. Stop it now? (y/N): " stop_confirm
        if [[ "${stop_confirm}" =~ ^[Yy]$ ]]; then
            stop_localstack
        else
            log_error "Please stop LocalStack first"
            return 1
        fi
    fi

    # Ask about data deletion
    read -p "Delete LocalStack data volume? This will remove all stored data. (y/N): " delete_confirm
    if [[ "${delete_confirm}" =~ ^[Yy]$ ]]; then
        log_info "Removing LocalStack container and data..."

        cd "${CONFIG_DIR}"

        if command -v docker-compose &> /dev/null; then
            docker-compose down -v
        else
            docker compose down -v
        fi

        # Remove image
        docker rmi localstack/localstack:latest 2>/dev/null || true
    else
        log_info "Removing LocalStack container only..."

        cd "${CONFIG_DIR}"

        if command -v docker-compose &> /dev/null; then
            docker-compose down
        else
            docker compose down
        fi
    fi

    # Remove config directory
    rm -rf "${CONFIG_DIR}"

    log_success "LocalStack removed"
}

# Main module interface
install() {
    local action="${1:-install}"

    if ! check_docker; then
        return 1
    fi

    case "${action}" in
        start)
            start_localstack
            ;;
        stop)
            stop_localstack
            ;;
        restart)
            stop_localstack
            start_localstack
            ;;
        install)
            install_localstack
            start_localstack
            ;;
        *)
            echo "Usage: localstack {install|start|stop|restart}"
            return 1
            ;;
    esac
}

remove() {
    local confirm=""
    read -p "Remove LocalStack completely? This will delete all data. (y/N): " confirm
    [[ "${confirm}" =~ ^[Yy]$ ]] || return 0

    remove_localstack
}

status() {
    check_status
}

# Entry point for direct execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        install|remove|status)
            "$@"
            ;;
        start|stop|restart)
            install "$@"
            ;;
        *)
            echo "LocalStack Module for DevMachine"
            echo "Usage: ${0} {install|start|stop|restart|remove|status}"
            exit 1
            ;;
    esac
fi