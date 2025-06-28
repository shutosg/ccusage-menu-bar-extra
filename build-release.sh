#!/bin/bash

# Build Release Script for CCUsage Menu Bar
set -e

echo "🔨 Building CCUsage Menu Bar for Release..."

# Clean build directory
rm -rf CCUsageMenuBar/.build/release
rm -rf CCUsageMenuBar/release

# Change to project directory
cd CCUsageMenuBar

# Build for release
echo "📦 Building release binary..."
swift build -c release --arch arm64 --arch x86_64

# Create release directory
mkdir -p ./release

# Create app bundle structure
APP_NAME="ccusage Menu Bar.app"
APP_PATH="./release/$APP_NAME"
mkdir -p "$APP_PATH/Contents/MacOS"
mkdir -p "$APP_PATH/Contents/Resources"

# Copy executable
cp .build/apple/Products/Release/CCUsageMenuBar "$APP_PATH/Contents/MacOS/"

# Copy Info.plist
cp CCUsageMenuBar/Info.plist "$APP_PATH/Contents/"

# Create a simple icon if it doesn't exist
if [ ! -f "$APP_PATH/Contents/Resources/AppIcon.icns" ]; then
    echo "⚠️  Note: AppIcon.icns not found. The app will use default icon."
fi

# Sign the app (if certificate is available)
if security find-identity -p codesigning | grep -q "Developer ID Application"; then
    echo "🔏 Signing the app..."
    codesign --force --deep --sign "Developer ID Application" "$APP_PATH"
else
    echo "⚠️  No Developer ID certificate found. The app will not be signed."
fi

# Create DMG
echo "💿 Creating DMG..."
DMG_NAME="ccusageMenuBar-1.0.0.dmg"
DMG_PATH="./release/$DMG_NAME"

# Create a temporary directory for DMG contents
DMG_TEMP="./release/dmg-temp"
mkdir -p "$DMG_TEMP"
cp -R "$APP_PATH" "$DMG_TEMP/"

# Create Applications shortcut
ln -s /Applications "$DMG_TEMP/Applications"

# Create DMG
hdiutil create -volname "ccusage Menu Bar" -srcfolder "$DMG_TEMP" -ov -format UDZO "$DMG_PATH"

# Clean up temporary directory
rm -rf "$DMG_TEMP"

# Create ZIP as an alternative
echo "🗜️  Creating ZIP archive..."
cd ./release
zip -r "ccusageMenuBar-1.0.0.zip" "$APP_NAME"
cd ..

echo "✅ Build complete!"
echo ""
echo "📁 Release files created in ./CCUsageMenuBar/release/"
echo "   - $APP_NAME (Application bundle)"
echo "   - $DMG_NAME (Disk image for distribution)"
echo "   - ccusageMenuBar-1.0.0.zip (ZIP archive)"
echo ""
echo "📝 Next steps:"
echo "   1. Test the app from the release folder"
echo "   2. If you have a Developer ID, notarize the app for distribution"
echo "   3. Upload the DMG or ZIP to your distribution platform"