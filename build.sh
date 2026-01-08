#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex
. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  # 1. Prepare Source
  . prepare_vscode.sh

  cd vscode || { echo "'vscode' dir not found"; exit 1; }

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
