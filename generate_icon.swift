#!/usr/bin/env swift

import AppKit

func generateIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    let context = NSGraphicsContext.current!
    context.imageInterpolation = .high

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let scale = CGFloat(size) / 512.0

    // Background - rounded square with gradient
    let bgPath = NSBezierPath(roundedRect: rect.insetBy(dx: CGFloat(size) * 0.05, dy: CGFloat(size) * 0.05),
                               xRadius: CGFloat(size) * 0.2,
                               yRadius: CGFloat(size) * 0.2)

    // Gradient background (dark blue to lighter blue)
    let gradient = NSGradient(colors: [
        NSColor(red: 0.1, green: 0.1, blue: 0.2, alpha: 1.0),
        NSColor(red: 0.15, green: 0.15, blue: 0.3, alpha: 1.0)
    ])!
    gradient.draw(in: bgPath, angle: -90)

    // Subtle border
    NSColor(white: 0.3, alpha: 0.5).setStroke()
    bgPath.lineWidth = CGFloat(size) * 0.01
    bgPath.stroke()

    // Horizontal bar dimensions (stacked like menu bar)
    let barHeight = CGFloat(size) * 0.12
    let barSpacing = CGFloat(size) * 0.06
    let maxBarWidth = CGFloat(size) * 0.6
    let barLeft = CGFloat(size) * 0.2
    let cornerRadius = CGFloat(size) * 0.03

    // Green gradient for bars
    let greenGradient = NSGradient(colors: [
        NSColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 1.0),
        NSColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
    ])!

    // Top bar (session - 65% width, green)
    let topBarWidth = maxBarWidth * 0.65
    let topBarY = CGFloat(size) / 2 + barSpacing / 2
    let topBarRect = NSRect(x: barLeft, y: topBarY, width: topBarWidth, height: barHeight)
    let topBarPath = NSBezierPath(roundedRect: topBarRect, xRadius: cornerRadius, yRadius: cornerRadius)
    greenGradient.draw(in: topBarPath, angle: 0)

    // Bottom bar (weekly - 45% width, also green)
    let bottomBarWidth = maxBarWidth * 0.45
    let bottomBarY = CGFloat(size) / 2 - barHeight - barSpacing / 2
    let bottomBarRect = NSRect(x: barLeft, y: bottomBarY, width: bottomBarWidth, height: barHeight)
    let bottomBarPath = NSBezierPath(roundedRect: bottomBarRect, xRadius: cornerRadius, yRadius: cornerRadius)
    greenGradient.draw(in: bottomBarPath, angle: 0)

    // Draw bar backgrounds (unfilled portion)
    let topBgRect = NSRect(x: barLeft, y: topBarY, width: maxBarWidth, height: barHeight)
    let bottomBgRect = NSRect(x: barLeft, y: bottomBarY, width: maxBarWidth, height: barHeight)

    NSColor(white: 0.3, alpha: 0.4).setStroke()
    let topBgPath = NSBezierPath(roundedRect: topBgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    let bottomBgPath = NSBezierPath(roundedRect: bottomBgRect, xRadius: cornerRadius, yRadius: cornerRadius)
    topBgPath.lineWidth = 1
    bottomBgPath.lineWidth = 1
    topBgPath.stroke()
    bottomBgPath.stroke()

    image.unlockFocus()

    return image
}

func saveIcon(image: NSImage, filename: String, pixelSize: Int) {
    // Create bitmap with exact pixel dimensions
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
        print("Failed to create bitmap for \(filename)")
        return
    }

    bitmap.size = NSSize(width: pixelSize, height: pixelSize)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: bitmap)

    // Draw the image scaled to the bitmap
    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize),
               from: NSRect(origin: .zero, size: image.size),
               operation: .copy,
               fraction: 1.0)

    NSGraphicsContext.restoreGraphicsState()

    guard let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data for \(filename)")
        return
    }

    let url = URL(fileURLWithPath: filename)
    do {
        try pngData.write(to: url)
        print("Created: \(filename) (\(pixelSize)x\(pixelSize))")
    } catch {
        print("Failed to write \(filename): \(error)")
    }
}

let basePath = "/Users/stuartcameron/Documents/GitHub/Clive/ClaudeUsageBar/ClaudeUsageBar/Assets.xcassets/AppIcon.appiconset"

let sizes: [(name: String, size: Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

// Note: The NSImage size property represents the "point size", not pixel size.
// For @2x images, we need to set the size to half the pixel dimensions.

for (name, size) in sizes {
    let image = generateIcon(size: 512)  // Generate at high res
    saveIcon(image: image, filename: "\(basePath)/\(name)", pixelSize: size)
}

print("Icon generation complete!")
