#!/bin/bash

# Setup macOS Quick Actions for AG AudioFlow
# This script creates Automator workflows for right-click audio processing

set -e

echo "Setting up AG AudioFlow Quick Actions for macOS..."

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

# Function to create an Automator workflow
create_workflow() {
    local NAME="$1"
    local COMMAND="$2"
    local WORKFLOW_PATH="$SERVICES_DIR/AG AudioFlow - $NAME.workflow"

    echo "Creating Quick Action: $NAME..."

    # Create workflow directory structure
    mkdir -p "$WORKFLOW_PATH/Contents"

    # Create Info.plist
    cat > "$WORKFLOW_PATH/Contents/Info.plist" << EOF
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
                <string>AG AudioFlow - $NAME</string>
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
                <string>public.avi</string>
                <string>org.webmproject.webm</string>
                <string>public.3gpp</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

    # Create document.wflow
    cat > "$WORKFLOW_PATH/Contents/document.wflow" << 'EOF'
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
                    <string>PLACEHOLDER_COMMAND</string>
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
                <string>PLACEHOLDER_UUID</string>
                <key>Keywords</key>
                <array>
                    <string>Shell</string>
                    <string>Script</string>
                    <string>Command</string>
                    <string>Run</string>
                    <string>Unix</string>
                </array>
                <key>OutputUUID</key>
                <string>PLACEHOLDER_UUID2</string>
                <key>UUID</key>
                <string>PLACEHOLDER_UUID3</string>
                <key>UnlocalizedApplications</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>arguments</key>
                <dict>
                    <key>0</key>
                    <dict>
                        <key>default value</key>
                        <integer>0</integer>
                        <key>name</key>
                        <string>inputMethod</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>0</string>
                    </dict>
                    <key>1</key>
                    <dict>
                        <key>default value</key>
                        <false/>
                        <key>name</key>
                        <string>CheckedForUserDefaultShell</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>1</string>
                    </dict>
                    <key>2</key>
                    <dict>
                        <key>default value</key>
                        <string></string>
                        <key>name</key>
                        <string>source</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>2</string>
                    </dict>
                    <key>3</key>
                    <dict>
                        <key>default value</key>
                        <string></string>
                        <key>name</key>
                        <string>COMMAND_STRING</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>3</string>
                    </dict>
                    <key>4</key>
                    <dict>
                        <key>default value</key>
                        <string>/bin/sh</string>
                        <key>name</key>
                        <string>shell</string>
                        <key>required</key>
                        <string>0</string>
                        <key>type</key>
                        <string>0</string>
                        <key>uuid</key>
                        <string>4</string>
                    </dict>
                </dict>
                <key>conversionLabel</key>
                <integer>0</integer>
                <key>isViewVisible</key>
                <integer>1</integer>
                <key>location</key>
                <string>309.000000:253.000000</string>
                <key>nibPath</key>
                <string>/System/Library/Automator/Run Shell Script.action/Contents/Resources/Base.lproj/main.nib</string>
            </dict>
            <key>isViewVisible</key>
            <integer>1</integer>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>applicationBundleID</key>
        <string>com.apple.finder</string>
        <key>applicationBundleIDsByPath</key>
        <dict/>
        <key>applicationPath</key>
        <string>/System/Library/CoreServices/Finder.app</string>
        <key>applicationPaths</key>
        <array>
            <string>/System/Library/CoreServices/Finder.app</string>
        </array>
        <key>backgroundColor</key>
        <data>
        YnBsaXN0MDDUAQIDBAUGBwpYJHZlcnNpb25ZJGFyY2hpdmVyVCR0b3BYJG9iamVjdHMS
        AAGGoF8QD05TS2V5ZWRBcmNoaXZlctEICVRyb290gAGpCwwXGBkaGyAhVSRudWxs1Q0O
        DxAREhMUFRZWJGNsYXNzW05TQ29sb3JOYW1lXE5TQ29sb3JTcGFjZV1OU0NhdGFsb2dO
        YW1lV05TQ29sb3KACIADEAaAAl8QEHN5c3RlbVB1cnBsZUNvbG9y1hwdDh4fVE5TSUQQ
        AIAEEAXSIiMkJVokY2xhc3NuYW1lWCRjbGFzc2VzV05TQ29sb3KiJCZYTlNPYmplY3QI
        ERokKTI3SUxRU1ddZGp3foWHiY6ZoqqttsjL0AAAAAAAAAEBAAAAAAAAABcAAAAAAAAA
        AAAAAAAAAADZ
        </data>
        <key>inputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>outputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>presentationMode</key>
        <integer>15</integer>
        <key>processesInput</key>
        <integer>0</integer>
        <key>serviceApplicationBundleID</key>
        <string>com.apple.finder</string>
        <key>serviceApplicationPath</key>
        <string>/System/Library/CoreServices/Finder.app</string>
        <key>serviceInputTypeIdentifier</key>
        <string>com.apple.Automator.fileSystemObject</string>
        <key>serviceOutputTypeIdentifier</key>
        <string>com.apple.Automator.nothing</string>
        <key>serviceProcessesInput</key>
        <integer>0</integer>
        <key>systemImageName</key>
        <string>NSTouchBarAudioOutputVolumeHighTemplate</string>
        <key>useAutomaticInputType</key>
        <integer>0</integer>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF

    # Generate unique UUIDs for the workflow
    UUID1=$(uuidgen)
    UUID2=$(uuidgen)
    UUID3=$(uuidgen)

    # Replace placeholders with actual values
    sed -i '' "s|PLACEHOLDER_COMMAND|$COMMAND|g" "$WORKFLOW_PATH/Contents/document.wflow"
    sed -i '' "s|PLACEHOLDER_UUID|$UUID1|g" "$WORKFLOW_PATH/Contents/document.wflow"
    sed -i '' "s|PLACEHOLDER_UUID2|$UUID2|g" "$WORKFLOW_PATH/Contents/document.wflow"
    sed -i '' "s|PLACEHOLDER_UUID3|$UUID3|g" "$WORKFLOW_PATH/Contents/document.wflow"

    echo "✓ Created: $NAME"
}

