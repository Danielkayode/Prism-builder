#!/bin/bash

# Application name and branding
APP_NAME="${APP_NAME:-Prism}"
APP_NAME_LC=$( echo "${APP_NAME}" | awk '{print tolower($0)}' )
BINARY_NAME="${BINARY_NAME:-prism}"

# GitHub configuration
GH_REPO_PATH="${GH_REPO_PATH:-Danielkayode/binaries}"
ORG_NAME="${ORG_NAME:-Danielkayode}"

echo "---------- utils.sh -----------"
echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "ORG_NAME=\"${ORG_NAME}\""

# Check if GNU sed is available
exists() {
  type -t "$1" > /dev/null 2>&1
}

is_gnu_sed() {
  sed --version >/dev/null 2>&1
}

# Use gsed if available (macOS), otherwise regular sed
if exists gsed; then
  REPLACE="gsed"
elif is_gnu_sed; then
  REPLACE="sed"
else
  REPLACE="sed"
fi

export APP_NAME
export APP_NAME_LC
export BINARY_NAME
export GH_REPO_PATH
export ORG_NAME
export REPLACE
