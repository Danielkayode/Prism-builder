#!/bin/bash

set -e

# Source repository to clone
# Option 1: Clone Void's repository (recommended if you're just rebranding)
REPO_URL="https://github.com/voideditor/void.git"

# Option 2: Clone your fork (if you've created one)
# REPO_URL="https://github.com/Danielkayode/prism-source.git"

BRANCH="main"

if [ -d "vscode" ]; then
  echo "vscode directory already exists, skipping clone"
  cd vscode
  git fetch origin
  cd ..
else
  echo "Cloning Prism source from Void..."
  echo "Repository: $REPO_URL"
  
  git clone --branch "$BRANCH" --depth 1 "$REPO_URL" vscode
  
  cd vscode
  
  # If a specific commit is provided via workflow input
  if [ -n "$PRISM_COMMIT" ]; then
    echo "Checking out specific commit: $PRISM_COMMIT"
    git fetch --depth 1 origin "$PRISM_COMMIT"
    git checkout "$PRISM_COMMIT"
  fi
  
  cd ..
fi

# If a custom release version is provided
if [ -n "$PRISM_RELEASE" ]; then
  echo "Using custom release version: $PRISM_RELEASE"
  export RELEASE_VERSION="$PRISM_RELEASE"
fi

echo "Void source cloned successfully"
