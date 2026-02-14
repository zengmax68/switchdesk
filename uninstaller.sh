#!/usr/bin/env bash

set -e

echo "Uninstalling switchdesk..."

# Remove the installed binary
if [ -f /usr/local/bin/switchdesk ]; then
    sudo rm /usr/local/bin/switchdesk
    echo "Removed /usr/local/bin/switchdesk"
else
    echo "switchdesk is not installed in /usr/local/bin"
fi

echo
echo "switchdesk has been uninstalled."
