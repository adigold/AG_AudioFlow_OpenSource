#!/bin/bash

# Create drag-and-drop scripts that avoid Apple workflows entirely
# Users can drag files onto these scripts instead of right-clicking

echo "Creating Apple Workflow-Free Drag & Drop Scripts..."

SCRIPTS_DIR="$HOME/Desktop/AG AudioFlow Scripts"
mkdir -p "$SCRIPTS_DIR"

# Function to create a drag-and-drop script
create_drag_script() {
    local NAME="$1"
    local COMMAND="$2"
    local SCRIPT_PATH="$SCRIPTS_DIR/$NAME.command"

    cat > "$SCRIPT_PATH" << EOF
#!/bin/bash
# AG AudioFlow: $NAME
# Drag audio files onto this script to process them

export PATH="/opt/homebrew/bin:/usr/local/bin:\$PATH"

echo "AG AudioFlow - $NAME"
echo "=========================="

if [ \$# -eq 0 ]; then
    echo "Drag audio files onto this script to process them"
    echo "Or run from terminal: '\$0' file1.mp3 file2.wav ..."
    read -p "Press Enter to close..."
    exit 0
fi

for file in "\$@"; do
    if [[ -f "\$file" ]]; then
        echo "Processing: \$(basename "\$file")"
        $COMMAND
        echo "✓ Completed: \$(basename "\$file")"
    else
        echo "⚠ Skipped (not a file): \$file"
    fi
done

echo ""
echo "All files processed!"
osascript -e 'display notification "Processing complete!" with title "AG AudioFlow"'
read -p "Press Enter to close..."
EOF

    chmod +x "$SCRIPT_PATH"
    echo "✓ Created: $NAME.command"
}

echo ""
echo "Creating drag-and-drop scripts..."

# 1. Convert to MP3
create_drag_script "Convert to MP3" 'agaudioflow convert "$file" mp3'

# 2. Stereo to Mono
create_drag_script "Stereo to Mono" 'agaudioflow stereo-to-mono "$file" mix'

# 3. Normalize Audio
create_drag_script "Normalize Audio" 'agaudioflow normalize "$file"'

# 4. Volume Up
create_drag_script "Volume Up (+5dB)" 'agaudioflow volume "$file" 5'

# 5. Volume Down
create_drag_script "Volume Down (-5dB)" 'agaudioflow volume "$file" -5'

# 6. Get Audio Info
create_drag_script "Get Audio Info" 'agaudioflow info "$file"'

# 7. Trim Silence
create_drag_script "Trim Silence" 'agaudioflow trim-silence "$file"'

# 8. Speed Up
create_drag_script "Speed Up (1.5x)" 'agaudioflow speed "$file" 150'

# 9. Convert to WAV
create_drag_script "Convert to WAV" 'agaudioflow convert "$file" wav'

# 10. Apply Bass Boost
create_drag_script "Bass Boost" 'agaudioflow eq "$file" bass'

echo ""
echo "✅ Apple Workflow-Free Scripts Created!"
echo ""
echo "📁 Location: $SCRIPTS_DIR"
echo ""
echo "🖱️ How to use:"
echo "1. Navigate to: $SCRIPTS_DIR"
echo "2. Drag audio files onto any .command script"
echo "3. The script will process the files automatically"
echo ""
echo "📋 Available Scripts:"
ls -1 "$SCRIPTS_DIR"/*.command | sed 's|.*/||' | sed 's|\.command$||' | sed 's/^/   • /'
echo ""
echo "💡 Pro Tip: Add this folder to your Dock for quick access!"