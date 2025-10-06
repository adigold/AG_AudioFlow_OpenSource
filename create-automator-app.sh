#!/bin/bash

# Create Automator Application for AG AudioFlow
# This bypasses all Service environment issues

echo "🎵 Creating AG AudioFlow Automator Application"
echo "============================================"
echo ""

# Create Applications folder
APP_DIR="$HOME/Applications"
mkdir -p "$APP_DIR"

# Create the app bundle
APP_PATH="$APP_DIR/AG AudioFlow.app"
rm -rf "$APP_PATH"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Create the main executable script
cat > "$APP_PATH/Contents/MacOS/AG AudioFlow" << 'EOF'
#!/bin/bash

# AG AudioFlow Application
# Processes audio files dropped on the app

# Find Node.js
NODE_PATH=""
for path in "/usr/local/bin/node" "/opt/homebrew/bin/node" "$HOME/.volta/bin/node" "/usr/bin/node"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        NODE_PATH="$path"
        break
    fi
done

if [ -z "$NODE_PATH" ]; then
    osascript -e 'display alert "AG AudioFlow Error" message "Node.js not found. Please install Node.js first."'
    exit 1
fi

# Find FFmpeg
FFMPEG_PATH=""
for path in "/usr/local/bin/ffmpeg" "/opt/homebrew/bin/ffmpeg" "/usr/bin/ffmpeg"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        FFMPEG_PATH="$path"
        break
    fi
done

if [ -z "$FFMPEG_PATH" ]; then
    osascript -e 'display alert "AG AudioFlow Error" message "FFmpeg not found. Please install FFmpeg first."'
    exit 1
fi

# If no files dropped, show menu
if [ $# -eq 0 ]; then
    osascript -e 'display alert "AG AudioFlow" message "Drop audio files on this app to process them, or use from command line."'
    exit 0
fi

# Process each dropped file
for FILE in "$@"; do
    # Check if it's an audio file
    if [[ ! "$FILE" =~ \.(mp3|wav|aiff|m4a|flac|ogg|aac)$ ]]; then
        continue
    fi

    # Show action chooser
    ACTION=$(osascript << 'APPLESCRIPT'
choose from list {"Stereo to Mono", "Normalize", "Volume Up", "Volume Down", "Convert to MP3", "Convert to WAV", "Trim Silence", "Speed Up", "Get Info"} with title "AG AudioFlow" with prompt "Choose action for: $(basename "$FILE")" default items {"Get Info"}
APPLESCRIPT
    )

    if [ -z "$ACTION" ] || [ "$ACTION" = "false" ]; then
        continue
    fi

    # Convert display name to action
    case "$ACTION" in
        "Stereo to Mono") ACTION_CMD="stereo-to-mono" ;;
        "Normalize") ACTION_CMD="normalize" ;;
        "Volume Up") ACTION_CMD="volume-up" ;;
        "Volume Down") ACTION_CMD="volume-down" ;;
        "Convert to MP3") ACTION_CMD="convert-mp3" ;;
        "Convert to WAV") ACTION_CMD="convert-wav" ;;
        "Trim Silence") ACTION_CMD="trim-silence" ;;
        "Speed Up") ACTION_CMD="speed-up" ;;
        "Get Info") ACTION_CMD="get-info" ;;
        *) continue ;;
    esac

    # Find agaudioflow script
    SCRIPT_PATH=""
    for path in "/usr/local/bin/agaudioflow" "$HOME/AG_AudioFlow_OpenSource/agaudioflow"; do
        if [ -f "$path" ]; then
            SCRIPT_PATH="$path"
            break
        fi
    done

    if [ -z "$SCRIPT_PATH" ]; then
        osascript -e 'display alert "AG AudioFlow Error" message "agaudioflow script not found."'
        exit 1
    fi

    # Process the file
    osascript -e "display notification \"Processing $(basename "$FILE")\" with title \"AG AudioFlow\" subtitle \"$ACTION\""

    "$NODE_PATH" "$SCRIPT_PATH" "$ACTION_CMD" "$FILE"

    if [ $? -eq 0 ]; then
        osascript -e "display notification \"Completed $(basename "$FILE")\" with title \"AG AudioFlow\" subtitle \"Success\""
    else
        osascript -e "display notification \"Failed to process $(basename "$FILE")\" with title \"AG AudioFlow\" subtitle \"Error\""
    fi
done
EOF

chmod +x "$APP_PATH/Contents/MacOS/AG AudioFlow"

# Create Info.plist
cat > "$APP_PATH/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>AG AudioFlow</string>
    <key>CFBundleDisplayName</key>
    <string>AG AudioFlow</string>
    <key>CFBundleIdentifier</key>
    <string>com.agsoundtrax.agaudioflow</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleExecutable</key>
    <string>AG AudioFlow</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>mp3</string>
                <string>wav</string>
                <string>aiff</string>
                <string>m4a</string>
                <string>flac</string>
                <string>ogg</string>
                <string>aac</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Audio Files</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
        </dict>
    </array>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
EOF

# Copy the agaudioflow script into the app
if [ -f "agaudioflow" ]; then
    cp agaudioflow "$APP_PATH/Contents/Resources/agaudioflow"
elif [ -f "/usr/local/bin/agaudioflow" ]; then
    cp /usr/local/bin/agaudioflow "$APP_PATH/Contents/Resources/agaudioflow"
fi

echo "✅ Created AG AudioFlow.app in ~/Applications/"
echo ""
echo "How to use:"
echo "1. Open ~/Applications/ in Finder"
echo "2. Drag AG AudioFlow.app to your Dock for easy access"
echo "3. Drop audio files on the app icon"
echo "4. Choose the action from the menu"
echo ""
echo "Alternative: Right-click audio files and choose 'Open With > AG AudioFlow'"
echo ""