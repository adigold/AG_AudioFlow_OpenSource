#!/bin/bash

# AG AudioFlow Installation Script for macOS
# This script installs the AG AudioFlow CLI tool and sets up macOS Quick Actions

set -e

echo "========================================="
echo "  AG AudioFlow Installation for macOS"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    print_error "This installer is for macOS only"
    exit 1
fi

# Step 1: Check for Homebrew
echo "Step 1: Checking dependencies..."
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -d "/opt/homebrew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_status "Homebrew is installed"
fi

# Step 2: Install FFmpeg
echo ""
echo "Step 2: Installing FFmpeg..."
if ! command -v ffmpeg &> /dev/null; then
    print_warning "FFmpeg not found. Installing via Homebrew..."
    brew install ffmpeg
    print_status "FFmpeg installed successfully"
else
    print_status "FFmpeg is already installed"
fi

# Step 3: Check for Node.js
echo ""
echo "Step 3: Checking Node.js..."
if ! command -v node &> /dev/null; then
    print_warning "Node.js not found. Installing via Homebrew..."
    brew install node
    print_status "Node.js installed successfully"
else
    print_status "Node.js is installed (version: $(node -v))"
fi

# Step 4: Install AG AudioFlow CLI
echo ""
echo "Step 4: Installing AG AudioFlow CLI..."

# Create a temporary directory for installation
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Clone or download the repository
print_status "Downloading AG AudioFlow..."
if command -v git &> /dev/null; then
    git clone https://github.com/adigold/AG_AudioFlow_OpenSource.git . 2>/dev/null || {
        # If repo doesn't exist yet, use local files
        cp "$OLDPWD"/agaudioflow-cli.js .
        cp "$OLDPWD"/cli-package.json ./package.json
    }
else
    # Copy local files if git is not available
    cp "$OLDPWD"/agaudioflow-cli.js .
    cp "$OLDPWD"/cli-package.json ./package.json
fi

# Install dependencies
print_status "Installing dependencies..."
npm install

# Install globally
print_status "Installing AG AudioFlow globally..."
npm install -g .

# Verify installation
if command -v agaudioflow &> /dev/null; then
    print_status "AG AudioFlow CLI installed successfully"
else
    print_error "Failed to install AG AudioFlow CLI"
    exit 1
fi

# Step 5: Create Quick Actions directory
echo ""
echo "Step 5: Setting up macOS Quick Actions..."

QUICK_ACTIONS_DIR="$HOME/Library/Services"
mkdir -p "$QUICK_ACTIONS_DIR"

# Return to original directory
cd "$OLDPWD"

# Install Quick Actions
./setup-mac-services.sh

# Cleanup
rm -rf "$TEMP_DIR"

# Final message
echo ""
echo "========================================="
echo -e "${GREEN}  Installation Complete!${NC}"
echo "========================================="
echo ""
echo "AG AudioFlow CLI is now installed and ready to use!"
echo ""
echo "CLI Usage:"
echo "  agaudioflow --help"
echo ""
echo "Quick Actions:"
echo "  Right-click on any audio file in Finder and look for"
echo "  'AG AudioFlow' options in the Quick Actions menu"
echo ""
echo "Available Quick Actions (30 total):"
echo "  🎵 Format Conversion: MP3, WAV, FLAC, AAC, OGG"
echo "  🎚️ Stereo Processing: Stereo↔Mono, Split Channels"
echo "  📊 Normalization: General, Spotify, Broadcast"
echo "  🔊 Volume Control: +/-5dB, +/-10dB options"
echo "  ✂️ Enhancement: Trim Silence, Fade Effects"
echo "  ⚡ Speed Control: 50%, 150%, 200%"
echo "  🎛️ EQ Presets: Bass, Treble, Vocal, Loudness"
echo "  🔧 Technical: Channel/Sample Rate conversion"
echo "  🎬 Video: Extract Audio from Video"
echo "  🔄 Effects: Reverse Audio, Get Info"
echo ""
print_warning "Note: You may need to enable Quick Actions in:"
print_warning "System Preferences > Extensions > Finder"
echo ""