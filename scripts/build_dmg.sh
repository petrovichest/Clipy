#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA_PATH="${ROOT_DIR}/build/DerivedData"
APP_PRODUCTS_PATH="${DERIVED_DATA_PATH}/Build/Products/Release"
APP_PATH="${APP_PRODUCTS_PATH}/Clipy.app"
DMG_STAGING="${ROOT_DIR}/build/dmg/Clipy"
DMG_OUTPUT="${ROOT_DIR}/build/Clipy.dmg"

rm -rf "${DERIVED_DATA_PATH}" "${DMG_STAGING}" "${DMG_OUTPUT}"
mkdir -p "${DMG_STAGING}"

xcodebuild \
  -workspace "${ROOT_DIR}/Clipy.xcworkspace" \
  -scheme "Clipy" \
  -configuration "Release" \
  -derivedDataPath "${DERIVED_DATA_PATH}" \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  clean build

if [ ! -d "${APP_PATH}" ]; then
  echo "Release build not found at ${APP_PATH}" >&2
  exit 1
fi

cp -R "${APP_PATH}" "${DMG_STAGING}/"
ln -sfn /Applications "${DMG_STAGING}/Applications"

hdiutil create \
  -volname "Clipy" \
  -srcfolder "${DMG_STAGING}" \
  -ov \
  -format UDZO \
  "${DMG_OUTPUT}"

echo "DMG created at ${DMG_OUTPUT}"
