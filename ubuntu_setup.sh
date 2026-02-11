#!/bin/bash

# =============================================================================
# Ubuntu Setup Script
# =============================================================================
# This script installs common development tools and applications for Ubuntu
#
# Features:
#   - Smart installation (checks if already installed)
#   - Continues on individual failures
#   - Clean terminal output with progress indicators
#   - Easy to add/remove packages
#
# Usage: ./ubuntu_setup.sh
# =============================================================================

# Clear terminal for clean start
clear

# =============================================================================
# Configuration Section - Easy to Update
# =============================================================================

# List of packages to install (in order)
declare -a PACKAGES=(
    "update"        # Update package lists (must be first)
    "build-essential" # Build tools
    "git"           # Version control
    "curl"          # Download tool
    "wget"          # Download tool
    "zsh"           # Shell
    "oh-my-zsh"     # Shell enhancement
    "ollama"        # AI model runner
    "bun"           # JavaScript runtime
    "node"          # Node.js
    "gh"            # GitHub CLI
    "syncthing"     # File sync
    "docker"        # Container platform
    "vscodium"      # Code editor
    "firefox"       # Web browser
    "spotify"       # Music streaming
    "signal"        # Secure messaging
    "discord"       # Chat and voice
    "obsidian"      # Note-taking app
    "qbittorrent"   # BitTorrent client
    "eddie"         # VPN client
    "opencode"      # AI coding assistant
)

# Package metadata: install_command:check_command:display_name
# Format: "type:apt_install|snap_install|script:command:check:Display Name"
declare -A PACKAGE_INFO=(
    ["update"]="script:apt_update:echo 'done':System Update"
    ["build-essential"]="apt:build-essential:dpkg -l build-essential:Build Essential"
    ["git"]="apt:git:command -v git:Git"
    ["curl"]="apt:curl:command -v curl:cURL"
    ["wget"]="apt:wget:command -v wget:wget"
    ["zsh"]="apt:zsh:command -v zsh:Zsh Shell"
    ["oh-my-zsh"]="script:install_ohmyzsh:test -d ~/.oh-my-zsh:Oh My Zsh"
    ["ollama"]="script:install_ollama:command -v ollama:Ollama"
    ["bun"]="script:install_bun:command -v bun:Bun.js"
    ["node"]="script:install_node:command -v node:Node.js"
    ["gh"]="script:install_gh:command -v gh:GitHub CLI"
    ["syncthing"]="apt:syncthing:command -v syncthing:Syncthing"
    ["docker"]="script:install_docker:command -v docker:Docker"
    ["vscodium"]="script:install_vscodium:command -v codium:VSCodium"
    ["firefox"]="apt:firefox:command -v firefox:Firefox"
    ["spotify"]="snap:spotify:snap list spotify:Spotify"
    ["signal"]="snap:signal-desktop:snap list signal-desktop:Signal"
    ["discord"]="snap:discord:snap list discord:Discord"
    ["obsidian"]="snap:obsidian:snap list obsidian:Obsidian"
    ["qbittorrent"]="apt:qbittorrent:command -v qbittorrent:qBittorrent"
    ["eddie"]="script:install_eddie:dpkg -l eddie-ui:Eddie VPN"
    ["opencode"]="script:install_opencode:command -v opencode:OpenCode"
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
    echo "║                  🚀 Ubuntu Setup Script                      ║"
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

apt_update() {
    print_progress "Updating package lists..."
    sudo apt-get update
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

install_node() {
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
}

install_gh() {
    type -p curl >/dev/null || sudo apt-get install curl -y
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
    sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt-get update
    sudo apt-get install gh -y
}

install_docker() {
    # Add Docker's official GPG key
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # Install Docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    sudo usermod -aG docker $USER
}

install_vscodium() {
    wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
    echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list
    sudo apt update && sudo apt install codium -y
}

install_opencode() {
    curl -fsSL https://opencode.ai/install.sh | sh
}

install_eddie() {
    print_progress "Setting up Eddie VPN repository..."
    curl -fsSL https://eddie.website/repository/keys/eddie_maintainer_gpg.key | sudo tee /usr/share/keyrings/eddie.website-keyring.asc > /dev/null
    echo "deb [signed-by=/usr/share/keyrings/eddie.website-keyring.asc] http://eddie.website/repository/apt stable main" | sudo tee /etc/apt/sources.list.d/eddie.website.list
    sudo apt-get update
    sudo apt-get install -y eddie-ui
}

# =============================================================================
# Package Installation Logic
# =============================================================================

install_package() {
    local package_key="$1"
    local info="${PACKAGE_INFO[$package_key]}"
    
    # Parse package info: type:command:check:display_name
    local type="${info%%:*}"
    info="${info#*:}"
    local command="${info%%:*}"
    info="${info#*:}"
    local check="${info%%:*}"
    local display_name="${info#*:}"
    
    print_progress "Installing ${display_name}..."
    
    # Check if already installed
    if eval "$check" &>/dev/null; then
        print_warning "${display_name} already installed"
        
        # Try to update if it's an apt or snap package
        if [[ "$type" == "apt" ]]; then
            sudo apt-get upgrade "$command" -y 2>/dev/null || true
        elif [[ "$type" == "snap" ]]; then
            sudo snap refresh "$command" 2>/dev/null || true
        fi
        
        return 0
    fi
    
    # Install based on type
    local success=true
    case "$type" in
        "apt")
            sudo apt-get install "$command" -y || success=false
            ;;
        "snap")
            sudo snap install "$command" || success=false
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
    current_name=$(hostname)

    read -p "New device name (current: ${current_name}, Enter to keep): " new_name

    if [[ -n "$new_name" ]]; then
        sudo hostnamectl set-hostname "$new_name"
        # Also update /etc/hosts
        sudo sed -i "s/127.0.1.1.*/127.0.1.1 $new_name/" /etc/hosts
        print_success "Device renamed to: ${new_name}"
    else
        print_info "Keeping current name: ${current_name}"
    fi
}

