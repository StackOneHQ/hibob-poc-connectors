#!/bin/bash

# -----------------------------------------------------------------------------
# Git Hook Installer Script
# -----------------------------------------------------------------------------
# Copies only changed or missing files from .githooks/ to .git/hooks/
# Makes them executable. Skips unchanged files. Safe to run anytime.
# -----------------------------------------------------------------------------

QUIET_MODE=false

# Detect CI automatically
if [ "$CI" = "true" ]; then
  QUIET_MODE=true
fi

log() {
  if [ "$QUIET_MODE" = false ]; then
    echo "$1"
  fi
}


HOOK_SRC_DIR=".githooks"
HOOK_DEST_DIR=".git/hooks"

# Define color variables
red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
reset=$(tput sgr0)

# Exit silently if not in a git repo
if [ ! -d "$HOOK_DEST_DIR" ]; then
  echo "${yellow}⚠️  Not a Git repo yet (.git/hooks missing). Skipping hook setup.${reset}"
  exit 0
fi

# Check if .githooks exists
if [ ! -d "$HOOK_SRC_DIR" ]; then
  echo "${red}❌ No .githooks/ directory found. Cannot install hooks.${reset}"
  exit 1
fi

log "${yellow}🔧 Checking Git hooks in ${HOOK_SRC_DIR}...${reset}"

changes=0

for hook in "$HOOK_SRC_DIR"/*; do
  [ -f "$hook" ] || continue  # Skip non-files
  hook_name=$(basename "$hook")
  src="$HOOK_SRC_DIR/$hook_name"
  dest="$HOOK_DEST_DIR/$hook_name"

  # Compare files (or check if dest doesn't exist)
  if [ ! -f "$dest" ] || ! cmp -s "$src" "$dest"; then
    cp "$src" "$dest"
    chmod +x "$dest"
    log "${green}Installed/updated hook: ${yellow}$hook_name${reset}"
    changes=$((changes + 1))
  fi
done

if [ "$changes" -eq 0 ]; then
  log "${green}All hooks already up to date.${reset}"
else
  log "${green}Git hook setup complete. ${changes} hook(s) installed or updated.${reset}"
fi
