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
