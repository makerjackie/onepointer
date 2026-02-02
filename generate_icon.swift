#!/usr/bin/env swift

import AppKit
import Foundation

func generateIcon(size: Int) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))

    image.lockFocus()

    let rect = NSRect(x: 0, y: 0, width: size, height: size)
    let cornerRadius = CGFloat(size) * 0.22
    let bgPath = NSBezierPath(roundedRect: rect, xRadius: cornerRadius, yRadius: cornerRadius)

    // Gradient background
    let gradient = NSGradient(colors: [
        NSColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),
        NSColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0)
    ])
    gradient?.draw(in: bgPath, angle: -45)

    let center = CGFloat(size) / 2

    // Outer ring (glow)
    let glowRadius = CGFloat(size) * 0.32
    for i in stride(from: 4, through: 1, by: -1) {
        let glowPath = NSBezierPath(ovalIn: NSRect(
            x: center - glowRadius - CGFloat(i) * 2,
            y: center - glowRadius - CGFloat(i) * 2,
            width: (glowRadius + CGFloat(i) * 2) * 2,
            height: (glowRadius + CGFloat(i) * 2) * 2
        ))
        NSColor.white.withAlphaComponent(0.1).setStroke()
        glowPath.lineWidth = 2
        glowPath.stroke()
    }

    // Main ring
    let ringRadius = CGFloat(size) * 0.3
    let ringPath = NSBezierPath(ovalIn: NSRect(
        x: center - ringRadius,
        y: center - ringRadius,
        width: ringRadius * 2,
        height: ringRadius * 2
    ))
    NSColor.white.setStroke()
    ringPath.lineWidth = CGFloat(size) * 0.06
    ringPath.stroke()

    // Inner yellow circle (cursor representation)
    let innerRadius = CGFloat(size) * 0.12
    let innerPath = NSBezierPath(ovalIn: NSRect(
        x: center - innerRadius,
        y: center - innerRadius,
        width: innerRadius * 2,
        height: innerRadius * 2
    ))
    NSColor.systemYellow.setFill()
    innerPath.fill()

    // Highlight dot on inner circle
    let dotRadius = CGFloat(size) * 0.04
    let dotPath = NSBezierPath(ovalIn: NSRect(
        x: center - dotRadius - innerRadius * 0.3,
        y: center - dotRadius + innerRadius * 0.3,
        width: dotRadius * 2,
        height: dotRadius * 2
    ))
    NSColor.white.withAlphaComponent(0.6).setFill()
    dotPath.fill()

    // Click ripple effect (small arcs)
    let rippleRadius = CGFloat(size) * 0.42
    let ripplePath = NSBezierPath()
    ripplePath.appendArc(
        withCenter: NSPoint(x: center, y: center),
        radius: rippleRadius,
        startAngle: 30,
        endAngle: 60
    )
    NSColor.white.withAlphaComponent(0.5).setStroke()
    ripplePath.lineWidth = CGFloat(size) * 0.02
    ripplePath.stroke()

    let ripplePath2 = NSBezierPath()
    ripplePath2.appendArc(
        withCenter: NSPoint(x: center, y: center),
        radius: rippleRadius,
        startAngle: 210,
        endAngle: 240
    )
    ripplePath2.stroke()

    image.unlockFocus()

    return image
}

func saveIcon(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiffData),
          let pngData = bitmap.representation(using: .png, properties: [:]) else {
        print("Failed to create PNG data")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("Saved: \(path)")
    } catch {
        print("Error saving \(path): \(error)")
    }
}

let outputDir = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "."

let sizes = [
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

for (filename, size) in sizes {
    let icon = generateIcon(size: size)
    let path = "\(outputDir)/\(filename)"
    saveIcon(icon, to: path)
}

print("\nDone! Move the generated icons to Assets.xcassets/AppIcon.appiconset/")
