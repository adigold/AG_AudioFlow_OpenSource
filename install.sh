#!/bin/bash

# AG AudioFlow - Simple Installer for macOS
# Just works on any Mac without complicated paths

set -e

echo "🎵 AG AudioFlow Installer"
echo "========================"
echo ""

# Check prerequisites
echo "Checking prerequisites..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js required. Install with: brew install node"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "❌ FFmpeg required. Install with: brew install ffmpeg"
    exit 1
fi

echo "✅ Prerequisites OK"
echo ""

# Install agaudioflow globally
echo "Installing AG AudioFlow..."

# Find the agaudioflow script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGAUDIOFLOW_PATH="$SCRIPT_DIR/agaudioflow"

if [ ! -f "$AGAUDIOFLOW_PATH" ]; then
    echo "❌ Error: agaudioflow script not found at: $AGAUDIOFLOW_PATH"
    echo "   Make sure you're running this installer from the AG_AudioFlow_OpenSource directory"
    echo "   Current directory: $(pwd)"
    echo "   Looking for: $AGAUDIOFLOW_PATH"
    exit 1
fi

# Fix the shebang to use env instead of hardcoded path
echo "Fixing Node.js path in script..."
NODE_PATH=$(which node)
echo "Found Node.js at: $NODE_PATH"

# Create a temp file with the correct shebang
TEMP_SCRIPT="/tmp/agaudioflow.tmp"
echo "#!/usr/bin/env node" > "$TEMP_SCRIPT"
tail -n +2 "$AGAUDIOFLOW_PATH" >> "$TEMP_SCRIPT"

# Copy script to standard location
sudo cp "$TEMP_SCRIPT" /usr/local/bin/agaudioflow
sudo chmod +x /usr/local/bin/agaudioflow
rm "$TEMP_SCRIPT"

echo "✅ AG AudioFlow installed to /usr/local/bin/agaudioflow"
echo ""

# Create services
echo "Creating macOS Services..."

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# Simple service creation function
create_service() {
    local action="$1"
    local name="$2"
    local service_dir="$SERVICES_DIR/AG AudioFlow - $name.workflow"

    mkdir -p "$service_dir/Contents"

    # Create Info.plist
    cat > "$service_dir/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>AG AudioFlow - $name</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSRequiredContext</key>
            <dict>
                <key>NSApplicationIdentifier</key>
                <string>com.apple.finder</string>
            </dict>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.audio</string>
            </array>
        </dict>
    </array>
    <key>CFBundleIdentifier</key>
    <string>com.agaudioflow.$action</string>
    <key>CFBundleName</key>
    <string>AG AudioFlow - $name</string>
</dict>
</plist>
EOF

    # Create workflow
    cat > "$service_dir/Contents/document.wflow" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>for f in "\$@"; do /usr/local/bin/agaudioflow "$action" "\$f"; done</string>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
            </dict>
        </dict>
    </array>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceApplicationBundleIdentifier</key>
        <string>com.apple.finder</string>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

    echo "  ✅ $name"
}

# Create all services
create_service "stereo-to-mono" "Stereo to Mono"
create_service "normalize" "Normalize"
create_service "volume-up" "Volume Up"
create_service "volume-down" "Volume Down"
create_service "convert-mp3" "Convert to MP3"
create_service "convert-wav" "Convert to WAV"
create_service "trim-silence" "Trim Silence"
create_service "speed-up" "Speed Up"

echo ""
echo "🔄 Refreshing Services..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall Finder 2>/dev/null || true

echo ""
echo "🎉 Installation Complete!"
echo ""
echo "Next steps:"
echo "1. Go to System Preferences > Keyboard > Shortcuts > Services"
echo "2. Find 'AG AudioFlow' services and enable them"
echo "3. Right-click any audio file and use Services menu"
echo ""
echo "Command line usage:"
echo "  agaudioflow stereo-to-mono song.wav"
echo "  agaudioflow normalize audio.mp3"
echo ""