# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

macOS Notifier is a Swift command-line tool that displays native macOS notifications. It accepts `--title`, `--content`, optional `--image`, and optional `--activate` parameters. The `--activate` option keeps the notification visible until clicked, then activates the specified app.

## Build Commands

```bash
# Build in Xcode
# Open macos-notifier.xcodeproj and press Cmd+B

# Build from command line
xcodebuild -project macos-notifier.xcodeproj -scheme macos-notifier -configuration Release

# Build and install globally
./scripts/install.sh
```

## Running

```bash
# Basic notification (auto-dismisses)
macos-notifier --title "Title" --content "Body"

# With image attachment
macos-notifier --title "Title" --content "Body" --image /path/to/image.png

# Persistent notification that activates an app when clicked
macos-notifier --title "Claude Code" --content "Permission needed" --activate com.jetbrains.pycharm

# Full example for Claude Code hooks
macos-notifier --title "Claude Code" --content "Permission needed" \
  --image /Applications/Claude.app/Contents/Resources/TrayIconTemplate-Dark@3x.png \
  --activate com.jetbrains.pycharm
```

Common bundle identifiers:
- PyCharm: `com.jetbrains.pycharm`
- PhpStorm: `com.jetbrains.PhpStorm`
- VS Code: `com.microsoft.VSCode`
- Terminal: `com.apple.Terminal`
- iTerm: `com.googlecode.iterm2`

## Architecture

- **main.swift** - Entry point using ArgumentParser for CLI argument parsing. Initializes NSApplication with AppDelegate.
- **AppDelegate.swift** - NSApplicationDelegate that triggers notification on launch and terminates after delivery.
- **NotificationManager.swift** - Handles UNUserNotificationCenter authorization, content creation, and attachment handling. Implements UNUserNotificationCenterDelegate.

## Key Implementation Details

- Uses `UserNotifications` framework (not deprecated NSUserNotification)
- App bundle required for notifications to work with custom icons
- `LSUIElement = true` in Info.plist keeps app out of Dock while running
- `NSUserNotificationAlertStyle = alert` requests persistent notifications (user can override in System Settings)
- Image attachments are copied to temp directory before attaching (UNNotificationAttachment requirement)
- Without `--activate`: App terminates 0.5s after notification delivery
- With `--activate`: App waits for notification click, then activates specified app via `NSWorkspace.shared.launchApplication(withBundleIdentifier:)`

## System Settings Requirement

For notifications to remain visible until clicked, the user must set the notification style to **Alerts** (not Banners) in:
**System Settings → Notifications → macos-notifier**

## Icon Generation

```bash
# Regenerate placeholder bell icons (light/dark variants)
./scripts/generate-icons.swift
```

Icons are stored in `macos-notifier/Assets.xcassets/AppIcon.appiconset/` with `Contents.json` configured for theme-aware switching via `luminosity` appearance.

## Git Workflow

When committing changes, use the `/commit` skill instead of running git commands directly.

## Plans

When working on complex tasks, save plans to `.claude/plans/` as markdown files.
