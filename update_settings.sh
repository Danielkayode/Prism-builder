#!/usr/bin/env bash
# shellcheck disable=SC1091,2148

. ../utils.sh

# --- Prism Rebranding & Remote URL Injection ---
echo "Injecting Prism-specific configurations..."
URL="https://github.com/${GH_REPO_PATH}/releases/download/${RELEASE_VERSION}/${APP_NAME_LC}-reh-\${os}-\${arch}-${RELEASE_VERSION}.tar.gz"

# 1. Inject the serverDownloadUrlTemplate
sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' })@g" build/gulpfile.reh.js
sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' })@g" build/gulpfile.vscode.js

# 2. Inject Binary Name
sed -i "s/name: 'code-oss'/name: '${BINARY_NAME}'/g" build/gulpfile.vscode.js

echo "Update settings completed successfully."
