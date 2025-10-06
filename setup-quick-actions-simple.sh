#!/bin/bash

# Simple Quick Actions setup using shell scripts and symbolic links
# This creates shell scripts that can be run from the Services menu

set -e

echo "Setting up AG AudioFlow Quick Actions for macOS..."

SERVICES_DIR="$HOME/Library/Services"
SCRIPTS_DIR="$HOME/.agaudioflow"

# Create directories
mkdir -p "$SERVICES_DIR"
mkdir -p "$SCRIPTS_DIR"

# Remove existing AG AudioFlow workflows
echo "Removing existing AG AudioFlow Quick Actions..."
rm -rf "$SERVICES_DIR"/AG\ AudioFlow*

# Function to create a shell script service
create_service() {
    local NAME="$1"
    local SCRIPT_CONTENT="$2"

    echo "Creating service: $NAME"

    # Create the shell script
    cat > "$SCRIPTS_DIR/$NAME.sh" << EOF
#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:\$PATH"

$SCRIPT_CONTENT
EOF

    chmod +x "$SCRIPTS_DIR/$NAME.sh"

    # Create Automator workflow manually with proper structure
    WORKFLOW_DIR="$SERVICES_DIR/AG AudioFlow - $NAME.workflow"
    mkdir -p "$WORKFLOW_DIR/Contents"

    # Create Info.plist with proper service configuration
    cat > "$WORKFLOW_DIR/Contents/Info.plist" << 'PLIST_EOF'
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
                <string>SERVICE_NAME_PLACEHOLDER</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.audio</string>
                <string>public.mp3</string>
                <string>public.mpeg-4-audio</string>
                <string>com.apple.m4a-audio</string>
                <string>public.aiff-audio</string>
                <string>public.aifc-audio</string>
                <string>com.microsoft.waveform-audio</string>
                <string>org.xiph.flac</string>
                <string>org.xiph.ogg-audio</string>
                <string>public.movie</string>
                <string>public.video</string>
                <string>public.mpeg-4</string>
                <string>com.apple.quicktime-movie</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
PLIST_EOF

    # Replace placeholder with actual service name
    sed -i '' "s/SERVICE_NAME_PLACEHOLDER/AG AudioFlow - $NAME/g" "$WORKFLOW_DIR/Contents/Info.plist"

    # Create minimal document.wflow that just calls our script
    UUID1=$(uuidgen)
    UUID2=$(uuidgen)
    UUID3=$(uuidgen)

    cat > "$WORKFLOW_DIR/Contents/document.wflow" << WORKFLOW_EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>523</string>
    <key>AMApplicationVersion</key>
    <string>2.10</string>
    <key>AMDocumentVersion</key>
    <string>2</string>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMAccepts</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Optional</key>
                    <false/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.path</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict/>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.string</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>"$SCRIPTS_DIR/$NAME.sh" "\$@"</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string></string>
                </dict>
                <key>BundleIdentifier</key>
                <string>com.apple.RunShellScript</string>
                <key>CFBundleVersion</key>
                <string>2.0.3</string>
                <key>CanShowSelectedItemsWhenRun</key>
                <false/>
                <key>CanShowWhenRun</key>
                <true/>
                <key>Category</key>
                <array>
                    <string>AMCategoryUtilities</string>
                </array>
                <key>Class Name</key>
                <string>RunShellScriptAction</string>
                <key>InputUUID</key>
                <string>$UUID1</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>$UUID2</string>
                <key>UUID</key>
                <string>$UUID3</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
WORKFLOW_EOF

    echo "✓ Created: $NAME"
}

echo "Creating essential Quick Actions..."

# Create a few essential Quick Actions first
create_service "Convert to MP3" '
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" mp3
        osascript -e "display notification \"Converted to MP3: $(basename \"$f\")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

create_service "Stereo to Mono" '
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow stereo-to-mono "$f" mix
        osascript -e "display notification \"Converted to mono: $(basename \"$f\")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

create_service "Normalize Audio" '
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow normalize "$f"
        osascript -e "display notification \"Normalized: $(basename \"$f\")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

create_service "Get Audio Info" '
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        INFO=$(agaudioflow info "$f" 2>&1)
        DURATION=$(echo "$INFO" | grep Duration | cut -d":" -f2 | xargs || echo "Unknown")
        CHANNELS=$(echo "$INFO" | grep Channels | cut -d":" -f2 | xargs || echo "Unknown")
        BITRATE=$(echo "$INFO" | grep Bitrate | cut -d":" -f2 | xargs || echo "Unknown")
        osascript -e "display dialog \"Audio Info for $(basename \"$f\"):\n\nDuration: $DURATION\nChannels: $CHANNELS\nBitrate: $BITRATE\" buttons {\"OK\"} default button 1 with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

create_service "Volume Up (+5dB)" '
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow volume "$f" 5
        osascript -e "display notification \"Increased volume: $(basename \"$f\")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# Refresh services database
echo ""
echo "Refreshing Services database..."
/System/Library/CoreServices/pbs -flush

echo ""
echo "✅ AG AudioFlow Quick Actions have been installed!"
echo ""
echo "📊 Installed Quick Actions (5 essential):"
echo "   🎵 Convert to MP3"
echo "   🎚️ Stereo to Mono"
echo "   📊 Normalize Audio"
echo "   🔊 Volume Up (+5dB)"
echo "   📋 Get Audio Info"
echo ""
echo "To use them:"
echo "1. Right-click on any audio file in Finder"
echo "2. Look for 'Quick Actions' or 'Services' in the context menu"
echo "3. Select any AG AudioFlow action"
echo ""
echo "Note: You may need to enable these services in:"
echo "System Preferences > Extensions > Finder > Quick Actions"
echo ""
echo "If workflows appear damaged, run: ./setup-quick-actions-simple.sh"