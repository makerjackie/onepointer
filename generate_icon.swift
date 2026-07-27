#!/usr/bin/env swift

import AppKit
import Foundation

private struct IconSize {
    let filename: String
    let pixels: Int
}

private let sizes = [
    IconSize(filename: "icon_16x16.png", pixels: 16),
    IconSize(filename: "icon_16x16@2x.png", pixels: 32),
    IconSize(filename: "icon_32x32.png", pixels: 32),
    IconSize(filename: "icon_32x32@2x.png", pixels: 64),
    IconSize(filename: "icon_128x128.png", pixels: 128),
    IconSize(filename: "icon_128x128@2x.png", pixels: 256),
    IconSize(filename: "icon_256x256.png", pixels: 256),
    IconSize(filename: "icon_256x256@2x.png", pixels: 512),
    IconSize(filename: "icon_512x512.png", pixels: 512),
    IconSize(filename: "icon_512x512@2x.png", pixels: 1024),
]

private func resizedPNG(from source: NSImage, pixels: Int) throws -> Data {
    guard let representation = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: pixels,
        pixelsHigh: pixels,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    ) else {
        throw CocoaError(.fileWriteUnknown)
    }

    representation.size = NSSize(width: pixels, height: pixels)

    NSGraphicsContext.saveGraphicsState()
    guard let context = NSGraphicsContext(bitmapImageRep: representation) else {
        NSGraphicsContext.restoreGraphicsState()
        throw CocoaError(.fileWriteUnknown)
    }
    NSGraphicsContext.current = context
    context.imageInterpolation = .high
    source.draw(
        in: NSRect(x: 0, y: 0, width: pixels, height: pixels),
        from: NSRect(origin: .zero, size: source.size),
        operation: .copy,
        fraction: 1
    )
    context.flushGraphics()
    NSGraphicsContext.restoreGraphicsState()

    guard let data = representation.representation(using: .png, properties: [:]) else {
        throw CocoaError(.fileWriteUnknown)
    }
    return data
}

private let masterPath =
    CommandLine.arguments.count > 1
        ? CommandLine.arguments[1]
        : "Assets/OnePointer-AppIcon-master.png"
private let outputDirectory =
    CommandLine.arguments.count > 2
        ? CommandLine.arguments[2]
        : "Sources/Resources/Assets.xcassets/AppIcon.appiconset"

guard let master = NSImage(contentsOfFile: masterPath) else {
    fatalError("Unable to read app icon master at \(masterPath)")
}

for size in sizes {
    let outputURL = URL(fileURLWithPath: outputDirectory)
        .appending(path: size.filename)

    do {
        let data = try resizedPNG(from: master, pixels: size.pixels)
        try data.write(to: outputURL)
        print("Saved \(outputURL.path)")
    } catch {
        fatalError("Unable to write \(outputURL.path): \(error.localizedDescription)")
    }
}
