#!/bin/bash

# =============================================================================
# Setup Installer - Central Entry Point
# =============================================================================
# Detects operating system and runs the appropriate setup script
#
# Usage: ./install.sh
# =============================================================================

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Progress tracking
readonly CHECK="✓"
readonly CROSS="✗"
readonly ARROW="➜"

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🚀 Development Environment Setup                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

print_info() {
    echo -e "${CYAN}${ARROW}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

detect_os() {
    local os_type=""
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    elif [[ -f /etc/os-release ]]; then
        if grep -q 'ubuntu\|debian' /etc/os-release; then
            os_type="ubuntu"
        elif grep -q 'arch' /etc/os-release; then
            os_type="arch"
        elif grep -q 'fedora' /etc/os-release; then
            os_type="fedora"
        else
            os_type="linux"
        fi
    else
        os_type="unknown"
    fi
    
    echo "$os_type"
}

main() {
    clear
    print_header
    
    local os=$(detect_os)
    print_info "Detected operating system: $os"
    echo ""
    
    case "$os" in
        "macos")
            if [[ -f "mac_setup.sh" ]]; then
                print_info "Running macOS setup..."
                chmod +x mac_setup.sh
                ./mac_setup.sh
            else
                print_error "mac_setup.sh not found!"
                exit 1
            fi
            ;;
        "ubuntu"|"debian")
            if [[ -f "ubuntu_setup.sh" ]]; then
                print_info "Running Ubuntu/Debian setup..."
                chmod +x ubuntu_setup.sh
                ./ubuntu_setup.sh
            else
                print_error "ubuntu_setup.sh not found!"
                exit 1
            fi
            ;;
        "arch")
            print_warning "Arch Linux detected but not yet supported"
            print_info "Consider running ubuntu_setup.sh and adapting for pacman"
            exit 1
            ;;
        "fedora")
            print_warning "Fedora detected but not yet supported"
            print_info "Consider running ubuntu_setup.sh and adapting for dnf"
            exit 1
            ;;
        *)
            print_error "Unsupported operating system: $os"
            print_info "Supported systems: macOS, Ubuntu, Debian"
            exit 1
            ;;
    esac
}

main "$@"
