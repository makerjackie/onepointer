import SwiftUI

struct SettingsView: View {
    @ObservedObject var settings = SettingsManager.shared
    @ObservedObject var permissions = PermissionsManager.shared

    var body: some View {
        TabView {
            GeneralSettingsView(settings: settings, permissions: permissions)
                .tabItem {
                    Label("General", systemImage: "gear")
                }

            HighlightSettingsView(settings: settings)
                .tabItem {
                    Label("Highlight", systemImage: "circle.circle")
                }

            EffectsSettingsView(settings: settings)
                .tabItem {
                    Label("Effects", systemImage: "sparkles")
                }
        }
        .frame(width: 450, height: 380)
        .padding()
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @ObservedObject var permissions: PermissionsManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox(label: Text("Enable").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Enable Mouse Highlighter", isOn: $settings.isEnabled)
                            .toggleStyle(.switch)
                        Toggle("Enable Click Effects", isOn: $settings.isClickEffectEnabled)
                            .toggleStyle(.switch)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox(label: Text("Permissions").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        if permissions.hasInputMonitoringPermission {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Input Monitoring Permission Granted")
                            }
                        } else {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                                Text("Input Monitoring Permission Required")
                            }

                            Text("Mouse Highlighter needs permission to track mouse movement and clicks.")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Button("Open System Settings") {
                                permissions.openSystemPreferences()
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                GroupBox(label: Text("Startup").font(.headline)) {
                    VStack(alignment: .leading, spacing: 8) {
                        Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                        Toggle("Show in Dock", isOn: $settings.showInDock)
                    }
                    .padding(.vertical, 4)
                }

                GroupBox {
                    Button("Reset to Defaults") {
                        settings.resetToDefaults()
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}

struct HighlightSettingsView: View {
    @ObservedObject var settings: SettingsManager
    @State private var selectedColor: Color

    init(settings: SettingsManager) {
        self.settings = settings
        _selectedColor = State(initialValue: Color(settings.highlightColor))
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox(label: Text("Highlight Style").font(.headline)) {
                    Picker("Style", selection: $settings.highlightStyle) {
                        ForEach(HighlightStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .labelsHidden()
                    .padding(.vertical, 4)
                }

                GroupBox(label: Text("Appearance").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        ColorPicker("Highlight Color", selection: $selectedColor, supportsOpacity: false)
                            .onChange(of: selectedColor) { newValue in
                                settings.highlightColor = NSColor(newValue)
                            }

                        VStack(alignment: .leading) {
                            HStack {
                                Text("Size")
                                Spacer()
                                Text("\(Int(settings.highlightSize)) px")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.highlightSize, in: 20...100, step: 1)
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Text("Opacity")
                                Spacer()
                                Text("\(Int(settings.highlightOpacity * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.highlightOpacity, in: 0.1...1.0, step: 0.05)
                        }
                    }
                    .padding(.vertical, 4)
                }

                if settings.highlightStyle == .spotlight {
                    GroupBox(label: Text("Spotlight Settings").font(.headline)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Dim Opacity")
                                Spacer()
                                Text("\(Int(settings.spotlightDimOpacity * 100))%")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.spotlightDimOpacity, in: 0.3...0.9, step: 0.05)
                        }
                        .padding(.vertical, 4)
                    }
                }

                if settings.highlightStyle == .ring {
                    GroupBox(label: Text("Ring Settings").font(.headline)) {
                        VStack(alignment: .leading, spacing: 12) {
                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Ring Thickness")
                                    Spacer()
                                    Text("\(Int(settings.ringThickness)) px")
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $settings.ringThickness, in: 1...10, step: 0.5)
                            }

                            VStack(alignment: .leading) {
                                HStack {
                                    Text("Glow Intensity")
                                    Spacer()
                                    Text("\(Int(settings.ringGlowIntensity * 100))%")
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $settings.ringGlowIntensity, in: 0...1.0, step: 0.1)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .padding()
        }
    }
}

struct EffectsSettingsView: View {
    @ObservedObject var settings: SettingsManager

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox(label: Text("Click Effect").font(.headline)) {
                    Picker("Click Effect", selection: $settings.clickEffect) {
                        ForEach(ClickEffect.allCases, id: \.self) { effect in
                            Text(effect.rawValue).tag(effect)
                        }
                    }
                    .pickerStyle(.radioGroup)
                    .labelsHidden()
                    .padding(.vertical, 4)
                }

                if settings.clickEffect != .none {
                    GroupBox(label: Text("Timing").font(.headline)) {
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Effect Duration")
                                Spacer()
                                Text("\(String(format: "%.2f", settings.effectDuration))s")
                                    .foregroundColor(.secondary)
                            }
                            Slider(value: $settings.effectDuration, in: 0.1...1.0, step: 0.05)
                        }
                        .padding(.vertical, 4)
                    }
                }

                GroupBox(label: Text("Help").font(.headline)) {
                    VStack(alignment: .leading, spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Ripple")
                                .fontWeight(.medium)
                            Text("An expanding circle that fades out from the click location.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Color Flash")
                                .fontWeight(.medium)
                            Text("A brief flash of color at the click point.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Shrink & Bounce")
                                .fontWeight(.medium)
                            Text("The highlight shrinks then bounces back with a spring effect.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding()
        }
    }
}

class SettingsWindowController {
    private var window: NSWindow?

    func showSettings() {
        NSApp.setActivationPolicy(.regular)

        if let existingWindow = window {
            existingWindow.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let settingsView = SettingsView()
        let hostingController = NSHostingController(rootView: settingsView)

        let newWindow = NSWindow(contentViewController: hostingController)
        newWindow.title = "Mac Mouse Highlighter Settings"
        newWindow.styleMask = [.titled, .closable, .miniaturizable]
        newWindow.center()
        newWindow.setFrameAutosaveName("SettingsWindow")
        newWindow.isReleasedWhenClosed = false
        newWindow.level = .floating

        window = newWindow
        newWindow.makeKeyAndOrderFront(nil)
        newWindow.orderFrontRegardless()
        NSApp.activate(ignoringOtherApps: true)
    }
}
