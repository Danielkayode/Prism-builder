#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e

# include common functions
. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# Run the settings and URL injection script
../update_settings.sh

# Apply patches
{ set +x; } 2>/dev/null

echo "Applying patches at ../patches/*.patch..."
for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    # We skip the specific patch file that was causing the build to fail
    if [[ "${file}" == *"add-remote-url.patch" ]]; then
      echo "Skipping ${file} (logic handled by update_settings.sh)"
      continue
    fi
    apply_patch "${file}"
  fi
done

# Standard VS Code build preparation continues...
if [[ "${VSCODE_QUALITY}" == "insider" ]]; then
  echo "Applying insider patches..."
  for file in ../patches/insider/*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

# Apply OS-specific patches if they exist
if [[ -d "../patches/${OS_NAME}/" ]]; then
  echo "Applying OS patches for ${OS_NAME}..."
  for file in ../patches/${OS_NAME}/*.patch; do
    if [[ -f "${file}" ]]; then
      apply_patch "${file}"
    fi
  done
fi

echo "VS Code source prepared successfully."
