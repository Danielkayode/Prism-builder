#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex
. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  # 1. Prepare Source
  . prepare_vscode.sh

  if [[ "$(basename "$PWD")" != "vscode" ]]; then
      cd vscode || { echo "'vscode' dir not found"; exit 1; }
  fi

  # --- HOTFIX: Ensure util.js uses package.json for versioning ---
  # This acts as a safety net if the patch didn't change the logic correctly
  UTIL_JS="build/lib/util.js"
  if [[ -f "$UTIL_JS" ]]; then
      sed -i 's/const npmrc =.*/const packageJson = JSON.parse(fs_1.default.readFileSync(path_1.default.join(root, "package.json"), "utf8"));/' "$UTIL_JS"
      sed -i 's/const electronVersion =.*/const electronVersion = packageJson.devDependencies.electron;/' "$UTIL_JS"
      sed -i 's/const msBuildId =.*/const msBuildId = "";/' "$UTIL_JS"
  fi
  # -----------------------------------------------------------------

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
      . ../build_cli.sh
  fi
fi
