#!/bin/bash

set -e

. ../utils.sh

echo "---------- update_settings.sh -----------"
echo "APP_NAME=\"${APP_NAME}\""
echo "APP_NAME_LC=\"${APP_NAME_LC}\""
echo "BINARY_NAME=\"${BINARY_NAME}\""
echo "GH_REPO_PATH=\"${GH_REPO_PATH}\""
echo "ORG_NAME=\"${ORG_NAME}\""

echo ""
echo "Rebranding from Void to ${APP_NAME}..."

# Update product.json
if [ -f "product.json" ]; then
  echo "Updating product.json..."
  
  # Replace name
  ${REPLACE} -i "s|\"nameShort\": \"Void\"|\"nameShort\": \"${APP_NAME}\"|g" product.json
  ${REPLACE} -i "s|\"nameLong\": \"Void\"|\"nameLong\": \"${APP_NAME}\"|g" product.json
  
  # Replace application name
  ${REPLACE} -i "s|\"applicationName\": \"void\"|\"applicationName\": \"${BINARY_NAME}\"|g" product.json
  
  # Replace data folder
  ${REPLACE} -i "s|\"dataFolderName\": \".void\"|\"dataFolderName\": \".${BINARY_NAME}\"|g" product.json
  
  # Replace URLs and identifiers
  ${REPLACE} -i "s|voideditor|${ORG_NAME}|g" product.json
  ${REPLACE} -i "s|void-editor|${BINARY_NAME}-editor|g" product.json
  
  # Update Windows identifiers
  ${REPLACE} -i "s|\"win32MutexName\": \"void\"|\"win32MutexName\": \"${BINARY_NAME}\"|g" product.json
  ${REPLACE} -i "s|\"win32DirName\": \"Void\"|\"win32DirName\": \"${APP_NAME}\"|g" product.json
  ${REPLACE} -i "s|\"win32NameVersion\": \"Void\"|\"win32NameVersion\": \"${APP_NAME}\"|g" product.json
  ${REPLACE} -i "s|\"win32AppUserModelId\": \"Void.Void\"|\"win32AppUserModelId\": \"${APP_NAME}.${APP_NAME}\"|g" product.json
  ${REPLACE} -i "s|\"win32AppId\": \"{{.*}}\"|\"win32AppId\": \"{{${APP_NAME}}}\"|g" product.json
  
  # Update shortcuts
  ${REPLACE} -i "s|\"win32ShellNameShort\": \"Void\"|\"win32ShellNameShort\": \"${APP_NAME}\"|g" product.json
  
  # Update Linux identifiers
  ${REPLACE} -i "s|\"linuxIconName\": \"void\"|\"linuxIconName\": \"${BINARY_NAME}\"|g" product.json
  
  # Update URLs
  ${REPLACE} -i "s|\"reportIssueUrl\": \"https://github.com/voideditor/void/issues/new\"|\"reportIssueUrl\": \"https://github.com/${GH_REPO_PATH}/issues/new\"|g" product.json
fi

# Update package.json
if [ -f "package.json" ]; then
  echo "Updating package.json..."
  ${REPLACE} -i "s|\"name\": \"void\"|\"name\": \"${BINARY_NAME}\"|g" package.json
  ${REPLACE} -i "s|\"description\": \"Void\"|\"description\": \"${APP_NAME}\"|g" package.json
fi

# Apply patches from patches directory
echo ""
echo "Applying patches at ../patches/*.patch..."
if [ -d "../patches" ] && compgen -G "../patches/*.patch" > /dev/null; then
  for patch in ../patches/*.patch; do
    if [ -f "$patch" ]; then
      echo "Applying patch: $patch"
      git apply "$patch" || echo "Warning: Could not apply $patch"
    fi
  done
  echo "Patches applied"
else
  echo "No patches to apply"
fi

# Apply user-specific patches (if any)
echo ""
echo "Applying user patches..."
if [ -d "../patches/user" ] && compgen -G "../patches/user/*.patch" > /dev/null; then
  for patch in ../patches/user/*.patch; do
    if [ -f "$patch" ]; then
      echo "Applying user patch: $patch"
      git apply "$patch" || echo "Warning: Could not apply $patch"
    fi
  done
  echo "User patches applied"
else
  echo "No user patches to apply"
fi

echo ""
echo "Settings updated successfully for ${APP_NAME}!"
