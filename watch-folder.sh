#!/bin/bash

# Apple Workflow-Free File Watcher
# Automatically process audio files when added to watched folders

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

WATCH_DIR="${1:-$HOME/Desktop/AudioFlow Watch}"
ACTION="${2:-normalize}"

print_usage() {
    echo "AG AudioFlow - Apple Workflow-Free File Watcher"
    echo "=============================================="
    echo ""
    echo "Usage: $0 [watch-directory] [action]"
    echo ""
    echo "Actions:"
    echo "  normalize      - Normalize audio levels (default)"
    echo "  stereo-to-mono - Convert stereo to mono"
    echo "  convert-mp3    - Convert to MP3 format"
    echo "  convert-wav    - Convert to WAV format"
    echo "  volume-up      - Increase volume by 5dB"
    echo "  volume-down    - Decrease volume by 5dB"
    echo "  trim-silence   - Remove silence from ends"
    echo "  bass-boost     - Apply bass enhancement"
    echo ""
    echo "Examples:"
    echo "  $0                                    # Watch ~/Desktop/AudioFlow Watch, normalize files"
    echo "  $0 ~/Music/Process convert-mp3       # Watch ~/Music/Process, convert to MP3"
    echo "  $0 ~/Desktop/Podcast normalize       # Watch ~/Desktop/Podcast, normalize"
    echo ""
    echo "How it works:"
    echo "1. Creates/watches the specified directory"
    echo "2. When audio files are added, automatically processes them"
    echo "3. Processed files are moved to 'Processed' subfolder"
    echo "4. No Apple workflows needed!"
}

if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
    print_usage
    exit 0
fi

# Check if fswatch is available (for file monitoring)
if ! command -v fswatch &> /dev/null; then
    echo "Installing fswatch for file monitoring..."
    if command -v brew &> /dev/null; then
        brew install fswatch
    else
        echo "Error: Homebrew not found. Please install fswatch manually."
        exit 1
    fi
fi

# Create watch directory if it doesn't exist
mkdir -p "$WATCH_DIR"
mkdir -p "$WATCH_DIR/Processed"

echo "🔍 AG AudioFlow File Watcher (Apple Workflow-Free)"
echo "=================================================="
echo ""
echo "📁 Watching: $WATCH_DIR"
echo "⚡ Action: $ACTION"
echo "📤 Processed files go to: $WATCH_DIR/Processed"
echo ""
echo "💡 Drop audio files into the watch folder to process them automatically!"
echo "🛑 Press Ctrl+C to stop watching"
echo ""

# Function to process a file
process_file() {
    local FILE="$1"
    local BASENAME=$(basename "$FILE")
    local EXTENSION="${FILE##*.}"

    # Skip if not an audio file
    if [[ ! "$EXTENSION" =~ ^(mp3|wav|aac|flac|ogg|m4a|wma)$ ]]; then
        return
    fi

    # Skip if file is still being written (check file size stability)
    local SIZE1=$(stat -f%z "$FILE" 2>/dev/null || echo 0)
    sleep 1
    local SIZE2=$(stat -f%z "$FILE" 2>/dev/null || echo 0)

    if [[ "$SIZE1" != "$SIZE2" ]]; then
        echo "⏳ File still being written, waiting..."
        return
    fi

    echo "🎵 Processing: $BASENAME"

    local OUTPUT_FILE="$WATCH_DIR/Processed/${BASENAME%.*}_processed.${EXTENSION}"

    case "$ACTION" in
        "normalize")
            agaudioflow normalize "$FILE" "$OUTPUT_FILE"
            ;;
        "stereo-to-mono")
            agaudioflow stereo-to-mono "$FILE" mix "$OUTPUT_FILE"
            ;;
        "convert-mp3")
            OUTPUT_FILE="$WATCH_DIR/Processed/${BASENAME%.*}_processed.mp3"
            agaudioflow convert "$FILE" mp3 "$OUTPUT_FILE"
            ;;
        "convert-wav")
            OUTPUT_FILE="$WATCH_DIR/Processed/${BASENAME%.*}_processed.wav"
            agaudioflow convert "$FILE" wav "$OUTPUT_FILE"
            ;;
        "volume-up")
            agaudioflow volume "$FILE" 5 "$OUTPUT_FILE"
            ;;
        "volume-down")
            agaudioflow volume "$FILE" -5 "$OUTPUT_FILE"
            ;;
        "trim-silence")
            agaudioflow trim-silence "$FILE" "$OUTPUT_FILE"
            ;;
        "bass-boost")
            agaudioflow eq "$FILE" bass "$OUTPUT_FILE"
            ;;
        *)
            echo "❌ Unknown action: $ACTION"
            return
            ;;
    esac

    if [[ $? -eq 0 ]]; then
        echo "✅ Completed: $BASENAME → Processed/$(basename "$OUTPUT_FILE")"
        # Move original to processed folder
        mv "$FILE" "$WATCH_DIR/Processed/original_$BASENAME"

        # Show notification
        osascript -e "display notification \"Processed: $BASENAME\" with title \"AG AudioFlow Watcher\""
    else
        echo "❌ Failed to process: $BASENAME"
    fi

    echo ""
}

# Watch the directory for new files
fswatch -o "$WATCH_DIR" --exclude="$WATCH_DIR/Processed" | while read; do
    # Process all new audio files in the directory
    for FILE in "$WATCH_DIR"/*.{mp3,wav,aac,flac,ogg,m4a,wma} 2>/dev/null; do
        if [[ -f "$FILE" ]] && [[ ! "$FILE" =~ Processed ]]; then
            process_file "$FILE"
        fi
    done
done