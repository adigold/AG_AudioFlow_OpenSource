#!/bin/bash

# AG AudioFlow Standalone Installer
# Works on any Mac without PATH issues

set -e

echo "🎵 AG AudioFlow Standalone Installer"
echo "====================================="
echo ""

# Find Node.js in common locations
echo "Finding Node.js..."
NODE_PATH=""
for path in "/usr/local/bin/node" "/opt/homebrew/bin/node" "$HOME/.volta/bin/node" "/usr/bin/node" "$(which node 2>/dev/null)"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        NODE_PATH="$path"
        echo "✅ Found Node.js at: $NODE_PATH"
        break
    fi
done

if [ -z "$NODE_PATH" ]; then
    echo "❌ Node.js not found. Install with: brew install node"
    exit 1
fi

# Find FFmpeg in common locations
echo "Finding FFmpeg..."
FFMPEG_PATH=""
for path in "/usr/local/bin/ffmpeg" "/opt/homebrew/bin/ffmpeg" "/usr/bin/ffmpeg" "$(which ffmpeg 2>/dev/null)"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        FFMPEG_PATH="$path"
        echo "✅ Found FFmpeg at: $FFMPEG_PATH"
        break
    fi
done

if [ -z "$FFMPEG_PATH" ]; then
    echo "❌ FFmpeg not found. Install with: brew install ffmpeg"
    exit 1
fi

echo ""
echo "Installing AG AudioFlow..."

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGAUDIOFLOW_PATH="$SCRIPT_DIR/agaudioflow"

if [ ! -f "$AGAUDIOFLOW_PATH" ]; then
    echo "❌ Error: agaudioflow script not found"
    exit 1
fi

# Create a standalone wrapper with hardcoded paths
WRAPPER_SCRIPT="/usr/local/bin/agaudioflow-standalone"

sudo tee "$WRAPPER_SCRIPT" > /dev/null << EOF
#!/bin/bash

# AG AudioFlow Standalone Wrapper
# Hardcoded paths for reliability in Service environment

ACTION="\$1"
INPUT_FILE="\$2"

# Hardcoded paths discovered during installation
NODE_PATH="$NODE_PATH"
FFMPEG_PATH="$FFMPEG_PATH"

# Export paths so the script can find them
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
export NODE="\$NODE_PATH"

# Function to show notification
notify() {
    osascript -e "display notification \"\$2\" with title \"AG AudioFlow\" subtitle \"\$1\"" 2>/dev/null || true
}

# Check arguments
if [ -z "\$ACTION" ] || [ -z "\$INPUT_FILE" ]; then
    notify "Error" "No file or action specified"
    exit 1
fi

# Check if Node.js exists
if [ ! -f "\$NODE_PATH" ]; then
    notify "Error" "Node.js not found at $NODE_PATH"
    exit 1
fi

# Get the filename for notifications
FILENAME=\$(basename "\$INPUT_FILE")

# Show starting notification
notify "Processing" "Starting \$ACTION on \$FILENAME"

# Create a temporary script with embedded FFmpeg path
TEMP_SCRIPT="/tmp/agaudioflow-temp-\$\$.js"
cat > "\$TEMP_SCRIPT" << 'SCRIPT_END'
$(cat "$AGAUDIOFLOW_PATH" | sed "s|'/opt/homebrew/bin/ffmpeg', '/usr/local/bin/ffmpeg', '/usr/bin/ffmpeg', 'ffmpeg'|'$FFMPEG_PATH', '/opt/homebrew/bin/ffmpeg', '/usr/local/bin/ffmpeg', '/usr/bin/ffmpeg'|")
SCRIPT_END

# Run the script
OUTPUT=\$("\$NODE_PATH" "\$TEMP_SCRIPT" "\$ACTION" "\$INPUT_FILE" 2>&1)
EXIT_CODE=\$?

# Clean up
rm -f "\$TEMP_SCRIPT"

if [ \$EXIT_CODE -eq 0 ]; then
    notify "Success" "Completed \$ACTION on \$FILENAME"
else
    notify "Failed" "Error: \$OUTPUT"
fi

exit \$EXIT_CODE
EOF

sudo chmod +x "$WRAPPER_SCRIPT"
echo "✅ Standalone wrapper created with hardcoded paths"
echo "   Node.js: $NODE_PATH"
echo "   FFmpeg: $FFMPEG_PATH"
echo ""

# Install the original script too
sudo cp "$AGAUDIOFLOW_PATH" /usr/local/bin/agaudioflow
sudo chmod +x /usr/local/bin/agaudioflow

# Create services using the standalone wrapper
echo "Creating macOS Services..."

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

create_service() {
    local action="$1"
    local name="$2"
    local service_dir="$SERVICES_DIR/AG AudioFlow - $name.workflow"

    rm -rf "$service_dir"
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
            <key>NSSendFileTypes</key>
            <array>
                <string>public.audio</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

    # Create workflow with standalone wrapper
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
                    <string>/usr/local/bin/agaudioflow-standalone "$action" "\$1"</string>
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
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

    echo "  ✅ $name"
}

# Remove old services first
echo "Removing old services..."
rm -rf "$SERVICES_DIR"/AG\ AudioFlow*

# Create all services
create_service "stereo-to-mono" "Stereo to Mono"
create_service "normalize" "Normalize"
create_service "volume-up" "Volume Up"
create_service "volume-down" "Volume Down"
create_service "convert-mp3" "Convert to MP3"
create_service "convert-wav" "Convert to WAV"
create_service "trim-silence" "Trim Silence"
create_service "speed-up" "Speed Up"
create_service "get-info" "Get Info"

echo ""
echo "🔄 Refreshing Services..."
/System/Library/CoreServices/pbs -flush 2>/dev/null || true
killall Finder 2>/dev/null || true

echo ""
echo "✅ Installation Complete!"
echo ""
echo "The services now use hardcoded paths:"
echo "  Node.js: $NODE_PATH"
echo "  FFmpeg: $FFMPEG_PATH"
echo ""
echo "This should work even in the limited Service environment."
echo ""
echo "Next steps:"
echo "1. Go to System Preferences > Keyboard > Shortcuts > Services"
echo "2. Enable the AG AudioFlow services"
echo "3. Right-click an audio file and try a service"
echo ""