import SwiftUI
import Cocoa

struct HighlightPreviewView: View {
    @ObservedObject var settings: SettingsManager
    @State private var isHovering = false

    var body: some View {
        GroupBox(label: Text("Preview").font(.headline)) {
            PreviewCanvas(settings: settings)
                .frame(height: 120)
                .background(Color(NSColor.windowBackgroundColor).opacity(0.5))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
    }
}

struct PreviewCanvas: NSViewRepresentable {
    @ObservedObject var settings: SettingsManager

    func makeNSView(context: Context) -> PreviewNSView {
        let view = PreviewNSView()
        view.settings = settings
        return view
    }

    func updateNSView(_ nsView: PreviewNSView, context: Context) {
        nsView.settings = settings
        nsView.needsDisplay = true
    }
}

class PreviewNSView: NSView {
    var settings: SettingsManager?

    private var circleHighlight = CircleHighlight()
    private var spotlightHighlight = SpotlightHighlight()
    private var ringHighlight = RingHighlight()
    private var crosshairHighlight = CrosshairHighlight()
    private var pulseHighlight = PulseHighlight()

    private var displayLink: CVDisplayLink?
    private var pulsePhase: CGFloat = 0
    private var lastUpdateTime: TimeInterval = CACurrentMediaTime()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        startDisplayLink()
    }

    private func startDisplayLink() {
        var link: CVDisplayLink?
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let displayLink = link else { return }

        self.displayLink = displayLink

        let callback: CVDisplayLinkOutputCallback = { (displayLink, inNow, inOutputTime, flagsIn, flagsOut, displayLinkContext) -> CVReturn in
            guard let context = displayLinkContext else { return kCVReturnSuccess }
            let view = Unmanaged<PreviewNSView>.fromOpaque(context).takeUnretainedValue()
            DispatchQueue.main.async {
                if view.settings?.highlightStyle == .pulse {
                    view.needsDisplay = true
                }
            }
            return kCVReturnSuccess
        }

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        CVDisplayLinkSetOutputCallback(displayLink, callback, refcon)
        CVDisplayLinkStart(displayLink)
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext,
              let settings = settings else { return }

        // Draw background
        context.setFillColor(NSColor.windowBackgroundColor.withAlphaComponent(0.3).cgColor)
        context.fill(bounds)

        // Draw grid pattern for visual reference
        drawGrid(in: context)

        // Calculate center point for preview
        let centerPoint = NSPoint(x: bounds.midX, y: bounds.midY)

        // Draw the highlight based on current style
        switch settings.highlightStyle {
        case .circle:
            circleHighlight.draw(
                in: context,
                at: centerPoint,
                size: min(settings.highlightSize, bounds.height - 20),
                color: settings.highlightColor,
                opacity: settings.highlightOpacity
            )

        case .spotlight:
            spotlightHighlight.draw(
                in: context,
                at: centerPoint,
                size: min(settings.highlightSize, bounds.height - 20),
                bounds: bounds,
                dimOpacity: settings.spotlightDimOpacity
            )

        case .ring:
            ringHighlight.draw(
                in: context,
                at: centerPoint,
                size: min(settings.highlightSize, bounds.height - 20),
                color: settings.highlightColor,
                opacity: settings.highlightOpacity,
                thickness: settings.ringThickness,
                glowIntensity: settings.ringGlowIntensity
            )

        case .crosshair:
            crosshairHighlight.draw(
                in: context,
                at: centerPoint,
                length: min(settings.crosshairLength, bounds.height - 20),
                thickness: settings.crosshairThickness,
                color: settings.highlightColor,
                opacity: settings.highlightOpacity,
                style: settings.crosshairStyle
            )

        case .pulse:
            pulseHighlight.draw(
                in: context,
                at: centerPoint,
                baseSize: min(settings.highlightSize, bounds.height - 20),
                color: settings.highlightColor,
                opacity: settings.highlightOpacity,
                speed: settings.pulseSpeed,
                intensity: settings.pulseIntensity
            )
        }

        // Draw cursor indicator
        drawCursorIndicator(in: context, at: centerPoint)
    }

    private func drawGrid(in context: CGContext) {
        context.saveGState()

        let gridColor = NSColor.gray.withAlphaComponent(0.1).cgColor
        context.setStrokeColor(gridColor)
        context.setLineWidth(0.5)

        let spacing: CGFloat = 20

        // Vertical lines
        var x = spacing
        while x < bounds.width {
            context.move(to: CGPoint(x: x, y: 0))
            context.addLine(to: CGPoint(x: x, y: bounds.height))
            x += spacing
        }

        // Horizontal lines
        var y = spacing
        while y < bounds.height {
            context.move(to: CGPoint(x: 0, y: y))
            context.addLine(to: CGPoint(x: bounds.width, y: y))
            y += spacing
        }

        context.strokePath()
        context.restoreGState()
    }

    private func drawCursorIndicator(in context: CGContext, at point: NSPoint) {
        context.saveGState()

        // Draw small cursor-like indicator
        let cursorSize: CGFloat = 4
        context.setFillColor(NSColor.white.cgColor)
        context.fillEllipse(in: CGRect(
            x: point.x - cursorSize / 2,
            y: point.y - cursorSize / 2,
            width: cursorSize,
            height: cursorSize
        ))

        context.setStrokeColor(NSColor.black.cgColor)
        context.setLineWidth(0.5)
        context.strokeEllipse(in: CGRect(
            x: point.x - cursorSize / 2,
            y: point.y - cursorSize / 2,
            width: cursorSize,
            height: cursorSize
        ))

        context.restoreGState()
    }

    deinit {
        if let link = displayLink {
            CVDisplayLinkStop(link)
        }
    }
}
