#!/bin/bash

# Ultra-simple macOS Services creation for AG AudioFlow
# Creates minimal shell script services

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Creating ultra-simple AG AudioFlow Services..."
echo "Script directory: $SCRIPT_DIR"

# Create a simple wrapper script in a standard location
WRAPPER_SCRIPT="$HOME/.agaudioflow-wrapper"
cat > "$WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash
# AG AudioFlow wrapper script

# Find the agaudioflow script
SCRIPT_PATH=""
for path in "$HOME/AG_AudioFlow_OpenSource/agaudioflow" "$HOME/Downloads/AG_AudioFlow_OpenSource/agaudioflow" "/usr/local/bin/agaudioflow"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        SCRIPT_PATH="$path"
        break
    fi
done

# Try to find it using which command
if [ -z "$SCRIPT_PATH" ] && command -v agaudioflow &> /dev/null; then
    SCRIPT_PATH="$(which agaudioflow)"
fi

if [ -z "$SCRIPT_PATH" ]; then
    osascript -e 'display alert "AG AudioFlow Error" message "agaudioflow script not found. Please check installation."'
    exit 1
fi

# Run the command
"$SCRIPT_PATH" "$@"
EOF

chmod +x "$WRAPPER_SCRIPT"

# Create simple service function
create_simple_service() {
    local action="$1"
    local display_name="$2"
    local service_dir="$SERVICES_DIR/AG AudioFlow - $display_name.workflow"

    mkdir -p "$service_dir/Contents"

    # Create minimal Info.plist
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
                <string>AG AudioFlow - $display_name</string>
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
                <string>com.apple.quicktime-movie</string>
                <string>public.mpeg-4</string>
            </array>
            <key>NSReturnTypes</key>
            <array>
                <string>NSStringPboardType</string>
            </array>
        </dict>
    </array>
    <key>CFBundleIdentifier</key>
    <string>com.agaudioflow.$action</string>
    <key>CFBundleName</key>
    <string>AG AudioFlow - $display_name</string>
</dict>
</plist>
EOF

    # Create minimal workflow
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
                    <string>for f in "\$@"; do "$WRAPPER_SCRIPT" "$action" "\$f"; done</string>
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

    echo "✓ Created: AG AudioFlow - $display_name"
}

# Create all services
create_simple_service "stereo-to-mono" "Stereo to Mono"
create_simple_service "normalize" "Normalize"
create_simple_service "volume-up" "Volume Up"
create_simple_service "volume-down" "Volume Down"
create_simple_service "convert-mp3" "Convert to MP3"
create_simple_service "convert-wav" "Convert to WAV"
create_simple_service "trim-silence" "Trim Silence"
create_simple_service "speed-up" "Speed Up"

echo ""
echo "✅ Ultra-simple AG AudioFlow Services created!"
echo "Wrapper script created at: $WRAPPER_SCRIPT"
echo ""

# Debug information
echo "🔍 Debug Information:"
echo "Services directory: $SERVICES_DIR"
echo "Created services:"
ls -la "$SERVICES_DIR" | grep "AG AudioFlow" || echo "  No AG AudioFlow services found!"
echo ""

# Force refresh services
echo "🔄 Refreshing Services..."
/System/Library/CoreServices/pbs -flush
killall Finder 2>/dev/null || true
sleep 2

echo ""
echo "📋 Next Steps:"
echo "1. Go to System Preferences > Keyboard > Shortcuts > Services"
echo "2. Look for 'AG AudioFlow' services and enable them"
echo "3. If services don't appear, try:"
echo "   - Restart your Mac"
echo "   - Run: sudo /System/Library/CoreServices/pbs -flush"
echo "   - Check that files exist in: $SERVICES_DIR"
echo "4. Right-click any audio file and look in Services menu"
echo ""

# Verify wrapper script
if [ -f "$WRAPPER_SCRIPT" ] && [ -x "$WRAPPER_SCRIPT" ]; then
    echo "✅ Wrapper script is executable"
else
    echo "❌ Wrapper script has issues"
fi

echo ""
echo "🚨 If services still don't appear:"
echo "1. Check System Preferences > Security & Privacy > Privacy > Automation"
echo "2. Make sure Finder is allowed to control other apps"
echo "3. Try logging out and back in"
echo ""