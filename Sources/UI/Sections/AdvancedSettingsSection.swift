import SwiftUI

struct AdvancedSettingsSection: View {
    @ObservedObject var appModel: AppModel
    @ObservedObject var settings: SettingsManager

    var body: some View {
        SettingsCard(title: "App Settings", systemImage: "gearshape") {
            HStack {
                Toggle("Launch OnePointer at login", isOn: $settings.launchAtLogin)

                Spacer()

                Button(
                    "Check for Updates…",
                    systemImage: "arrow.triangle.2.circlepath",
                    action: appModel.checkForUpdates
                )
            }

            Divider()

            Toggle("Hide the Dock and show in the menu bar", isOn: $settings.showMenuBarIcon)

            Text("Closing settings keeps OnePointer running. Choose Quit to stop all pointer effects.")
                .font(.caption)
                .foregroundStyle(.secondary)

            Divider()

            Picker("Presentation frame rate", selection: $settings.targetFrameRate) {
                Text("30 FPS").tag(30)
                Text("60 FPS").tag(60)
            }

            Divider()

            Button(
                "Reset to Defaults",
                action: settings.resetToDefaults
            )
        }
    }
}
