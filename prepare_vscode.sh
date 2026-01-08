#!/usr/bin/env bash
# shellcheck disable=SC1091,2154
set -e

. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# 1. Run settings injection
../update_settings.sh

# 2. Apply patches with clean loop logic
echo "Applying patches at ../patches/*.patch..."

# Use a safer loop that handles the case when no files match
shopt -s nullglob  # This prevents the glob from being literal if no files match

for file in ../patches/*.patch; do
    # Skip specific patches handled by update_settings.sh
    if [[ "$file" == *"add-remote-url.patch"* ]] || [[ "$file" == *"binary-name.patch"* ]]; then
        echo "Skipping $file (logic handled by update_settings.sh)"
        continue
    fi
    
    # Apply the patch
    if [[ -f "$file" ]]; then
        echo "Applying patch: $file"
        apply_patch "$file"
    fi
done

shopt -u nullglob  # Restore default behavior

# 3. Global Rebranding
echo "Performing global rebranding to Prism..."
REPLACE_FILES="\( -name '*.json' -o -name '*.template' -o -name '*.iss' -o -name '*.xml' -o -name '*.ts' \)"

find . -type f $REPLACE_FILES -not -path "./build/*" -exec sed -i 's|voideditor/void|Danielkayode/binaries|g' {} +
find . -type f $REPLACE_FILES -not -path "./build/*" -exec sed -i 's|Void Editor|Prism-Editor|g' {} +
find . -type f $REPLACE_FILES -not -path "./build/*" -exec sed -i 's|Void|Prism|g' {} +
find . -type f $REPLACE_FILES -not -path "./build/*" -exec sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g' {} +

# 4. Sync package.json version
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# 5. Fix Dependencies
# Rebranding changes the project name/version, so 'npm ci' would fail.
# 'npm install' is used here to recalculate the package-lock.json.
echo "Installing dependencies and updating lockfile..."
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm install --no-audit --no-fund

echo "VS Code source prepared successfully for Prism."
