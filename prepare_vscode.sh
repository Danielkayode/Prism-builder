#!/usr/bin/env bash
# shellcheck disable=SC1091,2154
set -e

. ./utils.sh

cd vscode || { echo "'vscode' dir not found"; exit 1; }

# 1. Run settings injection
../update_settings.sh

# 2. Apply patches with clean loop logic
echo "Applying patches at ../patches/*.patch..."

# Check if patches directory exists
if [ -d "../patches" ]; then
    # Loop through all .patch files
    for file in ../patches/*.patch; do
        # Check if the glob matched any files
        if [ ! -e "$file" ]; then
            echo "No patch files found in ../patches/"
            break
        fi
        
        # Skip specific patches handled by update_settings.sh
        if [[ "$file" == *"add-remote-url.patch"* ]] || [[ "$file" == *"binary-name.patch"* ]]; then
            echo "Skipping $file (logic handled by update_settings.sh)"
            continue
        fi
        
        # Apply the patch
        echo "Applying patch: $file"
        apply_patch "$file"
    done
else
    echo "Patches directory not found, skipping patch application"
fi

# 3. Global Rebranding
echo "Performing global rebranding to Prism..."

# Find and replace in JSON, template, ISS, XML, and TS files
find . -type f \( -name '*.json' -o -name '*.template' -o -name '*.iss' -o -name '*.xml' -o -name '*.ts' \) \
    -not -path "./build/*" \
    -exec sed -i 's|voideditor/void|Danielkayode/binaries|g' {} +

find . -type f \( -name '*.json' -o -name '*.template' -o -name '*.iss' -o -name '*.xml' -o -name '*.ts' \) \
    -not -path "./build/*" \
    -exec sed -i 's|Void Editor|Prism-Editor|g' {} +

find . -type f \( -name '*.json' -o -name '*.template' -o -name '*.iss' -o -name '*.xml' -o -name '*.ts' \) \
    -not -path "./build/*" \
    -exec sed -i 's|Void|Prism|g' {} +

find . -type f \( -name '*.json' -o -name '*.template' -o -name '*.iss' -o -name '*.xml' -o -name '*.ts' \) \
    -not -path "./build/*" \
    -exec sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g' {} +

# 4. Sync package.json version
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# 5. Fix Dependencies
echo "Installing dependencies and updating lockfile..."
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm install --no-audit --no-fund

echo "VS Code source prepared successfully for Prism."
