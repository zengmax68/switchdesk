#!/usr/bin/env bash

set -e

echo "Installing switchdesk..."

# Download the latest switchdesk.sh from GitHub
curl -fsSL https://raw.githubusercontent.com/zengmax68/switchdesk/main/switchdesk.sh -o /tmp/switchdesk.sh

# Make executable
chmod +x /tmp/switchdesk.sh

# Move into PATH
sudo mv /tmp/switchdesk.sh /usr/local/bin/switchdesk

echo "switchdesk installed successfully."
echo
echo "Run: sudo switchdesk status"
