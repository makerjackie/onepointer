import Carbon.HIToolbox
import Foundation

/// Registers a single app-global hotkey to toggle the highlighter on/off.
///
/// Uses Carbon's `RegisterEventHotKey`, which — unlike `NSEvent` global keyboard
/// monitoring — requires **no** Accessibility/Input Monitoring permission. This keeps the
/// app permission-free end to end.
///
/// Default shortcut: ⌃⌥⌘H (Control-Option-Command-H).
final class HotKeyManager {
    /// Called on the main thread when the hotkey is pressed.
    var onToggle: (() -> Void)?

    /// Human-readable description of the current shortcut, for display in Settings.
    static let shortcutDescription = "⌃⌥⌘H"

    private var hotKeyRef: EventHotKeyRef?
    private var eventHandler: EventHandlerRef?

    // ⌃⌥⌘H
    private let keyCode = UInt32(kVK_ANSI_H)
    private let modifiers = UInt32(controlKey | optionKey | cmdKey)
    private let hotKeyID = EventHotKeyID(signature: OSType(0x4D484C54 /* "MHLT" */), id: 1)

    func register() {
        guard hotKeyRef == nil else { return }

        var eventType = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )

        let selfPtr = Unmanaged.passUnretained(self).toOpaque()

        InstallEventHandler(
            GetApplicationEventTarget(),
            { _, eventRef, userData -> OSStatus in
                guard let userData = userData, let eventRef = eventRef else { return noErr }
                var receivedID = EventHotKeyID()
                let status = GetEventParameter(
                    eventRef,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &receivedID
                )
                guard status == noErr else { return status }
                let manager = Unmanaged<HotKeyManager>.fromOpaque(userData).takeUnretainedValue()
                if receivedID.id == manager.hotKeyID.id {
                    DispatchQueue.main.async { manager.onToggle?() }
                }
                return noErr
            },
            1,
            &eventType,
            selfPtr,
            &eventHandler
        )

        RegisterEventHotKey(
            keyCode,
            modifiers,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
    }

    func unregister() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
    }

    deinit {
        unregister()
    }
}
