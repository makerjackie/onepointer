import Cocoa
import Combine

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

final class MouseEventMonitor {
    weak var delegate: MouseEventDelegate?

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var isRunning = false

    private let mouseMovedSubject = PassthroughSubject<NSPoint, Never>()
    private let mouseDownSubject = PassthroughSubject<(NSPoint, MouseButton), Never>()
    private let mouseUpSubject = PassthroughSubject<(NSPoint, MouseButton), Never>()
    private let mouseDraggedSubject = PassthroughSubject<(NSPoint, MouseButton), Never>()

    var mouseMovedPublisher: AnyPublisher<NSPoint, Never> {
        mouseMovedSubject.eraseToAnyPublisher()
    }

    var mouseDownPublisher: AnyPublisher<(NSPoint, MouseButton), Never> {
        mouseDownSubject.eraseToAnyPublisher()
    }

    var mouseUpPublisher: AnyPublisher<(NSPoint, MouseButton), Never> {
        mouseUpSubject.eraseToAnyPublisher()
    }

    var mouseDraggedPublisher: AnyPublisher<(NSPoint, MouseButton), Never> {
        mouseDraggedSubject.eraseToAnyPublisher()
    }

    func start() -> Bool {
        guard !isRunning else { return true }

        var eventMask: CGEventMask = 0
        eventMask |= (1 << CGEventType.mouseMoved.rawValue)
        eventMask |= (1 << CGEventType.leftMouseDown.rawValue)
        eventMask |= (1 << CGEventType.leftMouseUp.rawValue)
        eventMask |= (1 << CGEventType.leftMouseDragged.rawValue)
        eventMask |= (1 << CGEventType.rightMouseDown.rawValue)
        eventMask |= (1 << CGEventType.rightMouseUp.rawValue)
        eventMask |= (1 << CGEventType.rightMouseDragged.rawValue)
        eventMask |= (1 << CGEventType.otherMouseDown.rawValue)
        eventMask |= (1 << CGEventType.otherMouseUp.rawValue)
        eventMask |= (1 << CGEventType.otherMouseDragged.rawValue)

        let refcon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: eventMask,
            callback: { (proxy, type, event, refcon) -> Unmanaged<CGEvent>? in
                guard let refcon = refcon else { return Unmanaged.passRetained(event) }
                let monitor = Unmanaged<MouseEventMonitor>.fromOpaque(refcon).takeUnretainedValue()
                monitor.handleEvent(type: type, event: event)
                return Unmanaged.passRetained(event)
            },
            userInfo: refcon
        ) else {
            return false
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)

        if let source = runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
            CGEvent.tapEnable(tap: tap, enable: true)
            isRunning = true
            return true
        }

        return false
    }

    func stop() {
        guard isRunning else { return }

        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), source, .commonModes)
        }

        eventTap = nil
        runLoopSource = nil
        isRunning = false
    }

    private func handleEvent(type: CGEventType, event: CGEvent) {
        let location = event.location
        let point = NSPoint(x: location.x, y: location.y)

        switch type {
        case .mouseMoved:
            delegate?.mouseMoved(to: point)
            mouseMovedSubject.send(point)

        case .leftMouseDown:
            delegate?.mouseDown(at: point, button: .left)
            mouseDownSubject.send((point, .left))

        case .leftMouseUp:
            delegate?.mouseUp(at: point, button: .left)
            mouseUpSubject.send((point, .left))

        case .leftMouseDragged:
            delegate?.mouseDragged(to: point, button: .left)
            mouseDraggedSubject.send((point, .left))

        case .rightMouseDown:
            delegate?.mouseDown(at: point, button: .right)
            mouseDownSubject.send((point, .right))

        case .rightMouseUp:
            delegate?.mouseUp(at: point, button: .right)
            mouseUpSubject.send((point, .right))

        case .rightMouseDragged:
            delegate?.mouseDragged(to: point, button: .right)
            mouseDraggedSubject.send((point, .right))

        case .otherMouseDown:
            delegate?.mouseDown(at: point, button: .other)
            mouseDownSubject.send((point, .other))

        case .otherMouseUp:
            delegate?.mouseUp(at: point, button: .other)
            mouseUpSubject.send((point, .other))

        case .otherMouseDragged:
            delegate?.mouseDragged(to: point, button: .other)
            mouseDraggedSubject.send((point, .other))

        default:
            break
        }
    }

    deinit {
        stop()
    }
}
