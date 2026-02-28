#!/usr/bin/env bash
# shellcheck disable=SC1091

set -ex
. version.sh

if [[ "${SHOULD_BUILD}" == "yes" ]]; then
  # 1. Prepare Source
  . prepare_vscode.sh

  # Sourcing prepare_vscode.sh (which sources utils.sh) gives us access to ensure_in_vscode
  # prepare_vscode.sh ends with 'cd ..', so we need to enter 'vscode' again.
  ensure_in_vscode

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

  # Return to parent directory to ensure subsequent steps (like compression) work as expected
  cd ..
fi 
