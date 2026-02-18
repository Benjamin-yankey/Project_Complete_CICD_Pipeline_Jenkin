#!/bin/bash

# Fix Jenkins PATH to include Node.js and Docker

JENKINS_HOME="/Users/huey/.jenkins"
PLIST_FILE="$HOME/Library/LaunchAgents/homebrew.mxcl.jenkins-lts.plist"

echo "Configuring Jenkins environment..."

# Create environment variables file
cat > "$JENKINS_HOME/environment.sh" << 'EOF'
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
EOF

chmod +x "$JENKINS_HOME/environment.sh"

# Restart Jenkins
echo "Restarting Jenkins..."
brew services restart jenkins-lts

echo "✅ Done! Wait 30 seconds, then re-run your pipeline."
echo "If still failing, go to Jenkins → Manage Jenkins → System"
echo "Under 'Global properties', check 'Environment variables' and add:"
echo "  Name: PATH"
echo "  Value: /opt/homebrew/bin:/usr/local/bin:\$PATH"
