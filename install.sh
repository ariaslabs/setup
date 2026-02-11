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

check_and_install_zsh() {
    print_info "Checking for zsh..."
    
    if command -v zsh &> /dev/null; then
        print_success "Zsh is already installed: $(which zsh)"
        
        # Set as default if not already
        local current_shell=$(basename "$SHELL")
        if [[ "$current_shell" != "zsh" ]]; then
            print_info "Setting zsh as default shell..."
            chsh -s "$(which zsh)"
            print_success "Zsh set as default shell (will take effect after next login)"
        fi
        return 0
    fi
    
    print_warning "Zsh not found. Installing..."
    local os=$(detect_os)
    
    case "$os" in
        "macos")
            if ! command -v brew &> /dev/null; then
                print_info "Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                if [[ $(uname -m) == 'arm64' ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi
            brew install zsh
            ;;
        "ubuntu"|"debian"|"linux")
            print_info "Installing zsh via apt..."
            sudo apt-get update
            sudo apt-get install -y zsh
            ;;
        *)
            print_error "Cannot install zsh on unsupported OS: $os"
            exit 1
            ;;
    esac
    
    # Verify and set as default
    if command -v zsh &> /dev/null; then
        print_success "Zsh installed: $(which zsh)"
        print_info "Setting zsh as default shell..."
        chsh -s "$(which zsh)"
        print_success "Zsh set as default (will take effect after next login)"
    else
        print_error "Zsh installation failed"
        exit 1
    fi
}

main() {
    clear
    print_header
    
    local os=$(detect_os)
    print_info "Detected operating system: $os"
    echo ""
    
    # Check and install zsh first
    check_and_install_zsh
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