# Create Quick Actions for common audio operations

# 1. Stereo to Mono (Mix)
create_workflow "Stereo to Mono" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow stereo-to-mono "$f" mix
        osascript -e "display notification \"Converted to mono: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 2. Split Stereo Channels
create_workflow "Split Stereo" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow split-stereo "$f"
        osascript -e "display notification \"Split stereo channels: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 3. Normalize Audio
create_workflow "Normalize Audio" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow normalize "$f"
        osascript -e "display notification \"Normalized: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 4. Convert to MP3
create_workflow "Convert to MP3" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" mp3
        osascript -e "display notification \"Converted to MP3: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 5. Convert to WAV
create_workflow "Convert to WAV" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" wav
        osascript -e "display notification \"Converted to WAV: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 6. Trim Silence
create_workflow "Trim Silence" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow trim-silence "$f"
        osascript -e "display notification \"Trimmed silence: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 7. Increase Volume
create_workflow "Increase Volume (+5dB)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow volume "$f" 5
        osascript -e "display notification \"Increased volume: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 8. Decrease Volume
create_workflow "Decrease Volume (-5dB)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow volume "$f" -5
        osascript -e "display notification \"Decreased volume: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 9. Convert to FLAC
create_workflow "Convert to FLAC" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" flac
        osascript -e "display notification \"Converted to FLAC: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 10. Add 2s Fade In/Out
create_workflow "Add Fade Effects (2s)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow fade "$f" 2 2
        osascript -e "display notification \"Added fade effects: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 11. Speed Up 1.5x
create_workflow "Speed Up (1.5x)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow speed "$f" 150
        osascript -e "display notification \"Speed increased to 1.5x: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 12. Extract Audio from Video
create_workflow "Extract Audio from Video" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow extract-audio "$f" mp3
        osascript -e "display notification \"Extracted audio: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 13. Apply Bass Boost
create_workflow "Apply Bass Boost" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow eq "$f" bass
        osascript -e "display notification \"Applied bass boost: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 14. Reverse Audio
create_workflow "Reverse Audio" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow reverse "$f"
        osascript -e "display notification \"Reversed audio: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 15. Get Audio Info
create_workflow "Get Audio Info" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        INFO=$(agaudioflow info "$f" 2>&1)
        DURATION=$(echo "$INFO" | grep Duration | cut -d":" -f2 | xargs)
        CHANNELS=$(echo "$INFO" | grep Channels | cut -d":" -f2 | xargs)
        BITRATE=$(echo "$INFO" | grep Bitrate | cut -d":" -f2 | xargs)
        osascript -e "display dialog \"Audio Info for $(basename "$f"):\n\nDuration: $DURATION\nChannels: $CHANNELS\nBitrate: $BITRATE\" buttons {\"OK\"} default button 1 with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 16. Convert to AAC
