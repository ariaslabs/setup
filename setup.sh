#!/bin/bash

# =============================================================================
# MacBook Setup Script
# =============================================================================
# This script installs common development tools and applications for macOS
# 
# Features:
#   - Smart installation (checks if already installed)
#   - Continues on individual failures
#   - Clean terminal output with progress indicators
#   - Easy to add/remove packages
#
# Usage: ./mac_setup.sh
# =============================================================================

# Clear terminal for clean start
clear

# =============================================================================
# Configuration Section - Easy to Update
# =============================================================================

# Package definitions using indexed arrays (bash 3.2 compatible)
# Format: "key|type|command|check|display_name"
declare -a PACKAGES=(
    "homebrew|script|install_homebrew|command -v brew|Homebrew"
    "oh-my-zsh|script|install_ohmyzsh|test -d ~/.oh-my-zsh|Oh My Zsh"
    "ollama|script|install_ollama|command -v ollama|Ollama"
    "bun|script|install_bun|command -v bun|Bun.js"
    "gh|brew|gh|command -v gh|GitHub CLI"
    "syncthing|brew|syncthing|command -v syncthing|Syncthing"
    "docker|cask|docker|brew list --cask docker|Docker Desktop"
    "vscodium|cask|vscodium|brew list --cask vscodium|VSCodium"
    "firefox|cask|firefox|brew list --cask firefox|Firefox"
    "spotify|cask|spotify|brew list --cask spotify|Spotify"
    "signal|cask|signal|brew list --cask signal|Signal"
    "discord|cask|discord|brew list --cask discord|Discord"
    "ghostty|cask|ghostty|brew list --cask ghostty|Ghostty"
    "raycast|cask|raycast|brew list --cask raycast|Raycast"
    "obsidian|cask|obsidian|brew list --cask obsidian|Obsidian"
    "qbittorrent|cask|qbittorrent|brew list --cask qbittorrent|qBittorrent"
    "eddie|cask|eddie|brew list --cask eddie|Eddie"
    "opencode|tap|anomalyco/tap/opencode|command -v opencode|OpenCode"
)

# =============================================================================
# Color and Formatting
# =============================================================================

# Colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Progress tracking
readonly CHECK="✓"
readonly CROSS="✗"
readonly ARROW="➜"
readonly WARN="⚠"
readonly INFO="ℹ"

# =============================================================================
# Output Functions
# =============================================================================

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                  🚀 MacBook Setup Script                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo ""
    echo -e "${BLUE}${BOLD}$1${NC}"
    echo -e "${BLUE}$(printf '=%.0s' $(seq 1 ${#1}))${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK}${NC} $1"
}

print_error() {
    echo -e "${RED}${CROSS}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}${WARN}${NC} $1"
}

print_info() {
    echo -e "${CYAN}${INFO}${NC} $1"
}

print_progress() {
    echo -e "${CYAN}${ARROW}${NC} $1"
}

# =============================================================================
# Installation Functions
# =============================================================================

install_homebrew() {
    if command -v brew &> /dev/null; then
        print_warning "Homebrew already installed, updating..."
        brew update
    else
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
}

install_ohmyzsh() {
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_warning "Oh My Zsh already installed"
    else
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

install_ollama() {
    curl -fsSL https://ollama.com/install.sh | sh
}

install_bun() {
    curl -fsSL https://bun.sh/install | bash
}

# =============================================================================
# Package Installation Logic
# =============================================================================

# Parse package info from PACKAGES array
# Returns: type|command|check|display_name
get_package_info() {
    local target_key="$1"
    local pkg_info
    
    for pkg_info in "${PACKAGES[@]}"; do
        local key="${pkg_info%%|*}"
        if [[ "$key" == "$target_key" ]]; then
            echo "${pkg_info#*|}"
            return 0
        fi
    done
    return 1
}

install_package() {
    local package_key="$1"
    local info
    
    info=$(get_package_info "$package_key")
    if [[ $? -ne 0 ]]; then
        print_error "Package not found: $package_key"
        return 1
    fi
    
    # Parse package info: type|command|check|display_name
    local type="${info%%|*}"
    info="${info#*|}"
    local command="${info%%|*}"
    info="${info#*|}"
    local check="${info%%|*}"
    local display_name="${info#*|}"
    
    print_progress "Installing ${display_name}..."
    
    # Check if already installed
    if eval "$check" &>/dev/null; then
        print_warning "${display_name} already installed"
        
        # Try to update if it's a brew package
        if [[ "$type" == "brew" ]]; then
            brew upgrade "$command" 2>/dev/null || true
        elif [[ "$type" == "cask" ]]; then
            brew upgrade --cask "$command" 2>/dev/null || true
        fi
        
        return 0
    fi
    
    # Install based on type
    local success=true
    case "$type" in
        "brew")
            brew install "$command" || success=false
            ;;
        "cask")
            brew install --cask "$command" || success=false
            ;;
        "tap")
            # Extract tap name from full package path
            local tap_name="${command%/*}"
            brew tap "$tap_name" 2>/dev/null || true
            brew install "$command" || success=false
            ;;
        "script")
            $command || success=false
            ;;
        *)
            print_error "Unknown package type: $type"
            success=false
            ;;
    esac
    
    if $success; then
        print_success "${display_name} installed"
        return 0
    else
        print_error "${display_name} installation failed"
        return 1
    fi
}

