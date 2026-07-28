import SwiftUI

struct QuickFocusControlBar: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        VStack(spacing: 0) {
            settingsRow {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Enable quick focus shortcut")
                        .font(.headline)
                    Text("Use the shortcut to focus the pointer from any app.")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            } trailing: {
                Toggle(
                    "Enable quick focus shortcut",
                    isOn: $settings.quickFocusShortcutEnabled
                )
                .labelsHidden()
            }

            Divider()

            settingsRow {
                Text("Trigger")
            } trailing: {
                Text("Double-tap \(settings.quickFocusModifier.localizedName)")
                    .foregroundStyle(.secondary)
            }

            Divider()

            settingsRow {
                Text("Modifier key")
            } trailing: {
                Picker(
                    "Double-tap shortcut",
                    selection: $settings.quickFocusModifier
                ) {
                    ForEach(QuickFocusModifier.allCases) { modifier in
                        Text(modifier.localizedName)
                            .tag(modifier)
                    }
                }
                .labelsHidden()
                .frame(width: 150)
                .disabled(!settings.quickFocusShortcutEnabled)
            }

            Divider()

            settingsRow {
                Text("Status")
            } trailing: {
                shortcutStatus
            }

            if settings.quickFocusShortcutEnabled && !appModel.isInputMonitoringGranted {
                Divider()
                InputMonitoringPermissionRow(appModel: appModel)
            }

            Divider()

            HStack {
                Spacer()
                focusButton
            }
            .padding(14)
        }
        .background(Color(nsColor: .controlBackgroundColor))
        .clipShape(.rect(cornerRadius: DesignTokens.cardRadius))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.cardRadius)
                .stroke(Color(nsColor: .separatorColor).opacity(0.5), lineWidth: 1)
        }
    }

    @ViewBuilder
    private var shortcutStatus: some View {
        if !settings.quickFocusShortcutEnabled {
            Label("Off", systemImage: "pause.circle")
                .foregroundStyle(.secondary)
        } else if appModel.isInputMonitoringGranted {
            Label("Ready", systemImage: "checkmark.circle.fill")
                .foregroundStyle(.green)
        } else {
            Label("Permission Required", systemImage: "exclamationmark.shield")
                .foregroundStyle(.orange)
        }
    }

    private var focusButton: some View {
        Button(
            "Focus Pointer Now",
            systemImage: "scope",
            action: appModel.focusNow
        )
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
    }

    private func settingsRow<Leading: View, Trailing: View>(
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing
    ) -> some View {
        HStack(alignment: .center, spacing: 16) {
            leading()
            Spacer()
            trailing()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
