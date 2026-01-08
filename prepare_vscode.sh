#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e
. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# 1. Run the unified settings and injection script
../update_settings.sh

# 2. Apply patches, skipping those now handled by sed logic
echo "Applying patches at ../patches/*.patch..."
for file in ../patches/*.patch; do
  if [[ -f "${file}" ]]; then
    # Skip patches that conflict with our direct sed replacements
    if [[ "${file}" == *"add-remote-url.patch" || "${file}" == *"binary-name.patch" ]]; then
      echo "Skipping ${file} (logic handled by update_settings.sh)"
      continue
    fi
    apply_patch "${file}"
  fi
done

# 3. Global Rebranding
echo "Performing global rebranding to Prism..."
# Exclude build dir to prevent breaking the Gulp logic we injected
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|voideditor/void|Danielkayode/binaries|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|Void Editor|Prism-Editor|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|Void|Prism|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g'

# 4. Sync package.json version
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# 5. Fix Dependencies
echo "Installing dependencies and updating lockfile..."
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm install --no-audit --no-fund

echo "VS Code source prepared successfully for Prism."
