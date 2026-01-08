#!/usr/bin/env bash
# shellcheck disable=SC1091,2154

set -e
. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# 1. Run settings injection
../update_settings.sh

# 2. Apply patches
echo "Applying patches at ../patches/*.patch..."
for file in ../patches/*.patch; do
  if [[ ! -f "$file" ]]; then
    continue
  fi

  # Skip patches handled by sed in update_settings.sh
  if [[ "$file" == *"add-remote-url.patch" || "$file" == *"binary-name.patch" ]]; then
    echo "Skipping $file (logic handled by update_settings.sh)"
  else
    apply_patch "$file"
  fi
done

# 3. Global Rebranding (Exclude build directory)
echo "Performing global rebranding to Prism..."
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|voideditor/void|Danielkayode/binaries|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|Void Editor|Prism-Editor|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|Void|Prism|g'
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" | xargs sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g'

# 4. Sync package.json version
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# 5. Dependency Install (Fixes the lockfile error)
echo "Installing dependencies and updating lockfile..."
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm install --no-audit --no-fund

echo "VS Code source prepared successfully for Prism."
