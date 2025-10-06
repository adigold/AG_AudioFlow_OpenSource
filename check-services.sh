#!/bin/bash

# AG AudioFlow Services Diagnostic Script

echo "🔍 AG AudioFlow Services Diagnostic"
echo "====================================="
echo ""

SERVICES_DIR="$HOME/Library/Services"
WRAPPER_SCRIPT="$HOME/.agaudioflow-wrapper"

echo "1. Checking Services Directory:"
echo "   Location: $SERVICES_DIR"
if [ -d "$SERVICES_DIR" ]; then
    echo "   ✅ Services directory exists"

    echo ""
    echo "2. Looking for AG AudioFlow services:"
    ag_services=$(ls "$SERVICES_DIR" | grep "AG AudioFlow" | wc -l)
    if [ "$ag_services" -gt 0 ]; then
        echo "   ✅ Found $ag_services AG AudioFlow services:"
        ls "$SERVICES_DIR" | grep "AG AudioFlow" | sed 's/^/      /'
    else
        echo "   ❌ No AG AudioFlow services found"
        echo "      Run ./simple-services.sh to create them"
    fi
else
    echo "   ❌ Services directory doesn't exist"
    echo "      This is unusual - macOS should create this automatically"
fi

echo ""
echo "3. Checking wrapper script:"
echo "   Location: $WRAPPER_SCRIPT"
if [ -f "$WRAPPER_SCRIPT" ]; then
    if [ -x "$WRAPPER_SCRIPT" ]; then
        echo "   ✅ Wrapper script exists and is executable"
    else
        echo "   ⚠️  Wrapper script exists but is not executable"
        echo "      Fix: chmod +x '$WRAPPER_SCRIPT'"
    fi
else
    echo "   ❌ Wrapper script not found"
    echo "      Run ./simple-services.sh to create it"
fi

echo ""
echo "4. Checking for agaudioflow script:"
script_found=""
for path in "$HOME/AG_AudioFlow_OpenSource/agaudioflow" "$HOME/Downloads/AG_AudioFlow_OpenSource/agaudioflow" "/usr/local/bin/agaudioflow" "$(which agaudioflow 2>/dev/null)"; do
    if [ -f "$path" ] && [ -x "$path" ]; then
        echo "   ✅ Found agaudioflow at: $path"
        script_found="$path"
        break
    fi
done

if [ -z "$script_found" ]; then
    echo "   ❌ agaudioflow script not found"
    echo "      Make sure you have the agaudioflow script in one of these locations:"
    echo "        - $HOME/AG_AudioFlow_OpenSource/agaudioflow"
    echo "        - $HOME/Downloads/AG_AudioFlow_OpenSource/agaudioflow"
    echo "        - /usr/local/bin/agaudioflow"
fi

echo ""
echo "5. Checking prerequisites:"
if command -v node &> /dev/null; then
    echo "   ✅ Node.js found: $(node --version)"
else
    echo "   ❌ Node.js not found - install with: brew install node"
fi

if command -v ffmpeg &> /dev/null; then
    echo "   ✅ FFmpeg found: $(ffmpeg -version 2>&1 | head -1)"
else
    echo "   ❌ FFmpeg not found - install with: brew install ffmpeg"
fi

echo ""
echo "6. Service refresh commands to try:"
echo "   sudo /System/Library/CoreServices/pbs -flush"
echo "   killall Finder"
echo "   # Or restart your Mac"

echo ""
echo "7. Manual check locations:"
echo "   System Preferences > Keyboard > Shortcuts > Services"
echo "   Look for 'AG AudioFlow' in the list"

echo ""
echo "8. If services still don't work:"
echo "   - Check System Preferences > Security & Privacy > Privacy > Automation"
echo "   - Make sure apps can control Finder"
echo "   - Try logging out and back in"
echo "   - Restart your Mac"
echo ""