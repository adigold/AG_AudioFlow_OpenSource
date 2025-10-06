#!/bin/bash

# AG AudioFlow Installer with Notifications
# Shows notifications when processing files

set -e

echo "🎵 AG AudioFlow Installer (with notifications)"
echo "=============================================="
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

# Create wrapper script with notifications
echo "Creating notification wrapper..."

WRAPPER_SCRIPT="/usr/local/bin/agaudioflow-wrapper"

sudo tee "$WRAPPER_SCRIPT" > /dev/null << 'EOF'
#!/bin/bash

# AG AudioFlow Wrapper with Notifications

ACTION="$1"
INPUT_FILE="$2"

# Function to show notification
notify() {
    osascript -e "display notification \"$2\" with title \"AG AudioFlow\" subtitle \"$1\""
}

# Check if we have the required arguments
if [ -z "$ACTION" ] || [ -z "$INPUT_FILE" ]; then
    notify "Error" "No file or action specified"
    exit 1
fi

# Get the filename for notifications
FILENAME=$(basename "$INPUT_FILE")

# Show starting notification
notify "Processing" "Starting $ACTION on $FILENAME"

# Find Node.js
NODE_PATH=$(which node)
if [ -z "$NODE_PATH" ]; then
    notify "Error" "Node.js not found"
    exit 1
fi

# Find FFmpeg
FFMPEG_PATH=$(which ffmpeg)
if [ -z "$FFMPEG_PATH" ]; then
    notify "Error" "FFmpeg not found"
    exit 1
fi

# Run the actual agaudioflow script
SCRIPT_OUTPUT=$("$NODE_PATH" /usr/local/bin/agaudioflow "$ACTION" "$INPUT_FILE" 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    notify "Success" "Completed $ACTION on $FILENAME"
else
    notify "Failed" "Error processing $FILENAME: $SCRIPT_OUTPUT"
fi

exit $EXIT_CODE
EOF

sudo chmod +x "$WRAPPER_SCRIPT"
echo "✅ Notification wrapper created"
echo ""

# Install the actual agaudioflow script
echo "Installing AG AudioFlow script..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGAUDIOFLOW_PATH="$SCRIPT_DIR/agaudioflow"

if [ ! -f "$AGAUDIOFLOW_PATH" ]; then
    echo "❌ Error: agaudioflow script not found"
    exit 1
fi

# Copy with universal shebang
sudo cp "$AGAUDIOFLOW_PATH" /usr/local/bin/agaudioflow
sudo chmod +x /usr/local/bin/agaudioflow

echo "✅ AG AudioFlow installed"
echo ""

# Create services that use the wrapper
echo "Creating macOS Services with notifications..."

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

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
                <string>public.movie</string>
            </array>
        </dict>
    </array>
    <key>CFBundleName</key>
    <string>AG AudioFlow - $name</string>
</dict>
</plist>
EOF

    # Create workflow with wrapper
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
                    <string>for f in "\$@"; do /usr/local/bin/agaudioflow-wrapper "$action" "\$f"; done</string>
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
echo "✅ Installation Complete with Notifications!"
echo ""
echo "Now when you use the services, you'll see notifications showing:"
echo "  • When processing starts"
echo "  • When processing completes"
echo "  • Any errors that occur"
echo ""
echo "Next steps:"
echo "1. Go to System Preferences > Keyboard > Shortcuts > Services"
echo "2. Enable the AG AudioFlow services"
echo "3. Right-click an audio file and use the services"
echo "4. Watch for notifications!"
echo ""