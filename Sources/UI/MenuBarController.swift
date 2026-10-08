import Cocoa

/// Owns the menu bar status item used while OnePointer runs as a
/// menu-bar-only app.
///
/// In that mode the app has no Dock icon and no ⌘⇥ entry, so this menu is the
/// only way to reach the settings window or quit. It is created when the
/// “Hide the Dock and show in the menu bar” setting is turned on and torn down
/// when it is turned back off.
final class MenuBarController: NSObject, NSMenuDelegate {
    private let statusItem: NSStatusItem
    private let appModel: AppModel
    private let settings: SettingsManager
    private let highlightItem = NSMenuItem(
        title: String(localized: "Keep a highlight around the pointer"),
        action: #selector(toggleHighlight),
        keyEquivalent: ""
    )

    weak var delegate: MenuBarControllerDelegate?

    init(appModel: AppModel, settings: SettingsManager) {
        self.appModel = appModel
        self.settings = settings
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        // A stable, app-specific autosave name. Status items without one get an
        // auto-assigned "Item-<n>", and macOS stores the menu bar position and
        // visibility of that name in the shared com.apple.controlcenter domain —
        // so unnamed items from different apps collide, and a position the user
        // drags the icon to would not reliably stick.
        statusItem.autosaveName = "studio.oneapps.onepointer.menuBarIcon"
        setupStatusItem()
        setupMenu()
    }

    /// Removes the status item from the menu bar.
    ///
    /// `NSStatusBar` keeps its own reference to the item, so the icon outlives
    /// the controller unless it is removed explicitly — dropping the controller
    /// alone is not enough.
    func invalidate() {
        NSStatusBar.system.removeStatusItem(statusItem)
    }

    private func setupStatusItem() {
        guard let button = statusItem.button else { return }
        button.image = Self.makeStatusIcon()
        button.image?.isTemplate = true
        button.toolTip = "OnePointer"
        button.setAccessibilityLabel("OnePointer")
    }

    private func setupMenu() {
        let menu = NSMenu()
        menu.delegate = self

        let focusItem = NSMenuItem(
            title: String(localized: "Focus Pointer Now"),
            action: #selector(focusPointer),
            keyEquivalent: ""
        )
        focusItem.target = self
        menu.addItem(focusItem)

        highlightItem.target = self
        menu.addItem(highlightItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(
            title: String(localized: "Open Settings…"),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        let updateItem = NSMenuItem(
            title: String(localized: "Check for Updates…"),
            action: #selector(checkForUpdates),
            keyEquivalent: ""
        )
        updateItem.target = self
        menu.addItem(updateItem)

        menu.addItem(.separator())

        let quitItem = NSMenuItem(
            title: String(localized: "Quit OnePointer"),
            action: #selector(quitApplication),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        statusItem.menu = menu
    }

    func menuWillOpen(_ menu: NSMenu) {
        highlightItem.state = settings.isEnabled ? .on : .off
    }

    @objc private func focusPointer() {
        appModel.focusNow()
    }

    @objc private func toggleHighlight() {
        settings.isEnabled.toggle()
    }

    @objc private func checkForUpdates() {
        appModel.checkForUpdates()
    }

    /// A focus ring with a pointer inside, matching the app icon.
    ///
    /// The shapes are drawn in black because the image is used as a template:
    /// the menu bar only reads the alpha channel and supplies the tint itself, so
    /// the icon follows the light and dark menu bar without extra work.
    private static func makeStatusIcon() -> NSImage {
        NSImage(size: NSSize(width: 18, height: 18), flipped: false) { rect in
            NSColor.black.setStroke()
            let ring = NSBezierPath(ovalIn: rect.insetBy(dx: 1.5, dy: 1.5))
            ring.lineWidth = 1.4
            ring.stroke()

            // The pointer sits slightly above and left of centre, the way it does
            // in the app icon, which keeps it visually balanced inside the ring.
            let side = rect.width * 10 / 18
            let pointerRect = NSRect(
                x: rect.midX - side / 2 - 0.3,
                y: rect.midY - side / 2 + 0.3,
                width: side,
                height: side
            )

            if let pointer = NSImage(
                systemSymbolName: "cursorarrow",
                accessibilityDescription: nil
            ) {
                pointer.draw(in: pointerRect)
            } else {
                Self.drawFallbackPointer(in: pointerRect)
            }

            return true
        }
    }

    /// A filled pointer arrow, used only if the system symbol is unavailable.
    private static func drawFallbackPointer(in rect: NSRect) {
        // An arrow designed in a 12.8 x 19.2 box, tip at the top left, with y
        // growing downwards like a CSS cursor polygon.
        let design = NSSize(width: 12.8, height: 19.2)
        func point(_ x: CGFloat, _ y: CGFloat) -> NSPoint {
            NSPoint(
                x: rect.minX + x / design.width * rect.width,
                y: rect.maxY - y / design.height * rect.height
            )
        }

        let path = NSBezierPath()
        path.move(to: point(0, 0))
        path.line(to: point(0, 16.4))
        path.line(to: point(4.4, 12.6))
        path.line(to: point(7.2, 19.2))
        path.line(to: point(10.2, 17.8))
        path.line(to: point(7.4, 11.2))
        path.line(to: point(12.8, 11.2))
        path.close()
        NSColor.black.setFill()
        path.fill()
    }

    @objc private func openSettings() {
        delegate?.menuBarControllerDidRequestSettings()
    }

    @objc private func quitApplication() {
        appModel.quit()
    }
}

protocol MenuBarControllerDelegate: AnyObject {
    func menuBarControllerDidRequestSettings()
}
