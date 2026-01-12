#!/usr/bin/env swift

import AppKit
import Foundation

let sizes: [(name: String, size: Int)] = [
    ("16x16", 16),
    ("16x16@2x", 32),
    ("32x32", 32),
    ("32x32@2x", 64),
    ("128x128", 128),
    ("128x128@2x", 256),
    ("256x256", 256),
    ("256x256@2x", 512),
    ("512x512", 512),
    ("512x512@2x", 1024)
]

func drawTerminalIcon(in context: CGContext, size: CGFloat, darkMode: Bool) {
    let rect = CGRect(x: 0, y: 0, width: size, height: size)

    // Background colors - dark slate for light mode, lighter for dark mode
    let bgColorTop: NSColor
    let bgColorBottom: NSColor

    if darkMode {
        // Lighter background for dark mode
        bgColorTop = NSColor(red: 0.35, green: 0.37, blue: 0.42, alpha: 1.0)
        bgColorBottom = NSColor(red: 0.28, green: 0.30, blue: 0.35, alpha: 1.0)
    } else {
        // Dark slate background for light mode
        bgColorTop = NSColor(red: 0.22, green: 0.24, blue: 0.29, alpha: 1.0)
        bgColorBottom = NSColor(red: 0.15, green: 0.17, blue: 0.21, alpha: 1.0)
    }

    // Draw rounded rectangle background with gradient
    let cornerRadius = size * 0.22
    let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Create gradient
    let gradient = NSGradient(starting: bgColorTop, ending: bgColorBottom)!
    gradient.draw(in: bgPath, angle: -90)

    // Subtle inner shadow/highlight at top
    context.saveGState()
    let highlightRect = CGRect(x: size * 0.1, y: size * 0.75, width: size * 0.8, height: size * 0.15)
    let highlightColor = NSColor(white: 1.0, alpha: 0.03)
    highlightColor.setFill()
    let highlightPath = NSBezierPath(roundedRect: highlightRect, xRadius: size * 0.05, yRadius: size * 0.05)
    highlightPath.fill()
    context.restoreGState()

    // White color for terminal elements
    let elementColor = NSColor.white

    // Draw chevron ">"
    let chevronPath = NSBezierPath()
    let chevronX = size * 0.22
    let chevronTopY = size * 0.62
    let chevronMidY = size * 0.45
    let chevronBottomY = size * 0.28
    let chevronWidth = size * 0.22
    let strokeWidth = size * 0.08

    chevronPath.move(to: NSPoint(x: chevronX, y: chevronTopY))
    chevronPath.line(to: NSPoint(x: chevronX + chevronWidth, y: chevronMidY))
    chevronPath.line(to: NSPoint(x: chevronX, y: chevronBottomY))

    elementColor.setStroke()
    chevronPath.lineWidth = strokeWidth
    chevronPath.lineCapStyle = .round
    chevronPath.lineJoinStyle = .round
    chevronPath.stroke()

    // Draw underscore cursor "_"
    let underscoreY = size * 0.25
    let underscoreX = size * 0.52
    let underscoreWidth = size * 0.22

    let underscorePath = NSBezierPath()
    underscorePath.move(to: NSPoint(x: underscoreX, y: underscoreY))
    underscorePath.line(to: NSPoint(x: underscoreX + underscoreWidth, y: underscoreY))

    underscorePath.lineWidth = strokeWidth
    underscorePath.lineCapStyle = .round
    underscorePath.stroke()

    // Draw orange notification dot with gradient
    let dotRadius = size * 0.1
    let dotCenterX = size * 0.8
    let dotCenterY = size * 0.8
    let dotRect = CGRect(
        x: dotCenterX - dotRadius,
        y: dotCenterY - dotRadius,
        width: dotRadius * 2,
        height: dotRadius * 2
    )

    // Orange gradient for the dot (top: lighter orange, bottom: red-orange)
    let dotPath = NSBezierPath(ovalIn: dotRect)
    let orangeTop = NSColor(red: 1.0, green: 0.55, blue: 0.25, alpha: 1.0)
    let orangeBottom = NSColor(red: 0.95, green: 0.35, blue: 0.2, alpha: 1.0)
    let dotGradient = NSGradient(starting: orangeTop, ending: orangeBottom)!
    dotGradient.draw(in: dotPath, angle: -90)

    // Subtle highlight on dot
    let dotHighlightRect = CGRect(
        x: dotCenterX - dotRadius * 0.5,
        y: dotCenterY,
        width: dotRadius,
        height: dotRadius * 0.6
    )
    let dotHighlight = NSColor(white: 1.0, alpha: 0.3)
    dotHighlight.setFill()
    let dotHighlightPath = NSBezierPath(ovalIn: dotHighlightRect)
    dotHighlightPath.fill()
}

func createIcon(pixelSize: Int, darkMode: Bool) -> Data? {
    // Create bitmap with exact pixel dimensions (1x scale)
    guard let bitmap = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixelSize,
        pixelsHigh: pixelSize,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        return nil
    }

    // Set size to match pixels (72 DPI, 1x scale)
    bitmap.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: bitmap) else {
        NSGraphicsContext.restoreGraphicsState()
        return nil
    }
    NSGraphicsContext.current = context

    // Clear to transparent
    context.cgContext.clear(CGRect(x: 0, y: 0, width: pixelSize, height: pixelSize))

    // Draw the icon
    drawTerminalIcon(in: context.cgContext, size: CGFloat(pixelSize), darkMode: darkMode)

    NSGraphicsContext.restoreGraphicsState()

    return bitmap.representation(using: .png, properties: [:])
}

func savePNG(_ data: Data, to path: String) {
    do {
        try data.write(to: URL(fileURLWithPath: path))
        print("Created: \(path)")
    } catch {
        print("Failed to write \(path): \(error)")
    }
}

// Get script directory
let scriptPath = CommandLine.arguments[0]
let scriptDir = (scriptPath as NSString).deletingLastPathComponent
let projectDir = (scriptDir as NSString).deletingLastPathComponent
let iconsetPath = "\(projectDir)/macos-notifier/Assets.xcassets/AppIcon.appiconset"

print("Generating terminal-style icons in: \(iconsetPath)")

// Generate light mode icons (dark background)
for (name, size) in sizes {
    if let pngData = createIcon(pixelSize: size, darkMode: false) {
        let filename = "icon_\(name).png"
        savePNG(pngData, to: "\(iconsetPath)/\(filename)")
    }
}

// Generate dark mode icons (slightly lighter background)
for (name, size) in sizes {
    if let pngData = createIcon(pixelSize: size, darkMode: true) {
        let filename = "icon_\(name)_dark.png"
        savePNG(pngData, to: "\(iconsetPath)/\(filename)")
    }
}

print("\nDone! All icons generated.")
