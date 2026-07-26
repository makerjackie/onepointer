import AppKit
import CoreGraphics

@MainActor
final class DoubleControlMonitor {
    var onDoubleControl: (() -> Void)?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var recognizer = DoubleControlTapRecognizer()

    var isRunning: Bool {
        eventTap != nil
    }

    @discardableResult
    func start() -> Bool {
        guard !isRunning else {
            return true
        }

        let eventMask = CGEventMask(
            (1 << CGEventType.flagsChanged.rawValue)
                | (1 << CGEventType.keyDown.rawValue)
                | (1 << CGEventType.leftMouseDown.rawValue)
                | (1 << CGEventType.rightMouseDown.rawValue)
                | (1 << CGEventType.otherMouseDown.rawValue)
        )

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let monitor = Unmanaged<DoubleControlMonitor>
                .fromOpaque(userInfo)
                .takeUnretainedValue()

            MainActor.assumeIsolated {
                monitor.handle(type: type, event: event)
            }

            return Unmanaged.passUnretained(event)
        }

        let userInfo = Unmanaged.passUnretained(self).toOpaque()
        guard let eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: callback,
            userInfo: userInfo
        ) else {
            return false
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)

        self.eventTap = eventTap
        runLoopSource = source
        return true
    }

    func stop() {
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        if let eventTap {
            CGEvent.tapEnable(tap: eventTap, enable: false)
        }
        runLoopSource = nil
        eventTap = nil
        recognizer = DoubleControlTapRecognizer()
    }

    private func handle(type: CGEventType, event: CGEvent) {
        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            return
        }

        let timestamp = ProcessInfo.processInfo.systemUptime

        guard type == .flagsChanged else {
            _ = recognizer.consume(.otherInput(timestamp: timestamp))
            return
        }

        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let side: ControlKeySide
        switch keyCode {
        case 59:
            side = .left
        case 62:
            side = .right
        default:
            _ = recognizer.consume(.otherInput(timestamp: timestamp))
            return
        }

        let isPressed = event.flags.contains(.maskControl)
        if recognizer.consume(
            .controlChanged(side: side, isPressed: isPressed, timestamp: timestamp)
        ) {
            onDoubleControl?()
        }
    }
}
