#!/bin/bash

# Create a single Quick Action for testing
# Usage: ./create-quick-action.sh "Action Name" "command to run"

ACTION_NAME="$1"
COMMAND="$2"

if [ -z "$ACTION_NAME" ] || [ -z "$COMMAND" ]; then
    echo "Usage: $0 \"Action Name\" \"command to run\""
    exit 1
fi

SERVICES_DIR="$HOME/Library/Services"
mkdir -p "$SERVICES_DIR"

WORKFLOW_PATH="$SERVICES_DIR/AG AudioFlow - $ACTION_NAME.workflow"

echo "Creating Quick Action: $ACTION_NAME"

# Remove existing workflow
rm -rf "$WORKFLOW_PATH"

# Create the workflow using Automator's command line tool
cat > /tmp/ag_workflow_script.sh << 'EOF'
#!/bin/bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
COMMAND_TO_RUN
EOF

# Replace the placeholder with actual command
sed "s|COMMAND_TO_RUN|$COMMAND|g" /tmp/ag_workflow_script.sh > /tmp/ag_final_script.sh

# Create Automator workflow programmatically
osascript << EOF
tell application "Automator"
    set newWorkflow to make new service document
    tell newWorkflow
        -- Set service to receive files
        set the input type to "files and folders"
        set the application name to "Finder"

        -- Add Run Shell Script action
        set theAction to make new action at the end of actions with properties {name:"Run Shell Script"}
        tell theAction
            set the value of parameter "inputMethod" to 1
            set the value of parameter "shell" to "/bin/bash"
            set the value of parameter "COMMAND_STRING" to (read POSIX file "/tmp/ag_final_script.sh" as string)
        end tell
    end tell

    save newWorkflow in POSIX file "$WORKFLOW_PATH"
    close newWorkflow
end tell
EOF

# Cleanup
rm -f /tmp/ag_workflow_script.sh /tmp/ag_final_script.sh

echo "✓ Created: $ACTION_NAME"