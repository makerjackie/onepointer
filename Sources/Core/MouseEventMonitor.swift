import Cocoa

protocol MouseEventDelegate: AnyObject {
    func mouseMoved(to point: NSPoint)
    func mouseDown(at point: NSPoint, button: MouseButton)
    func mouseUp(at point: NSPoint, button: MouseButton)
    func mouseDragged(to point: NSPoint, button: MouseButton)
}

enum MouseButton {
    case left
    case right
    case other
}

/// Tracks the global cursor position and mouse-button state WITHOUT any special
/// permissions.
///
/// Earlier this used a `CGEventTap`, which since macOS 10.15 requires the Input
/// Monitoring (TCC `ListenEvent`) permission. That permission is bound to a stable
/// code signature, so a locally/ad-hoc-signed build can never reliably hold the grant.
/// Since the highlighter only ever *observes* the cursor (it never intercepts events or
/// reads the keyboard), we instead poll `NSEvent.mouseLocation` and
/// `NSEvent.pressedMouseButtons` on a timer — both are permission-free reads. This also
/// removes the brittle coordinate conversion: `NSEvent.mouseLocation` is already in Cocoa
/// global coordinates (bottom-left origin) spanning all displays.
final class MouseEventMonitor {
    weak var delegate: MouseEventDelegate?

    private var timer: Timer?
    private var isRunning = false

    private var lastLocation: NSPoint = NSEvent.mouseLocation
    private var lastButtonMask: Int = 0

    private var pollInterval: TimeInterval {
        // SettingsManager exposes a target frame rate (e.g. 60 or 120). Poll at that rate.
        let fps = max(30, SettingsManager.shared.targetFrameRate)
        return 1.0 / Double(fps)
    }

    @discardableResult
    func start() -> Bool {
        guard !isRunning else { return true }

        lastLocation = NSEvent.mouseLocation
        lastButtonMask = NSEvent.pressedMouseButtons

        let timer = Timer(timeInterval: pollInterval, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.poll()
            }
        }
        // .common modes so polling continues during menu tracking / window resize.
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
        isRunning = true
        delegate?.mouseMoved(to: lastLocation)
        return true
    }

    func stop() {
        guard isRunning else { return }
        timer?.invalidate()
        timer = nil
        isRunning = false
    }

    private func poll() {
        let location = NSEvent.mouseLocation
        let buttonMask = NSEvent.pressedMouseButtons

        // Button transitions (diff against previous mask).
        if buttonMask != lastButtonMask {
            for change in Geometry.buttonTransitions(old: lastButtonMask, new: buttonMask) {
                let button = self.button(for: change.index)
                if change.isDown {
                    delegate?.mouseDown(at: location, button: button)
                } else {
                    delegate?.mouseUp(at: location, button: button)
                }
            }
            lastButtonMask = buttonMask
        }

        // Position changes.
        if location != lastLocation {
            lastLocation = location
            if let heldIndex = Geometry.lowestHeldButton(in: buttonMask) {
                // A button is held → this is a drag.
                delegate?.mouseDragged(to: location, button: button(for: heldIndex))
            } else {
                delegate?.mouseMoved(to: location)
            }
        }
    }

    private func button(for index: Int) -> MouseButton {
        switch index {
        case 0: return .left
        case 1: return .right
        default: return .other
        }
    }
}
