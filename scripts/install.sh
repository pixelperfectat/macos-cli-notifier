#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
APP_NAME="macos-notifier"
INSTALL_DIR="/Applications"
SYMLINK_PATH="/usr/local/bin/macos-notifier"

echo "Building $APP_NAME..."

cd "$PROJECT_DIR"

# Build the app in Release mode
xcodebuild -project "$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -derivedDataPath build \
    clean build

# Find the built app
BUILD_APP="$PROJECT_DIR/build/Build/Products/Release/$APP_NAME.app"

if [ ! -d "$BUILD_APP" ]; then
    echo "Error: Built app not found at $BUILD_APP"
    exit 1
fi

echo "Installing to $INSTALL_DIR..."

# Remove existing installation if present
if [ -d "$INSTALL_DIR/$APP_NAME.app" ]; then
    echo "Removing existing installation..."
    rm -rf "$INSTALL_DIR/$APP_NAME.app"
fi

# Copy app to Applications
cp -R "$BUILD_APP" "$INSTALL_DIR/"

echo "Creating symlink at $SYMLINK_PATH..."

# Create /usr/local/bin if it doesn't exist
if [ ! -d "/usr/local/bin" ]; then
    sudo mkdir -p /usr/local/bin
fi

# Remove existing symlink if present
if [ -L "$SYMLINK_PATH" ] || [ -e "$SYMLINK_PATH" ]; then
    sudo rm -f "$SYMLINK_PATH"
fi

# Create symlink
sudo ln -s "$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME" "$SYMLINK_PATH"

echo ""
echo "Installation complete!"
echo ""
echo "Usage:"
echo "  macos-notifier --title \"Title\" --content \"Body\""
echo "  macos-notifier --title \"Title\" --content \"Body\" --image /path/to/image.png"
echo "  macos-notifier --title \"Title\" --content \"Body\" --activate com.app.bundleid"
echo ""
echo "Note: On first run, macOS will ask for notification permissions."
echo "For persistent notifications, set notification style to Alerts in System Settings."