# =============================================================================
# Additional Setup Functions
# =============================================================================

configure_git() {
    print_section "Git Configuration"
    echo ""
    
    local git_name git_email
    
    read -p "Enter your Git name (or press Enter to skip): " git_name
    read -p "Enter your Git email (or press Enter to skip): " git_email
    
    if [[ -n "$git_name" && -n "$git_email" ]]; then
        git config --global user.name "$git_name"
        git config --global user.email "$git_email"
        print_success "Git configured: $git_name <$git_email>"
    else
        print_warning "Git configuration skipped"
    fi
}

rename_device() {
    print_section "Device Renaming"
    echo ""
    
    local current_name new_name
    current_name=$(scutil --get ComputerName)
    
    read -p "New device name (current: ${current_name}, Enter to keep): " new_name
    
    if [[ -n "$new_name" ]]; then
        sudo scutil --set ComputerName "$new_name"
        sudo scutil --set LocalHostName "$new_name"
        sudo scutil --set HostName "$new_name"
        print_success "Device renamed to: ${new_name}"
    else
        print_info "Keeping current name: ${current_name}"
    fi
}

# =============================================================================
# Summary and Reporting
# =============================================================================

print_summary() {
    print_section "Installation Summary"
    
    local success_count=0
    local fail_count=0
    local failed_packages=()
    local pkg_info
    
    for pkg_info in "${PACKAGES[@]}"; do
        # Skip if it's the homebrew entry (processed separately)
        local key="${pkg_info%%|*}"
        [[ "$key" == "homebrew" ]] && continue
        
        # Extract check command (4th field) and display name (5th field)
        local temp="${pkg_info#*|}"  # Remove key
        temp="${temp#*|}"            # Remove type
        temp="${temp#*|}"            # Remove command
        local check="${temp%%|*}"    # Get check
        local display_name="${temp#*|}" # Get display name
        
        if eval "$check" &>/dev/null; then
            print_success "$display_name"
            ((success_count++))
        else
            print_error "$display_name"
            ((fail_count++))
            failed_packages+=("$display_name")
        fi
    done
    
    echo ""
    print_info "Results: ${success_count} successful, ${fail_count} failed"
    
    if [[ $fail_count -gt 0 ]]; then
        echo ""
        print_warning "Failed installations: ${failed_packages[*]}"
        print_info "These can be manually installed later"
    fi
}

print_post_install_info() {
    print_section "Post-Installation Steps"
    
    print_info "Manual steps you may need to complete:"
    echo ""
    echo -e "  ${CYAN}•${NC} Docker: Launch Docker Desktop from Applications"
    echo -e "  ${CYAN}•${NC} GitHub CLI: Run 'gh auth login' to authenticate"
    echo -e "  ${CYAN}•${NC} Ollama: Run 'ollama run llama2' to download a model"
    echo -e "  ${CYAN}•${NC} Syncthing: Run 'brew services start syncthing'"
    echo -e "  ${CYAN}•${NC} Bun.js: Restart terminal or run 'source ~/.zshrc'"
    echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only!"
        exit 1
    fi
    
    # Print header
    print_header
    
    # Install packages
    print_section "Installing Packages"
    echo ""
    
    # Homebrew must be installed first and succeed
    install_package "homebrew"
    # Check if it actually installed/exists
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew installation failed - cannot continue"
        print_info "Please install Homebrew manually: https://brew.sh"
        exit 1
    fi
    
    # Install remaining packages
    local pkg_info
    for pkg_info in "${PACKAGES[@]}"; do
        local key="${pkg_info%%|*}"
        [[ "$key" == "homebrew" ]] && continue
        install_package "$key"
    done
    
    # Additional configuration
    configure_git
    rename_device
    
    # Print results
    print_summary
    print_post_install_info
    
    # Final message
    echo ""
    print_success "Setup complete! 🎉"
    echo ""
    print_info "You may need to restart your terminal for all changes to take effect"
    echo ""
}

# Run main function
main "$@"
