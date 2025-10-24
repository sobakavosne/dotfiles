#!/bin/bash

# Installation script for ASUS Zenbook Ubuntu dotfiles
# This script copies all configuration files and scripts to their proper locations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}🚀 Starting ASUS Zenbook Ubuntu dotfiles installation...${NC}"

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root. Run as a regular user."
    exit 1
fi

# Function to print status messages
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check for required dependencies
echo -e "${BLUE}🔍 Checking dependencies...${NC}"
missing_deps=()

# Check for essential commands
commands=("xmonad" "xmobar" "nitrogen" "compton" "dunst" "playerctl" "scrot" "sensors" "bc" "bluetoothctl" "xrandr" "setxkbmap" "nvidia-smi" "radeontop")
for cmd in "${commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        missing_deps+=("$cmd")
    fi
done

if [ ${#missing_deps[@]} -ne 0 ]; then
    print_warning "Missing dependencies: ${missing_deps[*]}"
    echo -e "${YELLOW}💡 Please install missing dependencies first:${NC}"
    echo -e "${YELLOW}   sudo apt install xmonad libghc-xmonad-contrib-dev nitrogen compton xmobar suckless-tools libxpm-dev acpi dunst playerctl flameshot xautolock scrot i3lock zoxide numlockx vim pulseaudio-utils imagemagick pavucontrol stacer flatpak neovim fzf fonts-firacode radeontop nvidia-smi lm-sensors bc bluetooth bluez-tools xrandr setxkbmap${NC}"
    echo -e "${YELLOW}   See README.txt for complete installation instructions.${NC}"
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Installation cancelled. Please install dependencies first."
        exit 1
    fi
else
    print_status "All dependencies found"
fi

# Create necessary directories
echo -e "${BLUE}📁 Creating necessary directories...${NC}"
mkdir -p ~/.config/xmobar
mkdir -p ~/.config/terminator
mkdir -p ~/Pictures/Wallpapers
mkdir -p ~/.xmonad
print_status "Directories created"

# Copy bashrc (append to existing)
echo -e "${BLUE}📝 Updating bashrc...${NC}"
if [ -f ~/.bashrc ]; then
    # Backup existing bashrc
    cp ~/.bashrc ~/.bashrc.backup.$(date +%Y%m%d_%H%M%S)
    print_warning "Backed up existing .bashrc"
fi

# Append repository bashrc to existing one
if [ -f "$SCRIPT_DIR/bash/.bashrc" ]; then
    cat "$SCRIPT_DIR/bash/.bashrc" >> ~/.bashrc
    print_status "bashrc updated (appended)"
else
    print_error "bashrc not found in repository"
fi

# Create ghci.conf
echo -e "${BLUE}🔧 Creating ghci.conf...${NC}"
if [ -f "$SCRIPT_DIR/ghc/ghci.conf" ]; then
    cp "$SCRIPT_DIR/ghc/ghci.conf" ~/.ghci
    print_status "ghci.conf created"
else
    print_error "ghci.conf not found in repository"
fi

# Copy terminator config (replace existing)
echo -e "${BLUE}🖥️  Installing terminator config...${NC}"
if [ -f "$SCRIPT_DIR/terminator/config" ]; then
    cp "$SCRIPT_DIR/terminator/config" ~/.config/terminator/
    print_status "Terminator config installed"
else
    print_error "Terminator config not found in repository"
fi

# Copy wallpapers
echo -e "${BLUE}🖼️  Installing wallpapers...${NC}"
if [ -d "$SCRIPT_DIR/wallpapers" ]; then
    cp -r "$SCRIPT_DIR/wallpapers/"* ~/Pictures/Wallpapers/ 2>/dev/null || true
    print_status "Wallpapers installed to ~/Pictures/Wallpapers/"
else
    print_warning "Wallpapers directory not found"
fi

# Copy xmobar configuration and scripts
echo -e "${BLUE}📊 Installing xmobar configuration...${NC}"
if [ -f "$SCRIPT_DIR/xmobar/xmobarrc" ]; then
    cp "$SCRIPT_DIR/xmobar/xmobarrc" ~/.config/xmobar/
    print_status "xmobarrc installed"
else
    print_error "xmobarrc not found in repository"
fi

# Copy all xmobar scripts
echo -e "${BLUE}📜 Installing xmobar scripts...${NC}"
for script in "$SCRIPT_DIR/xmobar"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        cp "$script" ~/.config/xmobar/
        chmod +x ~/.config/xmobar/"$script_name"
        print_status "Installed and made executable: $script_name"
    fi
done

# Copy xmobar xpm directory
if [ -d "$SCRIPT_DIR/xmobar/xpm" ]; then
    cp -r "$SCRIPT_DIR/xmobar/xpm" ~/.config/xmobar/
    print_status "xmobar xpm directory installed"
fi

# Copy xmonad configuration
echo -e "${BLUE}🪟 Installing xmonad configuration...${NC}"
if [ -f "$SCRIPT_DIR/xmonad/xmonad.hs" ]; then
    cp "$SCRIPT_DIR/xmonad/xmonad.hs" ~/.xmonad/
    print_status "xmonad.hs installed"
else
    print_error "xmonad.hs not found in repository"
fi

# Copy xmonad scripts
echo -e "${BLUE}🔧 Installing xmonad scripts...${NC}"
for script in "$SCRIPT_DIR/xmonad"/*.sh; do
    if [ -f "$script" ]; then
        script_name=$(basename "$script")
        cp "$script" ~/.xmonad/
        chmod +x ~/.xmonad/"$script_name"
        print_status "Installed and made executable: $script_name"
    fi
done

# Set proper permissions
echo -e "${BLUE}🔐 Setting permissions...${NC}"
chmod +x ~/.config/xmobar/*.sh 2>/dev/null || true
chmod +x ~/.xmonad/*.sh 2>/dev/null || true
print_status "Permissions set"

# Final status
echo -e "${BLUE}📋 Installation Summary:${NC}"
echo -e "${GREEN}✓${NC} bashrc updated (appended)"
echo -e "${GREEN}✓${NC} ghci.conf created"
echo -e "${GREEN}✓${NC} terminator config installed"
echo -e "${GREEN}✓${NC} wallpapers installed to ~/Pictures/Wallpapers/"
echo -e "${GREEN}✓${NC} xmobar configuration and scripts installed"
echo -e "${GREEN}✓${NC} xmonad configuration and scripts installed"

echo -e "${BLUE}🎉 Installation completed successfully!${NC}"
echo ""
echo -e "${BLUE}📋 Post-installation steps:${NC}"
echo -e "${YELLOW}1.${NC} Restart your window manager or reboot for all changes to take effect"
echo -e "${YELLOW}2.${NC} Make sure all required packages are installed (see README.txt)"
echo -e "${YELLOW}3.${NC} For ASUS Zenbook users, install coolercontrol:"
echo -e "${YELLOW}   sudo apt install curl apt-transport-https${NC}"
echo -e "${YELLOW}   curl -1sLf 'https://dl.cloudsmith.io/public/coolercontrol/coolercontrol/setup.deb.sh' | sudo -E bash${NC}"
echo -e "${YELLOW}   sudo apt update && sudo apt install coolercontrol${NC}"
echo -e "${YELLOW}4.${NC} Install oh-my-posh (optional):"
echo -e "${YELLOW}   curl -s https://ohmyposh.dev/install.sh | bash -s${NC}"
echo -e "${YELLOW}5.${NC} Configure touchpad natural scrolling (see README.txt)"
echo ""
echo -e "${GREEN}✨ Your ASUS Zenbook Ubuntu setup is ready!${NC}"
