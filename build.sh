#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex
. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  # 1. Prepare Source
  # This script enters the 'vscode' directory to run operations.
  . prepare_vscode.sh

  # FIX: Check if we are already inside 'vscode' before trying to cd into it.
  # prepare_vscode.sh changes directory to 'vscode', so we might already be there.
  if [[ "$(basename "$PWD")" != "vscode" ]]; then
      cd vscode || { echo "'vscode' dir not found"; exit 1; }
  fi

  # --------------------------------------------------------------------------------------------
  # FIX: Manually patch build/lib/util.js to prevent crash on electron version check
  # The original code looks for .npmrc regex which fails. We force it to read package.json.
  # --------------------------------------------------------------------------------------------
  UTIL_JS="build/lib/util.js"
  if [[ -f "$UTIL_JS" ]]; then
      echo "Applying hotfix to $UTIL_JS..."
      # Replace the line reading .npmrc with reading package.json
      sed -i 's/const npmrc =.*/const packageJson = JSON.parse(fs_1.default.readFileSync(path_1.default.join(root, "package.json"), "utf8"));/' "$UTIL_JS"
      # Replace the regex extraction with direct JSON access
      sed -i 's/const electronVersion =.*/const electronVersion = packageJson.devDependencies.electron;/' "$UTIL_JS"
      # Disable msBuildId check
      sed -i 's/const msBuildId =.*/const msBuildId = "";/' "$UTIL_JS"
  else
      echo "Warning: $UTIL_JS not found. Build may fail if using legacy build scripts."
  fi
  # --------------------------------------------------------------------------------------------

  export NODE_OPTIONS="--max-old-space-size=8192"

  # 2. Build
  npm run buildreact
  npm run gulp compile-build-without-mangling
  npm run gulp compile-extension-media
  npm run gulp compile-extensions-build
  npm run gulp minify-vscode

  # 3. Packaging
  if [[ "${OS_NAME}" == "linux" ]]; then
      npm run gulp "vscode-linux-${VSCODE_ARCH}-min-ci"
      # Source build_cli.sh from the parent directory
      . ../build_cli.sh
  fi
fi
