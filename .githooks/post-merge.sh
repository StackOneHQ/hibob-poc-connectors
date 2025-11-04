#!/bin/bash

# -----------------------------------------------------------------------------
# Git Hook: post-merge
# -----------------------------------------------------------------------------
# After merging/pulling changes, checks for a newer version of the SDK
# and installs it automatically if needed.
# -----------------------------------------------------------------------------

# Navigate to the root directory of the repository
cd "$(git rev-parse --show-toplevel)"

# Define color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

echo "${yellow}Checking for newer version of @stackone/connect-sdk...${reset}"

# Run npm outdated and capture the output
OUTDATED_OUTPUT=$(npm outdated @stackone/connect-sdk 2>/dev/null)

# Parse the latest version if the package is listed as outdated
if echo "$OUTDATED_OUTPUT" | grep -q '@stackone/connect-sdk'; then
    # Extract the version number from the output
    LATEST_VERSION=$(echo "$OUTDATED_OUTPUT" | grep '@stackone/connect-sdk' | awk '{print $4}')

    echo "${green}Updating @stackone/connect-sdk to version ${yellow}${LATEST_VERSION}${reset}"
    npm install "@stackone/connect-sdk@$LATEST_VERSION"

    # If package.json or package-lock.json changed, stage them
    for file in package.json package-lock.json; do
        if git diff --name-only | grep -q "$file"; then
            echo "${green}  Staging: ${yellow}$file${reset}"
            git add "$file"
        fi
    done
else
    echo "${green}@stackone/connect-sdk is already up to date.${reset}"
fi
