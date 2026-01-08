#!/usr/bin/env bash
# shellcheck disable=SC1091,2148

# Define constants for settings search
DEFAULT_TRUE="'default': true"
DEFAULT_FALSE="'default': false"
DEFAULT_ON="'default': TelemetryConfiguration.ON"
DEFAULT_OFF="'default': TelemetryConfiguration.OFF"
TELEMETRY_CRASH_REPORTER="'telemetry.enableCrashReporter':"
TELEMETRY_CONFIGURATION=" TelemetryConfiguration.ON"
NLS="workbench.settings.enableNaturalLanguageSearch"

# include common functions
. ../utils.sh

update_setting () {
  local FILENAME SETTING LINE_NUM IN_SETTING FOUND DEFAULT_TRUE_TO_FALSE

  FILENAME="${2}"
  if [[ ! -f "${FILENAME}" ]]; then
    echo "File to update setting in does not exist ${FILENAME}"
    return
  fi

  SETTING="${1}"
  LINE_NUM=0
  # Search for the line where the setting is defined
  while read -r line; do
    LINE_NUM=$(( LINE_NUM + 1 ))
    if [[ "${line}" == *"${SETTING}"* ]]; then
      IN_SETTING=1
    fi
    if [[ ("${line}" == *"${DEFAULT_TRUE}"* || "${line}" == *"${DEFAULT_ON}"*) && "${IN_SETTING}" == "1" ]]; then
      FOUND=1
      break
    fi
  done < "${FILENAME}"

  if [[ "${FOUND}" != "1" ]]; then
    echo "Default value not found for setting ${SETTING} in ${FILENAME}"
    return
  fi

  # Replace the found line with the disabled version
  if [[ "${line}" == *"${DEFAULT_TRUE}"* ]]; then
    DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_TRUE}/${DEFAULT_FALSE}/"
  else
    DEFAULT_TRUE_TO_FALSE="${LINE_NUM}s/${DEFAULT_ON}/${DEFAULT_OFF}/"
  fi

  replace "${DEFAULT_TRUE_TO_FALSE}" "${FILENAME}"
}

# Apply standard telemetry updates
update_setting "${TELEMETRY_CRASH_REPORTER}" src/vs/workbench/electron-sandbox/desktop.contribution.ts
update_setting "${TELEMETRY_CONFIGURATION}" src/vs/platform/telemetry/common/telemetryService.ts
update_setting "${NLS}" src/vs/workbench/contrib/preferences/common/preferencesContribution.ts

# --- INJECT REMOTE DOWNLOAD URL ---
# This replaces the failing add-remote-url.patch file
echo "Injecting serverDownloadUrlTemplate into Gulp files..."

# Construct the URL using environment variables
URL="https://github.com/${GH_REPO_PATH}/releases/download/${RELEASE_VERSION}/${APP_NAME_LC}-reh-\${os}-\${arch}-${RELEASE_VERSION}.tar.gz"

# We use '@' as a separator for sed because the URL contains forward slashes
sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' })@g" build/gulpfile.reh.js
sed -i "s@version }))@version, serverDownloadUrlTemplate: '${URL}' })@g" build/gulpfile.vscode.js

echo "Update settings completed successfully."
