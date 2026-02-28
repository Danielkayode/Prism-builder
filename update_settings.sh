#!/usr/bin/env bash
# shellcheck disable=SC1091,2148
. ../utils.sh

echo "Injecting Prism-specific configurations..."
URL="https://github.com/${GH_REPO_PATH}/releases/download/${RELEASE_VERSION}/${APP_NAME_LC}-reh-\${os}-\${arch}-${RELEASE_VERSION}.tar.gz"

# Inject Remote URL Template or replace placeholders if already present
if [[ -f "build/gulpfile.reh.js" ]]; then
    if grep -q "serverDownloadUrlTemplate" build/gulpfile.reh.js; then
        sed -i "s|!!RELEASE_VERSION!!|${RELEASE_VERSION}|g" build/gulpfile.reh.js
        sed -i "s|!!GH_REPO_PATH!!|${GH_REPO_PATH}|g" build/gulpfile.reh.js
        sed -i "s|!!APP_NAME_LC!!|${APP_NAME_LC}|g" build/gulpfile.reh.js
    else
        sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' }))@g" build/gulpfile.reh.js
    fi
fi

if [[ -f "build/gulpfile.vscode.js" ]]; then
    if grep -q "serverDownloadUrlTemplate" build/gulpfile.vscode.js; then
        sed -i "s|!!RELEASE_VERSION!!|${RELEASE_VERSION}|g" build/gulpfile.vscode.js
        sed -i "s|!!GH_REPO_PATH!!|${GH_REPO_PATH}|g" build/gulpfile.vscode.js
        sed -i "s|!!APP_NAME_LC!!|${APP_NAME_LC}|g" build/gulpfile.vscode.js
    else
        sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' }))@g" build/gulpfile.vscode.js
    fi

    # Inject Binary Name - Note: code-oss might not be in quotes anymore or might be different
    sed -i "s/name: 'code-oss'/name: '${BINARY_NAME}'/g" build/gulpfile.vscode.js
fi

echo "Update settings completed successfully."
