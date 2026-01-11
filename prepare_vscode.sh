#!/usr/bin/env bash
# shellcheck disable=SC1091,2154
set -e

. ./utils.sh

# Ensure we are in the vscode directory
if [[ "$(basename "$PWD")" != "vscode" ]]; then
    cd vscode || { echo "'vscode' dir not found"; exit 1; }
fi

# 1. Run settings injection
../update_settings.sh

# 2. Apply patches
echo "Applying patches at ../patches/*.patch..."
for file in ../patches/*.patch; do
    if [[ ! -f "$file" ]]; then
        continue
    fi
    
    # FIX: Skip obsolete patches or those handled by update_settings.sh
    if [[ "$file" == *"add-remote-url.patch"* ]] || \
       [[ "$file" == *"binary-name.patch"* ]] || \
       [[ "$file" == *"fix-gulpfile-reh-dependency.patch"* ]]; then
        echo "Skipping $file (logic handled by update_settings.sh or patch is obsolete)"
        continue
    fi
    
    apply_patch "$file"
done

# 3. Global Rebranding
echo "Performing global rebranding to Prism..."

# FIX: Inline the find arguments to avoid shell expansion errors with parentheses
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" -exec sed -i 's|voideditor/void|Danielkayode/binaries|g' {} +
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" -exec sed -i 's|Void Editor|Prism-Editor|g' {} +
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" -exec sed -i 's|Void|Prism|g' {} +
find . -type f \( -name "*.json" -o -name "*.template" -o -name "*.iss" -o -name "*.xml" -o -name "*.ts" \) -not -path "./build/*" -exec sed -i 's|voideditor.com|github.com/Danielkayode/binaries|g' {} +

# 4. Sync package.json version
sed -i "s/\"version\": \".*\"/\"version\": \"${RELEASE_VERSION%-insider}\"/" package.json

# 5. Fix Dependencies
echo "Installing dependencies and updating lockfile..."
export ELECTRON_SKIP_BINARY_DOWNLOAD=1
npm install --no-audit --no-fund

# FIX: Return to the parent directory so the calling script (build.sh) can continue correctly
cd ..

echo "VS Code source prepared successfully for Prism."
