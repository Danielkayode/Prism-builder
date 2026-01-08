#!/usr/bin/env bash
# shellcheck disable=SC2129

set -e

# Echo all environment variables used by this script
echo "----------- get_repo -----------"
echo "Environment variables:"
echo "CI_BUILD=${CI_BUILD}"
echo "GITHUB_REPOSITORY=${GITHUB_REPOSITORY}"
echo "RELEASE_VERSION=${RELEASE_VERSION}"
echo "VSCODE_LATEST=${VSCODE_LATEST}"
echo "VSCODE_QUALITY=${VSCODE_QUALITY}"
echo "GITHUB_ENV=${GITHUB_ENV}"

echo "SHOULD_DEPLOY=${SHOULD_DEPLOY}"
echo "SHOULD_BUILD=${SHOULD_BUILD}"
echo "-------------------------"

# git workaround
if [[ "${CI_BUILD}" != "no" ]]; then
  git config --global --add safe.directory "/__w/$( echo "${GITHUB_REPOSITORY}" | awk '{print tolower($0)}' )"
fi

PRISM_BRANCH="main"
echo "Cloning Prism ${PRISM_BRANCH}..."

mkdir -p vscode
cd vscode || { echo "'vscode' dir not found"; exit 1; }

git init -q
git remote add origin https://github.com/Danielkayode/prism-Editor.git

# Allow callers to specify a particular commit to checkout via the
# environment variable PRISM_COMMIT. We still default to the tip of the
# ${PRISM_BRANCH} branch when the variable is not provided. Keeping
# PRISM_BRANCH as "main" ensures the rest of the script (and downstream
# consumers) behave exactly as before.
if [[ -n "${PRISM_COMMIT}" ]]; then
  echo "Using explicit commit ${PRISM_COMMIT}"
  # Fetch just that commit to keep the clone shallow.
  git fetch --depth 1 origin "${PRISM_COMMIT}"
  git checkout "${PRISM_COMMIT}"
else
  git fetch --depth 1 origin "${PRISM_BRANCH}"
  git checkout FETCH_HEAD
fi

MS_TAG=$( jq -r '.version' "package.json" )
MS_COMMIT=$PRISM_BRANCH 

# Prism - Attempt to get prismVersion, fallback to null/empty if missing
PRISM_VERSION=$( jq -r '.prismVersion // empty' "product.json" )

# Fallback handling if not in product.json yet
if [[ -z "${PRISM_VERSION}" ]]; then
  echo "Prism version not found in product.json, using default fallback."
  PRISM_VERSION="0.0.1"
fi

if [[ -n "${PRISM_RELEASE}" ]]; then 
  RELEASE_VERSION="${MS_TAG}${PRISM_RELEASE}"
else
  # Prism - Attempt to get prismRelease, fallback
  PRISM_RELEASE=$( jq -r '.prismRelease // empty' "product.json" )
  
  if [[ -z "${PRISM_RELEASE}" ]]; then
     echo "Prism release not found in product.json, using default fallback."
     PRISM_RELEASE=""
  fi
  
  RELEASE_VERSION="${MS_TAG}${PRISM_RELEASE}"
fi

echo "RELEASE_VERSION=\"${RELEASE_VERSION}\""
echo "MS_COMMIT=\"${MS_COMMIT}\""
echo "MS_TAG=\"${MS_TAG}\""

cd ..

# for GH actions
if [[ "${GITHUB_ENV}" ]]; then
  echo "MS_TAG=${MS_TAG}" >> "${GITHUB_ENV}"
  echo "MS_COMMIT=${MS_COMMIT}" >> "${GITHUB_ENV}"
  echo "RELEASE_VERSION=${RELEASE_VERSION}" >> "${GITHUB_ENV}"
  echo "PRISM_VERSION=${PRISM_VERSION}" >> "${GITHUB_ENV}"
fi

echo "----------- get_repo exports -----------"
echo "MS_TAG ${MS_TAG}"
echo "MS_COMMIT ${MS_COMMIT}"
echo "RELEASE_VERSION ${RELEASE_VERSION}"
echo "PRISM VERSION ${PRISM_VERSION}"
echo "----------------------"


export MS_TAG
export MS_COMMIT
export RELEASE_VERSION
export PRISM_VERSION
