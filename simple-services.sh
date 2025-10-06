#!/bin/bash

# Simple macOS Services creation for AG AudioFlow
# Creates standard shell script services without Apple workflows

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Try to find agaudioflow in multiple locations
if [ -f "$SCRIPT_DIR/agaudioflow" ]; then
    AGAUDIOFLOW_PATH="$SCRIPT_DIR/agaudioflow"
elif command -v agaudioflow &> /dev/null; then
    AGAUDIOFLOW_PATH="$(which agaudioflow)"
else
    echo "Error: agaudioflow not found!"
    exit 1
fi

# Make sure agaudioflow is executable
chmod +x "$AGAUDIOFLOW_PATH" 2>/dev/null || true

# Create simple service scripts
create_service() {
    local action="$1"
    local display_name="$2"
    local service_dir="$SERVICES_DIR/AG AudioFlow - $display_name.workflow"

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
                <string>com.apple.quicktime-movie</string>
                <string>public.movie</string>
            </array>
        </dict>
    </array>
    <key>CFBundleIdentifier</key>
    <string>com.agaudioflow.$action</string>
    <key>CFBundleName</key>
    <string>AG AudioFlow - $display_name</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
</dict>
</plist>
EOF

    # Create the actual workflow document
    cat > "$service_dir/Contents/document.wflow" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>AMApplicationBuild</key>
    <string>444.42</string>
    <key>AMApplicationVersion</key>
    <string>2.9</string>
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
                    <true/>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.string</string>
                    </array>
                </dict>
                <key>AMActionVersion</key>
                <string>2.0.3</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <dict/>
                    <key>CheckedForUserDefaultShell</key>
                    <dict/>
                    <key>inputMethod</key>
                    <dict/>
                    <key>shell</key>
                    <dict/>
                    <key>source</key>
                    <dict/>
                </dict>
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
                    <string>for f in "\$@"
do
    "$AGAUDIOFLOW_PATH" "$action" "\$f"
done</string>
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
                <string>INPUTS</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>OUTPUTS</string>
                <key>UUID</key>
                <string>ACTION_UUID</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>arguments</key>
                <dict>
                    <key>0</key>
                    <dict>
                        <key>default value</key>
                        <string>cat</string>
                        <key>name</key>
                        <string>COMMAND_STRING</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>0</string>
                    </dict>
                </dict>
                <key>isViewVisible</key>
                <true/>
                <key>location</key>
                <string>309.000000:316.000000</string>
                <key>nibPath</key>
                <string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/English.lproj/main.nib</string>
            </dict>
            <key>isViewVisible</key>
            <true/>
        </dict>
    </array>
    <key>connectors</key>
    <array/>
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

echo "Creating simple AG AudioFlow Services..."
echo "Using agaudioflow at: $AGAUDIOFLOW_PATH"

# Create all the basic services
create_service "stereo-to-mono" "Stereo to Mono"
create_service "normalize" "Normalize"
create_service "volume-up" "Volume Up"
create_service "volume-down" "Volume Down"
create_service "convert-mp3" "Convert to MP3"
create_service "convert-wav" "Convert to WAV"
create_service "trim-silence" "Trim Silence"
create_service "speed-up" "Speed Up"

echo ""
echo "✅ All AG AudioFlow Services created!"
echo ""
echo "To activate:"
echo "1. Go to System Preferences > Keyboard > Shortcuts > Services"
echo "2. Look for 'AG AudioFlow' services and enable them"
echo "3. Right-click any audio file and look in Services menu"
echo ""