set_avatar() {
    print_section "User Avatar"
    echo ""

    local avatar_path="assets/avatars/2E950491-E1D1-4C43-BB77-460EE76CE7BF_1_105_c.jpeg"

    if [[ ! -f "$avatar_path" ]]; then
        print_warning "Avatar file not found at $avatar_path"
        return 1
    fi

    # Copy avatar to proper location
    local user_icon_dir="$HOME/.icons"
    local dest_path="$user_icon_dir/avatar.jpeg"

    mkdir -p "$user_icon_dir"
    cp "$avatar_path" "$dest_path"

    # Set avatar using gsettings (GNOME/GTK environments)
    if command -v gsettings &> /dev/null; then
        gsettings set org.gnome.desktop.interface gtk-theme 'Yaru'
        # Set the avatar via AccountsService
        local account_icon_dir="/var/lib/AccountsService/icons/$USER"
        sudo cp "$dest_path" "$account_icon_dir" 2>/dev/null || {
            print_warning "Could not set system avatar, using local only"
        }
        print_success "Avatar set from $avatar_path"
    else
        print_info "Avatar copied to $dest_path"
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
    
    for package in "${PACKAGES[@]}"; do
        local info="${PACKAGE_INFO[$package]}"
        
        # Extract check command (3rd field)
        local temp="${info#*:}"  # Remove type
        temp="${temp#*:}"        # Remove command
        local check="${temp%%:*}" # Get check
        
        # Extract display name (4th field)
        local display_name="${info##*:}"
        
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
    echo -e "  ${CYAN}•${NC} Docker: Log out and back in for docker group to take effect"
    echo -e "  ${CYAN}•${NC} GitHub CLI: Run 'gh auth login' to authenticate"
    echo -e "  ${CYAN}•${NC} Ollama: Run 'ollama run llama2' to download a model"
    echo -e "  ${CYAN}•${NC} Syncthing: Run 'sudo systemctl enable --now syncthing@$USER.service'"
    echo -e "  ${CYAN}•${NC} Bun.js: Restart terminal or run 'source ~/.bashrc'"
    echo -e "  ${CYAN}•${NC} Oh My Zsh: Run 'chsh -s $(which zsh)' to set as default shell"
    echo ""
}

# =============================================================================
# Main Script
# =============================================================================

main() {
    # Check Linux/Ubuntu
    if [[ ! -f /etc/os-release ]] || ! grep -q 'ubuntu\|debian' /etc/os-release; then
        print_warning "This script is designed for Ubuntu/Debian!"
        read -p "Continue anyway? (y/N): " continue_anyway
        [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]] && exit 1
    fi

    # Print header
    print_header

    # Install packages
    print_section "Installing Packages"
    echo ""

    # Install all packages
    for package in "${PACKAGES[@]}"; do
        install_package "$package"
    done

    # Additional configuration
    configure_git
    rename_device
    set_avatar

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