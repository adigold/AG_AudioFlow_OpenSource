#!/bin/bash

# Test script to debug what's happening when services run

echo "🧪 Testing AG AudioFlow Service"
echo "==============================="
echo ""

# Test 1: Check if agaudioflow is installed
echo "1. Checking agaudioflow installation:"
if [ -f "/usr/local/bin/agaudioflow" ]; then
    echo "   ✅ Found at /usr/local/bin/agaudioflow"
    if [ -x "/usr/local/bin/agaudioflow" ]; then
        echo "   ✅ Script is executable"
    else
        echo "   ❌ Script is not executable"
        echo "   Fix: sudo chmod +x /usr/local/bin/agaudioflow"
    fi
else
    echo "   ❌ agaudioflow not found at /usr/local/bin/agaudioflow"
    echo "   Run: ./install.sh"
fi

echo ""

# Test 2: Check Node.js path in the script
echo "2. Checking Node.js in agaudioflow script:"
if [ -f "/usr/local/bin/agaudioflow" ]; then
    SHEBANG=$(head -1 /usr/local/bin/agaudioflow)
    echo "   Shebang: $SHEBANG"

    NODE_PATH=$(echo "$SHEBANG" | sed 's/#!//')
    if [ -f "$NODE_PATH" ] && [ -x "$NODE_PATH" ]; then
        echo "   ✅ Node.js found at: $NODE_PATH"
    else
        echo "   ❌ Node.js not found at: $NODE_PATH"
        echo "   Actual Node.js location: $(which node)"
        echo "   Fix needed: Update shebang in agaudioflow"
    fi
fi

echo ""

# Test 3: Try running agaudioflow directly
echo "3. Testing agaudioflow directly:"
if command -v agaudioflow &> /dev/null; then
    echo "   ✅ agaudioflow is in PATH"
    echo "   Testing with --help or no args:"
    /usr/local/bin/agaudioflow 2>&1 | head -5 || echo "   Script ran but may have errored"
else
    echo "   ❌ agaudioflow not in PATH"
fi

echo ""

# Test 4: Create test audio file and process it
echo "4. Testing with real audio file:"
cd /tmp
if command -v say &> /dev/null; then
    echo "   Creating test audio file..."
    echo "test audio" | say -o test_audio.aiff 2>/dev/null

    if [ -f "test_audio.aiff" ]; then
        echo "   ✅ Test audio file created: test_audio.aiff"
        echo "   Testing stereo-to-mono conversion..."

        /usr/local/bin/agaudioflow stereo-to-mono test_audio.aiff 2>&1 || echo "   Conversion failed"

        if [ -f "test_audio_mono.aiff" ]; then
            echo "   ✅ Conversion successful! Output file created."
            rm test_audio.aiff test_audio_mono.aiff
        else
            echo "   ❌ Conversion failed - no output file created"
        fi
    else
        echo "   ❌ Could not create test audio file"
    fi
else
    echo "   ❌ 'say' command not available for testing"
fi

echo ""
echo "5. Service debugging tips:"
echo "   - Check Console.app for error messages"
echo "   - Services run in limited environment (no user PATH)"
echo "   - Try running: /usr/local/bin/agaudioflow stereo-to-mono /path/to/audio.mp3"
echo ""