import SwiftUI

struct QuickFocusSection: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        SettingsCard(title: "Quick Focus", systemImage: "scope") {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Double-tap \(settings.quickFocusModifier.localizedName)")
                        .font(.title3)
                        .bold()
                    Text("All displays dim briefly while a spotlight contracts toward the pointer.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 7) {
                    ShortcutKeyView(
                        label: settings.quickFocusModifier.symbol,
                        accessibilityLabel: settings.quickFocusModifier.localizedName
                    )
                    Text("×2")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            Toggle(
                "Enable quick focus shortcut",
                isOn: $settings.quickFocusShortcutEnabled
            )

            if settings.quickFocusShortcutEnabled {
                Picker(
                    "Double-tap shortcut",
                    selection: $settings.quickFocusModifier
                ) {
                    ForEach(QuickFocusModifier.allCases) { modifier in
                        Text(modifier.localizedName)
                            .tag(modifier)
                    }
                }

                Text("Press and release the selected modifier twice by itself.")
                    .foregroundStyle(.secondary)
            }

            if settings.quickFocusShortcutEnabled && !appModel.isInputMonitoringGranted {
                Label {
                    Text("Input Monitoring is required only to recognize the modifier-key rhythm.")
                } icon: {
                    Image(systemName: "exclamationmark.shield")
                }
                .foregroundStyle(.orange)

                HStack {
                    Button(
                        "Allow Input Monitoring",
                        systemImage: "lock.open",
                        action: appModel.requestInputMonitoring
                    )
                    .buttonStyle(.borderedProminent)

                    Button(
                        "Open System Settings",
                        action: appModel.openInputMonitoringSettings
                    )
                }
            } else if settings.quickFocusShortcutEnabled {
                Label("Ready", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }

            Button(
                "Focus Pointer Now",
                systemImage: "scope",
                action: appModel.focusNow
            )
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
    }
}
