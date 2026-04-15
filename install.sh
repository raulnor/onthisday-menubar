#!/bin/bash

set -e

echo "Building OnThisDay..."
swift build -c release

echo "Creating app bundle..."
APP_NAME="OnThisDay"
BUNDLE_DIR="$HOME/Applications/$APP_NAME.app"
CONTENTS_DIR="$BUNDLE_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

# Create bundle structure
mkdir -p "$MACOS_DIR"
mkdir -p "$RESOURCES_DIR"

# Copy executable
cp .build/release/OnThisDay "$MACOS_DIR/"

# Create Info.plist
cat > "$CONTENTS_DIR/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>OnThisDay</string>
    <key>CFBundleIdentifier</key>
    <string>com.onthisday</string>
    <key>CFBundleName</key>
    <string>OnThisDay</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>LSUIElement</key>
    <true/>
    <key>CFBundleURLTypes</key>
    <array>
        <dict>
            <key>CFBundleURLName</key>
            <string>On This Day URL</string>
            <key>CFBundleURLSchemes</key>
            <array>
                <string>onthisday</string>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF

echo "✅ App installed to: $BUNDLE_DIR"
echo ""
echo "To add to Login Items:"
echo "  System Settings → General → Login Items → Add '$APP_NAME'"
echo ""
echo "Or run now with:"
echo "  open \"$BUNDLE_DIR\""
