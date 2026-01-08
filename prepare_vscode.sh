#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e
. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# Run the unified settings and injection script
../update_settings.sh

# Apply patches, skipping those now handled by sed
echo "Applying patches at ../patches/*.patch..."
for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    if [[ "${file}" == *"add-remote-url.patch" || "${file}" == *"binary-name.patch" ]]; then
      echo "Skipping ${file} (logic handled by update_settings.sh)"
      continue
    fi
    apply_patch "${file}"
  fi
done

# Perform Global Rebranding: Replace Void with Prism in all config files
echo "Performing global rebranding to Prism..."
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" \) | xargs sed -i 's|voideditor/void|Danielkayode/binaries|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" \) | xargs sed -i 's|Void Editor|Prism-Editor|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" \) | xargs sed -i 's|Void|Prism|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" \) | xargs sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g'

# Set product and package versions
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# Continue with standard build setup (npm ci)
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm ci

echo "VS Code source prepared successfully for Prism."
