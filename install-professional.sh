#!/bin/bash

# AG AudioFlow Professional Installation Script
# Enhanced with SoX and FFmpeg for professional audio processing

set -e

echo "========================================="
echo "  AG AudioFlow Professional Setup"
echo "  Enhanced Audio Processing Suite"
echo "========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
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

# Step 2: Install Professional Audio Engines
echo ""
echo "Step 2: Installing Professional Audio Processing Engines..."

# Install SoX (primary professional engine)
if ! command -v sox &> /dev/null; then
    print_info "Installing SoX (Professional Audio Processing)..."
    brew install sox
    print_status "SoX installed successfully"
else
    print_status "SoX is already installed (version: $(sox --version | head -1))"
fi

# Install FFmpeg (secondary multimedia engine)
if ! command -v ffmpeg &> /dev/null; then
    print_info "Installing FFmpeg (Multimedia Processing)..."
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

# Step 4: Install AG AudioFlow Professional CLI
echo ""
echo "Step 4: Installing AG AudioFlow Professional CLI..."

# Create a temporary directory for installation
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Copy the multi-engine version
cp "$OLDPWD"/agaudioflow-multi-engine.js ./agaudioflow-cli.js
cp "$OLDPWD"/cli-package.json ./package.json

# Install dependencies
print_status "Installing dependencies..."
npm install

# Install globally
print_status "Installing AG AudioFlow Professional globally..."
npm install -g .

# Verify installation
if command -v agaudioflow &> /dev/null; then
    print_status "AG AudioFlow Professional CLI installed successfully"
else
    print_error "Failed to install AG AudioFlow Professional CLI"
    exit 1
fi

# Step 5: Test Audio Engines
echo ""
echo "Step 5: Testing Audio Processing Engines..."
cd "$OLDPWD"

echo ""
print_info "Audio Engine Status:"
agaudioflow --engines

# Step 6: Create Quick Actions
echo ""
echo "Step 6: Setting up Professional Quick Actions..."
if ./setup-quick-actions-simple.sh; then
    print_status "Quick Actions installed successfully"
else
    print_warning "Quick Actions installation had issues, but CLI is working"
    echo "   You can manually run ./setup-quick-actions-simple.sh later"
fi

# Cleanup
rm -rf "$TEMP_DIR"

# Final message
echo ""
echo "========================================="
echo -e "${GREEN}  Professional Installation Complete!${NC}"
echo "========================================="
echo ""
echo "🎛️ AG AudioFlow Professional is now ready!"
echo ""
echo "🎵 Audio Engines Installed:"
if command -v sox &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} SoX - Professional audio processing"
fi
if command -v ffmpeg &> /dev/null; then
    echo -e "   ${GREEN}✓${NC} FFmpeg - Multimedia processing"
fi
echo ""
echo "🚀 Enhanced Features:"
echo "   • Superior audio quality with SoX processing"
echo "   • Professional loudness standards"
echo "   • Advanced EQ and dynamics"
echo "   • High-quality speed/pitch algorithms"
echo "   • Precise volume control"
echo "   • Sophisticated silence detection"
echo ""
echo "CLI Usage:"
echo "   agaudioflow --engines              # Check engine status"
echo "   agaudioflow stereo-to-mono file.mp3   # Professional conversion"
echo "   agaudioflow normalize file.mp3 rms    # Professional loudness"
echo "   agaudioflow --help                    # Full command reference"
echo ""
echo "🖱️ Quick Actions:"
echo "   Right-click any audio file → Quick Actions → AG AudioFlow"
echo ""
print_info "Pro Tip: SoX provides superior audio quality for most operations!"
echo ""