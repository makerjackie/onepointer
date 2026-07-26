import SwiftUI

struct QuickFocusSection: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        SettingsCard(title: "Quick Focus", systemImage: "scope") {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Double-tap Control")
                        .font(.title3)
                        .bold()
                    Text("All displays dim briefly while a spotlight follows the pointer.")
                        .foregroundStyle(.secondary)
                }

                Spacer()

                HStack(spacing: 7) {
                    ShortcutKeyView(label: "control")
                    Text("×2")
                        .foregroundStyle(.secondary)
                }
            }

            Divider()

            Toggle("Enable double-tap Control", isOn: $settings.doubleControlEnabled)

            if settings.doubleControlEnabled && !appModel.isInputMonitoringGranted {
                Label {
                    Text("Input Monitoring is required only to recognize the Control-key rhythm.")
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
            } else if settings.doubleControlEnabled {
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
