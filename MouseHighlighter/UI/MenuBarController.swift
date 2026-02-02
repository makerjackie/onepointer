import Cocoa
import Combine

final class MenuBarController {
    private var statusItem: NSStatusItem?
    private var menu: NSMenu?
    private var cancellables = Set<AnyCancellable>()

    weak var delegate: MenuBarControllerDelegate?

    init() {
        setupStatusItem()
        setupBindings()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            button.image = createMenuBarIcon()
            button.image?.isTemplate = true
        }

        menu = createMenu()
        statusItem?.menu = menu
    }

    private func createMenuBarIcon() -> NSImage {
        let size = NSSize(width: 18, height: 18)
        let image = NSImage(size: size, flipped: false) { rect in
            let circleRect = rect.insetBy(dx: 2, dy: 2)

            NSColor.labelColor.setStroke()

            let path = NSBezierPath(ovalIn: circleRect)
            path.lineWidth = 1.5
            path.stroke()

            let centerRect = circleRect.insetBy(dx: 5, dy: 5)
            let centerPath = NSBezierPath(ovalIn: centerRect)
            NSColor.labelColor.setFill()
            centerPath.fill()

            return true
        }

        return image
    }

    private func createMenu() -> NSMenu {
        let menu = NSMenu()

        let enabledItem = NSMenuItem(title: "Enabled", action: #selector(toggleEnabled), keyEquivalent: "e")
        enabledItem.target = self
        enabledItem.state = SettingsManager.shared.isEnabled ? .on : .off
        menu.addItem(enabledItem)

        menu.addItem(NSMenuItem.separator())

        let styleMenu = NSMenu()
        for style in HighlightStyle.allCases {
            let item = NSMenuItem(title: style.rawValue, action: #selector(selectHighlightStyle(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = style
            item.state = SettingsManager.shared.highlightStyle == style ? .on : .off
            styleMenu.addItem(item)
        }
        let styleItem = NSMenuItem(title: "Highlight Style", action: nil, keyEquivalent: "")
        styleItem.submenu = styleMenu
        menu.addItem(styleItem)

        let effectMenu = NSMenu()
        for effect in ClickEffect.allCases {
            let item = NSMenuItem(title: effect.rawValue, action: #selector(selectClickEffect(_:)), keyEquivalent: "")
            item.target = self
            item.representedObject = effect
            item.state = SettingsManager.shared.clickEffect == effect ? .on : .off
            effectMenu.addItem(item)
        }
        let effectItem = NSMenuItem(title: "Click Effect", action: nil, keyEquivalent: "")
        effectItem.submenu = effectMenu
        menu.addItem(effectItem)

        menu.addItem(NSMenuItem.separator())

        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(NSMenuItem.separator())

        let quitItem = NSMenuItem(title: "Quit Mouse Highlighter", action: #selector(quitApp), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)

        return menu
    }

    private func setupBindings() {
        SettingsManager.shared.$isEnabled
            .sink { [weak self] enabled in
                self?.updateMenuState()
            }
            .store(in: &cancellables)

        SettingsManager.shared.$highlightStyle
            .sink { [weak self] _ in
                self?.updateMenuState()
            }
            .store(in: &cancellables)

        SettingsManager.shared.$clickEffect
            .sink { [weak self] _ in
                self?.updateMenuState()
            }
            .store(in: &cancellables)
    }

    private func updateMenuState() {
        guard let menu = menu else { return }

        if let enabledItem = menu.item(withTitle: "Enabled") {
            enabledItem.state = SettingsManager.shared.isEnabled ? .on : .off
        }

        if let styleItem = menu.item(withTitle: "Highlight Style"),
           let styleMenu = styleItem.submenu {
            for item in styleMenu.items {
                if let style = item.representedObject as? HighlightStyle {
                    item.state = SettingsManager.shared.highlightStyle == style ? .on : .off
                }
            }
        }

        if let effectItem = menu.item(withTitle: "Click Effect"),
           let effectMenu = effectItem.submenu {
            for item in effectMenu.items {
                if let effect = item.representedObject as? ClickEffect {
                    item.state = SettingsManager.shared.clickEffect == effect ? .on : .off
                }
            }
        }
    }

    @objc private func toggleEnabled() {
        SettingsManager.shared.isEnabled.toggle()
    }

    @objc private func selectHighlightStyle(_ sender: NSMenuItem) {
        guard let style = sender.representedObject as? HighlightStyle else { return }
        SettingsManager.shared.highlightStyle = style
    }

    @objc private func selectClickEffect(_ sender: NSMenuItem) {
        guard let effect = sender.representedObject as? ClickEffect else { return }
        SettingsManager.shared.clickEffect = effect
    }

    @objc private func openSettings() {
        delegate?.menuBarControllerDidRequestSettings()
    }

    @objc private func quitApp() {
        NSApplication.shared.terminate(nil)
    }

    func updateIcon(enabled: Bool) {
        if let button = statusItem?.button {
            button.image?.isTemplate = enabled
            if !enabled {
                button.alphaValue = 0.5
            } else {
                button.alphaValue = 1.0
            }
        }
    }
}

protocol MenuBarControllerDelegate: AnyObject {
    func menuBarControllerDidRequestSettings()
}
