import Cocoa
import Combine
import ServiceManagement

enum HighlightStyle: String, CaseIterable, Codable {
    case circle = "Circle"
    case spotlight = "Spotlight"
    case ring = "Ring"
}

enum ClickEffect: String, CaseIterable, Codable {
    case none = "None"
    case ripple = "Ripple"
    case colorFlash = "Color Flash"
    case shrinkBounce = "Shrink & Bounce"
}

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Keys {
        static let isEnabled = "isEnabled"
        static let isClickEffectEnabled = "isClickEffectEnabled"
        static let highlightStyle = "highlightStyle"
        static let clickEffect = "clickEffect"
        static let highlightColor = "highlightColor"
        static let highlightSize = "highlightSize"
        static let highlightOpacity = "highlightOpacity"
        static let spotlightDimOpacity = "spotlightDimOpacity"
        static let ringGlowIntensity = "ringGlowIntensity"
        static let ringThickness = "ringThickness"
        static let effectDuration = "effectDuration"
        static let launchAtLogin = "launchAtLogin"
        static let showInDock = "showInDock"
    }

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled)
        }
    }

    @Published var isClickEffectEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isClickEffectEnabled, forKey: Keys.isClickEffectEnabled)
        }
    }

    @Published var highlightStyle: HighlightStyle {
        didSet {
            UserDefaults.standard.set(highlightStyle.rawValue, forKey: Keys.highlightStyle)
        }
    }

    @Published var clickEffect: ClickEffect {
        didSet {
            UserDefaults.standard.set(clickEffect.rawValue, forKey: Keys.clickEffect)
        }
    }

    @Published var highlightColor: NSColor {
        didSet {
            saveColor(highlightColor, forKey: Keys.highlightColor)
        }
    }

    @Published var highlightSize: CGFloat {
        didSet {
            UserDefaults.standard.set(highlightSize, forKey: Keys.highlightSize)
        }
    }

    @Published var highlightOpacity: CGFloat {
        didSet {
            UserDefaults.standard.set(highlightOpacity, forKey: Keys.highlightOpacity)
        }
    }

    @Published var spotlightDimOpacity: CGFloat {
        didSet {
            UserDefaults.standard.set(spotlightDimOpacity, forKey: Keys.spotlightDimOpacity)
        }
    }

    @Published var ringGlowIntensity: CGFloat {
        didSet {
            UserDefaults.standard.set(ringGlowIntensity, forKey: Keys.ringGlowIntensity)
        }
    }

    @Published var ringThickness: CGFloat {
        didSet {
            UserDefaults.standard.set(ringThickness, forKey: Keys.ringThickness)
        }
    }

    @Published var effectDuration: CGFloat {
        didSet {
            UserDefaults.standard.set(effectDuration, forKey: Keys.effectDuration)
        }
    }

    @Published var launchAtLogin: Bool {
        didSet {
            UserDefaults.standard.set(launchAtLogin, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin()
        }
    }

    @Published var showInDock: Bool {
        didSet {
            UserDefaults.standard.set(showInDock, forKey: Keys.showInDock)
            updateDockVisibility()
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? true
        isClickEffectEnabled = defaults.object(forKey: Keys.isClickEffectEnabled) as? Bool ?? true

        if let styleRaw = defaults.string(forKey: Keys.highlightStyle),
           let style = HighlightStyle(rawValue: styleRaw) {
            highlightStyle = style
        } else {
            highlightStyle = .circle
        }

        if let effectRaw = defaults.string(forKey: Keys.clickEffect),
           let effect = ClickEffect(rawValue: effectRaw) {
            clickEffect = effect
        } else {
            clickEffect = .ripple
        }

        highlightColor = Self.loadColor(forKey: Keys.highlightColor) ?? NSColor.systemYellow
        highlightSize = defaults.object(forKey: Keys.highlightSize) as? CGFloat ?? 40.0
        highlightOpacity = defaults.object(forKey: Keys.highlightOpacity) as? CGFloat ?? 0.5
        spotlightDimOpacity = defaults.object(forKey: Keys.spotlightDimOpacity) as? CGFloat ?? 0.7
        ringGlowIntensity = defaults.object(forKey: Keys.ringGlowIntensity) as? CGFloat ?? 0.8
        ringThickness = defaults.object(forKey: Keys.ringThickness) as? CGFloat ?? 3.0
        effectDuration = defaults.object(forKey: Keys.effectDuration) as? CGFloat ?? 0.3
        launchAtLogin = defaults.object(forKey: Keys.launchAtLogin) as? Bool ?? false
        showInDock = defaults.object(forKey: Keys.showInDock) as? Bool ?? true
    }

    private func saveColor(_ color: NSColor, forKey key: String) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: color, requiringSecureCoding: true) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }

    private static func loadColor(forKey key: String) -> NSColor? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data)
    }

    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }

    private func updateDockVisibility() {
        if showInDock {
            NSApp.setActivationPolicy(.regular)
        } else {
            NSApp.setActivationPolicy(.accessory)
        }
    }

    func resetToDefaults() {
        isEnabled = true
        isClickEffectEnabled = true
        highlightStyle = .circle
        clickEffect = .ripple
        highlightColor = NSColor.systemYellow
        highlightSize = 40.0
        highlightOpacity = 0.5
        spotlightDimOpacity = 0.7
        ringGlowIntensity = 0.8
        ringThickness = 3.0
        effectDuration = 0.3
        launchAtLogin = false
        showInDock = true
    }
}
