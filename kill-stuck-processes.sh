#!/bin/bash

echo "🛑 Killing stuck AG AudioFlow processes..."

# Kill node processes related to agaudioflow
pkill -f "agaudioflow" && echo "✓ Killed agaudioflow processes"

# Kill any stuck ffmpeg processes
pkill -f "ffmpeg" && echo "✓ Killed ffmpeg processes"

# Kill any node processes that might be stuck
pkill -f "node.*agaudioflow" && echo "✓ Killed stuck node processes"

echo "✅ Done! Stuck processes should be terminated."
echo ""
echo "You can now try running AG AudioFlow again."