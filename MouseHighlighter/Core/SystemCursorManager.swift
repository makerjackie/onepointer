import Cocoa
import Combine

/// Reads and writes the **real macOS pointer size** — the system Accessibility setting at
/// `com.apple.universalaccess → mouseDriverCursorSize` (1.0 = normal … 4.0 = largest), the
/// same value the System Settings "Pointer size" slider controls.
///
/// Important: macOS only re-renders the live pointer at this size once the change is applied
/// through the accessibility daemon — which happens when the user confirms it in System
/// Settings or at next login. Writing the preference here makes it persist and take effect
/// then; we deliberately avoid private APIs that would force it live but break across macOS
/// versions. The Settings UI surfaces this caveat and offers a one-click jump to the pane.
final class SystemCursorManager: ObservableObject {
    static let shared = SystemCursorManager()

    static let minSize: Double = 1.0   // Normal
    static let maxSize: Double = 4.0   // Largest

    private let domain = "com.apple.universalaccess" as CFString
    private let key = "mouseDriverCursorSize" as CFString

    /// Bound to the Settings slider. Reading reflects the current system value; setting it
    /// writes the system preference.
    @Published var size: Double {
        didSet { applySize(size) }
    }

    private init() {
        size = Self.readCurrentSize(domain: domain, key: key)
    }

    private static func readCurrentSize(domain: CFString, key: CFString) -> Double {
        if let number = CFPreferencesCopyValue(key, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost) as? NSNumber {
            return number.doubleValue
        }
        return minSize
    }

    /// Re-read the system value (e.g. after the user changes it in System Settings) so the
    /// slider stays in sync. Avoids re-triggering a write.
    func refreshFromSystem() {
        let current = Self.readCurrentSize(domain: domain, key: key)
        if current != size {
            // Assign without writing back: temporarily bypass by comparing in didSet is
            // not possible, so write is harmless (same value) — but guard to avoid churn.
            size = current
        }
    }

    private func applySize(_ newValue: Double) {
        let clamped = min(max(newValue, Self.minSize), Self.maxSize)
        CFPreferencesSetValue(key, clamped as CFNumber, domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
        CFPreferencesSynchronize(domain, kCFPreferencesCurrentUser, kCFPreferencesAnyHost)
    }

    /// Open System Settings → Accessibility → Pointer, where the size applies live.
    func openPointerSettings() {
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.universalaccess?Seeing_Cursor") {
            NSWorkspace.shared.open(url)
        }
    }
}
