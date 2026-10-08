import Cocoa
import Combine
import ServiceManagement

enum HighlightStyle: String, CaseIterable, Codable {
    case circle = "Circle"
    case spotlight = "Spotlight"
    case ring = "Ring"
    case crosshair = "Crosshair"
    case pulse = "Pulse"

    var localizedName: String {
        switch self {
        case .circle:
            String(localized: "Circle")
        case .spotlight:
            String(localized: "Spotlight")
        case .ring:
            String(localized: "Ring")
        case .crosshair:
            String(localized: "Crosshair")
        case .pulse:
            String(localized: "Pulse")
        }
    }
}

enum ClickEffect: String, CaseIterable, Codable {
    case none = "None"
    case ripple = "Ripple"
    case colorFlash = "Color Flash"
    case shrinkBounce = "Shrink & Bounce"

    var localizedName: String {
        switch self {
        case .none:
            String(localized: "None")
        case .ripple:
            String(localized: "Ripple")
        case .colorFlash:
            String(localized: "Color Flash")
        case .shrinkBounce:
            String(localized: "Shrink & Bounce")
        }
    }
}

final class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    private enum Keys {
        static let isEnabled = "isEnabled"
        static let legacyDoubleControlEnabled = "doubleControlEnabled"
        static let quickFocusShortcutEnabled = "quickFocusShortcutEnabled"
        static let quickFocusModifier = "quickFocusModifier"
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
        static let showMenuBarIcon = "showMenuBarIcon"
        // Crosshair settings
        static let crosshairLength = "crosshairLength"
        static let crosshairThickness = "crosshairThickness"
        static let crosshairStyle = "crosshairStyle"
        // Pulse settings
        static let pulseSpeed = "pulseSpeed"
        static let pulseIntensity = "pulseIntensity"
        // Performance settings
        static let targetFrameRate = "targetFrameRate"
    }

    @Published var isEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isEnabled, forKey: Keys.isEnabled)
        }
    }

    @Published var quickFocusShortcutEnabled: Bool {
        didSet {
            UserDefaults.standard.set(
                quickFocusShortcutEnabled,
                forKey: Keys.quickFocusShortcutEnabled
            )
        }
    }

    @Published var quickFocusModifier: QuickFocusModifier {
        didSet {
            UserDefaults.standard.set(
                quickFocusModifier.rawValue,
                forKey: Keys.quickFocusModifier
            )
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

    @Published private(set) var launchAtLoginError: String?

    /// When on, OnePointer runs as a menu-bar-only app: it disappears from the
    /// Dock and from ⌘⇥, and the status item in the menu bar becomes the only
    /// way to reach the settings window or quit.
    @Published var showMenuBarIcon: Bool {
        didSet {
            UserDefaults.standard.set(showMenuBarIcon, forKey: Keys.showMenuBarIcon)
            applyActivationPolicy()
        }
    }

    // Crosshair settings
    @Published var crosshairLength: CGFloat {
        didSet {
            UserDefaults.standard.set(crosshairLength, forKey: Keys.crosshairLength)
        }
    }

    @Published var crosshairThickness: CGFloat {
        didSet {
            UserDefaults.standard.set(crosshairThickness, forKey: Keys.crosshairThickness)
        }
    }

    @Published var crosshairStyle: CrosshairStyle {
        didSet {
            UserDefaults.standard.set(crosshairStyle.rawValue, forKey: Keys.crosshairStyle)
        }
    }

    // Pulse settings
    @Published var pulseSpeed: PulseSpeed {
        didSet {
            UserDefaults.standard.set(pulseSpeed.rawValue, forKey: Keys.pulseSpeed)
        }
    }

    @Published var pulseIntensity: PulseIntensity {
        didSet {
            UserDefaults.standard.set(pulseIntensity.rawValue, forKey: Keys.pulseIntensity)
        }
    }

    // Performance settings
    @Published var targetFrameRate: Int {
        didSet {
            UserDefaults.standard.set(targetFrameRate, forKey: Keys.targetFrameRate)
        }
    }

    private init() {
        let defaults = UserDefaults.standard

        isEnabled = defaults.object(forKey: Keys.isEnabled) as? Bool ?? false
        quickFocusShortcutEnabled =
            defaults.object(forKey: Keys.quickFocusShortcutEnabled) as? Bool
                ?? defaults.object(forKey: Keys.legacyDoubleControlEnabled) as? Bool
                ?? true
        quickFocusModifier =
            defaults.string(forKey: Keys.quickFocusModifier)
                .flatMap(QuickFocusModifier.init(rawValue:))
                ?? .leftOption
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
        showMenuBarIcon = defaults.object(forKey: Keys.showMenuBarIcon) as? Bool ?? false

        // Crosshair settings
        crosshairLength = defaults.object(forKey: Keys.crosshairLength) as? CGFloat ?? 40.0
        crosshairThickness = defaults.object(forKey: Keys.crosshairThickness) as? CGFloat ?? 2.0

        if let crosshairStyleRaw = defaults.string(forKey: Keys.crosshairStyle),
           let style = CrosshairStyle(rawValue: crosshairStyleRaw) {
            crosshairStyle = style
        } else {
            crosshairStyle = .plus
        }

        // Pulse settings
        if let pulseSpeedRaw = defaults.string(forKey: Keys.pulseSpeed),
           let speed = PulseSpeed(rawValue: pulseSpeedRaw) {
            pulseSpeed = speed
        } else {
            pulseSpeed = .medium
        }

        if let pulseIntensityRaw = defaults.string(forKey: Keys.pulseIntensity),
           let intensity = PulseIntensity(rawValue: pulseIntensityRaw) {
            pulseIntensity = intensity
        } else {
            pulseIntensity = .moderate
        }

        // Performance settings
        targetFrameRate = defaults.object(forKey: Keys.targetFrameRate) as? Int ?? 60
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
                launchAtLoginError = nil
            } catch {
                launchAtLoginError = error.localizedDescription
            }
        }
    }

    /// Applies the activation policy that matches `showMenuBarIcon`. Called on
    /// every change and once at launch, before the app is on screen, so the
    /// Dock icon never flashes for menu-bar-only users.
    ///
    /// A regular app appears in the Dock and in ⌘⇥; an accessory app appears in
    /// neither but can still show windows and take focus when asked.
    func applyActivationPolicy() {
        NSApp.setActivationPolicy(showMenuBarIcon ? .accessory : .regular)
    }

    func resetToDefaults() {
        isEnabled = false
        quickFocusShortcutEnabled = true
        quickFocusModifier = .leftOption
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
        showMenuBarIcon = false
        // Crosshair defaults
        crosshairLength = 40.0
        crosshairThickness = 2.0
        crosshairStyle = .plus
        // Pulse defaults
        pulseSpeed = .medium
        pulseIntensity = .moderate
        // Performance defaults
        targetFrameRate = 60
    }

    func clearLaunchAtLoginError() {
        launchAtLoginError = nil
    }
}