create_workflow "Convert to AAC" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" aac
        osascript -e "display notification \"Converted to AAC: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 17. Convert to OGG
create_workflow "Convert to OGG" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow convert "$f" ogg
        osascript -e "display notification \"Converted to OGG: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 18. Force Mono (1 Channel)
create_workflow "Force Mono (1 Channel)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow channels "$f" 1
        osascript -e "display notification \"Converted to mono: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 19. Force Stereo (2 Channels)
create_workflow "Force Stereo (2 Channels)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow channels "$f" 2
        osascript -e "display notification \"Converted to stereo: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 20. Upsample to 48kHz
create_workflow "Upsample to 48kHz" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow sample-rate "$f" 48000
        osascript -e "display notification \"Upsampled to 48kHz: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 21. Downsample to 44.1kHz (CD Quality)
create_workflow "CD Quality (44.1kHz)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow sample-rate "$f" 44100
        osascript -e "display notification \"Converted to CD quality: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 22. Apply Treble Boost
create_workflow "Apply Treble Boost" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow eq "$f" treble
        osascript -e "display notification \"Applied treble boost: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 23. Apply Vocal Enhancement
create_workflow "Vocal Enhancement" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow eq "$f" vocal
        osascript -e "display notification \"Applied vocal enhancement: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 24. Apply Loudness Enhancement
create_workflow "Loudness Enhancement" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow eq "$f" loudness
        osascript -e "display notification \"Applied loudness enhancement: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 25. Slow Down (50%)
create_workflow "Slow Down (50%)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow speed "$f" 50
        osascript -e "display notification \"Slowed down to 50%: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 26. Speed Up (200% - Double)
create_workflow "Double Speed (200%)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow speed "$f" 200
        osascript -e "display notification \"Doubled speed to 200%: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 27. Normalize for Spotify (-14 LUFS)
create_workflow "Normalize for Spotify" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow normalize "$f" -14
        osascript -e "display notification \"Normalized for Spotify: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 28. Normalize for Broadcast (-23 LUFS)
create_workflow "Normalize for Broadcast" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow normalize "$f" -23
        osascript -e "display notification \"Normalized for broadcast: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 29. High Volume Boost (+10dB)
create_workflow "High Volume Boost (+10dB)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow volume "$f" 10
        osascript -e "display notification \"High volume boost applied: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

# 30. Significant Volume Reduction (-10dB)
create_workflow "Volume Reduction (-10dB)" '#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
for f in "$@"; do
    if command -v agaudioflow &> /dev/null; then
        agaudioflow volume "$f" -10
        osascript -e "display notification \"Volume reduced: $(basename "$f")\" with title \"AG AudioFlow\""
    else
        osascript -e "display notification \"AG AudioFlow CLI not found. Please run install.sh\" with title \"AG AudioFlow Error\""
    fi
done'

echo ""
echo "✅ AG AudioFlow Quick Actions have been installed!"
echo ""
echo "📊 Installed Quick Actions (30 total):"
echo "   🎵 Format Conversion: MP3, WAV, FLAC, AAC, OGG"
echo "   🎚️ Stereo Processing: Stereo↔Mono, Split Channels"
echo "   📊 Normalization: General, Spotify (-14), Broadcast (-23)"
echo "   🔊 Volume Control: +5dB, -5dB, +10dB, -10dB"
echo "   ✂️ Audio Enhancement: Trim Silence, Fade Effects"
echo "   ⚡ Speed Control: 50%, 150%, 200% (with pitch preservation)"
echo "   🎛️ EQ Presets: Bass, Treble, Vocal, Loudness"
echo "   🔧 Technical: Force Mono/Stereo, 44.1kHz/48kHz resampling"
echo "   🎬 Video Support: Extract Audio from Video"
echo "   🔄 Effects: Reverse Audio"
echo "   📋 Utility: Get Audio Information"
echo ""
echo "To use them:"
echo "1. Right-click on any audio file in Finder"
echo "2. Look for 'Quick Actions' or 'Services' in the context menu"
echo "3. Select any AG AudioFlow action"
echo ""
echo "Note: You may need to enable these services in:"
echo "System Preferences > Extensions > Finder > Quick Actions"