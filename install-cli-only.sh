#!/bin/bash

# AG AudioFlow CLI-Only Installation
# Completely avoids Apple workflows - pure CLI tool only

set -e

echo "========================================="
echo "  AG AudioFlow CLI-Only Installation"
echo "  No Apple Workflows - Pure CLI Tool"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }

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

    if [[ -d "/opt/homebrew" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
else
    print_status "Homebrew is installed"
fi

# Step 2: Install Audio Processing Engines
echo ""
echo "Step 2: Installing audio processing engines..."

# Ask user which engines to install
echo ""
echo "Which audio processing engines would you like to install?"
echo "1) SoX only (Professional audio processing)"
echo "2) FFmpeg only (Multimedia processing)"
echo "3) Both SoX and FFmpeg (Recommended)"
echo ""
read -p "Enter choice (1-3): " ENGINE_CHOICE

case $ENGINE_CHOICE in
    1)
        print_info "Installing SoX..."
        brew install sox
        ;;
    2)
        print_info "Installing FFmpeg..."
        brew install ffmpeg
        ;;
    3|*)
        print_info "Installing both SoX and FFmpeg..."
        brew install sox ffmpeg
        ;;
esac

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

# Determine which CLI version to install
if command -v sox &> /dev/null; then
    print_info "Installing Professional version with SoX support..."
    cp "$OLDPWD"/agaudioflow-multi-engine.js ./agaudioflow-cli.js
else
    print_info "Installing Standard version with FFmpeg..."
    cp "$OLDPWD"/agaudioflow-cli.js ./agaudioflow-cli.js
fi

cp "$OLDPWD"/cli-package.json ./package.json

# Install dependencies
print_status "Installing dependencies..."
npm install

# Install globally
print_status "Installing AG AudioFlow CLI globally..."
npm install -g .

# Step 5: Install Alternative Integration Methods
echo ""
echo "Step 5: Setting up Apple Workflow-Free alternatives..."

# Ask user what alternatives they want
echo ""
echo "Choose alternative integration methods (no Apple workflows):"
echo "1) Drag & Drop scripts only"
echo "2) File watcher only"
echo "3) Both drag & drop and file watcher"
echo "4) CLI only (no additional integration)"
echo ""
read -p "Enter choice (1-4): " INTEGRATION_CHOICE

cd "$OLDPWD"

case $INTEGRATION_CHOICE in
    1)
        print_info "Setting up drag & drop scripts..."
        chmod +x setup-drag-drop.sh
        ./setup-drag-drop.sh
        ;;
    2)
        print_info "Setting up file watcher..."
        chmod +x watch-folder.sh
        # Create a sample watch folder
        mkdir -p "$HOME/Desktop/AudioFlow Watch"
        echo "File watcher available: ./watch-folder.sh"
        ;;
    3)
        print_info "Setting up both drag & drop and file watcher..."
        chmod +x setup-drag-drop.sh watch-folder.sh
        ./setup-drag-drop.sh
        mkdir -p "$HOME/Desktop/AudioFlow Watch"
        ;;
    4|*)
        print_info "CLI-only installation - no additional integration"
        ;;
esac

# Cleanup
rm -rf "$TEMP_DIR"

# Verify installation
echo ""
echo "Step 6: Verifying installation..."
if command -v agaudioflow &> /dev/null; then
    print_status "AG AudioFlow CLI installed successfully"

    # Test engines
    echo ""
    print_info "Testing audio engines..."
    agaudioflow --engines 2>/dev/null || echo "CLI installed successfully"
else
    print_error "Failed to install AG AudioFlow CLI"
    exit 1
fi

# Final message
echo ""
echo "========================================="
echo -e "${GREEN}  CLI-Only Installation Complete!${NC}"
echo "========================================="
echo ""
echo "🎵 AG AudioFlow CLI is ready!"
echo ""
echo "✅ No Apple Workflows Used!"
echo "✅ Pure CLI audio processing"
echo "✅ SoX/FFmpeg powered"
echo ""
echo "🚀 Basic Usage:"
echo "   agaudioflow stereo-to-mono audio.mp3"
echo "   agaudioflow normalize podcast.mp3"
echo "   agaudioflow volume song.mp3 5"
echo "   agaudioflow --help"
echo ""

case $INTEGRATION_CHOICE in
    1|3)
        echo "🖱️ Drag & Drop Scripts:"
        echo "   Location: ~/Desktop/AG AudioFlow Scripts/"
        echo "   Usage: Drag audio files onto .command scripts"
        echo ""
        ;;
esac

case $INTEGRATION_CHOICE in
    2|3)
        echo "🔍 File Watcher:"
        echo "   Start: ./watch-folder.sh"
        echo "   Usage: Drop files in ~/Desktop/AudioFlow Watch/"
        echo ""
        ;;
esac

echo "💡 Pro Tips:"
echo "   • All processing is done via CLI - no Apple dependencies"
echo "   • Use Terminal, drag & drop, or file watcher as preferred"
echo "   • Professional audio quality with SoX integration"
echo ""